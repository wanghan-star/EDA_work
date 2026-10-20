"""The RTL optimization agent: state, graph nodes and routing.

    setup -> generate -> evaluate -+-> repair  -> evaluate ...
                                   +-> refine  -> evaluate ...
                                   +-> finalize -> END
"""

import os
import shutil
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor

from . import prompts
from .graph import StateGraph, END
from .llm import LLMClient, LLMError, Usage
from .synth import analyze, synth_eval, course_eval
from .util import log, read_text, write_text, write_json
from .verify import Verifier
from .verilog_utils import extract_verilog, sanity_issues, count_lines

W_AREA, W_DELAY = 0.5, 0.3


class Candidate:
    def __init__(self, cid, origin, parent=None, depth=0, strategy=""):
        self.id = cid
        self.origin = origin
        self.parent = parent
        self.depth = depth            # repair depth
        self.strategy = strategy
        self.messages = []            # conversation that produced it
        self.response = ""
        self.text = None
        self.file = None
        self.plan = ""
        self.synth = None
        self.verify = None
        self.status = "new"
        self.problem = ""
        self.repairable = False

    def score(self, base):
        if not self.synth or not self.synth.ok:
            return float("inf")
        return W_AREA * self.synth.area / base.area + W_DELAY * self.synth.ltp / max(1, base.ltp)

    def summary(self):
        if self.synth and self.synth.ok:
            return f"{self.origin}: area {self.synth.area:.1f}, ltp {self.synth.ltp} -> {self.status}"
        return f"{self.origin}: {self.status}"

    def to_dict(self):
        return {"id": self.id, "origin": self.origin, "parent": self.parent, "depth": self.depth,
                "strategy": self.strategy, "status": self.status, "problem": self.problem[:1500],
                "plan": self.plan, "synth": self.synth.to_dict() if self.synth else None,
                "verify": self.verify.to_dict() if self.verify else None}


class Budget:
    def __init__(self, max_calls=12, max_refine=3, max_repair=2, time_limit=1500, n_init=2,
                 patience=1, min_gain=0.005, resynth="full", resynth_seconds=30, allow_mem=False,
                 rescue_calls=4):
        self.allow_mem = allow_mem
        self.rescue_calls = rescue_calls
        self.resynth = resynth
        self.resynth_seconds = resynth_seconds
        self.max_calls = max_calls
        self.max_refine = max_refine
        self.max_repair = max_repair
        self.time_limit = time_limit
        self.n_init = n_init
        self.patience = patience
        self.min_gain = min_gain


class OptState:
    def __init__(self, cfg, rtl_file, top, outdir, budget, workdir=None, keep_work=False):
        self.cfg = cfg
        self.rtl_file = os.path.abspath(rtl_file)
        self.src = read_text(self.rtl_file)
        self.top = top
        self.outdir = os.path.abspath(outdir)
        self.budget = budget
        self.keep_work = keep_work
        self.workdir = workdir or tempfile.mkdtemp(prefix=f"rtlagent_{top}_")
        self.usage = Usage()
        self.llm = LLMClient(cfg, self.usage, trace_dir=os.path.join(self.outdir, "llm"))
        self.info = None
        self.base = None
        self.base_course = None
        self.verifier = None
        self.candidates = []
        self.pending = []
        self.best = None
        self.history = []
        self.refine_rounds = 0
        self.no_gain_rounds = 0
        self.round_best_before = None
        self.resynth_done = False
        self.resynth_sources = set()
        self.rescue_done = False
        self.t0 = time.time()
        self.error = ""
        self.stop_reason = ""
        self.final = None
        self.final_verify = None
        self.final_tier = None
        self.trace = []

    # ------------------------------------------------------------------ helpers
    def elapsed(self):
        return time.time() - self.t0

    def best_score(self):
        if self.best is None:
            return W_AREA + W_DELAY          # baseline normalised score
        return self.best.score(self.base)

    def new_cand(self, origin, parent=None, depth=0, strategy=""):
        c = Candidate(f"c{len(self.candidates) + 1:02d}", origin, parent, depth, strategy)
        self.candidates.append(c)
        return c

    def budget_left(self):
        return (self.usage.logical_calls < self.budget.max_calls and self.elapsed() < self.budget.time_limit
                and self.llm.available())

    def thinking_for(self, kind, index=0):
        mode = self.cfg.llm_thinking
        if mode in ("on", "true", "1", "yes"):
            return True
        if mode in ("off", "false", "0", "no"):
            return False
        # auto: visible short analysis is enough normally; hidden reasoning only for the rescue call
        # when nothing has been verified yet (reasoning tokens are expensive and unbounded)
        return kind == "rescue"


