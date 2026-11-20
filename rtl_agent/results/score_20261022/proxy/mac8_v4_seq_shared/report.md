# RTL optimization report: `TopModule`

- generated: 2026-10-22 14:45:15
- input: `/home/hansome_w/backup/rtl_agent/cases/proxy/mac8_v4_seq_shared/mac8_v4_seq_shared.v`
- design: top=TopModule, sequential, 21 ports, ~40 FF bits; clocks: clk(posedge); async resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **relaxed**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 3974.306 | 3131.618 | -21.2% |
| logic depth (ltp) | 142 | 114 | -19.7% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD RELAXED-PASS (power-up X / glitch events differ); course stimuli PASS: stim_mac8.v; formal: bounded PASS, 8 cycles
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

> Tier **relaxed**: no candidate passed the course-strict event-by-event comparison with a gain. The emitted design is formally equivalent and identical on every output after reset; it differs only in power-up X values before the reset sequence or in zero-width re-dump events.

## What changed (agent plan)

ABC logic re-synthesis (deep_s7_bds) of the original RTL

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 1189.5s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | relaxed | 3159.0 | 125 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c02 | resynth:deep_s7(orig) | relaxed | 3146.8 | 115 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c03 | resynth:deep_j400(orig) | relaxed | 3159.0 | 125 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c04 | resynth:deep_s7_j400(orig) | relaxed | 3146.8 | 115 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c05 | resynth:deep_i3(orig) | relaxed | 3179.5 | 128 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c06 | resynth:deep_bd(orig) | relaxed | 3753.5 | 140 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c07 **(final)** | resynth:deep_s7_bds(orig) | relaxed | 3131.6 | 114 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c08 | resynth:dc2x3(orig) | relaxed | 3406.7 | 116 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c09 | resynth:syn2_dch(orig) | relaxed | 3733.8 | 124 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |

## Agent graph trace

setup(1.1s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(141.55s) -> evaluate_resynth(708.31s) -> finalize(0.0s)
