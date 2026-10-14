# Phase 1 — Independent greybox specification (v1.2)

**Status:** geometry decisions closed; first canonical greybox code now exists in `scenes/prototypes/phase1_canonical_greybox.tscn` and `scripts/prototypes/phase1_canonical_greybox.gd`. It has not been executed or validated in Godot. See FASE1_FUNCTIONAL_SPEC.md v1.0 for exact interactions and progression. This document does not authorize final art, campaign integration, save migration, or changes to existing contracts.

## Coordinates and construction rules

Metres; Y up, X west-east, positive Z south. Main interior X 0..30, Z -10..10, walking surface Y=0. The cabin/public route is Y=3. Coordinates describe walking surfaces, not collider centres. Corridor and doorway dimensions are clear widths: rails, housings and wall thickness must remain outside clear rectangles. Third-person orbital camera; Compatibility renderer; no final art.

## Plan and section

```text
NORTH Z=-10
 [vestibule G / outer hatch][cabin/archive]---[controls]---[upper landing]
       | stairs to Y=0                          | platform
 [stairs][broken approach][machine]              |
 [entrance]---[south route]--[west pit corridor] |
                               | [pit]          |
                               '---[pit-stair apron]
SOUTH Z=+10

Y=+3: vestibule G -- cabin -- public walkway -- upper landing
Y= 0: entrance -- south route -- west pit corridor -- service apron
Y=-2: pit -- schematic -- bridge -- maintenance
```

The diagram is illustrative; footprints below define the layout.

## Main volumes

- Entrance (3,0,7), initially facing cabin (6,3,-7). Keep destination visible, not the solution.
- Central machine X 11..18, Z -2..3, maximum height 2 m for the first greybox. Its collider does not intrude into routes.
- Cabin floor X 2..9, Z -9..-5, Y=3. Archive console at (5,3,-7). Non-opaque frontage towards entrance.
- Broken direct stairs X 2..4, Z -3..3: Y=0 at south to Y=3 at north. Upper landing X 2..4, Z -4..-3. Missing span Z -5..-4. A physical barrier prevents crossing; this is not a jump challenge. Inspection position (4,0,3).
- Pit opening X 20..28, Z 1..8; floor Y=-2. Guardrails except at the stair mouth.
- Fixed pit stairs X 24..26, Z 8..11: (25,0,11) to (25,-2,8). Service apron X 20..28, Z 8..12 at Y=0, except the stair opening. Pit exit never depends on maintenance power.
- Pit inspection points: schematic (27,-2,6), bridge (22,-2,4), maintenance switch (26,-2,2). Each has a clear 2x2 m observation area. Return by fixed stairs.

## Continuous pit approach: 2 m clear, outside the opening

- South route rectangle X 7..19.5, Z 5..7 at Y=0, connected to the entrance by the main floor.
- West pit corridor X 17.5..19.5, Z 5..10 at Y=0: 2 m clear width, entirely west of the pit X=20 edge, with 0.5 m setback.
- Solid floor infill X 19.5..20, Z 1..8 at Y=0, top flush with the main floor and corridor; continuous load-bearing collider, no slot or trench. X 19.5..19.8 is additional floor outside the guaranteed 2 m corridor. X 19.8..20 supports the west guardrail. This infill stops at X=20 and never covers the pit opening. It joins the corridor over Z 5..8; no rail or seam at X=19.5.
- Apron connector X 17.5..22, Z 8..10 at Y=0: overlaps the west corridor over X 17.5..19.5 and service apron over X 20..22. It crosses X=20 only south of the pit boundary Z=8.
- Joins are flush and uninterrupted. Guardrail posts, collision and wall thickness cannot enter clear rectangles. West pit guardrail occupies X 19.8..20, Z 1..8; south edge protection occupies Z 7.8..8 except the stair mouth X 24..26.
- Walking centreline: entrance -> (8,0,6) -> (18.5,0,6) -> (18.5,0,9) -> (21,0,9) -> (23,0,9) -> (23,0,11.5) -> (25,0,11.5) -> stair top (25,0,11) -> stair foot (25,-2,8).

## Platform elevator and public upper route

The final slice uses one powered platform in the existing lift shaft. Do not build a second platform in the east annex and do not build the provisional ramp.

