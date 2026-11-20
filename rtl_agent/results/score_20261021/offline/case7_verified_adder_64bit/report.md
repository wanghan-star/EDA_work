# RTL optimization report: `verified_adder_64bit`

- generated: 2026-10-21 23:54:08
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case7_verified_adder_64bit/adder64_v1_pipe.v`
- design: top=verified_adder_64bit, sequential, 7 ports, ~360 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 484.386 | 441.028 | -9.0% |
| logic depth (ltp) | 57 | 47 | -17.5% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_adder64.v; formal: PROVED (temporal induction succeeded (length 4))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (syn2_dch) of c01

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 169.4s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | arithmetic:fused_all | ltp-worse | 384.9 | 69 | [metrics] the design is functionally correct (verified) and area 384.9 is good, but ltp=69 |
| c02 | arithmetic:fused_0 | ltp-worse | 450.9 | 61 | [metrics] the design is functionally correct (verified) and area 450.9 is good, but ltp=61 |
| c03 | arithmetic:fused_1 | ltp-worse | 455.1 | 64 | [metrics] the design is functionally correct (verified) and area 455.1 is good, but ltp=64 |
| c04 | arithmetic:fused_2 | ltp-worse | 449.0 | 63 | [metrics] the design is functionally correct (verified) and area 449.0 is good, but ltp=63 |
| c05 | arithmetic:cla4_all | ltp-worse | 445.6 | 67 | [metrics] the design is functionally correct (verified) and area 445.6 is good, but ltp=67 |
| c06 | arithmetic:cla4_0 | ltp-worse | 472.4 | 61 | [metrics] the design is functionally correct (verified) and area 472.4 is good, but ltp=61 |
| c07 | arithmetic:cla4_1 | ltp-worse | 472.4 | 61 | [metrics] the design is functionally correct (verified) and area 472.4 is good, but ltp=61 |
| c08 | arithmetic:cla4_2 | ltp-worse | 472.4 | 61 | [metrics] the design is functionally correct (verified) and area 472.4 is good, but ltp=61 |
| c09 | arithmetic:cla8_all | verified | 474.3 | 48 |  |
| c10 | arithmetic:cla8_0 | ltp-worse | 483.9 | 59 | [metrics] the design is functionally correct (verified) and area 483.9 is good, but ltp=59 |
| c11 | arithmetic:cla8_1 | ltp-worse | 483.9 | 59 | [metrics] the design is functionally correct (verified) and area 483.9 is good, but ltp=59 |
| c12 | arithmetic:cla8_2 | ltp-worse | 483.9 | 59 | [metrics] the design is functionally correct (verified) and area 483.9 is good, but ltp=59 |
| c13 | resynth:deep(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c14 | resynth:deep_s7(orig) | ltp-worse | 353.5 | 71 | [metrics] the design is functionally correct (verified) and area 353.5 is good, but ltp=71 |
| c15 | resynth:deep_j400(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c16 | resynth:deep_s7_j400(orig) | ltp-worse | 353.5 | 71 | [metrics] the design is functionally correct (verified) and area 353.5 is good, but ltp=71 |
| c17 | resynth:deep_i3(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c18 | resynth:deep_bd(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c19 | resynth:deep_s7_bds(orig) | ltp-worse | 353.5 | 71 | [metrics] the design is functionally correct (verified) and area 353.5 is good, but ltp=71 |
| c20 | resynth:dc2x3(orig) | no-gain | 524.6 | 57 | [metrics] area 524.6 / ltp 57 is not better than baseline 484.4 / 57 |
| c21 | resynth:syn2_dch(orig) | no-gain | 613.1 | 45 | [metrics] area 613.1 / ltp 45 is not better than baseline 484.4 / 57 |
| c22 | resynth:deep(c09) | ltp-worse | 372.4 | 72 | [metrics] the design is functionally correct (verified) and area 372.4 is good, but ltp=72 |
| c23 | resynth:deep_s7(c09) | ltp-worse | 377.7 | 72 | [metrics] the design is functionally correct (verified) and area 377.7 is good, but ltp=72 |
| c24 | resynth:deep_j400(c09) | ltp-worse | 372.4 | 72 | [metrics] the design is functionally correct (verified) and area 372.4 is good, but ltp=72 |
| c25 | resynth:deep_s7_j400(c09) | ltp-worse | 377.7 | 72 | [metrics] the design is functionally correct (verified) and area 377.7 is good, but ltp=72 |
| c26 | resynth:deep_i3(c09) | ltp-worse | 372.4 | 72 | [metrics] the design is functionally correct (verified) and area 372.4 is good, but ltp=72 |
| c27 | resynth:deep_bd(c09) | ltp-worse | 372.4 | 72 | [metrics] the design is functionally correct (verified) and area 372.4 is good, but ltp=72 |
| c28 | resynth:deep_s7_bds(c09) | ltp-worse | 377.7 | 72 | [metrics] the design is functionally correct (verified) and area 377.7 is good, but ltp=72 |
| c29 | resynth:dc2x3(c09) | ltp-worse | 387.6 | 69 | [metrics] the design is functionally correct (verified) and area 387.6 is good, but ltp=69 |
| c30 | resynth:syn2_dch(c09) | verified | 439.2 | 51 |  |
| c31 | resynth:deep(c01) | ltp-worse | 372.7 | 69 | [metrics] the design is functionally correct (verified) and area 372.7 is good, but ltp=69 |
| c32 | resynth:deep_s7(c01) | ltp-worse | 378.8 | 69 | [metrics] the design is functionally correct (verified) and area 378.8 is good, but ltp=69 |
| c33 | resynth:deep_j400(c01) | ltp-worse | 372.7 | 69 | [metrics] the design is functionally correct (verified) and area 372.7 is good, but ltp=69 |
| c34 | resynth:deep_s7_j400(c01) | ltp-worse | 378.8 | 69 | [metrics] the design is functionally correct (verified) and area 378.8 is good, but ltp=69 |
| c35 | resynth:deep_i3(c01) | ltp-worse | 372.7 | 69 | [metrics] the design is functionally correct (verified) and area 372.7 is good, but ltp=69 |
| c36 | resynth:deep_bd(c01) | ltp-worse | 372.7 | 69 | [metrics] the design is functionally correct (verified) and area 372.7 is good, but ltp=69 |
| c37 | resynth:deep_s7_bds(c01) | ltp-worse | 378.8 | 69 | [metrics] the design is functionally correct (verified) and area 378.8 is good, but ltp=69 |
| c38 | resynth:dc2x3(c01) | ltp-worse | 384.9 | 69 | [metrics] the design is functionally correct (verified) and area 384.9 is good, but ltp=69 |
| c39 **(final)** | resynth:syn2_dch(c01) | verified | 441.0 | 47 |  |

## Agent graph trace

setup(1.14s) -> arithmetic(0.0s) -> evaluate_arithmetic(16.85s) -> resynth(70.35s) -> evaluate_resynth(69.27s) -> finalize(0.0s)
