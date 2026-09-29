# FINAL THAW — Game Design Document

## 1. High Concept

**Final Thaw** is a single-player isometric action-adventure for Godot 4.x. In 2089, a climate-collapse emergency has fractured public order. Atmospheric scientist **Dr. Elena Vast** carries the Aster Protocol, a prototype capable of slowing a cascading planetary feedback loop. Former officer **Marcus Reyes** is sent to locate her, then learns that the Helix Consortium intends to seize the protocol and restrict survival to protected zones.

The game alternates between Elena's environmental puzzles and Marcus's compact beat-'em-up combat. Later, the player switches between both characters to solve spaces that neither can complete alone.

## 2. Player Promise

- Play two distinct but equally necessary protagonists.
- Solve readable, deterministic environmental problems as Elena.
- Use deliberate, readable combat as Marcus.
- See visible consequences from protection, aid, and evidence decisions.
- Reach one of three outcomes whose logic is shown, not hidden.

## 3. Target

| Item | Target |
|---|---|
| Engine | Godot 4.x |
| Perspective | Stylised 2D/2.5D isometric |
| Mode | Single-player |
| Length | 2.5–3.5 hours |
| Structure | 3 acts, 17 phases |
| Art | Industrial grey, toxic green, wildfire orange, floodwater blue, storm white |
| Scope | Focused linear chapters, not an open world |

## 4. Core Pillars

### Readable isometric spaces
Every room must have a clear silhouette, reliable collision, ground-contact shadows, and non-colour-only interaction feedback. Camera/camera framing must never hide the critical route or puzzle state.

### Complementary protagonists
Elena changes the environment; Marcus survives and controls threats. Neither protagonist is a weaker copy of the other.

### Escalation by recombination
Later chapters combine established mechanics rather than continuously introducing expensive systems.

### Determinism
Enemy patterns, hazards, platforms, water systems, minigame solutions, and endings have predictable rules. Same inputs and saved state produce the same outcome.

### Visible consequences
The player can inspect Elena Safety, Prototype Integrity, Civilian Aid, and the final evidence choice. The ending calculation is documented and never silently changed.

## 5. Core Loop

1. Enter a compact readable space.
2. Observe threat, route, puzzle state, or character limitation.
3. Use Elena's systems knowledge or Marcus's direct action.
4. Resolve the room through a deterministic sequence.
5. Receive a clear state change: opened route, restored power, civilian rescued, encounter cleared, evidence found.
6. Save/checkpoint and move forward.

## 6. Character Gameplay

### Elena Vast
- Movement, jumping, short climbing, pushing/pulling light objects.
- Scanning to identify nearby systems and interactables.
- Power routing, pumps, valves, lifts, cranes, doors, security systems.
- Aster calibration at explicitly marked machinery.
- Non-lethal traversal and observation.

### Marcus Reyes
- Movement, sprint, dodge, block, grab, throw.
- Light/heavy attacks and fixed three-hit combo.
- Environmental throws, breakable barriers, cover against marksmen.
- Combat protection during Elena's exposed system interactions.

## 7. Consequence State

| Variable | Start | Range | Meaning |
|---|---:|---:|---|
| Elena Safety | 3 | 0–3 | Reduced by direct, clear failures in joint missions |
| Prototype Integrity | 3 | 0–3 | Reduced by major prototype hazards/failures |
| Civilian Aid | 0 | 0–10 | Raised by optional rescue and assistance objectives |
| Evidence Choice | unset | preserve / erase | Final stance toward Helix evidence |

### Ending rules
1. **Fragile Thaw** has priority if Elena Safety <= 1 OR Prototype Integrity <= 1.
2. Otherwise, **Public Thaw** requires Civilian Aid >= 4, Prototype Integrity >= 2, and Evidence Choice = preserve.
3. Otherwise, **Guarded Thaw** applies.

## 8. Enemy Roster

| Enemy | Role | Counterplay |
|---|---|---|
| Desperate Scavenger | Fast, weak melee group | Spacing, combo, throws |
| Helix Enforcer | Tough melee, block/counter | Flank, environmental throw |
| Corporate Marksman | Ranged line-of-sight threat | Cover, flanking, approach |
| Shield Unit | Frontal defense | Flank, grab/bypass, environment stun |

## 9. Structure

### Act I — Separation
- Phase 0: Technical Foundation
- Phase 1: Elena movement and observation
- Phase 2: Abandoned Laboratory
- Phase 3: Marcus combat fundamentals
- Phase 4: Highway Riots
- Phase 5: Broken Vehicle minigame
- Phase 6: Flooded Shelter
- Phase 7: Militia Encirclement
- Phase 8: First Contact

### Act II — Cooperation
- Phase 9: Calibrate Aster minigame
- Phase 10: Collapsing Dam
- Phase 11: Port Mutiny
- Phase 12: Free Switching

### Act III — The Final Thaw
- Phase 13: Final Thaw Station
- Phase 14: Helix Retrieval Commander
- Phase 15: Choice of Spring
- Phase 16: QA and Release

## 10. Scope Boundaries

No open world, procedural generation, loot economy, online multiplayer, branching dialogue tree, dozens of enemies, or photorealistic asset pipeline. Act I is a self-contained vertical slice. Acts II–III expand established systems into the full experience.
