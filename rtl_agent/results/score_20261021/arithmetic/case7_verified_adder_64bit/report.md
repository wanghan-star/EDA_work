# RTL optimization report: `verified_adder_64bit`

- generated: 2026-10-21 23:54:14
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case7_verified_adder_64bit/adder64_v1_pipe.v`
- design: top=verified_adder_64bit, sequential, 7 ports, ~360 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback off

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 484.386 | 474.278 | -2.1% |
| logic depth (ltp) | 57 | 48 | -15.8% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_adder64.v; formal: PROVED (temporal induction succeeded (length 4))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

Unsigned carry fusion / block lookahead; original parameters and state retained

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 31.1s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | arithmetic:fused_all | not-better | 384.9 | 69 | [metrics] area 384.9 is good but ltp=69 exceeds the baseline ltp=57. Your longest path run |
| c02 | arithmetic:fused_0 | not-better | 450.9 | 61 | [metrics] area 450.9 is good but ltp=61 exceeds the baseline ltp=57. Your longest path run |
| c03 | arithmetic:fused_1 | not-better | 455.1 | 64 | [metrics] area 455.1 is good but ltp=64 exceeds the baseline ltp=57. Your longest path run |
| c04 | arithmetic:fused_2 | not-better | 449.0 | 63 | [metrics] area 449.0 is good but ltp=63 exceeds the baseline ltp=57. Your longest path run |
| c05 | arithmetic:cla4_all | not-better | 445.6 | 67 | [metrics] area 445.6 is good but ltp=67 exceeds the baseline ltp=57. Your longest path run |
| c06 | arithmetic:cla4_0 | not-better | 472.4 | 61 | [metrics] area 472.4 is good but ltp=61 exceeds the baseline ltp=57. Your longest path run |
| c07 | arithmetic:cla4_1 | not-better | 472.4 | 61 | [metrics] area 472.4 is good but ltp=61 exceeds the baseline ltp=57. Your longest path run |
| c08 | arithmetic:cla4_2 | not-better | 472.4 | 61 | [metrics] area 472.4 is good but ltp=61 exceeds the baseline ltp=57. Your longest path run |
| c09 **(final)** | arithmetic:cla8_all | verified | 474.3 | 48 |  |
| c10 | arithmetic:cla8_0 | not-better | 483.9 | 59 | [metrics] area 483.9 is good but ltp=59 exceeds the baseline ltp=57. Your longest path run |
| c11 | arithmetic:cla8_1 | not-better | 483.9 | 59 | [metrics] area 483.9 is good but ltp=59 exceeds the baseline ltp=57. Your longest path run |
| c12 | arithmetic:cla8_2 | not-better | 483.9 | 59 | [metrics] area 483.9 is good but ltp=59 exceeds the baseline ltp=57. Your longest path run |

## Agent graph trace

setup(2.23s) -> arithmetic(0.03s) -> evaluate_arithmetic(12.59s) -> finalize(0.0s)
