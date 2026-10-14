# Phase 1 — Independent greybox specification

Status: proposed layout for review, not built or validated. This revision closes the pit approach and separates the shortcut from the public walkway; it does not claim approval of the experience. Logic lives in FASE1_LOGIC_CONTRACT.md and is ready for implementation tests following static review. No complete mission, protected extraction or containment authorization. Existing resource paths remain unchanged.

## Coordinates

Metres; Y up, X west-east, positive Z south. Main interior X 0..30, Z -10..10, walking surface Y=0. Named annexes extend the envelope below. Coordinates describe walking surfaces, not collider centres. Corridor and doorway dimensions are clear widths: railing and wall thickness must be placed outside those widths. Third-person orbital camera, not the earlier overhead camera. No final art.

## Plan and section

```text
NORTH Z=-10
 [shortcut][cabin/archive]---[controls]---[upper landing]---[temporary annex]
     |                                         | lift
 [stairs] [broken approach] [machine]           |
 [entrance]---[south route]--[west pit corridor] |
                                |    [pit]     |
                                `---[pit-stair apron]
SOUTH Z=+10 (pit-stair annex extends to +12)

Y=+3: shortcut vestibule -- cabin -- public walkway -- upper landing
Y= 0: entrance -- south route -- west pit corridor -- service apron
Y=-2: pit -- schematic -- bridge -- maintenance
```

The diagram is illustrative; footprints below define the layout.

## Main volumes

- Entrance (3,0,7), initially facing cabin (6,3,-7). Keep destination visible, not the entire solution.
- Central machine X 11..18, Z -2..3, maximum height 2 m for the first greybox. Its collider does not intrude into routes.
- Cabin floor X 2..9, Z -9..-5, Y=3. Archive at (5,3,-7). Normal public entrance remains on its east side, distinct from the shortcut west door below. Non-opaque frontage towards entrance.
- Broken direct stairs X 2..4, Z -3..3: Y=0 at south to Y=3 at north. Upper landing X 2..4, Z -4..-3. Missing span Z -5..-4. Physical barrier prevents crossing; not a jump challenge. Inspection position (4,0,3).
- Pit opening X 20..28, Z 1..8; floor Y=-2. Guardrails except stair mouth.
- Fixed pit stairs X 24..26, Z 8..11: (25,0,11) to (25,-2,8). Service apron X 20..28, Z 8..12 at Y=0, except stair opening. Pit exit never depends on maintenance power.
- Pit inspection points: schematic (27,-2,6), bridge (22,-2,4), maintenance switch (26,-2,2). Each has a clear 2x2 m observation area. Return by fixed stairs.

## Continuous pit approach: 2 m clear, outside the opening

Replace the old endpoint (20,0,6) and boundary-following route through (20,0,9) with these explicit surfaces:

- South route rectangle X 7..19.5, Z 5..7 at Y=0, connected to the entrance by existing main floor.
- West pit corridor X 17.5..19.5, Z 5..10 at Y=0: 2 m clear width, entirely west of the pit X=20 edge, with 0.5 m setback.
- Solid floor infill X 19.5..20, Z 1..8 at Y=0, top flush with the main floor and corridor; continuous load-bearing collider, no slot or trench. The X 19.5..19.8 strip is additional floor outside the guaranteed 2 m corridor. The X 19.8..20 strip supports the west guardrail. This floor stops at X=20 and never covers the pit opening. It joins the corridor over Z 5..8; no rail or seam is placed at X=19.5.
- Apron connector X 17.5..22, Z 8..10 at Y=0: overlaps west corridor over X 17.5..19.5 and service apron over X 20..22. It crosses X=20 only south of the pit boundary Z=8.
- Surface joins are flush and uninterrupted. Guardrail posts, collision and wall thickness cannot enter these clear rectangles. Guardrails protecting the pit west edge occupy X 19.8..20, Z 1..8; south edge protection occupies Z 7.8..8 except the stair mouth X 24..26.

Walking centreline: entrance -> (8,0,6) -> (18.5,0,6) -> (18.5,0,9) -> (21,0,9) -> (23,0,9) -> (23,0,11.5) -> (25,0,11.5) -> stair top (25,0,11) -> pit stair foot (25,-2,8). This avoids walking into the sloped stair opening from its side. Centreline points are explanatory; the rectangles define usable width.

## Lift and public upper route

- East ground route X 28..30 connects service apron to lower landing around the pit.
- Lower landing X 24..28, Z -1..1, Y=0. Fixed connector X 24.5..27.5, Z -1.5..-1, Y=0 joins lift south edge.
- Lift footprint X 24.5..27.5, Z -4.5..-1.5; 3x3 m surface centred X=26,Z=-3, travelling Y=0..3.
- Upper landing X 24..28, Z -7..-4.5, Y=3 adjoins lift north edge. Protect shaft access when lift absent.
- Public walkway X 9..26, Z -8..-6, Y=3; 2 m clear width plus rails outside. Joins cabin through its east entrance.
- Isolator (19,3,-7), selector (12,3,-7); indicators intended readable from (15,3,-7). Verify with actual camera. Controls must not require leaning over a void.

## Shortcut: separate west vestibule and explicit openings

The former shortcut door (9,3,-8), vestibule X 9..11 and stairs X 9..11 are superseded. Public walkway geometry is unchanged.

- West shortcut vestibule: clear floor X 0..2, Z -9..-6, Y=3. It does not overlap public walkway X 9..26.
- Cabin west partition: plane X=2 over Z -9..-5, from Y=3 to Y=5.4; thickness 0.15 m into the cabin side, except shortcut opening below.
- Shortcut door: plane X=2, clear opening Z -8.5..-6.5, Y 3..5.2; centre at walking level (2,3,-7.5). Closed collider fills the opening. Unlock interaction only from cabin side X>2; once unlocked it remains open and bidirectional.
- Vestibule west wall: outer face of clear rectangle X=0, Z -9..-6; north wall Z=-9, X 0..2. Wall thickness outside clear floor; height Y 3..5.4.
- Vestibule south edge Z=-6 is open across clear X 0..2 into shortcut stair top. No public walkway reaches this opening.
- Fixed stairs: clear X 0..2, Z -6..0, descending Y=3 at Z=-6 to Y=0 at Z=0. Lower landing X 0..2, Z 0..2, Y=0; joins main floor through (1,0,1). Rails on both stair sides, without closing endpoints.
- Vestibule ceiling underside Y=5.4, footprint X 0..2, Z -9..-6. With the full-height cabin partition, prevents jumping over the locked shortcut boundary. Stair side rail/wall on X=2 separates these stairs from the broken direct stairs; thickness must not reduce either clear width.
- Normal cabin east entrance: plane X=9, clear opening Z -8..-6, Y 3..5.2, centred at (9,3,-7). Cabin east partition covers Z -9..-8 and -6..-5 up to Y=5.4, with lintel Y 5.2..5.4 across opening; thickness into cabin side.

Normal route: upper landing -> public walkway -> east entrance -> archive. Shortcut route after unlocking: cabin -> west door (2,3,-7.5) -> vestibule (1,3,-7.5) -> stair top (1,3,-6) -> foot (1,0,0) -> lower landing (1,0,1). Initial ascent reaches the closed west door and cannot bypass it. Both routes are independent of power.

## Provisional ramp route (unchanged)

Mark PROVISIONAL. Not evidence of working lift transport and not valid for mission duration.

- Ground connector X 28..31, Z 8..10, Y=0.
- Lower ramp landing X 31..33, Z 8..10, Y=0; centre (32,0,9).
- Ramp X 31..33, Z -6..8; Y=3*(8-Z)/14, rising from Y=0 at Z=8 to Y=3 at Z=-6.
- Upper ramp landing X 31..33, Z -8..-6, Y=3; centre (32,3,-7).
- Return bridge X 28..31, Z -8..-6, Y=3.
- Upper-landing extension X 26..28, Z -8..-6, Y=3, overlaps upper landing over Z -7..-6 and joins public walkway at X=26.

Continuous route: east ground (29,0,9) -> (30,0,9) -> lower landing (32,0,9) -> foot (32,0,8) -> top (32,3,-6) -> upper landing (32,3,-7) -> bridge (29,3,-7) -> extension (27,3,-7) -> main landing (26,3,-6.5). Reserve annex X 30..34, Z -8..10; openings through main boundary at ground connector and upper bridge. Rails do not close joins. Disable substitute during independent lift test.

## Clues, camera and recovery

Entrance: cabin and broken approach readable, not solution. Pit: close inspection of schematic/bridge with labelled wiring to A and T. Upper indicators contrast archive selection with recorded trial demand. Scanner shows continuity, not instructions. Cabin terminal diagnostics always accessible regardless of recovery supply. Do not rely on colour alone.

Safe points: entrance, pit stair top, upper landing after arrival. Falls preserve clues and logic. Pit exit fixed, lift callable at both ends. Shortcut useful only after ascent. Save compatibility requires separate tests, not schema rewrite authorization.

## Independent lift gate

Test transport without slipping, camera readability, boarding without jumps, calls from both ends, abandoning lift, falling/recovery and power loss without trapping Elena. Define mechanical power-loss behavior in that independent test before implementing the lift. Provisional ramp only enables spatial review.

## Playable review and authorization boundary

Route: entrance -> broken approach -> south route -> west pit corridor -> pit and return -> lower landing -> upper landing via validated lift or marked ramp -> controls -> cabin -> unlocked west shortcut.

Record Godot version, commit, resolution, renderer and input device. Observe destination recognition, readable obstruction, reliable pit exit, clue relations, camera clearance, and shortcut usefulness. Specifically test both doorway approaches and attempted shortcut bypass while locked. Log confusion, falls, camera corrections and hints. New players should explain the clue relations; reachability alone does not approve the experience.

Distinguish inspected drawing, executed scene and hands-on validation. This revision specifies continuity and partitions but claims no collision/camera/playtest evidence. Both geometry corrections remain subject to review before construction. No pursuit, final narrative, protected extraction, containment, Aster chronology, scanner origin, final art, legacy-scene removal or campaign rewrite.
