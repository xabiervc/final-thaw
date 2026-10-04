import importlib.util
from pathlib import Path

ROOT = Path(__file__).parents[2]
MODULE_PATH = ROOT / "agent" / "consensus.py"

spec = importlib.util.spec_from_file_location("consensus", MODULE_PATH)
consensus = importlib.util.module_from_spec(spec)
spec.loader.exec_module(consensus)


def review(agent_id, decision="approve", confidence=0.9, blockers=None, missing=None):
    return {
        "agent_id": agent_id,
        "decision": decision,
        "confidence": confidence,
        "blocking_findings": blockers or [],
        "non_blocking_findings": [],
        "missing_evidence": missing or [],
        "required_changes": [],
    }


def test_approve_requires_unanimous_reviews_and_threshold():
    result = consensus.calculate_consensus([{}, {}], [review("claude"), review("gpt")])
    assert result["decision"] == "approve"
    assert result["confidence"] >= 0.70


def test_blocker_prevents_approval():
    result = consensus.calculate_consensus([{}, {}], [review("claude", blockers=["save format unclear"]), review("gpt")])
    assert result["decision"] == "revise"
    assert result["blockers"] == ["save format unclear"]


def test_missing_artifacts_escalate():
    result = consensus.calculate_consensus([], [])
    assert result["decision"] == "escalate"


def test_disagreement_revises_then_escalates():
    first = consensus.calculate_consensus([{}, {}], [review("claude", "approve"), review("gpt", "reject")], 1, 2)
    second = consensus.calculate_consensus([{}, {}], [review("claude", "approve"), review("gpt", "reject")], 2, 2)
    assert first["decision"] == "revise"
    assert second["decision"] == "escalate"


def test_evidence_validation():
    validate_path = ROOT / "agent" / "validate.py"
    validate_spec = importlib.util.spec_from_file_location("validate", validate_path)
    validate = importlib.util.module_from_spec(validate_spec)
    validate_spec.loader.exec_module(validate)
    assert validate.validate_evidence({"status": "complete"})
