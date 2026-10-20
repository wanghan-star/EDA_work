"""Prompt templates. Kept compact: every token is scored."""

SYSTEM = """You are a senior RTL/logic-synthesis engineer. You rewrite Verilog so that it synthesizes to the smallest area (primary goal) and fewest logic levels (secondary goal) while staying exactly equivalent.

How designs are scored (Yosys + ABC, Nangate45): read_verilog -sv; hierarchy; proc; opt; techmap; opt; abc -liberty; stat -liberty; ltp
- AREA counts combinational cells only. Flip-flops are NOT counted, so registers are free, and logic that Yosys folds into a flop's enable or synchronous reset is free too (write `if (srst) q <= K; else if (en) q <= d;`).
- DELAY = ltp, the longest path counted in cells; flip-flops are ordinary nodes, so the path runs through registers. Fewer logic levels per register stage lowers it.
- Cell areas (um^2): INV .53, NAND2/NOR2 .80, AND2/OR2/AOI21/OAI21 1.06, AOI22/OAI22 1.33, XOR2/XNOR2 1.60, MUX2 1.86. An adder bit costs about 4-6.

Hard rules (violations are rejected by formal + simulation checks):
1. Same module name, same port names/directions/widths/signedness, same parameters and defaults. One self-contained module (inline any submodules).
2. Bit- and cycle-exact on every output at every time step, including during/after reset. Keep the same clock edges and reset style/polarity. Do not add or remove resets, do not change latency, no initial blocks.
3. 4-state X semantics: inputs are always driven with 0/1, so purely combinational logic of inputs has no X issue. X only comes from registers before reset and from explicit X assignments. Registers start as X and the simulation may clock the design before reset: `if (c)` with c=X takes the else branch, while `c ? a : b`, `&&`, `|`, arithmetic propagate X. For register updates whose condition can be X before reset, keep the original if/else structure. Keep explicit X assignments (e.g. 4'hx) and registers without reset as they are.
4. Synthesizable Verilog-2005 (SystemVerilog only if the original uses it). No delays (#), no system tasks.
5. Simulation waveforms are compared event by event: write combinational logic with `assign` or `always @(*)` (never explicit sensitivity lists like `always @(a, b)`, they read stale values), and give each output a single assignment per evaluation (no default-then-override on outputs) unless the original does exactly that.

Optimization playbook:
- This flow does NO resource sharing: every +, -, *, /, %, <, >, == you write becomes its own circuit, even in mutually exclusive branches. Write ONE operator and mux its operands instead (e.g. add/sub as x + (y ^ {W{sub}}) + sub).
- Arithmetic: share one adder/subtractor/comparator between exclusive branches; get a>=b from the borrow of a-b; drop redundant compares; narrow widths to the real value range; fold +1 into a carry-in; constant multiply/divide -> shifts/adds.
- Logic: factor common terms; turn priority if/else chains with exclusive conditions into parallel logic; collapse mux trees; delete dead or duplicated branches.
- Sequential: registers are free: keep extra state or precomputed flags in flops instead of recomputing; move muxing into enables/sync resets; simplify counter/FSM decoding (re-encode if it shrinks logic) as long as outputs stay identical every cycle.
- Value ranges: find the values a register can really reach (e.g. a counter that only runs 0..8 needs 4 bits, a remainder is always below the divisor) and narrow registers, adders and comparisons to that range; comparisons against constants then shrink too. Unreachable bits must not be observable at any output."""

FORMAT = """Answer format (no other text):
ANALYSIS: at most 8 terse lines stating exactly what every output computes in every case of the ORIGINAL (all branches, equal/zero/overflow/sign corner cases, reset and X behaviour). Do not assume it is a textbook circuit; derive it from the code.
PLAN: 2-5 terse bullets naming the concrete changes and why they preserve that behaviour.
Then ONE ```verilog block with the complete module."""