# ---------------------------------------------------------------------- nodes
def node_setup(st):
    os.makedirs(st.outdir, exist_ok=True)
    info, err = analyze(st.cfg, [st.rtl_file], st.top, st.src)
    if info is None:
        st.error = f"cannot elaborate input: {err}"
        return
    st.info = info
    with ThreadPoolExecutor(2) as ex:
        f1 = ex.submit(synth_eval, st.cfg, [st.rtl_file], st.top)
        f2 = ex.submit(course_eval, st.cfg, [st.rtl_file], st.top)
        st.base, st.base_course = f1.result(), f2.result()
    if not st.base.ok:
        st.error = f"baseline synthesis failed: {st.base.error}"
        return
    log(f"baseline {st.top}: area={st.base.area:.3f} ltp={st.base.ltp} "
        f"(course-literal area={st.base_course.area} ltp={st.base_course.ltp}); {info.summary()}", "setup")
    st.verifier = Verifier(st.cfg, info, [st.rtl_file], os.path.join(st.workdir, "verify"))
    ok, err = st.verifier.prepare()
    if not ok:
        st.error = f"reference simulation failed: {err}"
        return
    if st.verifier.event_sensitive:
        log(f"event-sensitive outputs: {st.verifier.event_sensitive}", "setup")


def _strategies(st):
    if st.info.is_sequential:
        order = ["conservative", "sequential", "datapath", "logic", "minimal"]
        n = st.budget.n_init + 1          # sequential designs benefit most from extra diversity
    else:
        order = ["conservative", "datapath", "logic", "minimal"]
        n = st.budget.n_init
    return order[:max(1, n)]


def _call(st, cand, thinking, temperature=0.2):
    try:
        cand.response = st.llm.chat(cand.messages, tag=f"{cand.id}_{cand.strategy or 'x'}",
                                    thinking=thinking, temperature=temperature,
                                    max_tokens=16000 if thinking else 8000)
    except LLMError as e:
        cand.status = "llm-error"
        cand.problem = str(e)
        log(f"{cand.id}: LLM error {e}", "llm")


def node_generate(st):
    strategies = _strategies(st)
    cands = []
    for i, s in enumerate(strategies):
        c = st.new_cand(f"init:{s}", strategy=s)
        user = prompts.initial_user(st.src, st.top, st.base, st.info, st.verifier.event_sensitive, s)
        c.messages = [{"role": "system", "content": prompts.SYSTEM}, {"role": "user", "content": user}]
        c.thinking = st.thinking_for("init", i)
        cands.append(c)
    with ThreadPoolExecutor(len(cands)) as ex:
        list(ex.map(lambda c: _call(st, c, c.thinking, temperature=0.2 + 0.2 * cands.index(c)), cands))
    st.pending = [c for c in cands if c.status != "llm-error"]


def _extract_plan(resp):
    lines = []
    grab = False
    for ln in (resp or "").splitlines():
        if ln.strip().upper().startswith("PLAN"):
            grab = True
            rest = ln.split(":", 1)[1].strip() if ":" in ln else ""
            if rest:
                lines.append(rest)
            continue
        if grab:
            if ln.strip().startswith("```"):
                break
            if ln.strip():
                lines.append(ln.strip())
    return "\n".join(lines[:8])


