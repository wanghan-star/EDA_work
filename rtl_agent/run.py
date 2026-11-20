#!/usr/bin/env python3
"""rtl_agent command line.

  python3 run.py --rtl design.v [--top TOP] [--out runs/design] [--budget normal]
  python3 run.py --batch cases/public --out runs/public          # every *.v below the folder
  python3 run.py --rtl ../opti_demo/case/case1/rtl.v             # official layout, uses case/tb/case1_tb.v
"""

import argparse
import re
import glob
import hashlib
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
        with open(path, encoding="utf-8", errors="replace") as fh:
            text = fh.read()
    except OSError:
        return True
    text = re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S)
    mods = re.findall(r"\bmodule\s+[A-Za-z_][\w$]*\s*(#\s*\(.*?\)\s*)?([;(])", text, flags=re.S)
    return bool(mods) and all(sep == ";" for _p, sep in mods)


def course_testbenches(rtl, explicit=()):
    """Explicit --tb files, else course-provided stimuli found by the course layouts:

    * opti_demo (2026-11): case/<name>/rtl.v with case/tb/<name>_tb.v
    * earlier releases:    stim_*.v / tb_*.v / *_tb.v next to the design
    """
    if explicit:
        return [os.path.abspath(p) for p in explicit]
    folder = os.path.dirname(os.path.abspath(rtl))
    name = os.path.basename(folder)
    found = [os.path.join(folder, f) for f in os.listdir(folder)
             if f.endswith(".v") and (re.match(r"^(stim|tb)_", f, re.I) or re.search(r"_tb\.v$", f, re.I))
             and os.path.abspath(os.path.join(folder, f)) != os.path.abspath(rtl)]
    for c in (os.path.join(os.path.dirname(folder), "tb", f"{name}_tb.v"),
              os.path.join(os.path.dirname(folder), "tb", f"stim_{name}.v")):
        if os.path.isfile(c):
            found.append(c)
    return sorted(dict.fromkeys(os.path.abspath(f) for f in found))


def default_case_name(rtl):
    """Output folder name: the file stem, or the case folder for generic names (case1/rtl.v -> case1)."""
    stem = os.path.splitext(os.path.basename(rtl))[0]
    if stem.lower() in ("rtl", "design", "top", "dut", "src", "input"):
        return os.path.basename(os.path.dirname(os.path.abspath(rtl))) or stem
    return stem


def run_one(cfg, rtl, outdir, top, budget, keep, resynth="full", allow_mem=False, allow_relaxed=True,
            accept="bounded", tbs=(), arithmetic=True, call_limit=None, course_guard=True):
    b = dict(BUDGETS[budget])
    b["resynth"] = resynth
    b["allow_mem"] = allow_mem
    b["allow_relaxed"] = allow_relaxed
    b["accept"] = accept
    b["arithmetic"] = arithmetic
    b["call_limit"] = call_limit
    b["course_guard"] = course_guard
    st = optimize(cfg, rtl, outdir, top=top, budget=Budget(**b), keep_work=keep,
                  course_tbs=course_testbenches(rtl, tbs))
    u = st.usage.to_dict()
    if st.final:
        b, f = st.base, st.final.synth
        log(f"DONE {st.top}: area {b.area:.2f} -> {f.area:.2f} ({(f.area / b.area - 1) * 100:+.1f}%), "
            f"ltp {b.ltp} -> {f.ltp}; tokens {u['total_tokens']}; {st.elapsed():.0f}s", "run")
    else:
        log(f"DONE {st.top}: no verified improvement ({st.error or st.stop_reason}); "
            f"tokens {u['total_tokens']}; {st.elapsed():.0f}s", "run")
    return st


def batch_cases(folder, out_root):
    """Discover designs once, exclude prior output, and assign unique directory names."""
    folder, out_root = os.path.abspath(folder), os.path.abspath(out_root)
    def in_output(path):
        try:
            return os.path.commonpath([os.path.abspath(path), out_root]) == out_root
        except ValueError:
            return False  # different Windows drives

    files = [f for f in sorted(glob.glob(os.path.join(folder, "**", "*.v"), recursive=True))
             if not in_output(f)
             and not _looks_like_testbench(f)]
    names = []
    for f in files:
        parent = os.path.basename(os.path.dirname(f))
        stem = os.path.splitext(os.path.basename(f))[0]
        siblings = sum(os.path.dirname(g) == os.path.dirname(f) for g in files)
        names.append(parent if siblings == 1 else f"{parent}_{stem}")
    used = set()
    cases = []
    for f, name in zip(files, names):
        if names.count(name) > 1 or name.casefold() in used:
            rel = os.path.relpath(f, folder).replace(os.sep, "/")
            name += "_" + hashlib.sha256(rel.encode("utf-8")).hexdigest()[:12]
        while name.casefold() in used:
            name += "_"
        used.add(name.casefold())
        cases.append((f, name))
    return cases


