> **Design status update — 2026-10-14:** This file preserves the earlier full-campaign narrative as historical source material. The 16-phase dual-protagonist structure, Marcus combat arc, fixed timeline, final-boss sequence and three-ending system are **under review**, not binding requirements for the current prototype. The active opening hypothesis is an Elena-led investigation/system puzzle followed by a third-person traversal and escape sequence. See [VISION.md](VISION.md), [DESIGN_PIVOT_PROTOTYPE_BRIEF.md](DESIGN_PIVOT_PROTOTYPE_BRIEF.md) and [MOTION_CHASE_PROTOTYPE.md](design/MOTION_CHASE_PROTOTYPE.md). Do not silently discard established character or world facts; reconcile them after the prototype playtest.

> **v4.0 note (2026-10-15, as-built):** The opening is implemented: intro and ending cinematics, lines N1-01/N1-02/N2-01/N2-06 as subtitles, public-address announcements, field notes. STAFF-M1 (N2-02) was removed. The restricted record's last line names FINAL THAW STATION as the hook for Phase 3. Texts: `data/game_text.json`. See [FASE1_PREMIUM_AUDIT.md](design/FASE1_PREMIUM_AUDIT.md) (v4.0).

## Current opening narrative and script beats (design proposal; not implemented)

**Authority:** this section governs the current opening proposal only. The legacy campaign below remains archived. Existing facts about Elena, Iris, Selene, Aster and Helix are retained where compatible; this opening does not lock the full campaign, Marcus's role, chronology or endings.

### Dramatic premise

Elena returns to a clandestine Helix facility to investigate a discrepancy around an Aster test. The official record and the physical state of the installation disagree. The player discovers that the test result was diverted or withheld, but does not yet learn the entire motive or chain of command. Activating maintenance queues a mission-level `SERVICE_OVERRIDE` without changing the circuit model; opening the exterior leaf of G sends the queued audit and initiates Containment. The recovery unit is the physical consequence of the system response, not a random enemy spawn.

The player's emotional progression is: **curiosity → doubt → inference → confirmation → alarm → urgent improvisation → temporary escape**.

### Mission 1 — The Ghost Protocol

**Dramatic objective:** establish the discrepancy and let the player infer manipulation through physical evidence.

1. **Entry / orientation.** Elena enters through the west service tunnel. The Aster rig is visible but inactive. The space suggests an operational research facility evacuated in haste, not a ruin.  
   *Dialogue proposal:* “No deberían haber dejado el circuito en este estado.”  
   The line is optional contextual reaction; the objective must be understandable without it.

2. **Physical contradiction.** The player compares the intended circuit diagram with the actual A→T bridge and follows the cable route. The scanner reveals continuity and state but does not mark the correct action.  
   *No exposition dump:* environmental state carries the primary information.

3. **Maintenance and diagnosis.** The player enables maintenance, observes the physical response, and configures the existing circuit under `FASE1_LOGIC_CONTRACT.md`. Errors are recoverable and teach the system's rules.

4. **Restricted record.** With ARCHIVO stable, the player reads the record. The record is concise and contradicts the official summary.  
   *Proposed terminal text:* “Ensayo Aster: resultado retenido. Recomendación de despliegue: suprimida.”  
   This is a proposed line for narrative review, not locked final copy. It establishes suppression, not who ordered it or why.

5. **Approach to G.** The player understands enough to leave, but the facility is still active. The maintenance interaction has queued `SERVICE_OVERRIDE`; reading the record is not itself the trigger.

6. **G / causal trigger.** Opening the exterior leaf of G and crossing the threshold sends the queued audit. Containment activates. The exterior side must be visible enough to explain the trigger; the recovery unit must enter through a physically plausible approach. No scene teleport.

### Mission 2 — Containment

**Dramatic objective:** turn discovery into physical jeopardy while preserving Elena's agency.

7. **Threat enters.** A containment alarm and an identifiable mechanical/audio cue precede the recovery unit's appearance. The player gets a short but real opportunity to retreat. The unit searches and tracks only from evidence it can perceive.

8. **Quiet evasion through F/E.** Elena turns back through the inner G door and moves through control/archive and connected work areas where staff may still be present. She uses real cover, timing and quiet movement to avoid attention; no takedown is required. Containment has begun, but the first section is not an automatic sprint.  
   *Dialogue proposal, only if a quiet window exists:* “La auditoría ha activado el protocolo de contención.”  
   This line is provisional and must not explain a fact already made obvious by the world.

9. **Reacquisition / running chase.** The first running segment begins at R1, the transition from P0 service gallery to the east return corridor (reference X≈29, Z≈1). Elena has descended in the existing lift; the recovery unit follows through the same lift and reacquires her by actual line of sight. R1 is the default transition; earlier reacquisition is allowed only through real LOS. The trigger and NPC positions must be authored on the plan and graph; no omniscient detection or camera cut.

10. **Vertical escape.** The player returns through existing vertical/service circulation toward P0/P−1 and the selected alternative exit. The level must never invent a new stair or lift to make the script work.

11. **Alternative service exit.** Elena leaves through a physically justified exterior mouth different from the west entrance. Its location is chosen to support the full route and can differ from the current provisional P−1 mouth. The selected exit connects continuously to the parking area; the parking plan's local coordinate frame is fitted afterward.

