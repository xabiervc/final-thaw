# Motion and chase prototype — hitos A and B (v2)

**Status:** prototype for owner validation. Not integrated into the campaign, not art-final. The v1 test was run by the owner (passed); the v2 code and its test have **not** been run yet.

## Purpose

Validate the new play direction before rebuilding the campaign: third-person movement, physical obstacles, stealth, a scanner used under pressure, and a recovery unit that hunts rather than shoots.

## What changed from v1 (and why)

A review of v1 found real defects that the v1 test could not catch, because it only checked that objects existed:

- The first obstacle was impossible: a low ceiling covered a 4 m gap, so the player could neither jump (head hits the ceiling) nor cross crouched.
- The climb could never work: it passed the player to a function expecting the trigger area, and the trigger did not detect the player's physics layer.
- The unit's vision cone pointed behind it (its model faces +Z, the cone used −Z).
- Space was bound to both jump and run (through `dodge`), so every jump ran.
- The chase steered to Elena's real position for two seconds after losing her, which is the magical knowledge the design brief forbids.
- The documentation said Escape returned to the menu; the code did not do it.

v2 also adds: Elena's real model and procedural pose layer (primitive fallback), the synthesized footsteps, landing, scan and alert sounds from the art team, a camera that fades walls, ceilings and pillars that hide Elena, and the stealth and chase behaviour below.

## Level (about 80 m, left to right)

1. Open start with controls written in the world.
2. Hop gap of 1.8 m (walk jump).
3. Low vent tunnel: crouch with Ctrl.
4. Long gap of 3.0 m: run with Shift and jump.
5. Recovery unit zone: pillars for cover, a low duct along the north wall that the unit cannot enter, and a catwalk reached by a defined climb (E) that the unit cannot climb.
6. A final 1.8 m gap that the unit cannot cross, then the exit.

## Recovery unit

States: patrol, investigate, alert, chase, search, return. It sees within a 55° half-angle cone up to 9 m (5 m if Elena is crouched), with line of sight, and always senses her within 1.6 m. It also hears: running reaches 10 m, walking 6 m, crouching 2.5 m, standing still 1.5 m.

- Awareness fills faster when Elena is close and visible; at full it enters a brief alert (about 0.55 s, with a sound and an eye flash) before the chase, so the player can break line of sight.
- During the chase it goes to the last position it saw, not Elena's real one. On arrival it searches, sweeping its cone, then returns to its route.
- A heard noise sends it to investigate that spot at a walking pace.
- It steers around pillars and stops at ledges instead of falling.
- Its state is shown by eye colour and a symbol (`?`, `!`, `!!`), not by colour alone, and by an alert sound.
- Contact catches Elena: she returns to the last checkpoint and the unit resets.

## Scanner

Hold Q for 0.9 s. For 3 s it shows the unit through walls, its vision cone, its patrol points and labels on the three alternative routes, then recharges for 4 s.

## Camera

Mouse orbit (click once to capture the mouse). Walls, ceilings, pillars and the catwalk that block the line between the camera and Elena fade out and return when they no longer block it. Collision is unchanged.

## How to run

In the Godot editor, open `scenes/prototypes/motion_chase_prototype.tscn` and press F6; open `tests/test_motion_chase_prototype.tscn` and press F6 to run the checks. Command line equivalents:

```bash
godot --path . res://scenes/prototypes/motion_chase_prototype.tscn
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
```

Escape returns to the main menu. After reaching the exit, R restarts.

## What it deliberately excludes

No weapons, combat, inventory, free climbing, navigation mesh or campaign integration. Text in the prototype is hard-coded Spanish and is not yet in `NarrativeText`.

## Validation questions

1. Does walking, running, jumping, crouching and climbing feel responsive?
2. Is the camera readable, including inside the tunnel and under the catwalk?
3. Does the unit create decisions (hide in the duct, climb, outrun it, cross the last gap)?
4. Does the scanner create a meaningful choice about when to stop?
5. Is it always clear why Elena is caught or escapes?
6. How long does a first-time player take, and where do they get stuck?

## Known limits

- The unit steers with probes, not a navigation mesh; unusual geometry could still trap it.
- The climb is a defined point with a short animation, not free climbing.
- The pose layer has no crouch or climb pose; crouching squashes the model.
- Detection and noise numbers are starting values that need playtesting.
- Not measured on the Web target or the reference GPU.
