#!/usr/bin/env python3
"""Copy a reviewable result snapshot, excluding prompts and temporary work.

python3 tools/export_results.py runs/validated_public results/public
"""
import argparse
import json
from pathlib import Path
import shutil
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from agent.verify import ACCEPTED_FORMAL  # noqa: E402


def export(source, destination):
    source, destination = Path(source).resolve(), Path(destination).resolve()
    if source == destination or source in destination.parents or destination in source.parents:
        raise ValueError("source and destination must be separate directory trees")
    cases = sorted(source.glob("*/result.json"))
    if not cases:
        raise ValueError(f"no results found in {source}")
    # Validate the whole snapshot before copying anything.
    for path in cases:
        d = json.loads(path.read_text(encoding="utf-8"))
        if d["status"] == "optimized":
            v = d.get("verification") or {}
            # snapshots written before the policy field existed were produced under --accept proved
            policy = (d.get("policy") or {}).get("accept", "proved")
            status = (v.get("formal") or {}).get("status")
            if status not in ACCEPTED_FORMAL.get(policy, ("proved",)):
                raise ValueError(f"{path.parent.name}: optimized result has no formal proof accepted under "
                                 f"--accept {policy} (formal status: {status})")
            if not (v.get("ok") or (d.get("tier") == "relaxed" and v.get("relaxed"))):
                raise ValueError(f"{path.parent.name}: optimized result has no accepted verification")
            b, o = d["baseline"], d["optimized"]
            if not (o["area"] < b["area"] and o["ltp"] <= b["ltp"]):
                raise ValueError(f"{path.parent.name}: optimized metrics do not meet constraints")
        required = ["result.json", "report.md"]
        if d["status"] != "error":
            required.append("optimized.v")
        for name in required:
            if not (path.parent / name).is_file():
                raise ValueError(f"{path.parent.name}: missing {name}")
    if destination.exists() and any(destination.iterdir()):
        raise ValueError("destination must be empty; use a new snapshot directory")
    destination.mkdir(parents=True, exist_ok=True)
    for path in cases:
        target = destination / path.parent.name
        target.mkdir()
        for name in ("result.json", "report.md", "optimized.v"):
            if (path.parent / name).is_file():
                shutil.copy2(path.parent / name, target / name)
    for name in ("summary.json", "summary.md"):
        if (source / name).is_file():
            shutil.copy2(source / name, destination / name)
    return len(cases)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("source")
    ap.add_argument("destination")
    args = ap.parse_args()
    try:
        count = export(args.source, args.destination)
    except (OSError, ValueError, KeyError, TypeError) as exc:
        ap.error(str(exc))
    print(f"Exported {count} cases to {args.destination}")


if __name__ == "__main__":
    main()
