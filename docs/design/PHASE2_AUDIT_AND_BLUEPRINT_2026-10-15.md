# FINAL THAW — Independent audit, design reconciliation and implementation blueprint

**First issued:** 2026-10-15 · **Corrected:** 2026-10-16 · **Branch:** `feat/godot-vertical-slice` · **Commit audited:** `073f8a7` (in sync with `origin`) plus the untracked working tree of §1.2
**Scope:** audit and design only. No game code, scene, asset or project setting was changed. The only repository additions are this file and `prompts/sonnet_phase2_human_escape_handoff.md`.
**Status:** a dated audit record, not a design authority. `docs/DESIGN_AUTHORITY.md` stays authoritative. §11 says which existing documents absorb this content once built and accepted; then archive this file.

## 0. Correction notice

The 2026-10-15 version of this report concluded that Phase 1 was "essentially complete and mainly needs a human playtest". That was wrong in method. It treated the owner's feedback as hypotheses to be re-discovered and defended the build because its automated tests pass.

The owner has played Phase 1 and said what is wrong with it. **That feedback is established design input.** Repository inspection and new probes (§1.3) now serve to locate each problem, scope the change and define how to verify it, not to decide whether the problem exists. Where this version still writes "unverified", it means the *measurement of the fix* needs a person, not that the complaint is in doubt.

What changed in this version: §2 maps every piece of owner feedback to a change; §3 is a new Phase 1 redesign plan; §4 develops Phase 2 as a distinct playable sequence with the presentation options compared; §6 splits the work into essential corrections, Phase 1 design, Phase 2 construction and integrated validation. The valid technical findings of the first version are kept and re-verified.

## 0.1 Evidence labels

| Label | Meaning |
|---|---|
| **RAN** | Executed in this audit (command and result in Appendix A) |
| **SOURCE** | Read in the repository, not executed |
| **OWNER** | Reported by the owner from playing the game; established input |
| **PROPOSAL** | A recommendation of this audit; not canon, not approved |
| **UNVERIFIED** | Needs a person, hardware or a measurement not available here |

Captures and recordings are kept outside the repository in `D:/Projects/evidence/final-thaw/audit_2026-10-15/` and `audit_2026-10-16/`.

---

## 1. Executive audit

### 1.1 Verdict

Phase 1 works as a chain of objectives and does not work as an experience. The evidence for the owner's complaints is concrete:

1. **The interior was never redesigned.** Between the commit before the illustrated-art pass (`9bd68ac`) and today, every interior plan footprint is byte-for-byte the same (ground slab 30 × 23.5 m, pit 18 × 7 m, mezzanine, control and archive floors). The art pass swapped materials and added a new entry outside. "It feels like the previous version" is accurate.
2. **The central hall is mechanically inert.** Of 17 interactions in the investigation, **none** is in the hall; 8 are in one 24 × 5.5 m strip on the top floor. The sample of captures shows an open, dark floor with a pit and a column. A ground-floor room of about 9 × 5.5 m under the archive is reachable and empty.
3. **The story is delivered as text cards, and the intro gives the answer away.** The deduction the player is asked to make ("current went to two places at once") is stated in the intro and again in a bridge card and in hint level 1.
4. **Nobody is there.** Phase 1 has no human voice, trace or presence and no threat between the culvert collapse and the last door.
5. **Things that should block do not.** The selector, isolator, rearm button, archive console, diagnostic terminal and pump motors are built without colliders (source). A scan flags visible surfaces inside the capsule radius around them, and a capture of Elena at the maintenance anchor shows her overlapping the housing.
6. **Low obstacles are handled by one climb for everything.** Walking is blocked from 0.10 m; a jump clears 0.40 m; anything from 0.50 to 1.60 m triggers the same arms-up "climb". There is no step, vault or slide.
7. **The audio is configured correctly and is nearly inaudible.** The music and ambience are sub-bass drones (94 % of the recorded energy is below 120 Hz). On speakers that do not reproduce bass, the whole mix peaks around −21 dBFS.
8. **The English interface shows Spanish** because of Spanish defaults in a resource class.

The Phase 2 conclusion of the first version stands: the approved human escape is not in the running game; an unfinished human annex sits untracked and unwired.

**Recommended direction.** Fix the verified defects first (small, independent, no design decision). In parallel, run a design-lock step for a proportionate Phase 1 revision ("Station B Revision", §3) that makes the hall the stage, moves the deduction from text into physical evidence, adds human presence and escalation by action, and gives every room a reason to exist, within the existing footprint plus one purposeful room. Isolate the first-person chase in a reversible prototype. Complete the human Phase 2 behind a variant flag. Make "better" a person's judgement at the end of each milestone, not a test result.

### 1.2 Repository facts

| Item | Value | Label |
|---|---|---|
| Branch / HEAD | `feat/godot-vertical-slice` / `073f8a7`; 0 commits ahead or behind `origin` (re-checked 2026-10-16) | RAN |
| Working tree | 19 untracked entries: the owner's 17 (below) plus this file and the handoff. Nothing modified | RAN |
| Owner's untracked work | `assets/models/characters/people/` (12 GLB, 84 PNG, 49 MB), `scripts/phase2/helix_staff.gd`, `phase2_annex.gd`, `scripts/characters/person_visual.gd`, `tools/blender/people_mpfb/`, `tools/art/prepare_people_textures.py`, `compress_texture_imports.py`, `tests/test_texture_imports.*`, `tools/capture/people_sheet.*`, `tools/capture/_tmp/inspect_anim.gd` (scratch; do not commit). **Preserve all of it** | RAN |
| Engine | Godot 4.7.2.stable.official.ed1daf0bf; Windows 10; Intel HD 630; Compatibility renderer; ANGLE on Direct3D 11 | RAN |
| Phase 0 | `godot --headless --path . res://tests/test_phase_0.tscn` → 7 passed, 0 failed | RAN |
| Full suite | `tools/run_tests.sh` → **34 suites, 1053 PASS, 0 FAIL, 0 script errors** (docs say 33 / 1051; the gap is the untracked `test_texture_imports`) | RAN |
| Save safety | `save_0.json` MD5 identical before and after every run in this audit | RAN |
| Protected | Autoloads `InputSetup`, `GameManager`, `DebugManager`, `GameStateManager`, `NarrativeTextManager`; Jolt; `gl_compatibility`; circuit contract; save format | SOURCE |

### 1.3 New evidence gathered for this correction

All probes were throwaway scripts outside the repository. None wrote to the project.

