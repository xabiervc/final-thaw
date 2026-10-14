# Phase 1 — The Ghost Protocol: grand design

Status: design proposal for design and script validation. Not built. It does not decide the narrative items listed in section 9. It builds on FASE1_ROOM_COMPLEX.md (layout), FASE1_LOGIC_CONTRACT.md (circuit) and MISSION1_GHOST_PROTOCOL.md (premise).

## 1. Intent

A flood-control wing of Helix, abandoned in the middle of the thaw, that the player reads like a crime scene, level by level, until the building itself shows what was hidden — and then answers back.

Pillars:

1. **Read the place.** Infrastructure is evidence. Elena understands what a pipe, a cable or a tide line means.
2. **Height is story.** You go down to find the cause and up to understand it.
3. **One system, many rooms.** There is a single investigation; every room contributes a different kind of clue.
4. **A place that reacts.** Power states change light, sound and mood in the rooms the player has already visited.
5. **Consequence.** The ending throws the building at Elena and hands over to the escape.

Target length: 12 to 15 minutes on a first playthrough, 6 to 8 on a replay. These are goals to verify, not promises.

## 2. The place: Helix Test Bay B

A flood-control wing evacuated during the thaw, matching the art direction already built for the test room: meltwater tide lines on the walls, flood barriers, a frosted shutter, a pump and gauge, a warming station, an evacuation plan and lockers.

**The Column.** One landmark ties the six rooms together: the Aster calibration column, a vertical test rig that rises through the test hall and past the catwalk. It is visible from almost everywhere. Its light rings show which circuit branches are live, so the player always has a diegetic sense of the state of the building without a HUD telling them what to do. The Column never shows the solution, only consequences.

Tone: cold, quiet, wet. Frost where it was warm, water where it was dry. No bodies, no tanks, no gore. Anything involving people stays implied.

## 3. Beat sheet

| Time | Room (level) | What the player does | Feeling | Hero moment |
|---|---|---|---|---|
| 0:00 | Entry vestibule (0 m) | Arrives, orients, sees the closed shortcut door above | Curiosity | The window |
| 1:30 | Test hall (0 m) | Reads the room, finds the three exits, learns the scanner on visible traces | Orientation | The Column |
| 3:00 | Service pit (-2 m) | Descends, compares schematic and tampered bridge, restores maintenance | Suspicion, then progress | The descent, the building wakes |
| 5:30 | Pump room (+1.5 m) | Breathes, finds the warming station, looks back down, climbs on | Relief, resolve | Optional resonance point |
| 7:00 | Catwalk (+3 m) | Sees the whole bay, reads indicators, operates selector and isolator | Comprehension | The vista, the trip |
| 9:30 | Archive cabin (+3 m) | Consults the archive, reads the record, extracts it | Revelation | The answer |
| 11:00 | Cabin glass wall | Watches the building close around her | Dread | Containment |

## 4. Six hero moments

1. **The window.** From the entry the player sees, through the hall door, a lit window high up: the cabin. The goal is visible before the way is known. Needs a clear sightline and a lit cabin window.
2. **The descent.** The stairs into the pit take the camera down with Elena. The sound changes first: water, echo, no hum. Needs pit ambience and a darker light state.
3. **The building wakes.** Throwing the maintenance switch brings power up in stages along the pit, then the Column's first ring, then a hum that is heard in the hall above. It should feel like a machine coming back, not a switch.
4. **The vista.** Reaching the catwalk opens the view down over the whole hall. The camera pulls back slightly in that zone so the player can compare what they learned below with what they see above.
5. **The trip.** The first wrong configuration trips the protection: lights dip, the alarm pips, the Column rings flicker, nothing is lost. It teaches that the building has rules and that mistakes are readable.
6. **The answer.** Extracting the record triggers containment. Seen through the cabin's glass wall, the hall's flood barriers close in sequence, the Column's rings go red and routes disappear. Control returns while the shutters are still moving.

## 5. The investigation as place-reading

The clue chain keeps the approved logic and gives each room one job.

| Clue type | Where | What it says |
|---|---|---|
| Documentation | Pit schematic | How the distribution should work |
| Anomaly | Pit, tampered bridge | What was changed and where |
| Demonstration | Catwalk indicators | What the change causes |
| Verification | Cabin diagnostic | Whether the player's idea is right, without naming the control |

The scanner reveals continuity, traces and thermal history (frost lines, wet paths, cable runs). It never marks the answer. Hints are requested, escalate in three steps, and never name a control. A wrong guess trips protection but loses nothing.

## 6. Atmosphere systems

- **Light states.** Cold white as the base, amber for things that can be used, cyan for Elena and Aster technology, red for danger, green for safe. Rooms already visited brighten as power returns.
- **Sound.** Room tone and drips, the generator hum, the alarm pip, footsteps by surface. Each level has its own ambience; the hum swells with each restored branch. All current sound is synthesized and needs a listening pass.
- **The thaw.** Meltwater is visual only: puddles and tide lines, a slow drip, a little more water in the pit after each milestone. It is never a timer, and the pit exit never depends on it.

## 7. Camera and controls

Third-person orbit, walls dither away when they hide Elena, wider framing in vista zones, no cutscene that removes control for more than a few seconds. Required verbs: move, jump (rarely needed), interact, scan. Crouch and climb are not required in this phase.

## 8. Production plan

**Exists now:** six-room layout with stairs and shortcut, circuit model and tests, facility materials, HUD, wall dither, Elena with 13 animations, synthesized audio, the test-room set pieces (barriers, shutter, pump, gauge, warming station, lockers).

**To build, in order:**

1. **Dress the rooms.** Put the central machine and the Column in the hall, set pieces and tide lines in every room, lighting per room, and hide world signs outside the current room. Acceptance: each room reads differently at a glance, in grayscale too.
2. **Make the clues real.** Schematic, bridge, selector, isolator, indicators, terminal and diagnostic as objects wired to the circuit model. Acceptance: all circuit tests pass in play and the deduction test is run with unfamiliar players.
3. **Power states.** Staged power-up, the trip, the Column rings, light changes in visited rooms. Acceptance: each state is distinguishable without color.
4. **Record and containment.** Archive record, extraction, barrier sequence. Blocked until script approves section 9.
5. **Hand-over.** Place the escape start in the cabin and reuse the learned routes. Acceptance: the escape uses at least two places the player explored.

**Requests to the Blender team:** the Column with named emissive rings; selector, isolator and indicator panels; schematic board; tampered bridge assembly with scorch marks; archive terminal with screen states; cabin glass wall; hall machine housing. Each with named emissive parts and no collision.

## 9. Decisions needed from design and script

| Decision | Options |
|---|---|
| What the record proves | A precise fact about the Aster test and the decision to withhold it |
| Aster and the scanner | What Elena carries on entry and where her scan ability comes from |
| Why extraction triggers containment | An authorization check, a physical lock, or a different cause |
| Use of Iris and Selene | Whether the existing memory fragments become optional resonance points here |
| The lift | Keep the fixed stairs, or add the lift as a later, separately validated option |
| Tone limits | Confirm no bodies or tanks, with people only implied |

## 10. Risks

- A beautiful hall that explains nothing. The Column and the tide lines must carry information, not just mood.
- Dressing cost on the target GPU. Keep draw calls and lights near the budget measured for the dressed test room.
- Overlong first playthrough. Cut optional content before cutting clarity.
- Hints that give the answer. Test the hint ladder with players who have not read the design.

Nothing here has been validated by play. Every acceptance line must be checked in Godot and by watching players.
