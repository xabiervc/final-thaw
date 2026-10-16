> **Rediseño espacial acordado (2026-10-16):** huella conceptual de 48 × 34 m (1.632 m² brutos; 2,32× la referencia de 30 × 23,5 m), cuatro cotas de planta (P−2, P0, mezzanine parcial M +1,50 y ala superior P+3), nave central de laboratorio de 6–8 m de altura libre y plantas superiores que dejan la nave en doble/triple altura donde corresponda. Las cotas son niveles de suelo, no alturas libres. En P0 se distinguen el acceso arquitectónico antiguo al pasillo y la brecha por la que entra Elena, que colapsa físicamente tras su entrada. La conexión con el segundo edificio clandestino queda fijada en P−2, oculta en el muro oriental del taller muerto; se descubre por indicios, pero permanece cerrada hasta obtener la llave de transferencia. La llave de transferencia es independiente de la llave de servicio y del puente aislado, que restauran la energía. La transición exige tanto la cadena de transferencia como la restauración eléctrica y el acceso físico a la puerta. La sección vertical debe representar el vacío de la nave y las alas parciales; no dibujar una mezzanine atravesando la nave a +1,50 m. Véanse [FASE1_ARCHITECTURAL_LAYOUT.md](design/FASE1_ARCHITECTURAL_LAYOUT.md), [FASE1_SPATIAL_GRAPH.md](design/FASE1_SPATIAL_GRAPH.md) y [fase1_fase2_mapa_progresion.md](design/fase1_fase2_mapa_progresion.md). Todo ello sigue siendo diseño objetivo, no implementación validada; los contratos técnicos y de guardado existentes permanecen protegidos.

# FINAL THAW — Design Authority During Prototype-Led Redesign

> **v4.0 note (2026-10-15, as-built):** Where Phase 1–2 documents disagree with the built game, the as-built record wins, and every affected document carries a pointer to it. See [FASE1_PREMIUM_AUDIT.md](design/FASE1_PREMIUM_AUDIT.md) (v4.0).

## Purpose

This document separates current design direction, actual implementation evidence, protected technical contracts and legacy full-campaign specifications. The project is developing a two-mission opening; the former campaign package is not fully reconciled with this direction.

## Active design authority

| Area | Source | Status |
|---|---|---|
| Working vision | `docs/VISION.md` | Active working vision; full-game canon is not locked |
| Prototype scope and boundaries | `docs/DESIGN_PIVOT_PROTOTYPE_BRIEF.md` | Active brief for the opening prototype |
| Core gameplay and narrative loop | `docs/CORE_LOOP.md` | Active design contract for the opening; implementation state is separately tracked |
| Opening level structure and Phase 2 spatial design | `docs/LEVEL_STRUCTURE.md` plus `docs/design/assets/phase2_parking/` | Design authority for route, concept v0.3 plan/section, edge clearances, obstacle register and selected handoff transform; dimensions/colliders require runtime reconciliation |
| Mission 1 puzzle | `docs/design/MISSION1_GHOST_PROTOCOL.md` plus `docs/design/FASE1_LOGIC_CONTRACT.md` | Puzzle design and logic contract; implementation and integration must be evidenced |
| Phase 1 architecture/program | `docs/design/FASE1_ARCHITECTURAL_LAYOUT.md` v3.1 | Expanded spatial intent; high central nave, partial mezzanine and P−2 clandestine connection; plans, graph and scene must remain aligned |
| Phase 1 plans and section | `docs/design/assets/phase1_architecture/` | Drawing authority for the expanded target; section must show the nave void, partial upper wings and P−2 transfer doorway; physical alignment remains pending verification |
| Phase 1 spatial graph | `docs/design/FASE1_SPATIAL_GRAPH.md` v1.1 | Current target topology; verify footprints and traversability in Godot |
| Phase 1 greybox dimensions/collisions | `docs/design/FASE1_GREYBOX_SPEC.md` v2.1 | Target measurements and collision contract, not proof of built geometry |
| Phase 1 functional experience | `docs/design/FASE1_FUNCTIONAL_SPEC.md` v2.1 | Target interactions, puzzle and escape flow; some escape requirements are not implemented |
| Phase 1/2 progression | `docs/design/fase1_fase2_mapa_progresion.md` v1.1 | Quiet evasion → perceptible reacquisition → running chase → selected exit and physical parking handoff; implementation pending |
| Movement/chase prototype mechanics | `docs/design/MOTION_CHASE_PROTOTYPE.md` plus current code | Prototype behavior and known limits; v2 test/playtest status must be recorded |
| Requirement-to-evidence mapping | `docs/TRACEABILITY_MATRIX.md` | Maps intended behavior to implementation, tests and verification gaps |
| Implementation status | `PROJECT_STATUS.md`, current scene/script/test state and recorded results | Source of truth for what exists and what was actually verified |
| Opening script and legacy narrative archive | `docs/narrative_complete.md` | Opening beats N2-01…N2-06 and unresolved decisions at the top are current proposals; the legacy full-campaign material below is historical where it conflicts with the active prototype direction |
| Technical/workflow contracts | `docs/PROJECT_CONTRACT.md`, `docs/QUALITY_GATES.md`, `AGENTS.md` | Protected engineering, testing and evidence requirements |
| Asset provenance | `docs/art/PROVENANCE.md` | Active source/licence record |

