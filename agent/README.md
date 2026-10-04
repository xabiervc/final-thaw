# Graph Consensus Agent Runtime v0

This directory contains a dependency-free, artifact-driven consensus protocol for Final Thaw.

The graph is provider-neutral:

- Claude and GPT produce independent structured proposals and reviews.
- Copilot implements localized approved changes.
- Claude Code implements complex approved changes.
- Godot provides deterministic runtime verification.
- Python scripts calculate consensus and validate evidence.

The common point is `.agent/runs/<run-id>/task.yaml` plus `shared-context.md`, not a specific chat window.

See [`docs/GRAPH_CONSENSUS.md`](../docs/GRAPH_CONSUS.md) for the complete workflow.
