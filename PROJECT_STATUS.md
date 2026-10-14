# Project Status — FINAL THAW

## Current phase

**Phase 1 — architectural direction closed; the current greybox must be rebuilt to match it.** Existing circuit/lift components and motion/chase prototype v2 remain. These plans are a design decision, not a claim that new floors already exist in Godot.

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

The canonical scene still reflects the previous geometry: lift to Y=3 and return stair in G. Rebuild the room partitions, M/S2/G, and set the mission lift to Y=1.5. Generic 3 m tests remain; add a 1.5 m mission test. No Godot execution or manual playtest is claimed.

## Next verification

1. Rebuild geometry without changing circuit behavior.
2. Add mission checks for graph and 1.5 m elevator.
3. Run circuit, lift, transport, canonical integration, and Phase 0 regression under Godot 4.7.x/Compatibility.
4. Manually check sightlines, camera, clearance, gates, lift power loss, clues and G→H.
5. Validate motion/chase v2 separately before accepting the combined slice.

Preserve inputs/autoloads/resource paths, JSON/CRC32 saves and Compatibility renderer. Keep old scenes. Distinguish code, automated tests, run results and human validation.
