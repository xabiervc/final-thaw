from __future__ import annotations

import json
from pathlib import Path
from typing import Any

REQUIRED_EVIDENCE_KEYS = {"run_id", "task_id", "status", "artifacts", "verification", "limitations"}


def validate_evidence(evidence: dict[str, Any]) -> list[str]:
    errors = [f"missing key: {key}" for key in sorted(REQUIRED_EVIDENCE_KEYS - evidence.keys())]
    if evidence.get("status") == "complete" and not evidence.get("verification"):
        errors.append("complete evidence requires verification")
    if not isinstance(evidence.get("limitations", []), list):
        errors.append("limitations must be a list")
    return errors


def main() -> None:
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("evidence")
    args = parser.parse_args()
    evidence = json.loads(Path(args.evidence).read_text(encoding="utf-8"))
    errors = validate_evidence(evidence)
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        raise SystemExit(1)
    print("Evidence valid")


if __name__ == "__main__":
    main()
