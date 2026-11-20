"""Equivalence verification pipeline: ports -> strict 4-state simulation -> formal proof."""

import os

from . import formal
from .simcheck import CourseTB, GoldSim, replay_trace
from .synth import analyze, lint
from .tbgen import default_stimuli


class VerifyResult:
    def __init__(self):
        self.ok = False
        self.relaxed = False     # passes everything except course-strict event/X equality before reset
        self.stage = ""          # where it failed (or 'done')
        self.message = ""
        self.mismatch = None
        self.sim = None
        self.formal = None
        self.seconds = 0.0

    def evidence(self):
        parts = []
        if self.sim is not None:
            verdict = "PASS" if self.sim.ok else ("RELAXED-PASS (power-up X / glitch events differ)"
                                                  if self.sim.relaxed_ok else "FAIL")
            parts.append(f"sim: {self.sim.n_vectors} vectors/cycles strict-VCD {verdict}")
            if getattr(self.sim, "course_passed", None):
                parts.append("course stimuli PASS: " + ", ".join(k.split(":", 1)[-1] for k in self.sim.course_passed))
        if self.formal is not None:
            f = self.formal
            if f.status == "proved":
                parts.append(f"formal: PROVED ({f.message})")
            elif f.status == "bounded":
                parts.append(f"formal: bounded PASS, {f.depth} cycles")
            else:
                parts.append(f"formal: {f.status} ({f.message[:80]})")
        return "; ".join(parts)

    def to_dict(self):
        return {"ok": self.ok, "relaxed": self.relaxed, "stage": self.stage, "message": self.message[-800:],
                "mismatch": self.mismatch, "evidence": self.evidence(),
                "sim": self.sim.to_dict() if self.sim else None,
                "formal": self.formal.to_dict() if self.formal else None,
                "seconds": round(self.seconds, 2)}


# Formal outcomes accepted per policy (strict 4-state simulation must pass in every case).
#   proved : only complete proofs (ABC iprove for comb, temporal induction for seq)
#   bounded: also bounded model checks without counter-example, multi-clock designs that cannot be
#            modelled (simulation only). Timeouts and unconfirmed counterexamples are rejected.
ACCEPTED_FORMAL = {"proved": ("proved",), "bounded": ("proved", "bounded", "skipped")}


class Verifier:
    def __init__(self, cfg, info, gold_files, workdir, budget="normal", formal_timeout=90, accept="bounded",
                 course_tbs=()):
        self.accept = accept if accept in ACCEPTED_FORMAL else "bounded"
        self.cfg, self.info = cfg, info
        self.gold_files = [os.path.abspath(f) for f in gold_files]
        self.workdir = workdir
        self.budget = budget
        self.formal_timeout = formal_timeout
        # provided course testbenches (stim_*.v) are run exactly like the course checker, strictly
        stimuli = list(default_stimuli(info, budget)) + [CourseTB(p) for p in course_tbs]
        self.gold = GoldSim(cfg, info, self.gold_files, stimuli, os.path.join(workdir, "sim"))
        self.ready = False

    def prepare(self):
        self.ready = self.gold.prepare()
        return self.ready, self.gold.error

    @property
    def event_sensitive(self):
        return self.gold.event_sensitive

    def check_ports(self, cand_files):
        cinfo, err = analyze(self.cfg, cand_files, self.info.top)
        if cinfo is None:
            return False, f"elaboration failed: {err}"
        g, c = self.info.ports, cinfo.ports
        probs = []
        for n in sorted(set(g) | set(c)):
            if n not in c:
                probs.append(f"port `{n}` missing")
            elif n not in g:
                probs.append(f"extra port `{n}`")
            elif g[n] != c[n]:
                probs.append(f"port `{n}`: expected direction/width/signedness {g[n]}, got {c[n]}")
        if getattr(self.info, "parameters", {}) != getattr(cinfo, "parameters", {}):
            probs.append("parameter names/defaults changed")
        return (not probs), "; ".join(probs)

    def verify(self, cand_files, label, do_formal=True):
        import time
        t0 = time.time()
        res = VerifyResult()
        cand_files = [os.path.abspath(f) for f in cand_files]
        ok, msg, _w = lint(self.cfg, cand_files, self.info.top)
        if not ok:
            res.stage, res.message = "lint", msg
            res.seconds = time.time() - t0
            return res
        ok, msg = self.check_ports(cand_files)
        if not ok:
            res.stage, res.message = "ports", msg
            res.seconds = time.time() - t0
            return res
        sres = self.gold.check(cand_files, label)
        res.sim = sres
        if sres.error:
            res.stage, res.message = "compile", sres.error
            res.seconds = time.time() - t0
            return res
        if not sres.ok and not sres.relaxed_ok:
            res.stage, res.mismatch = "sim", sres.mismatch
            res.message = f"simulation mismatch on {sres.bad_outputs}"
            res.seconds = time.time() - t0
            return res
        waveform_relaxed = not sres.ok and sres.relaxed_ok
        if waveform_relaxed:
            # functionally identical after reset; differs only in power-up X / zero-width events
            res.mismatch = sres.mismatch
            res.message = f"strict waveform mismatch on {sres.bad_outputs} (power-up X / zero-width events only)"
        if do_formal:
            fdir = os.path.join(self.workdir, "formal", label)
            if self.info.is_sequential:
                fr = formal.prove_seq(self.cfg, self.gold_files, cand_files, self.info.top, self.info, fdir,
                                      depth=10 if self.budget == "normal" else 30,
                                      timeout=self.formal_timeout)
            else:
                fr = formal.prove_comb(self.cfg, self.gold_files, cand_files, self.info.top, self.info, fdir,
                                       timeout=self.formal_timeout)
            res.formal = fr
            if fr.status == "cex":
                confirmed, mm = replay_trace(self.cfg, self.info, self.gold_files, cand_files, fr.trace,
                                             os.path.join(fdir, "replay"))
                if confirmed:
                    res.stage, res.mismatch = "sim", mm
                    if mm is not None:
                        mm["stimulus"] = "formal counter-example"
                    res.message = "formal counter-example confirmed in simulation"
                    res.seconds = time.time() - t0
                    return res
                # never accepted: the 2-valued trace may be an X artefact or a real bug the replay missed
                fr.status = "unconfirmed-cex"
                fr.message = "2-valued counter-example not reproducible in 4-state simulation (X semantics)"
            if fr.status not in ACCEPTED_FORMAL[self.accept]:
                res.stage = "formal"
                res.message = (f"formal evidence not accepted under --accept {self.accept}: "
                               f"{fr.status} ({fr.message})")
                res.seconds = time.time() - t0
                return res
        else:
            res.stage = "formal"
            res.message = "formal proof required: verification was disabled"
            res.seconds = time.time() - t0
            return res
        if waveform_relaxed:
            res.relaxed = True
            res.stage = "sim-relaxed"
            res.seconds = time.time() - t0
            return res
        res.ok = True
        res.stage = "done"
        res.seconds = time.time() - t0
        return res
