# RTL optimization report: `verified_traffic_light`

- generated: 2026-10-21 10:25:24
- input: `/home/hansome_w/backup/rtl_agent/cases/extra/traffic_light/verified_traffic_light.v`
- design: top=verified_traffic_light, sequential, 7 ports, ~16 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 53.466 | 50.806 | -5.0% |
| logic depth (ltp) | 45 | 32 | -28.9% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; formal: PROVED (temporal induction succeeded (length 4))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (deep) of the original RTL

## Cost

- LLM calls: 6, tokens: 20353 (prompt 13898, completion 6455, of which reasoning 0)
- wall time: 51.8s (LLM 53.3s)
- stop reason: budget exhausted

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | relaxed | 47.9 | 39 | [simulation mismatch at cycle 0 (t=0ps, no_reset_first)] output `clock`: expected 'bx, got |
| c02 | init:sequential | no-gain | 59.9 | 35 | [metrics] area 59.9 / ltp 35 is not better than baseline 53.5 / 45 |
| c03 | init:datapath | no-gain | 53.5 | 46 | [metrics] area 53.5 / ltp 46 is not better than baseline 53.5 / 45 |
| c04 | repair(c01) | no-gain | 53.5 | 45 | [metrics] area 53.5 / ltp 45 is not better than baseline 53.5 / 45 |
| c05 | init:logic | fail-sim | 30.6 | 21 | [simulation mismatch at cycle 6 (t=65000ps, reset_first)] output `red`: expected 0, got 1. |
| c06 | repair(c05) | relaxed | 47.9 | 39 | [simulation mismatch at cycle 0 (t=0ps, no_reset_first)] output `clock`: expected 'bx, got |
| c07 **(final)** | resynth:deep(orig) | verified | 50.8 | 32 |  |
| c08 | resynth:deep_s7(orig) | verified | 50.8 | 32 |  |
| c09 | resynth:deep_j400(orig) | verified | 50.8 | 32 |  |
| c10 | resynth:deep_s7_j400(orig) | verified | 50.8 | 32 |  |
| c11 | resynth:deep_i3(orig) | verified | 50.8 | 32 |  |
| c12 | resynth:deep_bd(orig) | verified | 51.1 | 41 |  |
| c13 | resynth:deep_s7_bds(orig) | verified | 50.8 | 35 |  |
| c14 | resynth:dc2x3(orig) | ltp-worse | 49.5 | 46 | [metrics] the design is functionally correct (verified) and area 49.5 is good, but ltp=46  |
| c15 | resynth:syn2_dch(orig) | no-gain | 55.1 | 42 | [metrics] area 55.1 / ltp 42 is not better than baseline 53.5 / 45 |

## Agent graph trace

setup(0.45s) -> generate(9.88s) -> evaluate(0.84s) -> repair(6.79s) -> evaluate(0.34s) -> refine(9.29s) -> evaluate_refine(0.36s) -> repair(10.46s) -> evaluate(1.0s) -> resynth(8.34s) -> evaluate_resynth(2.71s) -> finalize(0.0s)
