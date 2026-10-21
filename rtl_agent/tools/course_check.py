#!/usr/bin/env python3
"""Independent cross-check with the course's own tools (opti_demo).

For every case: run opti_demo/equiv_agent.py with the provided stimulus (--tb-file stim_*.v) on
original vs optimized RTL, and score both with the literal run_demo.sh synthesis command.

python3 tools/course_check.py --cases cases/public --results results/public --demo ../opti_demo
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)
from agent.config import Config  # noqa: E402


def demo_score(cfg, rtl, top):
    """Exactly run_demo.sh:gen_ys + extract_area/extract_depth (no flatten, last matching line)."""
    lib = cfg.lib_file
    script = (f"read_verilog -sv {rtl}; read_liberty -lib {lib}; hierarchy -top {top}; proc; opt; techmap; "
              f"opt; abc -liberty {lib}; stat -liberty {lib}; ltp")
    out = subprocess.run([cfg.yosys, "-p", script], capture_output=True, text=True, errors="replace").stdout
    area = re.findall(r"Chip area for module '[^']*': ([0-9.]+)", out)
    depth = re.findall(r"\(length=([0-9]+)\)", out)
    return (float(area[-1]) if area else None), (int(depth[-1]) if depth else None)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cases", required=True)
    ap.add_argument("--results", required=True)
    ap.add_argument("--demo", required=True, help="path to the opti_demo checkout")
    ap.add_argument("--output", help="write the Markdown table here")
    args = ap.parse_args()
    cfg = Config()
    env = dict(os.environ, YOSYS_BIN=cfg.yosys, IVERILOG_BIN=cfg.iverilog, VVP_BIN=cfg.vvp)
    demo = os.path.abspath(args.demo)
    rows = ["| 用例 | 课程检查器（官方激励） | 面积 基线→优化（run_demo.sh 字面口径） | ltp 基线→优化 |",
            "|---|---|---|---|"]
    failures = 0
    for res in sorted(glob.glob(os.path.join(args.results, "*", "result.json"))):
        case = os.path.basename(os.path.dirname(res))
        d = json.load(open(res, encoding="utf-8"))
        cdir = os.path.join(args.cases, case)
        gold = [f for f in glob.glob(os.path.join(cdir, "*.v")) if not os.path.basename(f).startswith(("stim_", "tb_"))]
        stim = glob.glob(os.path.join(cdir, "stim_*.v"))
        opt = os.path.join(os.path.dirname(res), "optimized.v")
        top = d.get("top")
        if not (gold and stim and os.path.isfile(opt) and top):
            rows.append(f"| {case} | 跳过（缺少原设计/激励/输出） | | |")
            continue
        with tempfile.TemporaryDirectory(prefix="course_") as td:
            p = subprocess.run([sys.executable, os.path.join(demo, "equiv_agent.py"), "--gold", os.path.abspath(gold[0]),
                                "--opt", os.path.abspath(opt), "--top", top, "--outdir", td,
                                "--tb-file", os.path.abspath(stim[0])],
                               cwd=demo, env=env, capture_output=True, text=True, errors="replace")
        verdict = {0: "PASS", 2: "FAIL"}.get(p.returncode, f"ERROR({p.returncode})")
        failures += verdict != "PASS"
        ba, bl = demo_score(cfg, os.path.abspath(gold[0]), top)
        oa, ol = demo_score(cfg, os.path.abspath(opt), top)
        same = " （原样输出）" if d.get("status") != "optimized" else ""
        rows.append(f"| {case} | **{verdict}**{same} | {ba} → {oa} | {bl} → {ol} |")
        print(rows[-1], flush=True)
    text = "\n".join(rows) + "\n"
    if args.output:
        with open(args.output, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(text)
    print(text)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