def _prepare(st, c):
    """Extraction, sanity checks and synthesis (cheap). Sets status for failures."""
    if c.text is None:
        c.plan = _extract_plan(c.response)
        c.text = extract_verilog(c.response, st.top)
    if c.text is None:
        c.status, c.repairable = "format", True
        c.problem = f"No complete ```verilog block defining module `{st.top}` was found."
        return
    issues = sanity_issues(c.text, st.top, st.src)
    if issues:
        c.status, c.repairable = "sanity", True
        c.problem = "[rules] " + "; ".join(issues)
        return
    c.file = os.path.join(st.outdir, "candidates", f"{c.id}.v")
    write_text(c.file, c.text)
    c.synth = synth_eval(st.cfg, [c.file], st.top)
    if not c.synth.ok:
        c.status, c.repairable = "synth-error", True
        c.problem = f"[yosys] {c.synth.error}"
        return
    a, d = c.synth.area, c.synth.ltp
    n_mem = sum(n for t, n in c.synth.cells.items() if t.startswith("$mem"))
    n_mem0 = sum(n for t, n in st.base.cells.items() if t.startswith("$mem"))
    if n_mem > n_mem0 and not st.budget.allow_mem:
        # the scoring script does not map memories, so their decode/mux logic would vanish from
        # the area report without any real saving -> not a legitimate gain
        c.status, c.repairable = "mem-artifact", True
        c.problem = ("[rules] your coding style makes Yosys infer a memory array ($mem cells); the scoring "
                     "flow does not map memories, which hides their logic instead of reducing it. Implement "
                     "storage as registers like the original (constant-index or reset-loop style).")
        return
    if d > st.base.ltp and a < st.base.area:
        c.status, c.repairable = "ltp-worse", True
        c.problem = (f"[metrics] area {a:.1f} is good but ltp={d} exceeds the baseline ltp={st.base.ltp}. "
                     f"Your longest path runs through: {' -> '.join(c.synth.ltp_path) or '?'}. "
                     f"Shorten that chain (fewer cell levels between registers).")
        return
    if a >= st.base.area or d > st.base.ltp:
        c.status = "no-gain"
        c.problem = f"[metrics] area {a:.1f} / ltp {d} is not better than baseline {st.base.area:.1f} / {st.base.ltp}"
        return
    c.status = "synth-ok"


def node_evaluate(st):
    pend = st.pending
    st.pending = []
    if not pend:
        return
    with ThreadPoolExecutor(min(len(pend), st.cfg.jobs)) as ex:
        list(ex.map(lambda c: _prepare(st, c), pend))
    thr = st.best_score()
    best_area = st.best.synth.area if st.best else st.base.area
    to_verify = [c for c in pend
                 if (c.status == "synth-ok" and c.score(st.base) < thr - 1e-9)
                 or (c.status == "ltp-worse" and c.synth.area < best_area)]
    for c in pend:
        if c.status in ("synth-ok", "ltp-worse") and c not in to_verify:
            c.status = "not-better"
            c.repairable = False
    with ThreadPoolExecutor(max(1, min(len(to_verify), st.cfg.jobs))) as ex:
        list(ex.map(lambda c: _verify(st, c), to_verify))
    for c in sorted(to_verify, key=lambda c: c.score(st.base)):
        if c.status == "verified" and c.score(st.base) < st.best_score() - 1e-9:
            st.best = c
            log(f"new best {c.id} ({c.origin}): area {c.synth.area:.3f} "
                f"({100 * (c.synth.area / st.base.area - 1):+.1f}%), ltp {c.synth.ltp}", "eval")
    for c in pend:
        st.history.append(c.summary())
        write_json(os.path.join(st.outdir, "candidates", f"{c.id}.json"), c.to_dict())
        if c.status not in ("verified",):
            log(f"{c.id} ({c.origin}): {c.status} {c.problem[:160]!r}", "eval")


