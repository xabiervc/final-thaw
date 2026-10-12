# Lab Art — Next Batch (proposal, not implemented)

Source of requirements: `scripts/levels/abandoned_lab.gd` (read only). Nothing below has a specification, geometry or approval yet; each item needs a written spec (size, silhouette, materials, collision, Godot integration) before it is modelled.

## Decisions needed before modelling

1. **Texture policy.** Batch 1 is flat-color. Dirt, signs and decals need textures, which means defining import/compression settings explicitly. Proposal: decals as separate quads with a small shared atlas, reviewed once before any texture is added.
2. **Wear scale.** Define levels 0–5 (the palette test mentions 2/5) with a visual reference per level.
3. **Sign text.** Text must be localized ES/EN and externalized; signs use `Label3D` or localized textures, never text baked into one language.
4. **Gameplay-prop dimensions.** Confirm real sizes and colliders from `terminal.gd`, `powered_terminal.gd`, `connection_node.gd`, `junction_box.gd`, `robotic_arm.gd`, `door.gd`, `checkpoint.gd` and `memory_fragment.gd` before speccing the matching art. Art must not change gameplay scripts or interaction ranges.

## Batch 2 — rooms 1 and 2 shell

| Asset | Purpose |
|---|---|
| `lab_floor_2x2_b`, `_c` | wear variants (scuffs, light staining) |
| `lab_floor_grate_2x2_a` | drainage/grate variant for room 2 |
| `lab_wall_2m_b`, `_c` | damaged panel, panel with vent |
| `lab_wall_2m_window_a` | observation window panel |
| `lab_wall_corner_outer_a` | outer corner for divider walls |
| `lab_wall_end_cap_a` | closes wall ends at openings |
| `lab_door_frame_a` | frame for "Puerta del laboratorio" (x = 16) and "Compuerta del brazo" (x = 34) |
| `lab_divider_wall_a` | replaces the 0.6 × 2.0 × 5.0 block in room 1 |

## Batch 3 — gameplay-linked props

| Asset | Used by |
|---|---|
| `lab_power_node_a` (× 3 placements) | room 1, "Nodo 1–3" |
| `lab_junction_box_a` | room 1, "Caja de unión" |
| `lab_terminal_power_a` | room 1, "Terminal de energía" (variant of `lab_terminal_a`) |
| `lab_robotic_arm_a` | room 2, arm |
| `lab_terminal_arm_a` | room 2, "Control del brazo" |
| `lab_memory_fragment_a` | both rooms, memory fragments |
| `lab_checkpoint_a` | checkpoints at x = 18 and x = 36 |
| `lab_door_a` | both doors, matching the existing door collider |

## Batch 4 — secondary props

`lab_desk_a`, `lab_chair_a`, `lab_shelf_a`, `lab_cart_a`, `lab_crate_a` (stackable), `lab_locker_a`, `lab_tablet_a`, `lab_beaker_set_a`.

## Batch 5 — details and recent abandonment

- **Cables:** `lab_cable_run_straight_a`, `lab_cable_run_corner_a`, `lab_cable_hanging_a`, cable tray.
- **Dirt:** floor stain, wall water stain, dust edge, scuffs (decals; depends on texture policy).
- **Signs:** hazard sign, room label, door label, arrow marker (localized).
- **Recent abandonment:** cup on desk, open notebook, coat on chair, overturned chair, dimmed monitor, opened locker, half-packed crate.
- **Lighting set:** `lab_wall_light_b` (flickering variant, asset only; behavior is gameplay/VFX), `lab_ceiling_panel_a` if the camera ever needs it.

## Suggested order

Decisions 1–4 → Batch 2 (unblocks assembling rooms 1 and 2) → Batch 3 → Batch 4 → Batch 5. Each batch ends with an automated `--check` and an owner review in Godot before the next starts.
