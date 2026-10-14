# Mission 1 — The Ghost Protocol

**Status:** current design contract for the investigation/puzzle portion of Phase 1. The circuit behavior is governed by `FASE1_LOGIC_CONTRACT.md`; the building-wide spatial sequence is governed by `FASE1_ARCHITECTURAL_LAYOUT.md`, `FASE1_SPATIAL_GRAPH.md`, `FASE1_GREYBOX_SPEC.md` and `fase1_fase2_mapa_progresion.md`. Not implemented or playtested as a complete sequence; not final full-game canon.

## Goal and player understanding

Elena enters a clandestine Helix hydrological/industrial research facility to investigate an Aster test whose official record conflicts with the installation's physical state. The player must infer that the Aster distribution was manipulated, safely stabilize the archive feed, and discover that the test result was retained and the deployment recommendation suppressed.

The puzzle is **distributed across the building**. It is not a self-contained 24 × 14 m room or a sequence of arbitrary locks. The architecture is part of the evidence: service labels, cable/piping continuity, the fixed A→T bridge, machine state, maintenance lighting and the diagnostic panel support the deduction.

The required player inference is:
1. The official diagram and the physical A→T bridge do not agree.
2. The trial feed must be isolated before selecting ARCHIVO.
3. A protection trip is recoverable; it is a consequence, not a game-over.
4. A stable archive reveals the suppressed result.
5. Opening the exterior leaf of G after the maintenance event is queued transmits the audit and starts Containment; consulting the record alone does not trigger the chase.

## Spatial distribution of clues

| Area | Evidence / action | Intended inference | Design constraint |
|---|---|---|---|
| A — Access/airlock | Site signage, safety instructions, route to the Aster hall | This is a real industrial facility with controlled access | Orientation must not depend on a text log |
| B — Aster test hall | Main rig, official distribution schematic, visible route of cable trays/pipes | Establish the intended system and give a readable spatial anchor | Keep the rig and main circulation visible from the third-person camera |
| C — Workshop/service area | Maintenance traces, repair tags and tools consistent with the altered bridge | The installation has been modified, not merely damaged at random | No mandatory key or unrelated collectible |
| D1/D2 — P−1 distribution and drainage | Fixed A→T bridge disagrees with the schematic; maintenance switch; isolator/selector/protection; diagnostic panel | Identify the physical discrepancy and understand that the fault is a simultaneous demand | D1/D2 remain connected by traversable floor; equipment and signage differentiate them |
| M — Pump mezzanine | Pump/light response after maintenance; sightline back into the plant | Maintenance changes service infrastructure, not the recovery-protection circuit | Do not imply that the machine starts; the start interlock remains active |
| E — Control/diagnostics | Selector, isolator/rearm controls and current-state/last-trip diagnostic | Apply the safe sequence and distinguish current state from trip history | Diagnostic labels describe state; they do not name the control to operate |
| F — Restricted archive | Record available only with stable ARCHIVO supply | Confirm that the Aster result was retained and the deployment recommendation suppressed | Consultation is not extraction, not a save-schema change, and not the Containment trigger by itself |
| G — Double-door airlock | Exterior leaf opens after the investigation; recovery unit approaches through the exterior threshold | The discovery has consequences; the player must retreat into the building | Opening G starts the interior chase; never teleport directly to parking |

## Circuit puzzle contract

`FASE1_LOGIC_CONTRACT.md` is authoritative for circuit behavior. Do not reintroduce the earlier “reconnect cable B, then restore power” puzzle: the physical A→T bridge is fixed, and the player solves the system through the isolator, destination selector, diagnostic and protection rearm.

**Initial circuit state:** maintenance OFF; destination ENSAYO; trial connected; recovery protection available; no last recorded trip. Emergency diagnostics are always available.

### Intended safe sequence

1. Observe the official distribution schematic and the physical A→T bridge; use the scanner to reveal continuity if needed.
2. Activate maintenance. Service lights and the P0↔M platform become available.
3. Isolate the trial feed.
4. Select ARCHIVO.
5. Inspect the diagnostic: destination is ARCHIVO, fault is absent, protection remains tripped only if it was tripped earlier.
6. Rearm protection. The archive becomes stable; the terminal can be consulted.
7. Read the restricted record. The working Spanish terminal copy is: **“ENSAYO ASTER — RESULTADO RETENIDO. RECOMENDACIÓN DE DESPLIEGUE: SUPRIMIDA.”** English localization is not locked and must preserve the same limited inference.
8. Return to G. Opening its exterior leaf transmits the queued service audit once and starts Containment.

### Recoverable error path

If the player selects ARCHIVO while the trial remains connected, protection trips and records `DEMANDA_SIMULTANEA`. The terminal remains inspectable, but the archive cannot be consulted. Isolating the trial clears the fault but does not rearm protection; the player must rearm. The last recorded trip remains visible after recovery. No progress is lost, no arbitrary reset occurs and no message names the correct control.

Reconnecting the trial while ARCHIVO is selected can trip available protection. Repeated valid rearm is harmless. The machine never starts in this milestone.

## Mission-level event contract (separate from the circuit model)

