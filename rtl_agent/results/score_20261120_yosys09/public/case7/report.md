# RTL optimization report: `verified_adder_64bit`

- generated: 2026-11-20 03:54:07
- input: `/f/Projects/EDA_work/rtl_agent/cases/public/case7/rtl.v`
- design: top=verified_adder_64bit, sequential, 7 ports, ~360 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 614.726 | 556.738 | -9.4% |
| logic depth (ltp) | 66 | 54 | -18.2% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: case7_tb.v; formal: PROVED (temporal induction succeeded (length 4))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (syn2_dch) of c09

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 462.0s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | arithmetic:fused_all | ltp-worse | 493.2 | 77 | [metrics] the design is functionally correct (verified) and area 493.2 is good, but ltp=77 |
| c02 | arithmetic:fused_0 | ltp-worse | 578.0 | 70 | [metrics] the design is functionally correct (verified) and area 578.0 is good, but ltp=70 |
| c03 | arithmetic:fused_1 | ltp-worse | 571.1 | 70 | [metrics] the design is functionally correct (verified) and area 571.1 is good, but ltp=70 |
| c04 | arithmetic:fused_2 | ltp-worse | 570.0 | 70 | [metrics] the design is functionally correct (verified) and area 570.0 is good, but ltp=70 |
| c05 | arithmetic:cla4_all | ltp-worse | 532.3 | 67 | [metrics] the design is functionally correct (verified) and area 532.3 is good, but ltp=67 |
| c06 | arithmetic:cla4_0 | verified | 587.9 | 66 |  |
| c07 | arithmetic:cla4_1 | ltp-worse | 586.8 | 67 | [metrics] the design is functionally correct (verified) and area 586.8 is good, but ltp=67 |
| c08 | arithmetic:cla4_2 | verified | 584.7 | 66 |  |
| c09 | arithmetic:cla8_all | verified | 564.7 | 55 |  |
| c10 | arithmetic:cla8_0 | verified | 609.9 | 60 |  |
| c11 | arithmetic:cla8_1 | verified | 598.2 | 62 |  |
| c12 | arithmetic:cla8_2 | ltp-worse | 594.5 | 68 | [metrics] the design is functionally correct (verified) and area 594.5 is good, but ltp=68 |
| c13 | resynth:deep(orig) | ltp-worse | 509.9 | 75 | [metrics] the design is functionally correct (verified) and area 509.9 is good, but ltp=75 |
| c14 | resynth:deep_s7(orig) | ltp-worse | 499.3 | 75 | [metrics] the design is functionally correct (verified) and area 499.3 is good, but ltp=75 |
| c15 | resynth:deep_j400(orig) | ltp-worse | 510.5 | 75 | [metrics] the design is functionally correct (verified) and area 510.5 is good, but ltp=75 |
| c16 | resynth:deep_s7_j400(orig) | ltp-worse | 516.0 | 74 | [metrics] the design is functionally correct (verified) and area 516.0 is good, but ltp=74 |
| c17 | resynth:deep_i3(orig) | ltp-worse | 501.1 | 75 | [metrics] the design is functionally correct (verified) and area 501.1 is good, but ltp=75 |
| c18 | resynth:deep_bd(orig) | ltp-worse | 511.3 | 75 | [metrics] the design is functionally correct (verified) and area 511.3 is good, but ltp=75 |
| c19 | resynth:deep_s7_bds(orig) | ltp-worse | 510.7 | 74 | [metrics] the design is functionally correct (verified) and area 510.7 is good, but ltp=74 |
| c20 | resynth:dc2x3(orig) | not-better | 609.4 | 73 | [metrics] area 609.4 is good but ltp=73 exceeds the baseline ltp=66. Your longest path run |
| c21 | resynth:syn2_dch(orig) | no-gain | 715.0 | 55 | [metrics] area 715.0 / ltp 55 is not better than baseline 614.7 / 66 |
| c22 | resynth:dc2x3(c09) | ltp-worse | 510.2 | 70 | [metrics] the design is functionally correct (verified) and area 510.2 is good, but ltp=70 |
| c23 **(final)** | resynth:syn2_dch(c09) | verified | 556.7 | 54 |  |
| c24 | resynth:dc2x3(c01) | ltp-worse | 511.5 | 74 | [metrics] the design is functionally correct (verified) and area 511.5 is good, but ltp=74 |
| c25 | resynth:syn2_dch(c01) | not-better | 569.5 | 56 |  |

## Agent graph trace

setup(11.27s) -> arithmetic(0.02s) -> evaluate_arithmetic(117.68s) -> resynth(124.94s) -> evaluate_resynth(155.85s) -> finalize(0.0s)
