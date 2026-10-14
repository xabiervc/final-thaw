# FINAL THAW — Level Structure for the Opening Prototype

**Status:** current opening structure under validation. The legacy 16-phase campaign is not approved as scope for this prototype.  
**Implementation reference:** `docs/design/MOTION_CHASE_PROTOTYPE.md`.

## Current playable structure: motion/chase test

`scenes/prototypes/motion_chase_prototype.tscn` is a single approximately 80 m traversal test built by `scripts/prototypes/motion_chase_prototype.gd`. It is a mechanics sandbox, not a finished campaign level.

| Beat | Current geometry/behavior | Purpose | Limitation |
|---|---|---|---|
| Start | Open area with controls in world | Learn controls/camera | Tutorial text is hard-coded Spanish |
| Gap 1 | About 1.8 m | Learn ordinary jump | Validate hands-on |
| Vent tunnel | Low ceiling, crouch passage | Teach crouch and camera occlusion | Current crouch visually squashes model |
| Gap 2 | About 3.0 m | Encourage run-up before jump | Validate forgiveness and feel |
| Recovery-unit zone | Cover pillars, patrol and low duct | Teach sight, sound and hiding | Steering uses probes, not navigation mesh |
| Climb/catwalk | Authored climb point | Elevated route the unit cannot climb | Defined tween, not free climbing |
| Gap 3 / exit | Final gap and exit | Route choice and end of test | Alternatives need hands-on validation |

The scanner temporarily reveals the unit, its cone, patrol points and labels for alternative routes. The unit can patrol, investigate noise, raise awareness, alert, chase the last position seen, search and return. Contact or falling returns Elena to a checkpoint.

## Proposed two-mission opening

### Mission 1 — The Ghost Protocol (not implemented)

**Structure:** enter → observe/scan → inspect evidence → infer system configuration → operate system → reveal Aster/Helix evidence → trigger containment.

Build this after traversal and chase are validated. Use one compact, hand-authored industrial space and one multi-step system puzzle. Avoid four consecutive rooms using the same interaction pattern.

### Mission 2 — Containment (current prototype foundation)

**Structure:** notice lockdown → choose a traversal route → cross a gap → use a low passage or elevated climb → manage noise and line of sight → react to pursuit → escape → short narrative aftermath.

The current motion/chase test provides a starting point for traversal and pursuit. It does not yet contain the Mission 1 puzzle, evidence reveal, cinematic beat or full narrative integration.

## Level-design principles

- Every obstacle should teach a rule or force a decision.
- Show a safe landing or communicate danger before demanding a precise jump.
- Alternative routes must have different risk profiles, not be cosmetic detours.
- The recovery unit obeys physical constraints and bounded knowledge.
- Scanner information supports planning, not automatic solution.
- Avoid repeated rooms, empty corridors, arbitrary timers and mandatory trial-and-error.
- Keep the route short enough to replay after failure.
- Validate scale, collision, ledge clearance, camera occlusion and visual readability from the actual third-person camera.

## Acceptance gate

Record a manual playtest verifying that all traversal is completable; jump/climb failures are understandable; crouch spaces remain camera-readable; at least one alternative route evades the unit; the unit does not track through walls; checkpoints avoid long retries; the route is understandable without HUD-only guidance; and the scene produces no script/resource errors.

## Legacy content

Prior tables for the abandoned lab, flooded shelter, dam, combat arenas and 16-phase campaign remain historical design material. They are not requirements for this prototype. Reconcile them only after owner review of prototype evidence.
