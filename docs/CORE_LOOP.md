# FINAL THAW — Core Gameplay Loop and Mission Contracts

**Status:** current runtime remains the as-built two-mission demo described in `FASE1_PREMIUM_AUDIT.md`; the owner-approved target redesign is not implemented or runtime-verified. The target preserves the Aster puzzle/field-notes loop, adds auxiliary power and a P−2 transfer-key chain, then moves into a human-operated clandestine building before the hybrid first-person escape and parking set piece. This document is not locked full-game canon.  
**Related authority:** `docs/VISION.md`, `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`, `docs/LEVEL_STRUCTURE.md`, `docs/design/MISSION1_GHOST_PROTOCOL.md`, `docs/design/FASE1_LOGIC_CONTRACT.md`, `docs/design/MOTION_CHASE_PROTOTYPE.md`.

## 1. Core loop

`Observe → Infer → Choose → Act → Read feedback → Adapt`

The player reads physical space, uses the scanner when information is worth the pause, forms a hypothesis, commits to a movement or system action, then interprets the world/enemy response. Investigation and movement should reinforce each other; they must not become disconnected puzzle-room and obstacle-course genres.

## 2. Player fantasy and design pillars

Elena Vast is a scientist in a hostile industrial system. The player should feel observant, capable and vulnerable, never helpless and never transformed into an action hero.

1. **Environmental inference:** clues emerge from machine state, cable/piping continuity, traces, signage, architecture and records.
2. **Physical agency:** movement and spatial choices have consistent, learnable outcomes.
3. **Bounded threat intelligence:** the recovery unit sees and hears under explicit rules and searches where it last had evidence.
4. **Legible consequence:** system changes affect lights, doors, machines, sound or threat state in a way the player can read.
5. **Fair recovery:** failure teaches something and permits a quick retry.
6. **Narrative restraint:** a small number of specific discoveries carry more weight than constant exposition.

## 3. Mission 1 — The Ghost Protocol

**Primary verb:** understand.  
**Status:** design specified; implementation/integration and playtest pending.

Elena enters the Aster facility, reconstructs the intended electrical/system configuration, compares it with the physical A→T diversion, uses maintenance to inspect the system, stabilizes the circuit under the existing `FASE1_LOGIC_CONTRACT.md`, and consults the restricted record. The machine test itself never starts.

The puzzle must be solved through at least two complementary clues. The scanner reveals continuity and state, never the answer. Wrong or premature actions have immediate, recoverable feedback. The restricted record supplies context and does not act as a key.

**Required outcome:** the player understands that the test result was withheld or manipulated and that the investigation creates a queued service audit. The mission-level interaction with maintenance queues `SERVICE_OVERRIDE` without changing the electrical reference model; opening the exterior leaf of G sends the queued audit and starts Containment exactly once. Reading the record adds `RESTRICTED_RECORD_READ` but is not the trigger. Runtime implementation and the exact recipient/supervision remain to be verified/decided.

## 4. Mission 2 — Containment

**Primary verb:** escape.  
**Status:** movement/chase prototype exists; integrated mission design is specified in `docs/LEVEL_STRUCTURE.md`; runtime verification pending.

The player first evades quietly through potentially occupied work areas, using real cover, timing and noise discipline. The recovery unit patrols/searches and follows through existing circulation; after the lift to P0 it reacquires Elena at R1 and the experience shifts to a running chase. Earlier reacquisition can start the chase sooner only when the unit has real line of sight. Walking, running, crouching, jumping, the authored climb and scanner use are tactical choices, not checklist mechanics.

### Decision model

At each major beat the player should answer:
- What is the goal or next readable landmark?
- What can the threat currently perceive?
- Which route trades time, exposure and traversal risk in my favour?
- What evidence would tell me that the decision worked?
- If I am detected or fail a movement, what fair recovery remains?

### Threat contract

- Vision requires range, facing and clear line of sight.
- Noise directs investigation to a location; it does not grant omniscience.
- Losing sight transfers the chase to the last known position and a bounded search.
- The unit respects geometry and cannot use unshown shortcuts or pass through vehicles/walls.
- A visible/audio telegraph precedes full alert/chase.
- Detection remains understandable after the event through HUD/audio/state feedback.
- The scanner gives temporary information with a meaningful opportunity cost. It does not solve the encounter automatically.

These are design requirements; their presence in code must be separately tested in the current build.

## 5. Phase 1 → Phase 2 continuity

The current **as-built** sequence remains `Solve Aster system → consult restricted record → open exterior leaf of G → audit sent / Containment starts → quiet evasion → recovery-unit reacquisition → running chase → service yard`. The owner-approved **target** sequence is `collapsed breach → explore abandoned building → solve Aster and consult record; independently restore auxiliary power and find TRANSFER_KEY → open concealed P−2 door in the dead workshop → observe human personnel in the active second building → detection → hybrid first-person escape with route choices/context actions → parking garage → public street`. The door requires Aster record read + PowerRestored + TRANSFER_KEY. The P−2 threshold replaces G as the narrative handoff in the target; G-to-yard and the robotic recovery unit remain as-built behavior until code migration and tests prove the replacement.

