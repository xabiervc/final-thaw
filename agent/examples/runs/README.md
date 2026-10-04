# Example Run Artifacts

A real run should create a directory such as:

```text
.agent/runs/2026-10-05T0001Z-first-level/
├── task.yaml
├── proposals/
│   ├── claude.json
│   └── gpt.json
├── reviews/
│   ├── claude.json
│   └── gpt.json
├── consensus.json
├── implementation.json
├── test-result.json
├── final-review.json
└── evidence.json
```

The graph should be resumable and should not repeat side effects when rerun.
