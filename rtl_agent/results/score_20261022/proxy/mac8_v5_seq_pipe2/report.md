# RTL optimization report: `TopModule`

- generated: 2026-10-22 15:36:26
- input: `/home/hansome_w/backup/rtl_agent/cases/proxy/mac8_v5_seq_pipe2/mac8_v5_seq_pipe2.v`
- design: top=TopModule, sequential, 21 ports, ~39 FF bits; clocks: clk(posedge); async resets: rst(active-high)
- result: **OPTIMIZED**, verification tier: **strict**
- acceptance policy: formal `--accept bounded`, relaxed fallback on

## Metrics (Yosys + ABC, Nangate45, course scoring script)

| metric | baseline | optimized | change |
|---|---:|---:|---:|
| area (um^2) | 3869.502 | 1208.704 | -68.8% |
| logic depth (ltp) | 161 | 106 | -34.2% |

Area counts combinational standard cells; flip-flops have no liberty area in the scoring script. ltp counts cells on the longest topological path (flip-flops included).

## Equivalence evidence

- sim: 15000 vectors/cycles strict-VCD PASS; course stimuli PASS: stim_mac8.v; formal: bounded PASS, 4 cycles
- checks: port/width identity, 4-state iverilog co-simulation with course-identical VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof (combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).

## What changed (agent plan)

- Keep the 4-cycle FSM and register set; only rewrite the datapath arithmetic.
- Compute one shared 8x8 multiply per pair using a single muxed product, then one shared 18-bit adder for acc+prod, instead of two parallel mults plus two adders per cycle.
- Since each cycle adds exactly two products, compute their sum with one 16-bit adder then one 18-bit add: acc + (prod_a + prod_b).
- Use a 4:1 mux on x and c selected by i to feed two multipliers, avoiding four separate multiply circuits; keep y write identical.
- Preserve reset/start/done/i/acc semantics and X behaviour exactly.

## Cost

- LLM calls: 3, tokens: 7353 (prompt 4866, completion 2487, of which reasoning 0)
- wall time: 757.6s (LLM 26.6s)
- stop reason: budget exhausted

## Iterations

| id | origin | status | area | ltp | note |
|---|---|---|---:|---:|---|
| c01 | init:conservative | verified | 3277.1 | 149 |  |
| c02 | init:storage | no-gain | 3940.3 | 168 | [metrics] area 3940.3 / ltp 168 is not better than baseline 3869.5 / 161 |
| c03 **(final)** | init:datapath | verified | 1208.7 | 106 |  |
| c04 | resynth:deep(orig) | not-better | 3604.8 | 164 | [metrics] area 3604.8 is good but ltp=164 exceeds the baseline ltp=161. Your longest path  |
| c05 | resynth:deep_s7(orig) | not-better | 3683.0 | 169 | [metrics] area 3683.0 is good but ltp=169 exceeds the baseline ltp=161. Your longest path  |
| c06 | resynth:deep_j400(orig) | not-better | 3604.8 | 164 | [metrics] area 3604.8 is good but ltp=164 exceeds the baseline ltp=161. Your longest path  |
| c07 | resynth:deep_s7_j400(orig) | not-better | 3683.0 | 169 | [metrics] area 3683.0 is good but ltp=169 exceeds the baseline ltp=161. Your longest path  |
| c08 | resynth:deep_i3(orig) | not-better | 3659.1 | 165 | [metrics] area 3659.1 is good but ltp=165 exceeds the baseline ltp=161. Your longest path  |
| c09 | resynth:deep_bd(orig) | no-gain | 5137.3 | 186 | [metrics] area 5137.3 / ltp 186 is not better than baseline 3869.5 / 161 |
| c10 | resynth:deep_s7_bds(orig) | not-better | 3703.5 | 168 | [metrics] area 3703.5 is good but ltp=168 exceeds the baseline ltp=161. Your longest path  |
| c11 | resynth:dc2x3(orig) | no-gain | 3945.6 | 158 | [metrics] area 3945.6 / ltp 158 is not better than baseline 3869.5 / 161 |
| c12 | resynth:syn2_dch(orig) | no-gain | 4547.5 | 175 | [metrics] area 4547.5 / ltp 175 is not better than baseline 3869.5 / 161 |
| c13 | resynth:deep(c03) | relaxed | 1048.6 | 109 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c14 | resynth:deep_s7(c03) | relaxed | 1031.0 | 103 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c15 | resynth:deep_j400(c03) | duplicate | 1048.6 | 109 | same area/ltp/cell mix as a candidate already verified |
| c16 | resynth:deep_s7_j400(c03) | duplicate | 1031.0 | 103 | same area/ltp/cell mix as a candidate already verified |
| c17 | resynth:deep_i3(c03) | not-better | 1096.5 | 114 |  |
| c18 | resynth:deep_bd(c03) | not-better | 1529.5 | 104 |  |
| c19 | resynth:deep_s7_bds(c03) | relaxed | 1030.5 | 100 | [simulation mismatch at cycle 0 (t=5000ps, no_reset_first)] output `done`: expected 0, got |
| c20 | resynth:dc2x3(c03) | not-better | 1188.0 | 109 |  |
| c21 | resynth:syn2_dch(c03) | not-better | 1248.1 | 106 |  |

## Agent graph trace

setup(1.13s) -> arithmetic(0.0s) -> evaluate_arithmetic(0.0s) -> generate(10.32s) -> evaluate(94.37s) -> resynth(226.67s) -> evaluate_resynth(179.54s) -> finalize(0.0s)