- East ground route X 28..30 connects the service apron around the pit.
- Lower landing X 24..28, Z -1..1, Y=0. Fixed connector X 24.5..27.5, Z -1.5..-1, Y=0 joins the platform's south edge.
- Platform footprint X 24.5..27.5, Z -4.5..-1.5; 3x3 m surface, travel Y=0..3. Lower and upper stops are Y=0 and Y=3. No other route through this shaft.
- Upper landing X 24..28, Z -7..-4.5, Y=3 adjoins the platform's north edge. Guard or gate the shaft when the platform is not at the stop.
- Public walkway X 9..26, Z -8..-6, Y=3; 2 m clear width plus rails outside. It joins the cabin through the east entrance.
- The platform begins at the lower stop with maintenance off; it only runs with maintenance enabled. See the functional spec for timing and loss-of-power behavior. The fixed stairs always work.
- Fixed shaft safety gates: lower gate centre `(26,0.55,-1.1)`, upper gate centre `(26,3.55,-4.9)`. These are stationary landing gates, distinct from the gates on the moving deck. Open only the gate at the docked landing; both fixed gates remain closed throughout motion. Place them so they do not collide visually or physically with the deck gates and verify walking clearance in scene.
- There is no ramp, no X=30..34 transport annex and no B-route acceptance test. Keep the main volume X 30..34 free of new transport geometry.

## Controls and status fixtures

- Isolator interaction centre (19,3,-7), selector interaction centre (12,3,-7). Do not move these contractual positions. Their housings must be slim/inset so they do not block the two-metre passage or require leaning over a void.
- Observation point (15,3,-7); this is not the physical position of the status display.
- Status panel on the north edge of the walkway, centre (15.5,4.55,-8.15), face toward +Z (south). Display destination, trial connection, protection state and last-trip presence. Text/symbol redundancy; no colour-only encoding.
- Rearm interaction (15.5,3.5,-8.15), on the same north-side support, visibly and interactively separate from the panel and both circuit controls. Reach from the passage without narrowing the clear rectangle Z=-8..-6. Support/collider remains north of the clear passage.
- Local archive supply indicator (8.55,3.8,-7), inside the east entrance, facing +X towards the public walkway. Exact states: SUMINISTRO ESTABLE / NO DISPONIBLE. It must not state which control to operate.
- Complete diagnostic terminal remains inside cabin; physically inspectable regardless of recovery-power state.

## Shortcut vestibule and exterior exit

The former shortcut doorway at the west cabin partition remains, but the west vestibule now also contains the distinct outer hatch to H.

- Cabin west partition: plane X=2 across Z -9..-5, Y=3..5.4 except the inner door.
- Inner door: plane X=2, clear opening Z -8.5..-6.5, Y=3..5.2; centre at (2,3,-7.5). Initially closed; unlock interaction from the cabin side only. Once unlocked, remains open and bidirectional.
- West vestibule floor: X 0..2, Z -9..-6, Y=3. It does not overlap the public walkway.
- Outer hatch in west wall X=0: clear opening Z -8.25..-6.75, Y=3..5.2; it opens from vestibule to H at the same walking elevation. The threshold triggers the transition, it is not a platform or jump.
- Retain vestibule east/north partition and ceiling, underside Y=5.4. The stair opening remains along the south edge Z=-6, clear X=0..2, descending to Y=0. Rails and walls may not narrow the vestibule floor.
- Fixed shortcut stairs X=0..2, Z=-6..0, descending from Y=3 to Y=0. Lower landing X=0..2, Z=0..2, Y=0, joins the main floor at (1,0,1). The stairs are a secondary return route, not the required transition to H.
- Normal east cabin entrance remains plane X=9, clear opening Z=-8..-6, Y=3..5.2 centred at (9,3,-7), with a lintel above.

## Lighting, clues and recovery

- The service switch at (26,-2,2) controls maintenance lights and platform. Maintain minimal ambient light on the fixed stairs and path so shutdown does not hide the safe exit.
- The schematic shows intended distribution; physical bridge labels show the A→T discrepancy. Scanner traces continuity but does not label the correct action.
- Falls and circuit trips do not erase session knowledge. No save-format change is authorized.
- Safe points: entrance, pit stair top, platform landings after arrival. The platform must always permit exit to a reachable landing.

## Construction and acceptance gate

Initial implementation is present but unverified. Run `docs/design/FASE1_CANONICAL_BUILD.md` before treating any geometry or interaction as accepted.

Build in this order: main floors and barriers; pit/stairs; platform shaft/landing gates; upper walkway and cabin openings; controls and status fixtures; G vestibule and outer hatch. Use plain materials and debug labels before art.

Acceptance requires a Godot run with evidence for: physical route continuity; 2 m clear route; fixed stair traversal with service lights off; platform travel and safe power loss; no shortcut bypass through the broken stairs; control reachability/collision; status/rearm readability from the real camera; archive consultation condition; west outer hatch transition. Record engine version, commit, resolution, renderer, input device, exact commands, failures and observations. The drawing itself is not validation.
