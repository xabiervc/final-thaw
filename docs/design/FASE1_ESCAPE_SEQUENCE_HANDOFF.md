# FINAL THAW — Escape sequence handoff for Opus

**Purpose:** provide one implementation contract for reviewing the reference map and implementing Elena's escape. This document supplements the existing Phase 1 architecture/greybox documents; it does not replace Phase 0 contracts or claim runtime validation.

## Authority and reference handling

1. Treat the owner's fully annotated, full-resolution PNG map as the primary visual authority for route placement and event markers. Keep it intact and inspect it at full resolution; cropped close-ups are details, not complete plans.
2. Treat the SVG reconstruction, route JSON, and dimensional calculations as editable supporting proposals only. They are not an exact architectural survey and must not silently override the PNG.
3. Before editing scenes, inspect all relevant existing documents and repository assets. Update the canonical existing documents where appropriate; do not create duplicate specs or delete user-owned files.
4. If the full annotated PNG is not present in the checkout, stop and report that missing input rather than substituting a crop, a generated map, or a different earlier image.
5. Keep this work on `feat/escape-conduit-labyrinth` and the existing PR. Do not merge it or alter `main`. Preserve Phase 0 input actions, autoloads, save compatibility, resource paths, Aster and the canonical mission until integration is explicitly validated.

## Route contract

- There is exactly one traversable escape route: entrance S, N1, west/left through Sector B, then the marked service galleries, Sector D, dry conduit A2, exit A3, secondary road, and forest concealment.
- The north/up corridor from N1 is NOT an escape route. Do not colour it as part of the route, connect it as a shortcut, or let Elena navigate through it.
- Orange in the owner's annotated plan identifies the single escape route. Red dashed paths indicate blocked routes, dead ends, or non-escape areas; they must not become alternate exits.
- The player must never cross walls, restricted rooms, or dead ends to complete the escape.
- The route length target is approximately 220–260 m from N1 to A3 and 2–4 minutes of playable time. Treat these as targets to measure in Godot, not verified facts.
- A2 rises from approximately −2 m to +8 m. At +10 degrees, the compatible ramp length is about 57.6 m along the slope (about 56.7 m horizontal). Do not label this as 80 m unless the elevation or slope is deliberately revised and documented.

## Narrative and actor contract

### Initial encounter at N1
Elena enters from S and meets three installation workers face-on at N1. They block the direct path. The alarm is still OFF. Elena must turn left/west. These three are workers, not security guards.

### Interaction 1 — shelf (blue X)
Show a contextual Interact prompt. Elena topples the shelf. Worker T1 trips and falls; T2 and T3 jump over it and continue the chase. The shelf falling does NOT trigger the alarm, directly or via a sensor. Use a short, readable camera insert to show the fall and reactions, then return to first-person at the same physical position and orientation.

Off-screen causality: T1 gets up, physically travels to the alarm button P, and presses it. Only that human action activates the alarm. Do not substitute a timer-only alarm trigger. Elena must be able to continue moving while T1 recovers and moves to P.

### Alarm and interaction 2 — cabinet (purple X)
The alarm begins after T1 presses P, during Elena's run. It alerts security, but the guards must have a credible response time and must not spawn instantaneously in front of the camera.

At the purple X, show Interact. Elena topples a cabinet into the corridor, physically blocking T2 and T3 with no lateral bypass. Use a brief camera pull-back to show the blockage, then return to first-person without teleporting Elena or changing her direction.

### Interaction 3 — extinguisher (green X)
Two distinct security guards G1 and G2 arrive because the alarm was activated. They block Elena's path. Show the prompt to pick up/use the extinguisher. Elena discharges it to create a cloud that temporarily blinds both guards, then strikes them while they cannot see. Show the result briefly, then return to first-person. The guards are disabled as pursuers; Elena continues with substantially less immediate pressure.

Do not confuse T1/T2/T3 with G1/G2. There are five distinct NPCs across the sequence.

### Final escape
Elena continues through the service route and Sector D, enters A2, climbs to A3, emerges beside the secondary road, and hides in the forest. There is no alternate exit and no return through the lab or the N1 upper corridor.

## Camera contract

- First-person is the continuous gameplay view.
- Use three short, motivated inserts: shelf/fall, cabinet blockage, extinguisher outcome.
- Each insert must communicate cause and effect, preserve player orientation, return to the same physical location, and restore control safely.
- Avoid long cutscenes. No visible teleport, forced accidental turn, or state that relies on a single exact frame.

## Suggested state/event model

`INITIAL_ENCOUNTER` → `SHELF_INTERACTION` → parallel `WORKER_RECOVERY` → `ALARM_ACTIVE` only when T1 presses P → `CABINET_INTERACTION` → `SECURITY_ARRIVAL` → `EXTINGUISHER_INTERACTION` → `SECURITY_DISABLED` → `ESCAPE_RUN` → `ESCAPE_COMPLETE`.

Model Elena's route progression separately from T1 recovery and security response. Handle interaction cancellation, leaving a trigger, interrupted animations, blocked navigation, fast/slow player timing, and NPC stuck recovery without softlocks or false events. T1 cannot activate the alarm unless he actually reaches and presses P.

## Implementation and review sequence

1. Inventory the current branch and compare the full annotated PNG with every existing SVG/spec/graph. Report conflicts before changing geometry.
2. Confirm the route topology and physical connectivity from walls, doors, corridor widths, and elevation transitions. Do not infer missing architecture from empty pixels.
3. Implement the interactions as gameplay systems, not merely illustrations. Preserve the existing mission until the prototype has passed review.
4. Run Godot 4.7.2 headless tests and an interactive playthrough. Validate collisions, NPC navigation, alarm causality/timing, camera return points, route completion, A2 slope, and the forest trigger.
5. Report exact commands and results. If Godot is unavailable, say so and leave runtime acceptance pending. Do not claim tests, audio, animations, or manual QA were verified without evidence.

## Acceptance checklist

- [ ] Full annotated PNG is available in the repository and is the primary visual reference.
- [ ] Single route S/N1 → west through B → service galleries/D → A2 → A3 → road/forest.
- [ ] N1 upper corridor is never part of the escape route.
- [ ] Three workers appear before the alarm; no guards are present at initial encounter.
- [ ] Shelf makes T1 fall; T2/T3 jump and continue; no automatic alarm.
- [ ] T1 gets up, reaches P, and physically presses it off-screen; alarm follows.
- [ ] Cabinet blocks T2/T3 without a bypass.
- [ ] G1/G2 arrive after the alarm with credible travel time.
- [ ] Extinguisher blinds both guards before the strikes; guards stop pursuing.
- [ ] Three short camera inserts return to first-person at the same physical position/orientation.
- [ ] No wall clipping, alternate escape path, dead-end completion, or softlock.
- [ ] Route length/time and all collisions are measured/tested in Godot.
- [ ] Phase 0, save, input/autoload, resource-path and canonical mission contracts remain intact.

**Status:** design handoff only. No claim of Godot runtime validation or manual playtesting is made by this document.
