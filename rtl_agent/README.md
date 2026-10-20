# rtl_agent：LLM + Yosys 闭环 RTL 自动优化 Agent

输入一份 Verilog RTL，Agent 全自动完成：基线综合评估 → 多策略候选生成（LLM 改写 + ABC 逻辑重综合）→ 等价性验证（形式证明 + 严格波形比对）→ 综合评估 → 迭代修复/精炼 → 输出最终 RTL 与报告。

- 纯 Python 3 标准库实现（无需 pip），在 Linux（含 WSL）下运行
- 评估口径与课程 `opti_demo/run_demo.sh` 完全一致（Nangate45 面积 + `ltp` 逻辑深度）
- LLM 走 OpenAI 兼容接口（DeepSeek 官方 / 阿里云百炼等），逐次记录 token 用量

## 1. 环境

| 依赖 | 说明 |
|---|---|
| yosys（≥0.33，开发用 0.52）、yosys-abc | 综合、评分、形式验证 |
| iverilog + vvp | 4 值仿真等价性检查 |
| Python ≥ 3.8 | 调度（仅标准库） |
| Nangate45 typical liberty | 评分用工艺库，默认路径 `../tech/NangateOpenCellLibrary_typical.lib` |

```bash
sudo apt install -y yosys iverilog python3
cp .env.example .env          # 填写 LLM_API_KEY / LLM_BASE_URL / LLM_MODEL
cp tools.env.example tools.env # 可选：自定义工具与 liberty 路径
python3 tests/test_selfcheck.py   # 验证链自检（必须全部 PASS）
```

## 2. 运行

```bash
# 单个设计
python3 run.py --rtl path/to/design.v [--top TOP] --out runs/design
# 批量：目录下每个 .v 一个用例
python3 run.py --batch cases/public --out runs/public
```

常用参数：

| 参数 | 含义 | 默认 |
|---|---|---|
| `--budget quick/normal/high` | LLM 调用与迭代轮数预算 | normal（≤6 次调用） |
| `--resynth full/fallback/off` | ABC 逻辑重综合候选：full = 原设计与 LLM 最优解都做；fallback = 仅当 LLM 无收益时；off = 只输出 LLM 改写的可读 RTL | full |
| `--allow-mem` | 允许“多推断出存储器”的候选（课程脚本不映射存储器，其逻辑不计面积，并非真实优化） | 关闭 |
| `--keep-work` | 保留临时仿真/形式验证文件 | 关闭 |

## 3. 输出（每个用例一个目录）

| 文件 | 内容 |
|---|---|
| `optimized.v` | 最终 RTL（无改进时原样输出原设计） |
| `report.md` | 面积/ltp 对比、等价性证据、token 与耗时、迭代历史、Agent 状态图轨迹 |
| `result.json` | 机器可读的全部指标 |
| `candidates/` | 每个候选的 RTL 与评估记录 |
| `llm/` | 每次 LLM 调用的完整提示词与回复（含 token 计量） |

批量运行另有 `summary.md` / `summary.json`。

## 4. 工作流程（LangGraph 风格状态图，`agent/graph.py`）

```
setup ──► generate ──► evaluate ──┬─► repair ───► evaluate …
  │                               ├─► refine ───► evaluate_refine …
  │                               └─► resynth ──► evaluate_resynth ──┬─► finalize ──► END
  └─(无 API Key)──► resynth                                          └─► rescue ──► evaluate …（尚无严格档收益时）
```

1. **setup**：解析设计（端口、时钟、复位极性、存储器、X 赋值），按课程脚本评估基线，生成参考波形。
2. **generate**：并行调用 LLM，每个调用使用不同优化策略（保守/数据通路/控制逻辑/时序/最简实现）。
3. **evaluate**：抽取代码 → 规则检查 → 综合评分 → 只验证“有望更优”的候选（省时间）。
4. **repair**：把精确反例（输入、期望值、实际值、周期）回灌 LLM，要求先手推原设计再修复。
5. **refine**：在当前最优已验证设计上继续优化，附带面积构成与 ltp 关键路径。
6. **resynth**：零 token 的 ABC 深度重综合（9 个确定性脚本组成的组合并行运行），输出为门级 Verilog；对原设计、LLM 最优解，以及“已验证正确但 ltp 超标”的候选都会执行。
7. **rescue**：若此时仍没有严格档收益，追加少量 LLM 调用，改用面向结构的策略（流水预计算、存储结构、状态机编码）。
8. **finalize**：用更强的激励与更深的形式验证复核最优候选，输出 RTL 与报告。

## 5. 等价性验证

- **端口检查**：名称、方向、位宽一致。
- **4 值仿真（iverilog）**：自动生成激励（组合电路 ≤16 位输入时穷举；时序电路含复位、复位前上电 X、随机中途复位、多时钟），用与课程 `equiv_agent.py` 完全相同的 VCD 逐事件比对。
- **形式验证（Yosys/ABC）**：组合电路用 miter + ABC `iprove` 完整证明；时序电路用 SAT 时序归纳/有界模型检查（复位约束、上电未定义态）。所有反例都会在 4 值仿真中回放确认。
- **分级验收**：严格通过（strict）优先；只有在没有任何严格候选有收益时，才采用“复位后完全一致、仅上电 X 或零宽事件不同”的候选（relaxed），并在报告中标注。

## 6. 目录

```
agent/        核心模块（config, llm, synth, verify, simcheck, formal, tbgen, vcd, resynth, optimizer, graph, report, prompts）
cases/public  公开用例（本地复刻版，官方用例发布后替换）
cases/extra   额外健壮性用例（多时钟异步 FIFO、状态机）
tests/        验证链自检与开发实验脚本
docs/         方案报告
```