| Finding | How | Result |
|---|---|---|
| Interior unchanged | `git diff 9bd68ac HEAD` on `phase1_building.gd` plan rectangles | Only material swaps and the entry channel changed |
| Interactions per zone | `_hotspots()` positions against the building plan | P2 strip 8 · pit 4 · P0 outside the hall 3 · M 1 · lift deck 1 · **hall 0** |
| Empty room | Capture `W2` and a ground-floor flood fill with the real capsule | West bay under F/G (x 0–9, z −10…−4.5) is reachable, 501 m² reachable on the ground level in total, contains only wall cabinets |
| Dead door | `phase1_building.gd` `StaffRefugeDoor` | A door painted on M's north (exterior) wall: "OFICINA DE TURNO", leads nowhere |
| Fixtures without colliders | `phase1_building.gd` `_p2()`: `static_visual` for `SelectorBody`, `IsolatorBody`, `RearmButtonBody`, `ArchiveConsole`, `DiagnosticTerminal`, `PumpMotor_*` | No collider by construction |
| Elena and the fixtures | Real controller walked toward each of the 20 interaction anchors from four sides | She can stand on all 20 (17 to within 0.01 m). Standing on an anchor is expected; together with the missing colliders and capture `H3` (Elena overlapping the maintenance housing) it shows the fixtures do not stop her |
| Visible-but-uncollidable surfaces | Grid scan: 8 667 free-capsule floor samples against 598 visible meshes | 132 cells of 1 m flag a visible surface inside the capsule radius, concentrated in the pit, the control strip and the S2 base |
| Climb reads wrongly | 0.6 m crate, real mantle, gameplay camera, frames `mantle_005/015` | The body rises vertically against the face with arms raised overhead, no hand contact, then stands on top. The capsule does not overlap the crate; the pose does not fit the obstacle |
| Audio is bass | Recorded the real flow (menu → intro → play), 80 s, Master bus | RMS −23.0 dBFS, A-weighted **−43 dBFS**; 94 % of energy below 120 Hz; 30 % below 20 Hz |
| Music layers | Spectrum of the four WAV layers | Investigation: 96 % below 120 Hz, A-weighted −37 dBFS. Release: a pure 120–500 Hz tone |
| Effects | Spectrum of 24 synthesised sounds | Pump hum, room tone, wind, landing and heavy steps 73–99 % below 150 Hz. Footsteps are mid/high but short (0.16 s) and quiet (about −25 dBFS peak in play). UI beeps are bright |
| What a laptop reproduces | The recording high-passed at 150 Hz | RMS −36 dBFS, peak −21 dBFS (13 dB quieter). Files in the evidence folder: `audio_laptop_sim_true_level.wav` |
| Narrative content | `data/game_text.json`, 306 keys | 6 examine cards, 6 Elena lines, 1 record, 6 PA lines; the answer is stated in `intro_line_2`, `ex_bridge_body`, `hint_circuit_1`, `archive_record` |
| Pacing | Route bot log | Whole route, perfect knowledge, 107.8 s of game time; Phase 1 has four objective lines |

### 1.4 Confirmed defects, ranked

**Experience (owner-reported, evidence above)**
- E1 Interior spatial design unchanged; hall inert; empty room; dead door.
- E2 Deduction pre-told by text; story delivered as cards; no human presence; no pressure before G.
- E3 Controls are small near-identical black boxes with painted labels; no visible cause and effect in space.
- E4 Fixtures and decorations without colliders.
- E5 Single climb for 0.5–1.6 m; no step-over, vault, slide.
- E6 Audio content inaudible on common speakers.
- E7 English shows Spanish.

