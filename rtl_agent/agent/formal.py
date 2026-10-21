"""Formal equivalence checking with Yosys (+ ABC).

combinational : miter -> AIG -> ABC `iprove` (fast, complete); counter-example via `sat -dump_vcd`.
sequential    : miter (3-valued, gold X ignored) -> `sat -tempinduct` with reset forced in step 1,
                undefined power-up state, defined inputs.  Result is either an induction proof,
                a bounded proof (no counter-example up to K cycles) or a concrete trace.

Every counter-example is replayed in 4-state simulation by the caller before it is trusted.
NOTE: never combine `miter -ignore_gold_x` with 2-valued solving -- the x-masking logic folds to
constants and the miter becomes vacuous (found the hard way; see tests/test_selfcheck.py).
"""

import os
import re

from .synth import read_cmds, _q
from .util import run_cmd, tail, write_text
from .vcd import parse_vcd


class FormalResult:
    def __init__(self, kind):
        self.kind = kind            # 'comb' | 'seq'
        self.status = "unknown"     # proved | bounded | cex | unknown | error | skipped
        self.depth = 0
        self.trace = None           # list of {port: int} per step (inputs), for replay
        self.message = ""
        self.seconds = 0.0

    def to_dict(self):
        return {"kind": self.kind, "status": self.status, "depth": self.depth,
                "message": self.message[-600:], "seconds": round(self.seconds, 2),
                "trace_len": len(self.trace) if self.trace else 0}


def _load_design_cmds(files, top, name, seq):
    mem = "memory -nomap; memory_map; opt_clean; " if seq else "memory; opt_clean; "
    return (f"{read_cmds(files)}; hierarchy -top {top}; proc; flatten; {mem}"
            f"rename {top} {name}; design -stash {name}; design -reset")


def miter_script(gold_files, opt_files, top, seq, ignore_x, modern=True):
    s = _load_design_cmds(gold_files, top, "gold", seq) + "; "
    s += _load_design_cmds(opt_files, top, "gate", seq) + "; "
    s += "design -copy-from gold -as gold gold; design -copy-from gate -as gate gate; "
    flags = "-equiv -flatten -make_outputs" + (" -ignore_gold_x" if ignore_x else "")
    s += f"miter {flags} gold gate miter; hierarchy -top miter; "
    if seq:
        s += "async2sync; dffunmap; opt -fast; " if modern else "async2sync; opt -fast; "
    else:
        s += "opt -fast; "
    return s


def _parse_trace(vcd_path, inputs):
    """Turn a `sat -dump_vcd` trace into a list of per-step input dicts."""
    if not os.path.isfile(vcd_path):
        return None
    waves = parse_vcd(vcd_path)
    steps = sorted(set(t for evs in waves.values() for t, _ in evs))
    trace = []
    for t in steps:
        vec = {}
        for p in inputs:
            evs = waves.get("in_" + p) or waves.get("\\in_" + p) or []
            val = "0"
            for et, ev in evs:
                if et <= t:
                    val = ev
            try:
                vec[p] = int(val.replace("x", "0").replace("z", "0"), 2)
            except ValueError:
                vec[p] = 0
        trace.append(vec)
    return trace


def _abc_cex(cex_file, map_file):
    """ABC `write_cex -n` + yosys `write_aiger -map` -> {port: int}."""
    bits = {}
    with open(map_file, encoding="utf-8") as fh:
        for ln in fh:
            p = ln.split()
            if len(p) == 4 and p[0] == "input":
                bits[int(p[1])] = (p[3], int(p[2]))
    vec = {}
    with open(cex_file, encoding="utf-8") as fh:
        for m in re.finditer(r"pi(\d+)(?:@\d+)?=([01xX])", fh.read()):
            idx, val = int(m.group(1)), m.group(2)
            if idx in bits and val == "1":
                name, bit = bits[idx]
                name = name[3:] if name.startswith("in_") else name
                vec[name] = vec.get(name, 0) | (1 << bit)
            elif idx in bits:
                name = bits[idx][0]
                vec.setdefault(name[3:] if name.startswith("in_") else name, 0)
    return vec


