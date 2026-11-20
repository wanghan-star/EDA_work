"""Failure-path regressions; standard library only, no tools or API required."""
import contextlib
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import time
from types import SimpleNamespace as NS
import unittest
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import run
from agent import optimizer, verify
from agent.config import Config
from agent.formal import FormalResult
from agent.util import run_cmd
from docs.report import make_results
from tools.export_results import export


class VerificationTests(unittest.TestCase):
    def test_parameter_defaults_and_signedness_are_part_of_interface(self):
        v = verify.Verifier.__new__(verify.Verifier)
        v.cfg = NS()
        v.info = NS(top="dut", ports={"a": ("input", 8, False)}, parameters={"W": "1000"})
        for candidate in (NS(ports={"a": ("input", 8, True)}, parameters={"W": "1000"}),
                          NS(ports={"a": ("input", 8, False)}, parameters={"W": "0100"})):
            with patch.object(verify, "analyze", return_value=(candidate, "")):
                self.assertFalse(v.check_ports(["candidate.v"])[0])

    def check(self, status="proved", relaxed=False, confirmed=False, do_formal=True, accept="bounded"):
        info = NS(top="dut", is_sequential=False, ports={})
        sim = NS(ok=not relaxed, relaxed_ok=relaxed, error="", mismatch=None,
                 bad_outputs=["q"] if relaxed else [])
        fr = FormalResult("comb")
        fr.status, fr.message, fr.trace = status, "test evidence", [{"a": 1}]
        with tempfile.TemporaryDirectory() as td, \
                patch.object(verify, "GoldSim") as gold, \
                patch.object(verify, "default_stimuli", return_value=[]), \
                patch.object(verify, "lint", return_value=(True, "", [])), \
                patch.object(verify.Verifier, "check_ports", return_value=(True, "")), \
                patch.object(verify.formal, "prove_comb", return_value=fr), \
                patch.object(verify, "replay_trace", return_value=(confirmed, {})):
            gold.return_value.check.return_value = sim
            v = verify.Verifier(NS(), info, ["gold.v"], td, accept=accept)
            return v.verify(["candidate.v"], "test", do_formal=do_formal)

    def test_proved_policy_rejects_weaker_evidence(self):
        for status in ("unknown", "error", "bounded", "skipped"):
            for relaxed in (False, True):
                with self.subTest(status=status, relaxed=relaxed):
                    r = self.check(status, relaxed, accept="proved")
                    self.assertFalse(r.ok or r.relaxed)
                    self.assertEqual(r.stage, "formal")

    def test_bounded_policy_accepts_bounded_evidence(self):
        for status in ("bounded", "skipped"):
            with self.subTest(status=status):
                self.assertTrue(self.check(status).ok)
                r = self.check(status, relaxed=True)
                self.assertFalse(r.ok)
                self.assertTrue(r.relaxed)

    def test_tool_error_never_accepted(self):
        for accept in ("bounded", "proved"):
            with self.subTest(accept=accept):
                r = self.check("error", accept=accept)
                self.assertFalse(r.ok or r.relaxed)
                self.assertEqual(r.stage, "formal")

    def test_timeout_never_accepted_as_bounded_check(self):
        for relaxed in (False, True):
            r = self.check("unknown", relaxed=relaxed)
            self.assertFalse(r.ok or r.relaxed)
            self.assertEqual(r.stage, "formal")

    def test_proved_strict(self):
        self.assertTrue(self.check().ok)

    def test_proved_relaxed(self):
        r = self.check(relaxed=True)
        self.assertFalse(r.ok)
        self.assertTrue(r.relaxed)

    def test_confirmed_counterexample_never_relaxed(self):
        r = self.check("cex", relaxed=True, confirmed=True)
        self.assertFalse(r.ok or r.relaxed)
        self.assertEqual(r.stage, "sim")

    def test_unreplayed_counterexample_not_proof(self):
        for accept in ("bounded", "proved"):
            with self.subTest(accept=accept):
                r = self.check("cex", accept=accept)
                self.assertFalse(r.ok or r.relaxed)
                self.assertEqual(r.formal.status, "unconfirmed-cex")

    def test_disabled_formal_not_proof(self):
        self.assertFalse(self.check(do_formal=False).ok)


