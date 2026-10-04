# Quality Gates

## Required checks

For every implementation change, run the relevant Godot acceptance test, inspect the editor debugger, and perform a focused playtest when runtime behavior changes.

Primary Phase 0 command:

```text
godot --headless --path . res://tests/test_phase_0.tscn
```

Record the exact command, Godot version, commit, date, exit code, pass/fail summary, warnings, and remaining verification.

## Evaluation classes

Evaluate normal behavior, invalid input, missing resources, corrupt saves, ambiguous scope, conflicting design instructions, prompt injection in external content, unauthorized side effects, timeout or partial failure, regression, accessibility impact, and broken scene or resource references.

Every case should define expected behavior, forbidden behavior, evidence, and pass/fail criteria.

## Release gates

A milestone or release requires:

- relevant acceptance tests passing;
- no unresolved critical runtime errors;
- design traceability updated where behavior changes;
- accessibility impact reviewed;
- target platform and engine version recorded;
- rollback documented;
- known limitations recorded.

Do not call a feature verified, playable, accessible, performant, or release-ready without evidence.