## Selected opening design decisions

These decisions are the current design baseline for the opening. **Selected** means the design direction is chosen; it does not mean the scene has been implemented or runtime-verified.

| Decision | Selected baseline | Remaining gate |
|---|---|---|
| Phase 1 exterior route | P−1 east service mouth at world X=34, Z=4.5..7.5, Y=−2.0 m; 3 m clear opening through a 6 × 3 m gallery. It is distinct from the west entrance. | Verify physical route, wall opening, elevation and collision continuity in the canonical scene. |
| Phase 1 → Phase 2 transform | Parking local frame maps with X_world=X_local+28.7 m, Z_world=Z_local−15.8 m, Y=−2.0 m. Entry threshold maps to world (34, 6, −2); recovery checkpoint to (35.5, 6, −2); far egress beyond the north wall to (71.5, −16.2, −2). | Verify the actual local/world transform, gate crossing, player capsule and camera; update all drawings together if the scene differs. |
| Chase pacing | Quiet evasion through F/E and M with STAFF-M1 perception; R1 in P0 triggers full running chase after the recovery unit follows through the existing lift and reacquires Elena by real line of sight; route continues via S1/P−1 to the east gallery and parking. | Verify NPC perception, R1 volume, chase transition and continuous route in Godot. |
| Parking footprint | Combined facade/site envelope 48 × 30 m, including the 5.3 m facade band; clear parking yard is 42.7 m east of the service threshold. Entry opening 3.0 m; north egress gate 3.6 m. | Verify dimensions and clearances against the real player/threat capsules. |
| Parking vertical language | Open-air central apron, no continuous canopy; two overhead service pipe racks at the inner parking-row edges with 2.8 m clear below. Pavement datum matches P−1 at Y=−2.0 m. | Verify wall height, rack supports, camera clearance, collision and lighting in the actual renderer. |
| Parking obstacle contracts | P2-O1: static 1.9 × 2.1 m, 1.1 m high; P2-O2: static 3 × 2 m, 1.4 m high, low cover only when crouched; P2-O3: fixed leaves with a 1.3 × 2.2 m clear aperture, no timed movement and no bypass in the baseline. | Verify each envelope, the O1 pinch and O3 passage for Elena and the recovery unit. |
| Parking checkpoint | P2-01 is the continuous scene handoff threshold. P2-CP is a recovery-only checkpoint 1.5 m inside the vestibule; it is not the initial spawn. | Test initial handoff and repeated failure recovery without teleport, state loss or direct unfair detection. |
| Containment trigger | Maintenance queues SERVICE_OVERRIDE; opening the exterior leaf of G sends the queued audit and starts Containment. Reading the restricted record alone is not the trigger. | Verify the exact event fires once; the specific recipient/command chain remains an open narrative decision. |

## Legacy specifications under review

Earlier documents describe a fixed 16-phase campaign, 13–15 hour duration, dual-protagonist switching, Marcus combat, combat arenas, survival counters and three fixed endings. Preserve this material as historical input; do not silently treat it as current prototype scope or erase its useful story ideas.

