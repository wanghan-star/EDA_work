"""VCD parsing / comparison.

`parse_vcd` + `compare_strict` reproduce opti_demo/equiv_agent.py exactly (event lists per output,
including zero-width re-assignments that iverilog dumps), so a design that passes here also passes
the course's simulation-based checker.  `first_mismatch` adds diagnostics for the repair prompt.
"""


def _norm(val):
    v = val.lower()
    if len(v) == 1 and v in "01xz":
        return v
    bits = v[1:] if v[:1] == "b" else v
    return bits.lstrip("0") or "0"


def parse_vcd(path):
    """{signal_name: [(time, value), ...]} -- identical semantics to the course checker."""
    decl = {}
    events = {}
    scope = []
    t = 0
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            if line.startswith("$scope"):
                parts = line.split()
                scope.append(parts[2] if len(parts) > 2 else "")
            elif line.startswith("$upscope"):
                if scope:
                    scope.pop()
            elif line.startswith("$var"):
                parts = line.split()
                if len(parts) >= 5:
                    in_dut = bool(scope) and "dut" in scope[-1].lower()
                    decl.setdefault(parts[3], (parts[4], int(parts[2]), in_dut))
            elif line.startswith("#"):
                try:
                    t = int(line[1:])
                except ValueError:
                    pass
            else:
                c = line[0]
                if c in "bB":
                    sp = line.find(" ")
                    if sp > 0:
                        code = line[sp + 1:].strip()
                        events.setdefault(code, []).append((t, _norm(line[1:sp])))
                elif c in "01xzXZ":
                    code = line[1:].strip()
                    events.setdefault(code, []).append((t, _norm(c)))
    out, fallback = {}, {}
    for code, (name, _w, in_dut) in decl.items():
        if code in events:
            (out if in_dut else fallback).setdefault(name, events[code])
    for name, ev in fallback.items():
        out.setdefault(name, ev)
    return out


def compare_strict(gold, opt, out_names):
    """Course-checker semantics: every output must have identical (time, value) event lists."""
    bad = []
    for name in out_names:
        ge, oe = gold.get(name), opt.get(name)
        if ge is None or oe is None or ge != oe:
            bad.append(name)
    return (len(bad) == 0), bad


def value_at(events, t):
    """Value of a signal at the end of time step t (events sorted by time)."""
    v = "x"
    for et, ev in events or []:
        if et > t:
            break
        v = ev
    return v


def _settled(events):
    """Collapse to the last value per time step and drop non-changes (functional view)."""
    res = []
    last = None
    i = 0
    evs = events or []
    while i < len(evs):
        t = evs[i][0]
        j = i
        while j + 1 < len(evs) and evs[j + 1][0] == t:
            j += 1
        v = evs[j][1]
        if v != last:
            res.append((t, v))
            last = v
        i = j + 1
    return res


def first_mismatch(gold, opt, out_names, in_names, max_items=3):
    """Diagnose the earliest divergence. Returns dict with kind='value' or kind='event'."""
    best = None
    for name in out_names:
        ge, oe = gold.get(name, []), opt.get(name, [])
        if ge == oe:
            continue
        gs, os_ = _settled(ge), _settled(oe)
        if gs != os_:
            # functional difference: earliest time where settled values differ
            times = sorted(set(t for t, _ in gs) | set(t for t, _ in os_))
            for t in times:
                gv, ov = value_at(gs, t), value_at(os_, t)
                if gv != ov:
                    cand = {"kind": "value", "time": t, "signal": name, "gold": gv, "opt": ov}
                    break
            else:
                continue
        else:
            # same settled waveform, different raw event list (zero-width glitch / re-assignment)
            gset, oset = set(ge), set(oe)
            extra_g = sorted(gset - oset)
            extra_o = sorted(oset - gset)
            t = min([x[0] for x in extra_g[:1] + extra_o[:1]] or [0])
            cand = {"kind": "event", "time": t, "signal": name,
                    "gold_only_events": extra_g[:max_items], "opt_only_events": extra_o[:max_items]}
        if best is None or cand["time"] < best["time"]:
            best = cand
    if best is not None:
        t = best["time"]
        best["inputs"] = {n: value_at(gold.get(n), t) for n in in_names if n in gold}
        best["inputs_prev"] = {n: value_at(gold.get(n), t - 1) for n in in_names if n in gold}
        best["outputs_gold"] = {n: value_at(gold.get(n), t) for n in out_names}
        best["outputs_opt"] = {n: value_at(opt.get(n), t) for n in out_names}
    return best


def value_mismatch_times(gold, opt, out_names, limit=3):
    """Earliest distinct times where settled output values differ (for extra counter-examples)."""
    times = set()
    for name in out_names:
        gs, os_ = _settled(gold.get(name, [])), _settled(opt.get(name, []))
        if gs == os_:
            continue
        for t in sorted(set(t for t, _ in gs) | set(t for t, _ in os_)):
            if value_at(gs, t) != value_at(os_, t):
                times.add(t)
                if len(times) >= 4 * limit:
                    break
    return sorted(times)


def snapshot(gold, opt, t, in_names, out_names):
    return {"time": t,
            "inputs": {n: value_at(gold.get(n), t) for n in in_names if n in gold},
            "outputs_gold": {n: value_at(gold.get(n), t) for n in out_names},
            "outputs_opt": {n: value_at(opt.get(n), t) for n in out_names}}


def has_duplicate_events(events):
    """True if a signal is dumped twice in a row with the same value (procedural re-assignment)."""
    prev = None
    for ev in events or []:
        if prev is not None and ev[1] == prev[1]:
            return True
        prev = ev
    return False
