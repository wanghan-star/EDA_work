# RTL optimization report: `verified_adder_64bit`

- generated: 2026-10-21 20:35:43
- input: `/home/hansome_w/backup/rtl_agent/cases/public/case7_verified_adder_64bit/adder64_v1_pipe.v`
- design: top=verified_adder_64bit, sequential, 7 ports, ~360 FF bits; clocks: clk(posedge); async resets: rst_n(active-low)
- result: **NO-GAIN**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 484.386 | 484.386 | +0.0% |
| logic depth (ltp) | 57 | 57 | +0.0% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Outcome

No verified candidate improved the design; the original RTL is emitted unchanged.

## Cost

- LLM calls: 9, tokens: 37616 (prompt 23159, completion 14457, of which reasoning 0)
- wall time: 152.5s (LLM 89.9s)
- stop reason: no further gain

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | no-gain | 484.4 | 57 | [metrics] area 484.4 / ltp 57 is not better than baseline 484.4 / 57 |
| c02 | init:sequential | no-gain | 484.4 | 57 | [metrics] area 484.4 / ltp 57 is not better than baseline 484.4 / 57 |
| c03 | init:datapath | ltp-worse | 481.5 | 59 | [metrics] the design is functionally correct (verified) and area 481.5 is good, but ltp=59 |
| c04 | repair(c03) | no-gain | 484.4 | 57 | [metrics] area 484.4 / ltp 57 is not better than baseline 484.4 / 57 |
| c05 | init:logic | no-gain | 484.4 | 57 | [metrics] area 484.4 / ltp 57 is not better than baseline 484.4 / 57 |
| c06 | resynth:deep(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c07 | resynth:deep_s7(orig) | ltp-worse | 353.5 | 71 | [metrics] the design is functionally correct (verified) and area 353.5 is good, but ltp=71 |
| c08 | resynth:deep_j400(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c09 | resynth:deep_s7_j400(orig) | ltp-worse | 353.5 | 71 | [metrics] the design is functionally correct (verified) and area 353.5 is good, but ltp=71 |
| c10 | resynth:deep_i3(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c11 | resynth:deep_bd(orig) | ltp-worse | 345.3 | 72 | [metrics] the design is functionally correct (verified) and area 345.3 is good, but ltp=72 |
| c12 | resynth:deep_s7_bds(orig) | ltp-worse | 353.5 | 71 | [metrics] the design is functionally correct (verified) and area 353.5 is good, but ltp=71 |
| c13 | resynth:dc2x3(orig) | no-gain | 524.6 | 57 | [metrics] area 524.6 / ltp 57 is not better than baseline 484.4 / 57 |
| c14 | resynth:syn2_dch(orig) | no-gain | 569.0 | 44 | [metrics] area 569.0 / ltp 44 is not better than baseline 484.4 / 57 |
| c15 | resynth:deep(c03) | ltp-worse | 374.8 | 72 | [metrics] the design is functionally correct (verified) and area 374.8 is good, but ltp=72 |
| c16 | resynth:deep_s7(c03) | ltp-worse | 364.7 | 72 | [metrics] the design is functionally correct (verified) and area 364.7 is good, but ltp=72 |
| c17 | resynth:deep_j400(c03) | ltp-worse | 374.8 | 72 | [metrics] the design is functionally correct (verified) and area 374.8 is good, but ltp=72 |
| c18 | resynth:deep_s7_j400(c03) | ltp-worse | 364.7 | 72 | [metrics] the design is functionally correct (verified) and area 364.7 is good, but ltp=72 |
| c19 | resynth:deep_i3(c03) | ltp-worse | 374.8 | 72 | [metrics] the design is functionally correct (verified) and area 374.8 is good, but ltp=72 |
| c20 | resynth:deep_bd(c03) | ltp-worse | 374.8 | 72 | [metrics] the design is functionally correct (verified) and area 374.8 is good, but ltp=72 |
| c21 | resynth:deep_s7_bds(c03) | ltp-worse | 364.7 | 72 | [metrics] the design is functionally correct (verified) and area 364.7 is good, but ltp=72 |
| c22 | resynth:dc2x3(c03) | no-gain | 524.6 | 57 | [metrics] area 524.6 / ltp 57 is not better than baseline 484.4 / 57 |
| c23 | resynth:syn2_dch(c03) | no-gain | 602.8 | 46 | [metrics] area 602.8 / ltp 46 is not better than baseline 484.4 / 57 |
| c24 | rescue:pipeline | no-gain | 484.4 | 57 | [metrics] area 484.4 / ltp 57 is not better than baseline 484.4 / 57 |
| c25 | rescue:storage | no-gain | 484.4 | 57 | [metrics] area 484.4 / ltp 57 is not better than baseline 484.4 / 57 |
| c26 | repair(c06) | format | - | - | No complete ```verilog block defining module `verified_adder_64bit` was found. |
| c27 | repair(c07) | format | - | - | No complete ```verilog block defining module `verified_adder_64bit` was found. |

## Agent graph trace

setup(0.61s) -> generate(13.78s) -> evaluate(1.7s) -> repair(12.71s) -> evaluate(0.27s) -> refine(9.35s) -> evaluate_refine(0.26s) -> resynth(54.86s) -> evaluate_resynth(40.5s) -> rescue(15.52s) -> evaluate(0.26s) -> repair(2.68s) -> evaluate(0.0s) -> finalize(0.0s)
