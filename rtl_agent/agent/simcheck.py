"""Simulation-based equivalence check (iverilog, 4-state), course-checker compatible."""

import os

from .tbgen import gen_testbench
from .util import run_cmd, write_text, tail
from .vcd import (parse_vcd, compare_strict, first_mismatch, has_duplicate_events,
                  value_mismatch_times, snapshot)


class SimResult:
    def __init__(self):
        self.ok = False
        self.error = ""            # compile / runtime problem (candidate unusable)
        self.mismatch = None       # dict from vcd.first_mismatch
        self.bad_outputs = []
        self.n_vectors = 0
        self.seconds = 0.0
        self.relaxed_ok = False

    def to_dict(self):
        return {"ok": self.ok, "relaxed_ok": self.relaxed_ok, "error": self.error[-600:],
                "mismatch": self.mismatch,
                "bad_outputs": self.bad_outputs, "n_vectors": self.n_vectors,
                "seconds": round(self.seconds, 2)}


def _simulate(cfg, tb_file, rtl_files, vcd, vec, workdir, label, timeout):
    vvp = os.path.join(workdir, f"{label}.vvp")
    cmd = [cfg.iverilog, "-g2012", f'-DVCD_PATH="{vcd}"', f'-DVEC_PATH="{vec}"', "-o", vvp, tb_file] + list(rtl_files)
    rc, out, err, s1 = run_cmd(cmd, cwd=workdir, timeout=timeout)
    if rc != 0:
        return False, "iverilog compile failed:\n" + tail(out + err, 1200), s1
    rc, out, err, s2 = run_cmd([cfg.vvp, "-n", vvp], cwd=workdir, timeout=timeout)
    if rc != 0 or not os.path.isfile(vcd):
        return False, "vvp simulation failed:\n" + tail(out + err, 800), s1 + s2
    return True, "", s1 + s2


class GoldSim:
    """Runs the reference design once per stimulus and caches the parsed waveforms."""

    def __init__(self, cfg, info, gold_files, stimuli, workdir, timeout=300):
        self.cfg, self.info = cfg, info
        self.gold_files = [os.path.abspath(f) for f in gold_files]
        self.stimuli, self.workdir, self.timeout = stimuli, workdir, timeout
        self.waves = []
        self.tb_files = []
        self.vec_files = []
        self.error = ""
        self.event_sensitive = []   # outputs whose gold waveform contains same-value re-dumps

    def prepare(self):
        os.makedirs(self.workdir, exist_ok=True)
        outs = self.info.outputs()
        sens = set()
        for i, st in enumerate(self.stimuli):
            vec = os.path.join(self.workdir, f"stim{i}.hex")
            write_text(vec, "\n".join(st.hex_lines()) + "\n")
            tb = os.path.join(self.workdir, f"tb{i}.v")
            write_text(tb, gen_testbench(self.info, st))
            vcd = os.path.join(self.workdir, f"gold{i}.vcd")
            ok, err, _ = _simulate(self.cfg, tb, self.gold_files, vcd, vec, self.workdir, f"gold{i}", self.timeout)
            if not ok:
                self.error = err
                return False
            wave = parse_vcd(vcd)
            missing = [o for o in outs if o not in wave]
            if missing:
                self.error = f"outputs missing from gold VCD: {missing}"
                return False
            for o in outs:
                if has_duplicate_events(wave.get(o)):
                    sens.add(o)
            self.waves.append(wave)
            self.tb_files.append(tb)
            self.vec_files.append(vec)
        self.event_sensitive = sorted(sens)
        return True

    def check(self, opt_files, label):
        """Compare a candidate against the cached gold waveforms.

        ok          : every output identical event-by-event in every stimulus (course-checker strict)
        relaxed_ok  : not strict, but all differences are zero-width re-dump events or X-vs-value
                      differences before the reset sequence completed (pre-reset power-up X)
        """
        res = SimResult()
        opt_files = [os.path.abspath(f) for f in opt_files]
        outs = self.info.outputs()
        ins = self.info.inputs()
        cdir = os.path.join(self.workdir, label)
        os.makedirs(cdir, exist_ok=True)
        strict_all, relaxed_all = True, True
        hard_recorded = False
        for i, st in enumerate(self.stimuli):
            vcd = os.path.join(cdir, f"opt{i}.vcd")
            ok, err, sec = _simulate(self.cfg, self.tb_files[i], opt_files, vcd, self.vec_files[i],
                                     cdir, f"opt{i}", self.timeout)
            res.seconds += sec
            if not ok:
                res.error = err
                return res
            wave = parse_vcd(vcd)
            good, bad = compare_strict(self.waves[i], wave, outs)
            res.n_vectors += len(st.vectors)
            if not good:
                strict_all = False
                rel = relaxed_equal(self.waves[i], wave, bad, getattr(st, "x_window_end", 0))
                relaxed_all &= rel
                if res.mismatch is None or (not rel and not hard_recorded):
                    hard_recorded = not rel
                    res.bad_outputs = bad
                    res.mismatch = first_mismatch(self.waves[i], wave, bad, ins)
                    if res.mismatch is not None:
                        res.mismatch["stimulus"] = st.kind
                        res.mismatch["cycle"] = _cycle_of(res.mismatch.get("time", 0), self.info)
                        if res.mismatch.get("kind") == "value":
                            extra = []
                            for t in value_mismatch_times(self.waves[i], wave, bad):
                                if t != res.mismatch["time"]:
                                    snap = snapshot(self.waves[i], wave, t, ins, outs)
                                    snap["cycle"] = _cycle_of(t, self.info)
                                    extra.append(snap)
                                if len(extra) >= 2:
                                    break
                            res.mismatch["more"] = extra
                if not rel:
                    break          # a real functional difference: no need to simulate further
            try:
                os.remove(vcd)
            except OSError:
                pass
        res.ok = strict_all
        res.relaxed_ok = (not strict_all) and relaxed_all
        return res


