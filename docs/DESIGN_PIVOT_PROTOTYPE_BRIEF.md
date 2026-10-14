# FINAL THAW — Design Pivot and Prototype Brief

**Status:** active working brief for the opening prototype; not yet the locked full-game specification.  
**Last reviewed:** 2026-10-14  
**Branch:** `feat/godot-vertical-slice`

## Why this brief exists

The repository contains a detailed earlier campaign package built around a fixed 16-phase structure, two protagonists with separate puzzle/combat roles, and repeated puzzle rooms and combat arenas. The project now has a stronger isolated third-person motion/chase prototype. The design work should build on that actual code rather than describe a hypothetical movement prototype from scratch.

This brief governs the **next prototype only**. It does not automatically rewrite the full campaign, final endings, save schema, Marcus's role or the established story chronology.

## Current design hypothesis

Final Thaw is a cinematic science-fiction climate thriller about investigating Helix, understanding physical systems, and escaping the organization once a consequential truth is uncovered.

The proposed opening has two contrasting but causally linked missions:

1. **The Ghost Protocol — investigation/system puzzle.** Elena investigates an Aster test, combines environmental evidence, infers a system configuration and reveals a contradiction in Helix's account.
2. **Containment — traversal/stealth/escape.** Her intervention triggers a lockdown and a recovery unit hunts her through a physical environment. She must jump, crouch, climb at a defined point, manage noise and line of sight, and choose a viable route.

The story material to preserve provisionally includes Elena, Iris, Helix, Aster, Selene and the evidence that an Aster test was concealed or manipulated. The full-campaign structure, Marcus's final role, ending system, playtime and platform scope remain open.

## Existing prototype: what the code actually does

Scene: `scenes/prototypes/motion_chase_prototype.tscn`  
Implementation: `scripts/prototypes/motion_chase_prototype.gd`  
Behavior test: `tests/test_motion_chase_prototype.tscn` / `tests/test_motion_chase_prototype.gd`

The v2 prototype currently contains:
- third-person camera orbit and fading of walls/ceilings/pillars that obstruct the view;
- walk/run/crouch movement, jump buffering, coyote time, gravity and landing audio;
- an approximately 80 m left-to-right greybox with three gaps, a low vent tunnel, a low duct and a defined climb to a catwalk;
- a recovery unit with patrol, investigate, alert, chase, search and return states;
- vision cone, line-of-sight checks, bounded last-known-position pursuit and noise-based investigation;
- a scanner with charge-up, a short reveal window, route labels and cooldown;
- checkpoints, catch/fall recovery, a finish state, a HUD and synthesized sound effects;
- the Elena MPFB model and procedural pose layer, with a primitive fallback.

**Not implemented:** the Mission 1 inference puzzle, evidence collection, narrative transition from puzzle to lockdown, a campaign-integrated enemy, general-purpose pathfinding, dedicated crouch/climb animations, localized prototype text, Web profiling or full controller validation.

The v2 prototype document records that its automated test has **not yet been run**. Do not claim v2 is verified until it is run in Godot and the results are recorded. Automated checks do not replace a hands-on playtest.

## Mission 1 — The Ghost Protocol (proposed)

**Primary verb: understand.**

Elena enters a Helix facility to reconstruct what happened to an Aster test. Use environmental evidence: cable routing, machine states, physical labels, scan traces, an inconsistent record or partial transmission. The player combines at least two clues to infer a system configuration.

The puzzle must have:
- a clear goal and understandable controls;
- evidence that supports reasoning rather than random trial and error;
- immediate feedback after meaningful interactions;
- an optional hint path that does not simply reveal the answer;
- a physical result that changes the environment;
- one specific narrative revelation rather than an exposition dump.

The HUD may explain the goal, but must not display the solution.

## Mission 2 — Containment (existing prototype foundation)

**Primary verb: escape.**

The existing motion/chase prototype is the foundation for traversal and pursuit. It already tests gaps, a crouch passage, a defined climb, cover, noise, scanning and a recovery unit. Improve this prototype rather than starting again.

The pursuer should change the player's plan. The player may break line of sight, hide in the duct, take the elevated route or attempt a timed crossing. Its behavior should be readable and bounded by what it has seen or heard. Avoid omniscient tracking, arbitrary catches and a chase that is only a timer.

