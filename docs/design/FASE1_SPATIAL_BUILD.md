# Phase 1 spatial build

Status: implementation prepared; not executed in Godot or manually validated. Independent from earlier scenes.

Open scenes/prototypes/phase1_spatial_greybox.tscn and press F6. Click to capture the mouse; WASD moves relative to the camera; Space jumps; E interacts; H asks for a hint; Escape releases the mouse, then Escape returns to the menu.

**Review views.** F4 toggles a top-down view of the whole complex and F5 a side cut seen from the south; both fade every wall so the layout and the four levels can be read, and pressing the same key again returns to Elena. Use them for the captures that review geometry.

The scene builds the six-room, four-level complex described in FASE1_ROOM_COMPLEX.md (data in scripts/prototypes/phase1_layout.gd). That document supersedes the single-bay plan of FASE1_GREYBOX_SPEC.md for this build and is itself pending design and script validation, so a comparison against the older plan will not match.

## Interactions (block 2 of FASE1_GRAND_DESIGN.md)

scripts/prototypes/phase1_interactions.gd wires nine interaction points to the circuit model (FASE1_LOGIC_CONTRACT.md); the model decides every outcome.

| Point | Room | What it does |
|---|---|---|
| Schematic | Pit | Documentation clue: one source, three independent branches |
| Connection | Pit | Anomaly clue: an orange cable joins the archive and trial branches and is not on the schematic |
| Maintenance switch | Pit | Toggles maintenance, independent of the recovery branches |
| Selector | Catwalk | Toggles the recovery destination between trial and archive |
| Trial isolator | Catwalk | Isolates or reconnects the trial branch |
| Indicators | Catwalk | Reads requested destination, demand on the trial branch and protection state |
| Archive terminal | Cabin | Diagnostic always available; reads the archive only with stable supply |
| Protection panel | Cabin | Requests a rearm, refused while the fault persists |
| Shortcut door | Cabin | Unlocks the shortcut from the cabin side |

Wrong configurations trip the protection with feedback: an alarm pip, a dip of every room light, a red protection ring and strip, and a banner. Nothing is lost and no text names the control to operate. The Column rings, the three indicator strips and the archive screen reflect the supply state. Hints (H) have three steps and never name a control. Every action is printed to the console as `[phase1 time] id detail`, so a play session can be pasted as a report.

Not implemented on purpose: the archive record (the text is a marked placeholder awaiting script), extraction, containment, the scanner, the lift and pursuit.

Checks (headless-friendly): tests/test_phase1_layout.tscn, tests/test_phase1_dressing.tscn and tests/test_phase1_navigation.tscn check geometry; tests/test_phase1_interactions.tscn runs the real scene and drives the handlers through a trip, diagnostic use while tripped, refused and accepted rearm, order independence and the hint ladder. The circuit model has its own tests in tests/test_phase1_circuit_model.tscn.

## Dressing and camera

scripts/prototypes/phase1_dressing.gd dresses every room with the art team's materials. The rig housing in the hall is low and compact (5 x 4 m, 2 m high) so it forces a detour without hiding the hall; the default camera elevation is about 31 degrees for the same reason. The machine itself has no behaviour of its own: it is scenery until the logic says otherwise.

## Not in this build

Elena uses the animations embedded in her model; the procedural pose layer is disabled in this scene. Walk playback speed needs tuning against the real stride. No crouch, climb, pursuit or save integration. The lift is not installed (a known limit, marked on the floor of the pump room). Falling below -8 m restores the last room's safe point. Performance on the target GPU is not measured: ten omni lights and large single-mesh floors cost on the Compatibility renderer.

Manual route: entry -> hall -> south stairs to the pit (read the schematic and the connection, throw the maintenance switch) -> back up and east to the pump room -> north stairs to the catwalk (read the indicators, try the selector and isolator) -> cabin (diagnostic, rearm, read the archive) -> unlock the shortcut and descend. Record Godot version, commit, renderer, resolution, input device, frame time, the console log, hints used and what the player says is happening.
