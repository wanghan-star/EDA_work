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
        for status in ("bounded", "skipped", "unknown"):
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
                    patch("agent.report.write_reports"):
                st = self.state(td, relaxed=True, allow_relaxed=allow)
                deep.return_value.prepare.return_value = (True, "")
                deep.return_value.verify.return_value = NS(ok=False, relaxed=True)
                optimizer.node_finalize(st)
                self.assertEqual(st.final is not None, allow)

    def test_repair_respects_remaining_call_budget(self):
        st = NS(calls_left=lambda: 1, new_cand=Mock(return_value=NS(status="new")),
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


if __name__ == "__main__":
    unittest.main()