def _verify(st, c):
    r = st.verifier.verify([c.file], c.id)
    c.verify = r
    if r.relaxed and c.status != "ltp-worse":
        # usable only as a fallback (identical after reset; differs in power-up X / glitch events)
        c.status = "relaxed"
        c.repairable = c.strategy != "resynth"
        c.problem = prompts.describe_failure(r, st.info)
        return
    if r.ok:
        if c.status == "ltp-worse":
            c.problem = ("[metrics] the design is functionally correct (verified) and area "
                         f"{c.synth.area:.1f} is good, but ltp={c.synth.ltp} exceeds the baseline ltp={st.base.ltp}. "
                         "Keep the logic but shorten the longest chain of cells (fewer levels between registers).")
            return
        c.status = "verified"
    else:
        c.status = f"fail-{r.stage}"
        c.repairable = True
        c.problem = prompts.describe_failure(r, st.info)


def _repairable(st):
    thr = st.best_score()
    out = []
    for c in st.candidates:
        if not c.repairable or c.depth >= st.budget.max_repair or getattr(c, "repaired", False):
            continue
        if c.synth and c.synth.ok and c.status not in ("ltp-worse",) and c.score(st.base) >= thr:
            continue
        out.append(c)
    return out


def _pending_resynth_sources(st):
    mode = st.budget.resynth
    if st.error or mode in (None, False, "off"):
        return []
    srcs = []
    if "orig" not in st.resynth_sources and not (mode == "fallback" and st.best is not None):
        srcs.append(("orig", [st.rtl_file]))
    if (mode == "full" and st.best is not None and st.best.strategy != "resynth"
            and st.best.id not in st.resynth_sources):
        srcs.append((st.best.id, [st.best.file]))
    # a verified LLM design that is smaller but too deep: depth-oriented re-synthesis may rescue it
    best_area = st.best.synth.area if st.best else st.base.area
    deep = sorted([c for c in st.candidates if c.status == "ltp-worse" and c.verify is not None and c.verify.ok
                   and c.synth.area < best_area and c.strategy != "resynth"
                   and c.id not in st.resynth_sources], key=lambda c: c.synth.area)
    if deep and mode != "off":
        srcs.append((deep[0].id, [deep[0].file]))
    return srcs


def _end_phase(st):
    if _pending_resynth_sources(st):
        return "resynth"
    return route_after_resynth(st)


def route_after_evaluate(st):
    if st.error:
        return "finalize"
    if not st.budget_left():
        st.stop_reason = st.stop_reason or "budget exhausted"
        return _end_phase(st)
    if _repairable(st):
        return "repair"
    if st.refine_rounds < st.budget.max_refine and st.no_gain_rounds < st.budget.patience:
        return "refine"
    st.stop_reason = st.stop_reason or ("no further gain" if st.no_gain_rounds else "refine rounds done")
    return _end_phase(st)


def node_resynth(st):
    """Zero-token ABC re-synthesis of the original and of the current best candidate."""
    from .resynth import resynth, DEFAULT_SET
    st.resynth_done = True
    sources = _pending_resynth_sources(st)
    st.resynth_sources.update(sid for sid, _f in sources)
    jobs = [(sid, files, s) for sid, files in sources for s in DEFAULT_SET]
    if not jobs:
        return

    def work(job):
        sid, files, script = job
        text, msg = resynth(st.cfg, files, st.top, os.path.join(st.workdir, "resynth", f"{sid}_{script}"),
                            script=script, seconds=st.budget.resynth_seconds, orig_src=st.src)
        return sid, script, text, msg
    # independent single-threaded ABC processes: use (almost) all cores
    with ThreadPoolExecutor(min(len(jobs), max(st.cfg.jobs, (os.cpu_count() or 4) - 2))) as ex:
        results = list(ex.map(work, jobs))
    seen = set()
    for sid, script, text, msg in results:
        if not text or text in seen:
            continue
        seen.add(text)
        c = st.new_cand(f"resynth:{script}({sid})", parent=None if sid == "orig" else sid, strategy="resynth")
        c.text = text
        c.plan = f"ABC logic re-synthesis ({script}) of {'the original RTL' if sid == 'orig' else sid}"
        st.pending.append(c)


