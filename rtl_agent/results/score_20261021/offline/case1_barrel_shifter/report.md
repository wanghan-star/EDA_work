# RTL optimization report: `barrel_shifter`

- generated: 2026-10-21 23:46:41
- input: `/mnt/f/Projects/EDA_work/rtl_agent/cases/public/case1_barrel_shifter/barrel_v1_mux.v`
- design: top=barrel_shifter, combinational, 3 ports, ~0 FF bits; submodules: mux2X1
- result: **NO-GAIN**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 39.368 | 39.368 | +0.0% |
| logic depth (ltp) | 4 | 4 | +0.0% |
| course-literal baseline (no flatten) | area 1.862, ltp 1 | | hierarchy makes the literal script report a sub-module |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Outcome

No verified candidate improved the design; the original RTL is emitted unchanged.

## Cost

- LLM calls: 0, tokens: 0 (prompt 0, completion 0, of which reasoning 0)
- wall time: 8.1s (LLM 0.0s)
- stop reason: no verified gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | resynth:deep(orig) | fail-sim | 37.8 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c02 | resynth:deep_s7(orig) | fail-sim | 38.0 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c03 | resynth:deep_j400(orig) | fail-sim | 37.8 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c04 | resynth:deep_s7_j400(orig) | fail-sim | 38.0 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c05 | resynth:deep_i3(orig) | fail-sim | 37.8 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c06 | resynth:deep_bd(orig) | fail-sim | 37.8 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c07 | resynth:deep_s7_bds(orig) | fail-sim | 37.8 | 4 | [waveform-events] Output `out` has the same settled values but the original also produces  |
| c08 | resynth:dc2x3(orig) | no-gain | 39.4 | 4 | [metrics] area 39.4 / ltp 4 is not better than baseline 39.4 / 4 |
| c09 | resynth:syn2_dch(orig) | no-gain | 40.7 | 4 | [metrics] area 40.7 / ltp 4 is not better than baseline 39.4 / 4 |

## Agent graph trace

setup(0.76s) -> arithmetic(0.01s) -> evaluate_arithmetic(0.0s) -> resynth(4.5s) -> evaluate_resynth(2.79s) -> finalize(0.0s)