class FinalizationTests(unittest.TestCase):
    def state(self, td, relaxed=False, allow_relaxed=False):
        src = "module dut(input a, output q); assign q=a; endmodule\n"
        rtl = Path(td) / "gold.v"
        rtl.write_text(src)
        cfg = NS(llm_key="", llm_thinking="off")
        st = optimizer.OptState(cfg, str(rtl), "dut", str(Path(td) / "out"),
                                optimizer.Budget(allow_relaxed=allow_relaxed), workdir=td,
                                keep_work=True)
        st.base = NS(ok=True, area=10, ltp=2)
        st.info, st.verifier = NS(), NS()
        c = st.new_cand("test")
        c.status = "relaxed" if relaxed else "verified"
        c.synth = NS(ok=True, area=5, ltp=1)
        c.text, c.file = src + "// candidate\n", "candidate.v"
        return st

    def test_failed_deep_prepare_keeps_original(self):
        with tempfile.TemporaryDirectory() as td, \
                patch.object(optimizer, "Verifier") as deep, \
                patch("agent.report.write_reports"):
            st = self.state(td)
            deep.return_value.prepare.return_value = (False, "simulator failed")
            optimizer.node_finalize(st)
            self.assertIsNone(st.final)
            self.assertIn("final reference simulation failed", st.error)
            self.assertEqual(Path(st.outdir, "optimized.v").read_text(), st.src)
            deep.return_value.verify.assert_not_called()

    def test_relaxed_fallback_follows_policy(self):
        for allow in (False, True):
            with self.subTest(allow=allow), tempfile.TemporaryDirectory() as td, \
                    patch.object(optimizer, "Verifier") as deep, \
                    patch.object(optimizer, "course_eval", return_value=NS(area=5, ltp=1)), \
                    patch("agent.report.write_reports"):
                st = self.state(td, relaxed=True, allow_relaxed=allow)
                deep.return_value.prepare.return_value = (True, "")
                deep.return_value.verify.return_value = NS(ok=False, relaxed=True)
                optimizer.node_finalize(st)
                self.assertEqual(st.final is not None, allow)

    def test_repair_respects_remaining_call_budget(self):
        st = NS(cfg=NS(jobs=1), calls_left=lambda: 1, new_cand=Mock(return_value=NS(status="new")),
                thinking_for=lambda _: False, pending=[])
        candidates = [NS(id=str(i), depth=0, strategy="logic", messages=[], response="", problem="")
                      for i in range(2)]
        with patch.object(optimizer, "_repairable", return_value=candidates), \
                patch.object(optimizer.prompts, "repair_user", return_value="repair"), \
                patch.object(optimizer, "_call") as call:
            optimizer.node_repair(st)
            self.assertEqual(call.call_count, 1)