The exterior door at G starts Containment, not an immediate uninterrupted sprint; a quiet evasion section precedes the running pursuit. G does not teleport Elena into the parking lot. The current parking prototype's entry checkpoint is test infrastructure only, not the canonical handoff. The integrated route preserves Elena's transform at P2-01, the physical service threshold; P2-CP is a recovery-only checkpoint 1.5 m inside the vestibule. The standalone corridor start must remain usable for mechanics testing.

For the target redesign, the principal threat in the active second building is human-operated; the current robotic recovery unit is existing as-built behavior and must not be mistaken for the approved target. Human detection, suspicion, communication and chase behavior still require implementation and playtest.

## 6. Mission 2 narrative progression

| Beat | Player experience | Narrative function | Required delivery |
|---|---|---|---|
| Exit to service forecourt | Relief interrupted by evidence of active security | Show escape is not safety | Environment, lighting, distant system response |
| First detection risk | Player reads the recovery unit | Establish that it searches under bounded rules | Facing, alert tell, clear line-of-sight behavior |
| Cover route | Player uses vehicles/columns as spatial information | Make the site feel operational and dangerous | Sightline breaks and distinct route trade-off |
| Exposed crossing | Player chooses when to move | Turn tension into agency | Fair telegraph, recoverable detection |
| Service bottleneck | Player commits to a physical route | Show security is embedded in infrastructure | Plausible shutter/barrier state and visible affordance |
| Escape threshold | Immediate pursuit is broken | Deliver temporary release, not resolution | After crossing the gate, the reader shows “PROTOCOLO DE CONTENCIÓN: ACTIVO / SECTOR EXTERIOR”; perimeter lights/access states change in sequence. Elena: “Fuera del perímetro. Eso no significa que haya terminado.” Short, skippable, no input lock |

The recommended implication is that the facility's security response is coordinated across the site. This remains a **proposal**, not established canon. Do not name a person responsible, reveal a wider conspiracy or decide Marcus's role through environmental dressing alone.

## 7. Scanner, feedback and accessibility

- Scanner charge, reveal duration and cooldown must match implementation and HUD.
- Critical threat state uses symbol/shape and sound in addition to colour.
- Important sound cues require visual alternatives.
- Critical instructions and narrative dialogue need subtitle/transcript treatment.
- The level must not require colour discrimination, hearing alone or a mandatory optional scan.
- Movement affordances must be visible from the third-person camera; no precision jump may depend on a hidden ledge.
- Optional hints may clarify goal, clue relationship or movement affordance, but must not directly reveal a puzzle solution unless an explicit accessibility mode requires it.
- The player can pause/retry and recover from ordinary failure without losing established mission knowledge unless a separate persistence decision says otherwise.

## 8. Out of scope until explicit approval

No weapons, mandatory combat, full inventory, dual-protagonist switching, legacy 16-phase campaign commitment, new save schema, new lift/stair shortcut, unreviewed renderer change or final-art expansion is implied by this opening. Existing legacy documents remain historical source material while the prototype-led direction is evaluated.

## 9. Evidence and acceptance

Collect real playtest evidence rather than invented targets:
- movement completion and failure points;
- player understanding of enemy detection and search;
- route choice and use of cover;
- scanner use and perceived forced waiting;
- time to retry and checkpoint fairness;
- camera/collision frustration and motion discomfort;
- comprehension of the Aster reveal and the Phase 1 → Phase 2 causal link.

A design criterion is not accepted merely because a function or node exists. Distinguish: **specified**, **implemented**, **covered by a test**, **test executed**, **hands-on validated**. The programming owner records engine version, renderer, commit, exact commands/results, warnings/errors and manual QA evidence.

## 10. Owner-approved experience contract — 2026-10-15

This section records the latest approved direction for the next production pass. It is a target contract, not evidence that the current build implements it.

### Phase 1 — understand a connected place
The player explores a substantial industrial research facility anchored by a large central pumping hall. Surrounding rooms and vertical routes must have distinct functions and visible relationships to the hall. Use environmental landmarks, purposeful backtracking, optional discoveries and causal mechanisms. Avoid a single open room, a maze, and repeated traversal without new information or access. The existing Aster puzzle and field-notes loop should be retained where correct.

Elena enters through a damaged service breach/culvert that collapses physically behind her. The original entrance must be blocked by geometry and collision. Phase 1 remains investigation-led; Elena is a scientist, not a mandatory combat protagonist.

### Phase 2 — observe, be detected, escape
The target Phase 2 begins with Elena cautiously entering a new operational zone where human personnel are doing meaningful work related to Helix/Aster. She observes and discovers information before a human threat detects her. This supersedes the robot as the intended principal antagonist for the redesigned sequence; the existing robot implementation remains part of the as-built record until the replacement is implemented and tested.