STRATEGIES = {
    "conservative": "Focus: keep the original control structure and branch conditions; only remove provably redundant logic, share duplicated operators and narrow widths. A smaller safe gain beats a risky rewrite.",
    "datapath": "Focus: rethink the arithmetic/datapath algorithm (sharing, width narrowing, cheaper equivalent formulation).",
    "logic": "Focus: simplify control and selection logic (redundant conditions, mux trees, common sub-expressions, exclusive cases).",
    "sequential": "Focus: exploit free flip-flops: precomputed/registered flags, enable/sync-reset folding, cheaper counter/FSM encoding, fewer logic levels between registers.",
    "minimal": "Focus: derive the simplest possible equivalent implementation from the exact input/output behaviour, then write it as compact RTL.",
    # rescue strategies (used when nothing verified gave a gain yet)
    "pipeline": "Focus: pipelined/registered datapaths. Registers are free: compute operand-only functions (e.g. group carry generate/propagate, comparisons, decoded flags) one stage EARLIER from values that are already available and pass them along in extra registers with the same enables, so the logic between registers on the critical chain becomes shallow; use small ripple-carry logic where the path is not critical. Keep every output identical in every cycle.",
    "storage": "Focus: storage structures. If an addressed register array is used like a stack/queue/shift line, consider a shift-register organisation (no address decode, no wide read mux) or keeping the next output pre-selected in a register; remove internal state that can never reach an output. Keep outputs (including X values) identical every cycle.",
    "fsm": "Focus: control/FSM. Re-encode states (one-hot or output-encoded) so that outputs and frequently decoded conditions come directly from flops; merge equivalent states and counters; simplify next-state logic. Keep outputs identical every cycle, including before reset if the original drives them through if/else.",
}

RESCUE_SEQ = ["pipeline", "storage", "fsm", "minimal", "logic"]
RESCUE_COMB = ["minimal", "logic", "datapath"]


def cells_line(cells, limit=12):
    items = sorted(((n, c) for n, c in cells.items() if not n.startswith("$")), key=lambda x: -x[1])
    return ", ".join(f"{n.replace('_X1', '')}x{c}" for n, c in items[:limit])


def initial_user(src, top, base, info, event_sensitive, strategy, history=None):
    facts = info.summary()
    s = [f"Original RTL (top `{top}`):", "```verilog", src.strip(), "```",
         f"Baseline: area={base.area:.1f}, ltp={base.ltp}. Cells: {cells_line(base.cells)}.",
         f"Facts: {facts}."]
    if base.ltp_path:
        s.append("Longest path (ltp) runs through: " + " -> ".join(base.ltp_path) + ".")
    if event_sensitive:
        s.append(f"Waveform events are compared exactly. Outputs {', '.join(event_sensitive)} are assigned "
                 f"procedurally with intermediate values in the original: keep their assignment statements "
                 f"(order, default assignments, blocking/non-blocking style) unchanged.")
    if history:
        s.append("Earlier attempts (all failed or gave no gain, do something different): "
                 + "; ".join(history[-8:]) + ".")
    s.append(f"Goal: area < {base.area:.1f} and ltp <= {base.ltp} (lower is better for both).")
    s.append(STRATEGIES.get(strategy, ""))
    s.append(FORMAT)
    return "\n".join(x for x in s if x)


def refine_user(best_src, top, base, best, history, info, event_sensitive):
    s = [f"This verified-equivalent version of `{top}` is the current best "
         f"(area={best.area:.1f}, ltp={best.ltp}; baseline area={base.area:.1f}, ltp={base.ltp}).",
         "```verilog", best_src.strip(), "```",
         f"Cells: {cells_line(best.cells)}."]
    if best.ltp_path:
        s.append("Its longest path (ltp) runs through: " + " -> ".join(best.ltp_path) + ".")
    if history:
        s.append("Attempts so far: " + "; ".join(history[-6:]) + ".")
    if event_sensitive:
        s.append(f"Keep the procedural assignment structure of outputs {', '.join(event_sensitive)}.")
    s.append(f"Find further reductions (area first, ltp must stay <= {base.ltp}). "
             "Target the most expensive cells listed. If nothing safe remains, return the same code.")
    s.append(FORMAT)
    return "\n".join(s)


