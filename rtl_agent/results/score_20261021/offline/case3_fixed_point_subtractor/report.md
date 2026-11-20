# RTL optimization report: `fixed_point_subtractor`

- generated: 2026-10-21 23:48:39
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case3_fixed_point_subtractor/fixed_sub_v1.v`
- design: top=fixed_point_subtractor, combinational, 3 ports, ~0 FF bits
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 477.736 | 353.780 | -25.9% |
| logic depth (ltp) | 30 | 25 | -16.7% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 20010 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_fixed_sub.v; formal: PROVED (ABC iprove: miter output is constant 0)
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (deep_i3) of the original RTL

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 107.8s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | ltp-worse | 424.0 | 33 | [metrics] the design is functionally correct (verified) and area 424.0 is good, but ltp=33 |
| c02 | resynth:deep_s7(orig) | ltp-worse | 387.8 | 31 | [metrics] the design is functionally correct (verified) and area 387.8 is good, but ltp=31 |
| c03 | resynth:deep_j400(orig) | ltp-worse | 424.0 | 33 | [metrics] the design is functionally correct (verified) and area 424.0 is good, but ltp=33 |
| c04 | resynth:deep_s7_j400(orig) | verified | 364.7 | 25 |  |
| c05 **(final)** | resynth:deep_i3(orig) | verified | 353.8 | 25 |  |
| c06 | resynth:deep_bd(orig) | ltp-worse | 428.0 | 33 | [metrics] the design is functionally correct (verified) and area 428.0 is good, but ltp=33 |
| c07 | resynth:deep_s7_bds(orig) | verified | 365.2 | 25 |  |
| c08 | resynth:dc2x3(orig) | ltp-worse | 427.7 | 32 | [metrics] the design is functionally correct (verified) and area 427.7 is good, but ltp=32 |
| c09 | resynth:syn2_dch(orig) | no-gain | 524.0 | 19 | [metrics] area 524.0 / ltp 19 is not better than baseline 477.7 / 30 |

## Agent graph trace

setup(0.8s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(90.31s) -> evaluate_resynth(12.45s) -> finalize(0.0s)
