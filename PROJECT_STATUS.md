# Project Status — FINAL THAW

## Current phase

**Phase 1 — canonical scene rebuilt in code to the four-elevation design; runtime verification pending.** Existing circuit/lift components and motion/chase prototype v2 remain. These plans are a design decision, not a claim that new floors already exist in Godot.

## Sources of truth

- Architecture: docs/design/FASE1_ARCHITECTURAL_LAYOUT.md v1.0.
- Plans and section: docs/design/assets/phase1_architecture/ (SVG).
- Spatial graph: FASE1_SPATIAL_GRAPH.md v0.6.
- Greybox: FASE1_GREYBOX_SPEC.md v1.3.
- Functional spec: FASE1_FUNCTIONAL_SPEC.md v1.1.
- Progression: fase1_fase2_mapa_progresion.md v0.8.
- Lift: FASE1_LIFT_GATE.md v1.1.
- Circuit: FASE1_LOGIC_CONTRACT.md (unchanged).
- Build protocol: FASE1_CANONICAL_BUILD.md.

## Architectural decision

P−1 maintenance pit Y=−2 m; P0 access/test hall/workshop Y=0 m; M pumps/observation mezzanine Y=+1.5 m; P2 control/archive/exterior vestibule Y=+3 m.

Unique vertical routes: S1 P0↔P−1; elevator P0↔M; S2 M↔P2; direct P0↔P2 stair blocked. G exits horizontally to H, with no stair back to P0.

## Implementation status

The canonical scene builder now constructs P−1, P0, M (+1.5 m) and P2 (+3 m), configures the mission lift to +1.5 m, adds M/S2, and removes the return stair from G. A dedicated .tscn resource and integration assertions are included. Godot execution and manual playtest are still pending; do not treat static changes as runtime validation.

## Next verification

1. Run circuit, generic lift, transport, canonical integration, and Phase 0 regression under Godot 4.7.x/Compatibility.
2. Fix any parse/runtime/test failures before expanding the slice.
3. Manually traverse A→B→D→P0→M→S2→E→F→G→H; inspect sightlines, camera, clearance, gates, lift power loss, clues and transition.
4. Validate motion/chase v2 separately before accepting the combined slice.

Preserve inputs/autoloads/resource paths, JSON/CRC32 saves and Compatibility renderer. Keep old scenes. Distinguish code, automated tests, run results and human validation.
