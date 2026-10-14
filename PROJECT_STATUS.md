# Project Status — FINAL THAW

## Current phase

**Phase 1 — architectural redesign and canonical greybox reconciliation. Runtime verification pending.** The design now defines a complete clandestine/semi-abandoned industrial research facility, a building-wide investigation puzzle, an interior chase triggered by opening G, and a physically distinct service exit to the parking area. Documentation and SVG plans have been updated to this direction; the canonical Godot scene has not yet been reconciled to the full new route.

## Design direction and ownership

**Design ownership:** architecture, level design, progression, narrative/script, visual/audio direction, documentation consistency and acceptance criteria are specified in the design sources. Programming is implemented by the programming owner. Design documents define intended behavior; they do not claim code completion or runtime validation.

The Phase 2 design package now contains a provisional 48 × 30 m plan, transverse section, spatial graph, route-clearance contract, obstacle register, separate threat/sightline and lighting/landmark overlays, and a provisional opening script/trigger table. The plan's candidate transform aligns its entry with the Phase 1 mouth at approximately (X=34, Z=6), but the current prototype starts near (34.5, 0) and has only a 14 m corridor width; this mismatch is explicitly documented for the programming owner. The drawings are design proposals, not approved production geometry. `docs/narrative_complete.md` separates the opening script proposal and unresolved decisions from the legacy campaign archive; full-game canon is not locked.

## Sources of truth

Keep existing documents coordinated; do not create duplicates.

- Architecture and program: `docs/design/FASE1_ARCHITECTURAL_LAYOUT.md` v2.0.
- Plans and vertical section: `docs/design/assets/phase1_architecture/`.
- Spatial graph: `docs/design/FASE1_SPATIAL_GRAPH.md` v1.0.
- Greybox footprints/collisions: `docs/design/FASE1_GREYBOX_SPEC.md` v2.0.
- Functional experience: `docs/design/FASE1_FUNCTIONAL_SPEC.md` v2.0.
- Phase 1/2 progression: `docs/design/fase1_fase2_mapa_progresion.md` v1.0.
- Opening gameplay/narrative contract: `docs/CORE_LOOP.md`.
- Phase 2 parking architecture, routes, beats and acceptance: `docs/LEVEL_STRUCTURE.md` and `docs/design/assets/phase2_parking/` (plan, section, threat/sightline and lighting/landmark overlays; all provisional).
- Opening script and unresolved story decisions: top section of `docs/narrative_complete.md`; legacy campaign retained below.
- Requirement-to-evidence traceability: `docs/TRACEABILITY_MATRIX.md`.
- Circuit logic: `docs/design/FASE1_LOGIC_CONTRACT.md` (unchanged).
- Build and verification protocol: `docs/design/FASE1_CANONICAL_BUILD.md`.

## Architectural target

The facility is one coherent building with access/decontamination, Aster test hall, workshop, service galleries, lower pumping/distribution level, pump mezzanine, control, archive and a door G that initiates an interior escape. G is a two-door airlock: opening its exterior leaf triggers the interior pursuit, and Elena retreats through the inner leaf toward F/E. The final route returns through S2/M, the existing lift to P0, S1 to P−1 and a new evacuation gallery to an exterior service mouth connected to the parking area. This exit differs from the west entrance tunnel.

The existing vertical connections remain: S1 P0↔P−1; lift P0↔M (+1.5 m); S2 M↔P2; collapsed P0↔P2 stair remains blocked. Do not add a second lift or arbitrary secret stair.

## Implemented vs planned

- **Documented:** revised architectural program, spatial graph, progression contract, functional spec and greybox requirements; existing SVGs now show the P−1 evacuation gallery, G pursuit trigger, and initial O1/O2/O3 obstacle footprints.
- **Previously present in code, not runtime-verified:** west entrance tunnel, P0 rooms/perimeter, D1/D2 lower floor and P0 void, south/east return route, S1/S2, mission lift P0↔M, control/archive fixtures and safety rails.
- **Not yet implemented/verified against the revised architecture:** P−1 evacuation gallery and exterior mouth, G as the start of an interior chase, the obstacle sequence, the full chase traversal back through existing vertical connections, physical continuity into parking, and the end-to-end handoff.
- **Narrative direction specified as a proposal:** maintenance queues `SERVICE_OVERRIDE`; opening G's exterior leaf sends the queued audit and starts the facility recovery protocol. The Aster record states that the result was retained and the deployment recommendation suppressed.
- **Narrative decisions still open:** suppression motive, exact event recipient/supervision, final recovery-unit identity/visual design, Elena/Iris/Selene chronology in this moment, Marcus's role and post-parking destination.
- **Runtime status:** the previous editing environment did not have a Godot executable. No claim is made that recent GDScript, SVGs, or tests have been executed. CI status must be checked from the actual run before claiming green.

## Mandatory design work

1. Confirm the candidate Phase 2 world transform against the exact Phase 1 mouth width/orientation/elevation; then lock dimensions across plan, section and graph.
2. Reconcile `threat_sightline_overlay.svg` and `lighting_landmark_overlay.svg` against measured cover and the actual route graph; confirm each sightline endpoint and landmark visibility, then review the three provisional obstacle envelopes.
3. Complete a cross-document consistency pass across Phase 1 plans, section, spatial graph, greybox, progression and the new parking handoff.
4. Review and approve/revise the proposed opening script, particularly the suppression reveal and the end-of-parking beat; retain unresolved full-campaign decisions explicitly.

## Mandatory implementation work (programming owner)

1. Inspect and freeze exact footprints, clear widths, door swings/states, obstacles and the P−1 exit in every SVG and section.
2. Reconcile `scripts/prototypes/phase1_canonical_greybox.gd` and its scene to the plans; keep all coordinates traceable.
3. Implement G → interior chase → S2/M → lift/P0 → S1/P−1 → evacuation gallery → exterior parking.
4. Add integration tests for navigation, doors, chase state, lift state, exit mouth and parking checkpoint.
5. Run circuit, lift, transport, canonical integration, parking-entry, vertical-slice and Phase 0 tests under Godot 4.7.x/Compatibility.
6. Manually play the full route, inspect camera/collisions/clearances and verify the puzzle is inferable without mandatory text collection.
7. Record commit SHA, engine version, renderer, commands, exit codes, output, warnings/errors, manual QA and evidence.

Preserve existing autoloads, InputMap action names/remaps, resource paths, JSON/CRC32 save compatibility and Compatibility renderer. No feature is accepted from documentation or static tests alone.