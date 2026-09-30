You are continuing FINAL THAW in Godot 4.x. This game targets award-worthy quality at The Game Awards, D.I.C.E. Awards, BAFTA Games Awards, and Game Developers Choice Awards.

Read CLAUDE.md and inspect the full project. Phases 0–15 are complete with professional-grade foundation.

GOAL
Perform release-focused QA, correct verified defects, add essential accessibility settings if missing, prepare export configuration, and create release documentation. Do NOT add new gameplay features.

QUALITY STANDARDS
- QA documentation reflects real verification, not assumptions
- Full game can reach each ending using documented test steps
- Windows export is created and run-tested if export tooling is available
- No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains
- Accessibility: all options functional and tested

DELIVERABLES

1. Create docs/qa_checklist.md covering:
   - Every menu (MainMenu, HUD, epilogue, credits, settings)
   - Every level (test_room, elena_test_room, laboratory rooms, highway arenas, shelter, perimeter, joint missions, dam, port, transit hub, Final Thaw Station, boss arena)
   - Every puzzle (terminal sequences, moving platforms, water puzzles, circuit minigame, power routing, timed interactions, lighting control, stealth takedowns, calibration panels)
   - Every enemy type (scavenger, enforcer, marksman, shield) with all attacks and behaviors
   - Every boss move (Riot Commander, Transport Captain, Helix Commander) with all phases
   - Every minigame (vehicle repair, Aster calibration)
   - Every character switch scenario (transit hub, Final Thaw Station, boss arena)
   - Save/load/checkpoint behavior (every checkpoint tested, reload tested)
   - All consequence counters (Elena Safety, Prototype Integrity, Civilian Aid) with all increment/decrement scenarios
   - All three endings (Fragile, Public, Guarded) with test steps to reach each
   - Controls (all inputs tested with default and remapped bindings)
   - Exported builds (Windows, macOS/Linux if applicable)
   - Accessibility options (all toggles, sliders, and settings tested)
   - Clear pass/fail checkboxes and notes sections

2. Run systematic full-game verification:
   - Play through entire game from start to finish at least once
   - Record actual issues found in docs/qa_results.md with:
     - Severity (blocker, critical, major, minor)
     - Reproduction steps (clear, repeatable)
     - Resolution (fixed, wontfix, deferred)
     - Verification status (tested, pending)
   - Do NOT invent test results; be honest about what was tested
   - Include performance metrics (FPS in heavy sections, load times)
   - Include accessibility testing (test with reduced vision/hearing/motor simulators if possible)

3. Fix confirmed blockers first:
   - Crashes (any scenario that crashes game)
   - Parser errors (Godot console errors)
   - Softlocks (player cannot progress)
   - Broken progression (cannot complete level, puzzle, or boss)
   - Corrupted save handling (save/load fails or corrupts state)
   - Incorrect ending logic (wrong ending triggered)
   - Input failures (inputs not working or not remappable)
   - Then address clear visual/audio defects (typos, misaligned UI, missing sounds)

4. Profile performance using Godot tooling where available:
   - Use Godot Profiler to identify bottlenecks
   - Optimize only verified bottlenecks: excessive nodes/particles, unnecessary processing, expensive effects
   - Preserve gameplay behavior (do not change mechanics while optimizing)
   - Target: 60 FPS stable on modest hardware (GTX 1050 or equivalent)
   - Document optimizations in qa_results.md

5. Ensure essential accessibility:
   - Input remapping or documented configurable bindings (all inputs tested)
   - Text size setting (normal/large/extra-large; all sizes tested)
   - Reduced camera shake toggle (tested and functional)
   - Reduced weather/effect intensity toggle (tested and functional)
   - Visual non-colour-only puzzle indicators (all puzzles tested for colorblind accessibility)
   - Audio descriptions for visual-only information (if implemented)
   - Visual indicators for audio-only information (if implemented)
   - Document any accessibility gaps in qa_results.md

6. Configure export presets for Windows:
   - Create Windows export preset in Godot
   - Configure export settings (resolution, icon, executable name, etc.)
   - Export Windows build (ZIP or EXE)
   - Run-test exported build (launch, play through sections, verify no errors)
   - Configure macOS/Linux only if export templates and practical testing are available
   - Do NOT falsely claim untested builds work; mark as "untested" if applicable
   - Document export process in docs/release_checklist.md

7. Create docs/release_checklist.md with:
   - Version: 1.0.0
   - Tested platforms: Windows (tested), macOS/Linux (untested if applicable)
   - Known issues: list any unresolved minor/minor issues
   - Store asset checklist: screenshots (5–10), trailer placeholder, description placeholder, tags, age rating
   - Content warning review: climate themes, combat, no graphic violence/gore
   - Release sign-off fields: developer name, date, platform, build number
   - Clear, professional documentation

8. Update README.md with:
   - Installation/run instructions for release build (how to download, extract, launch)
   - Controls table with default bindings
   - Accessibility features list (all options documented)
   - Credits placeholder (developer names, roles)
   - License decision placeholder (TODO if undecided; mark clearly)
   - Clear, professional formatting

9. If Git is available:
   - Ensure clean working tree (no uncommitted changes)
   - Make final version commit with all QA fixes and documentation
   - Create annotated tag v1.0.0 only after all checks pass
   - If any release blocker remains, do NOT tag; report it in qa_results.md instead
   - Clear commit message: "Phase 16: QA, optimization, and release build complete"

ACCEPTANCE CRITERIA
- QA documentation reflects real verification, not assumptions (docs/qa_checklist.md and docs/qa_results.md are complete and honest)
- Full game can reach each ending using documented test steps (all three endings tested and verified)
- Windows export is created and run-tested if export tooling is available (build launches and runs without errors)
- No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains (all blockers fixed or documented)
- All accessibility options are functional and tested
- Performance is stable at 60 FPS on modest hardware (verified via profiler)

DO NOT
- Add new gameplay features (only fix bugs and optimize)
- Invent test results (be honest about what was tested)
- Claim untested platforms work (mark as "untested" if applicable)
- Tag release if any blocker remains (report instead)

Finish by reporting:
- Changed files with brief descriptions
- Actual QA results (what was tested, what passed, what failed)
- Remaining known issues (be honest and specific)
- Build test results (Windows export tested? macOS/Linux?)
- Propose this commit message exactly:
Phase 16: QA, optimization, and release build complete
