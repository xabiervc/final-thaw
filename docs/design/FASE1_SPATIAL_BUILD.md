# Phase 1 spatial build — first pass

Status: implementation prepared; not executed in Godot or manually validated. Independent from circuit tests and earlier scenes.

Open scenes/prototypes/phase1_spatial_greybox.tscn and press F6. Click to capture mouse; WASD moves relative to camera; Space jumps. Escape releases mouse, then Escape returns to menu. E unlocks the west shortcut only from cabin side.

Three heights: pit -2 m, ground 0 m, cabin/walkway +3 m. The pit west floor includes X 19.5..20 with no slot. Lift is not implemented: use the marked provisional ramp. Fixed stairs currently use sloped collision and ramp visuals; tread art is deferred. Existing Elena model and visual pose are reused through an adapter; shared controller is unchanged. No crouch, climb, new animation, circuit interaction, scanner clues, archive record, pursuit, extraction, containment or campaign save integration. Signage marks future clue/control positions, not a playable deduction puzzle.

Known first-pass limits: not all upper-route and ramp guardrails/enclosure are present; falling is possible and restores a safe point. The camera uses SpringArm3D to shorten on obstruction, but comfort is unverified. Shortcut and pit continuity require runtime tests. No claim of animation quality or of the complete approved spatial design.

Manual route: entrance -> broken direct approach -> west pit corridor -> pit stairs -> pit clue positions -> fixed return -> east ground route -> provisional ramp -> upper walkway -> cabin -> unlock shortcut -> descend. Record Godot version, commit, renderer, resolution and input device, plus blocked views, falls and unclear destinations. The lift remains a separate acceptance gate.
