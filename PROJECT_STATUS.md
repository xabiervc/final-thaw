# Project Status — FINAL THAW

## Current phase

**Phase 1 — architectural greybox reconstruction in progress; runtime verification pending.** The canonical scene builder has been expanded to represent a connected industrial facility across four elevations. This is implementation work, not proof that the scene runs or that the traversal is accepted.

## Sources of truth

- Architecture: docs/design/FASE1_ARCHITECTURAL_LAYOUT.md v1.1.
- Plans and section: docs/design/assets/phase1_architecture/ (existing SVGs).
- Spatial graph: FASE1_SPATIAL_GRAPH.md v0.7.
- Greybox: FASE1_GREYBOX_SPEC.md v1.4.
- Functional spec: FASE1_FUNCTIONAL_SPEC.md v1.1.
- Progression: fase1_fase2_mapa_progresion.md v0.9.
- Lift: FASE1_LIFT_GATE.md v1.1.
- Circuit: FASE1_LOGIC_CONTRACT.md (unchanged).
- Build protocol: FASE1_CANONICAL_BUILD.md.

## Architectural decision

P−1 maintenance void D1/D2 at Y=−2 m; P0 exterior approach tunnel, access/test hall and workshop at Y=0 m; M pumps/observation mezzanine Y=+1.5 m; P2 control/archive/exterior vestibule Y=+3 m. G opens horizontally to H and transitions to the parking-entry variant of the chase prototype. The standalone corridor prototype retains its own start checkpoint.

Unique vertical routes: S1 P0↔P−1; elevator P0↔M; S2 M↔P2; direct P0↔P2 stair blocked. No return stair from G.

## Implementation status

The canonical builder now adds room boundaries and industrial fixtures at P0, an open D1/D2 maintenance void with continuous lower floor, sloped handrails on S1/S2, lateral protection at both lift landings, and guardrails on exposed M/P2 edges. The mission lift remains P0↔M (+1.5 m); G→H targets a dedicated parking-entry point in the existing chase script. The existing scene wrapper and regression tests are preserved; a parking-entry scene variant and dedicated smoke test have been added. The latest edits have not been executed in Godot. Visual scale, collision clearances, floor holes, camera readability and the G→H parking handoff are not verified.

## Automated regression

A GitHub Actions workflow (`.github/workflows/godot-headless-tests.yml`) defines the import step and the Phase 0, vertical slice, circuit, generic lift, lift transport, canonical integration and parking-entry tests for Godot 4.7.1. The workflow is currently disabled (`if: false`, manual dispatch only), and no run result is recorded. CI is not claimed green or active.

## Next verification

1. Run circuit, generic lift, transport, canonical integration, parking-entry smoke test, existing vertical-slice regression and Phase 0 regression under Godot 4.7.x/Compatibility.
2. Fix parse/runtime/test failures before adding detail.
3. Manually traverse A→B→D1/D2→B→service gallery→M→S2→E→F→G→H.
4. Inspect sightlines, camera, collisions, clearances, doors, lift power loss and clues.
5. Verify parking context and chase transition as a separate integration gate.

Preserve inputs/autoloads/resource paths, JSON/CRC32 saves and Compatibility renderer. Keep old scenes. Distinguish code, automated tests, run results and human validation.
