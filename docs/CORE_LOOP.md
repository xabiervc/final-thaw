# FINAL THAW — Core Gameplay Loop and Mission Contracts

**Status:** current design direction for the two-mission opening. Mission 1's system puzzle is designed but not integrated; Mission 2 has a movement/chase prototype but has not passed its recorded v2 verification gate. This document is not locked full-game canon.  
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

The intended continuous sequence is:

`Solve Aster system → consult restricted record → open exterior leaf of G → audit sent / Containment starts → quiet evasion through F/E and potentially occupied work areas → recovery unit reacquires Elena at a mapped exposed threshold → running interior chase → selected alternative exit → parking entry → parking chase`.

The exterior door at G starts Containment, not an immediate uninterrupted sprint; a quiet evasion section precedes the running pursuit. G does not teleport Elena into the parking lot. The current parking prototype's entry checkpoint is test infrastructure only, not the canonical handoff. The integrated route preserves Elena's transform at P2-01, the physical service threshold; P2-CP is a recovery-only checkpoint 1.5 m inside the vestibule. The standalone corridor start must remain usable for mechanics testing.

The design does not yet establish whether the recovery unit is a human, robot or other specific entity beyond the current prototype's recovery-unit presentation. Keep identity and command chain open until the story decision is made.

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