12. **Parking chase.** The running pressure continues into the parking area. The player reads cover, columns, vehicles, sightlines and the service perimeter. The routes trade exposure against time/traversal. The recovery unit remains bound by its senses and physical navigation.

13. **Egress / aftermath.** Elena crosses the physically defined north gate and exits the perimeter. The immediate pursuit is broken, but the broader threat remains.  
   *Proposed final beat:* after the crossing, a service reader displays “PROTOCOLO DE CONTENCIÓN: ACTIVO / SECTOR EXTERIOR” while perimeter lights/access states change in sequence. Elena says: “Fuera del perímetro. Eso no significa que haya terminado.” Deliver one short, skippable subtitle after the gate crossing, without pausing control. This implies a coordinated response without naming an operator or resolving the wider conspiracy; it remains a proposal for the opening, not locked full-game canon.

### Recommended narrative baseline (proposal for owner review)

To keep the opening coherent without inventing a full conspiracy explanation, use the following as the recommended direction for this slice:

- **Aster fact:** the physical circuit state and restricted record disagree with the official summary; the record says the result was retained and the deployment recommendation suppressed. The opening establishes suppression, not motive.
- **Containment cause:** the maintenance interaction queues `SERVICE_OVERRIDE` as separate mission state; opening G transmits the queued audit and starts the facility's recovery protocol. The event is automated at the facility level. No named executive is shown ordering the pursuit.
- **Recovery unit:** treat it as an autonomous facility recovery/security unit, not a supernatural pursuer or a combat enemy. It uses bounded senses, has a recognizable mechanical signature and cannot pass through physical barriers. Do not lock a specific manufacturer, model or human operator in final art yet.
- **Mission 2 new information:** the response affects more than one local door: a perimeter light/access state changes in a sequence that implies coordinated facility control. This implies coordination, not who controls it or why.
- **Elena's personal history:** do not insert an Iris memory or name Selene in the chase just to add emotion. Use either only when a specific established chronology and a quiet, gameplay-safe trigger justify it. Keep Marcus out of this opening unless full-campaign reconciliation makes him necessary.

This baseline closes the *opening's dramatic logic* while keeping the larger mystery intact. It is a recommendation for review, not user-approved full-game canon.

### Provisional in-game script table

All lines below are proposed Spanish source copy for the prototype. They must be approved and localized before final recording. Silent environmental delivery is preferred wherever it can carry the same fact.

| ID | Trigger / safe window | Proposed line or text | Delivery / player control | Purpose |
|---|---|---|---|---|
| N1-01 | First clear view of Aster rig; movement not blocked | Elena: “El registro no coincide con el estado del circuito.” | One short subtitle; no camera lock; skippable | Establish discrepancy without solving it |
| N1-02 | Player scans the A→T bridge after first seeing the diagram | Optional Elena reaction: “Este puente no figura en el esquema.” | Only once; no repeat spam; can be omitted if environmental cue is clear | Reinforce physical manipulation |
| N1-03 | Player reads restricted record | Terminal: “ENSAYO ASTER — RESULTADO RETENIDO. RECOMENDACIÓN DE DESPLIEGUE: SUPRIMIDA.” | Static readable text, accessible again from archive during Mission 1; not required during chase | State the specific contradiction |
| N1-04 | Opening G's exterior leaf after maintenance queued SERVICE_OVERRIDE | No mandatory spoken line. Alarm changes state; status light changes; exterior door mechanism is audible/visible | Gameplay continues; no forced camera | Make cause and consequence legible |
| N2-01 | Recovery unit becomes audible/visible beyond G | Elena: “La auditoría ha activado el protocolo de contención.” | Trigger only after the unit can be perceived by sight or sound; subtitle; skippable | Connect the audit to the response without naming an operator |
| N2-02 | First occupied work area during quiet evasion | No mandatory spoken line. Staff voices, work posture and a readable sightline establish who may notice Elena | NPC routines are deterministic enough to learn; no required takedown; optional dialogue never blocks movement | Establish stealth pressure before the running chase |
| N2-03 | Recovery unit reacquires Elena at R1 in P0 | No mandatory line. Footsteps/servo, alert-state change and a clear silhouette communicate the switch to pursuit | R1 target: X≈29, Z≈1, 2 × 2 m; transition requires actual line of sight. No camera cut or input lock | Turn quiet evasion into a readable running chase |
| N2-04 | Elena reaches the P−1 service gallery; machinery briefly masks the pursuer's audio | No dialogue required; pump/ventilation bed gives way to exterior ambience | This is a brief acoustic breath, not a guaranteed loss of line of sight; the threat may continue through the physically connected gallery | Create a readable spatial transition without a teleport or invented occluder |
| N2-05 | First view of parking exit/perimeter | No mandatory line. A service reader displays “PROTOCOLO DE CONTENCIÓN: ACTIVO / SECTOR EXTERIOR” while perimeter lights/access states change in sequence | Environmental storytelling; readable without sound; no forced stop or log interaction | Show coordinated facility response without naming an operator or explaining the motive |
| N2-06 | Escape boundary crossed | Elena: “Fuera del perímetro. Eso no significa que haya terminado.” | One short, skippable subtitle after the player crosses the gate and reaches a safe delivery window; never interrupt the final movement | Deliver temporary release, preserve stakes |