class CLITests(unittest.TestCase):
    def invoke(self, args):
        with patch.object(sys, "argv", ["run.py"] + args), \
                contextlib.redirect_stderr(io.StringIO()), \
                contextlib.redirect_stdout(io.StringIO()):
            return run.main()

    def test_missing_and_conflicting_input(self):
        for args in ([], ["--rtl", "missing.v"],
                     ["--rtl", "x.v", "--batch", "cases"]):
            with self.subTest(args=args), self.assertRaises(SystemExit) as err:
                self.invoke(args)
            self.assertEqual(err.exception.code, 2)

    def test_empty_batch_rejected(self):
        with tempfile.TemporaryDirectory() as td, self.assertRaises(SystemExit) as err:
            self.invoke(["--batch", td])
        self.assertEqual(err.exception.code, 2)

    def test_discovery_avoids_collisions_and_outputs(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            for rel in ("a/same/dut.v", "b/same/dut.v", "out/optimized.v", "tb_dut.v"):
                p = root / rel
                p.parent.mkdir(parents=True, exist_ok=True)
                p.write_text("module dut(input a, output q); assign q=a; endmodule")
            cases = run.batch_cases(td, str(root / "out"))
            self.assertEqual(len(cases), 2)
            self.assertEqual(len({name for _, name in cases}), 2)

    def test_batch_continues_and_returns_failure(self):
        with tempfile.TemporaryDirectory() as td, patch.object(run, "Config") as cfg, \
                patch.object(run, "run_one") as one:
            root = Path(td)
            for name in ("a.v", "b.v"):
                (root / name).write_text("module dut(input a, output q); assign q=a; endmodule")
            cfg.return_value.check_tools.return_value = []
            one.side_effect = [OSError("unreadable input"),
                               NS(base=None, final=None, final_verify=None, final_tier=None,
                                  error="", top="dut", elapsed=lambda: 1,
                                  usage=NS(to_dict=lambda: {"total_tokens": 0, "calls": 0}))]
            code = self.invoke(["--batch", td, "--out", str(root / "out"), "--offline"])
            self.assertEqual(code, 1)
            self.assertEqual(one.call_count, 2)
            self.assertTrue((root / "out" / "summary.json").is_file())
            self.assertEqual(cfg.return_value.llm_key, "")

    def test_input_cannot_be_overwritten(self):
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "optimized.v"
            p.write_text("module dut(input a, output q); assign q=a; endmodule")
            with self.assertRaises(SystemExit) as err:
                self.invoke(["--rtl", str(p), "--out", td])
            self.assertEqual(err.exception.code, 2)

    def test_config_never_displays_key_prefix(self):
        cfg = Config.__new__(Config)
        cfg.llm_key = "sensitive-value"
        self.assertEqual(cfg.masked_key(), "<configured>")

    def test_negative_call_limit_rejected(self):
        with self.assertRaises(SystemExit):
            self.invoke(["--rtl", "x.v", "--max-calls", "-1"])


class CourseAuditTests(unittest.TestCase):
    def test_required_stimulus_failure_is_fatal(self):
        from agent import simcheck
        for simulated, waves in (((False, "bad stimulus", 0), {}), ((True, "", 0), {})):
            with self.subTest(simulated=simulated), tempfile.TemporaryDirectory() as td, \
                    patch.object(simcheck, "_simulate", return_value=simulated), \
                    patch.object(simcheck, "parse_vcd", return_value=waves):
                path = Path(td) / "stim.v"
                path.write_text("module tb; endmodule")
                gold = simcheck.GoldSim(NS(), NS(outputs=lambda: ["q"]), ["gold.v"],
                                       [simcheck.CourseTB(str(path))], td)
                self.assertFalse(gold.prepare())
                self.assertIn("required course-tb", gold.error)

    def test_missing_case_cannot_pass_audit(self):
        from tools.course_check import audit
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            case = root / "cases" / "one"
            case.mkdir(parents=True)
            (case / "dut.v").write_text("module dut; endmodule")
            demo = root / "demo"
            demo.mkdir()
            (demo / "equiv_agent.py").write_text("# fixture")
            with contextlib.redirect_stdout(io.StringIO()):
                result = audit(NS(yosys="yosys", iverilog="iverilog", vvp="vvp"),
                               root / "cases", root / "results", demo)
            self.assertFalse(result["passed"])
            self.assertFalse(result["complete"])
            self.assertEqual(result["cases"][0]["verdict"], "ERROR")

    def test_synthesis_failure_cannot_become_missing_metrics_pass(self):
        from tools import course_check
        with patch.object(course_check, "run_cmd", return_value=(1, "", "failed", 0)):
            with self.assertRaises(ValueError):
                course_check.demo_score(NS(yosys="yosys", lib_file="a b.lib"), "a b.v", "dut")


class BudgetTests(unittest.TestCase):
    def test_rescue_cannot_exceed_hard_call_limit(self):
        st = NS(budget=optimizer.Budget(max_calls=20, call_limit=3), usage=NS(logical_calls=3))
        self.assertEqual(optimizer.OptState.calls_left(st), 0)

    def test_output_token_setting_is_respected(self):
        st = NS(cfg=NS(llm_max_tokens=1024), llm=Mock())
        candidate = NS(messages=[], id="c01", strategy="test")
        optimizer._call(st, candidate, thinking=False)
        self.assertEqual(st.llm.chat.call_args.kwargs["max_tokens"], 1024)


class SelectionTests(unittest.TestCase):
    def fixture(self, root, name, tokens, input_hash="same", earlier=()):
        folder = root / name / "case"
        folder.mkdir(parents=True)
        d = {"status": "no-gain", "baseline": {"area": 10, "ltp": 2},
             "optimized": {"area": 10, "ltp": 2}, "usage": {"total_tokens": tokens},
             "runtime_s": 1, "reproducibility": {"input_sha256": input_hash},
             "runs_compared": list(earlier)}
        (folder / "result.json").write_text(json.dumps(d))
        (folder / "report.md").write_text("report")
        (folder / "optimized.v").write_text("module dut; endmodule")
        return root / name

    def test_reports_losing_run_costs_and_historical_gaps(self):
        from tools.select_results import select
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            a = self.fixture(root, "a", 100, earlier=("old1", "old2"))
            b = self.fixture(root, "b", 0)
            result = select([a, b], root / "out")["cases"][0]
            self.assertEqual(result["observed_search_tokens"], 100)
            self.assertFalse(result["search_costs_complete"])
            self.assertEqual(sum(r["selected"] for r in result["runs"]), 1)
            saved = json.loads((root / "out/case/result.json").read_text())
            self.assertEqual(saved["usage"]["total_tokens"], 0)

    def test_rejects_different_inputs_before_writing(self):
        from tools.select_results import select
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            a = self.fixture(root, "a", 10)
            b = self.fixture(root, "b", 0, input_hash="changed")
            with self.assertRaisesRegex(ValueError, "different input hashes"):
                select([a, b], root / "out")
            self.assertFalse((root / "out").exists())


class ReportTests(unittest.TestCase):
    def test_failed_case_renders_in_both_formats(self):
        with tempfile.TemporaryDirectory() as td:
            with contextlib.redirect_stderr(io.StringIO()):
                run.failure_result("missing.v", str(Path(td) / "case_1&bad"), OSError("test"))
            for render in (make_results.main_md, make_results.main_tex):
                out = io.StringIO()
                with contextlib.redirect_stdout(out):
                    render([td])
                self.assertIn("运行失败", out.getvalue())
                self.assertNotIn("无正收益", out.getvalue())

    def test_null_metrics_do_not_crash(self):
        self.assertEqual(make_results.pct(10, None), "--")
        self.assertEqual(make_results.number(None), "--")
        self.assertEqual(make_results.latex_escape("case_1&x"), r"case\_1\&x")

    def write_case(self, case, formal_status, accept=None):
        case.mkdir(parents=True)
        d = {"status": "optimized", "tier": "strict",
             "verification": {"ok": True, "relaxed": False, "formal": {"status": formal_status}},
             "baseline": {"area": 10.0, "ltp": 5}, "optimized": {"area": 8.0, "ltp": 5}}
        if accept:
            d["policy"] = {"accept": accept, "allow_relaxed": True}
        (case / "result.json").write_text(json.dumps(d))
        (case / "report.md").write_text("# r\n")
        (case / "optimized.v").write_text("module m; endmodule\n")

    def test_export_follows_recorded_policy(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            self.write_case(root / "runs" / "case", "bounded", accept="bounded")
            self.assertEqual(export(root / "runs", root / "results"), 1)
        for status in ("error", "cex"):
            with self.subTest(status=status), tempfile.TemporaryDirectory() as td:
                root = Path(td)
                self.write_case(root / "runs" / "case", status, accept="bounded")
                with self.assertRaisesRegex(ValueError, "no formal proof accepted"):
                    export(root / "runs", root / "results")

    def test_export_rejects_unproved_optimization(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            case = root / "runs" / "case"
            case.mkdir(parents=True)
            (case / "result.json").write_text(json.dumps({
                "status": "optimized", "verification": {"formal": {"status": "unknown"}}}))
            with self.assertRaisesRegex(ValueError, "no formal proof"):
                export(root / "runs", root / "results")
            self.assertFalse((root / "results").exists())


class ProcessTests(unittest.TestCase):
    def test_subprocess_input_and_output(self):
        rc, out, err, _ = run_cmd([sys.executable, "-c", "print(input().upper())"],
                                 input_text="hello\n", timeout=5)
        self.assertEqual((rc, out.strip(), err), (0, "HELLO", ""))

    @unittest.skipUnless(os.name == "posix", "EDA child-process cleanup targets Linux/WSL")
    def test_timeout_kills_child_holding_output_pipe(self):
        code = ("import subprocess,sys,time; "
                "p=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)']); "
                "print(p.pid,flush=True); time.sleep(30)")
        start = time.monotonic()
        rc, out, err, _ = run_cmd([sys.executable, "-c", code], timeout=0.5)
        self.assertEqual(rc, -9)
        self.assertIn("[TIMEOUT]", err)
        self.assertLess(time.monotonic() - start, 5)
        pid = int(out.strip())
        stat = Path(f"/proc/{pid}/stat")
        # A killed child may remain briefly as a zombie until init reaps it.
        if stat.exists():
            self.assertEqual(stat.read_text().split()[2], "Z")


class ToolchainCompatTests(unittest.TestCase):
    """Course layout (opti_demo 2026-11) and old-toolchain (Ubuntu 22.04: Yosys 0.9) fixes."""

    def test_official_layout_testbench_and_case_name(self):
        with tempfile.TemporaryDirectory() as td:
            case = Path(td) / "case" / "case3"
            (Path(td) / "case" / "tb").mkdir(parents=True)
            case.mkdir()
            (case / "rtl.v").write_text("module m(input a, output y); assign y = a; endmodule\n")
            tb = Path(td) / "case" / "tb" / "case3_tb.v"
            tb.write_text("module tb; endmodule\n")
            (Path(td) / "case" / "tb" / "case30_tb.v").write_text("module tb; endmodule\n")
            self.assertEqual(run.course_testbenches(str(case / "rtl.v")), [str(tb.resolve())])
            self.assertEqual(run.default_case_name(str(case / "rtl.v")), "case3")
            self.assertEqual(run.default_case_name("x/adder.v"), "adder")
            names = [n for _f, n in run.batch_cases(str(Path(td) / "case"), str(Path(td) / "out"))]
            self.assertEqual(names, ["case3"])

    def test_single_block_declares_bare_output_ports(self):
        from agent.resynth import to_single_block, T0_KICK
        net = ("module m(a, b, y);\n  wire _0_;\n  input a;\n  input b;\n  output [1:0] y;\n"
               "  assign y[1] = _0_ | b;\n  assign _0_ = a & b;\n  assign y[0] = ~_0_;\nendmodule\n")
        out = to_single_block(net)
        self.assertIn("  reg [1:0] y;", out)
        self.assertIn("reg _0_;", out)
        body = out[out.index("always @*"):]
        self.assertLess(body.index("_0_ = a & b"), body.index("y[1] = _0_ | b"))
        self.assertIn("`ifndef SYNTHESIS", out)
        self.assertIn(T0_KICK, out)
        from agent.verilog_utils import sanity_issues
        self.assertEqual(sanity_issues(out, "m", net), [])

    def test_legacy_abc_gets_aliases_and_gate_mapping(self):
        from agent import resynth
        legacy = NS(yosys_abc="legacy-abc", modern_yosys=lambda: False)
        modern = NS(yosys_abc="modern-abc", modern_yosys=lambda: True)
        with patch.dict(resynth._ALIAS_PROBE, {"legacy-abc": True, "modern-abc": False}):
            old = resynth.abc_script_text(legacy, "deep", 10).splitlines()
            new = resynth.abc_script_text(modern, "deep", 10).splitlines()
        self.assertTrue(old[0].startswith("alias b balance"))
        self.assertTrue(any(ln.startswith("alias compress2rs") for ln in old))
        self.assertEqual(old[-1], "map")
        self.assertEqual(new, ["strash", "&get -n", "&deepsyn -I 1 -J 150 -T 10", "&put"])

    def test_parameter_names_from_source(self):
        from agent.synth import _top_param_names
        with tempfile.TemporaryDirectory() as td:
            f = Path(td) / "p.v"
            f.write_text("module p #(parameter Q = 15, parameter N = 32)(input [N-1:0] a, output y);\n"
                         "  localparam L = 2; parameter integer K = 3, J = 4;\n  assign y = a[0];\n"
                         "endmodule\nmodule other #(parameter Z = 1)(); endmodule\n")
            self.assertEqual(_top_param_names([str(f)], "p"), ["Q", "N", "K", "J"])


if __name__ == "__main__":
    unittest.main()
