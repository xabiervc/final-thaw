# Phase 1 spatial build

Status: implementation prepared; not executed in Godot or manually validated. Independent from the circuit tests and from earlier scenes.

Open scenes/prototypes/phase1_spatial_greybox.tscn and press F6. Click to capture the mouse; WASD moves relative to the camera; Space jumps. Escape releases the mouse, then Escape returns to the menu. E unlocks the shortcut door only from the cabin side.

The scene now builds the six-room, four-level complex described in FASE1_ROOM_COMPLEX.md (data in scripts/prototypes/phase1_layout.gd). Run tests/test_phase1_layout.tscn for the layout checks (pure data).

Elena uses the animations embedded in her model; the procedural pose layer is disabled in this scene. Walk playback speed follows ground speed and needs tuning against the real stride. No crouch, climb, circuit interaction, clue objects, archive record, pursuit, extraction, containment or save integration. The lift is not installed. Falling below -8 m restores the last room's safe point.

Manual route: entry -> hall -> south stairs to the pit and back -> east stairs to the pump room -> north stairs to the catwalk -> west along the catwalk to the cabin -> unlock the shortcut -> descend to the entry. Record Godot version, commit, renderer, resolution and input device, plus blocked views, falls and unclear destinations.
