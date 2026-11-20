"""Per-case markdown/JSON reports."""

import datetime
import hashlib
import os
import platform

from .util import write_text, write_json


def _pct(b, o):
    try:
        return f"{(o - b) / b * 100:+.1f}%"
    except (TypeError, ZeroDivisionError):
        return "n/a"


def result_dict(st):
    base, fin = st.base, (st.final.synth if st.final else None)
    fc = getattr(st, "final_course", None) if st.final else getattr(st, "base_course", None)
    d = {
        "top": st.top,
        "input": st.rtl_file,
        "kind": ("sequential" if st.info and st.info.is_sequential else "combinational") if st.info else None,
        "status": "optimized" if st.final else ("error" if st.error else "no-gain"),
        "tier": getattr(st, "final_tier", None),
        "policy": {"accept": getattr(st.budget, "accept", "proved"),
                   "allow_relaxed": bool(getattr(st.budget, "allow_relaxed", False))},
        "error": st.error,
        "baseline": {"area": base.area if base else None, "ltp": base.ltp if base else None,
                     "course_area": st.base_course.area if st.base_course else None,
                     "course_ltp": st.base_course.ltp if st.base_course else None,
                     "course_hier_area": getattr(st.base_course, "hier_area", None) if st.base_course else None,
                     "cells": base.cells if base else {}},
        "optimized": {"area": fin.area if fin else (base.area if base else None),
                      "ltp": fin.ltp if fin else (base.ltp if base else None),
                      # unchanged output -> the course reading is the baseline's
                      "course_area": fc.area if fc else None,
                      "course_ltp": fc.ltp if fc else None,
                      "course_hier_area": getattr(fc, "hier_area", None) if fc else None,
                      "cells": fin.cells if fin else (base.cells if base else {}),
                      "candidate": st.final.id if st.final else None},
        "verification": st.final_verify.to_dict() if st.final_verify else None,
        "usage": st.usage.to_dict(),
        "runtime_s": round(st.elapsed(), 1),
        "stop_reason": st.stop_reason,
        "graph_trace": st.trace,
        "candidates": [c.to_dict() for c in st.candidates],
        "reproducibility": {
            "input_sha256": hashlib.sha256(st.src.encode("utf-8")).hexdigest(),
            "python": platform.python_version(),
            "yosys_version": ".".join(map(str, st.cfg.yosys_version())),
            "liberty_sha256": _file_hash(st.cfg.lib_file),
            "llm_model": st.cfg.llm_model if st.cfg.llm_key else None,
            "budget": vars(st.budget),
            "formal_required": st.budget.accept,
            "output_sha256": hashlib.sha256((st.final.text if st.final else st.src).encode("utf-8")).hexdigest(),
        },
    }
    if base and base.ok and base.area and fin:
        d["gain"] = {"area_pct": round((fin.area - base.area) / base.area * 100, 2),
                     "ltp_pct": round((fin.ltp - base.ltp) / max(1, base.ltp) * 100, 2)}
    return d


def _file_hash(path):
    with open(path, "rb") as fh:
        return hashlib.sha256(fh.read()).hexdigest()


def write_reports(st):
    d = result_dict(st)
    write_json(os.path.join(st.outdir, "result.json"), d)
    L = [f"# RTL optimization report: `{st.top}`", "",
         f"- generated: {datetime.datetime.now():%Y-%m-%d %H:%M:%S}",
         f"- input: `{st.rtl_file}`",
         f"- design: {st.info.summary() if st.info else 'n/a'}",
         f"- result: **{d['status'].upper()}**" + (f" ({st.error})" if st.error else "")
         + (f", verification tier: **{d['tier']}**" if d.get("tier") else ""),
         f"- acceptance policy: formal `--accept {d['policy']['accept']}`, relaxed fallback "
         f"{'on' if d['policy']['allow_relaxed'] else 'off'}", ""]
    base = st.base
    if base and base.ok:
        fin = st.final.synth if st.final else base
        L += ["## Metrics (Yosys + ABC, Nangate45, course scoring script)", "",
              "| metric | baseline | optimized | change |", "|---|---:|---:|---:|",
              f"| area (um^2) | {base.area:.3f} | {fin.area:.3f} | {_pct(base.area, fin.area)} |",
              f"| logic depth (ltp) | {base.ltp} | {fin.ltp} | {_pct(base.ltp, fin.ltp)} |"]
        bc, oc = d["baseline"], d["optimized"]
        if st.base_course and st.base_course.ok and (st.base_course.area != base.area or
                                                     st.base_course.ltp != base.ltp):
            # the unflattened script reports the alphabetically last module (see synth.py)
            L.append(f"| course-literal area (no flatten) | {bc['course_area']} | {oc['course_area']} | "
                     f"{_pct(bc['course_area'], oc['course_area'])} |")
            L.append(f"| course-literal ltp (no flatten) | {bc['course_ltp']} | {oc['course_ltp']} | "
                     f"{_pct(bc['course_ltp'], oc['course_ltp'])} |")
            if bc.get("course_hier_area") is not None:
                L.append(f"| hierarchy total area | {bc['course_hier_area']} | {oc.get('course_hier_area')} | "
                         f"{_pct(bc['course_hier_area'], oc.get('course_hier_area'))} |")
        L += ["", "Area counts combinational standard cells; flip-flops have no liberty area in the "
              "scoring script. ltp counts cells on the longest topological path (flip-flops included).", ""]
    if st.final:
        v = st.final_verify
        L += ["## Equivalence evidence", "",
              f"- {v.evidence() if v else 'n/a'}",
              "- checks: port/width identity, 4-state iverilog co-simulation with course-identical "
              "VCD event comparison (reset-first and pre-reset-X stimuli), Yosys/ABC formal proof "
              "(combinational: ABC iprove on a miter; sequential: SAT temporal induction / BMC).", ""]
        if getattr(st, "final_tier", None) == "relaxed":
            L += ["> Tier **relaxed**: no candidate passed the course-strict event-by-event comparison with a gain. "
                  "The emitted design is formally equivalent and identical on every output after reset; it differs "
                  "only in power-up X values before the reset sequence or in zero-width re-dump events.", ""]
        if st.final.plan:
            L += ["## What changed (agent plan)", "", st.final.plan, ""]
    else:
        L += ["## Outcome", "", "No verified candidate improved the design; the original RTL is emitted unchanged.", ""]
    u = st.usage.to_dict()
    L += ["## Cost", "",
          f"- LLM calls: {u['calls']}, tokens: {u['total_tokens']} (prompt {u['prompt_tokens']}, "
          f"completion {u['completion_tokens']}, of which reasoning {u['reasoning_tokens']})",
          f"- wall time: {st.elapsed():.1f}s (LLM {u['llm_seconds']}s)",
          f"- stop reason: {st.stop_reason or '-'}", "",
          "## Iterations", "", "| id | origin | status | area | ltp | note |", "|---|---|---|---:|---:|---|"]
    for c in st.candidates:
        a = f"{c.synth.area:.1f}" if c.synth and c.synth.ok else "-"
        l_ = str(c.synth.ltp) if c.synth and c.synth.ok else "-"
        note = (c.problem.splitlines()[0][:90] if c.problem else "").replace("|", "/")
        mark = " **(final)**" if st.final is c else ""
        L.append(f"| {c.id}{mark} | {c.origin} | {c.status} | {a} | {l_} | {note} |")
    L += ["", "## Agent graph trace", "", " -> ".join(f"{n}({t}s)" for n, t in st.trace), ""]
    write_text(os.path.join(st.outdir, "report.md"), "\n".join(L))
