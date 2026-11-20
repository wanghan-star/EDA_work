# RTL optimization report: `fixed_point_subtractor`

- generated: 2026-11-20 03:41:15
- input: `/f/Projects/EDA_work/rtl_agent/cases/public/case3/rtl.v`
- design: top=fixed_point_subtractor, combinational, 3 ports, ~0 FF bits
- result: **NO-GAIN**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 477.736 | 477.736 | +0.0% |
| logic depth (ltp) | 30 | 30 | +0.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Outcome

No verified candidate improved the design; the original RTL is emitted unchanged.

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 186.1s (LLM 0.0s)
- stop reason: no verified gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | ltp-worse | 429.9 | 33 | [metrics] the design is functionally correct (verified) and area 429.9 is good, but ltp=33 |
| c02 | resynth:deep_s7(orig) | ltp-worse | 408.0 | 33 | [metrics] the design is functionally correct (verified) and area 408.0 is good, but ltp=33 |
| c03 | resynth:deep_j400(orig) | duplicate | 429.9 | 33 | same area/ltp/cell mix as a candidate already verified |
| c04 | resynth:deep_s7_j400(orig) | duplicate | 408.0 | 33 | same area/ltp/cell mix as a candidate already verified |
| c05 | resynth:deep_i3(orig) | ltp-worse | 417.1 | 33 | [metrics] the design is functionally correct (verified) and area 417.1 is good, but ltp=33 |
| c06 | resynth:deep_bd(orig) | ltp-worse | 429.3 | 33 | [metrics] the design is functionally correct (verified) and area 429.3 is good, but ltp=33 |
| c07 | resynth:deep_s7_bds(orig) | ltp-worse | 409.1 | 33 | [metrics] the design is functionally correct (verified) and area 409.1 is good, but ltp=33 |
| c08 | resynth:dc2x3(orig) | ltp-worse | 423.7 | 32 | [metrics] the design is functionally correct (verified) and area 423.7 is good, but ltp=32 |
| c09 | resynth:syn2_dch(orig) | no-gain | 488.1 | 20 | [metrics] area 488.1 / ltp 20 is not better than baseline 477.7 / 30 |

## Agent graph trace

setup(14.4s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(124.79s) -> evaluate_resynth(45.25s) -> finalize(0.0s)
