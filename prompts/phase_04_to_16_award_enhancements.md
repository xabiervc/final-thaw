# FINAL THAW — Award-Level Enhancements for Phases 4-16

Use this document to enhance the original phase prompts with award-winning standards. For each phase, copy the original prompt and ADD the enhancements listed below before pasting into Claude Code.

---

## Phase 4: Highway Riots Combat

**Original**: `prompts/phase_04_highway_riots.md`

**Add These Requirements**:

### Combat Enhancements
- **Style meter**: Visible UI element showing D→C→B→A→S rating based on:
  - Combo variety (light, heavy, environmental throws)
  - No-damage streaks
  - Speed of clear
  - Environmental kills (fuel canister explosions, ledge finishers)
- **Enemy Enforcer AI**:
  - Block/counter pattern: Block 3 hits, counter with shield bash (telegraphed 1.0s)
  - Flank weakness: 2x damage from behind (visual indicator: back glows red)
  - Environmental weakness: Throwable objects stun for 2 seconds
- **Arena progression**:
  - Arena 1: 3 Scavengers (teach basic combat)
  - Arena 2: 1 Enforcer + 2 Scavengers (teach Enforcer patterns)
  - Arena 3: 2 Enforcers + 4 Scavengers + throwables (test mastery)
  - Arena 4: 3 Enforcers + 6 Scavengers + fuel canisters (final test)

### Accessibility
- **Arena skip option**: After 3 deaths in same arena, offer "Skip this arena" button (sets story flag, reduces final score but allows progression)
- **Visual telegraphs**: All enemy attacks have 0.5-1.0s visual warning (red flash, arm raise)

