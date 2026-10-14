# Phase 1 — Long exploration route

> **ESTADO ACTUAL — REFERENCIA NO CANÓNICA.** Este documento describe un diseño/prototipo anterior y se conserva como histórico/comparativo. Para implementar el slice actual, seguir `FASE1_FUNCTIONAL_SPEC.md` v1.0, `FASE1_SPATIAL_GRAPH.md` v0.4, `FASE1_GREYBOX_SPEC.md` v1.1, `fase1_fase2_mapa_progresion.md` v0.6 y `FASE1_LOGIC_CONTRACT.md`. No utilizar sus recorridos, coordenadas ni preguntas abiertas cuando contradigan esas fuentes.

Status: route design requested by the owner on 2026-10-14. Not an implemented expansion, approved construction plan, or playtest result. Written in English under the documentation convention.

## 1. Experience and authority

A substantial first encounter with Final Thaw: explore an industrial facility, search for relevant elements, understand its physical relationships, and feel restrained tension before the escape. Walking, looking and discovering are part of the experience, not downtime to eliminate. The electrical puzzle supports exploration; it is not the purpose of every room.

This route refines the pacing of FASE1_GRAND_DESIGN.md and proposes an expansion of the six-room complex in FASE1_ROOM_COMPLEX.md. It does not alter FASE1_LOGIC_CONTRACT.md, save formats, inputs, autoloads or existing scenes. Earlier geometry remains the comparison build. Final record contents, Aster chronology, scanner origin, protected extraction and containment trigger remain subject to script approval.

## 2. Ten spaces, not ten mandatory puzzles

Six existing room identities are retained. Four new spaces extend the route, with proposed floor levels, not final coordinates.

| Space | Level | Build status | Purpose |
|---|---|---|---|
| Covered service approach | 0 m | New proposal | Enter gradually; see part of the facility before crossing its threshold |
| Entry vestibule | 0 m | Existing prototype identity | Orientation, evacuation diagram and closed return shortcut seen from below |
| Test hall | 0 m | Existing prototype identity | Main landmark and route choice; machine occupies space without hiding destinations |
| Observation gallery | +1.5 m | New proposal | Optional first look at the rig and a suspicious cable route from another angle |
| Service pit | -2 m | Existing prototype identity | Compare intended distribution with physical intervention |
| Lower service passage | -2 m | New proposal | Longer atmospheric traversal and recognition of a later escape connection |
| Maintenance workshop | -2 m | New proposal | Investigate a quiet working area; local diagnostic display and onward route |
| Pump room | +1.5 m | Existing prototype identity | Contrast, pause and ascent after the enclosed lower route |
| Upper control walkway | +3 m | Existing prototype identity | Read the whole installation from above; selector, isolator and indicators |
| Archive cabin | +3 m | Existing prototype identity | Confirm the hypothesis and reach the narrative boundary |

Existing room names do not imply all their behavior is complete. The new gallery is a separate room, not a second label for the current catwalk. The approach is a covered threshold, not a new exterior landscape.

## 3. Connection graph

```text
APPROACH -- VESTIBULE -- TEST HALL -- PUMP ROOM -- UPPER WALKWAY -- ARCHIVE
                             |          ^                            |
                 OBSERVATION GALLERY    |                            |
                   (look-and-return)    |                            |
                             |          |                            |
                         SERVICE PIT -- LOWER PASSAGE -- WORKSHOP ---'
                                          |              |
                                   optional recess       `-- fixed ascent to PUMP ROOM