The escape is hybrid first-person gameplay: free movement and meaningful route choice, plus short contextual actions such as vaulting, ducking/sliding, pushing an object or operating a mechanism. Brief looks back may show player-caused consequences. Prompts must be accessible and contextual, and the sequence must remain playable rather than becoming a QTE-only video.

The route ends through a separately designed parking garage and then a public street, where Elena loses the pursuers among pedestrians. A credible service connection or deliberate scene transition is acceptable; maintain continuity of movement, sound and narrative.

### Future Marcus-led beat-'em-up contract
The future beat-'em-up phases are played as Marcus with Elena accompanying him. Initially Elena cannot reliably defend herself and seeks cover; Marcus must intervene when she is threatened. As the story progresses, Elena learns limited defensive abilities from Marcus and can later escape grabs, avoid/block basic attacks and opportunistically counter minor threats. She remains less combat-specialized than Marcus. Once she becomes more autonomous, encounters should challenge Marcus through enemy variety, coordination and attack patterns rather than inflated health alone.

This is a future design contract. Full Marcus combat and Elena's companion progression are outside the current Phase 1/2 implementation scope. Keep the systems separable and record their future acceptance criteria without adding unapproved combat features to the current demo.

**Status:** specified 2026-10-15. Not implemented, not prototyped, not tested.

**Roles.** The player controls Marcus. Elena is an AI companion with her own goals: survive, observe, help. She is never an escort cargo bar. Marcus fights. Elena reads the space: she tags threats, spots mechanisms and finds routes. The Aster wrist unit stays a scientific instrument and never becomes a weapon.

**Elena's progression.** Each stage is unlocked by a story beat in which Marcus teaches her, never by experience points. She never fights as well as Marcus.

| Stage | When | What Elena can do | What Marcus must do |
|---|---|---|---|
| E0 Dependent | first beat-'em-up phase | moves between valid cover points; calls out threats; flees grabs only with Marcus's help | intercept anyone who targets her; free her from grabs within a visible, generous window |
| E1 Aware | after the first lesson | can also break a basic grab once; she telegraphs the attempt | intervene against armed or heavy enemies; basic ones she can stall |
| E2 Defensive | mid-story | can also dodge or block basic attacks with a clear readable timing; she still takes damage from heavy attacks | focus on elites and coordinated groups |
| E3 Opportunist | late story | can also counter a staggered basic enemy, and briefly trigger an environmental mechanism (shutter, valve, light) | handle the encounter's main threat; Elena manages minor pressure |

**Companion rules (all stages):**
- Elena's state is always readable, from her pose and a non-colour-only marker: safe, threatened, grabbed or hurt.
- Threats against Elena are telegraphed long enough for Marcus to react from anywhere on screen. Default 1.5 s; assist options lengthen it.
- She never blocks Marcus's path or his attacks. She never runs into an active attack. She never chooses cover in a hazard.
- **Failure is fair.** If Elena is overwhelmed, she enters a *downed* state with a rescue window; failure restarts at the encounter's checkpoint and never ends the run. A difficulty option can make her invulnerable.
- **Encounter difficulty grows** through enemy variety, coordination (flankers, a caller who radios, a grabber who targets Elena) and attack patterns. Inflating health is not a lever.

**Separable interfaces (to build later).** Defined now so the Phase 1/2 systems do not grow combat code:
- **Cover points:** `Marker3D` nodes in group `companion_cover`, with metadata `quality` (0–1) and `faces` (direction).
- **Threat contract:** the human AI of Phase 2 already exposes `perception`, `suspicion` and `state` per agent. A future enemy adds `attack_intent(target)` and `telegraph_time`. Elena's companion AI reads only these signals.
- **Instructions:** the companion receives at most two instructions, `stay_close` and `hold_cover`. No squad commands.

**Acceptance criteria (future):**
1. A first-time player understands why Elena cannot fight yet, without a tutorial text wall.
2. In E0, no Elena failure happens without a telegraph Marcus could have answered.
3. In playtests, Elena's E1–E3 actions read as learned from Marcus. They do not feel like a sudden power-up.
4. Every encounter can be completed with assist options on, which slow telegraphs and lengthen rescue windows.
5. Combat systems live in their own scenes and scripts; the Phase 1/2 demo loads none of them.

**Out of scope now:**
- any combat input, hit detection or health for Elena or Marcus in the current demo;
- any Marcus character production beyond the existing spec (`docs/art/MARCUS_MPFB_SPEC.md`).

### Visual identity contract
The target is illustrated 3D adventure art based on the owner-provided Marcus concept and illustrated industrial laboratory reference. Do not target photorealism, generic cartoon aesthetics or deliberately low-resolution retro styling. Validate character and environment treatment in Godot at gameplay distance. Elena's scanner must be credibly wrist-mounted/holstered or animated through draw/use/stow; it must not appear stuck to her hand.
