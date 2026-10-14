# Project Status — FINAL THAW

## Current phase

**Design pivot / prototype validation.** The next goal is a small, evidence-driven third-person 3D gameplay prototype. The full campaign design is not yet re-approved.

## Current design direction

See [`docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`](docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md).

Working hypothesis:
- Mission 1: Elena investigates Helix/Aster evidence and solves one compact, inference-driven system puzzle.
- Mission 2: activating the system triggers containment; Elena escapes through physical traversal while a readable pursuer searches for her.
- Third-person 3D is the first camera/movement hypothesis because the proposed mechanics need spatial depth. The choice remains subject to playtest, camera readability, performance, and target-platform validation.
- The existing Elena/Helix/Iris/Selene/Aster narrative material is retained provisionally. The dual-protagonist campaign, Marcus combat, fixed 16-phase structure, total duration, and final platform scope are not reconfirmed by this prototype.

## Implementation status — existing branch content

The `feat/godot-vertical-slice` branch contains earlier experiments:
1. The Flooded Shelter 2.5D gameplay skeleton, including movement, oxygen, interactions, rescue, localization and a decision summary.
2. An early 3D Elena test room with movement, interaction, scanning, environmental presentation, HUD and synthesized audio experiments.
3. Lab greybox scenes, visual wrappers, props, materials, character models and shader/capture tooling.

These are useful comparison points and asset sources. They do not implement the proposed crawl/climb/pursuit loop unless a specific feature is verified in code and by playtest.

## Next milestone

**M0 — Five-minute third-person proof of concept.**

Build in this order:
1. Movement sandbox: camera, movement, jump, fall/land, crouch/crawl, one reliable climb affordance, quick restart.
2. Traversal greybox: gap, low passage, ledge, visible alternate route.
3. Pursuer prototype: telegraphed investigation/detection/pursuit/search, breakable line of sight and fair recovery.
4. One multi-step investigation puzzle using physical clues and optional scanner/hint support.
5. Connect puzzle completion to lockdown, pursuit, and a story-relevant evidence reveal.

Do not expand combat, inventory, Marcus gameplay, full-campaign content, or production art before the proof of concept passes.

## Acceptance gate

A hands-on playtest must establish that:
- a new player understands the immediate goal without the HUD giving away the solution;
- traversal is readable and does not routinely fail due to camera/collision issues;
- the pursuer is threatening but fair and its states are legible;
- the escape requires at least one meaningful route/timing/concealment decision;
- failure teaches and retries are short;
- puzzle, escape and narrative feel causally connected;
- the scene loads cleanly and runs acceptably on the actual target configuration;
- Phase 0 acceptance remains green.

Record Godot version, exact steps, PASS/FAIL, console output, captures, performance notes, and unresolved issues.

## Technical foundation and regression boundary

Phase 0 acceptance testing remains the only formally recorded foundation result in this status record: the last recorded run reported 11 passed, 0 failed, exit code 0. Re-run it after changes; do not assume a historical pass covers new code.

Preserve existing input/autoload/resource contracts, save compatibility and CRC32 behavior. Keep previous prototype scenes available until migration is reviewed and the new prototype has been compared in a hands-on session.

## Art and asset review

Current art is a prototype library, not a set of approved final assets.
- Reusable candidates: Elena concept/model/materials, lab kit and props, scan effects, HUD patterns, wall cutaway, synthesized audio, lighting experiments, capture harness.
- Revalidate all scale, collision, traversal clearance, camera occlusion, silhouette and interaction needs against the third-person camera.
- Marcus model and combat-related assets are not a reason to retain the earlier dual-protagonist/combat direction.
- The MPFB/MakeHuman base-mesh licence is not yet verified in the documented source; do not ship derived assets until resolved.
- Visual captures do not substitute for hands-on playtesting. Animation, audio by ear, broad accessibility and target-platform performance still require verification.

See `docs/art/PROVENANCE.md` and the model status documents for asset-specific caveats.

## Documentation migration policy

Legacy documents currently specify a 16-phase, dual-protagonist, isometric/combat-heavy campaign as normative. Those assumptions conflict with the new prototype direction. They are to be marked **legacy / under review for the redesign**, not followed as implementation requirements for the new prototype. Do not mass-rewrite them until prototype evidence informs a deliberate design decision.

## Next action

Implement and test M0 from `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`, starting with movement and camera feel. Keep changes narrow and reversible; do not continue broad art production first.

## Reporting rule

Do not mark a feature as verified, playable, accessible, performant or release-ready without evidence.
