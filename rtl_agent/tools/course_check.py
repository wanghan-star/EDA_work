#!/usr/bin/env python3
"""Independent, fail-closed course-checker audit of a complete result snapshot."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from agent.config import Config
from agent.synth import _q
from agent.util import run_cmd, write_json, write_text


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def demo_score(cfg, rtl, top):
    """run_demo.sh's exact pass order and last-match metric extraction."""
    lib = _q(cfg.lib_file)
    script = (f"read_verilog -sv {_q(str(rtl))}; read_liberty -lib {lib}; hierarchy -top {top}; "
              f"proc; opt; techmap; opt; abc -liberty {lib}; stat -liberty {lib}; ltp")
    rc, out, err, _ = run_cmd([cfg.yosys, "-p", script], timeout=180)
    area = re.findall(r"Chip area for module '[^']*': ([0-9.]+)", out)
    depth = re.findall(r"\(length=([0-9]+)\)", out)
    if rc or not area or not depth:
        raise ValueError(f"course synthesis failed (exit={rc}): {(err or out)[-400:]}")
    return float(area[-1]), int(depth[-1])


def audit(cfg, cases, results, demo):
    cases, results, demo = (Path(p).resolve() for p in (cases, results, demo))
    env = dict(os.environ, YOSYS_BIN=cfg.yosys, IVERILOG_BIN=cfg.iverilog, VVP_BIN=cfg.vvp)
    # opti_demo layout: <cases>/<name>/rtl.v + <cases>/tb/<name>_tb.v (older: stim_*.v beside the RTL)
    expected = {p.name for p in cases.iterdir() if p.is_dir() and p.name != "tb" and list(p.glob("*.v"))}
    # result folders may carry the pre-2026-11 descriptive names (case1_barrel_shifter -> case1)
    rdirs = {}
    for p in results.glob("*/result.json"):
        name = p.parent.name
        match = [c for c in expected if name == c or name.startswith(c + "_")]
        rdirs[max(match, key=len) if match else name] = p.parent
    actual = set(rdirs)
    names = sorted(expected | actual)
    records = []
    if not names:
        raise ValueError("no cases/results to audit")
    checker = demo / "equiv_agent.py"
    if not checker.is_file():
        raise ValueError(f"missing course checker: {checker}")
    for case in names:
        row = {"case": case, "verdict": "ERROR", "stimuli": []}
        try:
            if case not in expected:
                raise ValueError("result has no corresponding input case")
            cdir, rdir = cases / case, rdirs.get(case, results / case)
            gold = sorted(p for p in cdir.glob("*.v")
                          if not p.name.startswith(("stim_", "tb_")) and not p.name.endswith("_tb.v"))
            stimuli = sorted(set(list(cdir.glob("stim_*.v")) + list(cdir.glob("tb_*.v"))
                                 + list(cdir.glob("*_tb.v")) + list((cases / "tb").glob(f"{case}_tb.v"))))
            opt = rdir / "optimized.v"
            if len(gold) != 1 or not stimuli or not opt.is_file():
                raise ValueError("expected exactly one RTL, at least one stimulus, and optimized.v")
            d = json.loads((rdir / "result.json").read_text(encoding="utf-8"))
            top = d.get("top")
            if not top or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_$]*", top):
                raise ValueError("missing/invalid top module")
            row.update(input_sha256=digest(gold[0]), output_sha256=digest(opt), status=d.get("status"))
            for stim in stimuli:
                with tempfile.TemporaryDirectory(prefix="course_") as td:
                    rc, out, err, seconds = run_cmd(
                        [sys.executable, str(checker), "--gold", str(gold[0]), "--opt", str(opt),
                         "--top", top, "--outdir", td, "--tb-file", str(stim)],
                        cwd=str(demo), env=env, timeout=180)
                row["stimuli"].append({"file": stim.name, "sha256": digest(stim), "exit_code": rc,
                                       "seconds": round(seconds, 2),
                                       "error": (out + err)[-800:] if rc else ""})
            ba, bl = demo_score(cfg, gold[0], top)
            oa, ol = demo_score(cfg, opt, top)
            row.update(baseline={"area": ba, "ltp": bl}, optimized={"area": oa, "ltp": ol},
                       literal_gain=oa < ba and ol <= bl)
            row["verdict"] = "PASS" if all(r["exit_code"] == 0 for r in row["stimuli"]) else "FAIL"
        except (OSError, ValueError, KeyError, TypeError) as exc:
            row["error"] = str(exc)
        records.append(row)
        print(f"{case}: {row['verdict']} {row.get('error', '')}", flush=True)
    return {"checker_sha256": digest(checker), "complete": expected == actual,
            "passed": expected == actual and all(r["verdict"] == "PASS" for r in records),
            "cases": records}


def markdown(data):
    lines = ["| 用例 | 课程检查器（全部官方激励） | 面积 基线→优化（字面口径） | ltp 基线→优化 |",
             "|---|---|---|---|"]
    for r in data["cases"]:
        b, o = r.get("baseline", {}), r.get("optimized", {})
        note = " （原样输出）" if r.get("status") == "no-gain" else ""
        error = r.get("error", "").replace("|", "/").replace("\n", " ")
        lines.append(f"| {r['case']} | **{r['verdict']}**{note} {error} | "
                     f"{b.get('area', '--')} → {o.get('area', '--')} | "
                     f"{b.get('ltp', '--')} → {o.get('ltp', '--')} |")
    return "\n".join(lines) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cases", required=True)
    ap.add_argument("--results", required=True)
    ap.add_argument("--demo", required=True)
    ap.add_argument("--output", help="Markdown report (JSON evidence written beside it)")
    args = ap.parse_args()
    try:
        data = audit(Config(), args.cases, args.results, args.demo)
    except (OSError, ValueError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    report = markdown(data)
    if args.output:
        write_text(args.output, report)
        write_json(str(Path(args.output).with_suffix(".json")), data)
    print(report)
    return 0 if data["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
