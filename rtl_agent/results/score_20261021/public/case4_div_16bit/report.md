# RTL optimization report: `div_16bit`

- generated: 2026-10-21 23:50:46
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case4_div_16bit/div16_v1.v`
- design: top=div_16bit, combinational, 4 ports, ~0 FF bits
- result: **NO-GAIN**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 775.124 | 775.124 | +0.0% |
| logic depth (ltp) | 59 | 59 | +0.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Outcome

No verified candidate improved the design; the original RTL is emitted unchanged.

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 126.6s (LLM 0.0s)
- stop reason: no verified gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | fail-sim | 749.3 | 66 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c02 | resynth:deep_s7(orig) | fail-sim | 749.3 | 66 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c03 | resynth:deep_j400(orig) | fail-sim | 634.4 | 83 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c04 | resynth:deep_s7_j400(orig) | fail-sim | 625.4 | 90 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c05 | resynth:deep_i3(orig) | fail-sim | 619.2 | 88 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c06 | resynth:deep_bd(orig) | fail-sim | 641.3 | 68 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c07 | resynth:deep_s7_bds(orig) | fail-sim | 640.8 | 83 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c08 | resynth:dc2x3(orig) | fail-sim | 747.7 | 55 | [waveform-events] Output `result` has the same settled values but the original also produc |
| c09 | resynth:syn2_dch(orig) | fail-sim | 726.7 | 55 | [waveform-events] Output `result` has the same settled values but the original also produc |

## Agent graph trace

setup(1.29s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> resynth(95.47s) -> evaluate_resynth(29.72s) -> finalize(0.0s)
