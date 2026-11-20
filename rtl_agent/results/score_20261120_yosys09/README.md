# 2026-11-20：课程仓库新布局与 Ubuntu 22.04 旧工具链兼容

本快照**不替换**交付结果（公开用例交付仍为 [`score_20261021/public`](../score_20261021/README.md)，在 Yosys 0.52 上选出并经课程检查器复核）。它记录两项工程改动，以及在课程 README 推荐的 `apt` 工具链上的零 token 实测。

## 1. 课程仓库更新（opti_demo `f6380d5`，2026-11-20）

- 用例改为 `case/caseN/rtl.v`，官方激励改为 `case/tb/caseN_tb.v`；旧的 `case/bench/*`（mac8、mult8 等）被移除。8 个 RTL 与原版相比只差文件末尾换行。
- `cases/public/` 已改成与课程仓库**逐字节一致**的布局。
- `run.py` 自动按新布局查找激励（`<用例目录>/../tb/<用例名>_tb.v`），`rtl.v` 这类通用文件名的输出目录使用用例目录名；`tools/course_check.py` 支持新布局，并把旧快照目录名（`case1_barrel_shifter`）对应到 `case1`。
- 隐藏用例按同样布局放入 `case/` 即可批量运行：`python3 run.py --batch ../opti_demo/case --out runs/course`。

## 2. Ubuntu 22.04 `apt` 工具链（Yosys 0.9 + berkeley-abc 2021 + Icarus 11）

修复前，零 token 重综合在这套工具链上**全部静默失败**（8 个用例 0 个候选）：

| 问题 | 修复 |
|---|---|
| `berkeley-abc` 无 abc.rc，`&deepsyn` 调用的 `compress2rs`/`b`/`rs` 别名不存在，ABC 段错误 | 探测 ABC，缺失时在脚本前注入标准 abc.rc 别名 |
| Yosys 0.9 的 `abc -g -script` 把结果读回为 `$lut`（`4'h8 >> {a,b}`） | 旧版 Yosys 在脚本末尾追加 `map` |
| Yosys 0.9 的 JSON 不导出 `parameter_default_values`，参数化设计的网表全部被拒 | 用 iverilog 展开顶层求默认参数值（与 Yosys 格式一致），失败仍拒绝 |
| 0.9 网表中被驱动的输出端口没有 `wire` 声明，改写为 `always @*` 后不是合法左值 | 补 `reg` 声明 |
| 单个 `always @*` 块在 0 时刻不求值，输入不变时输出为 X | 仅仿真可见的 0 时刻触发（`` `ifndef SYNTHESIS ``，Yosys 默认定义该宏，综合结果不变） |

修复后 `--offline` 批量实测（`public/`，0 token，总耗时 1702 s）：

| 用例 | 基线 面积/ltp | 优化 面积/ltp | Δ面积 | 档位 | 形式证据 | 胜出候选 |
|---|---|---|---:|---|---|---|
| case5 verified_accu | 84.588 / 62 | 77.938 / 48 | **-7.9%** | 宽松 | proved | `deep`(原设计) |
| case7 adder_64bit | 614.726 / 66 | 556.738 / 54 | **-9.4%** | 严格 | proved | 算术候选 + `syn2_dch` |
| case8 radix2_div | 249.508 / 85 | 230.090 / 68 | **-7.8%** | 严格 | bounded | `deep_s7`(原设计) |
| case1/2/3/6 | — | — | — | — | — | 无合格收益，输出原设计 |
| case4 div_16bit | — | — | — | — | — | Yosys 0.9 无法解析 SV 宽度转换 `16'(...)` |

独立复核（课程原版 `equiv_agent.py` + `case/tb/caseN_tb.v`，课程原版综合命令）：7 个可解析用例全部 PASS，见 [`course_check.md`](course_check.md)。

## 3. 结论

- **评分数值依赖 Yosys 版本**。同一份交付文件在 0.9 下重新打分：case3/7 仍有收益，case5/6/8 反而变差（如 case8 ltp 85→100）。case4 在 0.9 下连原设计都无法综合，说明课程评测必须使用较新的 Yosys。
- 因此 Agent 必须在**评测方自己的工具链**上评估与择优；本次修复保证了它在新旧两代工具链上都能正常工作并找到经验证的收益，而不是静默退化为“原样输出”。
- 尝试过用 YoWASP（WebAssembly 版 Yosys 0.52/0.71）在本机复现新版口径，但其 `abc` 需要派生 `yosys-abc` 子进程，WASM 下无法运行，故未采用。