REPAIR_FORMAT = """Answer format (no other text):
TRACE: evaluate the ORIGINAL code by hand on the first failing case (decode each input bit-field, list the branches taken and every intermediate value), then evaluate your design on the same case and name the exact difference. Be precise; do not guess.
PLAN: 1-4 bullets: the fix, and whether the same mistake affects other cases.
Then ONE ```verilog block with the complete corrected module (keep the optimization where it is correct)."""


def repair_user(problem):
    return "Your design was rejected.\n" + problem.strip() + "\n" + REPAIR_FORMAT


def describe_failure(vres, info):
    """Compact, actionable feedback text from a VerifyResult."""
    st = vres.stage
    if st in ("sanity", "lint", "ports", "synth", "compile"):
        return f"[{st}] {vres.message}"
    mm = vres.mismatch or {}
    if st in ("sim", "sim-relaxed") and mm:
        if mm.get("kind") == "event":
            if mm.get("opt_only_events"):
                return (f"[waveform-events] Output `{mm['signal']}` has the right values but your design produces "
                        f"extra zero-width events {mm.get('opt_only_events')} (the output is assigned more than once "
                        f"in a time step). Assign it exactly once per evaluation: compute intermediates first, use "
                        f"`assign` or a single final assignment, no default-then-override, no explicit sensitivity lists.")
            return (f"[waveform-events] Output `{mm['signal']}` has the same settled values but the original also "
                    f"produces events {mm.get('gold_only_events')} that yours does not: it re-assigns this output "
                    f"procedurally inside a time step. Replicate the original assignment sequence for this output "
                    f"exactly (same default/intermediate assignments, same statement order).")
        cyc = f" cycle {mm['cycle']}" if mm.get("cycle") is not None else ""
        ins = ", ".join(f"{k}={_fmt(v)}" for k, v in (mm.get("inputs") or {}).items())
        prev = mm.get("inputs_prev") or {}
        outs_g = ", ".join(f"{k}={_fmt(v)}" for k, v in (mm.get("outputs_gold") or {}).items())
        outs_o = ", ".join(f"{k}={_fmt(v)}" for k, v in (mm.get("outputs_opt") or {}).items())
        txt = (f"[simulation mismatch at{cyc} (t={mm.get('time')}ps, {mm.get('stimulus')})] output "
               f"`{mm['signal']}`: expected {_fmt(mm.get('gold'))}, got {_fmt(mm.get('opt'))}.\n"
               f"Inputs: {ins}.\nExpected outputs: {outs_g}.\nYour outputs: {outs_o}.")
        for k, snap in enumerate(mm.get("more") or []):
            cy = f" cycle {snap['cycle']}" if snap.get("cycle") is not None else ""
            si = ", ".join(f"{a}={_fmt(v)}" for a, v in (snap.get("inputs") or {}).items())
            sg = ", ".join(f"{a}={_fmt(v)}" for a, v in (snap.get("outputs_gold") or {}).items())
            so = ", ".join(f"{a}={_fmt(v)}" for a, v in (snap.get("outputs_opt") or {}).items())
            txt += f"\nAnother failing case{cy}: inputs {si}; expected {sg}; yours {so}."
        gx, ox = "x" in str(mm.get("gold")), "x" in str(mm.get("opt"))
        if gx != ox:
            txt += ("\nThis is an X-propagation difference: state is still X (no reset yet) and the original "
                    "resolves it differently (if/else on an X condition takes the else branch). Restore the "
                    "original if/else/case structure for the registers feeding this output.")
        elif info.is_sequential and prev:
            txt += "\n(Sequential design: the difference may come from state built up in earlier cycles.)"
        return txt
    if st == "formal":
        return f"[formal] {vres.message}"
    return f"[{st}] {vres.message}"


def _fmt(v):
    """VCD bit-string -> readable value: small values in decimal, wide ones also in hex."""
    if v is None:
        return "?"
    s = str(v)
    if set(s) <= {"0", "1"}:
        n = int(s, 2)
        return str(n) if n < 16 else f"{n}(0x{n:x})"
    return "'b" + s
