"""Synthesis-based evaluation with Yosys, mirroring the course scoring script.

Course script (opti_demo/run_demo.sh):
    read_verilog -sv F; read_liberty -lib LIB; hierarchy -top TOP; proc; opt; techmap; opt;
    abc -liberty LIB; stat -liberty LIB; ltp
    area  = last  "Chip area for module '...': X"
    delay = last  "(length=N)"   (ltp = longest topological path, FF cells included)

Note: the course script does not flatten. For hierarchical inputs it then reports the area of
whatever module is printed last, which is meaningless.  We therefore score every design flattened
(identical numbers for the single-module designs we emit) and additionally record the literal
course numbers for the report.
"""

import json
import os
import re
import tempfile

from .util import run_cmd, tail

AREA_RE = re.compile(r"Chip area for module '([^']*)': ([0-9.]+)")
TOP_AREA_RE = re.compile(r"Chip area for top module '([^']*)': ([0-9.]+)")
LTP_RE = re.compile(r"\(length=([0-9]+)\)")
CELL_RE = re.compile(r"^\s+(\S+)\s+([0-9]+)\s*$", re.M)


def _q(path):
    # yosys command-line quoting for paths with spaces
    return '"' + path + '"' if " " in path else path


def read_cmds(files):
    return "; ".join(f"read_verilog -sv {_q(f)}" for f in files)


class SynthResult:
    def __init__(self):
        self.ok = False
        self.area = None          # float (um^2), combinational cells only (FF area unknown => 0)
        self.hier_area = None     # "Chip area for top module" (whole hierarchy), non-flattened runs only
        self.ltp = None           # int, longest topological path
        self.cells = {}           # cell type -> count (from the last stat block)
        self.n_ff = 0
        self.unknown_area_cells = []
        self.ltp_path = []
        self.log = ""
        self.error = ""
        self.seconds = 0.0

    def to_dict(self):
        return {"ok": self.ok, "area": self.area, "hier_area": self.hier_area, "ltp": self.ltp, "cells": self.cells,
                "n_ff": self.n_ff, "ltp_path": self.ltp_path, "error": self.error[-800:] if self.error else "",
                "seconds": round(self.seconds, 2)}


def _parse_stat(log, result, use_top_line=False):
    areas = AREA_RE.findall(log)
    tops = TOP_AREA_RE.findall(log)
    if use_top_line and tops:
        result.area = float(tops[-1][1])
    elif areas:
        result.area = float(areas[-1][1])
    if tops:
        result.hier_area = float(tops[-1][1])
    lt = LTP_RE.findall(log)
    if lt:
        result.ltp = int(lt[-1])
    # cell histogram of the last "Number of cells" block
    idx = log.rfind("Number of cells")
    if idx >= 0:
        block = log[idx: idx + 6000]
        end = block.find("Chip area")
        if end > 0:
            block = block[:end]
        cells = {}
        for name, cnt in CELL_RE.findall(block):
            if name.startswith("$") or re.match(r"^[A-Z][A-Z0-9]*_X\d+$", name):
                cells[name] = cells.get(name, 0) + int(cnt)
        result.cells = cells
        result.n_ff = sum(c for n, c in cells.items() if "DFF" in n or "DLATCH" in n or "SR_" in n)
    result.unknown_area_cells = sorted(set(re.findall(r"Area for cell type (\S+) is unknown", log)))
    result.ltp_path = parse_ltp_path(log)


