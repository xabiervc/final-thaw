# Motion and chase prototype — hito A

**Status:** prototype for owner validation. Not integrated into the campaign, not art-final, not run in Godot from this session.

## Purpose

Validate the new play direction before rebuilding the campaign: third-person movement, physical obstacles, a scanner used under pressure, and a recovery unit that hunts rather than shoots.

## What it contains

- Third-person Elena: WASD relative to the camera, Shift to run, Ctrl to crouch, Space to jump, E to climb, Q to scan.
- A jump gap, a low service tunnel, one defined climb point, pillars for evasion and an exit marker.
- A recovery unit with patrol, detection cone, chase, search and return states. It catches Elena on contact; Elena returns to the last checkpoint and the unit resets.
- A scanner: hold Q for 0.9 s to reveal the unit's patrol route for 3 s, with a 4 s cooldown.
- Minimal greybox visuals only. The art team owns the final look.

## What it deliberately excludes

No weapons, combat, inventory, free climbing, navigation mesh or campaign integration. The point is to test whether movement and pursuit feel good.

## How to run

```bash
godot --path . res://scenes/prototypes/motion_chase_prototype.tscn
godot --headless --path . res://tests/test_motion_chase_prototype.tscn
```

Click once to capture the mouse. Escape returns to the main menu through the existing pause action.

## Validation questions

1. Does walking, running, jumping and crouching feel responsive?
2. Is the camera readable during movement and pursuit?
3. Does the recovery unit create decisions instead of simply following Elena?
4. Does the scanner create a meaningful choice about when to stop?
5. Is it clear why Elena is caught or escapes?

## Known limits

- The unit steers directly towards its target; it does not use a navigation mesh, so complex geometry could trap it.
- The climb is a defined point, not free climbing.
- The scanner reveals a fixed patrol route, not a dynamic prediction.
- No sound, animation or final art.
- Not measured on the Web target or on the reference GPU.
