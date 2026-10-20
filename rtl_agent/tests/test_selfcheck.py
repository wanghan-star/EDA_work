#!/usr/bin/env python3
"""Regression self-check of the verification pipeline (no LLM needed).

Every row: (gold file, candidate text, expected verdict).  The most important row is the
"needle" mutant that differs on exactly ONE input combination out of 2^24: random simulation
will almost surely miss it, so it proves the formal engine is not vacuous.
Run:  python3 tests/test_selfcheck.py
"""

import os
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from agent.config import Config            # noqa: E402
from agent.synth import analyze            # noqa: E402
from agent.verify import Verifier          # noqa: E402

CASES = os.path.join(ROOT, "cases", "public")
DIV = os.path.join(CASES, "case4_div_16bit", "div_16bit.v")
ACCU = os.path.join(CASES, "case5_verified_accu", "verified_accu.v")

DIV_OPT = """module div_16bit(input wire [15:0] A, input wire [7:0] B,
  output wire [15:0] result, output wire [15:0] odd);
  reg [8:0] r; reg [9:0] d; reg [15:0] q; integer i;
  always @(*) begin
    r = 9'd0;
    for (i = 15; i >= 0; i = i - 1) begin
      d = {r[7:0], A[i]} - {2'b00, B};
      if (!d[9]) begin r = d[8:0]; q[i] = 1'b1; end
      else begin r = {r[7:0], A[i]}; q[i] = 1'b0; end
    end
  end
  assign result = (B == 8'd0) ? 16'hFFFF : q;
  assign odd    = (B == 8'd0) ? A : {7'd0, r};
endmodule
"""

DIV_NEEDLE = DIV_OPT.replace("assign result = (B == 8'd0) ? 16'hFFFF : q;",
                             "assign result = (B == 8'd0) ? 16'hFFFF : ((A == 16'h1234 && B == 8'h56) ? ~q : q);")

DIV_PORTS = DIV_OPT.replace("output wire [15:0] odd", "output wire [14:0] odd").replace(
    "assign odd    = (B == 8'd0) ? A : {7'd0, r};", "assign odd    = (B == 8'd0) ? A[14:0] : {6'd0, r};")

ACCU_BUG = open(ACCU).read().replace("count == 3)", "count == 2)") if os.path.isfile(ACCU) else ""


def run():
    cfg = Config()
    rows = [
        (DIV, open(DIV).read(), True, "self-equivalence (comb)"),
        (DIV, DIV_OPT, True, "restructured divider (comb, formal proof)"),
        (DIV, DIV_NEEDLE, False, "needle mutant: 1 of 2^24 inputs differs -> formal must catch"),
        (DIV, DIV_PORTS, False, "port width change"),
        (ACCU, open(ACCU).read(), True, "self-equivalence (seq)"),
        (ACCU, ACCU_BUG, False, "sequential mutant"),
    ]
    infos = {}
    ok_all = True
    for gold, text, expect, name in rows:
        top = "div_16bit" if gold == DIV else "verified_accu"
        if gold not in infos:
            info, err = analyze(cfg, [gold], top, open(gold).read())
            wd = tempfile.mkdtemp(prefix="selfcheck_")
            v = Verifier(cfg, info, [gold], wd)
            ok, err = v.prepare()
            assert ok, err
            infos[gold] = v
        v = infos[gold]
        fd, path = tempfile.mkstemp(suffix=".v")
        with os.fdopen(fd, "w") as fh:
            fh.write(text)
        r = v.verify([path], f"t{len(name)}_{rows.index((gold, text, expect, name))}")
        good = (r.ok == expect)
        ok_all &= good
        print(f"[{'PASS' if good else 'FAIL'}] {name}: verdict={'equivalent' if r.ok else 'rejected@' + r.stage}"
              f"  ({r.evidence()})")
    print("SELF-CHECK", "OK" if ok_all else "FAILED")
    return 0 if ok_all else 1


if __name__ == "__main__":
    sys.exit(run())
