# RTL optimization report: `fixed_point_subtractor`

- generated: 2026-10-21 20:26:11
- input: `/home/hansome_w/backup/rtl_agent/cases/public/case3_fixed_point_subtractor/fixed_sub_v1.v`
- design: top=fixed_point_subtractor, combinational, 3 ports, ~0 FF bits
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 477.736 | 366.814 | -23.2% |
| logic depth (ltp) | 30 | 26 | -13.3% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 20010 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_fixed_sub.v; formal: PROVED (ABC iprove: miter output is constant 0)
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (deep_i3) of the original RTL

## Cost

- LLM calls: 6, tokens: 17115 (prompt 12802, completion 4313, of which reasoning 0)
- wall time: 154.5s (LLM 37.5s)
- stop reason: budget exhausted

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | fail-sim | 448.2 | 25 | [simulation mismatch at (t=32000ps, random)] output `c`: expected 4294967295(0xffffffff),  |
| c02 | init:datapath | fail-sim | 402.7 | 32 | [simulation mismatch at (t=522000ps, random)] output `c`: expected 2147483646(0x7ffffffe), |
| c03 | repair(c01) | relaxed | 452.7 | 25 | [waveform-events] Output `c` has the right values but your design produces extra zero-widt |
| c04 | repair(c02) | fail-sim-relaxed | 431.2 | 32 | [waveform-events] Output `c` has the right values but your design produces extra zero-widt |
| c05 | init:logic | fail-sim | 412.8 | 32 | [simulation mismatch at (t=42000ps, random)] output `c`: expected 0, got 'bx00000000000000 |
| c06 | repair(c05) | fail-sim | 458.6 | 25 | [simulation mismatch at (t=142000ps, random)] output `c`: expected 1637386968(0x61988ad8), |
| c07 | resynth:deep(orig) | ltp-worse | 422.1 | 33 | [metrics] the design is functionally correct (verified) and area 422.1 is good, but ltp=33 |
| c08 | resynth:deep_s7(orig) | ltp-worse | 376.1 | 32 | [metrics] the design is functionally correct (verified) and area 376.1 is good, but ltp=32 |
| c09 | resynth:deep_j400(orig) | ltp-worse | 422.1 | 33 | [metrics] the design is functionally correct (verified) and area 422.1 is good, but ltp=33 |
| c10 | resynth:deep_s7_j400(orig) | ltp-worse | 376.1 | 32 | [metrics] the design is functionally correct (verified) and area 376.1 is good, but ltp=32 |
| c11 **(final)** | resynth:deep_i3(orig) | verified | 366.8 | 26 |  |
| c12 | resynth:deep_bd(orig) | ltp-worse | 426.9 | 33 | [metrics] the design is functionally correct (verified) and area 426.9 is good, but ltp=33 |
| c13 | resynth:deep_s7_bds(orig) | ltp-worse | 383.6 | 33 | [metrics] the design is functionally correct (verified) and area 383.6 is good, but ltp=33 |
| c14 | resynth:dc2x3(orig) | ltp-worse | 434.1 | 32 | [metrics] the design is functionally correct (verified) and area 434.1 is good, but ltp=32 |
| c15 | resynth:syn2_dch(orig) | no-gain | 486.8 | 19 | [metrics] area 486.8 / ltp 19 is not better than baseline 477.7 / 30 |

## Agent graph trace

setup(1.07s) -> generate(8.55s) -> evaluate(0.98s) -> repair(5.95s) -> evaluate(1.47s) -> refine(5.36s) -> evaluate_refine(0.69s) -> repair(7.04s) -> evaluate(0.87s) -> resynth(90.61s) -> evaluate_resynth(23.14s) -> finalize(0.0s)
