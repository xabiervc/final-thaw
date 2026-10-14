# Lab Environment Kit — Production Plan

**Status:** proposal for owner approval. Nothing here is built, integrated, final, optimized or release-ready. Values marked **[proposed]** are new; everything else is read from the repository at commit `d029f07` (rooms 1–4 implemented).

**Goal:** turn the greybox abandoned laboratory into a credible environment with Blender + Godot while keeping gameplay, autoloads, input actions, `project.godot`, functional colliders and interaction points untouched.

Companion documents: `docs/art/LAB_STYLE_SPEC.md` (palette, lighting, conventions), `docs/art/LAB_BATCH1_SPEC.md` (Batch 1 detail), `docs/art/ELENA_BLOCKOUT_SPEC.md`. This plan supersedes the batch numbering in `docs/art/LAB_NEXT_BATCH.md` (its decision list still applies).

## 1. Review findings

| Source | Finding |
|---|---|
| `abandoned_lab.tscn` | Root `Node3D` + `abandoned_lab.gd` only. Everything is built in code. |
| `abandoned_lab.gd` | All 4 rooms are implemented (dividers at x = 16, 34, 60; end wall x = 86; pit floors x 40–46 and 52–58; room 4 floor x 58–86). Room 4 has 4 timed floor hazard zones from `hazard_zone.gd`: 3 real (cycle 3 s off / 1 s warning / 2 s active) and 1 decoy (`fake`). They are generic zones, not the steam/electric/toxic types in `docs/LEVEL_STRUCTURE.md`. |
| Shell | Floor is 12 m deep (z ±6), 0.5 m thick colliders, top at y = 0. Back wall 3.2 m high, 0.5 thick, inner face z = −6. **Front wall (camera side) is 0.9 m high** so the camera sees in. Dividers 0.6 thick, two arms of 4.6 m (z 1.4–6.0) leaving a 2.8 m opening. |
| Components | Every interactable builds its own greybox meshes in `_ready()` with `B.box()`, and its scripts recolor specific emissive meshes (`_orb`, `_ring`, `_lamp`, `_screen`, `_top`) through `B.set_glow()` or `material_override`. |
| Camera | `follow_camera.gd`, FOV 40, offset (0, 8.5, 6.5), unchanged. |
| Elena | `elena_controller.gd`: capsule r 0.32 / h 1.7, primitive meshes under a `visual` node that rotates with `atan2(x, z)`. **Front = +Z, backpack at −Z.** (The palette-test reference uses −Z; the blockout follows the game, not the reference.) |
| Existing art | Style spec + 6 `_a` assets (floor, wall, corner, terminal, container, wall light) already match the greybox sizes (e.g. `lab_terminal_a` = `terminal.gd` volumes). |

## 2. Kit definition (all four rooms)

Sizes are the current greybox volumes that art must respect.

**Shell:** `lab_floor_2x2_a/b`, `lab_floor_edge_2m_a` (pit and ledge lips), `lab_wall_2m_a/b`, `lab_wall_low_2m_a` (0.9 m camera-side wall), `lab_wall_corner_a`, `lab_divider_wall_2m_a` (0.6 m, two-sided), `lab_door_frame_a` (opening 2.8 × 3.0). Baseboards are integrated in wall modules (no separate asset).

**Interactive:**

| Component | Greybox volume (m) | Art asset (later batch) |
|---|---|---|
| `terminal.gd`, `powered_terminal.gd` | body 1.0 × 1.0 × 0.7, tilted screen | `lab_terminal_a` (exists), `lab_terminal_power_a` |
| `connection_node.gd` | base 0.7 × 0.5 × 0.7, orb r 0.28 @ y 0.85, ring r 0.5 @ y 0.55 | `lab_power_node_a` |
| `junction_box.gd` | 1.1 × 1.0 × 0.6, lamp 0.3 × 0.1 × 0.05 | `lab_junction_box_a` |
| `lever.gd` | base 0.9 × 0.5 × 0.6, arm 0.1 × 0.9 × 0.1, knob 0.2 | `lab_lever_a` (arm as separate pivoting mesh) |
| `push_button.gd` | 0.5 × 0.7 × 0.5, cap 0.36 × 0.1 × 0.36 @ y 0.75 | `lab_button_pedestal_a` |
| `door.gd` | slab 0.4 × 3.0 × 2.8, strip above | `lab_door_slab_a` |
| `robotic_arm.gd` | 0.7 × 2.2 × 4.8 @ (0, 1.1, 0.8), base r 0.6 h 0.3 | `lab_robotic_arm_a` (single mesh, rotates as one) |
| `checkpoint.gd` | posts 0.2 × 2.6 × 0.2 at z ±1.2, lintel y 2.6 | `lab_checkpoint_arch_a` |
| `memory_fragment.gd` | gem 0.3 cube @ y 1.0 | `lab_memory_fragment_a` |
| `moving_platform.gd` | 3.0 × 0.4 × 5.0 + hazard stripes | `lab_platform_a` |
| `hazard_zone.gd` | floor plate 3 × 0.06 × (3, 8, 8, 6) at x = 66, 71, 76, 81; warning/active column 2.2 high | `lab_hazard_plate_a` (3 m module, tileable along z) |
| `inspect_point.gd` | console 0.7 × 1.0 × 0.5, barrel r 0.35 h 0.9, crate 0.9 × 0.7 × 0.9 | `lab_console_a`, `lab_barrel_a`, `lab_crate_a` |

