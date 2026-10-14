# FINAL THAW — Design Pivot and Prototype Brief

**Status:** proposed working direction; validate through a playable prototype before treating it as a new full-game specification.  
**Date:** 2026-10-14  
**Branch:** `feat/godot-vertical-slice`

## Why this document exists

The repository contains a large legacy design package built around a fixed 16-phase campaign, two mechanically distinct protagonists, isometric presentation, puzzle rooms for Elena and combat arenas for Marcus. That package is more specific than the experience currently demonstrated by the playable project, and several of its structural decisions are being reconsidered.

This brief supersedes those old assumptions **for the next prototype only**. It does not automatically rewrite the full campaign, ending system, save schema, or character arcs. Use it to test the next gameplay direction with the smallest reversible implementation.

## Current design hypothesis

**Final Thaw is a cinematic, third-person sci-fi survival adventure about investigation, physical traversal, and escape under pressure.** Its identity should come from tense embodied situations and consequential discoveries—not a sequence of abstract rooms, generic combat arenas, or HUD-led chores.

The strongest existing narrative material stays in place for now: Elena Vast, Helix, Iris, Selene, the Aster prototype, the withheld test results, civilian consequences, and the recovery force sent after Elena. Narrative facts may be rearranged to serve the revised playable sequence, but no character motivation or causal fact is silently changed.

### Pillars to validate

1. **Physical traversal with readable risk.** The player jumps gaps, climbs authored ledges, squeezes through confined spaces, balances or times movement across unstable machinery, and understands why a route is dangerous.
2. **Investigation that rewards inference.** The scanner is a tool for observing traces, mechanisms, environmental evidence, and the consequences of Helix's actions. It should reveal information, not automatically solve every puzzle.
3. **Pressure from a pursuer.** A threat changes how the player moves, what they inspect, and which route they choose. The encounter needs readable detection and search behavior—not magical tracking or a simple countdown.
4. **Mechanics with narrative purpose.** The power-system puzzle and the escape should be causally connected: the player's successful intervention triggers a facility response and makes the next sequence more dangerous.
5. **Short, fair failure recovery.** Telegraph hazards, communicate mistakes, and restore the player close to the failed challenge. Difficulty should come from decisions and execution, not hidden rules.

## Proposed two-mission opening

### Mission 1 — The Ghost Protocol: investigate and solve

**Primary verb:** understand.

Elena enters a Helix test facility to establish what happened to an Aster test and recover evidence that Helix manipulated or concealed the result.

The playable space should teach looking, scanning, moving around machinery, and interacting with physical systems. A compact multi-step energy-routing or system-reconfiguration puzzle is the central challenge. The player should infer the solution from cable routing, equipment states, labels, wear, sound, and scan traces. Do not print the answer directly in the objective HUD.

The puzzle must have:
- a legible goal and understandable controls;
- at least two pieces of evidence that can be combined;
- immediate feedback after a meaningful action;
- a hint path that can help without removing the inference;
- an outcome that changes the physical environment, not just a progress flag.

**Narrative turn:** restoring the system uncovers or confirms consequential evidence, but also wakes containment/security systems. The mission ends with a clear causal transition into the escape.

Avoid increasing puzzle complexity by adding arbitrary symbols, many identical switches, or trial-and-error states. Depth should come from relationships the player can reason about.

### Mission 2 — Containment: move, evade, escape

**Primary verb:** survive.

The facility locks down and a recovery unit begins searching for Elena. The route out is a short, authored 3D traversal space with several different physical problems: a readable jump, a low passage that requires crouching/crawling, an authored ledge or ladder to climb, and a moving or failing structure that changes the safe route.

The pursuer should create changing decisions. The player may break line of sight, hide briefly, use a noisy environmental interaction as a distraction, or take a more dangerous exposed route. Do not implement every option unless the prototype demonstrates its value; one strong alternative route is better than several shallow interactions.

The sequence should include:
- a safe observation moment before the first serious risk;
- one low-cost failure that teaches a rule;
- an escalation that combines traversal with threat awareness;
- a final escape beat that feels earned;
- a short aftermath that reconnects the action to Elena's evidence and Iris/Selene story.

**Enemy behavior hypothesis:** investigate → patrol/search → detect → pursue → lose sight/search again → intercept a likely route. Each transition needs telegraphing and fair counterplay. Avoid unavoidable damage, teleporting, permanent wall-hacks, or a chase that is only a timer.

Combat, firearms, elaborate melee, skill trees, full inventory, multiple enemy classes, and boss systems are explicitly out of scope for this prototype.

## Perspective and camera decision

Prototype **third-person 3D** first because jumping, climbing, crawling, spatial cover, and pursuit depend on depth and readable body-to-world relationships. This is a hypothesis, not an irreversible engine-wide decision.

The prototype must validate:
- camera framing during jumps, climbs, crouch spaces, and pursuit;
- movement response, air control, landing, collision, and ledge detection;
- visibility of the next safe landing and hazards;
- motion comfort, camera obstruction, and readable depth;
- stable performance in the actual target renderer.

