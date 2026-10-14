# Phase 1 — Independent greybox specification

Status: proposed layout for review, not built or validated. No authorization to construct the scene or complete mission. Logic lives in FASE1_LOGIC_CONTRACT.md. This supersedes the older flat layout only for the new prototype. Existing resource paths remain unchanged.

## Coordinates

Metres; Y up, X west-east, positive Z south. Main interior X 0..30, Z -10..10, walking surface Y=0. Named annexes extend the envelope as specified below. Coordinates describe walking surfaces, not collider centres. Third-person orbital camera; not the earlier overhead camera. No final art.

## Plan and section

```text
NORTH Z=-10
 [cabin/archive]---[controls]---[upper landing]---[temporary annex]
      | shortcut                    | lift
 [broken approach]   [machine]      |
 [entrance]---[south route]---[pit stairs]
SOUTH Z=+10 (pit-stair annex extends to +12)

Y=+3: cabin -- controls -- walkway -- upper landing
Y= 0: entrance -- route -- lower lift landing
Y=-2: pit -- schematic -- bridge -- maintenance
```

The diagram is illustrative; footprints below define the layout.

## Main volumes and routes

- Entrance (3,0,7), initially facing cabin (6,3,-7). Keep the destination visible, not the entire solution.
- Central machine X 11..18, Z -2..3, maximum height 2 m for the first greybox. Its collider does not intrude into routes.
- Cabin floor X 2..9, Z -9..-5, Y=3. Archive at (5,3,-7); east access at (9,3,-7). Non-opaque frontage towards entrance.
- Broken direct stairs X 2..4, Z -3..3: Y=0 at south to Y=3 at north. Upper landing X 2..4, Z -4..-3. Missing span Z -5..-4. A physical barrier prevents attempted crossing; this is not a jump challenge. Inspection position (4,0,3).
- Initial south route: entrance -> (8,0,6) -> (20,0,6), minimum 2 m clear width south of machine.
- Pit opening X 20..28, Z 1..8; floor Y=-2. Guardrails except stair mouth.
- Fixed pit stairs X 24..26, Z 8..11: (25,0,11) to (25,-2,8). Service apron X 20..28, Z 8..12 at Y=0, except stair opening; connect through (20,0,9). Exit never depends on maintenance power.
- Pit inspection points: schematic (27,-2,6), tampered bridge (22,-2,4), maintenance switch (26,-2,2). Each has a clear 2x2 m observation area. Return by fixed stairs.
- East route X 28..30 connects service apron to lower landing by rounding the pit, not crossing it.
- Lower lift landing X 24..28, Z -1..1, Y=0. Fixed connector X 24.5..27.5, Z -1.5..-1, Y=0 joins the lift south edge without a gap.
- Service lift: 3x3 m surface centred X=26,Z=-3, moves vertically Y=0..3; footprint X 24.5..27.5, Z -4.5..-1.5.
- Upper landing X 24..28, Z -7..-4.5, Y=3, directly adjoins lift north edge. Protect open shaft access when lift absent.
- Upper walkway X 9..26, Z -8..-6, Y=3, joins cabin and upper landing. Clear walking width 2 m plus rail thickness.
- Isolator at (19,3,-7), selector (12,3,-7). Indicators intended to be readable from (15,3,-7); verify in the actual camera. Controls must not require leaning over a void.

## Explicit shortcut connection

The shortcut door is at (9,3,-8). Define a fixed upper vestibule X 9..11, Z -9..-6, Y=3; its west edge joins cabin X=9, its south edge joins stair top Z=-6. Give the doorway a clear opening centred Z=-8; place barriers so the public walkway cannot bypass the locked shortcut through the vestibule's east or south sides.

Fixed shortcut stairs occupy X 9..11, Z -6..0, descending from Y=3 at Z=-6 to Y=0 at Z=0. A lower landing X 9..11, Z 0..2, Y=0 leads to (10,0,1), west of the central machine.

Continuous shortcut route: cabin -> door (9,3,-8) -> vestibule (10,3,-8) -> stair top (10,3,-6) -> stair foot (10,0,0) -> lower landing (10,0,1). The door can be unlocked only from the cabin side, remains open afterwards, and blocks initial ascent from below. The complete fixed route is independent of power.

## Explicit provisional ramp route

This is a test substitute, never evidence that lift transport works. Mark it PROVISIONAL throughout.

- Ground connector X 28..31, Z 8..10, Y=0, extends the east ground route through boundary X=30 into the annex.
- Lower ramp landing X 31..33, Z 8..10, Y=0; centre (32,0,9).
- Ramp X 31..33, Z -6..8, rising linearly from Y=0 at Z=8 to Y=3 at Z=-6. Surface Y=3*(8-Z)/14; continuous endpoints.
- Upper ramp landing X 31..33, Z -8..-6, Y=3; centre (32,3,-7).
- Return bridge X 28..31, Z -8..-6, Y=3 joins the landing at X=31 to upper-landing extension at X=28.
- Upper-landing extension X 26..28, Z -8..-6, Y=3 overlaps upper landing over Z -7..-6 and public walkway along X=26.

Full walking route: east route (29,0,9) -> connector (30,0,9) -> lower landing (32,0,9) -> ramp foot (32,0,8) -> ramp top (32,3,-6) -> upper landing (32,3,-7) -> bridge (29,3,-7) -> extension (27,3,-7) -> main landing (26,3,-6.5).

Reserve annex X 30..34, Z -8..10 with boundary openings at the ground connector and upper return bridge. Their footprints are continuous at identical heights, with no jump required. Guardrails must not close these joins. The provisional route is disabled or removed for the independent lift test and must not be used to claim mission duration.

## Clues, camera and recovery

At entrance: identify cabin and broken approach, not the solution. Pit schematic and bridge need close inspection; labelled physical wiring relates bridge to nodes A and T. Upper indicators contrast requested archive destination with recorded trial demand. Scanner reveals hidden continuity, not a control instruction. Diagnostics at the cabin terminal are available regardless of recovery supply. Never rely on colour alone.

Safe points proposed: entrance, top of pit stairs, upper lift landing after arrival. Falls do not erase discovered clues or logical state. Pit exit is fixed. Lift can be called from both ends. Shortcut helps revisits without opening the upper route initially. Save representation and compatibility require separate tests; this is not authorization to alter schemas.

## Independent lift gate

Before integration, test full passenger transport without slipping, camera readability, boarding/disembarking without jumps, calls from both ends, leaving the platform, falling and safe recovery, and power loss without trapping Elena. Mechanical behavior on power loss must be specified in that test before lift implementation. The provisional ramp permits spatial evaluation while this remains pending.

## Playable spatial review

Route: entrance -> broken approach -> south route -> pit and fixed return -> lower landing -> upper landing (via separately validated lift or explicitly provisional ramp) -> controls -> cabin -> shortcut. No enemy, final extraction or containment.

Record Godot version, commit, resolution, renderer and input device. Observe destination recognition without verbal direction; understanding of blocked approach without a failed jump; reliable pit exit; clue readability; camera visibility of landings/controls; shortcut discovery and usefulness. Log confusion, falls, camera corrections, hints and defects. Reachability alone does not approve space.

Use players unfamiliar with the design. Distinguish drawing inspection, scene execution and hands-on validation. Footprint continuity does not prove clearance, comfort or deduction. If dimensions fail in the actual camera/collision setup, explicitly revise the drawing before expanding content. No such execution or manual evidence is claimed here.

## Outside authorization

Final narrative, Aster chronology, scanner origin, protected extraction, containment, pursuit, final art, removal of earlier scenes and campaign rewrite. Both documents require review before scene construction.
