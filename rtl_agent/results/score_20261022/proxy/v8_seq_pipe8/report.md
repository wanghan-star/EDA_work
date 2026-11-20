# RTL optimization report: `TopModule`

- generated: 2026-10-22 15:59:56
- input: `/home/hansome_w/backup/rtl_agent/cases/proxy/v8_seq_pipe8/v8_seq_pipe8.v`
- design: top=TopModule, sequential, 21 ports, ~39 FF bits; clocks: clk(posedge); async resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 3620.260 | 3429.538 | -5.3% |
| logic depth (ltp) | 303 | 212 | -30.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_mac8.v; formal: bounded PASS, 1 cycles
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (deep) of the original RTL

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 710.8s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 **(final)** | resynth:deep(orig) | verified | 3429.5 | 212 |  |
| c02 | resynth:deep_s7(orig) | verified | 3441.0 | 249 |  |
| c03 | resynth:deep_j400(orig) | duplicate | 3429.5 | 212 | same area/ltp/cell mix as a candidate already verified |
| c04 | resynth:deep_s7_j400(orig) | duplicate | 3441.0 | 249 | same area/ltp/cell mix as a candidate already verified |
| c05 | resynth:deep_i3(orig) | duplicate | 3429.5 | 212 | same area/ltp/cell mix as a candidate already verified |
| c06 | resynth:deep_bd(orig) | synth-error | - | - | [yosys] synthesis exceeded 60s (original needs 1s); avoid constructs that unroll into huge |
| c07 | resynth:deep_s7_bds(orig) | verified | 3454.5 | 288 |  |
| c08 | resynth:dc2x3(orig) | no-gain | 3650.8 | 275 | [metrics] area 3650.8 / ltp 275 is not better than baseline 3620.3 / 303 |
| c09 | resynth:syn2_dch(orig) | no-gain | 4100.7 | 306 | [metrics] area 4100.7 / ltp 306 is not better than baseline 3620.3 / 303 |

## Agent graph trace

setup(1.33s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(160.96s) -> evaluate_resynth(218.23s) -> finalize(0.0s)
