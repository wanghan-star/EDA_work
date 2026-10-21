# 验收结果快照

本目录保存 2026-10-21 的验收结果。公开用例为课程仓库发布的 8 个官方用例（含官方激励 `stim_*.v`），额外用例用于健壮性测试；隐藏用例成绩以助教评测为准。

同一套系统对每个用例运行了多轮（公开用例：`official`、`official_hi`、`official2`；额外用例：`final2x`、`extra2`），每个用例取各轮中通过全部验证且 J = 0.5·A/A0 + 0.3·D/D0 最小的结果。`result.json` 中 `run` 记录被选中的轮次，`runs_compared` 记录参与比较的轮次。

- 运行配置：WSL Ubuntu、Yosys 0.52、Icarus Verilog 12；LLM 为 `deepseek-v4.1-flash`（关闭思考），`normal` 预算（无收益用例另以 `high` 预算补跑），默认验收策略（`--accept bounded`，宽松兜底开启），重综合 `full`。
- `public/`：8 个官方公开用例；`extra/`：异步 FIFO、交通灯、GCD、demo `opt_top`。
- `table.md`：由各用例 `result.json` 自动生成的完整指标表（与根目录 README 第 1 节相同）。
- `course_check.md`：用课程原版 `equiv_agent.py` + 官方激励与 `run_demo.sh` 评分流程对 `public/` 的输出逐个复核（8/8 PASS）。

每个用例保留 `optimized.v`、`report.md`、`result.json`。完整提示词与临时工作文件保留在本地 `runs/`，不包含在快照中。`no-gain` 表示该预算下没有找到通过终验的正收益候选，此时输出原设计，并不意味着不存在更优实现。

## 证据强度

`result.json` 中的字段：

- `tier`：`strict` 表示全部激励逐事件波形一致；`relaxed` 表示复位后一致，仅上电 X 或零宽事件不同。
- `verification.formal.status`：`proved` 为完整证明；`bounded` 为 30 拍有界模型检查无反例；`skipped` 为多时钟设计，仅有严格仿真。
- `policy`：本次运行采用的验收策略。

导出工具 `tools/export_results.py` 会按 `policy` 重新校验每个优化结果：面积严格下降、ltp 不增加、形式证据在策略允许范围内，不满足即拒绝导出。

## 复现

在 `rtl_agent/` 下运行（Linux 或 WSL，配置 Yosys、yosys-abc、iverilog/vvp 与 `.env`）：

```bash
python3 run.py --batch cases/public --budget normal --out runs/final_public
python3 run.py --batch cases/extra  --budget normal --out runs/final_extra
python3 tools/export_results.py runs/final_public results/public   # 目标目录需为空
python3 docs/report/make_results.py results/public results/extra --md --output results/table.md
```

LLM 输出具有随机性，单次运行的收益可能不同；ABC 重综合按迭代数截断，同版本工具下可复现。若需只接受完整证明，加 `--strict`。
