# RTL optimization report: `verified_radix2_div`

- generated: 2026-11-20 04:03:22
- input: `/f/Projects/EDA_work/rtl_agent/cases/public/case8/rtl.v`
- design: top=verified_radix2_div, sequential, 9 ports, ~47 FF bits; clocks: clk(posedge); sync resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 249.508 | 230.090 | -7.8% |
| logic depth (ltp) | 85 | 68 | -20.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: case8_tb.v; formal: bounded PASS, 29 cycles
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (deep_s7) of the original RTL

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 554.4s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | verified | 227.7 | 74 |  |
| c02 **(final)** | resynth:deep_s7(orig) | verified | 230.1 | 68 |  |
| c03 | resynth:deep_j400(orig) | duplicate | 227.7 | 74 | same area/ltp/cell mix as a candidate already verified |
| c04 | resynth:deep_s7_j400(orig) | verified | 227.2 | 78 |  |
| c05 | resynth:deep_i3(orig) | ltp-worse | 227.2 | 88 | [metrics] the design is functionally correct (verified) and area 227.2 is good, but ltp=88 |
| c06 | resynth:deep_bd(orig) | verified | 233.3 | 81 |  |
| c07 | resynth:deep_s7_bds(orig) | verified | 228.0 | 71 |  |
| c08 | resynth:dc2x3(orig) | ltp-worse | 243.4 | 91 | [metrics] the design is functionally correct (verified) and area 243.4 is good, but ltp=91 |
| c09 | resynth:syn2_dch(orig) | ltp-worse | 246.3 | 88 | [metrics] the design is functionally correct (verified) and area 246.3 is good, but ltp=88 |

## Agent graph trace

setup(8.31s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(123.74s) -> evaluate_resynth(107.44s) -> finalize(0.0s)
