"""Zero-token candidate generator: technology-independent logic re-synthesis with ABC.

The design (original or the best LLM candidate) is optimised with stronger ABC scripts than the
scoring flow uses (&deepsyn / dch / mfs), then written back as structural Verilog (generic gates,
registers kept as always blocks).  The scoring flow re-maps it, but starts from a much smaller AIG,
so most of the reduction survives.  Candidates go through the same verification as LLM output.

Modes (--resynth): full (default: also re-synthesize the best LLM candidate), fallback (only when
the LLM found no verified gain), off (readable RTL only).  The emitted file is a gate-level
netlist, which the reports state explicitly.
"""

import os
import re

from .synth import read_cmds, _q
from .util import run_cmd, read_text, write_text

GATES = "AND,NAND,OR,NOR,XOR,XNOR,ANDNOT,ORNOT,MUX"

SCRIPTS = {
    # Area-oriented stochastic deep re-synthesis.  Bounded by "J steps without improvement" (not by
    # wall-clock) so a given seed gives the same result on any machine/load; -T is only a safety cap.
    # The landscape is rugged (seed/effort change results by >20%), hence a small portfolio.
    "deep": ["strash", "&get -n", "&deepsyn -I 1 -J 150 -T {T}", "&put"],
    "deep_s7": ["strash", "&get -n", "&deepsyn -I 1 -J 150 -T {T} -S 7", "&put"],
    "deep_j400": ["strash", "&get -n", "&deepsyn -I 1 -J 400 -T {T6}", "&put"],
    "deep_s7_j400": ["strash", "&get -n", "&deepsyn -I 1 -J 400 -T {T6} -S 7", "&put"],
    "deep_i3": ["strash", "&get -n", "&deepsyn -I 3 -J 200 -T {T}", "&put"],
    # deep + delay balancing (trades area back for fewer levels)
    "deep_bd": ["strash", "&get -n", "&deepsyn -I 1 -J 150 -T {T}", "&b -d", "&put"],
    "deep_s7_bds": ["strash", "&get -n", "&deepsyn -I 1 -J 400 -T {T6} -S 7", "&b -d -s", "&put"],
    # level-preserving rewriting (keeps depth, smaller gains)
    "dc2x3": ["strash", "&get -n", "&dc2", "&dc2", "&dc2", "&put"],
    # delay-oriented (choices + balancing)
    "syn2_dch": ["strash", "&get -n", "&syn2", "&dch -f", "&b -d -s", "&put"],
}
DEFAULT_SET = ("deep", "deep_s7", "deep_j400", "deep_s7_j400", "deep_i3", "deep_bd", "deep_s7_bds",
               "dc2x3", "syn2_dch")


def _param_header(src, top):
    m = re.search(r"\bmodule\s+" + re.escape(top) + r"\s*#\s*\(", src)
    if not m:
        return ""
    i = m.end()
    depth = 1
    while i < len(src) and depth:
        if src[i] == "(":
            depth += 1
        elif src[i] == ")":
            depth -= 1
        i += 1
    return src[m.end() - 1: i]          # "( parameter ... )"


_ID = r"(?:\\\S+\s|[A-Za-z_][A-Za-z0-9_$]*)"
# for parsing references an escaped id ends at whitespace OR end of text (LHS text is stripped)
_ID_REF = r"(?:\\\S+|[A-Za-z_][A-Za-z0-9_$]*)"
_REF = re.compile(r"(" + _ID_REF + r")\s*(\[\s*(\d+)\s*(?::\s*(\d+)\s*)?\])?")
_KEYWORDS = {"assign", "begin", "end", "if", "else", "always", "posedge", "negedge", "or", "reg", "wire"}


def _refs(expr):
    """[(base, lo, hi)] for every identifier reference; lo/hi None means the whole signal."""
    out = []
    for m in _REF.finditer(expr):
        base = m.group(1).strip()
        if base in _KEYWORDS or re.match(r"^\d", base):
            continue
        if m.group(2):
            a = int(m.group(3))
            b = int(m.group(4)) if m.group(4) is not None else a
            out.append((base, min(a, b), max(a, b)))
        else:
            out.append((base, None, None))
    return out


def _strip_consts(expr):
    # remove sized constants like 8'h1f / 1'b0 so their digits/letters are not taken as identifiers
    return re.sub(r"\d+'[sS]?[bBhHdDoO][0-9a-fA-FxXzZ_?]+", " ", expr)