**Ambient:** `lab_container_a` (exists), `lab_shelf_a`, `lab_monitor_a/b`, `lab_cable_*`, `lab_pipe_*`, `lab_wall_light_a` (exists), `lab_cable_tray_a`, plus dirt/sign decals.

## 3. Integration rule (applies to every batch)

- Functional colliders stay exactly where they are. Art is **visual only**: no `CollisionShape3D` in any GLB; art never moves, resizes or replaces a collider, trigger or interaction origin.
- State visuals must stay controllable: each interactive asset names its emissive parts (`emit_orb`, `emit_ring`, `emit_lamp`, `emit_screen`, `emit_cap`) so they can be driven exactly like today.
- **Decision D1 (needed before Batch 2, not Batch 1):** how art attaches without gameplay-script changes. Option A (recommended): a separate `lab_art_dressing.tscn` added to the level that overlays art on the greybox and a one-line, visual-only toggle that hides the greybox meshes. Option B: swap meshes inside each component. Option A touches only `abandoned_lab.tscn`/`.gd` minimally and only after your approval.

## 4. Three production batches

Shared rules: GLB in `assets/models/lab/` (Elena in `assets/models/characters/`); 1 unit = 1 m; +Y up; front +Z; embedded `lab_mat_*` materials; no baked lights/cameras; `.blend` and capture PNGs stay out of the repo; reproducible Python in `tools/blender/`; automated `--check` plus your visual review in Godot before the next batch.

### Batch 1 — base environment kit + Elena blockout (specified in detail in `LAB_BATCH1_SPEC.md`)

| Item | Detail |
|---|---|
| New assets | `lab_wall_low_2m_a`, `lab_wall_2m_b`, `lab_floor_2x2_b`, `lab_floor_edge_2m_a`, `lab_divider_wall_2m_a`, `lab_door_frame_a`, `elena_blockout_a` |
| Reused | `lab_floor_2x2_a`, `lab_wall_2m_a`, `lab_wall_corner_a`, `lab_wall_light_a` |
| Triangles | as built: modules 36–204 each; Elena 1,544 (budget ≤ 3,500) |
| Materials | existing 8 `lab_mat_*` + 9 `elena_blk_*` (+ `lab_mat_painted_metal` for the unlit beacon) |
| Textures | None. The proposed detail map was dropped to respect the no-PNG-in-repo rule; `_b` variants use geometric wear. |
| Collisions | none in GLBs; colliders added in the test scene only (same pattern as `build_util.gd`) |
| Export | GLB per asset, applied transforms, pivots as in the spec |
| Test scene | `scenes/levels/art_tests/lab_kit_art_test_batch1.tscn`: room slice with divider and door frame, camera-side low wall, pit edge, Elena blockout beside the current capsule Elena, same camera and lighting |
| Acceptance (Godot) | see §5 |

### Batch 2 — interactive props, rooms 1 and 2

Assets: `lab_power_node_a`, `lab_junction_box_a`, `lab_terminal_power_a`, `lab_lever_a`, `lab_button_pedestal_a`, `lab_door_slab_a`, `lab_robotic_arm_a`, `lab_checkpoint_arch_a`, `lab_memory_fragment_a`, `lab_console_a`.

- Dimensions: the greybox volumes in §2. Silhouette may add detail inside those volumes; it must not exceed them by more than 5 cm.
- Triangles [proposed]: ≤ 600 each (arm ≤ 1,000); batch ≈ 6,000.
- Materials: existing set + `lab_mat_state_emissive_*` (amber/cyan/red/green keep their current gameplay meanings; color is never the only state cue, labels remain).
- Textures: reuse `lab_detail_wear_a`; no new maps unless decided.
- Collisions: none exported; existing functional colliders untouched.
- Export: named emissive sub-meshes; pivots at the component origin so the existing transforms still apply.
- Acceptance: each prop sits on its component origin; interaction prompt, scan overlay and glow states still read; silhouette identifiable in grayscale from the gameplay camera; **requires D1**.

### Batch 3 — ambient props, room 3 and room 4

Assets: `lab_platform_a`, `lab_barrel_a`, `lab_crate_a`, `lab_shelf_a`, `lab_monitor_a/b`, `lab_cable_run_*`, `lab_pipe_*`, `lab_cable_tray_a`, room 4 hazard set (`lab_hazard_plate_a`, `lab_hazard_emitter_a` mounted on the walls beside each zone), signs and dirt decals.

