#!/usr/bin/env python3
"""rtl_agent command line.

  python3 run.py --rtl design.v [--top TOP] [--out runs/design] [--budget normal]
  python3 run.py --batch cases/public --out runs/public          # every *.v below the folder
"""

import argparse
import glob
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from agent.config import Config                      # noqa: E402
from agent.optimizer import Budget, optimize         # noqa: E402
from agent.util import log, write_text, write_json   # noqa: E402

BUDGETS = {
    # LLM calls are cheap individually but tokens/runtime are ranked too: the zero-token ABC
    # re-synthesis does most of the heavy lifting, the LLM explores algorithmic rewrites.
    "quick":  dict(max_calls=3,  max_refine=0, max_repair=1, time_limit=600,  n_init=2, rescue_calls=0),
    "normal": dict(max_calls=6,  max_refine=1, max_repair=1, time_limit=900,  n_init=2, rescue_calls=4),
    "high":   dict(max_calls=14, max_refine=3, max_repair=2, time_limit=2400, n_init=3, patience=2,
                   rescue_calls=6),
}


def _looks_like_testbench(path):
    """Skip stimulus/testbench files that sit next to designs (tb_*.v, stim_*.v, port-less modules)."""
    import re
    base = os.path.basename(path).lower()
    if re.match(r"^(tb|stim|test|testbench)[_.]", base) or re.search(r"_(tb|test|testbench)\.v$", base):
        return True
    try:
        text = open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        return True
    text = re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S)
    mods = re.findall(r"\bmodule\s+[A-Za-z_][\w$]*\s*(#\s*\(.*?\)\s*)?([;(])", text, flags=re.S)
    return bool(mods) and all(sep == ";" for _p, sep in mods)


def run_one(cfg, rtl, outdir, top, budget, keep, resynth="full", allow_mem=False):
    b = dict(BUDGETS[budget])
    b["resynth"] = resynth
    b["allow_mem"] = allow_mem
    st = optimize(cfg, rtl, outdir, top=top, budget=Budget(**b), keep_work=keep)
    u = st.usage.to_dict()
    if st.final:
        b, f = st.base, st.final.synth
        log(f"DONE {st.top}: area {b.area:.2f} -> {f.area:.2f} ({(f.area / b.area - 1) * 100:+.1f}%), "
            f"ltp {b.ltp} -> {f.ltp}; tokens {u['total_tokens']}; {st.elapsed():.0f}s", "run")
    else:
        log(f"DONE {st.top}: no verified improvement ({st.error or st.stop_reason}); "
            f"tokens {u['total_tokens']}; {st.elapsed():.0f}s", "run")
    return st


def main():
    ap = argparse.ArgumentParser(description="LLM + Yosys closed-loop RTL optimizer")
    ap.add_argument("--rtl", help="input Verilog file")
    ap.add_argument("--top", default=None, help="top module (auto-detected)")
    ap.add_argument("--batch", help="folder: optimize every .v file found below it")
    ap.add_argument("--out", default=None, help="output folder")
    ap.add_argument("--budget", default="normal", choices=sorted(BUDGETS))
    ap.add_argument("--env-file", default=None)
    ap.add_argument("--keep-work", action="store_true")
    ap.add_argument("--resynth", default=os.environ.get("RTL_AGENT_RESYNTH", "full"),
                    choices=["full", "fallback", "off"],
                    help="zero-token ABC re-synthesis candidates (gate-level output): full = also applied to "
                         "the best LLM design, fallback = only if the LLM found no gain, off = readable RTL only")
    ap.add_argument("--allow-mem", action="store_true",
                    help="accept candidates that infer extra memories (their logic is not counted by the "
                         "course script; off by default because it is not a real saving)")
    args = ap.parse_args()

    cfg = Config(env_file=args.env_file)
    missing = cfg.check_tools()
    if missing:
        log("missing tools: " + ", ".join(missing), "run")
        return 2
    log(f"model={cfg.llm_model} base={cfg.llm_base} key={cfg.masked_key()} thinking={cfg.llm_thinking}", "run")

    if args.rtl:
        name = os.path.splitext(os.path.basename(args.rtl))[0]
        out = args.out or os.path.join("runs", name)
        st = run_one(cfg, args.rtl, out, args.top, args.budget, args.keep_work, args.resynth, args.allow_mem)
        return 0 if (st.final or not st.error) else 1

    if args.batch:
        files = [f for f in sorted(glob.glob(os.path.join(args.batch, "**", "*.v"), recursive=True))
                 if not _looks_like_testbench(f)]
        out_root = args.out or os.path.join("runs", time.strftime("batch_%m%d_%H%M"))
        rows = []
        t0 = time.time()
        for f in files:
            folder = os.path.basename(os.path.dirname(f))
            stem = os.path.splitext(os.path.basename(f))[0]
            siblings = [g for g in files if os.path.dirname(g) == os.path.dirname(f)]
            name = folder if (folder and len(siblings) == 1) else (f"{folder}_{stem}" if folder else stem)
            st = run_one(cfg, f, os.path.join(out_root, name), None, args.budget, args.keep_work, args.resynth,
                         args.allow_mem)
            b = st.base
            fin = st.final.synth if st.final else b
            u = st.usage.to_dict()
            rows.append({"case": name, "top": st.top, "base_area": b.area if b else None,
                         "base_ltp": b.ltp if b else None, "opt_area": fin.area if fin else None,
                         "opt_ltp": fin.ltp if fin else None, "tokens": u["total_tokens"],
                         "calls": u["calls"], "seconds": round(st.elapsed(), 1),
                         "status": "optimized" if st.final else (st.error or "no-gain"),
                         "evidence": st.final_verify.evidence() if st.final_verify else ""})
        L = ["# Batch summary", "", f"total wall time {time.time() - t0:.0f}s", "",
             "| case | area base | area opt | d_area | ltp base | ltp opt | tokens | calls | time(s) | status |",
             "|---|---:|---:|---:|---:|---:|---:|---:|---:|---|"]
        for r in rows:
            da = (f"{(r['opt_area'] / r['base_area'] - 1) * 100:+.1f}%" if r["base_area"] else "n/a")
            L.append(f"| {r['case']} | {r['base_area']} | {r['opt_area']} | {da} | {r['base_ltp']} | "
                     f"{r['opt_ltp']} | {r['tokens']} | {r['calls']} | {r['seconds']} | {r['status']} |")
        write_text(os.path.join(out_root, "summary.md"), "\n".join(L) + "\n")
        write_json(os.path.join(out_root, "summary.json"), rows)
        print("\n".join(L))
        return 0
    ap.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
