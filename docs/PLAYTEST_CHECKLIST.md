# Flooded Shelter 2.5D — Playtest Checklist

## Build under test

- Branch: `feat/godot-vertical-slice`
- Canonical scene: `scenes/levels/flooded_shelter_2_5d.tscn`
- Latest repair commits: `6b43013`, `6c0daf7`, `50b80f4`

## Required result

Do not mark TD-011 closed until every item below has a recorded pass/fail result.

## 1. Scene load

| Check | Expected result | Result |
|---|---|---|
| Open project in Godot | No script parse errors |  |
| Load `flooded_shelter_2_5d.tscn` | No missing node or resource errors |  |
| Run scene | No runtime errors in Output |  |
| Inspect `ShelterController` | Elena, civilian, console, valves and gate references are set |  |
| Inspect `FloodedShelterController` | It is in group `flooded_shelter` |  |

## 2. Movement and collision

| Check | Expected result | Result |
|---|---|---|
| Move left/right | Elena moves and sprite flips |  |
| Jump | Elena jumps only while grounded |  |
| Reach floor | Elena lands and remains on floor |  |
| Reach left wall | Elena stops at wall |  |
| Reach right wall | Elena stops at wall |  |
| Wait for oxygen drain | Oxygen HUD decreases |  |

## 3. Interaction chain

| Check | Expected result | Result |
|---|---|---|
| Approach generator | Interaction area detects `PowerConsole` |  |
| Press interact | Generator activates once |  |
| Observe HUD | Objective changes after power |  |
| Approach left valve | Interaction area detects valve |  |
| Open left valve | Controller counts one valve |  |
| Approach right valve | Interaction area detects valve |  |
| Open right valve | Gate opens |  |
| Approach civilian | Interaction area detects civilian |  |
| Press interact | Civilian is rescued |  |
| Observe HUD | Civilian state changes |  |

## 4. Completion and failure

| Check | Expected result | Result |
|---|---|---|
| Enter win zone after gate opens | Level completes successfully |  |
| Observe `DemoEnd` | End screen appears |  |
| Let oxygen reach zero | Level completes as failure |  |
| Observe `DemoEnd` | Failure end screen appears |  |
| Restart after completion | Scene reloads without stale completion state |  |

## 5. Persistence

| Check | Expected result | Result |
|---|---|---|
| Activate generator and reload scene | Controller restores power state |  |
| Open both valves and reload scene | Controller restores valve completion and opens gate |  |
| Rescue civilian and reload scene | Controller restores rescue state |  |
| Inspect props after reload | Console/valve visual state matches restored controller state |  |

## 6. Localization

| Check | Expected result | Result |
|---|---|---|
| Switch to Spanish | HUD, prompts and civilian text are Spanish |  |
| Switch to English | HUD, prompts and civilian text are English |  |
| Complete demo in Spanish | Completion text is Spanish |  |
| Complete demo in English | Completion text is English |  |
| Fail demo in Spanish | Failure text is Spanish |  |
| Fail demo in English | Failure text is English |  |

## Known expected gaps

These are not pass/fail blockers for TD-011, but they are known debt:

- Generator and valve prompts may still be hardcoded in Spanish.
- Props may not restore their visual state after persistence.
- There is no animation, VFX or audio feedback yet.
- AccessibilityManager and SoundCueHUD are not yet integrated into the canonical scene.
- The narrative dismissal grace period is not yet ported.

## Evidence format

For each section, record:

- PASS or FAIL.
- Godot version.
- Date and time.
- Errors or warnings observed.
- Screenshots or short notes where useful.

A FAIL must include the exact reproduction steps and the relevant console output.
