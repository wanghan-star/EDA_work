# RTL optimization report: `TopModule`

- generated: 2026-10-22 15:47:47
- input: `/home/hansome_w/backup/rtl_agent/cases/proxy/mac8_v6_4parallel/mac8_v6_4parallel.v`
- design: top=TopModule, sequential, 21 ports, ~38 FF bits; clocks: clk(posedge); async resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 3741.024 | 3675.056 | -1.8% |
| logic depth (ltp) | 171 | 106 | -38.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_mac8.v; formal: PROVED (temporal induction succeeded (length 4))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

- Replace the 1-bit `i` phase register with a single-cycle FSM-free structure: keep `i` but note done=1 freezes everything, so `i` only matters while !done. Keep it as-is (free flop).
- Share the two half dot-products: compute both halves' products once, and reuse the second-half sum for both acc update and y. Original already computes x4*c4+...+x7*c7 twice (once for acc, once for y) — factor into one wire.
- Narrow nothing observable; keep 18-bit acc/y.
- Keep exact if/else priority and X semantics; only hoist the duplicated second-half sum into a shared wire.

## Cost

- LLM calls: 3, tokens: 6924 (prompt 4713, completion 2211, of which reasoning 0)
- wall time: 680.9s (LLM 24.6s)
- stop reason: budget exhausted

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | verified | 3713.4 | 106 |  |
| c02 **(final)** | init:storage | verified | 3675.1 | 106 |  |
| c03 | init:datapath | no-gain | 3782.5 | 114 | [metrics] area 3782.5 / ltp 114 is not better than baseline 3741.0 / 171 |
| c04 | resynth:deep(orig) | fail-sim-relaxed | 3529.0 | 188 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c05 | resynth:deep_s7(orig) | fail-sim-relaxed | 3605.4 | 202 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c06 | resynth:deep_j400(orig) | duplicate | 3529.0 | 188 | same area/ltp/cell mix as a candidate already verified |
| c07 | resynth:deep_s7_j400(orig) | duplicate | 3605.4 | 202 | same area/ltp/cell mix as a candidate already verified |
| c08 | resynth:deep_i3(orig) | fail-sim-relaxed | 3505.6 | 193 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c09 | resynth:deep_bd(orig) | no-gain | 6107.1 | 258 | [metrics] area 6107.1 / ltp 258 is not better than baseline 3741.0 / 171 |
| c10 | resynth:deep_s7_bds(orig) | fail-sim-relaxed | 3613.9 | 192 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c11 | resynth:dc2x3(orig) | no-gain | 3773.2 | 202 | [metrics] area 3773.2 / ltp 202 is not better than baseline 3741.0 / 171 |
| c12 | resynth:syn2_dch(orig) | no-gain | 4477.8 | 181 | [metrics] area 4477.8 / ltp 181 is not better than baseline 3741.0 / 171 |
| c13 | resynth:deep(c02) | relaxed | 3473.7 | 115 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c14 | resynth:deep_s7(c02) | not-better | 3592.6 | 117 |  |
| c15 | resynth:deep_j400(c02) | duplicate | 3473.7 | 115 | same area/ltp/cell mix as a candidate already verified |
| c16 | resynth:deep_s7_j400(c02) | not-better | 3592.6 | 117 |  |
| c17 | resynth:deep_i3(c02) | relaxed | 3502.4 | 116 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c18 | resynth:deep_bd(c02) | synth-error | - | - | [yosys] synthesis exceeded 60s (original needs 1s); avoid constructs that unroll into huge |
| c19 | resynth:deep_s7_bds(c02) | not-better | 3584.1 | 113 |  |
| c20 | resynth:dc2x3(c02) | no-gain | 3750.3 | 110 | [metrics] area 3750.3 / ltp 110 is not better than baseline 3741.0 / 171 |
| c21 | resynth:syn2_dch(c02) | no-gain | 4372.2 | 114 | [metrics] area 4372.2 / ltp 114 is not better than baseline 3741.0 / 171 |

## Agent graph trace

setup(1.6s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> generate(9.24s) -> evaluate(13.62s) -> resynth(243.26s) -> evaluate_resynth(398.9s) -> finalize(0.0s)
