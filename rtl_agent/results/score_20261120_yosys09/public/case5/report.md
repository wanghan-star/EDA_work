# RTL optimization report: `verified_accu`

- generated: 2026-11-20 03:43:40
- input: `/f/Projects/EDA_work/rtl_agent/cases/public/case5/rtl.v`
- design: top=verified_accu, sequential, 6 ports, ~13 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **OPTIMIZED**, verification tier: **relaxed**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 84.588 | 77.938 | -7.9% |
| logic depth (ltp) | 62 | 48 | -22.6% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD RELAXED-PASS (power-up X / glitch events differ); course stimuli PASS: case5_tb.v; formal: PROVED (temporal induction succeeded (length 5))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

> Tier **relaxed**: no candidate passed the course-strict event-by-event comparison with a gain. The emitted design is formally equivalent and identical on every output after reset; it differs only in power-up X values before the reset sequence or in zero-width re-dump events.

## What changed (agent plan)

ABC logic re-synthesis (deep) of the original RTL

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 142.6s (LLM 0.0s)
- stop reason: verified improvement

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 **(final)** | resynth:deep(orig) | relaxed | 77.9 | 48 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c02 | resynth:deep_s7(orig) | relaxed | 78.7 | 51 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `valid_out`: expected 0 |
| c03 | resynth:deep_j400(orig) | duplicate | 77.9 | 48 | same area/ltp/cell mix as a candidate already verified |
| c04 | resynth:deep_s7_j400(orig) | duplicate | 78.7 | 51 | same area/ltp/cell mix as a candidate already verified |
| c05 | resynth:deep_i3(orig) | duplicate | 77.9 | 48 | same area/ltp/cell mix as a candidate already verified |
| c06 | resynth:deep_bd(orig) | duplicate | 77.9 | 48 | same area/ltp/cell mix as a candidate already verified |
| c07 | resynth:deep_s7_bds(orig) | duplicate | 77.9 | 48 | same area/ltp/cell mix as a candidate already verified |
| c08 | resynth:dc2x3(orig) | no-gain | 85.9 | 62 | [metrics] area 85.9 / ltp 62 is not better than baseline 84.6 / 62 |
| c09 | resynth:syn2_dch(orig) | no-gain | 89.9 | 59 | [metrics] area 89.9 / ltp 59 is not better than baseline 84.6 / 62 |

## Agent graph trace

setup(10.06s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(88.52s) -> evaluate_resynth(29.56s) -> finalize(0.0s)
