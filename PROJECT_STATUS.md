# Project Status — FINAL THAW

## Current phase

**Prototype validation for the redesign.** The branch now contains an isolated third-person motion/chase prototype (v2) in addition to earlier shelter and Elena-room experiments.

## Active design direction

See:
- [Working vision](docs/VISION.md)
- [Design pivot brief](docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md)
- [Motion/chase prototype specification](docs/design/MOTION_CHASE_PROTOTYPE.md)
- [Current core loop](docs/CORE_LOOP.md)

The working hypothesis is an Elena-led opening with an investigation/system puzzle followed by a traversal/stealth escape. This is not yet an approved full-campaign redesign.

## Motion/chase prototype v2

Files:
- Scene: `scenes/prototypes/motion_chase_prototype.tscn`
- Code: `scripts/prototypes/motion_chase_prototype.gd`
- Test: `tests/test_motion_chase_prototype.tscn`
- Test code: `tests/test_motion_chase_prototype.gd`

Implemented in code:
- Third-person camera orbit and fading of occluding walls, ceilings, pillars and catwalk.
- Walk, run, crouch, jump, gravity, jump buffer, coyote time and landing/footstep audio.
- Three gaps, a low vent tunnel, a low duct, a climb trigger and an elevated catwalk.
- Recovery-unit state machine: patrol, investigate, alert, chase, search and return.
- Vision cone and line-of-sight checks, bounded last-known-position pursuit and noise-based investigation.
- Scanner reveal, route labels, cooldown, checkpoint recovery, catches, exit state and HUD.
- Elena model/pose layer with primitive fallback and synthesized audio.

These are implementation facts from code inspection, not a claim of validated gameplay quality.

### Verification boundary

The prototype design document states that v2 code and its automated test have not yet been run. The next technical action is to run:

```sh
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
godot --headless --path . res://tests/test_phase_0.tscn
```

Then run `scenes/prototypes/motion_chase_prototype.tscn` manually. Record engine version, command output, movement/camera observations, detection fairness, failures and retries. Do not mark v2 as passing until that evidence exists.

### Known limitations

- The recovery unit steers with probes, not a navigation mesh.
- Climbing is a defined point and tween, not free climbing.
- Crouching visually squashes the model; there is no dedicated crouch or climb pose.
- Detection/noise tuning has not been validated by recorded playtest.
- Prototype text is hard-coded Spanish and is not integrated with `NarrativeText`.
- Web performance and target GPU profiling have not been performed.
- Mission 1's inference puzzle and the puzzle-to-containment transition are not implemented.
- The test is not integrated into the campaign.

## Earlier prototypes retained

### Flooded Shelter 2.5D

The branch retains the earlier oxygen, interaction, generator, valves, rescue, localization and decision-summary experiment. It remains available for comparison; it is not the current direction for new gameplay work.

### Elena test room and art wrappers

The branch retains the earlier 3D room with movement, interaction, scanning, visual dressing, HUD and synthesized audio. Reusable elements include camera/presentation experiments, interaction targeting, scan feedback, Elena model/pose, environmental art and capture tooling. These do not automatically become production-approved assets.

## Art and asset status

Current models, lab kit, materials, shaders, lighting and HUD are a prototype library. Reassess scale, collision, traversal clearance, camera occlusion and silhouette from the third-person camera before production use. The MPFB/MakeHuman base-mesh licence remains unverified in the recorded provenance and must be resolved before shipping derived assets.

## Technical foundation and regression boundary

The last recorded Phase 0 run reported 11 passed, 0 failed, exit code 0. That historical result does not verify later changes. Re-run Phase 0 after relevant modifications and record the result.

Preserve input/autoload/resource-path contracts, save JSON/CRC32 behavior and Compatibility renderer assumptions unless an explicit impact review authorizes a change. Keep legacy scenes until the new slice has passed a human review.

## Next milestone: combined five-minute opening

1. Run/fix the motion/chase v2 test and record a manual playtest.
2. Tune movement, camera, climb, low tunnel, checkpoints and enemy fairness.
3. Design one compact Aster/Helix investigation puzzle with multiple clues, scan support and optional hints.
4. Connect puzzle completion to a lockdown response and the recovery unit.
5. Playtest the combined sequence; collect evidence on comprehension, fairness, tension, accessibility and performance.
6. Reconcile the full narrative and campaign specifications only after the owner reviews results.

## Documentation migration policy

The former 16-phase, dual-protagonist, combat-arena and ending specifications are marked legacy/under review for prototype work. Preserve their useful narrative and technical details; do not implement them as requirements for the current prototype without explicit reconciliation.

## Reporting rule

Distinguish code present, automated test coverage, test run successfully, manual playtest and production readiness. Never claim one on the basis of another.
