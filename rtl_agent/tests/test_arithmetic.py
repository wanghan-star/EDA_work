"""Recognizer boundaries and real HDL oracle checks (no LLM or API needed)."""
import pathlib
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from agent.arithmetic import candidates
from agent.specialize import preserve_parameters

SOURCE = """module dut #(parameter W=3)(input [W-1:0] a,b, input ci, output [W:0] y);
assign y = a + b + ci;
endmodule
"""


class RecognizerTests(unittest.TestCase):
    def test_preserves_parameters_and_comments(self):
        src = SOURCE.replace("assign y", "// a + b + ci;\nassign y")
        variants = list(candidates(src, "dut"))
        self.assertEqual(len(variants), 3)
        for _, text in variants:
            self.assertIn("parameter W=3", text)
            self.assertIn("// a + b + ci;", text)

    def test_unsupported_syntax_is_not_rewritten(self):
        for src in (SOURCE.replace("input ci", "input [1:0] ci"),
                    SOURCE.replace("input [W-1:0]", "input signed [W-1:0]"),
                    SOURCE.replace("+ ci;", "+ ci + a;"),
                    SOURCE + "module extra; endmodule\n",
                    SOURCE.replace("input ci", "input [W-1:0] ci")):
            self.assertEqual(list(candidates(src, "dut")), [])

    def test_specialization_refuses_unknown_defaults(self):
        self.assertIsNone(preserve_parameters(SOURCE, SOURCE, "dut", {"W": "xx"}, ["a", "b", "ci", "y"]))


@unittest.skipUnless(shutil.which("iverilog") and shutil.which("vvp"), "requires Icarus Verilog")
class HDLOracleTests(unittest.TestCase):
    def simulate(self, src, tb):
        with tempfile.TemporaryDirectory(prefix="rtl_arithmetic_") as td:
            td = pathlib.Path(td)
            (td / "design.v").write_text(src)
            (td / "tb.v").write_text(tb)
            p = subprocess.run(["iverilog", "-g2012", "-s", "tb", "-o", str(td / "sim"),
                                str(td / "design.v"), str(td / "tb.v")], capture_output=True, text=True, timeout=30)
            self.assertEqual(p.returncode, 0, p.stderr)
            p = subprocess.run(["vvp", str(td / "sim")], capture_output=True, text=True, timeout=30)
            self.assertEqual(p.returncode, 0, p.stdout + p.stderr)
            self.assertIn("PASS", p.stdout)

    def test_parameterized_adders_against_builtin_addition(self):
        for strategy, text in candidates(SOURCE, "dut"):
            for width in (1, 3, 5, 8, 9, 16):
                with self.subTest(strategy=strategy, width=width):
                    # Exhaustive small widths; deterministic random wide inputs,
                    # plus all-ones + carry to expose truncation/overflow errors.
                    n = 1 << (2 * width + 1) if width <= 5 else 1000
                    self.simulate(text, f"""module tb;
reg [{width}-1:0] a,b; reg ci; wire [{width}:0] y;
reg [{width}:0] expected; integer i; integer seed=734;
dut #(.W({width})) d(a,b,ci,y);
initial begin
for(i=0;i<{n};i=i+1) begin
  if ({width} <= 5) {{a,b,ci}}=i;
  else begin a=$random(seed); b=$random(seed); ci=$random(seed); end
  expected={{1'b0,a}}+b+ci; #1;
  if(y !== expected) $fatal(1,"carry mismatch");
end
a='1; b='1; ci=1; expected={{1'b0,a}}+b+ci; #1;
if(y !== expected) $fatal(1,"overflow mismatch");
$display("PASS"); $finish;
end
endmodule""")

    @unittest.skipUnless(shutil.which("yosys"), "requires Yosys")
    def test_inline_guard_does_not_hide_depth_behind_a_wrapper(self):
        from agent.config import Config
        from agent.synth import synth_eval, course_eval
        cfg = Config()
        if not pathlib.Path(cfg.lib_file).is_file():
            self.skipTest("requires Nangate45 liberty")
        fixed = "module dut(input [2:0] a,b,input ci,output [3:0] y); assign y=a+b+ci; endmodule"
        ports = {n: {"direction": "output" if n == "y" else "input", "bits": list(range(w))}
                 for n, w in (("a", 3), ("b", 3), ("ci", 1), ("y", 4))}
        text = preserve_parameters(fixed, SOURCE, "dut", {"W": format(3, "032b")}, ports)
        with tempfile.TemporaryDirectory(prefix="guard_score_") as td:
            path = pathlib.Path(td) / "dut.v"
            path.write_text(text)
            flat = synth_eval(cfg, [str(path)], "dut")
            literal = course_eval(cfg, [str(path)], "dut")
        self.assertTrue(flat.ok and literal.ok, flat.error + literal.error)
        self.assertGreater(flat.ltp, 1)
        self.assertEqual((flat.area, flat.ltp), (literal.area, literal.ltp))

    def test_specialized_netlist_default_and_overrides(self):
        fixed = "module dut(input [2:0] a,b,input ci,output [3:0] y); assign y=a+b+ci; endmodule"
        for source in (SOURCE, """module dut #(parameter W=3)(a,b,ci,y);
input [W-1:0] a,b; input ci; output [W:0] y;
assign y=a+b+ci; endmodule"""):
            ports = {n: {"direction": "output" if n == "y" else "input", "bits": list(range(w))}
                     for n, w in (("a", 3), ("b", 3), ("ci", 1), ("y", 4))}
            text = preserve_parameters(fixed, source, "dut", {"W": format(3, "032b")}, ports)
            self.assertIsNotNone(text)
            for width in (3, 5, 9):
                with self.subTest(width=width):
                    self.simulate(text, f"""module tb;
reg [{width}-1:0] a,b; reg ci; wire [{width}:0] y;
dut #(.W({width})) d(a,b,ci,y);
initial begin a='1; b='1; ci=1; #1;
if(y !== {{1'b1,{{{width}{{1'b1}}}}}}) $fatal(1,"parameter override broken");
$display("PASS"); $finish; end
endmodule""")


if __name__ == "__main__":
    unittest.main()