def failure_result(rtl, outdir, exc):
    """Persist a case failure so a batch can continue and reports remain consumable."""
    message = f"{type(exc).__name__}: {exc}"
    d = {"input": os.path.abspath(rtl), "top": None, "kind": None, "status": "error",
         "error": message, "tier": None, "baseline": {"area": None, "ltp": None},
         "optimized": {"area": None, "ltp": None, "candidate": None},
         "verification": None, "candidates": [], "runtime_s": None,
         "usage": {"total_tokens": None, "calls": None}}
    write_json(os.path.join(outdir, "result.json"), d)
    write_text(os.path.join(outdir, "report.md"), f"# Optimization failed\n\n{message}\n")
    # Remove stale successful output only from this case's output, never the input.
    old_output = os.path.join(outdir, "optimized.v")
    if os.path.isfile(old_output) and os.path.realpath(old_output) != os.path.realpath(rtl):
        os.remove(old_output)
    log(message, "run")
    return message


def main():
    ap = argparse.ArgumentParser(description="LLM + Yosys closed-loop RTL optimizer")
    source = ap.add_mutually_exclusive_group(required=True)
    source.add_argument("--rtl", help="input Verilog file")
    ap.add_argument("--top", default=None, help="top module (auto-detected)")
    source.add_argument("--batch", help="folder: optimize every .v file found below it")
    ap.add_argument("--out", default=None, help="output folder")
    ap.add_argument("--budget", default="normal", choices=sorted(BUDGETS))
    ap.add_argument("--max-calls", type=int, default=None,
                    help="hard per-case logical LLM call cap, including rescue (0 disables requests)")
    ap.add_argument("--env-file", default=None)
    ap.add_argument("--keep-work", action="store_true")
    ap.add_argument("--offline", action="store_true", help="disable LLM requests; arithmetic and ABC remain available")
    ap.add_argument("--no-arithmetic", dest="arithmetic", action="store_false",
                    help="disable deterministic source-level arithmetic candidates (ablation)")
    ap.add_argument("--accept", choices=["bounded", "proved"], default="bounded",
                    help="formal evidence accepted on top of strict simulation: bounded (default: complete "
                         "proof, bounded model check, simulation-only for multi-clock designs) or proved "
                         "(complete proofs only)")
    ap.add_argument("--no-relaxed", dest="allow_relaxed", action="store_false",
                    help="never fall back to candidates that differ only in power-up X / zero-width events")
    ap.add_argument("--allow-relaxed", dest="allow_relaxed", action="store_true",
                    help="(default) use such candidates only when no strict candidate has a gain")
    ap.add_argument("--strict", action="store_true", help="shortcut for --accept proved --no-relaxed")
    ap.add_argument("--tb", action="append", default=[],
                    help="course-style stimulus testbench (__VCD__/__SEED__ placeholders) that every output must "
                         "pass strictly; default: case/tb/<case>_tb.v (opti_demo layout) or stim_*.v / tb_*.v "
                         "next to the design")
    ap.set_defaults(allow_relaxed=True)
    ap.add_argument("--resynth", default=os.environ.get("RTL_AGENT_RESYNTH", "full"),
                    choices=["full", "fallback", "off"],
                    help="zero-token ABC re-synthesis candidates (gate-level output): full = also applied to "
                         "the best LLM design, fallback = only if the LLM found no gain, off = readable RTL only")
    ap.add_argument("--flat-metric-only", dest="course_guard", action="store_false",
                    help="hierarchical designs: judge candidates on the flattened metric only (default also "
                         "rejects candidates that regress the unflattened course-script reading)")
    ap.add_argument("--allow-mem", action="store_true",
                    help="accept candidates that infer extra memories (their logic is not counted by the "
                         "course script; off by default because it is not a real saving)")
    args = ap.parse_args()
    if args.max_calls is not None and args.max_calls < 0:
        ap.error("--max-calls must be nonnegative")
    if args.strict:
        args.accept, args.allow_relaxed = "proved", False

    if args.rtl and not os.path.isfile(args.rtl):
        ap.error(f"input file does not exist: {args.rtl}")
    if args.batch and not os.path.isdir(args.batch):
        ap.error(f"batch folder does not exist: {args.batch}")
    if args.batch and args.top:
        ap.error("--top is only supported with --rtl")
    cases = None
    if args.batch:
        out_root = args.out or os.path.join("runs", time.strftime("batch_%m%d_%H%M%S"))
        cases = batch_cases(args.batch, out_root)
        if not cases:
            ap.error("no design .v files found (testbenches and output folder are excluded)")
    else:
        name = default_case_name(args.rtl)
        out = args.out or os.path.join("runs", name)
        if os.path.realpath(args.rtl) == os.path.realpath(os.path.join(out, "optimized.v")):
            ap.error("output optimized.v would overwrite the input; choose a different --out")
    try:
        cfg = Config(env_file=args.env_file)
    except (OSError, ValueError) as exc:
        ap.error(f"invalid configuration: {exc}")
    if args.offline:
        cfg.llm_key = ""
    missing = cfg.check_tools()
    if missing:
        log("missing tools: " + ", ".join(missing), "run")
        return 2
    log(f"model={cfg.llm_model} base={cfg.llm_base} key={cfg.masked_key()} thinking={cfg.llm_thinking}", "run")

    if args.rtl:
        try:
            st = run_one(cfg, args.rtl, out, args.top, args.budget, args.keep_work, args.resynth,
                         args.allow_mem, args.allow_relaxed, args.accept,
                         args.tb, args.arithmetic, args.max_calls, args.course_guard)
        except (OSError, ValueError, RuntimeError) as exc:
            failure_result(args.rtl, out, exc)
            return 1
        return 0 if (st.final or not st.error) else 1

    if args.batch:
        rows = []
        failed = False
        t0 = time.time()
        for f, name in cases:
            case_out = os.path.join(out_root, name)
            try:
                st = run_one(cfg, f, case_out, None, args.budget, args.keep_work, args.resynth,
                             args.allow_mem, args.allow_relaxed, args.accept,
                         args.tb, args.arithmetic, args.max_calls, args.course_guard)
            except (OSError, ValueError, RuntimeError) as exc:
                failed = True
                error = failure_result(f, case_out, exc)
                rows.append({"case": name, "top": None, "base_area": None, "base_ltp": None,
                             "opt_area": None, "opt_ltp": None, "tokens": None, "calls": None,
                             "seconds": None, "status": "error", "error": error, "evidence": ""})
                continue
            failed |= bool(st.error)
            b = st.base
            fin = st.final.synth if st.final else b
            u = st.usage.to_dict()
            rows.append({"case": name, "top": st.top, "base_area": b.area if b else None,
                         "base_ltp": b.ltp if b else None, "opt_area": fin.area if fin else None,
                         "opt_ltp": fin.ltp if fin else None, "tokens": u["total_tokens"],
                         "calls": u["calls"], "seconds": round(st.elapsed(), 1),
                         "status": "optimized" if st.final else ("error" if st.error else "no-gain"),
                         "error": st.error, "tier": st.final_tier,
                         "evidence": st.final_verify.evidence() if st.final_verify else ""})
        L = ["# Batch summary", "", f"total wall time {time.time() - t0:.0f}s", "",
             "| case | area base | area opt | d_area | ltp base | ltp opt | tokens | calls | time(s) | status |",
             "|---|---:|---:|---:|---:|---:|---:|---:|---:|---|"]
        for r in rows:
            da = (f"{(r['opt_area'] / r['base_area'] - 1) * 100:+.1f}%"
                  if r["base_area"] and r["opt_area"] is not None else "n/a")
            L.append(f"| {r['case']} | {r['base_area']} | {r['opt_area']} | {da} | {r['base_ltp']} | "
                     f"{r['opt_ltp']} | {r['tokens']} | {r['calls']} | {r['seconds']} | {r['status']} |")
        write_text(os.path.join(out_root, "summary.md"), "\n".join(L) + "\n")
        write_json(os.path.join(out_root, "summary.json"), rows)
        print("\n".join(L))
        return 1 if failed else 0
    ap.print_help()
    return 1


if __name__ == "__main__":
    sys.exit(main())