- Triangles [proposed]: ≤ 400 per ambient prop; hazard props ≤ 800; scene budget to be set from profiling.
- Textures: decal atlas (requires the texture-policy decision D3); signs use localized `Label3D` text, never baked text.
- Collisions: ambient props are visual-only unless a prop must block; any blocking collider is a separate, documented gameplay decision.
- Room 4 (x 58–86) is specified against the implemented zones in `abandoned_lab.gd` / `hazard_zone.gd`.
- Hazard fairness is a gameplay rule: the plate keeps distinct, non-color-only states (off, warning, active) and the decoy must remain distinguishable from real zones exactly as it is in the greybox. Art must not make the decoy look more or less dangerous than today; the per-state emissive part is named `emit_plate` so `hazard_zone.gd` keeps driving it.
- Zone footprints and timings stay owned by the scripts; art never changes them.
- Acceptance: no gameplay-readability regression (hazards identifiable without color), profiling evidence before any performance claim.

## 5. Batch 1 acceptance criteria (owner validates in Godot 4.7.2)

1. `--check` reports 0 failures (sizes, pivots, materials, collision rays).
2. Pivots and sizes match the spec; modules tile with no gaps or z-fighting at 2 m steps.
3. Camera framing: from the existing camera, the low wall, the divider, the door opening and the pit edge are all readable; the interior is not occluded.
4. Grayscale review: floor, wall, door frame and Elena separate by value.
5. Elena blockout reads as the concept art silhouette (long teal coat, backpack, knee boots) at gameplay distance and does not clash with the capsule size.
6. Amber and cyan remain reserved for interactables and Elena respectively.
7. No gameplay file, `project.godot`, autoload or input action is modified.

## 6. Decisions

The owner delegated these decisions ("take the most appropriate ones and continue"). They are recorded here and can be reversed.

- **D1 — Art attachment: option A, refined (decided 2026-10-14, delegated by the owner).** `abandoned_lab.tscn/.gd` stay **unchanged**. The level builds its greybox in code (`abandoned_lab.gd`, `_ready`), and its only loader is the `NEXT_PATH` constant in `scripts/levels/elena_test_room.gd`. So the art is attached by a **wrapper scene** `scenes/levels/abandoned_lab_art.tscn` that instances `abandoned_lab.tscn` and adds a `lab_art_dressing.gd` node. After the level's `_ready` it finds the greybox pieces by their built names/positions, adds the art instances beside them, and hides the greybox meshes (visual only; colliders, interaction origins and scripts untouched). Switching is one constant (`NEXT_PATH`) and is reversible. Imported materials are shared per asset, so the dressing duplicates materials per instance. **Implemented 2026-10-14** as visual-only wrappers: `scenes/levels/abandoned_lab_art.tscn` (phase 2, whole lab x 0–86; `NEXT_PATH` in `elena_test_room.gd` points at it) and `scenes/levels/elena_test_room_art.tscn` (phase 1; `LEVEL_PATH` in `main_menu.gd` points at it), both driven by `scripts/levels/lab_art_dressing.gd` with a profile. They add batched floor tiles, walls, dividers, consoles, containers and wall lights with photographic CC0 textures (triplanar) and raise the level's ambient/sun and lower its fog. To go back to the plain greybox, revert those two constants. No colliders, so Elena can walk through the set pieces; pits in room 3 stay undecorated. **Interactive components (2026-10-14):** `scripts/levels/lab_art_components.gd` hangs the Batch 2 art under each known component (power nodes, junction boxes, terminals, push buttons, memory fragments, checkpoints, levers, doors, the robotic arm), hides its greybox meshes by render layer 0, and mirrors the greybox glow, visibility, lever angle, door slide and fragment bob onto the art's `emit_*` parts every frame; scan highlight works because the scan walks the component's mesh children. Component scripts and colliders are untouched (`tests/test_lab_art_components.tscn`: 12 checks). Inspect points now show a container, console or a Poly Haven barrel scaled to their greybox footprint, and moving platforms get a photographic metal material. Not yet dressed: hazard zones, the prototype carrier, and tutorial barriers/stations (no art in the kit; hazard zones stay flat on purpose so danger reads by colour). Not final.
- **D2 — Amber backpack beacon:** modelled unlit, no emission (amber stays reserved for interactables).
- **D3 — Textures:** none for now (no PNG in the repository). Dirt and decals stay postponed until the owner approves a policy.
- **D4 — Elena front is +Z**, as in the game.
- **D5 — Tooling:** Blender MCP is unavailable in this environment; headless Blender with reproducible scripts is used and noted in every delivery.

## 7. Status

| Batch | State |
|---|---|
| 1 — environment kit + Elena blockout | Generated, checked (40 checks), pushed; awaiting the owner's visual validation. |
| 2 — interactive props, rooms 1–2 | Generated, checked (47 checks); `LAB_BATCH2_SPEC.md`; awaiting the owner's visual validation. |
| 3 — ambient props, rooms 3–4 | Not started; superseded by the reference-scene phase below. |
| Reference scene — quality target | Built as an isolated scene (`LAB_REFERENCE_SCENE_SPEC.md`); awaiting the owner's visual review. Batches 1–2 are kept only as blockouts and technical references. |
