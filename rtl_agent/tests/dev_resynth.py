"""Dev experiment: zero-token ABC re-synthesis candidates + full verification, per case."""
import os, sys, glob, tempfile, time
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from agent.config import Config
from agent.synth import analyze, synth_eval
from agent.verify import Verifier
from agent.resynth import resynth, DEFAULT_SET
from agent.verilog_utils import detect_top
from agent.util import write_text

cfg = Config()
for d in sys.argv[1:]:
    f = sorted(glob.glob(os.path.join(d, "*.v")))[0]
    src = open(f).read(); top = detect_top(src)
    info, _ = analyze(cfg, [f], top, src)
    base = synth_eval(cfg, [f], top)
    wd = tempfile.mkdtemp(prefix="rs_")
    v = Verifier(cfg, info, [f], wd); ok, err = v.prepare()
    if not ok:
        print("gold prepare failed:", err); continue
    print(f"== {os.path.basename(d)}: base area {base.area:.1f} ltp {base.ltp}")
    for s in DEFAULT_SET:
        t = time.time()
        text, msg = resynth(cfg, [f], top, os.path.join(wd, s), script=s, seconds=10, orig_src=src)
        if not text:
            print(f"   {s}: resynth failed {msg[-200:]}"); continue
        p = os.path.join(wd, s + "_out.v"); write_text(p, text)
        r = synth_eval(cfg, [p], top)
        vr = v.verify([p], s)
        print(f"   {s:12s} area {r.area:.1f} ({(r.area/base.area-1)*100:+.1f}%) ltp {r.ltp} | {'OK' if vr.ok else 'FAIL@'+vr.stage} {vr.evidence()[:90]} | {time.time()-t:.0f}s")
        if not vr.ok and vr.mismatch:
            m = vr.mismatch; print(f"      first mismatch: {m.get('kind')} {m.get('signal')} t={m.get('time')} gold={m.get('gold')} opt={m.get('opt')} ({m.get('stimulus')})")
