# EDA_work：基于大模型与 Yosys 闭环的 RTL 自动优化 Agent

课程大作业：搭建一个 Agent 系统，对输入 RTL 全自动优化，在保证等价与延时不恶化的前提下尽可能减小综合面积。

| 目录 | 内容 |
|---|---|
| [`rtl_agent/`](rtl_agent/) | Agent 系统本体（纯 Python 标准库），使用说明见 [`rtl_agent/README.md`](rtl_agent/README.md) |
| [`rtl_agent/docs/report/`](rtl_agent/docs/report/) | 方案报告（LaTeX 源文件与 PDF） |
| [`tech/`](tech/) | 评分用标准单元库 Nangate45 typical（来源：OpenROAD-flow-scripts） |

## 快速开始（Linux / WSL）

```bash
sudo apt install -y yosys iverilog python3
cd rtl_agent
cp .env.example .env            # 填写 LLM_BASE_URL / LLM_API_KEY / LLM_MODEL
python3 tests/test_selfcheck.py # 验证链自检，应全部 PASS
python3 run.py --rtl path/to/design.v --out runs/design
python3 run.py --batch cases/public --out runs/public
```

评估口径与课程 demo（<https://github.com/alex00153/opti_demo>）的 `run_demo.sh` 一致：Yosys + ABC 映射到 Nangate45，面积取 `stat -liberty`，延时取 `ltp`。