def replay_trace(cfg, info, gold_files, opt_files, trace, workdir, timeout=120):
    """Replay a formal counter-example in 4-state simulation. Returns (confirmed, mismatch)."""
    from .tbgen import Stim
    clocks = set(info.clocks)
    names = [n for n in info.inputs() if n not in clocks]
    widths = [info.ports[n][1] for n in names]
    if not trace:
        return False, None
    steps = list(trace) + [trace[-1]] * 3
    vectors = []
    for step in steps:
        v = 0
        for n, w in zip(names, widths):
            v = (v << w) | (int(step.get(n, 0)) & ((1 << w) - 1))
        vectors.append(v)
    st = Stim(names, widths, vectors, "formal-cex")
    st.x_window_end = 12000
    gs = GoldSim(cfg, info, gold_files, [st], workdir, timeout)
    if not gs.prepare():
        return False, None
    r = gs.check(opt_files, "replay")
    if r.ok or r.error or r.relaxed_ok:
        return False, None
    return True, r.mismatch


def relaxed_equal(gold, opt, bad, x_window_end):
    """True if the outputs in `bad` differ only by zero-width re-dump events, or by X-vs-value
    differences strictly before `x_window_end` (power-up X before the reset sequence finished)."""
    from .vcd import _settled, value_at
    for name in bad:
        gs, os_ = _settled(gold.get(name, [])), _settled(opt.get(name, []))
        if gs == os_:
            continue
        for t in sorted(set(t for t, _ in gs) | set(t for t, _ in os_)):
            gv, ov = value_at(gs, t), value_at(os_, t)
            if gv != ov and (t >= x_window_end or ("x" not in gv and "x" not in ov)):
                return False
    return True


def _cycle_of(t_ps, info):
    # timescale 1ns/1ps -> VCD time unit is ps; reference clock period = 10 ns
    if not info.is_sequential:
        return None
    return int(t_ps // 10000)