def to_single_block(text):
    """Rewrite yosys `assign` netlist logic into one `always @*` block (topological order).

    Zero-delay simulation of a deep gate netlist produces zero-width glitches, which iverilog dumps
    as extra VCD events; behavioural originals compute each output once per time step.  Evaluating
    the whole netlist in one procedural block assigns every signal exactly once -> no glitches.
    Synthesis result is identical.  Returns None if the netlist cannot be ordered (cycle/odd syntax).
    """
    lines = text.splitlines()
    assigns = []
    for i, ln in enumerate(lines):
        m = re.match(r"^\s*assign\s+(.*?)\s*=\s*(.*);\s*$", ln)
        if m:
            assigns.append((i, m.group(1), m.group(2)))
    if not assigns:
        return None
    writers = {}
    targets = []
    for k, (_i, lhs, _rhs) in enumerate(assigns):
        t = _refs(lhs.strip("{} "))
        targets.append(t)
        for base, lo, hi in t:
            writers.setdefault(base, []).append((k, lo, hi))
    deps = [set() for _ in assigns]
    for k, (_i, _lhs, rhs) in enumerate(assigns):
        for base, lo, hi in _refs(_strip_consts(rhs)):
            for (w, wlo, whi) in writers.get(base, []):
                if w == k:
                    continue
                if lo is None or wlo is None or not (hi < wlo or lo > whi):
                    deps[k].add(w)
    # Kahn topological sort (stable w.r.t. original order)
    users = [[] for _ in assigns]
    indeg = [len(d) for d in deps]
    for k, d in enumerate(deps):
        for w in d:
            users[w].append(k)
    ready = [k for k in range(len(assigns)) if indeg[k] == 0]
    order = []
    import heapq
    heapq.heapify(ready)
    while ready:
        k = heapq.heappop(ready)
        order.append(k)
        for u in users[k]:
            indeg[u] -= 1
            if indeg[u] == 0:
                heapq.heappush(ready, u)
    if len(order) != len(assigns):
        return None
    lhs_bases = {b for t in targets for b, _lo, _hi in t}
    # declarations of assigned signals become `reg`; inputs can never be targets
    out = []
    drop = {i for i, _l, _r in assigns}
    inputs = set()
    for ln in lines:
        m = re.match(r"^\s*input\s+(?:\[[^\]]*\]\s*)?(" + _ID + r")\s*;", ln)
        if m:
            inputs.add(m.group(1).strip())
    if lhs_bases & inputs:
        return None
    for i, ln in enumerate(lines):
        if i in drop:
            continue
        m = re.match(r"^(\s*)wire(\s+(?:signed\s+)?(?:\[[^\]]*\]\s*)?)(" + _ID + r")\s*;\s*$", ln)
        if m and m.group(3).strip() in lhs_bases:
            ln = f"{m.group(1)}reg{m.group(2)}{m.group(3)};"   # keep the space ending an escaped id
        if re.match(r"^\s*endmodule\b", ln):
            out.append("  always @* begin")
            for k in order:
                _i, lhs, rhs = assigns[k]
                out.append(f"    {lhs} = {rhs};")
            out.append("  end")
        out.append(ln)
    return "\n".join(out) + "\n"


def resynth(cfg, files, top, workdir, script="deep", seconds=10, orig_src=""):
    """Returns (verilog_text or None, message)."""
    os.makedirs(workdir, exist_ok=True)
    abc_file = os.path.join(workdir, f"{script}.abc")
    scr = "\n".join(SCRIPTS[script]).replace("{T6}", str(seconds * 2)).replace("{T}", str(seconds))
    write_text(abc_file, scr + "\n")
    out_v = os.path.join(workdir, f"{script}.v")
    # NOTE: must be a script file: with `yosys -p`, the comma list of `abc -g` gets split into commands
    ys_file = os.path.join(workdir, f"{script}.ys")
    lines = [f"read_verilog -sv {_q(f)}" for f in files] + [
        f"hierarchy -top {top}", "proc", "flatten", "opt -full", "memory -nomap", "opt -full",
        "techmap", "opt -fast", f"abc -g {GATES} -script {_q(abc_file)}", "opt_clean -purge",
        f"write_verilog -noattr {_q(out_v)}"]
    write_text(ys_file, "\n".join(lines) + "\n")
    rc, out, err, _ = run_cmd([cfg.yosys, "-q", "-s", ys_file], timeout=seconds * 8 + 180)
    if rc != 0 or not os.path.isfile(out_v):
        return None, (out + err)[-600:]
    text = read_text(out_v)
    blk = to_single_block(text)
    if blk is not None:
        text = blk
    # keep the original parameter list so any instantiation with overrides still parses
    hdr = _param_header(orig_src, top) if orig_src else ""
    if hdr:
        text = re.sub(r"\bmodule\s+" + re.escape(top) + r"\s*\(", f"module {top} #{hdr} (", text, count=1)
    text = "// Logic re-synthesized by rtl_agent (ABC " + script + "); registers and ports unchanged.\n" + text
    return text, ""
