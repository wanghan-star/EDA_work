"""Dev check: verification pipeline must accept equivalent and reject buggy designs."""
import os, sys, time, tempfile
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from agent.config import Config
from agent.synth import analyze, synth_eval
from agent.verify import Verifier

cfg = Config()
gold, top = os.path.abspath(sys.argv[1]), sys.argv[2]
src = open(gold).read()
info, err = analyze(cfg, [gold], top, src)
print("INFO:", info.summary() if info else err)
wd = tempfile.mkdtemp(prefix="rtlv_")
v = Verifier(cfg, info, [gold], wd)
t = time.time(); ok, e = v.prepare(); print("gold sim prepared:", ok, e, "%.1fs" % (time.time() - t), "event-sensitive:", v.event_sensitive)
for i, cand in enumerate(sys.argv[3:]):
    cand = os.path.abspath(cand)
    t = time.time()
    r = v.verify([cand], f"c{i}")
    s = synth_eval(cfg, [cand], top)
    print(f"{os.path.basename(cand):28s} ok={r.ok} stage={r.stage} {r.evidence()} | area={s.area} ltp={s.ltp} | {time.time()-t:.1f}s")
    if not r.ok:
        print("    msg:", r.message[:300].replace("\n", " | "))
        if r.mismatch: print("    mismatch:", {k: r.mismatch[k] for k in list(r.mismatch)[:6]})
