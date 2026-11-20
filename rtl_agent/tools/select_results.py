#!/usr/bin/env python3
"""Select verified results across runs, keeping search costs separate from winner costs.

Example: python tools/select_results.py results/public runs/score_offline \
    --out results/score_20261021/public
No LLM prompts/configuration are copied. Run course_check.py on the new snapshot.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from agent.verify import ACCEPTED_FORMAL
from agent.util import write_json


def eligible(d):
    if d.get("status") == "no-gain":
        return True
    if d.get("status") != "optimized":
        return False
    v, p = d.get("verification") or {}, d.get("policy") or {}
    evidence = (v.get("formal") or {}).get("status")
    b, o = d["baseline"], d["optimized"]
    return (evidence in ACCEPTED_FORMAL.get(p.get("accept", "proved"), ("proved",))
            and (v.get("ok") or (p.get("allow_relaxed") and d.get("tier") == "relaxed" and v.get("relaxed")))
            and o["area"] < b["area"] and o["ltp"] <= b["ltp"])


def rank(d):
    b, o = d["baseline"], d["optimized"]
    return (0 if d["status"] == "optimized" else 1,
            0 if d.get("tier") == "strict" else 1,
            .5 * o["area"] / max(b["area"], 1e-9) + .3 * o["ltp"] / max(b["ltp"], 1),
            d["usage"]["total_tokens"], d["runtime_s"])


def select(sources, destination):
    destination = Path(destination).resolve()
    sources = list(dict.fromkeys(Path(p).resolve() for p in sources))
    if destination.exists():
        raise ValueError("destination must not exist; use a new snapshot directory")
    if any(p == destination or p in destination.parents or destination in p.parents for p in sources):
        raise ValueError("source and destination trees must be separate")
    groups = {}
    for source in sources:
        paths = sorted(source.glob("*/result.json"))
        if not paths:
            raise ValueError(f"no result files: {source}")
        for path in paths:
            d = json.loads(path.read_text(encoding="utf-8"))
            groups.setdefault(path.parent.name, []).append((path, d))
    decisions = []
    winners = []
    for case, entries in sorted(groups.items()):
        identity = {(d.get("reproducibility") or {}).get("input_sha256") for _, d in entries}
        if None in identity or len(identity) != 1:
            raise ValueError(f"{case}: missing or different input hashes; cannot compare")
        baselines = {(d["baseline"]["area"], d["baseline"]["ltp"]) for _, d in entries if d.get("status") != "error"}
        if len(baselines) != 1:
            raise ValueError(f"{case}: different baseline metrics; use a consistent toolchain")
        valid = [(p, d) for p, d in entries if eligible(d)]
        if not valid:
            raise ValueError(f"{case}: no accepted output")
        winner, d = min(valid, key=lambda item: rank(item[1]))
        for file in ("optimized.v", "report.md"):
            if not (winner.parent / file).is_file():
                raise ValueError(f"{case}: selected result missing {file}")
        saved_hash = (d.get("reproducibility") or {}).get("output_sha256")
        output_hash = hashlib.sha256((winner.parent / "optimized.v").read_text(encoding="utf-8").encode()).hexdigest()
        if saved_hash and saved_hash != output_hash:
            raise ValueError(f"{case}: selected output changed since verification")
        costs = [{"source": str(p), "result_sha256": hashlib.sha256(p.read_bytes()).hexdigest(),
                  "tokens": r.get("usage", {}).get("total_tokens"), "runtime_s": r.get("runtime_s"),
                  "status": r.get("status"), "selected": p == winner,
                  "earlier_search_costs_incomplete": len(r.get("runs_compared", [])) > 1}
                 for p, r in entries]
        decisions.append({"case": case, "selected_source": str(winner), "output_sha256": output_hash,
                          "observed_search_tokens": sum(r["tokens"] or 0 for r in costs),
                          "observed_search_runtime_s": round(sum(r["runtime_s"] or 0 for r in costs), 1),
                          "search_costs_complete": not any(r["earlier_search_costs_incomplete"] for r in costs),
                          "runs": costs})
        winners.append((case, winner))
    destination.mkdir(parents=True)
    for case, winner in winners:
        target = destination / case
        target.mkdir()
        for file in ("result.json", "report.md", "optimized.v"):
            shutil.copy2(winner.parent / file, target / file)
    manifest = {"selection_rule": "accepted output, strict tier, normalized area/depth, tokens, runtime",
                "cost_note": "Winner runtime/tokens remain unchanged. Observed search costs include all supplied "
                             "records; historical merged snapshots may omit earlier attempts. Runtime sums are "
                             "case elapsed-time sums, not parallel wall time.", "cases": decisions}
    write_json(str(destination / "selection.json"), manifest)
    return manifest


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("sources", nargs="+")
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    try:
        data = select(args.sources, args.out)
    except (OSError, ValueError, KeyError, TypeError) as exc:
        ap.error(str(exc))
    print(f"Selected {len(data['cases'])} cases. Run course_check.py before reporting acceptance.")


if __name__ == "__main__":
    main()