**Trigger safeguards:** N1-03 is not the Containment trigger; N1-04 occurs only once when the queued audit crosses G. N2-01 must never play before the unit can be perceived. N2-06 must not interrupt the final movement or play before the exit boundary is crossed. Any line removed for pacing must have its narrative function covered by a readable environmental cue.

### Script and delivery rules

- Every line must have a speaker/source, trigger, exact approved text, subtitle, delivery window, skip/replay policy and a statement of whether gameplay continues.
- No mandatory voice line may play over a precision traversal or obscure a threat cue.
- Do not force the player to read optional documents during a chase.
- Keep core story facts available through physical evidence and readable state changes; dialogue can reinforce but must not be the only source.
- Use Iris as emotional subtext only when the beat has a specific personal trigger. Do not add a generic memory collectible or explain her entire history in the opening.
- Preserve ambiguity around Selene's exact responsibility. Do not introduce Marcus as a required participant in this opening.
- Proposed lines above are placeholders for tone and meaning, not final localization/script lock.

### Open narrative decisions (must not be silently invented)

| Decision | Current status | Required owner decision |
|---|---|---|
| Why the Aster result was suppressed | The suppression is evidenced; motive is open | Decide the minimum truth revealed in the opening |
| Who supervises the response | The facility-level recovery protocol is the recommended baseline; the audit is sent when G opens | Keep the exact recipient and degree of remote supervision unresolved until full-campaign reconciliation |
| Recovery-unit identity | Recovery unit exists in prototype; final identity is open | Decide visual/story identity before final art and VO |
| Elena's relationship to Iris in this exact moment | Emotional history exists in legacy material; opening beat is not locked | Choose one specific, restrained personal reaction or omit it |
| Selene's responsibility | Open | Preserve ambiguity until full campaign reconciliation |
| Marcus's role, chronology and endings | Legacy campaign under review | Do not resolve in this opening without owner approval |

### Narrative acceptance

A first-time player should be able to answer after the opening:
1. What was inconsistent about the Aster system?
2. What evidence suggests the result was withheld?
3. Which player action caused Containment to begin?
4. How can Elena avoid staff during the quiet section, what event turns it into a run, and what can the recovery unit perceive or lose?
5. Has Elena solved the larger conspiracy? (Correct understanding: no.)

These are playtest questions, not assumed results. Record actual answers and revise the staging if players cannot infer the intended facts.

---

# LEGACY FULL-CAMPAIGN NARRATIVE — UNDER REVIEW

The material below documents an earlier 16-phase campaign direction. It is retained so that character history, themes, dialogue ideas and continuity details are not lost during redesign. Its phase order, timings, character roles, canon claims, state variables and ending rules are not approved requirements for the current prototype. Where this legacy material conflicts with the opening hypothesis above, use the opening hypothesis for prototype work and record unresolved canon questions for owner review.

---

# FINAL THAW — Complete Narrative Documentation

## 1. Arco Completo de la Campaña

### Three-Act Structure with 4 Inflection Points

```
ACT I: SEPARATION (4-5 hours)
├─ Phases 0-1: Tutorial (Elena movement, Marcus combat)
├─ Phases 2-3: First solo chapters (laboratory, combat arena)
├─ Phases 4-7: Escalation (highway, shelter, perimeter)
└─ Phase 8: INFLECTION #1 — First meeting, temporary truce

ACT II: COOPERATION (5-6 hours)
├─ Phases 9-11: Joint progression (Aster calibration, dam, port)
├─ Phase 12: INFLECTION #2 — Free switching unlocked, evidence choice
└─ Phase 13: INFLECTION #3 — Final evidence discovery

ACT III: CONVERGENCE (4-5 hours)
├─ Phase 14: INFLECTION #4 — Final boss (coordination climax)
├─ Phase 15: Ending choice (3 distinct cinematics)
└─ Phase 16: Credits, post-credits stinger
```

### Detailed Act Breakdown

#### ACT I: SEPARATION ("We Need Each Other But Don't Trust Yet")

**Phase 0-1: Tutorial** (30 minutes)
- Elena escapes monitoring facility (teaches movement, scan, interaction)
- Marcus clears first combat arena (teaches combat, dodge, block)
- **Narrative state**: Both isolated, running from Helix

**Phase 2: Laboratory** (20 minutes)
- Elena discovers Helix withheld viable Aster method
- Retrieves partial transmission for Final Thaw Station
- **Narrative state**: Elena now has purpose (reach station), still alone

**Phase 3: Combat Arena** (15 minutes)
- Marcus learns his unit reassigned to "terminate Elena if capture fails"
- **Narrative state**: Marcus now disillusioned, starts questioning orders

**Phase 4: Highway** (15 minutes)
- Marcus clears route, finds evidence of reassignment
- **Narrative state**: Marcus knows he must find Elena, but why?

**Phase 5: Vehicle Minigame** (5 minutes)
- Marcus repairs emergency vehicle before fire front arrives
- **Narrative state**: Marcus now en route to shelter where Elena is trapped

