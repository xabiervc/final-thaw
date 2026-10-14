# FINAL THAW — Working Vision (Prototype-Led Redesign)

**Status:** working vision for the next playable prototype; not yet locked full-game canon.  
**Implementation reference:** [Motion/chase prototype](design/MOTION_CHASE_PROTOTYPE.md).

## North star

Final Thaw is a cinematic science-fiction climate thriller about a scientist uncovering a consequential truth and surviving the system that wants to silence her. Its moment-to-moment identity should come from physical traversal, environmental inference, stealth under pressure, and discoveries that change the player's understanding of Helix.

The player should feel intelligent and vulnerable—not powerless, not an action hero. The world is dangerous, but its rules are legible enough to learn.

## Player fantasy

As Elena Vast, the player reads a hostile industrial environment as a system that can be understood, uses a scanner to find evidence and routes, crosses physical obstacles through timing and movement, manages the risk of being heard or seen, and uncovers evidence connecting Helix to the Aster project and personal loss.

Elena is a scientist, not a soldier. Combat, firearms and elaborate melee are not part of the current prototype.

## Core emotional target: tension with agency

| Emotion | Design mechanism |
|---|---|
| Curiosity | Environmental clues, scan traces, machine states and unexplained evidence |
| Tension | Sound, line of sight, a searching pursuer and risky traversal |
| Competence | Consistent movement, learnable hazard rules and clear enemy tells |
| Consequence | Solving a system changes the environment and triggers a response |
| Hope | Evidence shows Helix's actions are not inevitable and Elena can still act |

## Working pillars (hypotheses to validate)

1. **Physical traversal is the action.** Gaps, low passages, authored climbs, cover and unstable machinery create varied decisions.
2. **Investigation rewards inference.** The scanner reveals useful information; it does not simply mark the correct switch.
3. **Threats obey readable rules.** Detection, sound, line of sight, search and recovery need understandable feedback and counterplay.
4. **Actions cause the next situation.** The investigation and escape are linked: activating a system reveals something and triggers containment.
5. **Failure teaches and retries quickly.** Players understand what went wrong and return close to the failed challenge.

## Proposed opening

### Mission 1 — The Ghost Protocol (not yet implemented)
Elena investigates a Helix facility to reconstruct what happened to an Aster test. The player combines environmental clues and infers a system configuration. The result changes the environment, reveals one meaningful contradiction in Helix's account and triggers a containment response.

### Mission 2 — Containment (prototype foundation exists)
Elena traverses the laboratory and service forecourt while a recovery unit searches for her. The mechanics prototype currently tests gaps, a low duct, an authored climb, noise and line of sight; these are candidate mechanics, not a mandatory checklist for the canonical level. The final architectural plan determines which are retained, and each retained traversal must be justified by the physical site and measured in the greybox.

**Code boundary:** the isolated motion/chase prototype implements movement, jump, crouch, a defined climb, scanner reveal, checkpoints and a recovery-unit state machine. It does not yet implement Mission 1's inference puzzle or the narrative bridge. See `docs/design/MOTION_CHASE_PROTOTYPE.md`.

## Narrative material to preserve provisionally

Elena, Iris, Helix, the Aster climate-stabilization project, evidence of a concealed/manipulated Aster test, Dr. Selene Voss, and a recovery unit sent after Elena remain the opening's narrative foundation. The precise chronology, Marcus's role, full campaign structure, ending rules and total duration remain under review. Do not silently discard established story facts; propose changes explicitly.

## Anti-pillars

- No generic combat arenas or enemy waves just to create action.
- No arbitrary symbols or trial-and-error as the main puzzle method.
- No enemy that knows Elena's position after losing sight.
- No instant-fail hazards without clear warning.
- No long backtracking after a mistake.
- No scanner that turns the environment into a list of answers.
- No production-art expansion before camera, movement and readability are tested.
- No award-readiness or full-game-quality claims without evidence.

## Prototype scope

**In scope:** third-person movement/camera; jump, crouch and one authored climb; recovery unit with patrol/investigate/alert/chase/search/return; noise and line-of-sight; scanner reveal; one compact investigation puzzle and a causal containment transition after traversal is validated.

**Out of scope for this test:** the full 16-phase campaign, final duration/endings, Marcus combat, weapons, boss fights, skill trees, large inventory, wholesale art replacement, renderer migration, save-schema changes.

## Technical and accessibility constraints

Preserve the Godot 4.7.x baseline, Compatibility renderer and Phase 0 input/autoload/resource/save/CRC32 contracts unless an explicit review approves a change. Measure performance on target rather than assuming it.

From prototype stage provide non-colour-only threat cues, readable text, remappable actions, adjustable camera sensitivity, clear audio/visual detection signals and short retry loops. Crouch/climb animation, camera comfort, localization, controller parity, Web performance and broader accessibility still need validation.

## Evidence gate

Before promoting this vision to full-game canon, record a hands-on playtest demonstrating responsive movement, readable camera/collision, fair threat behavior, a meaningful route/timing/concealment decision, useful scanner trade-offs, a causally linked puzzle/escape, short informative failure recovery, clean loading and acceptable target performance. Only then revise the full-campaign documents.
