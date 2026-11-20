"""Hierarchical designs: the unflattened course reading must not regress, and re-synthesis keeps
the module hierarchy (no LLM or API needed; EDA checks are skipped without the tools)."""
import pathlib
import random
import shutil
import subprocess
import sys
import tempfile
import unittest
from types import SimpleNamespace as NS

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from agent import optimizer
from agent.resynth import per_module, without_module
from agent.specialize import preserve_parameters

TOP = """module hier_top(input clk, input rst, input [7:0] a, b, output reg [7:0] q);
  wire [7:0] y;
  sat_add u (.a(a), .b(b), .y(y));
  always @(posedge clk) if (rst) q <= 8'd0; else q <= y;
endmodule
"""
SUB = """module sat_add(input [7:0] a, b, output [7:0] y);
  wire [8:0] s = a + b;
  assign y = (s > 9'd255) ? 8'hff : (s[8] ? 8'hff : s[7:0]);
endmodule
"""
PSUB = SUB.replace("module sat_add(", "module sat_add #(parameter W = 8)(")

FIFO_HEADER = """`timescale 1ns/1ns
module ram #(parameter DEPTH = 16)(input clk, input [3:0] a, output reg [7:0] d);
endmodule
module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(input clk, input [WIDTH-1:0] din, output [WIDTH-1:0] dout);
parameter ADDR_WIDTH = $clog2(DEPTH);
ram #(.DEPTH(DEPTH)) ram (.clk(clk), .a(din[3:0]), .d(dout));
endmodule
"""


def guard_state(base_course, info_subs=("sub",)):
    st = optimizer.OptState.__new__(optimizer.OptState)
    st.budget = optimizer.Budget()
    st.base = NS(ok=True, area=72.6, ltp=39)
    st.base_course = base_course
    st.info = NS(submodules=list(info_subs))
    return st


class CourseGuardTests(unittest.TestCase):
    def test_guard_only_for_hierarchical_or_divergent_readings(self):
        same = NS(ok=True, area=72.6, ltp=39, hier_area=None)
        self.assertFalse(guard_state(same, info_subs=()).course_guarded())
        self.assertTrue(guard_state(same).course_guarded())
        st = guard_state(NS(ok=True, area=54.264, ltp=36, hier_area=67.032), info_subs=())
        self.assertTrue(st.course_guarded())
        st.budget.course_guard = False
        self.assertFalse(st.course_guarded())

    def test_flattened_gain_that_regresses_literal_reading_is_rejected(self):
        st = guard_state(NS(ok=True, area=54.264, ltp=36, hier_area=67.032))
        # the old asyn_fifo result: better flattened, worse in every unflattened reading
        why = st.course_problem(NS(ok=True, area=67.564, ltp=37, hier_area=67.564))
        self.assertIn("literal area", why)
        self.assertIn("literal ltp", why)
        self.assertIn("hierarchy area", why)
        self.assertIsNone(st.course_problem(NS(ok=True, area=54.264, ltp=36, hier_area=66.0)))
        self.assertIn("hierarchy area", st.course_problem(NS(ok=True, area=50.0, ltp=30, hier_area=68.0)))
        self.assertIn("failed", st.course_problem(NS(ok=False, error="boom")))


