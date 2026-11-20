# RTL optimization report: `TopModule`

- generated: 2026-10-22 15:20:28
- input: `/home/hansome_w/backup/rtl_agent/cases/proxy/v7_seq_pipe4/v7_seq_pipe4.v`
- design: top=TopModule, sequential, 21 ports, ~40 FF bits; clocks: clk(posedge); async resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **relaxed**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 3787.308 | 3540.726 | -6.5% |
| logic depth (ltp) | 203 | 190 | -6.4% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD RELAXED-PASS (power-up X / glitch events differ); course stimuli PASS: stim_mac8.v; formal: bounded PASS, 2 cycles
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

> Tier **relaxed**: no candidate passed the course-strict event-by-event comparison with a gain. The emitted design is formally equivalent and identical on every output after reset; it differs only in power-up X values before the reset sequence or in zero-width re-dump events.

## What changed (agent plan)

ABC logic re-synthesis (deep) of the original RTL

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 884.0s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 **(final)** | resynth:deep(orig) | relaxed | 3540.7 | 190 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c02 | resynth:deep_s7(orig) | relaxed | 3605.6 | 200 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c03 | resynth:deep_j400(orig) | relaxed | 3540.7 | 190 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c04 | resynth:deep_s7_j400(orig) | relaxed | 3605.6 | 200 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c05 | resynth:deep_i3(orig) | fail-sim-relaxed | 3535.7 | 219 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c06 | resynth:deep_bd(orig) | no-gain | 6172.8 | 257 | [metrics] area 6172.8 / ltp 257 is not better than baseline 3787.3 / 203 |
| c07 | resynth:deep_s7_bds(orig) | relaxed | 3613.1 | 202 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c08 | resynth:dc2x3(orig) | no-gain | 3809.4 | 213 | [metrics] area 3809.4 / ltp 213 is not better than baseline 3787.3 / 203 |
| c09 | resynth:syn2_dch(orig) | no-gain | 4339.0 | 221 | [metrics] area 4339.0 / ltp 221 is not better than baseline 3787.3 / 203 |

## Agent graph trace

setup(1.39s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(171.82s) -> evaluate_resynth(392.21s) -> finalize(0.0s)