### Performance
- **60 FPS locked**: Even with 10+ enemies, particles, camera shake
- **Enemy pooling**: Pre-spawn enemies, disable when defeated (don't free/reload)

---

## Phase 5: Broken Vehicle Minigame

**Original**: `prompts/phase_05_broken_vehicle.md`

**Add These Requirements**:

### UI/UX Enhancements
- **Visual clarity**: Systems diagram uses color + icons + text (triple-coded for accessibility)
- **Progressive hints**: After 30 seconds of no progress, highlight one incorrect system. After 60 seconds, show full solution.
- **Feedback**: Each correct connection plays pleasant chime (major chord). Incorrect connection plays soft buzz (minor dissonance).

### Fire Timer
- **Visual**: Fire bar fills from left to right over 120 seconds (generous)
- **Audio**: Fire sound intensifies as timer fills (25%, 50%, 75%, 100% markers)
- **On expiry**: Auto-complete with `vehicle_repaired_under_pressure` flag. Show alternate narrative: "You fixed it, but barely. The fire nearly took you."
- **On success**: `vehicle_repaired_cleanly` flag. Narrative: "Perfect repair. No damage taken."

### Accessibility
- **Untimed mode**: Option to disable fire timer entirely (no penalty, just different flag)
- **Colorblind mode**: Fire uses red+orange+pattern (not just color)

---

## Phase 6: Flooded Shelter Puzzles

**Original**: `prompts/phase_06_flooded_shelter.md`

**Add These Requirements**:

### Water System
- **State-based, not timed**: Water levels change based on pump/valve states, not arbitrary timers (more predictable, less frustrating)
- **Visual indicators**: Current direction arrows on water flow (particles moving with current)
- **Safety**: Water can't trap player (always a drain or exit route)

### Civilian Rescues
- **Dynamic dialogue**: Rescued NPCs appear later in game (Final Thaw Station, epilogue)
  - Shelter rescue: "Dr. Vast! You saved us. We've been helping the resistance."
  - If NOT rescued: Different NPCs, bitter tone: "You scientists come and go. We're still here."
- **Memory fragments**: 2-3 memory fragments hidden in optional rescue areas (reward exploration)

### Oxygen Section
- **Generous timing**: 60 seconds minimum (most players finish in 30-40s)
- **Visual timer**: Depleting oxygen bar with audio beeps at 25%, 10%, 5%
- **Checkpoint**: Midway through oxygen section (no full restart on failure)

---

## Phase 7: Militia Encirclement Combat

**Original**: `prompts/phase_07_militia_encirclement.md`

**Add These Requirements**:

### Marksman Enemy
- **Line-of-sight system**: Marksmen can only shoot if clear LOS (no shooting through walls)
- **Telegraph**: Electronic targeting beep 0.8s before shot, red laser sight visible
- **Counterplay**: Solid cover blocks 100% damage. Move between cover during telegraph.

### Boss: Riot Commander
- **Fixed state machine** (no randomness):
  1. Shield bash (0.5s telegraph, 20 damage, knockback)
  2. Frontal shield block (60% damage reduction, 90-degree cone)
  3. Tear gas (area denial, 5 damage/second in cloud, lasts 10 seconds)
  4. Enraged (at 50% health: attack speed +50%, defense -25%)
- **Weak point**: Back takes 2x damage (visual: shield doesn't cover back)
- **Telegraph hierarchy**: All attacks 1.0-1.5s windup (readable, avoidable)

### Arena Design
- **Cover system**: 50% of arena has solid cover (sandbags, wrecks, barriers)
- **Destructible cover**: Some cover breaks after 3-4 hits (forces movement)
- **Throwable objects**: 5-10 environmental weapons (pipes, signs, fuel canisters)

---

## Phase 8: First Joint Mission

**Original**: `prompts/phase_08_first_contact.md`

**Add These Requirements**:

### Elena Follower
- **Waypoint system**: Elena follows authored Path2D, not dynamic pathfinding (more reliable)
- **Safe points**: Named waypoints where Elena waits ("Elena_Wait_1", "Elena_Wait_2", etc.)
- **Never in combat**: Elena teleports to next safe point if Marcus dies (no softlock)
- **Proximity warning**: If enemy gets within 100px of Elena, HUD shows "PROTECT ELENA" warning

### Elena Safety System
- **Decrement events** (only these, not random):
  1. Enemy crosses protected boundary and reaches Elena
  2. Scripted threat (falling debris, explosion) targets Elena
  3. Player choice (sacrifice Elena to save civilians—rare, story-driven)
- **Visual**: Heart icon with number (3→2→1→0), color-coded (green→yellow→orange→red)
- **Narrative impact**: Low Elena Safety changes dialogue, ending conditions

### Dialogue Sequence
- **First contact**:
  - Marcus: "I'm not here to hurt you."
  - Elena: "You're Helix. That's exactly what you're here for."
  - Marcus (quiet): "Yeah. That's what I was trained to be. Not anymore."
- **Mid-mission**:
  - Elena: "Why help me?"
  - Marcus: "Because I've seen what Helix does to people like you."
  - Elena: "People like me?"
  - Marcus: "People who think data matters more than control."
- **Exit sequence**:
  - Marcus: "Temporary truce. We escape together, then decide next steps."
  - Elena: "Agreed. But I choose when and where the protocol goes."
  - Marcus: "As long as it goes somewhere Helix can't reach immediately, we're fine."

---

## Phase 9: Calibrate Aster Minigame

**Original**: `prompts/phase_09_calibrate_aster.md`

**Add These Requirements**:

### Circuit Puzzle
- **6 rotatable tiles**: Each has 4 orientations (0°, 90°, 180°, 270°)
- **Fixed solution**: One correct configuration (no randomization)
- **Visual feedback**: Powered segments glow cyan, unpowered segments gray
- **Hint system**: 3 charges, each highlights one incorrect tile (doesn't auto-fix)

### UI/UX
- **Accessibility**: Works with mouse, keyboard (arrow keys), controller (D-pad)
- **Zoom**: Can zoom in/out on circuit board (75%-150%)
- **Undo**: Can undo last 3 rotations before confirming

### Narrative Reveal
- **On completion**:
  - Elena: "Aster has identified a relay station. Mountain range, atmospheric equipment."
  - Marcus: "Final Thaw Station. Sounds like their endgame."
  - Elena: "Helix isn't just deploying Aster. They're deploying it selectively."
  - Marcus: "Protected zones for the privileged. Everyone else burns."
  - Elena: "Then we make sure everyone gets the cure. Not just the chosen few."

---

## Phase 10: Collapsing Dam Puzzles

**Original**: `prompts/phase_10_collapsing_dam.md`

**Add These Requirements**:

### Water System Enhancements
- **Cycle indicator**: Visible UI element showing water level cycle (0-100%, 10-second loop)
- **Safe windows**: 4-5 seconds per cycle where water is low enough to pass
- **No frame-perfect**: All jumps have 2-3 second windows

### Power Routing
- **Color-coded**: Red = emergency, blue = life support, yellow = machinery, green = safety
- **Load management**: Too many devices = overload, 2-second blackout, reset required
- **Visual**: Overloaded wires glow orange, spark. Correct routing = steady blue pulse

### Aster Calibration
- **3 charges**: Can calibrate 3 obstacles per level (limited resource)
- **Visual**: Calibration creates safe path through hazard (blue energy bridge)
- **Saved**: `aster_calibrations_used: int` tracked in GameManager

### Hazards
- **Falling debris**: Telegraphed 1.0s (shadow appears, then debris falls)
- **Steam vents**: Telegraphed 0.5s (hissing sound, then steam erupts)
- **Electrical danger**: Telegraphed 0.8s (sparks, then arc)

---

## Phase 11: Port Mutiny Combat

**Original**: `prompts/phase_11_port_mutiny.md`

**Add These Requirements**:

### Shield Enemy
- **Frontal immunity**: 90% damage reduction from front (not 100%, allows chip damage)
- **Slow movement**: 150px/s (vs. 250px/s for Scavenger)
- **Shield bash telegraph**: 1.0s windup (shield pulls back, then lunges)
- **Counterplay**:
  - Flank: 2x damage from behind (visual: back glows red)
  - Grab/bypass: Can grab and throw (stuns for 3 seconds)
  - Environment: Throwable objects stun for 2 seconds

### Boss: Transport Captain
- **Fixed moves**:
  1. Ground slam (1.0s telegraph, avoidable shockwave, 25 damage)
  2. Cargo throw (1.5s telegraph, throws random object, 20 damage)
  3. Reinforcement call (2.0s cast, spawns 2 Scavengers)
- **Crane interaction**:
  - Operable during 5-second window (after boss slams ground)
  - Drops cargo on boss: 50 damage + 5-second stun
  - Optional: Boss beatable without crane, but crane makes it much easier

### Civilian Rescues
- **2-3 optional rescues**: Each increments Civilian Aid, persists after save/load
- **Dynamic epilogue**: Rescued civilians appear in epilogue (thriving community, Marcus's name on memorial)
- **If NOT rescued**: Epilogue shows abandoned port, graffiti: "Helix left us. So did Reyes."

---

## Phase 12: Transit Hub Joint Mission

**Original**: `prompts/phase_12_free_switching.md`

**Add These Requirements**:

### Character Switching
- **<100ms swap time**: Instant transition, no loading
- **Inactive character**: Frozen, invulnerable, subtle idle animation (breathing, scanning)
- **Contextual lockout**: Can't switch during scripted sequences, mid-air, or combat arenas (clear UI feedback: "Cannot switch now")
- **Emotional progression**:
  - Early game: 2-second cooldown (hesitation, distrust)
  - Late game: Instant swap (full trust, seamless)

### Room 1: Security Terminal
- **Elena**: Timed interaction (10 seconds to hack terminal)
- **Marcus**: Defend against 3 waves of enemies (2 Scavengers per wave)
- **Synergy**: Elena can't complete if Marcus dies. Marcus can't progress if Elena doesn't hack.

### Room 2: Heavy Object
- **Marcus**: Pushes heavy crate to create access (5-second push animation)
- **Elena**: Powers lift to raise crate (terminal interaction)
- **Synergy**: Both must act within 3 seconds of each other (coordination test)

### Room 3: Lighting Stealth
- **Elena**: Controls lighting (3 switches: off, dim, bright)
- **Marcus**: Stealth takedowns on unaware enemies (instant kill from behind)
- **Light immunity**: Enemies with flashlights immune to stealth (must turn off lights first)
- **Synergy**: Elena creates darkness, Marcus exploits it

### Evidence Choice
- **Binary, saved choice**:
  - Preserve evidence: `evidence_choice: "preserve"`. Delays activation, exposes Helix conspiracy.
  - Erase evidence: `evidence_choice: "erase"`. Immediate activation, Helix controls narrative.
- **Narrative weight**:
  - Elena: "If we preserve this, we expose them. But people die while we argue."
  - Marcus: "If we erase it, Helix owns the story. But the protocol deploys now."
  - Player choice: No "correct" answer—both have valid points

---

## Phase 13: Final Thaw Station Level

**Original**: `prompts/phase_13_final_thaw_station.md`

**Add These Requirements**:

### Weather Stages
- **Light snow**: 25% particle density, minimal mechanical effect
- **Blizzard**: 50% density, visibility -25%, movement speed -10%
- **Extreme storm**: 100% density, visibility -50%, movement speed -20%
- **Accessibility**: Option to reduce weather intensity by 75% (no mechanical penalty)

### Sections (5-6 total)
1. **Security surveillance**: Disable cameras while avoiding patrol (stealth + combat)
2. **Power reroute**: Route power to doors/elevators while defending against waves
3. **Barricade clearing**: Break through 3 barricades while under fire (combat + environmental destruction)
4. **Atmospheric calibration**: Use Aster charges to stabilize weather equipment (puzzle + combat)
5. **Rapid switching**: Elena stabilizes system while Marcus prevents sabotage waves (coordination climax)
6. **Optional rescues**: 3-4 researchers to rescue/equipment to repair (increments Civilian Aid or opens shortcuts)

### Evidence Discovery
- **Final explicit choice** (overwrites Phase 12 preliminary intention):
  - Discover Helix engineered earlier Aster test failure
  - Choice: Publicly expose (delay deployment) or immediately activate (let Helix control narrative)
  - Impact: Determines which endings are available (Public Thaw requires exposure)

---

## Phase 14: Final Boss Battle

**Original**: `prompts/phase_14_final_boss.md`

**Add These Requirements**:

### Boss: Helix Commander (Dr. Selene Voss)

**Fixed State Machine** (no randomness):
1. **Energy blast** (1.0s telegraph, dodgeable, 30 damage)
2. **Shield barrier** (2.0s cast, 10-second invulnerability, breakable with 100 damage)
3. **Reinforcement call** (2.0s cast, spawns 2 Scavengers or 1 Enforcer)
4. **Reactor sabotage** (1.5s telegraph, Elena must counter-calibrate or reactor explodes for 50 damage)

### Elena Calibration Interactions
- **3 panels**: Each requires 5-second calibration (visible progress bar)
- **Interruption**: If Marcus doesn't protect Elena, calibration resets
- **Reward**: Each calibration creates 10-second boss vulnerability window

### Vulnerability Windows
- **During vulnerability**: Boss takes 3x damage, no shield, no counter-attacks
- **Outside vulnerability**: Boss has 75% damage reduction, shield active
- **Visual**: Boss glows red during vulnerability (clear feedback)

### Final Phase
- **Elena**: Maintain reactor balance (repeated QTE: press interact when bar in green zone)
- **Marcus**: Stop boss pressure (attack boss, defeat reinforcements)
- **Duration**: 60 seconds (generous, most players finish in 40-50s)
- **Failure**: Reactor explodes, retry from checkpoint (no game over)

### Environmental Actions (Optional)
- **Vent steam**: 10-second cooldown, stuns boss for 3 seconds
- **Overload panel**: 3 charges, deals 25 damage to boss
- **Visual availability**: Both have clear UI indicators (not hidden)

---

## Phase 15: Epilogue and Endings

**Original**: `prompts/phase_15_epilogue.md`

**Add These Requirements**:

### Ending Rules (Exact Thresholds)

```gdscript
# Priority 1: Fragile Thaw
if elena_safety <= 1 or prototype_integrity <= 1:
    ending = "fragile_thaw"

# Priority 2: Public Thaw
elif civilian_aid >= 4 and prototype_integrity >= 2 and evidence_choice == "preserve":
    ending = "public_thaw"

# Priority 3: Guarded Thaw (default)
else:
    ending = "guarded_thaw"
```

### Cinematics (90+ seconds each, fully voiced)

**Public Thaw**:
- Earth recovering, Helix disbanded, Aster public domain
- Elena at Iris's grave: "It's done. The protocol is free. You would have loved this world."
- Marcus at police memorial: "I'm not that person anymore. I hope you can forgive me."
- Final shot: Elena and Marcus on mountain, watching sunrise
- Text: "The climate stabilized over 17 years. Recovery was not easy. But it was possible."

**Guarded Thaw**:
- Split screen: Protected zones thrive, outside struggle
- Helix controls access, resistance forms
- Elena in lab: "I saved the climate. But not everyone."
- Marcus training resistance: "They control the cure. We take it back."
- Text: "The climate stabilized. But access was controlled. Resistance formed within 3 years. Elena Vast disappeared 6 months later."

**Fragile Thaw**:
- Incomplete stabilization, storms weaker but present
- Communities adapting, resilience montage
- Elena injured: "It's not enough. But it's something."
- Marcus distributing supplies: "We make do. We always have."
- Text: "The climate improved, but not enough. Recovery took 40 years. They became symbols—not of victory, but of persistence."

### Post-Credits Stinger
- Earth from space, 3 years later
- Helix logo crumbling worldwide
- News ticker: "Aster Protocol now open-source. 147 nations deploying."
- Young scientist: "Let's see what we can do better."

### Statistics Screen
- Civilians aided: X/10
- Elena Safety: X/3
- Prototype Integrity: X/3
- Evidence choice: Preserve/Erase
- Ending title: [Public/Guarded/Fragile] Thaw

---

## Phase 16: QA and Release

**Original**: `prompts/phase_16_qa_release.md`

**Add These Requirements**:

### QA Checklist (Comprehensive)

**Every menu**:
- [ ] Navigable with keyboard (Tab/Enter)
- [ ] Navigable with controller (D-pad/A)
- [ ] Focus indicators visible
- [ ] Screen reader can read all text

**Every level**:
- [ ] Completable without softlocks
- [ ] All puzzles solvable
- [ ] All enemies defeatable
- [ ] Checkpoints save/load correctly
- [ ] 60 FPS locked (profiler verification)

**Every enemy type**:
- [ ] Telegraphed attacks (0.5-1.5s windup)
- [ ] Punishable windows after attacks
- [ ] Hit reactions (flash, knockback, hitstun)
- [ ] Death animation plays correctly

**Every boss move**:
- [ ] Telegraph visible and readable
- [ ] Avoidable with dodge/block/movement
- [ ] Damage matches design (test with god mode off)
- [ ] Phase transitions at correct health thresholds

**Every minigame**:
- [ ] Solvable without hints
- [ ] Hint system works (3 charges)
- [ ] Timeout/failure handled gracefully
- [ ] Success/failure states save correctly

**Every character switch scenario**:
- [ ] Switch <100ms
- [ ] Inactive character invulnerable
- [ ] Contextual lockout works (can't switch mid-air, in combat)
- [ ] Camera follows active character smoothly

**All consequence counters**:
- [ ] Elena Safety changes only on defined events
- [ ] Prototype Integrity changes only on hazard events
- [ ] Civilian Aid increments once per rescue (not farmable)
- [ ] All counters save/load correctly

**All three endings**:
- [ ] Fragile Thaw triggers at elena_safety ≤1 OR prototype_integrity ≤1
- [ ] Public Thaw triggers at civilian_aid ≥4 AND prototype_integrity ≥2 AND evidence=preserve
- [ ] Guarded Thaw triggers as default
- [ ] All cinematics play fully (90+ seconds)
- [ ] Post-credits stinger plays after all endings

**Exported builds**:
- [ ] Windows executable runs without errors
- [ ] Controls work (keyboard, mouse, controller)
- [ ] Performance matches editor (60 FPS, <2s loads)
- [ ] No debug tools accessible (password-protected only)

### Accessibility Testing

**Test with actual disabled gamers**:
- [ ] Colorblind players can distinguish all hazards, enemies, interactables
- [ ] Motor-impaired players can complete all sections (with accessibility options)
- [ ] Hearing-impaired players can access all story information (visual cues, subtitles)
- [ ] Cognitive-impaired players can navigate puzzles (hints, extended time)

### Performance Targets

| Platform | Resolution | FPS | Load Time | Status |
|----------|------------|-----|-----------|--------|
| Minimum (GTX 1060) | 1080p | 60 locked | <3s | [ ] |
| Recommended (RTX 3060) | 1440p | 60 locked | <2s | [ ] |
| High-end (RTX 4070+) | 4K | 60 locked | <1s | [ ] |
| Steam Deck | 800p | 60 locked | <3s | [ ] |

### Release Checklist

- [ ] Version 1.0.0 tagged in Git
- [ ] All known issues documented in docs/known_issues.md
- [ ] Store assets prepared (screenshots, trailer, description)
- [ ] Content warnings reviewed (violence, themes of climate collapse, character death)
- [ ] License decided and added to README (recommend MIT or CC BY-NC-SA)
- [ ] Credits complete (team, advisors, voice actors, testers)
- [ ] Website/press kit prepared
- [ ] Award submissions ready (The Game Awards, D.I.C.E., BAFTA, GDC)

---

## How to Use This Document

1. **For each phase (4-16)**:
   - Copy the original prompt (e.g., `phase_04_highway_riots.md`)
   - Copy the enhancement section for that phase from this document
   - Paste BOTH into Claude Code (original + enhancements)

2. **Test thoroughly**:
   - Run all acceptance criteria from original prompt
   - Verify all enhancements are implemented
   - Document any deviations or limitations

3. **Commit with enhanced message**:
   - Example for Phase 4:
   ```
   Phase 4: highway riots combat complete
   
   Award-level combat with:
   - 4 arenas with escalating difficulty (Scavengers → Enforcers → mixed)
   - Style meter (D→S rating) for performance feedback
   - Enemy Enforcer with block/counter pattern, flank weakness
   - Breakable barricades, environmental throws, fuel canister AoE
   - Arena skip option after 3 deaths (accessibility)
   - 60 FPS locked with enemy pooling
   
   All acceptance criteria PASS. Ready for Phase 5.
   ```

---

## Success Criteria

**Phase is award-worthy when**:
- Playtesters report "this feels as good as [AAA reference]"
- No complaints about unfair difficulty, randomness, or softlocks
- Accessibility options allow all players to experience full story
- Performance matches targets (60 FPS, fast loads)
- Critics specifically praise this section in reviews

**This is the standard. Nothing less.**
