# Lab Art — Batch 2 Specification (interactive props, rooms 1 and 2)

**Role: technical blockout, not the artistic standard** (owner decision; see `LAB_REFERENCE_SCENE_SPEC.md`). **Status:** generated, imported in Godot 4.7.2 and checked automatically; **pending the owner's validation in Godot**. Not final, optimized or integrated: nothing here is used by `abandoned_lab.tscn`, and no gameplay script, scene, autoload, input action or `project.godot` was touched.

Conventions: `LAB_STYLE_SPEC.md`. Sources: `tools/blender/build_lab_interactive_props_batch2.py` (+ `lab_blender_common.py`); `.blend` outside the repo. Test scene: `scenes/levels/art_tests/lab_props_art_test_batch2.tscn` + `scripts/levels/art_tests/lab_props_art_test_batch2.gd`.

## Assets (`assets/models/lab/`)

Volumes are the greybox volumes of the component that each asset will dress (sizes from the component scripts). Origins are the component origin unless noted.

| Asset | Dresses | AABB as built (x·y·z, m) | Triangles (budget 600) | Named parts the gameplay recolors |
|---|---|---|---|---|
| `lab_power_node_a` | `connection_node.gd` | 1.00 · 1.13 · 1.00 | 428 | `emit_orb`, `emit_ring` |
| `lab_junction_box_a` | `junction_box.gd` | 1.10 · 1.00 · 0.655 | 140 | `emit_lamp` |
| `lab_terminal_power_a` | `terminal.gd`, `powered_terminal.gd` | 1.04 · 1.46 · 0.76 | 176 | `emit_screen` |
| `lab_lever_a` | `lever.gd` | 0.90 · 1.60 · 0.635 | 232 | `emit_lamp`, `emit_knob`; pivot node `LeverArm` at (0, 0.55, 0) |
| `lab_button_pedestal_a` | `push_button.gd` | 0.54 · 0.80 · 0.54 | 80 | `emit_cap` |
| `lab_door_slab_a` | `door.gd` | 0.60 · 3.245 · 3.10 | 144 | `emit_strip`; `DoorSlab` origin at (0, 1.5, 0) |
| `lab_robotic_arm_a` | `robotic_arm.gd` | 1.20 · 2.01 · 4.80 | 412 (budget 1,000) | none |
| `lab_checkpoint_arch_a` | `checkpoint.gd` | 0.26 · 2.72 · 2.68 | 192 | `emit_arch_post_L`, `emit_arch_post_R`, `emit_arch_lintel` |
| `lab_memory_fragment_a` | `memory_fragment.gd` | 0.46 · 1.24 · 0.46 | 144 | `emit_gem`, origin (0, 1.0, 0) |
| `lab_console_a` | `inspect_point.gd` (variant 1) | 0.74 · 1.00 · 0.56 | 116 | `emit_screen` |

Total 2,064 triangles. Terminal: one asset serves both terminal scripts; `lab_terminal_a` from the first batch has the screen merged into the body and cannot be recolored.

## Rules this batch follows

- **No collision in files.** The functional colliders (`make_solid`, `B.solid_box`, the arm's `AnimatableBody3D`) stay untouched; every asset fits inside its greybox volume (+5 cm tolerance), so it can sit over the existing collider.
- **Recolorable parts are separate meshes** named `emit_*`, each with its own material, and are never shared with the structural meshes. Default materials hold each component's initial state color; scripts replace them at runtime.
- **Origins match the scripts' expectations:** the lever arm pivots at (0, 0.55, 0); the gem sits at (0, 1.0, 0) because `memory_fragment.gd` animates `position.y = 1.0 + 0.1 sin(…)` and rotation; the door slab is a separate node at (0, 1.5, 0) because the script moves it in z while the strip stays.
- **New materials (pending approval as part of the palette):** `lab_mat_arm_orange` `#E6801F` (the greybox arm color) and `lab_mat_state_red` `#D93333`, `_green` `#33E680`, `_cyan` `#33B3E6`, `_gem` `#4DE6FF`, `_console` `#4DCCE6`, with the greybox emission energies. They are initial state colors, not a decision to reuse amber or cyan for new purposes.
- **Checkpoint legibility:** the greybox made the whole arch emissive. The arch plane is perpendicular to the player's path and the camera looks along −Z, so a first version with strips only on the ±X faces nearly disappeared. The final asset has strips on the ±Z faces of the posts and on the lintel top, which the camera sees.

## What the check covers (`-- --check`, headless)

47 checks, 0 failures: every asset sits inside its greybox volume, covers it within 25 cm and rests on y = 0; triangle budgets; all `emit_*` parts exist, have emission and a material not shared with the structure; 10 material colors (and emissive radiance); lever pivot at (0, 0.55, 0) and the knob orbits it at 0.95 m; gem origin; door slab and strip origins and slab travel 2.8 m with the strip fixed; recoloring one instance with its own material does not leak into another.

It cannot judge appearance, and it only shows that the assets are *ready* to be driven; no gameplay script drives them yet.

## Findings that affect the integration decision (D1)

- **GLB materials are shared across instances.** Setting a glow color on one prop's imported material would recolor every prop of that asset. Integration must duplicate the material per instance (the test scene does so, like `B.set_glow` needs).
- The scripts build their own greybox meshes in `_ready()` and recolor `material_override` on them. Dressing with art means either hiding those meshes or swapping them; both need a change outside this branch of work and are **not** done here.
- Decision recorded in `LAB_KIT_PLAN.md` §6: option A (overlay dressing scene + visual-only toggle), to be implemented only after the owner approves integration.

## Test scene keys

A/D or arrows: previous/next prop · 1–9, 0: jump · V greybox volume (orange wireframe) · C cycle emissive states · K lever · O door · G grayscale · P manual capture. Capture mode writes 30 PNG (10 props × color / grayscale / volume).

## What the owner validates

1. Each prop reads as its component at gameplay distance, in color and grayscale (`V` shows the volume it must respect).
2. The emissive parts keep their cue: press `C` and confirm amber/red/green/cyan states read, including the checkpoint and the lever lamp.
3. The lever pivots naturally (`K`), the door slab and strip behave (`O`), the gem animates around its origin.
4. The arm silhouette works as the passage blocker that the 0.7 × 2.2 × 4.8 m box is today.
5. The new state materials are acceptable as palette additions.