The circuit reference model remains authoritative and unchanged. Its maintenance operation changes only the maintenance state. The mission interaction has a separate side effect: on the rising edge OFF → ON, the maintenance switch queues the mission flag `SERVICE_OVERRIDE`. Once queued, it remains queued for this mission even if maintenance is later switched OFF; toggling maintenance cannot enqueue duplicate audits. This flag does not change circuit outputs, protection history, archive stability or save format.

- Reading the restricted record adds the in-session knowledge flag `RESTRICTED_RECORD_READ`; it does not send the audit or start Containment.
- Opening the exterior leaf of G while `SERVICE_OVERRIDE` is queued sends the audit, marks it sent and starts Containment exactly once. Repeated interaction/open callbacks must not send duplicate audits or restart the chase.
- The event must be visible/audible through door motion, a state-light change and the containment cue. No forced camera, unskippable line or direct scene transition.
- The recovery unit enters from the exterior side of G; Elena retreats through the inner leaf toward F/E. The player first evades quietly through the observation walkway, S2/M and the staffed pump work area. Elena then descends via the existing lift to P0; the recovery unit follows through the same lift and reacquires her at R1, the exposed transition from service gallery to east return corridor (X≈29, Z≈1). The running chase continues to S1, P−1 and the selected alternative service exit.
- If G is opened before `SERVICE_OVERRIDE` is queued, the door must provide a diegetic unavailable/locked response; it must not start Containment. Do not invent an alternate trigger. Restarting the mission resets both mission flags; no flag is written to persistent save data.

| Event | Precondition | Mission-state result | Circuit-model result | Player-facing result |
|---|---|---|---|---|
| Maintenance OFF → ON | Switch interaction accepted | Set `SERVICE_OVERRIDE_QUEUED=true` once | Only maintenance changes, as defined by the logic contract | Service lights/platform respond; no chase starts |
| Maintenance ON → OFF | Switch interaction accepted | Queue remains true for this mission | Only maintenance changes | Service lighting/platform follows maintenance state; no audit sent |
| Consult archive | ARCHIVO stable | Set `RESTRICTED_RECORD_READ=true` | No change to circuit outputs/history | Record becomes readable; no chase starts |
| Open exterior G | Queue true, audit not sent | Mark audit sent and Containment active | No circuit change | Door/alarm/state-light response; unit enters from exterior |
| Open exterior G | Queue false | No flags change | No circuit change | Diegetic locked/unavailable feedback; no chase |
| Repeat G/open callback | Audit already sent | No duplicate event; Containment remains active | No circuit change | No second alarm sequence or enemy spawn |
| Restart mission | New mission instance | Reset queued/read/sent/Containment flags | Circuit returns to defined initial state | Start from mission entry/checkpoint contract |

- These mission flags are session-level design state only. Any persistence beyond the current mission requires explicit compatibility review; no save-schema change is implied.

## Scanner and feedback

The scanner reveals relationships and state for 3 seconds and has a 4-second cooldown from activation; charge behavior remains aligned with the current input contract. It must not highlight the correct control or turn the puzzle into a checklist.

| Target | Reveal | Must not reveal |
|---|---|---|
| Official schematic / B | Intended distribution | The correct action sequence |
| Physical A→T bridge | Actual continuity and discrepancy | A direct “select ARCHIVO” instruction |
| Diagnostic panel | Current state and last recorded trip separately | Which control the player should operate |
| Archive terminal | Record availability and the withheld result once stable | A solution to the circuit controls |

Feedback for wrong order is immediate and recoverable: protection trip cue, status change and diagnostic history. The safe sequence produces stable archive supply, terminal access and a readable state change. Important audio cues require a visual equivalent; no clue relies on colour alone.

## HUD and dialogue

Permitted contextual text includes:
- “La compuerta sigue bloqueada.”
- “El circuito es inconsistente.”
- “No hay alimentación estable en ARCHIVO.”

The HUD must not say:
- “Aísla el ensayo.”
- “Selecciona ARCHIVO.”
- “Rearma la protección.”

The puzzle should teach the relationship, not name the answer. Optional hints may progress from the goal, to the relation between diagram and bridge, to stronger guidance; hints must not silently change circuit state.

## Failure and recovery

- Invalid order: protection trips; no progress lost.
- Isolate after trip: fault clears, protection remains tripped until rearm.
- Rejected rearm while fault remains: no state/history change.
- Fall or stuck state: return to the last fair checkpoint without erasing acquired in-session knowledge.
- No active pursuer before G's agreed trigger.
- Opening G after the audit is queued: starts the interior chase once.
- Opening G without the queued event: stays safely closed/unavailable; no chase.

## Acceptance criteria

- A first-time player can explain what physical evidence contradicts the schematic.
- The safe endpoint is reached by isolating the trial before selecting ARCHIVO and then rearming protection.
- A wrong order is recoverable and preserves the last-trip record.
- Archive consultation requires stable ARCHIVO supply and reveals the suppressed result.
- The maintenance side effect is separate from the circuit reference model.
- Opening G, not reading the archive, sends the queued audit and starts Containment exactly once.
- G begins an interior pursuit; the complete route continues through the existing vertical connections and exits via P−1, not the west entrance.
- The experience remains inferable without HUD instructions, arbitrary symbols, mandatory combat or trial-and-error.
- Code, automated tests, executed tests and hands-on validation are reported as separate evidence states.
