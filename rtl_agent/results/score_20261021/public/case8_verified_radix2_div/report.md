# RTL optimization report: `verified_radix2_div`

- generated: 2026-10-21 20:37:00
- input: `/home/hansome_w/backup/rtl_agent/cases/public/case8_verified_radix2_div/radix2_div_v1.v`
- design: top=verified_radix2_div, sequential, 9 ports, ~47 FF bits; clocks: clk(posedge); sync resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **relaxed**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 212.268 | 198.968 | -6.3% |
| logic depth (ltp) | 76 | 76 | +0.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD RELAXED-PASS (power-up X / glitch events differ); course stimuli PASS: stim_radix2_div.v; formal: PROVED (temporal induction succeeded (length 11))
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

> Tier **relaxed**: no candidate passed the course-strict event-by-event comparison with a gain. The emitted design is formally equivalent and identical on every output after reset; it differs only in power-up X values before the reset sequence or in zero-width re-dump events.

## What changed (agent plan)

- Keep the datapath identical; only restructure storage so the 9-bit NEG_DIVISOR and the 16-bit SR are the only wide state, and remove the redundant `start_cnt` by deriving it from `cnt` (cnt==0 means idle, cnt!=0 means running) since cnt is set to 1 on start and 0 on finish — but start_cnt is needed to distinguish idle from the cnt=0 finish cycle, so instead encode the run state in cnt itself: use cnt[3] as the "done" flag and a separate 1-bit `busy` that is exactly start_cnt, which is already minimal.
- Replace the 4-bit cnt with a 3-bit counter plus the cnt[3] flag folded into busy: run 8 iterations, then a final store cycle. Actually keep 4-bit cnt but drop start_cnt by using cnt==0 as idle and cnt==15 as done: start loads cnt=1, increments until cnt==8 (cnt[3]) does the final store and resets cnt to 0. This removes start_cnt flop and its decode logic.
- Fold NEG_DIVISOR's 9th bit: it is always 1 when sign&divisor[7], else it is the two's complement carry; keep as is but note NEG_DIVISOR[8] is only used via CO addition, so keep 9 bits.
- Precompute the quotient/remainer sign-fix as a single conditional negate on the final result register instead of two separate negates of SR halves, sharing one adder.
- Keep res_valid logic exactly; move the cnt[3] check into the enable of the final store.

## Cost

- LLM calls: 8, tokens: 23207 (prompt 13005, completion 10202, of which reasoning 0)
- wall time: 76.1s (LLM 77.5s)
- stop reason: no further gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | no-gain | 212.3 | 76 | [metrics] area 212.3 / ltp 76 is not better than baseline 212.3 / 76 |
| c02 | init:sequential | no-gain | 212.3 | 76 | [metrics] area 212.3 / ltp 76 is not better than baseline 212.3 / 76 |
| c03 | init:datapath | no-gain | 212.3 | 76 | [metrics] area 212.3 / ltp 76 is not better than baseline 212.3 / 76 |
| c04 | init:logic | no-gain | 212.3 | 76 | [metrics] area 212.3 / ltp 76 is not better than baseline 212.3 / 76 |
| c05 | resynth:deep(orig) | fail-sim | 196.6 | 59 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c06 | resynth:deep_s7(orig) | fail-sim | 198.2 | 85 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c07 | resynth:deep_j400(orig) | fail-sim | 196.6 | 59 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c08 | resynth:deep_s7_j400(orig) | fail-sim | 198.2 | 85 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c09 | resynth:deep_i3(orig) | fail-sim | 196.6 | 59 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c10 | resynth:deep_bd(orig) | fail-sim | 198.7 | 84 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c11 | resynth:deep_s7_bds(orig) | fail-sim | 197.9 | 83 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c12 | resynth:dc2x3(orig) | fail-sim | 205.6 | 71 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c13 | resynth:syn2_dch(orig) | no-gain | 223.2 | 87 | [metrics] area 223.2 / ltp 87 is not better than baseline 212.3 / 76 |
| c14 | rescue:pipeline | fail-sim | 210.1 | 84 | [simulation mismatch at cycle 22 (t=225000ps, reset_first)] output `result`: expected 6491 |
| c15 **(final)** | rescue:storage | relaxed | 199.0 | 76 | [simulation mismatch at cycle 4 (t=42000ps, no_reset_first)] output `result`: expected 'bx |
| c16 | repair(c05) | format | - | - | No complete ```verilog block defining module `verified_radix2_div` was found. |
| c17 | repair(c07) | format | - | - | No complete ```verilog block defining module `verified_radix2_div` was found. |

## Agent graph trace

setup(0.32s) -> generate(9.67s) -> evaluate(0.24s) -> refine(8.43s) -> evaluate_refine(0.23s) -> resynth(21.72s) -> evaluate_resynth(2.97s) -> rescue(11.22s) -> evaluate(3.89s) -> repair(11.76s) -> evaluate(0.0s) -> finalize(0.0s)