class TextTests(unittest.TestCase):
    def test_per_module_and_module_removal(self):
        text = "/* hdr */\n" + SUB + TOP
        out = per_module(text, lambda m: m.replace("endmodule", "endmodule // seen"))
        self.assertEqual(out.count("// seen"), 2)
        self.assertTrue(out.startswith("/* hdr */"))
        rest = without_module("`timescale 1ns/1ps\n" + SUB + TOP, "hier_top")
        self.assertIn("module sat_add", rest)
        self.assertNotIn("hier_top", rest)
        self.assertIn("`timescale", rest)

    def test_guard_accepts_timescale_and_local_body_parameter(self):
        net = ("module fifo(clk, din, dout);\ninput clk; input [7:0] din; output [7:0] dout;\n"
               "ram #(.DEPTH(32'd16)) ram (.clk(clk), .a(din[3:0]), .d(dout));\nendmodule\n")
        ports = {"clk": {"direction": "input", "bits": [0]},
                 "din": {"direction": "input", "bits": list(range(8))},
                 "dout": {"direction": "output", "bits": list(range(8))}}
        defaults = {"WIDTH": format(8, "032b"), "DEPTH": format(16, "032b"),
                    "ADDR_WIDTH": format(4, "032b")}
        text = preserve_parameters(net, FIFO_HEADER, "fifo", defaults, ports)
        self.assertIsNotNone(text)
        self.assertNotIn("ADDR_WIDTH ===", text)          # local: not part of the override test
        self.assertNotIn(".ADDR_WIDTH(", text)
        self.assertIn(".clk(", text)                       # submodule pins are not renamed
        self.assertIn("parameter ADDR_WIDTH = $clog2(DEPTH);", text)
        # a real macro still fails closed
        self.assertIsNone(preserve_parameters(net, "`define W 8\n" + FIFO_HEADER, "fifo", defaults, ports))


def _tools():
    from agent.config import Config
    cfg = Config()
    ok = all(shutil.which(t) for t in ("yosys", "iverilog", "vvp")) and pathlib.Path(cfg.lib_file).is_file()
    return cfg if ok else None


@unittest.skipUnless(_tools(), "requires Yosys, Icarus Verilog and the Nangate45 liberty")
class HierResynthTests(unittest.TestCase):
    def run_resynth(self, src):
        from agent.resynth import resynth
        cfg = _tools()
        td = tempfile.mkdtemp(prefix="rtl_hier_")
        self.addCleanup(shutil.rmtree, td, True)
        gold = pathlib.Path(td) / "gold.v"
        gold.write_text(src)
        text, msg = resynth(cfg, [str(gold)], "hier_top", str(pathlib.Path(td) / "w"), script="dc2x3",
                            seconds=5, orig_src=src, hier=True)
        self.assertIsNotNone(text, msg)
        opt = pathlib.Path(td) / "opt.v"
        opt.write_text(text)
        return cfg, gold, opt, text

    def simulate_equal(self, gold, opt):
        rnd = random.Random(7)
        vec = "\n".join(f"  a = 8'd{rnd.randrange(256)}; b = 8'd{rnd.randrange(256)}; #10;" for _ in range(64))
        tb = (f"module tb; reg clk = 0, rst = 1; reg [7:0] a = 0, b = 0; wire [7:0] q;\n"
              f"hier_top dut(.clk(clk), .rst(rst), .a(a), .b(b), .q(q));\n"
              f"always #5 clk = ~clk;\ninitial begin #12 rst = 0;\n{vec}\n$finish; end\n"
              f"always @(negedge clk) $display(\"%0t %b\", $time, q);\nendmodule\n")
        outs = []
        for design in (gold, opt):
            d = design.parent
            (d / "tb.v").write_text(tb)
            sim = d / (design.stem + ".vvp")
            p = subprocess.run(["iverilog", "-g2012", "-o", str(sim), str(d / "tb.v"), str(design)],
                               capture_output=True, text=True, timeout=60)
            self.assertEqual(p.returncode, 0, p.stderr)
            outs.append(subprocess.run(["vvp", str(sim)], capture_output=True, text=True, timeout=60).stdout)
        self.assertEqual(outs[0], outs[1])

    def test_plain_submodule_optimized_in_place(self):
        from agent.synth import course_eval
        cfg, gold, opt, text = self.run_resynth(SUB + TOP)
        self.assertIn("module sat_add", text)
        self.assertIn("module hier_top", text)
        self.assertNotIn("$paramod", text)
        base, cand = course_eval(cfg, [str(gold)], "hier_top"), course_eval(cfg, [str(opt)], "hier_top")
        self.assertTrue(base.ok and cand.ok, base.error + cand.error)
        self.assertIsNotNone(cand.hier_area)
        self.simulate_equal(gold, opt)

    def test_parameterized_submodule_kept_verbatim(self):
        cfg, gold, opt, text = self.run_resynth(PSUB + TOP)
        self.assertIn(PSUB.strip(), text)
        self.simulate_equal(gold, opt)


if __name__ == "__main__":
    unittest.main()
