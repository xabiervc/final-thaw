---
applyTo: "**/*.gd"
---

# GDScript Instructions

- Follow existing project conventions before introducing new ones.
- Keep scripts focused and small.
- Avoid hidden global state.
- Prefer explicit types at public method and signal boundaries.
- Do not change public signals, node paths, save formats, or input actions without checking dependants.
- Add or update tests for non-trivial logic.
- Never claim runtime behavior was verified unless the project was actually run.