def route_after_resynth(st):
    if (st.best is None and not st.rescue_done and st.budget.rescue_calls > 0 and st.llm.available()
            and not st.error and st.elapsed() < st.budget.time_limit):
        # A combinational original whose own waveform has zero-width re-dumps cannot be matched
        # event-by-event by ANY restructured design; a relaxed gain is the best attainable there.
        relaxed_gain = any(c.status == "relaxed" and _gainful(st, c) for c in st.candidates)
        if relaxed_gain and not st.info.is_sequential and st.verifier.event_sensitive:
            st.stop_reason = st.stop_reason or "relaxed gain; original has glitch events (rescue skipped)"
            return "finalize"
        return "rescue"
    return "finalize"


def node_rescue(st):
    """Nothing verified gave a gain yet: spend a few more LLM calls on structural strategies."""
    st.rescue_done = True
    st.budget.max_calls = st.usage.logical_calls + st.budget.rescue_calls
    st.budget.max_refine = st.refine_rounds + 1
    st.no_gain_rounds = 0
    used = {c.strategy for c in st.candidates}
    pool = prompts.RESCUE_SEQ if st.info.is_sequential else prompts.RESCUE_COMB
    picks = [s for s in pool if s not in used][:2] or pool[:2]
    cands = []
    for i, s in enumerate(picks):
        c = st.new_cand(f"rescue:{s}", strategy=s)
        user = prompts.initial_user(st.src, st.top, st.base, st.info, st.verifier.event_sensitive, s,
                                    history=st.history)
        c.messages = [{"role": "system", "content": prompts.SYSTEM}, {"role": "user", "content": user}]
        cands.append(c)
    log(f"rescue round with strategies {picks}", "rescue")
    with ThreadPoolExecutor(len(cands)) as ex:
        list(ex.map(lambda c: _call(st, c, st.thinking_for("rescue"), temperature=0.5), cands))
    st.pending = [c for c in cands if c.status != "llm-error"]


def node_repair(st):
    todo = _repairable(st)[:2]
    news = []
    for c in todo:
        c.repaired = True
        n = st.new_cand(f"repair({c.id})", parent=c.id, depth=c.depth + 1, strategy=c.strategy)
        n.messages = list(c.messages) + [{"role": "assistant", "content": c.response},
                                         {"role": "user", "content": prompts.repair_user(c.problem)}]
        news.append(n)
    with ThreadPoolExecutor(len(news)) as ex:
        list(ex.map(lambda n: _call(st, n, thinking=st.thinking_for("repair"), temperature=0.3), news))
    st.pending = [n for n in news if n.status != "llm-error"]


def node_refine(st):
    st.refine_rounds += 1
    before = st.best_score()
    if st.best is None:
        # nothing verified yet: try a different strategy from scratch
        used = {c.strategy for c in st.candidates}
        allowed = [s for s in prompts.STRATEGIES if st.info.is_sequential or s != "sequential"]
        rest = [s for s in allowed if s not in used] or ["minimal"]
        c = st.new_cand(f"init:{rest[0]}", strategy=rest[0])
        user = prompts.initial_user(st.src, st.top, st.base, st.info, st.verifier.event_sensitive, rest[0])
        c.messages = [{"role": "system", "content": prompts.SYSTEM}, {"role": "user", "content": user}]
        _call(st, c, thinking=st.thinking_for("rescue"))
    else:
        c = st.new_cand(f"refine#{st.refine_rounds}({st.best.id})", parent=st.best.id, strategy="refine")
        user = prompts.refine_user(st.best.text, st.top, st.base, st.best.synth, st.history, st.info,
                                   st.verifier.event_sensitive)
        c.messages = [{"role": "system", "content": prompts.SYSTEM}, {"role": "user", "content": user}]
        _call(st, c, thinking=False, temperature=0.4)
    st.pending = [c] if c.status != "llm-error" else []
    st.round_best_before = before


