"""Per-case markdown/JSON reports."""

import datetime
import os

from .util import write_text, write_json


def _pct(b, o):
    try:
        return f"{(o - b) / b * 100:+.1f}%"
    except (TypeError, ZeroDivisionError):
        return "n/a"


def result_dict(st):
    base, fin = st.base, (st.final.synth if st.final else None)
    d = {
        "top": st.top,
        "input": st.rtl_file,
        "kind": ("sequential" if st.info and st.info.is_sequential else "combinational") if st.info else None,
        "status": "optimized" if st.final else ("error" if st.error else "no-gain"),
        "tier": getattr(st, "final_tier", None),
        "error": st.error,
        "baseline": {"area": base.area if base else None, "ltp": base.ltp if base else None,
                     "course_area": st.base_course.area if st.base_course else None,
                     "course_ltp": st.base_course.ltp if st.base_course else None,
                     "cells": base.cells if base else {}},
        "optimized": {"area": fin.area if fin else (base.area if base else None),
                      "ltp": fin.ltp if fin else (base.ltp if base else None),
                      "cells": fin.cells if fin else {}, "candidate": st.final.id if st.final else None},
        "verification": st.final_verify.to_dict() if st.final_verify else None,
        "usage": st.usage.to_dict(),
        "runtime_s": round(st.elapsed(), 1),
        "stop_reason": st.stop_reason,
        "graph_trace": st.trace,
        "candidates": [c.to_dict() for c in st.candidates],
    }
    if base and base.ok and fin:
        d["gain"] = {"area_pct": round((fin.area - base.area) / base.area * 100, 2),
                     "ltp_pct": round((fin.ltp - base.ltp) / max(1, base.ltp) * 100, 2)}
    return d


def write_reports(st):
    d = result_dict(st)
    write_json(os.path.join(st.outdir, "result.json"), d)
    L = [f"# RTL optimization report: `{st.top}`", "",
         f"- generated: {datetime.datetime.now():%Y-%m-%d %H:%M:%S}",
         f"- input: `{st.rtl_file}`",
         f"- design: {st.info.summary() if st.info else 'n/a'}",
         f"- result: **{d['status'].upper()}**" + (f" ({st.error})" if st.error else "")
         + (f", verification tier: **{d['tier']}**" if d.get("tier") else ""), ""]
    base = st.base
    if base and base.ok:
        fin = st.final.synth if st.final else base
        L += ["## Metrics (Yosys + ABC, Nangate45, course scoring script)", "",
              "| metric | baseline | optimized | change |", "|---|---:|---:|---:|",
              f"| area (um^2) | {base.area:.3f} | {fin.area:.3f} | {_pct(base.area, fin.area)} |",
              f"| logic depth (ltp) | {base.ltp} | {fin.ltp} | {_pct(base.ltp, fin.ltp)} |"]
        if st.base_course and st.base_course.ok and (st.base_course.area != base.area or
                                                     st.base_course.ltp != base.ltp):
            L.append(f"| course-literal baseline (no flatten) | area {st.base_course.area}, "
                     f"ltp {st.base_course.ltp} | | hierarchy makes the literal script report a sub-module |")
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
