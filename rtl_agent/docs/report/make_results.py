#!/usr/bin/env python3
"""Generate the LaTeX results table of the report from run folders.

usage: python3 make_results.py runs/batch4 [runs/batch4x ...] > results.tex
"""
import glob
import json
import os
import sys

TIER = {"strict": "严格", "relaxed": "宽松", None: "--"}


def origin_label(o):
    if not o:
        return "--"
    if o.startswith("resynth:"):
        src = o.split("(", 1)[1].rstrip(")") if "(" in o else "orig"
        return "重综合" + ("（原设计）" if src == "orig" else "（LLM 解）")
    if o.startswith("init:") or o.startswith("rescue:"):
        return "LLM"
    if o.startswith("repair") or o.startswith("refine"):
        return "LLM（迭代）"
    return o


def rows(folder):
    out = []
    for rj in sorted(glob.glob(os.path.join(folder, "*", "result.json"))):
        d = json.load(open(rj, encoding="utf-8"))
        case = os.path.basename(os.path.dirname(rj))
        b, o = d["baseline"], d["optimized"]
        win = next((c for c in d["candidates"] if c["id"] == o.get("candidate")), None)
        u = d["usage"]
        out.append({
            "case": case.replace("_", r"\_"), "kind": "时序" if d.get("kind") == "sequential" else "组合",
            "ba": b["area"], "oa": o["area"], "bl": b["ltp"], "ol": o["ltp"],
            "tok": u["total_tokens"], "sec": d["runtime_s"], "tier": TIER.get(d.get("tier")),
            "src": origin_label(win["origin"]) if win else "--", "status": d["status"]})
    return out


def pct(b, o):
    return f"{(o - b) / b * 100:+.1f}\\%" if b else "--"


def main():
    print(r"\begin{table}[h]\centering\small")
    print(r"\caption{实验结果（Yosys 0.52 + ABC，Nangate45，课程评分脚本，展平评估；``--'' 表示未找到经验证的正收益，输出原设计）}")
    print(r"\setlength{\tabcolsep}{4pt}")
    print(r"\begin{tabular}{@{}l c r r r r r r r r l l@{}}")
    print(r"\toprule")
    print(r"用例 & 类型 & 基线面积 & 优化面积 & $\Delta$面积 & 基线 ltp & 优化 ltp & $\Delta$ltp & token & 耗时/s & 档位 & 来源 \\")
    print(r"\midrule")
    for k, folder in enumerate(sys.argv[1:]):
        if k:
            print(r"\midrule")
        for r in rows(folder):
            gain = r["status"] == "optimized"
            print(f"{r['case']} & {r['kind']} & {r['ba']:.1f} & {r['oa']:.1f} & "
                  f"{pct(r['ba'], r['oa']) if gain else '--'} & {r['bl']} & {r['ol']} & "
                  f"{pct(r['bl'], r['ol']) if gain else '--'} & {r['tok']} & {r['sec']:.0f} & "
                  f"{r['tier'] if gain else '--'} & {r['src'] if gain else '--'} \\\\")
    print(r"\bottomrule")
    print(r"\end{tabular}")
    print(r"\end{table}")


if __name__ == "__main__":
    main()
