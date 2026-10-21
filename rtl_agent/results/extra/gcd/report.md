# RTL optimization report: `TopModule`

- generated: 2026-10-21 10:18:34
- input: `/home/hansome_w/backup/rtl_agent/cases/extra/gcd/gcd_v1.v`
- design: top=TopModule, combinational, 7 ports, ~0 FF bits
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 1715.168 | 629.090 | -63.3% |
| logic depth (ltp) | 252 | 53 | -79.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 20022 vectors/cycles strict-VCD PASS; formal: PROVED (ABC iprove: miter output is constant 0)
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

ABC logic re-synthesis (deep_s7_bds) of c04

## Cost

- LLM calls: 4, tokens: 9291 (prompt 6469, completion 2822, of which reasoning 0)
- wall time: 649.9s (LLM 25.4s)
- stop reason: no further gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | no-gain | 1715.2 | 252 | [metrics] area 1715.2 / ltp 252 is not better than baseline 1715.2 / 252 |
| c02 | init:datapath | no-gain | 1870.0 | 122 | [metrics] area 1870.0 / ltp 122 is not better than baseline 1715.2 / 252 |
| c03 | init:logic | synth-error | - | - | [yosys] /home/hansome_w/runs/final2x/gcd/candidates/c03.v:28: ERROR: Left hand side of 1st |
| c04 | repair(c03) | verified | 1090.6 | 61 |  |
| c05 | resynth:deep(orig) | not-better | 1500.2 | 245 |  |
| c06 | resynth:deep_s7(orig) | not-better | 1454.2 | 237 |  |
| c07 | resynth:deep_j400(orig) | not-better | 1461.1 | 239 |  |
| c08 | resynth:deep_s7_j400(orig) | not-better | 1449.7 | 240 |  |
| c09 | resynth:deep_i3(orig) | not-better | 1428.7 | 239 |  |
| c10 | resynth:deep_bd(orig) | not-better | 1475.0 | 245 |  |
| c11 | resynth:deep_s7_bds(orig) | not-better | 1451.0 | 240 |  |
| c12 | resynth:dc2x3(orig) | no-gain | 1761.7 | 241 | [metrics] area 1761.7 / ltp 241 is not better than baseline 1715.2 / 252 |
| c13 | resynth:syn2_dch(orig) | no-gain | 1995.3 | 246 | [metrics] area 1995.3 / ltp 246 is not better than baseline 1715.2 / 252 |
| c14 | resynth:deep(c04) | verified | 705.7 | 47 |  |
| c15 | resynth:deep_s7(c04) | verified | 711.0 | 54 |  |
| c16 | resynth:deep_j400(c04) | verified | 702.0 | 48 |  |
| c17 | resynth:deep_s7_j400(c04) | verified | 650.9 | 54 |  |
| c18 | resynth:deep_i3(c04) | verified | 673.0 | 50 |  |
| c19 | resynth:deep_bd(c04) | verified | 708.9 | 50 |  |
| c20 **(final)** | resynth:deep_s7_bds(c04) | verified | 629.1 | 53 |  |
| c21 | resynth:dc2x3(c04) | not-better | 1245.7 | 99 |  |
| c22 | resynth:syn2_dch(c04) | not-better | 1267.5 | 75 |  |

## Agent graph trace

setup(5.95s) -> generate(6.24s) -> evaluate(4.92s) -> refine(8.89s) -> evaluate_refine(0.02s) -> repair(5.11s) -> evaluate(179.57s) -> resynth(207.98s) -> evaluate_resynth(165.37s) -> finalize(0.0s)