def parse_ltp_path(log, limit=14):
    """Named signals along the longest topological path, e.g. ['A[15]', 'tmp_a[31]', 'odd[3]']."""
    idx = log.rfind("Longest topological path")
    if idx < 0:
        return []
    names = []
    for ln in log[idx:].splitlines()[1:]:
        m = re.match(r"\s*(\d+|ff):\s+(\S+)(\s*\[\d+\])?", ln)
        if not m:
            if names and not ln.strip():
                break
            continue
        sig = m.group(2)
        if not sig.startswith("\\"):
            continue                      # abc-internal net
        name = sig[1:] + (m.group(3).replace(" ", "") if m.group(3) else "")
        base = re.sub(r"\[\d+\]$", "", name)
        if names and re.sub(r"\[\d+\]$", "", names[-1]) == base:
            names[-1] = name
            continue
        names.append(name)
    if len(names) > limit:
        names = names[: limit // 2] + ["..."] + names[-limit // 2:]
    return names


def synth_eval(cfg, files, top, flatten=True, timeout=600, extra_log=False):
    """Score a design with the course flow (optionally flattened). Returns SynthResult."""
    res = SynthResult()
    lib = _q(cfg.lib_file)
    script = (f"{read_cmds(files)}; read_liberty -lib {lib}; hierarchy -top {top}; "
              + ("flatten; " if flatten else "")
              + f"proc; opt; techmap; opt; abc -liberty {lib}; stat -liberty {lib}; ltp")
    rc, out, err, sec = run_cmd([cfg.yosys, "-p", script], timeout=timeout)
    res.seconds = sec
    res.log = out if extra_log else ""
    if rc != 0:
        res.error = tail(_yosys_error(out + err), 1500)
        return res
    _parse_stat(out, res)
    res.ok = res.area is not None and res.ltp is not None
    if not res.ok:
        res.error = "could not parse area/ltp from yosys log"
    return res


def course_eval(cfg, files, top, timeout=600):
    """Literal course numbers (no flatten, last 'Chip area for module' line)."""
    return synth_eval(cfg, files, top, flatten=False, timeout=timeout)


def _yosys_error(text):
    lines = text.splitlines()
    keep = [ln for ln in lines if re.search(r"ERROR|Error|error:|syntax error|Warning: .*(latch|driver|undriven|multiple)", ln)]
    if keep:
        return "\n".join(keep[-12:])
    return "\n".join(lines[-15:])


def lint(cfg, files, top, timeout=120):
    """Parse + elaborate with yosys; returns (ok, message, warnings)."""
    script = f"{read_cmds(files)}; hierarchy -check -top {top}; proc; check -assert"
    rc, out, err, _ = run_cmd([cfg.yosys, "-p", script], timeout=timeout)
    warns = [ln.strip() for ln in out.splitlines() if ln.strip().startswith("Warning")]
    if rc != 0:
        # check -assert failing on warnings like multiple drivers -> report them
        return False, _yosys_error(out + err), warns
    return True, "", warns


def design_json(cfg, files, top, flatten=True, timeout=180):
    """Elaborated design as yosys JSON (after proc + opt_dff), for structural analysis."""
    with tempfile.TemporaryDirectory(prefix="rtlagent_json_") as td:
        jf = os.path.join(td, "d.json")
        script = (f"{read_cmds(files)}; hierarchy -top {top}; "
                  + ("flatten; " if flatten else "")
                  + ("proc; opt_clean; opt_dff; opt_clean; " if cfg.modern_yosys() else "proc; opt; ")
                  + f"write_json {_q(jf)}")
        rc, out, err, _ = run_cmd([cfg.yosys, "-q", "-p", script], timeout=timeout)
        if rc != 0 or not os.path.isfile(jf):
            return None, _yosys_error(out + err)
        with open(jf, encoding="utf-8") as fh:
            data = json.load(fh)
    mod = data.get("modules", {}).get(top)
    if mod is not None and "parameter_default_values" not in mod:
        # Yosys < 0.10 (e.g. Ubuntu 22.04's 0.9) does not export parameter defaults.
        values = source_param_defaults(cfg, files, top)
        if values:
            mod["parameter_default_values"] = values
    return data, ""


def _top_param_names(files, top):
    """Names of every `parameter` (header and body) declared by module `top`; [] if none/unknown."""
    from .arithmetic import mask_comments
    names = []
    for f in files:
        try:
            with open(f, encoding="utf-8", errors="replace") as fh:
                body = mask_comments(fh.read())
        except OSError:
            continue
        m = re.search(r"\bmodule\s+" + re.escape(top) + r"\b", body)
        e = re.search(r"\bendmodule\b", body[m.end():]) if m else None
        if not e:
            continue
        text = body[m.end():m.end() + e.start()]
        for d in re.finditer(r"\bparameter\b(.*?)(?=[;)]|\bparameter\b|\binput\b|\boutput\b|\binout\b)",
                             text, flags=re.S):
            decl = re.sub(r"^\s*(?:(?:integer|signed|unsigned|real)\s+|\[[^\]]*\]\s*)*", "", d.group(1))
            names += re.findall(r"(?:^|,)\s*([A-Za-z_][A-Za-z0-9_$]*)\s*=(?!=)", decl)
    return list(dict.fromkeys(names))


def source_param_defaults(cfg, files, top):
    """{name: binary string} of the top's default parameter values, elaborated by iverilog.

    Matches the format of Yosys' `parameter_default_values` (MSB first, 32 bits for integers).
    Returns {} when there are no parameters or they cannot be evaluated (callers fail closed)."""
    names = _top_param_names(files, top)
    if not names:
        return {}
    with tempfile.TemporaryDirectory(prefix="rtlagent_par_") as td:
        tb = os.path.join(td, "par_tb.v")
        lines = [f'    $display("RTLAGENT_PAR {n} %b", u.{n});' for n in names]
        with open(tb, "w", encoding="utf-8") as fh:
            fh.write("module rtlagent_par_tb;\n  " + top + " u ();\n  initial begin\n"
                     + "\n".join(lines) + "\n    $finish;\n  end\nendmodule\n")
        sim = os.path.join(td, "par.vvp")
        rc, out, err, _ = run_cmd([cfg.iverilog, "-g2012", "-o", sim, "-s", "rtlagent_par_tb", tb]
                                  + list(files), timeout=60)
        if rc != 0:
            return {}
        rc, out, err, _ = run_cmd([cfg.vvp, "-n", sim], timeout=60)
    values = dict(re.findall(r"^RTLAGENT_PAR (\S+) ([01]+)\s*$", out or "", flags=re.M))
    return values if set(values) == set(names) else {}


FF_TYPES = ("$dff", "$dffe", "$adff", "$adffe", "$sdff", "$sdffe", "$sdffce", "$dffsr", "$dffsre",
            "$aldff", "$aldffe", "$ff", "$dlatch", "$adlatch", "$dlatchsr", "$sr")


class DesignInfo:
    """Port list + sequential structure, used for testbench generation and prompting."""

    def __init__(self):
        self.top = ""
        self.ports = {}           # name -> (direction, width, signed)
        self.parameters = {}      # elaborated defaults; interface must be preserved
        self.port_order = []
        self.clocks = {}          # port -> 'pos' | 'neg'
        self.async_resets = {}    # port -> active level 0/1
        self.sync_resets = {}     # port -> active level 0/1 (best effort)
        self.n_ff_bits = 0
        self.has_latch = False
        self.has_memory = False
        self.is_sequential = False
        self.submodules = []
        self.has_x = False
        self.n_lines = 0
        self.notes = []

    def inputs(self):
        return [p for p in self.port_order if self.ports[p][0] == "input"]

    def outputs(self):
        return [p for p in self.port_order if self.ports[p][0] in ("output", "inout")]

    def data_inputs(self):
        ctl = set(self.clocks) | set(self.async_resets) | set(self.sync_resets)
        return [p for p in self.inputs() if p not in ctl]

    def summary(self):
        kind = "sequential" if self.is_sequential else "combinational"
        s = [f"top={self.top}, {kind}, {len(self.ports)} ports, ~{self.n_ff_bits} FF bits"]
        if self.clocks:
            s.append("clocks: " + ", ".join(f"{k}({v}edge)" for k, v in self.clocks.items()))
        if self.async_resets:
            s.append("async resets: " + ", ".join(f"{k}(active-{'high' if v else 'low'})"
                                                 for k, v in self.async_resets.items()))
        if self.sync_resets:
            s.append("sync resets: " + ", ".join(f"{k}(active-{'high' if v else 'low'})"
                                                for k, v in self.sync_resets.items()))
        if self.has_memory:
            s.append("has memory array")
        if self.has_latch:
            s.append("has latch")
        if self.submodules:
            s.append("submodules: " + ", ".join(self.submodules))
        if self.has_x:
            s.append("assigns X (don't-care) values")
        return "; ".join(s)

    def to_dict(self):
        return {"top": self.top, "ports": {k: list(v) for k, v in self.ports.items()},
                "port_order": self.port_order, "clocks": self.clocks,
                "async_resets": self.async_resets, "sync_resets": self.sync_resets,
                "n_ff_bits": self.n_ff_bits, "has_latch": self.has_latch,
                "has_memory": self.has_memory, "is_sequential": self.is_sequential,
                "submodules": self.submodules, "has_x": self.has_x, "notes": self.notes}


_RST_NAME = re.compile(r"(^|_)(rst|reset|clr|clear)(_?n|_b|b)?($|_)|^n?rst|^reset|^rst", re.I)
_CLK_NAME = re.compile(r"(^|_)(clk|clock|ck)($|_|\d)", re.I)


def reset_polarity(p, source_text):
    """Active level (0/1) of a reset input: earliest use in an if-condition wins, name as fallback."""
    from .verilog_utils import strip_comments
    q = re.escape(p)
    one = r"(?:1'b1|1'h1|1'd1|'b1|1)"
    zero = r"(?:1'b0|1'h0|1'd0|'b0|0)"
    high = [rf"if\s*\(\s*{q}\s*\)", rf"if\s*\(\s*{q}\s*===?\s*{one}\s*\)", rf"if\s*\(\s*{q}\s*!==?\s*{zero}\s*\)",
            rf"posedge\s+{q}\b"]
    low = [rf"if\s*\(\s*[!~]\s*{q}\s*\)", rf"if\s*\(\s*{q}\s*===?\s*{zero}\s*\)", rf"if\s*\(\s*{q}\s*!==?\s*{one}\s*\)",
           rf"negedge\s+{q}\b"]
    text = strip_comments(source_text or "")
    best = None
    for level, pats in ((1, high), (0, low)):
        for pat in pats:
            m = re.search(pat, text)
            if m and (best is None or m.start() < best[0]):
                best = (m.start(), level)
    if best is not None:
        return best[1]
    return 0 if re.search(r"(_n|_b|n)$|^n", p, re.I) else 1


def analyze(cfg, files, top, source_text=""):
    """Collect DesignInfo using yosys JSON. Returns (info, error)."""
    from .verilog_utils import find_modules, has_x_assign, count_lines
    info = DesignInfo()
    info.top = top
    data, err = design_json(cfg, files, top, flatten=True)
    if data is None:
        return None, err
    mod = data.get("modules", {}).get(top)
    if mod is None:
        return None, f"top module {top} not found after elaboration"
    info.parameters = mod.get("parameter_default_values", {})
    bit2port = {}
    for name, p in mod.get("ports", {}).items():
        width = len(p["bits"])
        signed = bool(p.get("signed", 0))
        info.ports[name] = (p["direction"], width, signed)
        for i, b in enumerate(p["bits"]):
            if isinstance(b, int):
                bit2port[b] = (name, i)
    # keep source order: yosys JSON preserves declaration order of ports
    info.port_order = list(mod.get("ports", {}).keys())

    def port_of(bits):
        if len(bits) != 1 or not isinstance(bits[0], int):
            return None
        return bit2port.get(bits[0], (None,))[0]

    for cname, cell in mod.get("cells", {}).items():
        ctype = cell.get("type", "")
        params = cell.get("parameters", {})
        conns = cell.get("connections", {})

        def pbool(key, default=1):
            v = params.get(key)
            if v is None:
                return default
            try:
                return int(str(v), 2) & 1
            except ValueError:
                return default
        if ctype in FF_TYPES:
            width = len(conns.get("Q", [])) or 1
            if ctype in ("$dlatch", "$adlatch", "$dlatchsr", "$sr"):
                info.has_latch = True
            info.n_ff_bits += width
            if "CLK" in conns:
                pn = port_of(conns["CLK"])
                if pn:
                    info.clocks[pn] = "pos" if pbool("CLK_POLARITY") else "neg"
            if "ARST" in conns:
                pn = port_of(conns["ARST"])
                if pn:
                    info.async_resets[pn] = pbool("ARST_POLARITY")
            if "SRST" in conns:
                pn = port_of(conns["SRST"])
                if pn:
                    info.sync_resets[pn] = pbool("SRST_POLARITY")
            for key in ("SET", "CLR"):
                if key in conns:
                    for b in conns[key]:
                        pn = bit2port.get(b, (None,))[0] if isinstance(b, int) else None
                        if pn:
                            info.async_resets.setdefault(pn, pbool(key + "_POLARITY"))
        elif ctype.startswith("$mem"):
            info.has_memory = True
            info.n_ff_bits += int(str(params.get("WIDTH", "0")), 2) * int(str(params.get("SIZE", "0")), 2) \
                if isinstance(params.get("WIDTH"), str) else 0
            for key in ("RD_CLK", "WR_CLK"):
                for b in conns.get(key, []):
                    pn = bit2port.get(b, (None,))[0] if isinstance(b, int) else None
                    if pn:
                        info.clocks.setdefault(pn, "pos")
    info.is_sequential = bool(info.clocks) or info.n_ff_bits > 0 or info.has_latch

    # name-based fallback for resets that opt_dff did not turn into SRST (e.g. reset muxed with enable)
    if info.is_sequential:
        for p in info.inputs():
            if p in info.clocks or p in info.async_resets or p in info.sync_resets:
                continue
            if info.ports[p][1] == 1 and _RST_NAME.search(p):
                info.sync_resets[p] = reset_polarity(p, source_text)
        if not info.clocks:
            for p in info.inputs():
                if info.ports[p][1] == 1 and _CLK_NAME.search(p):
                    info.clocks[p] = "pos"
                    info.notes.append(f"clock {p} guessed from name")
    if source_text:
        mods = find_modules(source_text)
        info.submodules = [m for m in mods if m != top]
        info.has_x = has_x_assign(source_text)
        info.n_lines = count_lines(source_text)
    return info, ""
