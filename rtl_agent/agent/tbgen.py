"""Testbench + stimulus generation for simulation-based equivalence checking.

Stimuli are precomputed in Python (deterministic seeds) and loaded with $readmemh, so the same
vectors drive gold and optimized designs.  Inputs change 2 time units after the falling edge of the
reference clock (never on an active edge -> race free).  The testbench dumps only the DUT scope
($dumpvars(1, dut_i)) exactly like the course checker.
"""

import random


def _mask(w):
    return (1 << w) - 1


class Stim:
    def __init__(self, names, widths, vectors, kind):
        self.names = names          # input port names in vector order (MSB first)
        self.widths = widths
        self.vectors = vectors      # list of ints (concatenated, names[0] in MSBs)
        self.kind = kind
        self.x_window_end = 0       # ps; X-vs-value differences before this are power-up effects

    @property
    def total_width(self):
        return sum(self.widths)

    def hex_lines(self):
        nd = max(1, (self.total_width + 3) // 4)
        return [format(v, "0%dx" % nd) for v in self.vectors]


def _pack(values, widths):
    v = 0
    for x, w in zip(values, widths):
        v = (v << w) | (x & _mask(w))
    return v


def _data_value(rng, w, prev, other_same_width):
    r = rng.random()
    if other_same_width is not None and r < 0.10:
        o = other_same_width
        return [o, (o + 1) & _mask(w), (o - 1) & _mask(w)][rng.randrange(3)]
    r = rng.random()
    if r < 0.66:
        return rng.getrandbits(w)
    if r < 0.74:
        return 0
    if r < 0.82:
        return _mask(w)
    if r < 0.88:
        return rng.randrange(min(4, 1 << w))
    if r < 0.94:
        return 1 << (w - 1)
    return (_mask(w) >> 1) if w > 1 else rng.getrandbits(1)


def comb_stimulus(info, seed=1, n_random=6000, exhaustive_limit=16):
    names = info.inputs()
    widths = [info.ports[n][1] for n in names]
    total = sum(widths)
    rng = random.Random(seed)
    vectors = []
    if total <= exhaustive_limit:
        vectors = list(range(1 << total))
        rng.shuffle(vectors)
        # keep a few structured vectors at the start too
        vectors = [0, _mask(total)] + vectors
        return Stim(names, widths, vectors, "exhaustive")
    # corners
    for fill in (0, 1):
        vectors.append(_pack([_mask(w) if fill else 0 for w in widths], widths))
    for i, w in enumerate(widths):
        for val in (1, _mask(w), 1 << (w - 1), _mask(w) >> 1):
            vals = [0] * len(widths)
            vals[i] = val
            vectors.append(_pack(vals, widths))
    prev = [0] * len(widths)
    for _ in range(n_random):
        vals = []
        for i, w in enumerate(widths):
            other = None
            same = [j for j in range(i) if widths[j] == w and w > 1]
            if same:
                other = vals[rng.choice(same)]
            if w == 1:
                vals.append(rng.getrandbits(1))
            else:
                vals.append(_data_value(rng, w, prev[i], other))
        prev = vals
        vectors.append(_pack(vals, widths))
    return Stim(names, widths, vectors, "random")


def seq_stimulus(info, seed=1, n_cycles=2000, mode="reset_first"):
    """Per-cycle input vectors for all non-clock inputs (resets included)."""
    clocks = set(info.clocks)
    names = [n for n in info.inputs() if n not in clocks]
    widths = [info.ports[n][1] for n in names]
    resets = {}
    resets.update(info.sync_resets)
    resets.update(info.async_resets)
    rng = random.Random(seed * 7919 + (0 if mode == "reset_first" else 17))
    ctrl = [n for n, w in zip(names, widths) if w == 1 and n not in resets]
    cur = {n: 0 for n in names}
    for r, lvl in resets.items():
        if r in cur:
            cur[r] = 1 - lvl
    vectors = []
    seg_left = 0
    probs = {}
    hold_p = 0.0
    reset_left = 0
    pre = 4 if mode == "no_reset_first" else 0
    for cyc in range(n_cycles):
        # --- reset schedule ---
        in_reset_phase = False
        if resets:
            if cyc < pre:
                active = False
            elif cyc < pre + 5:
                active = True
                in_reset_phase = True
            elif reset_left > 0:
                active = True
                reset_left -= 1
                in_reset_phase = True
            else:
                active = False
                if cyc > 20 and rng.random() < 1.0 / 150:
                    reset_left = rng.randrange(1, 4)
                    active = True
                    in_reset_phase = True
            for r, lvl in resets.items():
                if r in cur:
                    cur[r] = lvl if active else 1 - lvl
        # --- new stimulus segment ---
        if seg_left <= 0:
            seg_left = rng.randrange(16, 120)
            for n in ctrl:
                probs[n] = rng.choice([0.03, 0.2, 0.5, 0.5, 0.8, 0.97])
            hold_p = rng.choice([0.0, 0.0, 0.5, 0.85])
        seg_left -= 1
        for n, w in zip(names, widths):
            if n in resets:
                continue
            if w == 1:
                # resets gated by enables (e.g. `if (EN) if (Rst) ...`) need the enables high
                p = 0.75 if in_reset_phase else probs.get(n, 0.5)
                cur[n] = 1 if rng.random() < p else 0
            else:
                if rng.random() < hold_p:
                    continue
                same = [m for m, mw in zip(names, widths) if mw == w and m != n and m not in resets]
                other = cur[rng.choice(same)] if same else None
                cur[n] = _data_value(rng, w, cur[n], other)
        vectors.append(_pack([cur[n] for n in names], widths))
    st = Stim(names, widths, vectors, mode)
    # reset sequence ends after cycle pre+5; inputs change at 10k+2 ns, VCD unit is ps
    st.x_window_end = ((pre + 5) * 10 + 2) * 1000 if resets else 0
    return st


def gen_testbench(info, stim, vcd_macro="VCD_PATH", vec_macro="VEC_PATH"):
    """Verilog testbench text driving `info.top` from a $readmemh vector file."""
    top = info.top
    L = ["`timescale 1ns/1ps", "module tb;"]
    clocks = list(info.clocks)
    for c in clocks:
        L.append(f"  reg {c};")
    for n, w in zip(stim.names, stim.widths):
        L.append(f"  reg [{w - 1}:0] {n};" if w > 1 else f"  reg {n};")
    for n in info.outputs():
        w = info.ports[n][1]
        L.append(f"  wire [{w - 1}:0] {n};" if w > 1 else f"  wire {n};")
    tw = max(1, stim.total_width)
    nvec = len(stim.vectors)
    L.append(f"  reg [{tw - 1}:0] vec [0:{nvec - 1}];")
    L.append("  integer k;")
    conns = [f".{p}({p})" for p in info.port_order if info.ports[p][0] in ("input", "output", "inout")]
    L.append(f"  {top} dut_i ({', '.join(conns)});")
    lhs = "{" + ", ".join(stim.names) + "}" if stim.names else None
    L.append("  initial begin")
    L.append(f"    $dumpfile(`{vcd_macro});")
    L.append("    $dumpvars(1, dut_i);")
    L.append(f"    $readmemh(`{vec_macro}, vec);")
    for i, c in enumerate(clocks):
        # negedge-triggered clocks start high so their first active edge is mid-period as well
        L.append(f"    {c} = {1 if info.clocks[c] == 'neg' else 0};")
    if lhs:
        L.append(f"    {lhs} = vec[0];")
    L.append("    #2;")
    if lhs:
        L.append(f"    for (k = 1; k < {nvec}; k = k + 1) begin")
        L.append(f"      #10 {lhs} = vec[k];")
        L.append("    end")
    L.append("    #10 $finish;")
    L.append("  end")
    # reference clock: period 10, edges at 5 (+10k) and 10k; inputs change at 10k+2
    halfs = [5.0, 7.123, 6.317, 8.411]
    for i, c in enumerate(clocks):
        L.append(f"  always #{halfs[i % len(halfs)]} {c} = ~{c};")
    L.append("endmodule")
    return "\n".join(L) + "\n"


def default_stimuli(info, budget="normal"):
    """List of Stim objects to run (each is one simulation per design)."""
    if not info.is_sequential:
        n = 6000 if budget == "normal" else 20000
        return [comb_stimulus(info, seed=1, n_random=n)]
    n = 1500 if budget == "normal" else 5000
    return [seq_stimulus(info, seed=1, n_cycles=n, mode="reset_first"),
            seq_stimulus(info, seed=2, n_cycles=n, mode="no_reset_first"),
            seq_stimulus(info, seed=3, n_cycles=n, mode="reset_first")]