**Phase 6: Shelter** (20 minutes)
- Elena rescues civilians (optional), learns Marcus is approaching perimeter
- **Narrative state**: Elena knows Helix is coming, must decide: trust Marcus or run?

**Phase 7: Perimeter** (15 minutes)
- Marcus fights through Helix blockade, defeats Riot Commander
- Discovers termination orders
- **Narrative state**: Marcus now knows Helix wants Elena dead, not captured

**Phase 8: First Joint Mission** (25 minutes)
- **INFLECTION #1**: Marcus breaches shelter, finds Elena
- Dialogue:
  - Marcus: "I'm not here to hurt you."
  - Elena: "You're Helix. That's exactly what you're here for."
  - Marcus (quiet): "Yeah. That's what I was trained to be. Not anymore."
- They agree to temporary truce to escape toxic rain
- **Narrative state**: Both alive, both distrustful, both need each other

---

#### ACT II: COOPERATION ("Learning to Trust")

**Phase 9: Aster Calibration** (10 minutes)
- Elena recalibrates Aster in damaged vehicle while Marcus drives through storm
- Aster identifies Final Thaw Station (mountain atmospheric relay)
- **Narrative state**: Both now have shared goal (reach station), trust improving

**Phase 10: Dam** (20 minutes)
- Elena navigates collapsing dam, uses Aster charges to stabilize path
- Marcus waits at exit, protects Elena from scavengers
- **Narrative state**: Elena sees Marcus as protector, not threat

**Phase 11: Port** (25 minutes)
- Marcus clears port, rescues evacuees (optional), defeats Transport Captain
- Elena arrives, sees Marcus's compassion firsthand
- **Narrative state**: Elena now trusts Marcus enough to share Aster plans

**Phase 12: Transit Hub** (30 minutes)
- **INFLECTION #2**: Free switching unlocked (2s cooldown → instant)
- Three rooms requiring both characters:
  1. Elena hacks terminal while Marcus defends
  2. Marcus moves heavy object, Elena powers lift
  3. Elena controls lighting, Marcus performs stealth takedowns
- Evidence choice: Preserve (expose Helix) or erase (immediate deployment)
- **Narrative state**: Full trust, but moral disagreement emerges

**Phase 13: Final Thaw Station** (35 minutes)
- **INFLECTION #3**: Discover Helix engineered earlier Aster test failure
- Final evidence choice (overwrites Phase 12 preliminary intention)
- **Narrative state**: Both know truth, must decide: expose Helix or deploy now?

---

#### ACT III: CONVERGENCE ("One Unit, One Choice")

**Phase 14: Final Boss** (20 minutes)
- **INFLECTION #4**: Helix Commander (Dr. Selene Voss, Elena's mentor) confronts them
- Elena maintains reactor balance while Marcus protects her and fights boss
- Boss defeated through coordination (Elena calibrates, Marcus attacks during vulnerability)
- **Narrative state**: Both survived, choice must be made

**Phase 15: Epilogue** (15 minutes)
- Player makes final choice (Public/Guarded/Fragile Thaw)
- 90+ second cinematic per ending
- **Narrative state**: Consequences of all choices realized

**Phase 16: Credits + Stinger** (5 minutes)
- Credits scroll (skippable after 10 seconds)
- Post-credits stinger: 3 years later, young scientist opens Aster files
- **Narrative state**: Legacy continues, sequel hook

---

## 2. Cronología de Acontecimientos

### Pre-Game Timeline (Backstory)

