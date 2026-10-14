# Mission 1 — The Ghost Protocol

**Status:** design for implementation. Not built, not playtested, not final.

## Goal

Elena enters a Helix test bay to find out what happened to an Aster test. The power is off, the exit is locked, and someone has altered the circuit to hide the result.

The player must understand **which circuit was manipulated, where it was diverted, and how to restore it**. The puzzle is solved by combining physical evidence, not by following HUD instructions.

## Player fantasy

Elena reads infrastructure as evidence. The room should feel like a place where something was covered up: a test that did not go as Helix expected, a result that was diverted, and a system left deliberately incomplete.

## Room layout

One compact bay, about 24 x 14 m, readable from the third-person camera.

| Zone | What is there | Purpose |
|---|---|---|
| Entrance | Broken lights, an evacuation sign, a locked exit door | Establish goal: restore power and leave |
| Panel wall | Three circuit panels: A, B, C | Show the intended configuration |
| Cable floor | Loose cables, a cut cable end, scorch marks | Reveal that circuit B was altered |
| Registration terminal | A terminal connected to a diverted cable | Hold the hidden test record |
| Generator alcove | The lever that restores power | The final action, hidden behind a wall that fades for the camera |
| Exit | A pressure door tied to circuit B | The reward for solving the puzzle |

## The deduction

The intended configuration is written on the panel wall:

- Circuit A feeds the lights.
- Circuit B feeds the exit door.
- Circuit C feeds the test-record terminal.

But the room shows that circuit B was cut and diverted into the terminal. The terminal contains a partial record: the Aster test was rerouted, and its result was withheld.

The player must:

1. Scan the panel wall to learn the intended configuration.
2. Scan the cut cable to see that B was diverted into the terminal.
3. Read the terminal record, which confirms the diversion and mentions the withheld Aster result.
4. Reconnect B at the junction.
5. Restore power at the generator lever.

The correct action is **reconnect B, then restore power**. Restoring power before reconnecting B gives a partial result: lights come on, but the door stays locked and the terminal reports an inconsistent circuit.

## Scanner rules

The scanner reveals relationships and traces. It never marks the solution.

| Scan target | What it shows | What it does not show |
|---|---|---|
| Panel wall | Which circuit feeds which system | What to do next |
| Cut cable | A highlighted path from B to the terminal | That B must be reconnected |
| Terminal | That it is receiving power from B | The correct final action |
| Generator lever | That it is live but the circuit is inconsistent | The answer |

Scan reveals last 3 seconds and recharge for 4 seconds. The player chooses when to stop and scan.

## Feedback

- Connecting the wrong cable: sparks, a local reset, and a diegetic error message.
- Restoring power with B still diverted: lights come on, but the door stays locked and the terminal reports an inconsistent circuit.
- Restoring power after reconnecting B: the door unlocks, the terminal completes the record, and the containment system wakes up.
- Every error has a visible and audible cause. No abstract penalty.

## Narrative reveal

When the circuit is restored, the terminal completes the record:

> Aster test rerouted. Result withheld. Deployment recommendation suppressed.

This is the evidence Elena came for. It also explains why the facility reacts: restoring the system exposes the manipulation, and Helix containment identifies her as an intruder.

The mission ends with the exit opening and the containment alarm starting. This is the causal bridge into Mission 2.

## HUD rules

The HUD may say:

- "Restaura la energía."
- "La compuerta sigue bloqueada."
- "El circuito es inconsistente."

The HUD must not say:

- "Reconecta el cable B."
- "La solución es B."
- "Ve al terminal."

The scanner, the room and the player's reasoning carry the solution.

## Failure and recovery

- Wrong cable: local reset, no progress lost.
- Power restored too early: no progress lost, the player keeps investigating.
- Falling or getting stuck: return to the last checkpoint.
- No enemies in this mission. The threat is discovery, not combat.

## What this needs from Blender

- Elena: idle, walk, run, crouch, scan, interact, alert.
- Room: panel wall, cables, cut cable end, terminal, generator lever, exit door, signage.
- Scanner: cable trace highlight, panel configuration highlight, terminal record highlight.
- Audio: room tone, scan pulse, cable spark, terminal beep, power up, door unlock, containment alarm.

## Acceptance criteria

- A new player can solve it by observing and reasoning, without the HUD giving the answer.
- The solution requires combining at least two pieces of evidence.
- Every action gives immediate, understandable feedback.
- The scanner is useful but optional for a player who explores carefully.
- Solving the puzzle changes the room physically and triggers the escape.
- The sequence takes about 4 to 6 minutes for a first-time player.
- No combat, no inventory, no arbitrary symbols, no trial-and-error states.