Use hand-authored greybox geometry and only enough art to judge scale, silhouette, and route readability. Do not migrate every scene, rewrite the art kit, or commit to a final renderer before the test passes. Keep the Compatibility renderer and existing Web-target constraints unless profiling and an explicit product decision justify a change.

## Five-minute proof of concept

| Time | Player experience | Evidence required |
|---|---|---|
| 0:00–1:00 | Learn third-person move, camera, jump, and landing in a safe area | Controls feel predictable; intended route is visible |
| 1:00–2:00 | Read a hazard and traverse a gap or unstable platform | Telegraph and safe landing are understandable |
| 2:00–3:00 | Crawl through a confined passage and climb a defined ledge | Body, camera, collision, and animation do not fight each other |
| 3:00–4:00 | Pursuer detects Elena; player breaks line of sight or chooses an alternate route | Threat is understandable, fair, and changes the player's plan |
| 4:00–5:00 | Reach a short investigation point or environmental choice before escape | Scanning adds useful inference; story and action reinforce each other |

This is a test script, not a claim that the current build already supports those actions.

## Prototype acceptance criteria

Do not green-light a larger migration unless a hands-on playtest demonstrates all of the following:

- A new player can identify the immediate goal without needing the solution shown in the HUD.
- Movement, jump, crawl and climb feel consistent, with no routine camera or collision frustration.
- The pursuer communicates detection state and gives the player a learnable response.
- The chase contains at least one real decision—route, timing, concealment or distraction—not only sustained forward running.
- Failure teaches a specific rule and retry time is short.
- The investigation and escape feel like one causal sequence.
- The scene loads without missing resources or errors and runs acceptably on the current target configuration.
- The existing Phase 0 acceptance test still passes.
- Results are recorded with Godot version, exact test procedure, observations, issues and captures where useful.

A failed criterion is a reason to iterate on the prototype, not to declare the premise proven.

## Art and asset policy during the pivot

Treat current assets as a reusable **prototype library**, not a set of approved production assets.

- Retain Elena's concept art, current 3D character model, material studies, lab props, shaders, scan effects, HUD patterns, synthesized audio, capture harness, and environmental dressing where they serve the new experience.
- Do not expand the Marcus model or implement Marcus gameplay until the narrative and protagonist model are reconsidered after the two-mission test.
- Do not assume the current room layouts, 2.5D scene dressing, prop placements, or isometric readability carry over to third-person.
- Reassess all imported set pieces for collision, scale, traversal clearance, ledge height, camera occlusion, and silhouette readability.
- Record source, author, licence and files used before any external resource is considered shippable. The MPFB/MakeHuman base-mesh licence remains a release blocker until verified against authoritative terms.
- Keep renders and manual playtest evidence separate from the asset source files and record the exact build used.

## Technical boundaries

- Preserve Phase 0 input, autoload, resource-path, save and CRC32 compatibility contracts unless a separately reviewed migration is approved.
- Avoid silently replacing the current canonical project or deleting the Flooded Shelter / lab prototypes. Keep them available for comparison until the new prototype demonstrates a better direction.
- Keep gameplay state, traversal, scanner, pursuer AI, presentation, and narrative triggers separable enough to test independently.
- Save compatibility and platform export behavior must be tested if any runtime or project configuration is changed.
- Accessibility is an early design constraint: remappable inputs, non-colour-only cues, subtitles for narrative/audio cues, adjustable camera sensitivity, reduced camera motion where feasible, generous interaction affordances, and options to simplify or skip the most demanding traversal/chase sections without blocking story comprehension.

## Scope and decision log

### Working direction for the next prototype
- Elena-led third-person 3D.
- One investigation/system puzzle mission.
- One traversal/escape mission with one pursuer.
- Industrial climate-thriller tone and environmental storytelling.
- No full campaign, production asset pass, combat loop, or large inventory implementation.

### Still open; must be validated
- Final camera style and movement feel.
- Whether crawling, climbing, and hiding all earn their complexity.
- How active the pursuer should be and whether it searches dynamically.
- Exact mission length and number of puzzle steps.
- How much of the dual-protagonist concept survives in the complete game.
- Final platform scope and rendering strategy.

### Explicitly not decided
- The full-game campaign structure, final ending conditions, total playtime, all accessibility requirements, and shipping platform list are not re-approved by this prototype brief.

## Next implementation order

1. **Movement sandbox:** third-person camera, move, jump, fall/land, crouch/crawl, one reliable climb interaction, restart.
2. **Traversal greybox:** one route with a gap, low tunnel, ledge and visible alternate path; no enemy yet.
3. **Pursuer test:** clear state machine, readable detection, line-of-sight break, search and fair recovery after failure.
4. **Investigation puzzle:** one compact multi-step energy/system puzzle with clues, feedback, scan traces and hint support.
5. **Narrative stitching:** connect the successful system intervention to lockdown, pursuit and one story-relevant evidence reveal.
6. **Review gate:** human playtest, accessibility pass, camera review, technical profiling, asset/license check, then revise normative specs based on findings.

Implement the smallest playable proof first. Do not create a larger content plan until this test provides evidence.