Relevant legacy sources include `docs/core_gameplay_loop.md`, detailed campaign tables in `docs/narrative_complete.md`, `docs/EXPLORATION_FLOW.md`, `docs/PROGRESSION_SPEC.md`, `docs/SURVIVAL_SYSTEMS.md`, `docs/NARRATIVE_STATE_MAP.md`, `docs/VERTICAL_SLICE_PLAN.md` and older phase prompts.

## Conflict resolution

1. For Phase 1 spatial intent, use `FASE1_ARCHITECTURAL_LAYOUT.md` v3.1, the current plan/section SVGs, `FASE1_SPATIAL_GRAPH.md` v3.1 and `FASE1_GREYBOX_SPEC.md` v2.1. The expanded layout is a new target; older built geometry remains the as-built record until the greybox is replaced and verified.
2. For the opening's player-facing behavior and mission boundaries, use `DESIGN_PIVOT_PROTOTYPE_BRIEF.md`, `CORE_LOOP.md` and `LEVEL_STRUCTURE.md`.
3. For Phase 1 circuit behavior, `FASE1_LOGIC_CONTRACT.md` remains authoritative unless a specific change is explicitly approved.
4. For what exists, inspect current code, scenes and tests. Design documentation does not prove implementation.
5. For test status, require the exact command and observed result. A test file is not evidence that the test ran; a passing headless test is not a substitute for a manual playtest.
6. Preserve Phase 0 input actions/remaps, autoloads/public signals, resource paths, JSON/CRC32 save compatibility and Compatibility renderer assumptions unless impact analysis and explicit approval authorize a change.
7. When a legacy campaign document conflicts with the active prototype brief, the brief wins for prototype scope only. Record the conflict; do not silently declare the whole campaign redesigned.
8. Separate established story facts from proposals. The opening proposal now defines the causal beat (maintenance queues `SERVICE_OVERRIDE`; opening G's exterior leaf sends the audit and starts Containment) and recommends a facility-automated recovery protocol. The exact recipient/supervision, final recovery-unit identity, suppression motive, Marcus's role, chronology and endings remain open; do not promote proposals to full-game canon without owner approval.
9. Do not invent architectural connections to solve a gameplay beat. The selected Phase 1 → clandestine-building connection is the concealed transfer door in the P−2 dead workshop; it must appear in the P−2 plan, vertical section, spatial graph and progression contract. Do not substitute P+3, the lift, or an emergency exit for this threshold.

## Required review gates

### Mission 1 — The Ghost Protocol
- Confirm the circuit follows `FASE1_LOGIC_CONTRACT.md` and scanner clues do not reveal the answer.
- Verify partial success, invalid order, safe recovery and restricted-record behavior.
- Verify the reveal triggers Containment exactly once and only under the agreed event contract.

### Mission 2 — Containment and parking
- Review the provisional plan, section, spatial graph, edge-clearance contract, obstacle register and conceptual threat/light overlays as a consistent package; the P−1 east mouth and local-to-world transform are selected design baselines; verify their actual footprint, elevation and clearances against the canonical scene before implementation acceptance.
- Run `godot --headless --path . res://tests/test_motion_chase_prototype.tscn` and `godot --headless --path . res://tests/test_phase_0.tscn`.
- Run the scene manually; review movement, camera occlusion, staff NPC routines/perception, noise and cover in the quiet section, the mapped transition to running chase, enemy sight/hearing/search, catches, checkpoints, selected exit and physical handoff.
- Verify the Phase 1 interior pursuit and distinct P−1 service exit before accepting the parking integration.
- Record engine version, renderer, commit, commands/output, warnings/errors, manual QA, evidence and remaining limitations.

### Narrative and integration
- Define clue relationships and intended inference before implementation.
- Make the scanner support reasoning without solving the puzzle.
- Ensure the system reveal causes a single visible and audible Containment response.
- Ensure Mission 2 adds a new narrative implication without claiming unsupported canon.
- Test mission continuity, state preservation, checkpoint behavior and the end-of-mission beat.

### Asset and production
- Review from the actual gameplay camera, not beauty renders alone.
- Verify scale, collision alignment, clearance, occlusion, performance and asset provenance.
- Do not call an asset production-ready without integration and owner review.

### Full-game reconciliation
After the combined opening is reviewed and playtested, explicitly decide whether the two-mission direction is accepted as campaign canon. Then reconcile Marcus's role, chronology, campaign structure, endings, duration, platform scope, accessibility and narrative-state documents. Until then, keep the prior campaign preserved as legacy material.

## Change policy

Keep design changes traceable and reversible. Update existing sources of truth instead of creating competing documents. Never claim a feature is specified, implemented, tested, playable or production-ready beyond the evidence actually available.

## Owner-approved creative direction (2026-10-15)

The following decisions supersede earlier provisional assumptions where they conflict. They define the intended future direction; they do not claim that implementation has already changed or been runtime-verified.

### Visual identity
- Target style: **illustrated 3D adventure**, using the owner-provided Marcus concept as the primary character-art reference and the owner-provided illustrated industrial laboratory as a major environment-art reference.
- Do not target photorealism, generic cartoon styling, or deliberately low-resolution 1990s-console aesthetics. Use designed silhouettes, painterly/illustrated material treatment, controlled edge definition, disciplined palettes, cinematic composition and readable lighting.
- Apply one coherent visual language across characters, environments, props, effects and UI. Validate it in the actual Godot gameplay camera before scaling asset production.
- Preserve Elena's recognizable concept identity. Redesign the Aster/scanner device so it is physically integrated into a wrist mount or credible holster, or provide proper draw/use/stow animations; it must not appear inexplicably attached to her hand.

### Phase 1 — investigation and spatial exploration
- Phase 1 remains Elena-led and investigation-first. Retain the functioning Aster puzzle and field-notes loop where sound; improve the spaces and interactions around them rather than replacing working systems without cause.
- The building should feel substantially larger and more interconnected than a single open room, while remaining legible rather than labyrinthine. Retain a memorable central pumping hall as the spatial anchor, surrounded by purposeful rooms, vertical routes, landmarks, optional discoveries and meaningful shortcuts.
- Each major room must have a distinct gameplay or narrative purpose. Backtracking is justified only by a new deduction, changed system, newly opened route or optional discovery.
- Elena enters through a breach, collapsed culvert or damaged service access, not a normal door. The entry collapses physically after entry. The return route must be genuinely impassable through geometry/collision, not only dialogue or an invisible blocker.
- Elena is a scientist. Phase 1 should emphasize observation, hypothesis, testing, environmental interaction, traversal and deduction, not mandatory combat.

### Phase 2 — human discovery and hybrid first-person escape
- The current robotic recovery-unit escape is not the target final direction for Phase 2's principal threat. The new target is a human-operated restricted zone with a small number of purposeful personnel engaged in work related to Helix/Aster.
- Elena first moves cautiously through this previously unseen operational area and has an opportunity to observe its activity and discover meaningful evidence. Detection then initiates the escape.
- The escape is a **hybrid first-person sequence**: genuine free movement and route choices, combined with short, context-sensitive actions (vault, duck/slide, push an object, operate a door or choose a route). Prompts complement movement and must not turn the sequence into a long chain of arbitrary button presses.
- Brief motivated looks back and cinematic beats should show consequences of the player's actions, such as a pursuer being delayed by an object. Preserve player agency, readable hazards, accessibility and fair recovery from minor errors.
- The route reaches a separately designed parking garage through a credible service connection or controlled scene transition, then exits to a public street where Elena loses the pursuers in the crowd. The garage need not be adjacent to the central hall.

### Future Marcus-led beat-'em-up progression
- Future beat-'em-up phases are controlled by Marcus, with Elena accompanying him.
- Initially Elena cannot defend herself reliably: she seeks valid cover, stays near Marcus and requires intervention when threatened. She can still contribute through observation, warnings and environmental mechanisms.
- Across the story, Elena learns from Marcus. Her later abilities should include limited escapes from grabs, defensive dodges/blocks and opportunistic counters against basic threats. She must not abruptly become an expert fighter.
- Once Elena can defend herself, Marcus can focus on more demanding enemies. Increase challenge through enemy variety, coordination and attack patterns rather than only inflating health.
- This progression is an approved future design direction, not authorization to implement the full combat campaign in the current Phase 1/2 vertical-slice task. Document its contracts now; defer full implementation until the current opening is coherent.

### Product-level principle
Final Thaw may combine exploration, investigation, stealth, escape and beat-'em-up action, but each mode must serve a clear emotional and narrative purpose. Variety must not make the game feel like unrelated mini-games. The current production priority is to consolidate the illustrated visual identity and the Phase 1/2 experience.
