#!/usr/bin/env python3
"""Generate the LaTeX results table of the report from run folders.

usage: python3 make_results.py runs/batch4 [runs/batch4x ...] > results.tex
"""
import glob
import argparse
import contextlib
import io
import json
import os
import re
import sys

TIER = {"strict": "严格", "relaxed": "宽松", None: "--"}


def number(value, decimals=1):
    return f"{value:.{decimals}f}" if isinstance(value, (int, float)) else "--"


def latex_escape(text):
    escapes = {"\\": r"\textbackslash{}", "_": r"\_", "&": r"\&", "%": r"\%",
               "#": r"\#", "$": r"\$", "{": r"\{", "}": r"\}", "~": r"\textasciitilde{}",
               "^": r"\textasciicircum{}"}
    return "".join(escapes.get(c, c) for c in str(text))


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
        with open(rj, encoding="utf-8") as fh:
            d = json.load(fh)
        case = os.path.basename(os.path.dirname(rj))
        b, o = d["baseline"], d["optimized"]
        win = next((c for c in d["candidates"] if c["id"] == o.get("candidate")), None)
        u = d["usage"]
        out.append({
            "case": case, "kind": {"sequential": "时序", "combinational": "组合"}.get(d.get("kind"), "--"),
            "ba": b["area"], "oa": o["area"], "bl": b["ltp"], "ol": o["ltp"],
            "tok": u["total_tokens"], "sec": d["runtime_s"], "tier": TIER.get(d.get("tier")),
            "src": origin_label(win["origin"]) if win else "--", "status": d["status"]})
    return out


def pct(b, o):
    return f"{(o - b) / b * 100:+.1f}\\%" if b and o is not None else "--"


def main_md(folders):
    """Markdown version of the table (for README.md)."""
    print("| 用例 | 类型 | 基线面积 | 优化面积 | Δ面积 | 基线 ltp | 优化 ltp | Δltp | token | 耗时(s) | 档位 | 胜出来源 |")
    print("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|---|")
    for folder in folders:
        for r in rows(folder):
            gain = r["status"] == "optimized"
            p = lambda b, o: f"{(o - b) / b * 100:+.1f}%" if (gain and b and o is not None) else "—"
            name = r["case"].replace("|", r"\|")
            outcome = "运行失败，见 result.json" if r["status"] == "error" else "无正收益，输出原设计"
            print(f"| {name} | {r['kind']} | {number(r['ba'])} | {number(r['oa'])} | **{p(r['ba'], r['oa'])}** | "
                  f"{number(r['bl'], 0)} | {number(r['ol'], 0)} | {p(r['bl'], r['ol'])} | "
                  f"{number(r['tok'], 0)} | {number(r['sec'], 0)} | "
                  f"{r['tier'] if gain else '—'} | {r['src'] if gain else outcome} |")


def main_tex(folders):
    print(r"\begin{table}[h]\centering\small")
    print(r"\caption{实验结果（Yosys 0.52 + ABC，Nangate45，展平评估；$A$ 为面积、$D$ 为 ltp，0/1 分别表示基线/输出；``--'' 为无经验证的正收益，输出原设计）}")
    print(r"\setlength{\tabcolsep}{3pt}")
    print(r"\resizebox{\linewidth}{!}{%")
    print(r"\begin{tabular}{@{}l c r r r r r r r r l l@{}}")
    print(r"\toprule")
    print(r"用例 & 类型 & $A_0$ & $A_1$ & $\Delta A$ & $D_0$ & $D_1$ & $\Delta D$ & token & 秒 & 档位 & 来源 \\")
    print(r"\midrule")
    for k, folder in enumerate(folders):
        if k:
            print(r"\midrule")
        for r in rows(folder):
            gain = r["status"] == "optimized"
            short = re.match(r"case\d+(?=_|$)", r["case"])
            name = short.group() if short else r["case"]
            print(f"{latex_escape(name)} & {r['kind']} & {number(r['ba'])} & {number(r['oa'])} & "
                  f"{pct(r['ba'], r['oa']) if gain else '--'} & {number(r['bl'], 0)} & {number(r['ol'], 0)} & "
                  f"{pct(r['bl'], r['ol']) if gain else '--'} & {number(r['tok'], 0)} & {number(r['sec'], 0)} & "
                  f"{r['tier'] if gain else '--'} & {latex_escape(r['src']) if gain else ('运行失败' if r['status'] == 'error' else '--')} \\\\")
    print(r"\bottomrule")
    print(r"\end{tabular}")
    print("}")
    print(r"\end{table}")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("folders", nargs="+", help="folders containing case/result.json")
    ap.add_argument("--md", action="store_true", help="emit Markdown instead of LaTeX")
    ap.add_argument("--output", help="write UTF-8 directly (avoids shell encoding differences)")
    args = ap.parse_args()
    for folder in args.folders:
        if not rows(folder):
            ap.error(f"no case result.json found in {folder}")
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        (main_md if args.md else main_tex)(args.folders)
    if args.output:
        with open(args.output, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(buf.getvalue())
    else:
        print(buf.getvalue(), end="")


if __name__ == "__main__":
    main()
