from __future__ import annotations

import json
from pathlib import Path
from typing import Any

DECISIONS = {"approve", "revise", "reject", "escalate"}


def _read_many(paths: list[str]) -> list[dict[str, Any]]:
    return [json.loads(Path(path).read_text(encoding="utf-8")) for path in paths]


def calculate_consensus(
    proposals: list[dict[str, Any]],
    reviews: list[dict[str, Any]],
    round_number: int = 1,
    max_rounds: int = 2,
) -> dict[str, Any]:
    if not proposals or not reviews:
        return _result("escalate", 0.0, "Required proposals or reviews are missing.", [], [], ["Provide the missing artifacts."], round_number)

    blockers = [finding for review in reviews for finding in review.get("blocking_findings", [])]
    missing_evidence = [item for review in reviews for item in review.get("missing_evidence", [])]
    decisions = [review.get("decision") for review in reviews]
    confidences = [float(review.get("confidence", 0.0)) for review in reviews]

    if any(decision not in DECISIONS for decision in decisions):
        return _result("escalate", 0.0, "A review contains an invalid decision.", [], [], [], round_number)
    if blockers:
        decision = "revise" if round_number < max_rounds else "escalate"
        return _result(decision, 0.0, "Blocking findings remain.", blockers, [], missing_evidence, round_number)
    if missing_evidence:
        decision = "revise" if round_number < max_rounds else "escalate"
        return _result(decision, 0.0, "Required evidence is missing.", [], [], missing_evidence, round_number)

    total_weight = sum(confidences)
    approval_ratio = sum(c for d, c in zip(decisions, confidences) if d == "approve") / total_weight if total_weight else 0.0
    rejection_ratio = sum(c for d, c in zip(decisions, confidences) if d == "reject") / total_weight if total_weight else 0.0

    if approval_ratio >= 0.70 and all(decision == "approve" for decision in decisions):
        decision = "approve"
    elif rejection_ratio >= 0.70:
        decision = "reject"
    elif round_number < max_rounds:
        decision = "revise"
    else:
        decision = "escalate"

    minority = [f"{review.get('agent_id')}: {review.get('decision')}" for review in reviews if review.get("decision") != decision]
    confidence = round(approval_ratio if decision == "approve" else max(approval_ratio, rejection_ratio), 3)
    rationale = f"Weighted approval ratio={approval_ratio:.3f}; weighted rejection ratio={rejection_ratio:.3f}."
    return _result(decision, confidence, rationale, [], minority, [], round_number)


def _result(decision, confidence, rationale, blockers, minority_report, reopen_conditions, round_number):
    return {"decision": decision, "confidence": confidence, "rationale": rationale, "blockers": blockers, "minority_report": minority_report, "reopen_conditions": reopen_conditions, "round": round_number}


def main() -> None:
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--proposals", nargs="+", required=True)
    parser.add_argument("--reviews", nargs="+", required=True)
    parser.add_argument("--round", type=int, default=1)
    parser.add_argument("--max-rounds", type=int, default=2)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    result = calculate_consensus(_read_many(args.proposals), _read_many(args.reviews), args.round, args.max_rounds)
    Path(args.output).write_text(json.dumps(result, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