Current known limitations from code/design review:
- steering uses probes rather than a navigation mesh and may fail on unusual geometry;
- climbing is a defined point with a short tween, not free climbing;
- crouching currently squashes the visual model; there is no dedicated crouch/climb pose;
- scanner timing and detection/noise numbers are unvalidated tuning values;
- prototype text is hard-coded Spanish;
- the puzzle-to-chase narrative link is not implemented.

## Camera and perspective

Keep third-person 3D as the leading hypothesis because the intended mechanics rely on spatial depth, cover, jumps and a pursuer. Do not treat the camera decision as final until a human playtest validates camera framing, depth perception, collision, motion comfort and route readability.

Keep the current Compatibility renderer and platform assumptions unless profiling and an explicit decision justify changing them. Do not migrate all scenes or replace the art pipeline as part of this prototype.

## Next work, in order

1. **Run and inspect v2.** Execute the prototype and its headless test, fix any failures, and record the Godot version and results. Then perform a hands-on playtest.
2. **Tune traversal and camera.** Test gaps, crouch clearance, climb prompt/trigger, camera occlusion, fall recovery and checkpoints. Fix confusing or unfair segments.
3. **Validate the recovery unit.** Observe detection, noise investigation, loss of sight, search and reset. Ensure it does not track Elena magically or get trapped on normal geometry.
4. **Design and implement the investigation puzzle.** Build one compact, inference-driven system puzzle with two or more clues, useful scan traces, feedback and hints.
5. **Connect cause and effect.** Solving the system reveals evidence and triggers containment; escaping produces a short narrative aftermath.
6. **Review the combined slice.** Manual playtest, accessibility review, camera review, technical profiling, localization check, asset/license check and Phase 0 regression.
7. **Reconcile full-game documents.** Only after owner review of the combined prototype should the old campaign, Marcus, endings and duration be promoted, replaced or retired.

## Five-minute proof of concept

| Beat | Experience | Evidence |
|---|---|---|
| 0:00–1:00 | Learn camera, movement and first jump | Controls and landing are predictable |
| 1:00–2:00 | Cross a gap and crouch through a low passage | The geometry teaches a rule without frustration |
| 2:00–3:00 | Encounter the recovery unit and test sound/line of sight | The player understands detection and can respond |
| 3:00–4:00 | Use scanner information to choose between duct, climb or exposed route | The scanner supports a real decision |
| 4:00–5:00 | In the combined slice, infer a system fault and trigger the escape | Puzzle, narrative and chase form one causal sequence |

The current motion/chase prototype covers much of the middle of this test, not the opening puzzle or the complete five-minute experience.

## Acceptance gate

Do not expand the campaign until a recorded hands-on playtest establishes:
- movement and camera feel predictable and comfortable;
- gaps, low passage and climb are fair and readable;
- the recovery unit's states are clear and it gives the player counterplay;
- at least one meaningful route/timing/concealment decision exists;
- scanner use adds information without removing the need to think;
- failures teach a specific rule and retries are short;
- the puzzle's outcome clearly causes containment;
- scene load and target performance are acceptable;
- Phase 0 acceptance remains green.

Record the Godot version, exact commands, PASS/FAIL output, observed defects, first-time-player confusion, screenshots/video where useful, and performance notes. Do not invent success percentages before testing.

## Asset policy during the pivot

Treat current assets as a prototype library, not approved final production content. Reuse Elena, lab kit, materials, shaders, scanner effects, HUD, audio and capture tools where they help. Do not expand Marcus or combat assets until the full-game role is reconsidered. Recheck scale, collisions, clearance, camera occlusion and silhouette from the actual third-person camera. The MPFB/MakeHuman base-mesh licence remains a blocker until verified from authoritative terms.

## Technical boundaries

Preserve Phase 0 input/autoload/resource/save/CRC32 contracts. Keep previous shelter and lab prototypes available for comparison. Do not silently change project settings, renderer, save schema, autoloads or public signals. Separate traversal, scanner, AI, presentation and narrative triggers sufficiently for testing. Consider accessibility from the start: remappable controls, non-colour-only cues, readable subtitles/text, adjustable camera sensitivity, reduced motion where feasible and fair alternatives for demanding traversal.

## Decisions still open

- Final camera tuning and movement feel.
- Whether every traversal verb adds enough value.
- Pursuer activity, search behavior and route intelligence.
- Puzzle steps, hint levels and mission duration.
- How much of the dual-protagonist concept survives.
- Full campaign structure, endings, total playtime and platform scope.

**Principle:** implement and validate the smallest compelling playable proof before writing another large content plan.