**Technical (carried from the first version, re-verified)**
- T1 `StaffRadio` referenced and undefined (`scripts/phase2/helix_staff.gd:66`); bark keys missing; glass wall on layer 1 blocks staff sight (inferred from source: `Builder.wall_x` → layer 1; sight ray mask 1; needs a test); no garage scene; human annex unwired and untested.
- T2 People assets absent from `docs/art/PROVENANCE.md` (licences verified in the source files: all 12 skins and 13 clothes assets carry the CC0 header); credits omit them.
- T3 Document contradictions (§11).
- T4 49 MB of binaries untracked; each re-export adds about 32 MB to git history.
- T5 Perf: 33–43 FPS on ANGLE at Balanced (prior session's measurement, not re-measured); native OpenGL decision pending.
- T6 `tests/phase2/test_threat_agent.gd` has no scene; `game_text.gd` cites a test that does not exist.

**Unclear.** Camera frames `06b_archive.png` and `H1_selector_anchor.png` are near-black close-ups of a floor; may be a capture artefact (teleport plus camera snap) or an occlusion problem near low ceilings. Needs a live check.

### 1.5 What to keep, revise, expand, replace

| Keep | Revise | Expand | Replace |
|---|---|---|---|
| Culvert entry and collapse; circuit contract and 54-check oracle; mission state and event contract; field-notes loop; route graph and robot unit; route bot; capture/bench harness; options and remapping; Elena v2; people and clips; music director logic | Intro, hint and card copy; objectives; control fixtures and the status panel; the mantle motion and pose; audio content; room dressing; lighting and camera in the hall | The hall's role; the west bay (a real room); human presence; escalation by action; Phase 2 (annex, garage, street) | Painted-label-only room identity; the dead door; visual-only fixtures; the sub-bass audio content |

---

## 2. Reconciliation: owner feedback to concrete change

Summary first; each concern is then detailed with the six required statements.

| # | Owner concern | Headline change | Priority |
|---|---|---|---|
| 2.1 | Level design too similar, not substantial | Station B Revision: the hall as stage and readout, a real trial cell in the empty west bay, defined thresholds and signatures per room, the dead door removed, the exterior silhouette grown by the annex | Essential (hall, cell, signatures); desirable (office annex, camera/lighting zones) |
| 2.2 | Narrative and pacing | Three acts, evidence moved from cards to physical objects, intro no longer spoils, escalation by action, memorable set-pieces | Essential |
| 2.3 | Gameplay engaging, no needless backtracking | Hall has things to do; each room one purposeful action; traversal training beats; backtracking only for a changed state | Essential (hall), desirable (rest) |
| 2.4 | Electrical puzzle intuitive, not a checklist | Same logic; physical controls with feedback, a synoptic panel that shows what should happen against what does, the hall as readout, staged objectives, hint ladder rewritten | Essential |
| 2.5 | Collisions and low-obstacle traversal | Colliders for every fixture; a tested traversal contract (step, hop, vault, mantle, slide); the climb pose and path replaced for low obstacles | Essential |
| 2.6 | Humans meaningful | Phase 1 presence (traces, intercom traffic, one glimpse); Phase 2 roles with gameplay functions | Essential |
| 2.7 | English shows Spanish | Complete the English resource; a test that fails on leaks | Essential |
| 2.8 | Audio inaudible | Re-render content with mid-range content and a measured loudness target; offline spectral tests; owner listening pass | Essential |

### 2.1 Level design

1. **Established.** Identical interior footprints since `9bd68ac`; one-shed silhouette from outside (capture `08`); a hall with no interaction; empty west bay; a dead door; rooms named by floor-paint labels; the facility is about 34 × 24 m over four levels.
2. **Uncertain.** How much additional footprint the owner expects; whether the hall's problem is plan, light, camera or content (all four contribute; the camera is a high orbit that flattens the hall and the light leaves it dark).
3. **Change.** §3.4–§3.7. No plan change is required for the hall's redesign. The one spatial addition is a real **trial cell T** in the existing empty west bay (a partition, a glass wall onto the hall, a door), plus removing the dead door. A shift-office annex north of M is a desirable extension behind a design-lock. The facility's overall mass grows through the annex, tower and garage of Phase 2.
4. **Dependencies and files.** `scripts/phase1/phase1_building.gd`, `phase1_art.gd`, `kit_library.gd`; plans in `docs/design/assets/phase1_architecture/`; `FASE1_SPATIAL_GRAPH.md`; `FASE1_GREYBOX_SPEC.md`. Tests `test_phase1_layout`, `edges`, `navigation`. The robot route graph must not change.
5. **Acceptance.** Test: per-zone count of interactions or discoveries from the hotspot list (hall at least 3, every named room at least 1); the partition leaves every graph edge passable for a 0.45 m body; no new omni light in the nave view (report tool); plans and graph updated in the same commit. Person: the owner compares same-camera captures of the hall before and after and judges it a different place; first-time players can sketch the hall and name three rooms by function.
6. **Priority.** Essential.

### 2.2 Narrative and pacing

1. **Established.** Delivery by cards at hotspots; the answer stated in the intro; four objective lines; a strong first beat (collapse) and a strong last beat (the transfer); a long middle with no memorable moment.
2. **Uncertain.** Whether the owner wants more story volume or more story *felt in the place* (the feedback reads as the latter).
3. **Change.** §3.3 and §3.7: a three-act structure with six memorable moments, evidence as objects (a paper strip chart, a stopped shift board, a scorched jumper), intro de-spoiled, escalation by action, human traffic over the intercom.
4. **Dependencies.** `data/game_text.json`; `scripts/game/cinematic_director.gd` (intro text); `field_notes.gd`; orchestrator objectives; `docs/narrative_complete.md` (copy approval). Needs the owner's canon boundary (§10).
5. **Acceptance.** Test: no text before the observation flags states the double-demand consequence (forbidden-phrase list); every escalation cue fires once on its trigger. Person: after playing, three first-time players can recall at least four of the six memorable moments unprompted; they can say what the strip chart showed.
6. **Priority.** Essential.

### 2.3 Gameplay

1. **Established.** The loop is walk, press E, read; two places hold nearly all the action; the hall holds none; backtracking is minimal (one descent to the pit and back), which is good.
2. **Uncertain.** Whether the optional discoveries will be found without hints (needs play).
3. **Change.** Each room gets one purposeful action or discovery (table §3.4). Add two training traversal beats on the normal route (a pallet to hop, a cart to vault) so the contract is learned before Phase 2. Keep the linear critical path; add two optional discoveries. No new keys, collectibles or mandatory secondary puzzles.
4. **Dependencies.** Traversal contract (§5.1); room dressing.
5. **Acceptance.** Test: hotspot coverage as above; the optional discoveries are reachable by the route bot. Person: no first-time player reports "nothing to do here" about a named room; time spent in the hall is above a floor to be set from the first playtest.
6. **Priority.** Essential for the hall; desirable for the rest.

### 2.4 Electrical puzzle

1. **Established.** The logic is sound and tested. The presentation: three similar boxes with painted text; indicator strips; a text panel; ring meshes on the column that show state faintly; the deduction told in text.
2. **Uncertain.** Whether presentation alone fixes the confusion. Only a person can say.
3. **Change.** §3.6. Logic untouched. (a) Evidence is observed: a paper strip chart in cell T shows two traces rising together; the bridge is scorched and scanned, not described. (b) Controls are physical: a two-position selector lever, a knife-switch isolator with a visible gap, a guarded rearm button; each animates and has a collider. (c) A synoptic panel in E draws the *official* diagram and lights **demand** (triangle) and **supply** (disc) at each branch, so when the player asks for the archive and the trial branch still shows demand, the diagram contradicts itself. (d) The hall column's three rings mirror trial, archive and protection with shape-coded states, visible from E. (e) Objectives name goals, never controls. (f) The hint ladder moves from a question to the mechanism.
4. **Dependencies.** `phase1_building.gd` `_p2`, `_column`; orchestrator `_refresh_state_fixtures`, `_circuit_action`; `scripts/phase1/phase1_art.gd`; `data/game_text.json`; the circuit model is read, never written.
5. **Acceptance.** Test: the 54 circuit checks unchanged; a panel test that each of the circuit's reachable states produces a distinct, specified lamp and ring pattern; a text test that HUD strings never name a control ("isolate", "select ARCHIVO", "rearm") and that no card before the observation flags states the consequence. Person: the comprehension protocol of `FASE1_LOGIC_CONTRACT.md` ("Deduction test") with at least three first-time players: they must explain in their own words why the trial goes first.
6. **Priority.** Essential.

### 2.5 Movement and collision

1. **Established.** §1.3: fixtures lack colliders; 132 cells flag visible-but-uncollidable surfaces; walking is blocked from 0.10 m; jump to 0.40 m; one arms-up climb from 0.50 to 1.60 m; the existing tests prove only that dressing colliders do not block routes.
2. **Uncertain.** Which specific object the owner walked through (the controls are the most likely); the 132 cells need review (some are thin trim).
3. **Change.** §5.1: give every fixture a collider sized to its housing; review and fix the 132 cells; add the contract classes (step-over to 0.30 m, hop to 0.40 m, vault 0.60–1.10 m, mantle 0.50–1.85 m, slide 0.70–1.10 m); replace the low-obstacle motion with an arc over the obstacle and a pose that fits; keep the existing mantle for tall ledges.
4. **Dependencies.** `elena_controller.gd`, `phase1_spatial_player.gd`, `elena_procedural_pose.gd`, the builder; `test_elena_movement` must stay at 17.
5. **Acceptance.** Test: `test_traversal_contract` at each threshold ±0.01 m; `test_prop_collision_contract` (every visible non-decorative prop collides; every route passable); the hotspot walk (re-run as a test with stand positions in front of each fixture: closest approach to the housing is at least 0.25 m). Person: the owner walks the building and reports no pass-through and judges the low-obstacle motion natural.
6. **Priority.** Essential.

### 2.6 Characters and atmosphere

1. **Established.** Phase 1 contains no human; the prior idle operator was removed; the 12 people exist and compile but are unreferenced.
2. **Uncertain.** How much human presence the owner wants in Phase 1 before the reveal (the plan keeps the *sight* of people for Phase 2).
3. **Change.** Phase 1: traces (shift board, locker, mug, stopped clock), intercom traffic that responds to the player's actions, and one glimpse of a technician crossing the lit gantry as the player enters G. Phase 2: each person has a gameplay function (§4.6). No idle scenery.
4. **Dependencies.** `PersonVisual`, `HelixStaff`; `data/game_text.json`; audio.
5. **Acceptance.** Test: the three intercom exchanges fire once each on their triggers and in order; the glimpse plays once and only in the human variant; staff tests of §5.4. Person: players mention the people they heard or saw and what those people were doing.
6. **Priority.** Essential.

### 2.7 Localization

1. **Established.** Confirmed in the running game (captures `A1`, `A2`): "Opciones", "Créditos", "Volver" in English. Cause: 45 `NarrativeText` properties keep Spanish class defaults that `narrative_text_en.tres` never overrides; `NarrativeTextManager._text()` returns any non-null value, so the English fallbacks never run.
2. **Uncertain.** Which of the 45 appear on screens beyond the menu and credits (the options screen is English).
3. **Change.** Complete the English resource or remove the Spanish class defaults; one test; one rule: new text goes in `game_text.json` with both languages.
4. **Dependencies.** `scripts/data/narrative_text.gd`, `data/narrative_text_en.tres`, `main_menu.gd`, `credits.gd`.
5. **Acceptance.** `test_localization_en` red before and green after; the English menu, credits and options contain no Spanish label (checked by the test and by capture).
6. **Priority.** Essential.

### 2.8 Audio

1. **Established.** Configuration is right (buses exist, nothing muted, players playing, peaks present). Content is the problem (§1.3). Footsteps and UI sounds are audible but short and quiet.
2. **Uncertain.** The owner's device (not known), and subjective quality. The measurements explain the report; they do not prove it on that device.
3. **Change.** Re-render the four music layers and the ambience with a mid-range body (120 Hz–4 kHz), a 40 Hz high-pass, and a measured loudness target; raise footstep and landing transients; add spectral tests that run offline in GDScript on the generated streams; add the Phase 1 and 2 cues of §5.6. Keep every music mode and the director logic.
4. **Dependencies.** `scripts/audio/game_synth.gd`, `sfx_synth.gd`, `tools/audio/render_music.gd`, `assets/audio/music/`, `scripts/game/music_director.gd`.
5. **Acceptance.** Test: for each music layer, energy below 30 Hz at most 1 %, energy below 150 Hz at most 50 %, A-weighted RMS between −30 and −26 dBFS, no clipping; for ambience beds at least 20 % above 200 Hz; footsteps and landing at least 25 % above 500 Hz. Evidence: re-run the real-flow recording and compare A-weighted level and band shares. Person: the owner listens on their own speakers and answers "can you hear music, ambience and footsteps?" for each state.
6. **Priority.** Essential.

---

## 3. Phase 1 revised design: Station B Revision

### 3.1 Principles

1. **The hall is the stage.** Everything the player does elsewhere shows up in the hall.
2. **Evidence is an object.** The player finds, looks at and measures things; cards annotate, they do not explain.
3. **The facility answers.** Each significant action changes light, sound, or what the player overhears. Escalation is caused by the player, never by a timer.
4. **Every room has a reason.** A form, a light, a sound, one thing to do or find.
5. **Proportion.** No footprint growth beyond one partition and one optional annex; no new key, puzzle or mandatory collectible; no change to the circuit, the mission event contract, the autoloads or the input.

### 3.2 Pressure curve (where tension and memory come from)

| Time (approx.) | Moment | Pressure source |
|---|---|---|
| Act 1, 0–5 min | **M1 The collapse** (exists) | Commitment |
| | **M2 The lit glass cell**: from the access threshold the player sees an intact rig lit behind glass in the dark hall | Contradiction ("dismantled") |
| | **M3 The strip chart**: two traces that rise together | The aha, discovered not told |
| Act 2, 5–12 min | **M4 The surge**: maintenance ON sends a lighting ripple across the trusses, pumps spin up, the column rings ignite, the intercom crackles to life, an unseen person says the building has power | Ownership of a consequence |
| | Radio exchange 1 ("Nobody's cleared for B tonight") | Someone is out there |
| Act 3, 12–20 min | **M5 The synoptic panel** answers the player's action in light; the rings in the hall echo it | Understanding |
| | Radio exchange 2 on first stable archive ("Then somebody's inside") | Exposure |
| | **M6 The window**: at G, through the wired glass, a technician crosses the lit gantry toward the tower | The place is occupied; the door must be opened |

Durations are design targets, not measurements.

### 3.3 Three acts (the objectives rewritten)

Objectives name goals and never controls.
- **Act 1, "The hall".** Enter; read the evacuation traces; see the cell; read the chart; follow the feed (the scanner shows the cable trunk leaving the cell and the column toward the pit). Objective: *Find out why the rig still draws power.*
- **Act 2, "The pit and the price".** Examine the schematic and the physical bridge, read the workshop tag, switch on service power (the surge). Objective: *Get power to the upper floor.*
- **Act 3, "The floor above".** Control, the synoptic panel and the hall through the glass; the report; the circuit; the archive; G. Objectives: *Make the archive supply safe*, then *Leave through G with the record.*

### 3.4 Room by room

| Zone | Today | Revised identity | Signature | One thing to do or find | Human trace | Sound bed | Priority |
|---|---|---|---|---|---|---|---|
| Channel, culvert, tunnel | Strong | Keep | The collapse | — | Gate, plate | Water, concrete | Keep |
| A Access lock | A painted label and a plan | **Evacuation lock** | Lockers, coats, a clock stopped at the evacuation time | Shift board (roster, "Annex H: night shift ACTIVE") | Coat, mug, locker note | Dripping, one failing lamp | Essential |
| B Hall | Open floor, pit, column | **Aster hall** | The column as readout; a cable trunk crossing the floor; the lit cell | Cell T chart; the trunk to follow | Intercom horns | Low pump bed with a mid body | Essential |
| T Trial cell (new, west bay) | An empty room | **The intact rig** | Glass front onto the hall; the rig; a paper strip chart | Chart (examine, scanner highlights the traces) | Test log, empty sample cases | Quiet | Essential |
| C Workshop | Black boxes, one tag | **Workshop and desk** | Enclosed with a door; an open toolkit missing a jumper spool | Repair tag (exists); desk with the intercom | Mug, notes | Fluorescent buzz | Essential |
| Service gallery | A passage | A threshold between old and new | Painted route line toward the stairs to P2 and "ANEXO H · LOGÍSTICA" | — | — | Pipes | Desirable |
| D1 Pit, drainage | Valves | Keep; colliders | Level marks, valves | — | — | Water | Keep |
| D2 Pit, distribution | Panel, bridge, switch | Keep; the evidence is observed | Scorched floor, melted jumper | Schematic, bridge (scanner), maintenance | — | Hum | Essential |
| M Pump room | Pumps and panels | **Pumps alive** | Motors spin when powered; pressure readouts change | — | Intercom horn | Pump bed | Essential |
| M north wall dead door | A door to nowhere | Remove; or desirable annex below | — | — | — | — | Essential |
| (Optional) Shift office annex north of M | Does not exist | **Office of the shift** | A real room behind the existing door position | Roster, intercom desk with the live annex channel | Personal items | Radio | Desirable, behind design-lock |
| E Control | Small boxes | **The control desk** | Lever, knife-switch, guarded button, the synoptic panel, glass onto the hall | Operate; read the panel | Report on the desk | Relays | Essential |
| F Archive | A console | **The record** | Console with collider; record screen | Read; the record gains one transfer line (needs approval) | — | Fans | Essential |
| G Airlock | A door and a lamp | **The threshold** | Wired-glass window onto the gantry; status lamp | Open outer leaf | The technician glimpse | Wind through the seal | Essential |
| Gantry | Walkway | A lit approach | The tower's glow | — | — | Wind | Keep |

### 3.5 The hall (B) in detail

**State A, standby** (default): emergency base light; rings dark; pumps still; the cell lit by its own safety lamp so it stands out; an intact rig visible.
**State B, powered** (`circuit.maintenance_on`): the service lights ripple outward from the column in 0.15 s steps; the four pump motors rotate and their lamps go green; the column rings follow the circuit.

**Rings (bottom to top):** 0 = trial feed, 1 = archive feed, 2 = protection. Each ring has three states that differ by *shape*, not only colour:
- *Supplied:* a full steady ring.
- *Demanded but not supplied:* a ring of four arcs, dim, with gaps.
- *Tripped (protection ring):* a broken ring with two segments out.
Colour (cyan, green, white and red) is secondary.

**Cable trunk.** A floor trunk 0.15 m high runs from the cell, past the column, to the pit well. It is the first low obstacle the player steps over (§5.1) and the thing the scanner highlights ("follow the feed").

**Camera zone.** In the hall the orbit camera lengthens to 6 m and lowers its pitch by about 0.2 rad so the verticality reads (a `CAMERA_MODES` entry named `hall`, switched by position, not a new mechanism).

**Light.** No increase in omni lights in the nave view. Use emissive strips, ring emission and the cell's own lamp. Check with `scene_capture --report`.

### 3.6 The electrical puzzle, presented (logic unchanged)

The evidence chain, in the order a curious player meets it:

1. Cell T, the chart: two traces, A and T, rise together at the start of the trial window and stay together. *It is shown, not captioned.*
2. The hall: the column's rings show what is drawing now.
3. The workshop tag: "Temporary jumper A→T. Remove after trial." (kept).
4. The pit: the physical jumper; scorched floor; the scanner traces its continuity from A to T; the schematic shows the official, independent branches.
5. Maintenance (the surge).
6. Control: the player wants the archive; the synoptic panel (the *official* diagram, no bridge drawn) lights demand and supply per branch. Selecting ARCHIVO with the trial connected makes both demands show and then protection trips; the panel contradicts itself, so the player concludes there is a path the diagram lacks. The player isolates the trial, the trial demand lamp goes dark; selects the archive; rearms.
7. The hall's rings echo each step; the archive screen comes alive.

**Controls, specified.** Selector: a lever with two detents (ENSAYO / ARCHIVO), 35° each way, 0.25 s. Isolator: a knife switch whose blade visibly bridges two contacts when connected and lifts clear when isolated, 0.3 s. Rearm: a guarded button whose cover lifts and whose plunger depresses. Each has a collider, a sound and the existing banner or note.

**Text rules.** Cards describe what is seen. They never state the consequence. Hint level 3 may. The HUD never names a control.

**Walkthrough for validation.** You find a cell where the rig is intact and a paper strip with two lines that go up together. You follow the cable down to the pit, see a scorched jumper that is not on the drawing, and switch on service power; the hall wakes and somebody on the intercom says nobody should be here. Upstairs the panel shows two demands when you ask for the archive and the protection trips. You cut the trial branch, ask again, reset the protection, and the archive opens. If a first-time player cannot say this in their own words, simplify before proceeding.

### 3.7 Human presence and escalation by action

Delivered as subtitled intercom traffic through horns in the hall and pump room, with a synthetic squelch and no voice. Each fires **once**, on its trigger, in order. Spanish and English copy below is a **proposal**; the owner approves the wording (§10, D-CANON).

| # | Trigger | Speakers | English |
|---|---|---|---|
| R1 | Maintenance ON, first time, after 4 s | Annex, Desk | **Annex:** "Desk, B's lights just came on. Is anyone over there?" **Desk:** "Nobody's cleared for B tonight. Finish the crating. We'll send someone after the transfer." |
| R2 | Archive supply stable, first time | Supervisor, Desk | **Supervisor:** "Who authorised an archive read at B?" **Desk:** "Nobody." **Supervisor:** "Then somebody's inside. Close the transfer. Now." |
| R3 | Record read | Annex, Desk | **Annex:** "Last case sealed. Van's at the ramp." **Desk:** "Go. Don't wait for B." |
| G-window | Inner leaf of G opened, human variant only | A technician (model `helix_tech_a`) | Walks the gantry in the tower's light toward the door, 6 s, once |

Escalation uses what exists: the PA announcement at G (kept), the lift announcement (kept).

**Traces in A and C** (examine cards, English proposals): *Shift board* — "Station B shift board. Technicians 6 · Shift lead 1 · Security 2. Evacuation drill: PARTIAL. Annex H: night shift ACTIVE (5)." *Locker note* — "Taped inside a locker: 'Back in 5, don't lock up. — M.'"

### 3.8 Collisions and traversal in Phase 1

- Collider for every fixture and for the pump motors; review the 132 flagged cells; the dead door removed.
- The trunk (0.15 m) and one pallet (0.40 m) on the main route teach step-over and hop; one cart (0.80 m) in the workshop teaches vault; the existing crates teach mantle.
- Low-obstacle motion: for 0.50–1.10 m the vault of §5.1 replaces the vertical rise with arms raised (arc over the obstacle, apex 0.15 m above the top, tucked-leg pose); taller ledges keep the current climb. The trigger, the eligibility checks and the stamina cost do not change, so Phase 1's existing climbs onto cars, cages and crates keep working and only look different.

### 3.9 Visual direction

The illustrated direction stands (`docs/art/ASSET_PRODUCTION_BIBLE.md`). The problems the captures show are composition and light, not materials: a dark hall under a high orbit camera, small unlit black fixtures, rooms without thresholds. The revision answers with the hall camera zone, emissive accents, threshold frames (doors, sills, a change of floor and wall material) and per-room light colour. Judge it only in captures from the gameplay camera.

### 3.10 What is out of scope for Phase 1

No new circuit logic. No new keys or collectibles. No combat. No change to Phase 0 contracts. No new lift or stair. The shift-office annex is optional and does not block anything.

### 3.11 Design-lock gate (before any Phase 1 construction beyond the essential fixes)

Deliver for owner approval: the updated P0 plan and a section showing cell T and the removal of the dead door; the updated spatial graph (cell T edge); the room-signature table of §3.4 with any edits; the copy of §3.7 and of the edited cards. Construction of B-milestones starts after this approval. The essential corrections of §6.A do not wait for it.

---

## 4. Phase 2 revised: a distinct playable sequence

### 4.1 Purpose and flow

Phase 2 changes the player's relation to the place: from investigator to witness to quarry to someone who disappears. Each stage uses a different verb.

| Stage | Verb | Place | What happens | Ends when |
|---|---|---|---|---|
| 1 Crossing | Approach | Gantry, tower | Cold air; the lit tower; a voice through the door | The door opens |
| 2 Observing | Watch | Annex gallery over the packing hall | Technicians crate Aster cases for FINAL THAW; a guard at the security desk; the supervisor on a call in a glass office; the guard patrol starts after a delay | The player decides to move |
| 3 Choosing | Decide | Stair or the quiet back way | Two ways down, different exposure | Reaches the floor |
| 4 Learning | Take | Supervisor's office | The manifest: the transfer and her credential on the audit | Reads it, or is seen first |
| 5 Seen | Run | Packing hall | A telegraphed tell; the camera moves to her eyes | Moves |
| 6 Through | Act | Annex corridors | Vault, push, slide, shove, shut; three looks back | Reaches the stair door |
| 7 Under | Choose | Garage | Two routes; headlights; a shutter to drop; a barrier to duck | Reaches the ramp |
| 8 Vanish | Slow down | Street | Pursuers stop at the ramp mouth; the crowd; walking hides her, sprinting does not | The cinematic |

The sequence is coherent as story: Elena's own action (the audit) is what puts people on guard; what she sees (a transfer of the evidence) is what she must carry out; the escape ends in the one place a company cannot chase her: in public.

### 4.2 Presentation options compared

| Option | Readability | Immersion | Performance | Implementation risk | Animation needed | Verdict |
|---|---|---|---|---|---|---|
| A. First person throughout | Stealth suffers: Elena's posture and the sight lines are not visible; the wrist unit is the only body | High | Neutral (draw calls unchanged; saves one 14 k-triangle skinned body) | New for the project; comfort and motion-sickness risk for the whole phase | Almost none | Rejected: the observation stage needs Elena visible |
| **B. Hybrid: third person to detection, first person to the street, third person in the crowd** | Stealth readable; the chase feels bodily | High at the moment that matters | Same as A during the chase | Camera switch twice; one prototype to de-risk | None for the chase; existing clips elsewhere | **Recommended**, gated by the prototype (task C0 in §6) |
| C. Third person throughout with contextual traversal | Best for readability and for the crowd rule | Medium | Neutral | Needs vault, slide and push poses; today `climb`, `interact`, `caught` are procedural and there is no crawl | Vault, slide, push (new) | **Fallback** if B fails the prototype; same contextual actions in the `pursuit` camera |
| D. Scripted chase with prompts only | High | Low (not play) | Lowest | Low | Moderate | Rejected: it removes agency and violates the owner's "not QTE" |

**Evidence for B.** The repository records that Elena has no crawl or hit animation and that her `climb`, `interact` and `caught` clips are procedural; the mantle frames of §1.3 show how the third-person climb reads. First person removes the need for those clips during the chase. The cost is a prototype and a comfort risk, which is why it is isolated.

### 4.3 Containment semantics under the human variant (PROPOSAL)

The event contract in `docs/design/MISSION1_GHOST_PROTOCOL.md` is unchanged: maintenance queues `SERVICE_OVERRIDE`; opening G's outer leaf sends the audit once and starts Containment. In the human variant the consequence is the PA notice, a radio call and, after a fixed delay (45 s, a named constant), a guard patrol that includes the gallery. The legacy variant spawns the robot as today.

### 4.4 Coexistence with the robot route

A variant flag `phase2_variant` on the orchestrator: `legacy_robot` (default) and `human_annex`. Phase 1 changes apply to both; the G-window glimpse and the intercom lines R2/R3 are gated by variant. The human variant becomes the default only when **all** are true: the 34 existing suites and the new suites pass; at least three first-time players complete it without a soft-lock; the owner approves the first-person prototype and the ending; no new zone is slower than the worst current view on the same driver and preset; accessibility checks pass; both variants end in the same results screen; the owner approves in writing. The robot route is deleted only on a separate written approval.

### 4.5 Garage and street

Placement options: (A) convert the open yard, 60 m east of the annex: spatially incredible; (B) a new staff garage below the annex in the same scene, hidden until reached: preserves the v4.0 decision of one scene; (C) a separate scene: needs a state hand-off without a new autoload. **Recommended B**; C only if B breaks the performance budget and the owner approves. Specification in the handoff §5.C; coordinates are locked by drawings first (task C4 in §6).

**Street.** About 30 × 20 m at ground level; 12 staged pedestrians in three clusters; the pursuers stop at the ramp mouth because they cannot act in public. Rule: sprinting inside the crowd zone can re-acquire Elena; walking multiplies her visibility by 0.4. The last verb is *slow down*, which contrasts the chase and uses the stealth contract.

### 4.6 People and their roles

| Person | Role | Gameplay function |
|---|---|---|
| `helix_tech_a`, `helix_tech_b` | Technicians crating cases | Sight lines and noise sensors; they call it in on the radio; they do not chase |
| `helix_supervisor` | In the glass office, on a call | Delivers the stakes by overheard speech; carries the manifest; her office is the objective |
| `helix_guard_a` | At the security desk, then the patrol | The first threat; his patrol timing sets the observation window |
| `helix_guard_b` | Patrol, then the chase | The pursuer in the annex and the garage |
| `civ_*` (7 models, 12 placements) | The street crowd | Cover for the final beat; deterministic loops |

### 4.7 AI contract

Two layers: **Stealth** (third person, perception-driven, existing states) and **Chase** (first person, scripted route with a managed gap; pursuers do not perceive). Values and fairness rules are in the handoff §5.C. Glass must block movement and not sight; `StaffRadio` is to be written; no perception through geometry; every state has a visible indicator (symbol and size, never colour alone) and ALERT has a sound.

### 4.8 What Phase 2 must not become

No combat for Elena. No mandatory prompt chain. No Marcus mechanics: the future Marcus-led phases (companion progression in `docs/CORE_LOOP.md` §10) stay specification only; this phase adds `perception`, `suspicion` and `state` signals that a later companion AI can read, nothing else.

---

## 5. Systems specification

### 5.1 Movement, collision and traversal

**Measured behaviour (RAN, real controller, 60 Hz).** Capsule radius 0.32, height 1.7 (1.05 crouched); `collision_mask = 1 | 16`.

| Obstacle height | Walking | Walking and jumping |
|---|---|---|
| 0.10–0.30 m | blocked | hop over |
| 0.40 m | blocked | hop over |
| 0.50–1.60 m (1.2 m deep) | blocked | climb (mantle), then walk across |
| 1.90 m and above | blocked | blocked |

**Contract (PROPOSAL; thresholds are starting values for task A4).**

| Class | Marking | Behaviour | Threshold |
|---|---|---|---|
| Blocking | layer 1 | Stops | Over 1.85 m or too thin to stand on |
| Guard rail | layer 16 | Blocks, never mantled | Existing |
| **Step-over (new)** | layer 1 | The body rises smoothly onto a lip; no animation | Up to 0.30 m, top at least 0.25 m deep, moving at 0.5 m/s or more |
| Hop | none | Existing jump | Up to 0.40 m |
| **Vault (new motion)** | any ledge the mantle accepts; group `vaultable` and meta `vault_size` add the contextual prompt and guarantee a clear landing | Same trigger as today (`jump` within about 1.0 m facing the ledge). The body follows an arc over the obstacle (about 0.5 s, apex 0.15 m above the top, tucked-leg pose) and lands beyond it, or stands on top if the top is deeper than 1.2 m. It replaces the vertical rise with arms raised for this band | 0.50–1.10 m high |
| Mantle (existing climb) | layer 1 | Unchanged for tall ledges | 1.10–1.85 m |
| **Slide under (new)** | group `slide_under` | Sprint plus `crouch`, capsule 0.65 m for about 0.7 s | Opening 0.70–1.10 m |
| **Push (new, scripted)** | group `pushable` | One `interact`, fixed vector, deterministic, refuses if blocked | Fixed displacement |
| Door, shutter, scripted boundary | existing | Unchanged | — |
| Decoration | no collider | Allowed only under 0.05 m, above 2.2 m or off every route | Rule |

Use only the existing input actions. A traversal that cannot complete is refused before it starts, with a visible prompt state. `test_elena_movement` stays at 17 passing.

### 5.2 First person

Third camera mode `first_person` beside `explore` and `pursuit` in `phase1_spatial_player.gd`; same controller; eye 1.62 / 1.0 / 0.7 m; Elena's body hidden; field of view 75 as an option; bob off by default; reduce-motion removes procedural motion and looks back. Entry is a 0.4 s cut at detection; exit when the crowd rule starts. Fallback: the same actions in the `pursuit` camera.

### 5.3 Interaction and prompts

Reuse line-of-sight targeting and `prompt_hud.gd`. A traversal prompt appears only when available, shows the bound key, and never times out.

### 5.4 Human AI

States, thresholds and tests are in the handoff §5.C and §5.A5. The values (cone ±55° to 9.5 m; peripheral ±100° to 2.6 m; darkness ×0.55; crouch ×0.6; gain 1.15/s; SUSPECT 0.3; ALERT 1.0; decay 0.22/s; 1.6 s; 4.5 s; 1.1 s; 0.8 s; catch 0.85 m) are read from `helix_staff.gd`.

### 5.5 Mission state and checkpoints

Extend `Phase1MissionState` with session flags; no save field; no autoload. New checkpoints restore all flags and sit at least 15 m of route from pursuers, out of sight.

### 5.6 Audio

| Cue | Purpose | Status |
|---|---|---|
| Pump and hall bed with a mid body | Place and function | Re-render |
| Surge on maintenance, ring ignition | Cause and effect | New |
| Lever, knife-switch, button, trip | Feedback on the controls | New (trip exists) |
| Intercom squelch and murmur | Human presence | New (synthetic, no voice) |
| Footsteps with a louder transient; landing | Noise discipline readable | Raise |
| Staff footsteps, radio, "?" rising tone, "!" sting | Legible suspicion | Mostly new |
| Vault, slide, cart, door, shutter | Physical feedback | New |
| Garage drone, street ambience, crowd murmur | Space | New |
| Music (four modes) | Pressure | Re-render with mid-range content; keep the director |

Every critical cue has a visual equivalent. Voices are subtitles.

### 5.7 Localization

Complete the English resource (§2.7). One rule: new text goes in `game_text.json` with both languages. English checklist: menu, credits, options, pause, objectives, prompts, notes, cards, subtitles, intercom, barks, banners, results. World signage stays Spanish with an English translation beside the action.

### 5.8 Accessibility

No new actions; controller reaches every traversal; reduce motion removes the dip, the bob and the looks back (replaced by a HUD marker and a sound); subtitles for lines and for important sound cues; no colour-only state; prompts never time out; game speed 50/75/100 % scales the chase.

### 5.9 Performance

Budget: no new zone slower than the worst current view on the same driver and preset; hidden zones are `visible = false` and `process_mode = disabled`; crowd copies decimated to 6 000 triangles or fewer; no net omni lights in the nave view; measure with `tools/capture/scene_capture.tscn --bench`. The native-OpenGL question (a `project.godot` change) is the owner's.

---

## 6. Implementation plan

Four groups, with the reason each precedes the next.

### 6.A Essential corrections (no design decision needed; start now)

| ID | Task | Depends | Acceptance | Rollback |
|---|---|---|---|---|
| A1 | English locale | — | `test_localization_en` red before, green after; captures show no Spanish | Revert two data files and the test |
| A2 | Audio content re-render and spectral tests | — | §2.8 thresholds pass; re-recorded flow compared; owner listens | Keep the old WAVs in place until the owner approves |
| A3 | Fixture colliders; review the 132 cells; remove the dead door | — | `test_prop_collision_contract` green; hotspot walk keeps ≥ 0.25 m | Revert |
| A4 | Traversal contract: step, vault, slide, push; low-obstacle arc and pose | A3 | `test_traversal_contract` green; `test_elena_movement` unchanged at 17 | Revert; mantle untouched |
| A5 | `StaffRadio`, glass layer, bark keys, staff tests, people test | — | `test_helix_staff`, `test_people_assets` green | Revert |
| A6 | Provenance rows and credits for the people | — | Complete in both languages | Revert |
| A7 | Commit plan for the owner's untracked work (three commits, push each) | Owner approval | Tests pass at each commit; nothing from `_tmp` | `git revert` |

*Why first.* They are verified defects, small, and independent of the design. A3 precedes A4 because traversal tests assume solid fixtures. A1, A2, A5 and A6 can run in parallel.

### 6.B Phase 1 design and gameplay (after the design-lock gate of §3.11)

| ID | Task | Depends | Acceptance | Rollback |
|---|---|---|---|---|
| B0 | Design lock: plan, section, graph, signatures, copy | Owner approval | Documents agree; owner signs | — |
| B1 | De-spoil the copy; stage the objectives; rewrite the hints | B0 copy | Forbidden-phrase test; objective sequence test | Revert text |
| B2 | Hall readout: rings, pump motors, light ripple, camera zone | A3 | State-pattern tests; captures from the gameplay camera | Revert |
| B3 | Trial cell T, chart, trunk, scanner extension | B0, A3 | Partition leaves all edges passable; chart reachable; route bot walks it | Remove the partition |
| B4 | Controls redesign and synoptic panel | A3, B2 | The four state patterns; 54 circuit checks unchanged | Revert the visuals |
| B5 | Intercom traffic, traces in A and C, G-window | B1 | Each cue fires once, in order; variant-gated glimpse | Flag |
| B6 | Room signature pass and lighting | B3 | Light budget; owner review of captures | Revert |
| B7 | Optional shift-office annex | B0 | Behind design lock | Remove |

*Why this order.* Copy before fixtures because the cards describe what is seen; hall readout before the controls so the controls have something to echo; the cell before the objectives that point at it.

### 6.C Phase 2 construction

| ID | Task | Depends | Acceptance | Rollback |
|---|---|---|---|---|
| C0 | **First-person prototype room; owner plays it** | A4 | Owner verdict on comfort, control, vault, slide, reduce-motion; frame time recorded | Delete the prototype |
| C1 | Wire the annex behind the variant flag; observation, manifest, discovery | A5 | Route bot walks every edge; both variants complete | Flag |
| C2 | Containment semantics for the human variant | C1, owner D-CONT | Audit once; patrol after 45 s | Flag |
| C3 | The chase: route, gap, beats, looks back, stun, retry | C0 gate, C1 | `test_phase2_chase` green; a person finishes it | Flag |
| C4 | Garage and street design lock | Owner | Drawings agree, no overlap | — |
| C5 | Garage, ramp, barrier | C4 | `test_phase2_garage` | Remove the zone |
| C6 | Street, crowd, stop line, crowd rule | C5 | `test_phase2_street` | Remove the zone |
| C7 | Human, traversal and space cues | C1 | Cue tests; owner listens | Revert |
| C8 | Accessibility for first person and the chase | C3 | Reduce-motion test; controller reaches all | Revert |

*Why C0 is a gate.* First person is the biggest unknown; it is isolated so it cannot block A or B and cannot be built into the whole chase before it is judged.

### 6.D Integrated validation and final gates

| ID | Task | Depends | Acceptance |
|---|---|---|---|
| D1 | Regression: 34 legacy suites plus every new suite; Phase 0; save MD5 | each milestone | Green; identical |
| D2 | Performance rows per driver and preset | C6 | No new zone worse than the worst current one |
| D3 | Playtest with at least three first-time players | B and C complete | Recorded: time, catches, hints, where lost, recall of the memorable moments, the comprehension explanation |
| D4 | Flip the default variant | D1–D3, owner | §4.4 conditions met and approved |
| D5 | Documentation reconciliation | each | §11 |

**Critical path.** A3 → A4 → C0 (owner gate) → C3 → D3 → D4. **Second path (independent).** B0 (owner approval) → B1 → B2 → B3 → B4 → B5 → D3. Both end in D3.
**Parallel.** A1, A2, A5, A6; B0 while A runs; C0 while B runs.
**Never before its gate.** C3 before C0; B-construction before B0; D4 before D3.
**Evidence kinds, kept apart.** *Automated tests* prove contracts. *Technical integration checks* (route bot, graph walk, bench rows) prove the pieces connect and fit the budget. *Qualitative evaluation* (owner captures, owner listening, first-time-player protocol) is the only evidence for comprehension, tension, comfort and "better".

---

## 7. Defects, open questions and owner decisions

**Confirmed defects.** §1.4 (E1–E7, T1–T6).

**Unresolved questions.** The near-black camera frames; the owner's speakers; the 132 flagged cells; whether presentation alone fixes the puzzle; first-person comfort on the HD 630; the cost of 12 people and the annex on ANGLE.

**Decisions only the owner can make**

| Id | Decision | Recommended default | Blocks |
|---|---|---|---|
| D-DESIGN | Approve the Phase 1 design lock (§3.11): the cell, the signatures, the copy | Approve with edits | B-group |
| D-CANON | Story boundary and the wording of the new lines | Pursuers are Helix security staff; no named person or chain; the only new fact is the FINAL THAW transfer, already implied by the ending | B1, B5 |
| D-CAM | When first person starts and ends | §4.2 option B; the prototype decides | C3 |
| D-CONT | Containment semantics under the human variant | §4.3 | C2 |
| D-COMMIT | Commit the working tree in three commits and push | Yes | A7 |
| D-LFS | Binary people assets in git | Freeze after approval; consider Git LFS before re-exports | none |
| D-GL | Native OpenGL on Intel Gen9 (`project.godot`) | Ask; needed before a performance claim | D2 |
| D-PLAY | Three first-time players | The owner supplies them | D3 |
| D-DEVICE | What speakers or headphones the owner used | Answer in one line | Interprets A2 |

Decided here and not asked: single scene with zone gating (the split needs approval only if the budget fails); the robot route kept behind a flag; the garage below the annex.

---

## 8. Sonnet handoff

`prompts/sonnet_phase2_human_escape_handoff.md`, updated in place. It is self-contained and organised in the same four groups. Start with group A; B waits for D-DESIGN; C0 may run in parallel with B; C3 waits for C0.

## 9. Character pipeline assessment (carried, re-verified)

12 GLB: 5 staff and 7 civilians; the same 53-bone `game_engine` rig as Elena; about 14 000 triangles each; faces +Z; staff clips `alert idle point radio run search sprint stop turn_left turn_right walk work`; civilians `idle radio walk walk_casual`. Missing: a stumble clip for the delayed-pursuer beat, a civilian run, any crouch. The pipeline (`tools/blender/people_mpfb/build_people.py`) takes its inputs from `D:/Projects/external_assets/` and was not re-run, so reproducibility is unverified. Licences: CC0 headers on every skin and clothes file used; CMU motion capture under its published terms; the record is missing and is task A6. No scene uses the models.

## 10. Test strategy

Layers: static; behavioural; headless suites through `tools/run_tests.sh`; scene and import validation; runtime smoke (non-headless); manual QA; visual inspection from the gameplay camera; performance; save and regression.

Commands: `godot --headless --path . res://tests/test_phase_0.tscn`; `tools/run_tests.sh <godot-console-binary>`; one suite: `godot --headless --fixed-fps 60 --path . res://tests/<suite>.tscn`. New suites are `tests/test_*.tscn`, set `GameManager.settings_slot` to a test slot before saving (99 and 98 are used; slot 0 is the player's options), and exit non-zero on failure.

New suites: `test_localization_en`, `test_audio_mix` (offline spectral and loudness), `test_prop_collision_contract`, `test_traversal_contract`, `test_helix_staff`, `test_people_assets`, `test_phase1_hall_readout`, `test_phase1_controls_and_panel`, `test_phase1_text_contract` (forbidden phrases, objective sequence), `test_phase1_intercom`, `test_phase2_annex`, `test_phase2_chase`, `test_phase2_garage`, `test_phase2_street`, `test_phase1_variant_flag`.

A milestone is accepted only if its suites and the legacy suites pass, Phase 0 passes, `git status` is clean apart from the owner's work, and a person has judged the affected experience.

## 11. Documentation reconciliation

Update existing files only: `PROJECT_STATUS.md` (counts, variant, evidence); `docs/DESIGN_AUTHORITY.md` (replace the STAFF-M1 and robot rows; record D-CAM, D-CONT); `docs/LEVEL_STRUCTURE.md` (renumber the second §7; mark the robot yard as the legacy variant; add annex, garage, street); `docs/design/FASE1_ARCHITECTURAL_LAYOUT.md`, `FASE1_SPATIAL_GRAPH.md`, `FASE1_GREYBOX_SPEC.md` and the SVG plans (cell T, dead door); `docs/design/MISSION1_GHOST_PROTOCOL.md` (human-variant consequence row); `docs/design/FASE1_FUNCTIONAL_SPEC.md` (acts, objectives, controls); `docs/design/FASE1_PREMIUM_AUDIT.md` (§11 licence line); `docs/CORE_LOOP.md`; `docs/narrative_complete.md` (new lines); `docs/TRACEABILITY_MATRIX.md`; `docs/art/PROVENANCE.md`; `docs/art/MASTER_ASSET_LIST.md`; `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md`; `docs/LOCALIZATION_AUDIT.md`; `README.md`, `CLAUDE.md`; the stale comment in `scripts/game/game_text.gd`. No competing documents. Archive this file after acceptance.

Known contradictions: counts 33/1051 against 34/1053; two sections numbered "7" in `LEVEL_STRUCTURE.md`; "licence unverified" against the verified record; STAFF-M1 and the robot in the selected-decisions table against the owner-approved section; M and P2 datums in the architecture document (+1.5/+3) against the as-built (+3/+6).

---

## 12. Final quality test

1. *Does the plan address the owner's actual feedback rather than prove the systems function?* Yes. §2 maps all eight concerns; §1.3 shows measured evidence for each; no item is closed by "the code exists".
2. *Will the changes create a meaningfully better experience?* They target the causes found: the unchanged interior, the inert hall, the spoiled deduction, absent people, fixtures without bodies, inaudible content. Whether the result *is* better is the owner's and the first-time players' judgement (D3); the plan makes that judgement the acceptance gate.
3. *Is Phase 2 a coherent narrative sequence?* §4.1 gives a verb and a reason per stage, ties the escape to what Elena did and what she saw, and ends with a contrast verb.
4. *Are technical fixes, design improvements and new content prioritised separately?* Yes: groups A, B, C, D; A needs no design decision.
5. *Can Sonnet implement without inventing design decisions?* The copy, thresholds, ring states, lever motions, radio triggers, objective sequence and acceptance thresholds are specified; the remaining open items are listed as owner decisions with defaults, and construction that depends on them is gated.
6. *Are scope, risks, acceptance and evidence clear enough to review each milestone?* Each task has dependencies, acceptance, rollback and the kind of evidence required.

---

## 13. Change summary

| File | Change |
|---|---|
| `docs/design/PHASE2_AUDIT_AND_BLUEPRINT_2026-10-15.md` | **Updated in place** (this file). Corrected conclusions; added reconciliation, Phase 1 redesign, Phase 2 option comparison, A–D plan |
| `prompts/sonnet_phase2_human_escape_handoff.md` | **Updated in place**; restructured to groups A–D with the specifications |
| Project code, scenes, assets, `project.godot` | **Not changed** |
| Owner's untracked work | **Untouched** |

Outside the repository: captures, a recording and two listening WAVs under `D:/Projects/evidence/final-thaw/audit_2026-10-16/`; scratchpad probes; memory notes. Nothing was committed or pushed.

## Appendix A — Verification record

| What | Method | Result |
|---|---|---|
| Repo state | `git status`, `git fetch`, `rev-list` | Branch and HEAD unchanged; 19 untracked |
| Full suite | `tools/run_tests.sh` | 34 / 1053 / 0 |
| Phase 0 | Verbatim command | 7 passed |
| Locale | Resource probe; captures `A1`–`A3` | Confirmed |
| Interior unchanged | `git diff 9bd68ac HEAD` | Footprints identical |
| Before and after visuals | `v1`/`v2` captures against `04b`, `05`, `43` | Same composition, new materials |
| Room inventory | `_hotspots()`, building plan | Hall 0 |
| Empty west bay | Capture `W2`; flood fill | Reachable and empty |
| Fixtures | Source `_p2()`; capture `H3`; anchor walk | No colliders; 17/20 reachable to 0.01 m |
| Uncollidable surfaces | Grid scan | 132 cells |
| Mantle | 0.6 m crate frames | Arms-up vertical rise |
| Traversal thresholds | Controller probes | §5.1 |
| Audio flow | Recorded 80 s through the real path | RMS −23, A-weighted −43, 94 % below 120 Hz |
| Music and SFX spectra | Python on WAV and rendered streams | §1.3 |
| Laptop simulation | High-pass 150 Hz | RMS −36, peak −21 |
| Text content | `game_text.json` | 306 keys, structure in §1.3 |
| Route pace | Bot log | 107.8 s |
| Annex code | Loaded in project context | Compiles; models load with 53 bones |
| **Not done** | People pipeline re-run; any performance benchmark; any playtest; gamepad; listening on the owner's device | **UNVERIFIED** |