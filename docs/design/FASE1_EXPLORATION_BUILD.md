# Phase 1 exploration expansion — first construction pass

> **ESTADO ACTUAL — REFERENCIA NO CANÓNICA.** Este documento describe un diseño/prototipo anterior y se conserva como histórico/comparativo. Para implementar el slice actual, seguir `FASE1_FUNCTIONAL_SPEC.md` v1.0, `FASE1_SPATIAL_GRAPH.md` v0.4, `FASE1_GREYBOX_SPEC.md` v1.1, `fase1_fase2_mapa_progresion.md` v0.6 y `FASE1_LOGIC_CONTRACT.md`. No utilizar sus recorridos, coordenadas ni preguntas abiertas cuando contradigan esas fuentes.

Status: new alternative scene prepared, not executed in Godot or manually validated. Not definitive. Baseline six-room scene and all shared scripts remain unchanged.

## Run

Open scenes/prototypes/phase1_exploration_greybox.tscn and press F6. Run tests/test_phase1_exploration.tscn separately for smoke/surface checks. Mouse orbit, WASD, Space, E interactions, H hints and F4/F5 review views are inherited. No changes to main_menu.

## Exact extension

Existing six-room coordinates are preserved. Added clear footprints: approach X -24..-6 / Z -2..4 / Y 0; observation gallery X 18..26 / Z 14..24 / Y +1.5; lower passage X 26..42 / Z 18..22 / Y -2; workshop X 42..52 / Z 16..28 / Y -2. Source constants are in phase1_exploration_greybox.gd.

Approach joins vestibule through a 6x2 m ground connector X -6..0 / Z 0..2. Gallery is stacked above the eastern portion of the pit: 3.25 m clearance to its floor underside, intentionally overlapping in plan but not in walkable volume. Hall-gallery stairs X 22..24 / Z 8..14 rise 1.5 m over 6 m (14.04 degrees). Workshop-pump stairs X 42..44 / Z 6..16 rise 3.5 m over 10 m (19.29 degrees). Both have 2 m clear nominal width.

Gallery inspection windows occupy X 18..22 at Z 14 and Z 8, from Y 1.1..3.3. Window collisions remain, visible glass is transparent. Baseline pit north/east/south walls are rebuilt to top Y 1.2 below the upper floor, with the east passage opening retained. The lower passage has a partition from Z 18..20 at X 34, leaving a 2 m route south of it.

Graph without shortcut: approach -> vestibule -> hall -> pit -> passage -> workshop -> pumps -> upper walkway -> cabin. Existing direct hall-pump stairs remain; gallery is optional and reached from the hall. The cabin return shortcut remains. New rooms currently reuse facility materials but do not have finished set dressing.

## Verification boundary

An equivalent Python data check found ten rooms graph-reachable without the shortcut, no same-height room overlap, 3.25 m vertical clearance for the stacked gallery/pit, and both new slopes below 30 degrees. This is not GDScript execution, collision simulation or a playtest. Godot tests only check construction, selected floor samples, inherited interactions and shortcut side rules; they do not prove complete routes, sightlines or entertainment.

Runtime checks needed: all apertures and stair joins, gallery view of the rig, lower-room head/camera clearance, optional route discovery, safe restoration, and renderer cost of the extra lights. The gallery floor may affect pit camera framing. Fixed collision ramps remain the walking surface of staircases.

## Remaining work towards a definitive Phase 1

Scanner and physical trace presentation; longer-route ambience and meaningful discoveries; line-of-sight interaction targeting; truthful indicator semantics; robust scenario assertions; save/retry integration; accessibility and performance passes; unfamiliar-player deduction/exploration test. Archive evidence, extraction authorization, scanner chronology and containment require script approval. Pursuit and the standalone lift are not integrated here. No claim that this new route already delivers the proposed 15-25 minutes.
