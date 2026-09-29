You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect the full project. Phases 0–15 are complete.

GOAL
Perform release-focused QA, correct verified defects, add essential accessibility settings if missing, prepare export configuration, and create release documentation. Do not add new gameplay features.

DELIVERABLES
1. Create docs/qa_checklist.md covering every menu, level, puzzle, enemy type, boss move, minigame, character switch scenario, save/load/checkpoint behavior, all consequence counters, all three endings, controls, and exported builds.
2. Run a systematic full-game verification. Record actual issues found in docs/qa_results.md with severity, reproduction steps, resolution, and verification status. Do not invent test results.
3. Fix confirmed blockers first: crashes, parser errors, softlocks, broken progression, corrupted save handling, incorrect ending logic, and input failures. Then address clear visual/audio defects.
4. Profile performance using Godot tooling where available. Optimize only verified bottlenecks: excessive nodes/particles, unnecessary processing, expensive effects. Preserve gameplay behavior.
5. Ensure essential accessibility: input remapping or documented configurable bindings; text size setting (normal/large); reduced camera shake; reduced weather/effect intensity; visual non-colour-only puzzle indicators.
6. Configure export presets for Windows. Configure macOS/Linux only if export templates and practical testing are available; do not falsely claim untested builds work.
7. Create docs/release_checklist.md with version 1.0.0, tested platforms, known issues, store asset checklist, screenshots/trailer placeholders, description placeholder, content warning review, and release sign-off fields.
8. Update README.md with installation/run instructions for the release build, controls, accessibility, credits placeholder, and license decision placeholder. Do not choose a license without asking; mark it clearly as TODO if undecided.
9. If Git is available, ensure clean working tree, make final version commit, and create annotated tag v1.0.0 only after checks pass. If any release blocker remains, do not tag; report it instead.

ACCEPTANCE CRITERIA
- QA documentation reflects real verification, not assumptions.
- Full game can reach each ending using documented test steps.
- Windows export is created and run-tested if export tooling is available.
- No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains.

Finish with changed files, actual QA results, remaining known issues, build test results, and propose this commit message exactly:
Phase 16: QA, optimization, and release build complete