ARCHIVE -- shortcut stairs -- VESTIBULE (unlocked from archive side)
```

Edges are walkable connections, except observations explicitly described as window sightlines. The workshop does not directly join the archive: the drawing's long lower line represents the return network, not a hidden door into the final room. Definitive route edges: approach-vestibule; vestibule-hall; hall-gallery; hall-pit; pit-passage; passage-workshop; workshop-pump by fixed ascent; hall-pump by existing stairs; pump-walkway; walkway-archive; archive-vestibule by existing unlockable shortcut. The optional recess belongs to the passage, not an eleventh production room.

Main investigation route: approach -> vestibule -> hall -> pit -> passage -> workshop -> pump -> walkway -> archive. Optional gallery may be explored before or after the pit. Keep hall-pump access open as an alternative order; do not force an invisible checklist. A player who reaches upper controls early can experiment and then descend to understand the result.

Walking targets for new connections are roughly 10-30 m between significant destinations, with turns and changes of sightline. These are blockout targets, not additional empty straight corridors or guaranteed duration. The fixed ascent from -2 m to +1.5 m needs a landing or switchback with tested clearance; no free climb or unvalidated lift. Final coordinates, door openings and wall volumes must be specified before construction.

## 4. Experience sequence

### A. Threshold and orientation

The covered approach offers quiet movement before instruction. Through a controlled sightline Elena sees a lit upper cabin or another recognizable destination cue. This needs a new sightline check: the present layout does not prove visibility. The vestibule gives spatial information through signage and a simplified facility plan. Do not introduce keypad codes or collected keys.

### B. First choice in the hall

The hall opens after the narrower entrance. The rig, the downward service route and the upper walkway establish a place larger than one room. The player can inspect the gallery or go down. Use architecture and room signs rather than permanently floating debug labels. Walking around the rig should expose a new view, not just lengthen the path.

### C. Observation gallery

A fixed stair reaches a smaller room with windows towards the hall. From here the anomalous feed is easier to recognize, but its full continuity is still unclear. Seeing a conductor emerge where the schematic does not expect it motivates inspection below. The gallery rewards a detour with understanding; it contains no required collectible and no access unlock.

### D. Descent and physical evidence

The pit contains the intended-distribution schematic, bridge anomaly and maintenance control. They supply different information. Investigating is possible with physical labels and visible connections; scanner presentation may later make hidden continuity easier to read. Do not require collecting an item to repair the bridge: the approved isolator/selector model remains the solution.

### E. Lower passage

A substantial section of walking is intentional. Turns conceal the next room; glimpses through service apertures locate the machinery above. A continuous pipe or structural feature provides orientation. One proposed cue is an intermittent mechanical sound whose source is encountered at the passage end. Do not imply an enemy is stalking Elena unless script approves that fact. No global timer, forced chase, random damage or repeated fake jump scare.

An optional recess contains a maintenance observation or personal detail, subject to script approval. The main route remains recognizable; the recess need not contain a reward currency or puzzle piece.

### F. Workshop and pause

The workshop gives a quieter place to inspect and relate what was found. Proposed local diagnostics duplicate current state and last recorded trip without adding new electrical rules. Keep the existing rearm in the archive cabin for short recovery; do not require another full descent after every wrong guess. The workshop's fixed ascent to pumps completes a loop instead of ending in a dead end.

### G. Pumps and regained scale

After the lower enclosed route, the pump room opens the view and provides a safe pause at the existing warming-station presentation. This is not a new survival resource gate. A view back towards the lower route helps the player understand the climb. The next stair visibly leads higher. Existing lift tests stay independent; the mission route never depends on their success.

### H. Upper understanding

The walkway lets the player compare the seen installation with the documented one. Selector, isolator and indicators implement the agreed circuit. Experimenting is allowed; a trip communicates a consequence and retains progress. Optional hints remain requested, and diagnostics must distinguish requested destination from effective supply and retained trip history.

### I. Archive and narrative boundary

Stable archive supply enables consultation. The player should be able to explain why it is stable. No mission-complete flag merely for reaching the room. Definitive evidence, extraction authorization and containment are not invented here. Until script approval, the playable endpoint is clearly marked successful system access with provisional content; it is not a finished narrative ending.

## 5. Relevant discoveries

| Category | Examples | Rules |
|---|---|---|
| Required to operate the system | Reach the controls; achieve stable archive supply | Do not gate a correct solution on mandatory clue-reading flags |
| Supports deduction | Schematic, bridge, actual demand indicators, diagnostic | Each contributes a distinct relationship, not a repeated answer |
| Useful spatial knowledge | Evacuation plan, workshop-pump link, upper view, return shortcut | Benefits exploration and future escape, not an arbitrary key hunt |
| Optional context | Work-area traces; possible Iris/Selene resonance point | Subject to script approval, never necessary for completion |

The player may discover, understand and remember without collecting an inventory object. Preserve acquired knowledge across power changes and retries.

## 6. Tension progression without chasing

1. Approach: quiet unfamiliarity; destination partly visible.
2. Hall/gallery: contradiction between apparent shutdown and remaining activity.
3. Pit: physical evidence of intervention; interpretation begins.
4. Lower passage: reduced sightlines, restrained sound and anticipation.
5. Workshop/pumps: relief and a moment to connect observations.
6. Restoration/control: familiar spaces change light and sound in response to the player's actions.
7. Archive: focused expectation before the approved narrative turn.

All cues must have a cause or an explicitly pending narrative explanation. Tension does not mean silently spawning a pursuer in Phase 1. Reduced-motion and audio-independent signals must be retained when implementing responses. Never make access depend on timing a flicker or identifying a sound.

## 7. Preparation for Phase 2

Exploration teaches room identity, vertical connections and alternatives. The later escape can use the workshop-pump loop, lower passage sightline breaks, hall cover and archive-vestibule shortcut. These are design opportunities, not pursuit already implemented.

Do not turn Phase 2 into an exact reverse traversal. A script-approved containment event may alter one familiar connection, with a visibly available alternative. Knowledge should help, but memorizing the entire map must not be mandatory; unfamiliar players still need fair route cues and short checkpoints. Evidence must persist across escape retries when that feature is approved.

## 8. Scale and pacing targets

Proposed first-time investigation range: 15-25 minutes including optional exploration; an informed route should be materially shorter. Measure actual time rather than slowing Elena, adding waits, forcing revisits or insisting on a quota. No action-per-minute requirement. A quiet walk may succeed because it establishes distance, atmosphere and anticipation.

Record separately travel, looking, inspecting, thinking, experimenting, recovery, optional detours and time lost to camera/confusion. Cut purposeless repetition, not the sense of a large place. Review duration only after the new room connections are playable.

## 9. Implementation batches

A. Layout extension: add approach, gallery, passage and workshop; define exact footprints, heights, shared wall ownership, safe spawns and sightlines. Preserve current six-room scene for comparison before replacing its route.
B. Traversal validation: walk both investigation and alternative-order routes; test fixed ascent, gallery visibility and shortcuts. No lift or pursuit dependency.
C. Discovery placement: redistribute existing physical clues and add only approved contextual details; keep circuit logic and local rearm recovery unchanged.
D. Restrained tension: attach reusable audio and light responses to explicit states; do not add unapproved threats.
E. Unfamiliar-player review: observe exploration, deduction and desire to continue; revise room connections before adding more content.
F. Narrative handover: only after evidence and containment are approved, connect the endpoint to escape.

Reuse Claude's model, embedded animations, FacilityMaterials, shared HUD, shaders and existing industrial props. Adapt object positions and clearance to third person, not copy old room dressing blindly. Do not replace completed assets with a new permanent primitive character.

## 10. Acceptance and evidence

Technical: continuous route and alternate order; no blocked doors, hidden drops, trapped power states or lost knowledge; tested camera clearance and stable restoration. Logical: agreed circuit tests and diagnostic availability remain valid. Spatial: player distinguishes the major rooms/levels and finds relevant elements without continuous directions. Experiential: player describes anticipation and discovery, not only waiting or confusion; longer travel has at least some locations they want to investigate voluntarily.

For unfamiliar-player tests, ask afterwards what anomaly they found, why isolating trial matters, which connections they remember, whether any quiet section felt purposeless, and whether they want to continue. Do not demand that they share the author's intended emotional response. Failure of deduction or sustained boredom triggers iteration, not more rooms automatically.

Record exact commit, Godot version, renderer, resolution, input device, console errors, hints, actions, durations, observations and unresolved defects. Distinguish inspected design, executed build and manually validated experience. This document provides no new execution evidence.
