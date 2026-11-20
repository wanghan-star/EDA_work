# RTL optimization report: `verified_adder_64bit`

- generated: 2026-10-21 23:56:18
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case7_verified_adder_64bit/adder64_v1_pipe.v`
- design: top=verified_adder_64bit, sequential, 7 ports, ~360 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback off

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
- wall time: 44.1s (LLM 0.0s)
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
| c13 | resynth:dc2x3(c01) | ltp-worse | 384.9 | 69 | [metrics] the design is functionally correct (verified) and area 384.9 is good, but ltp=69 |
| c14 **(final)** | resynth:syn2_dch(c01) | verified | 441.0 | 47 |  |

## Agent graph trace

setup(1.2s) -> arithmetic(0.02s) -> evaluate_arithmetic(20.76s) -> resynth(0.2s) -> evaluate_resynth(9.89s) -> finalize(0.0s)