def node_evaluate_refine(st):
    node_evaluate(st)
    before = st.round_best_before if st.round_best_before is not None else st.best_score()
    gain = before - st.best_score()
    if gain < st.budget.min_gain * (W_AREA + W_DELAY):
        st.no_gain_rounds += 1
    else:
        st.no_gain_rounds = 0


def _gainful(st, c):
    return (c.synth is not None and c.synth.ok and c.synth.area < st.base.area
            and c.synth.ltp <= st.base.ltp)


def node_finalize(st):
    from .report import write_reports
    strict = sorted([c for c in st.candidates if c.status == "verified" and _gainful(st, c)],
                    key=lambda c: c.score(st.base))
    relaxed = sorted([c for c in st.candidates if c.status == "relaxed" and _gainful(st, c)],
                     key=lambda c: c.score(st.base))
    chosen = None
    st.final_tier = None
    if st.verifier is not None and (strict or relaxed):
        deep = Verifier(st.cfg, st.info, [st.rtl_file], os.path.join(st.workdir, "final"), budget="high",
                        formal_timeout=240)
        ok, err = deep.prepare()
        # strict candidates first; relaxed ones only if no strict candidate has a gain
        for tier, pool in (("strict", strict), ("relaxed", relaxed)):
            for c in pool[:4]:
                r = deep.verify([c.file], f"final_{c.id}") if ok else None
                good = r is None or r.ok or (tier == "relaxed" and r.relaxed)
                if good:
                    chosen = c
                    st.final_tier = tier if (r is None or r.ok) else "relaxed"
                    st.final_verify = r or c.verify
                    break
                c.status = f"fail-final-{r.stage}"
                c.problem = prompts.describe_failure(r, st.info)
                log(f"{c.id} rejected by deep verification: {c.problem[:200]}", "final")
            if chosen is not None:
                break
    if chosen is not None and st.final_tier == "relaxed":
        log(f"using RELAXED candidate {chosen.id}: identical after reset, differs only in power-up X or "
            f"zero-width waveform events", "final")
    st.final = chosen
    out_v = os.path.join(st.outdir, "optimized.v")
    write_text(out_v, chosen.text if chosen else st.src)
    write_reports(st)
    if not st.keep_work:
        shutil.rmtree(st.workdir, ignore_errors=True)


def build_graph():
    g = StateGraph("rtl-opt")
    g.add_node("setup", node_setup)
    g.add_node("generate", node_generate)
    g.add_node("evaluate", node_evaluate)
    g.add_node("repair", node_repair)
    g.add_node("refine", node_refine)
    g.add_node("evaluate_refine", node_evaluate_refine)
    g.add_node("resynth", node_resynth)
    g.add_node("evaluate_resynth", node_evaluate)
    g.add_node("finalize", node_finalize)
    g.add_node("rescue", node_rescue)
    g.add_edge("resynth", "evaluate_resynth")
    g.add_conditional_edges("evaluate_resynth", route_after_resynth)
    g.add_edge("rescue", "evaluate")
    g.add_conditional_edges("setup", lambda s: "finalize" if s.error else
                            ("generate" if s.llm.available() else _end_phase(s)))
    g.add_edge("generate", "evaluate")
    g.add_conditional_edges("evaluate", route_after_evaluate)
    g.add_edge("repair", "evaluate")
    g.add_edge("refine", "evaluate_refine")
    g.add_conditional_edges("evaluate_refine", route_after_evaluate)
    g.add_edge("finalize", END)
    return g


def optimize(cfg, rtl_file, outdir, top=None, budget=None, workdir=None, keep_work=False):
    from .verilog_utils import detect_top
    src = read_text(rtl_file)
    top = top or detect_top(src)
    st = OptState(cfg, rtl_file, top, outdir, budget or Budget(), workdir, keep_work)
    g = build_graph()
    st.trace = g.run(st, "setup")
    return st