| Year | Event | Impact on Story |
|------|-------|-----------------|
| **2018** | Elena Vast born (Romania) | Protagonist origin |
| **2020** | Marcus Reyes born (California) | Protagonist origin |
| **2025** | Iris Vast born (Elena's sister, age 8 when Elena is 10) | Elena's guilt source |
| **2035** | Climate Collapse begins (Jakarta floods, Mumbai heat dome) | World state |
| **2038** | Iris Vast dies (Jakarta floods, age 23). Elena chose research over evacuation. | Elena's core trauma |
| **2040** | Helix Corporation develops Aster Protocol (climate stabilization) | MacGuffin created |
| **2041** | Dr. Selene Voss (Elena's mentor) loses daughter in Mumbai heat dome | Antagonist motivation |
| **2042** | Aster Test 7-C deliberately misreported as failure by Helix | Conspiracy begins |
| **2043** | Elena joins Helix as protégé of Voss | Relationship established |
| **2045** | Marcus joins police force | Backstory |
| **2047** | Climate riots begin. Marcus ordered to protect assets, not civilians. Refuses, discharged. | Marcus's shame |
| **2048** | Marcus fails to save child (Amara) during riots. Chose following orders over saving life. | Marcus's core trauma |
| **2049** | Elena discovers Helix weaponized her research | Inciting incident |
| **2050** | Elena steals Aster prototype, escapes Helix facility | Game begins |
| **2050** | Marcus reassigned to Helix, ordered to capture/terminate Elena | Conflict established |

### In-Game Timeline (13-15 hours)

| Time | Event | Location | Characters Present |
|------|-------|----------|-------------------|
| **Hour 0** | Elena escapes monitoring facility | Underground facility | Elena only |
| **Hour 0.5** | Elena completes laboratory puzzles | Abandoned lab | Elena only |
| **Hour 1** | Marcus clears combat arena, discovers reassignment orders | Highway | Marcus only |
| **Hour 1.5** | Marcus repairs vehicle, reaches shelter perimeter | Shelter exterior | Marcus only |
| **Hour 2** | Elena navigates shelter, rescues civilians (optional) | Flooded shelter | Elena only |
| **Hour 2.5** | Marcus defeats Riot Commander, learns termination orders | Shelter perimeter | Marcus only |
| **Hour 3** | **INFLECTION #1**: Marcus breaches shelter, meets Elena | Shelter interior | Elena + Marcus |
| **Hour 3.5** | Toxic rain escape, temporary truce formed | Exterior | Elena + Marcus |
| **Hour 4** | Aster calibration minigame, Final Thaw Station identified | Damaged vehicle | Elena + Marcus |
| **Hour 5** | Elena navigates collapsing dam | Dam interior | Elena only (Marcus waits) |
| **Hour 6** | Marcus clears port, defeats Transport Captain | Port docks | Marcus only (Elena arrives late) |
| **Hour 7** | **INFLECTION #2**: Free switching unlocked, evidence choice | Transit hub | Elena + Marcus |
| **Hour 8-10** | Final Thaw Station infiltration | Mountain relay | Elena + Marcus |
| **Hour 11** | **INFLECTION #3**: Final evidence discovery | Station archive | Elena + Marcus |
| **Hour 12** | **INFLECTION #4**: Final boss (Voss confrontation) | Atmospheric control | Elena + Marcus + Voss |
| **Hour 12.5** | Ending choice, cinematic | Varies | Elena + Marcus |
| **Hour 13** | Credits, post-credits stinger | N/A | N/A |

---

## 3. Estados Narrativos

### Global States (Tracked in GameManager)

| State | Type | Possible Values | Default | Changes When |
|-------|------|-----------------|---------|---------------|
| `elena_safety` | Integer | 0, 1, 2, 3 | 3 | Enemy reaches Elena, scripted threat hits her |
| `prototype_integrity` | Integer | 0, 1, 2, 3 | 3 | Elena crosses hazard without protection |
| `civilian_aid` | Integer | 0-10 | 0 | Player rescues civilian (once per rescue) |
| `evidence_choice` | String | "preserve", "erase", null | null | Player makes choice in Phase 12 or 13 |
| `active_character_id` | String | "elena", "marcus" | "elena" | Player switches character |
| `current_checkpoint_id` | String | Phase-specific (e.g., "phase_6_shelter_exit") | "" | Player reaches checkpoint |
| `completed_phases` | Array | ["phase_0", "phase_1", ...] | [] | Player completes phase |
| `story_flags` | Dictionary | See below | {} | Various narrative events |

### Story Flags (Dictionary Keys)

| Flag | Type | Set When | Impact |
|------|------|----------|--------|
| `rescued_shelter_civilians` | Boolean | Phase 6: Player rescues ≥1 civilian | NPCs in Phase 13 are grateful vs. bitter |
| `rescued_port_civilians` | Boolean | Phase 11: Player rescues ≥1 evacuee | Epilogue shows thriving community vs. abandoned port |
| `vehicle_repaired_cleanly` | Boolean | Phase 5: Player solves before timer expires | Minor narrative variation in Phase 6 intro |
| `vehicle_repaired_under_pressure` | Boolean | Phase 5: Timer expires | Vehicle has reduced speed in Phase 6 |
| `perimeter_complete` | Boolean | Phase 7: Boss defeated | Unlocks Phase 8 |
| `termination_order_discovered` | Boolean | Phase 7: Marcus reads orders | Marcus dialogue changes in Phase 8 |
| `aster_calibrated` | Boolean | Phase 9: Minigame complete | Unlocks Phase 10 |
| `final_thaw_station_revealed` | Boolean | Phase 9: Aster identifies station | Elena dialogue: "We know where to go" |
| `dam_complete` | Boolean | Phase 10: Elena reaches exit | Unlocks Phase 11 |
| `port_complete` | Boolean | Phase 11: Marcus clears arena | Unlocks Phase 12 |
| `switching_unlocked` | Boolean | Phase 12: Free switching enabled | UI changes, cooldown removed |
| `final_thaw_station_complete` | Boolean | Phase 13: All sections cleared | Unlocks Phase 14 |
| `boss_defeated` | Boolean | Phase 14: Voss defeated | Unlocks Phase 15 |
| `ending_viewed` | Boolean | Phase 15: Any ending cinematic watched | Prevents replay loop, enables New Game |

---

## 4. Arcos de Personajes

### Elena Vast (28 years old, Romanian atmospheric scientist)

**Arc**: "Guilt → Purpose → Transcendence"

| Act | State | Belief | Behavior |
|-----|-------|--------|----------|
| **Act I** | Running from guilt | "I chose wrong. I can't save everyone." | Isolates, focuses on prototype, avoids civilians |
| **Act II** | Running toward purpose | "Maybe individual action matters." | Cooperates with Marcus, starts rescuing civilians |
| **Act III** | Transcends guilt | "This is for Iris. Not to bring her back, but to make sure no one else has to choose." | Makes selfless choice (Public Thaw) or pragmatic choice (Guarded/Fragile) |

**Key Moments**:
- Phase 6: Sees girl same age as Iris in shelter. Player choice: rescue or skip.
- Phase 10: Alone at dam terminal, whispers: "Iris, I'm sorry. I chose wrong. But I'm choosing different now."
- Phase 15 (Public Thaw): At Iris's grave: "It's done. The protocol is free. You would have loved this world."

---

### Marcus Reyes (35 years old, North American former police officer)

**Arc**: "Obedience → Disillusionment → Redemption"

| Act | State | Belief | Behavior |
|-----|-------|--------|----------|
| **Act I** | Following orders, numb | "I'm just a tool. My choices don't matter." | Protects assets, follows reassignment orders |
| **Act II** | Learning to trust | "Maybe I can choose who to protect." | Protects Elena, rescues evacuees (optional) |
| **Act III** | Redemption | "I'm not that person anymore. I hope you can forgive me." | Final choice: kill Voss (revenge) or spare her (let Elena finish) |

**Key Moments**:
- Phase 4: Reads reassignment orders: "Terminate if capture fails." Realizes he's become what he hated.
- Phase 11: Evacuees thank him. He looks away: "Don't thank me. I haven't earned it yet."
- Phase 15 (Guarded Thaw): At police memorial, placing badge: "I'm not that person anymore."

---

### Dr. Selene Voss (55 years old, Elena's mentor, Helix Commander)

**Arc**: "Grief → Control → Tragic Downfall"

| Act | State | Belief | Behavior |
|-----|-------|--------|----------|
| **Act I** | Off-screen puppetmaster | "Democracy failed. We need benevolent dictatorship." | Orders capture/termination, withholds Aster |
| **Act II** | Active antagonist | "Elena will understand when she sees the results." | Deploys forces, tries to reclaim prototype |
| **Act III** | Confrontation | "Every world is built on corpses. Will you let them die for nothing?" | Final boss, tries to stop Elena/Marcus |

**Key Moments**:
- Phase 14: "You think I wanted this? I watched Mumbai burn. I held my daughter's hand as she stopped breathing at 38 degrees."
- Phase 14: "I became the firebreak. Someone had to."
- Phase 14 (defeated): "Perhaps you are right. But the world will not thank you for this."

---

## 5. Relaciones y Conflictos

### Primary Relationships

| Relationship | Type | Evolution | Key Dialogue |
|--------------|------|-----------|--------------|
| **Elena ↔ Marcus** | Distrust → Cooperation → Trust → Partnership | Phase 8: Temporary truce. Phase 12: Full switching. Phase 14: Coordination climax. | Phase 8: "Temporary truce. We escape together." Phase 12: "Your turn." / "Don't get killed." Phase 14: "She's not worth becoming him." |
| **Elena ↔ Voss** | Protégé → Betrayed → Confrontation | Phase 0: Voss is mentor. Phase 13: Voss ordered test failure. Phase 14: Final confrontation. | Phase 14: "You hoarded the cure." / "I rationed it. There wasn't enough for everyone." |
| **Marcus ↔ Voss** | Enforcer → Disillusioned → Enemy | Phase 4: Marcus follows Voss's orders. Phase 7: Discovers termination orders. Phase 14: Final boss. | Phase 14: "Some things don't deserve second chances." (if kills Voss) |
| **Elena ↔ Iris (deceased sister)** | Guilt → Penance → Transcendence | Phase 6: Sees girl same age as Iris. Phase 10: Whispers apology. Phase 15: Final dedication. | Phase 15: "This is for you, Iris. Not to bring you back. To make sure no one else has to choose." |
| **Marcus ↔ Amara (child he failed to save)** | Shame → Atonement → Redemption | Phase 4: Flashback to riots. Phase 11: Rescues evacuees. Phase 15: Memorial scene. | Phase 15: "I'm not that person anymore. I hope you can forgive me." |

### Conflict Types

| Conflict | Type | Resolution |
|----------|------|------------|
| **Elena vs. Helix** | External (organizational) | Defeat Voss, deploy Aster |
| **Marcus vs. Himself** | Internal (guilt over Amara) | Protect Elena, redeem himself |
| **Elena vs. Herself** | Internal (guilt over Iris) | Transcend guilt, choose for future |
| **Elena & Marcus vs. Each Other** | Interpersonal (trust) | Learn to cooperate, switch seamlessly |
| **Elena & Marcus vs. Time** | Environmental (climate collapse) | Deploy Aster before too late |
| **Elena & Marcus vs. Morality** | Philosophical (who to save) | Make final choice (Public/Guarded/Fragile) |

---

## 6. Reglas de Canon

### What Is Canon (Fixed Across All Playthroughs)

| Element | Canon Status | Notes |
|---------|--------------|-------|
| **Elena's sister Iris died** | Canon | Always died in Jakarta floods, age 23 |
| **Marcus failed to save Amara** | Canon | Always happened during riots, age 6 |
| **Voss's daughter died in Mumbai** | Canon | Always heat dome, age 12 |
| **Helix engineered Aster test failure** | Canon | Always Test 7-C, always deliberate |
| **Three endings exist** | Canon | Public, Guarded, Fragile all "happen" in multiverse |
| **Elena and Marcus survive** | Canon (for Public/Guarded) | Fragile Thaw: Elena injured but alive |
| **Aster deploys** | Canon | Always deploys, question is HOW (free vs. controlled) |

### What Is NOT Canon (Player Choice Determines)

| Element | Variable | Possible Values |
|---------|----------|-----------------|
| **Civilian Aid total** | Player choice | 0-10 (depends on rescues) |
| **Elena Safety at end** | Player choice | 0-3 (depends on protection) |
| **Prototype Integrity at end** | Player choice | 0-3 (depends on hazard navigation) |
| **Evidence choice** | Player choice | Preserve or erase |
| **Ending achieved** | Player choice | Public, Guarded, or Fragile Thaw |
| **Which civilians rescued** | Player choice | Specific NPCs appear in Phase 13/epilogue |
| **Marcus kills or spares Voss** | Player choice | Affects his dialogue in epilogue |

### Canon Hierarchy (If Contradiction Arises)

1. **Character backstories** (Iris, Amara, Voss's daughter) — ALWAYS canon
2. **Major plot points** (Helix conspiracy, Aster deployment) — ALWAYS canon
3. **Player choices** (rescues, evidence, ending) — VARIES per playthrough
4. **Optional content** (memory fragments, shortcuts) — VARIES per playthrough

**Rule**: If a sequel contradicts player choice from Phase 1, choice is retconned as "one possible timeline." Backstories are NEVER retconned.

---

## 7. Tratamiento de Temas Sensibles

### Sensitive Themes Present

| Theme | Depiction | Safeguards |
|-------|-----------|------------|
| **Climate refugee deaths** | Referenced (Iris died in floods, Voss's daughter in heat dome) | Not shown on-screen, no graphic descriptions, treated with gravity |
| **Mass casualties** | Implied (cities burned, millions displaced) | No body counts, no "suffering porn," focus on survivors' resilience |
| **Character death** | Iris, Amara, Voss's daughter (backstory); Voss (optional, Phase 14) | Deaths serve narrative, not shock value; mourning shown respectfully |
| **Violence (combat)** | Marcus fights scavengers, enforcers, marksmen | No gore toggle, no torture, enemies surrender or flee when defeated |
| **Suicide ideation** | Elena's guilt over Iris ("I chose wrong") | Never explicit, framed as grief not self-harm, hope emerges |
| **Authoritarianism** | Helix rations Aster to privileged zones | Clearly framed as wrong, resistance is heroic, no "both sides" equivocation |

### Content Warnings (Pre-Game)

```
FINAL THAW contains:
- Depictions of climate-related deaths (off-screen, backstory)
- Violence (combat with melee weapons, no gore)
- Themes of grief, guilt, and moral ambiguity
- Authoritarian control of life-saving technology

Not included:
- Graphic violence or gore (toggleable if enabled)
- Sexual content
- Strong language (mild profanity only)
- Jump scares or horror elements

If you experience distress, pause and take breaks. Resources:
- Crisis Text Line: Text HOME to 741741
- National Suicide Prevention Lifeline: 988
```

### In-Game Safeguards

| Safeguard | Implementation |
|-----------|----------------|
| **Gore toggle** | Off by default. If on, blood decals, death cries louder. |
| **Skip dialogue** | All narrative scenes skippable after 5 seconds (hold E) |
| **Reduce weather intensity** | Options menu: 25%, 50%, 75%, 100% particle density |
| **Reduce camera shake** | Options menu: 0%, 25%, 50%, 100% |
| **Pause anytime** | Pause button (Escape/P/Start) works except during 10-second scripted sequences |

---

## 8. Criterios para Evitar Exposición Redundante

### "Show, Don't Tell" Rules

| Rule | Example (GOOD) | Example (BAD) |
|------|----------------|---------------|
| **Environmental storytelling** | Elena sees Iris's memorial photo on terminal, looks away silently | Elena says: "This photo of my dead sister Iris reminds me of my guilt" |
| **Dialogue subtext** | Marcus: "We should move." (means: "I'm scared you'll die") | Marcus: "I am scared you will die so we should move" |
| **Player inference** | Rescued civilian appears in Phase 13: "Dr. Vast! You saved us!" | Narrator: "You rescued this civilian in Phase 6. They remember."
| **Memory fragments** | 1-second flashback: Elena and Iris building weather station | Text log: "Elena remembered building a weather station with Iris when she was 10" |

### Exposition Budget (Per Chapter)

| Chapter | Max Narrative Messages | Max Dialogue Lines | Max Flashbacks |
|---------|----------------------|--------------------|----------------|
| Tutorial (0-1) | 3 | 5 | 1 (optional memory) |
| Puzzle chapters (2, 6, 10) | 4 | 8 | 2-3 memories |
| Combat chapters (3, 4, 7, 11) | 3 | 6 | 2 memories |
| Joint chapters (8, 12, 13) | 5 | 12 | 2-3 memories |
| Boss chapters (7, 11, 14) | 4 | 10 | 1-2 memories |
| Epilogue (15) | 6 | 15 | 0 (cinematic only) |

**Rule**: If a chapter exceeds budget, cut redundant lines. Priority: Environmental > Dialogue > Flashback > Narrator.

### Redundancy Checks

Before adding any exposition, ask:

1. **Has this been shown before?** (e.g., Iris's death shown in memory fragment)
   - If yes: Don't re-explain in dialogue. Let player infer.
   - Example: Don't have Elena say "My sister Iris died in Jakarta floods" if player already saw memory.

2. **Can this be environmental?** (e.g., photo, terminal log, graffiti)
   - If yes: Show, don't tell.
   - Example: Instead of Marcus saying "I failed to save a child," show graffiti: "Amara, age 6. Gone but not forgotten."

3. **Is this critical for understanding?** (e.g., Helix conspiracy, ending thresholds)
   - If yes: State clearly once. Don't repeat.
   - Example: Evidence choice explained in Phase 12. Phase 13 reminds once ("This overwrites your Phase 12 choice"). No further explanation.

4. **Will player infer this from gameplay?** (e.g., Civilian Aid counter, integrity loss)
   - If yes: No exposition needed.
   - Example: Don't explain "Civilian Aid ≥4 for Public Thaw." Let player discover through HUD + playthroughs.

### Example: Iris's Death (Multiple Exposures, Non-Redundant)

| Exposure | Method | Information Conveyed | Why Not Redundant |
|----------|--------|---------------------|-------------------|
| **Memory fragment 1** (Phase 1) | 1-second flashback | Elena and Iris building weather station (age 8 and 10) | Shows relationship, not death |
| **Memory fragment 2** (Phase 6) | 1-second flashback | Elena in Helix office, evacuation form: "Select ONE dependant." Hand hovering | Shows choice, not outcome |
| **Memory fragment 3** (Phase 10) | 1-second flashback | Elena at Iris's memorial, alone, prototype case at feet | Shows aftermath, not cause |
| **Dialogue** (Phase 15, Public Thaw) | Elena at grave: "You would have loved this world." | Elena has transcended guilt | Shows growth, not backstory |

**Total**: 4 exposures, each adds NEW information. No redundancy.

---

## Summary: Narrative Documentation Complete

| Document | Status | Key Content |
|----------|--------|-------------|
| **Campaign arc** | ✅ | 3 acts, 4 inflection points, 13-15 hours |
| **Chronology** | ✅ | Pre-game (2018-2050), in-game (13 hours) |
| **Narrative states** | ✅ | Global states (counters), story flags (booleans) |
| **Character arcs** | ✅ | Elena (guilt→purpose), Marcus (obedience→redemption), Voss (grief→control) |
| **Relationships** | ✅ | Elena↔Marcus (distrust→trust), Elena↔Voss (protégé→enemy), etc. |
| **Canon rules** | ✅ | Backstories fixed, player choices variable, hierarchy defined |
| **Sensitive themes** | ✅ | Climate death, violence, guilt, authoritarianism — with safeguards |
| **Exposition criteria** | ✅ | Show don't tell, budget per chapter, redundancy checks |

**This narrative is SPECIFIC, MEASURABLE, and VALIDATED. No ambiguity.**

## Owner-approved opening direction — 2026-10-15

The following decisions refine the opening narrative proposal above. They are approved direction, not claims of implemented scenes or final full-campaign canon. Legacy campaign material below remains historical wherever it conflicts with the current prototype direction.

### Phase 1 — investigation and discovery
Elena enters the Helix facility through a damaged service breach or culvert. The access collapses behind her, removing the possibility of returning the way she came. Her investigation of Aster remains the primary gameplay and narrative engine: she observes, compares evidence, forms hypotheses, tests a system and uncovers a contradiction in the official account. The facility should feel like a large interconnected industrial research site, with a central pumping hall and meaningful surrounding rooms, rather than a sequence of unrelated puzzle chambers.

### Phase 2 — the human operation
Opening the required gate leads Elena into a previously unseen operational area. She initially proceeds cautiously and observes a small number of people performing work related to Helix/Aster. Their activity reveals meaningful information about the project. Elena is discovered by a human security threat; this human threat is the target direction for the redesigned Phase 2, superseding the current robot-led prototype as the intended principal antagonist.

The discovery triggers an urgent escape. The gameplay shifts to first-person, combining free movement and route choice with brief contextual actions. Occasional motivated glances back show the consequences of Elena's choices, such as an object delaying a pursuer. She escapes through a separately designed parking garage and reaches a public street, where she loses the pursuers in the crowd. This ending closes the immediate escape but leaves a meaningful question about Helix/Aster unresolved.

### Future Marcus-led action arc
In future beat-'em-up phases, Marcus is the player-controlled protagonist and Elena accompanies him. Initially Elena cannot defend herself reliably and relies on Marcus to intervene. As he teaches her through experience, she gains limited defensive autonomy: escaping grabs, evading or blocking basic attacks and countering minor threats opportunistically. The change must be visible in playable behavior, not only dialogue. Later encounters can challenge Marcus with more capable, varied and coordinated enemies while Elena handles basic threats herself. Do not implement the full arc in the current Phase 1/2 vertical slice.

### Tone and art alignment
The game uses illustrated 3D art informed by the owner-provided Marcus concept and illustrated industrial laboratory reference. Keep the visual world coherent rather than photorealistic, generic cartoon-like or deliberately low-resolution retro. Storytelling should emerge from people, machinery, evidence, room layout, light and player-caused consequences, not exposition alone.
