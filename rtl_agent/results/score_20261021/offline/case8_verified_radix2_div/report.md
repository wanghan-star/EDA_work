# RTL optimization report: `verified_radix2_div`

- generated: 2026-10-21 23:54:49
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case8_verified_radix2_div/radix2_div_v1.v`
- design: top=verified_radix2_div, sequential, 9 ports, ~47 FF bits; clocks: clk(posedge); sync resets: rst(active-high)
- result: **NO-GAIN**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 212.268 | 212.268 | +0.0% |
| logic depth (ltp) | 76 | 76 | +0.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Outcome

No verified candidate improved the design; the original RTL is emitted unchanged.

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 41.0s (LLM 0.0s)
- stop reason: no verified gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | fail-sim | 196.6 | 59 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c02 | resynth:deep_s7(orig) | fail-sim | 198.2 | 85 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c03 | resynth:deep_j400(orig) | fail-sim | 196.6 | 59 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c04 | resynth:deep_s7_j400(orig) | fail-sim | 198.2 | 85 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c05 | resynth:deep_i3(orig) | fail-sim | 196.6 | 59 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c06 | resynth:deep_bd(orig) | fail-sim | 198.7 | 84 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c07 | resynth:deep_s7_bds(orig) | fail-sim | 197.9 | 83 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c08 | resynth:dc2x3(orig) | fail-sim | 205.6 | 71 | [simulation mismatch at cycle 0 (t=5000ps, reset_first)] output `result`: expected 0, got  |
| c09 | resynth:syn2_dch(orig) | no-gain | 223.2 | 87 | [metrics] area 223.2 / ltp 87 is not better than baseline 212.3 / 76 |

## Agent graph trace

setup(0.98s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(34.24s) -> evaluate_resynth(5.64s) -> finalize(0.0s)
