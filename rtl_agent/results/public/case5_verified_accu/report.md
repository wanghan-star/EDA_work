# RTL optimization report: `verified_accu`

- generated: 2026-10-21 20:32:13
- input: `/home/hansome_w/backup/rtl_agent/cases/public/case5_verified_accu/accu_v1.v`
- design: top=verified_accu, sequential, 6 ports, ~13 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **relaxed**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 74.480 | 69.958 | -6.1% |
| logic depth (ltp) | 56 | 47 | -16.1% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD RELAXED-PASS (power-up X / glitch events differ); course stimuli PASS: stim_accu.v; formal: PROVED (temporal induction succeeded (length 7))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

> Tier **relaxed**: no candidate passed the course-strict event-by-event comparison with a gain. The emitted design is formally equivalent and identical on every output after reset; it differs only in power-up X values before the reset sequence or in zero-width re-dump events.

## What changed (agent plan)

ABC logic re-synthesis (dc2x3) of the original RTL

## Cost

- LLM calls: 8, tokens: 16211 (prompt 11107, completion 5104, of which reasoning 0)
- wall time: 47.4s (LLM 48.5s)
- stop reason: no further gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | no-gain | 74.5 | 51 | [metrics] area 74.5 / ltp 51 is not better than baseline 74.5 / 56 |
| c02 | init:sequential | no-gain | 74.5 | 51 | [metrics] area 74.5 / ltp 51 is not better than baseline 74.5 / 56 |
| c03 | init:datapath | no-gain | 74.5 | 51 | [metrics] area 74.5 / ltp 51 is not better than baseline 74.5 / 56 |
| c04 | init:logic | no-gain | 74.5 | 51 | [metrics] area 74.5 / ltp 51 is not better than baseline 74.5 / 56 |
| c05 | resynth:deep(orig) | fail-sim-relaxed | 62.2 | 61 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c06 | resynth:deep_s7(orig) | fail-sim-relaxed | 62.2 | 61 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c07 | resynth:deep_j400(orig) | fail-sim-relaxed | 62.2 | 61 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c08 | resynth:deep_s7_j400(orig) | fail-sim-relaxed | 62.2 | 61 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c09 | resynth:deep_i3(orig) | fail-sim-relaxed | 62.2 | 61 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c10 | resynth:deep_bd(orig) | fail-sim-relaxed | 64.1 | 60 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c11 | resynth:deep_s7_bds(orig) | fail-sim-relaxed | 62.2 | 59 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c12 **(final)** | resynth:dc2x3(orig) | relaxed | 70.0 | 47 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c13 | resynth:syn2_dch(orig) | fail-sim-relaxed | 64.9 | 58 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c14 | rescue:pipeline | no-gain | 74.5 | 51 | [metrics] area 74.5 / ltp 51 is not better than baseline 74.5 / 56 |
| c15 | rescue:storage | no-gain | 74.5 | 51 | [metrics] area 74.5 / ltp 51 is not better than baseline 74.5 / 56 |
| c16 | repair(c05) | format | - | - | No complete ```verilog block defining module `verified_accu` was found. |
| c17 | repair(c06) | format | - | - | No complete ```verilog block defining module `verified_accu` was found. |

## Agent graph trace

setup(0.27s) -> generate(6.38s) -> evaluate(0.23s) -> refine(5.98s) -> evaluate_refine(0.18s) -> resynth(11.55s) -> evaluate_resynth(7.15s) -> rescue(8.87s) -> evaluate(0.19s) -> repair(4.85s) -> evaluate(0.0s) -> finalize(0.0s)