def prove_comb(cfg, gold_files, opt_files, top, info, workdir, timeout=120):
    res = FormalResult("comb")
    os.makedirs(workdir, exist_ok=True)
    aig = os.path.join(workdir, "miter.aig")
    amap = os.path.join(workdir, "miter.map")
    cex = os.path.join(workdir, "cex.txt")
    # single-output miter (no -make_outputs) for ABC
    script = miter_script(gold_files, opt_files, top, seq=False, ignore_x=False)
    script = script.replace("-make_outputs ", "")
    script += (f"techmap; opt -fast; setundef -zero; aigmap; opt_clean; "
               f"write_aiger -zinit -map {_q(amap)} {_q(aig)}")
    rc, out, err, sec = run_cmd([cfg.yosys, "-q", "-p", script], timeout=timeout)
    res.seconds += sec
    if rc != 0 or not os.path.isfile(aig):
        res.status = "error"
        res.message = "miter build failed: " + tail(out + err, 800)
        return res
    rc, out, err, sec = run_cmd([cfg.yosys_abc, "-c", f"read {_q(aig)}; strash; iprove; write_cex -n {_q(cex)}"],
                                timeout=timeout)
    res.seconds += sec
    text = out + err
    if rc == 0 and re.search(r"\bUNSATISFIABLE\b", text):
        res.status = "proved"
        res.message = "ABC iprove: miter output is constant 0"
        return res
    if rc == 0 and re.search(r"\bSATISFIABLE\b", text) and os.path.isfile(cex):
        res.status = "cex"
        res.trace = [_abc_cex(cex, amap)]
        res.message = "ABC iprove: outputs differ for some input"
        return res
    # ABC undecided/timeout: second opinion from yosys sat (MiniSAT)
    vcd = os.path.join(workdir, "cex.vcd")
    script2 = miter_script(gold_files, opt_files, top, seq=False, ignore_x=False)
    tlim = max(10, int(timeout))
    script2 += f"sat -prove trigger 0 -timeout {tlim} -dump_vcd {_q(vcd)} -show-inputs miter"
    rc, out, err, sec = run_cmd([cfg.yosys, "-p", script2], timeout=timeout + 30)
    res.seconds += sec
    log = out + err
    if "SUCCESS!" in log:
        res.status = "proved"
        res.message = "yosys sat: proof succeeded"
    elif "model found: FAIL" in log:
        res.status = "cex"
        res.trace = _parse_trace(vcd, info.inputs())
        res.message = "counter-example found"
    else:
        res.status = "unknown"
        res.message = "solver timeout / undecided"
    return res


def prove_seq(cfg, gold_files, opt_files, top, info, workdir, depth=24, timeout=180):
    res = FormalResult("seq")
    os.makedirs(workdir, exist_ok=True)
    if len(info.clocks) > 1:
        res.status = "skipped"
        res.message = "multi-clock design: formal proof unsupported"
        return res
    vcd = os.path.join(workdir, "cex.vcd")
    script = miter_script(gold_files, opt_files, top, seq=True, ignore_x=True, modern=cfg.modern_yosys())
    sets = []
    resets = dict(info.sync_resets)
    resets.update(info.async_resets)
    for r, lvl in resets.items():
        sets.append(f"-set-at 1 in_{r} {lvl}")
    tlim = max(10, int(timeout))
    script += (f"sat -tempinduct -prove trigger 0 -seq 1 -maxsteps {depth} -set-init-undef "
               f"-enable_undef -set-def-inputs {' '.join(sets)} -timeout {tlim} "
               f"-dump_vcd {_q(vcd)} miter")
    rc, out, err, sec = run_cmd([cfg.yosys, "-p", script], timeout=timeout + 60)
    res.seconds = sec
    log = out + err
    write_text(os.path.join(workdir, "formal_seq.log"), log)
    proven_base = [int(x) for x in re.findall(r"Base case for induction length (\d+) proven", log)]
    res.depth = max(proven_base) if proven_base else 0
    if "Induction step proven: SUCCESS" in log:
        res.status = "proved"
        res.message = f"temporal induction succeeded (length {res.depth})"
    elif "model found for base case: FAIL" in log:
        res.status = "cex"
        res.trace = _parse_trace(vcd, info.inputs())
        res.message = f"counter-example after {len(res.trace or [])} cycles"
    elif res.depth > 0:
        res.status = "bounded"
        res.message = f"no counter-example within {res.depth} cycles (induction inconclusive)"
    elif rc != 0:
        res.status = "error"
        res.message = tail(log, 800)
    else:
        res.status = "unknown"
        res.message = tail(log, 400)
    return res
