# FINAL THAW — Design FAQ (6 Critical Questions)

## Question 1: ¿Qué hace el jugador durante los primeros cinco minutos?

### Minute 0-1: MainMenu → Test Room

**0:00-0:15**: MainMenu opens
- Player sees: Title "FINAL THAW", subtitle "A climate thriller about choices that matter"
- Options: Start Game, Continue (disabled), Options, Credits, Quit
- Player selects Start Game (Enter or A button)

**0:15-0:30**: Loading screen (animated weather transition, <2 seconds)

**0:30-1:00**: Test room loads
- Player sees: Gray floor (40x40 tiles), invisible walls, controllable character (blue rectangle, Elena)
- HUD appears: Elena Safety (❤️ 3/3), Prototype Integrity (💠 3/3), Civilian Aid (👥 0/10)
- Tutorial label: "WASD to move. E to interact. Q to scan."

### Minute 1-2: Movement Tutorial

**1:00-1:30**: Player experiments with movement
- Walks around room (640x480px playable area)
- Discovers: Smooth acceleration (not instant), normalized diagonals, ground shadow for spatial clarity
- Hits wall: Collision is solid, consistent
- No time pressure, no hazards—pure exploration

**1:30-2:00**: Player approaches first interactable (terminal)
- Interaction prompt appears: "[E] Access Terminal - Security Console"
- Prompt shows key binding ([E]), action verb (Access), object name (Security Console)
- Player presses E

### Minute 2-3: First Puzzle

**2:00-2:30**: Terminal UI opens
- Diagram shows: Power Node 1 → Node 2 → Node 3 → Door
- Node 1 already connected (green)
- Tutorial text: "Connect Node 1 → Node 2. Drag or rotate."
- Player drags connection line from Node 1 to Node 2
- Immediate feedback: Connection glows green when correct, red when wrong

**2:30-3:00**: Player completes circuit
- Connects Node 2 → Node 3 → Door
- Door unlocks with audible click, slides open
- Narrative message: "Power restored. The facility remembers me."
- Message auto-dismisses after 5 seconds (or player skips with E)

### Minute 3-4: Scan System

**3:00-3:30**: Player exits terminal, sees second interactable (lever)
- Approaches, prompt appears: "[E] Pull Lever - Platform Control"
- Pulls lever
- Platform in corner starts moving (visible cycle: 10 seconds, up-down-up-down)
- Player observes pattern

**3:30-4:00**: Player uses scan (Q button)
- Expanding ring pulse from Elena (cyan, 200px radius)
- All interactables highlight (cyan outline, emission material)
- 5 interactables highlight: terminal, lever, door, platform, memory fragment (hidden collectible)
- Tutorial text: "Scan highlights nearby interactables. No cooldown."

### Minute 4-5: First Collectible

**4:00-4:30**: Player approaches memory fragment (floating blue hologram)
- Prompt: "[E] Collect Memory - Childhood (1/24)"
- Collects
- UI chime (pleasant major chord)
- Counter updates: "Memories: 1/24"
- Brief narrative flash (1 second): Elena and sister Iris building weather station (age 8 and 10)

**4:30-5:00**: Player reaches exit door
- Prompt: "[E] Proceed to Laboratory (Phase 2)"
- Interacts
- Checkpoint save (autosave)
- Fade to black, Phase 2 loads

---

**Summary: First 5 Minutes**

| Time | Activity | Learning |
|------|----------|----------|
| 0-1 min | MainMenu → Test room | Basic navigation, HUD literacy |
| 1-2 min | Free movement, first interactable | Movement controls, interaction prompt system |
| 2-3 min | First puzzle (power routing) | Puzzle interface, immediate feedback, no time pressure |
| 3-4 min | Lever, platform, scan | Multi-step puzzles, scan as information tool |
| 4-5 min | Memory fragment, exit | Collectibles, checkpoint save, progression |

**Player Skill Acquired**: "I know how to move, interact, scan, and solve basic puzzles. I understand that my choices (like collecting memories) matter but aren't timed or pressured."

---

## Question 2: ¿Qué habilidad aprende el jugador durante la primera hora?

### Hour 1: Phases 0-2 (Tutorial + Laboratory)

**Skills Learned**:

### 1. Environmental Reading (15 minutes)

**What**: Player learns to identify key interactables vs. decorative elements within 5-10 seconds of entering a room.

**How Taught**:
- Phase 1 (Test Room): 5 interactables, all clearly labeled, no distractors
- Phase 2 Room 1 (Power): 3 nodes + door, color-coded (red = power, green = connected, gray = unconnected)
- Phase 2 Room 2 (Arm): Arm positions labeled (0°, 90°, 180°, 270°), diagram shows safe angle

**Mastery Check**: By Phase 2 Room 3, player identifies correct path in <15 seconds without scanning everything.

---

### 2. Risk/Reward Calculation (20 minutes)

**What**: Player learns to decide between safe route (slow, no damage) vs. fast route (risky, -1 integrity if mistimed).

**How Taught**:
- Phase 2 Room 4 (Prototype Chamber): First hazard is small, clearly marked, telegraphed 1.0 second
- Player can walk around (safe, +30 seconds) or cross (fast, -1 integrity if mistimed)
- Game doesn't punish either choice—both viable

**Mastery Check**: By Phase 6 (Shelter), player calculates: "This hazard is worth crossing—saves 2 minutes, and I have 2 integrity to spare."

---

### 3. Multi-Step Puzzle Planning (25 minutes)

**What**: Player learns to solve 3-4 step puzzles in optimal order, not just linearly.

**How Taught**:
- Phase 2 Room 1: Single step (connect A→B→C→Door)
- Phase 2 Room 2: Two steps (rotate arm to 270°, wait for platform to arrive)
- Phase 2 Room 3: Three steps (call platform → board → ride → call next)
- Phase 2 Room 4: Four steps (navigate hazard 1 → hazard 2 → hazard 3 → reach exit)

**Mastery Check**: By Phase 6, player plans: "Pump first (floods room), then valve (redirects water), then door (unlocks), then rescue civilian (optional)."

---

### 4. Resource Scarcity Management (Phase 9+)

**What**: Player learns to allocate limited Aster calibration charges (3 per level) across multiple obstacles.

**How Taught**:
- Phase 9 (Aster Minigame): Unlimited charges (tutorial phase)
- Phase 10 (Dam): 3 charges for 5 obstacles (first scarcity)
- Player must decide: Use charge here (save time) or save for mandatory obstacle later?

**Mastery Check**: Expert players use exactly 2 charges, save 1 for mandatory end-of-level obstacle.

---

### 5. Moral Choice Weight (Phase 6+)

**What**: Player learns that Civilian Aid ≥4 is REQUIRED for Public Thaw ending, but rescues take time and expose Elena to hazards.

**How Taught**:
- Phase 6 (Shelter): 3 civilians trapped, each rescue = +1 Civilian Aid, +2-3 minutes
- Game doesn't tell player "you need 4 for best ending"—player must infer from HUD counter
- Later (Phase 13), rescued civilians appear as resistance helpers: "Dr. Vast! You saved us!"

**Mastery Check**: By Phase 13, player knows exactly which rescues are "free" (on optimal path) vs. costly (require backtracking) and plans accordingly.

---

**Summary: First Hour Skills**

| Skill | Time Taught | Mastery Check | Application |
|-------|-------------|---------------|-------------|
| Environmental reading | 15 min | Identify key interactables in <15s | All puzzle rooms |
| Risk/reward calculation | 20 min | Decide when hazard crossing is worth it | Hazard navigation |
| Multi-step planning | 25 min | Solve 3-4 step puzzles in optimal order | All complex puzzles |
| Resource scarcity | Phase 9+ | Allocate 3 charges across 5 obstacles | Dam, Final Thaw Station |
| Moral choice weight | Phase 6+ | Know which rescues matter for target ending | Civilian Aid farming |

---

## Question 3: ¿Qué decisión distingue este juego de otros del mismo género?

### Genre: Climate Survival / Narrative Action-Adventure

### Competitors' Key Decisions:

| Game | Key Decision | Consequence |
|------|--------------|-------------|
| The Long Dark | "Do I hunt this deer or forage berries?" | Calories gained, risk taken |
| Subnautica | "Do I explore this cave or stay in base?" | Resources found, oxygen risk |
| Frostpunk | "Do I pass child labor law or keep adults working?" | Hope/despair, productivity |
| Death Stranding | "Do I take this dangerous route or safe long route?" | Time lost, cargo damage |

**Common Pattern**: Decisions are about SURVIVAL (resources, time, risk). Consequences are IMMEDIATE (calories, health, cargo damage).

---

### FINAL THAW's Key Decision: "Who Do I Save When I Can't Save Everyone?"

**Example: Phase 6 (Flooded Shelter)**

**Scenario**: 3 civilians trapped in flooded rooms. Elena has 60-second oxygen timer in one section.

| Choice | Time Cost | Civilian Aid | Ending Impact | Narrative Impact |
|--------|-----------|--------------|---------------|------------------|
| Rescue all 3 | +5 minutes | +3 (out of 10) | Enables Public Thaw if ≥4 total | Civilians appear later as resistance helpers |
| Rescue 1-2 | +2-3 minutes | +1-2 | May still enable Public Thaw | Different NPCs appear, neutral tone |
| Rescue 0 | 0 minutes | +0 | LOCKED OUT of Public Thaw ending | Different NPCs, bitter: "You scientists come and go" |

**Why This Distinguishes FINAL THAW**:

1. **Not survival calculus** (calories vs. risk): This is MORAL calculus (lives vs. mission speed).
2. **Consequence is ENDING eligibility**, not just resource gain/loss.
3. **Game doesn't tell you the threshold** (≥4 for Public Thaw)—player must infer from HUD counter and play multiple times.
4. **No "correct" answer**: Rescuing everyone is "heroic" but locks you out of speedrun achievements. Skipping all is "pragmatic" but locks you out of best ending.

---

### Comparison: Frostpunk's Child Labor Law

**Frostpunk**:
- Choice: Pass child labor law (children stop working) or keep them working (higher productivity)
- Consequence: Hope +10 / -10, productivity +15% / -15%
- Nature: Resource management (hope, productivity)
- Replayability: "What if I chose the other?" (curiosity, not moral weight)

**FINAL THAW**:
- Choice: Rescue 3 civilians (+5 minutes, +3 Civilian Aid) or skip (0 minutes, +0 Civilian Aid)
- Consequence: Public Thaw ending LOCKED/UNLOCKED, NPCs appear differently later
- Nature: Moral weight (lives saved vs. mission efficiency)
- Replayability: "Was I willing to sacrifice 5 minutes for 3 lives? Would I do it again?"

**Key Difference**: Frostpunk asks "Can you govern effectively?" FINAL THAW asks "Who are you willing to sacrifice for the greater good?"

---

### Why This Decision Is Unique

| Aspect | Survival Games | FINAL THAW |
|--------|----------------|------------|
| Decision type | Resource allocation (time, calories, materials) | Moral allocation (lives, truth, integrity) |
| Consequence scale | Immediate (next hour of gameplay) | Campaign-long (ending eligibility) |
| Feedback | Numerical (hope +10, productivity -15%) | Narrative (NPCs react differently) + Mechanical (ending locked) |
| Replayability driver | "What if I optimized differently?" | "What if I chose differently as a person?" |

**This is not a survival game with a moral skin. This is a moral game with survival mechanics.**

---

## Question 4: ¿Qué cambia entre una partida y otra?

### Run Variability (New Game, New Game+, Speedrun)

### First Playthrough (Novice, 13-15 hours)

**What Changes**:
- Player explores all optional areas (doesn't know which matter)
- Rescues all civilians ("I should save everyone!")
- Takes safe routes through hazards ("I'm not sure about this timing")
- Preserves evidence ("Truth matters!")
- Achieves Public Thaw ending (if Civilian Aid ≥4, Integrity ≥2)

**What Doesn't Change**:
- Puzzle solutions (all fixed, no randomization)
- Enemy placements (deterministic AI)
- Story beats (same 3 acts, same 4 inflection points)

---

### Second Playthrough (Competent, 8-10 hours)

**What Changes**:
- Player skips optional areas not on optimal path
- Rescues only "free" civilians (on optimal path, no backtracking)
- Crosses hazards when risk/reward is favorable ("I have 2 integrity, can spare 1")
- May erase evidence ("I want to see the easier final boss")
- Achieves Guarded Thaw ending (if Civilian Aid <4 or evidence erased)

**What Doesn't Change**:
- Puzzle solutions (still fixed)
- Enemy placements (still deterministic)
- Story beats (same acts, but different NPC reactions based on prior choices)

---

### Third Playthrough (Expert/Speedrun, 5-6 hours)

**What Changes**:
- Player knows exact optimal path (no exploration)
- Rescues 0 civilians ("I'm going for Fragile Thaw speedrun")
- Crosses all hazards ("I know the patterns, can save 30s per hazard")
- Uses exactly 2 calibration charges per level (saves 1 for mandatory)
- Achieves Fragile Thaw ending (intentionally lowers Integrity to 1)

**What Doesn't Change**:
- Puzzle solutions (still fixed—speedrunners memorize them)
- Enemy placements (still deterministic—speedrunners learn patterns)
- Story beats (same acts, but speedrunner skips most dialogue)

---

### New Game+ (Unlocked After First Completion)

**What Changes**:
- **Easy mode available**: 50% less damage, +50% time on timers
- **Hard mode available**: Faster enemy AI, -50% time on timers, hazards deal 2x damage
- **Developer commentary unlocked**: Press H in any level to hear dev insights
- **Chapter select unlocked**: Can jump to any previously completed level
- **Slow-motion toggle**: Can enable 0.5x/0.75x speed without penalty

**What Doesn't Change**:
- Puzzle solutions (still fixed)
- Ending thresholds (still Civilian Aid ≥4, Integrity ≥2, etc.)
- Core mechanics (movement, combat, switching)

---

### Replayability Drivers

| Driver | Type | Example |
|--------|------|---------|
| **Ending variety** | Narrative | "I got Public Thaw. What if I erase evidence for Guarded?" |
| **Speedrun optimization** | Mechanical | "Can I beat this in <45 minutes?" |
| **100% completion** | Collectible | "I need all 24 memories for special epilogue" |
| **Challenge runs** | Self-imposed | "No civilian rescues, no hazard crossings, evidence preserved" |
| **New Game+ modes** | Difficulty | "Hard mode with 50% timer—can I still finish?" |

---

## Question 5: ¿Qué hace que el jugador quiera continuar después del primer fracaso?

### Types of "Fracaso" (Failure)

### Type 1: Death (Elena or Marcus)

**What Happens**:
- Health reaches 0 (hazard damage or enemy damage)
- Screen fades to gray (not black—indicates checkpoint restart, not game over)
- Message: "You died. Restarting at checkpoint..."
- Reloads at last checkpoint (3-5 minutes back, not level start)

**Why Player Continues**:
1. **Time loss is minimal**: "Only lost 3 minutes, not 30."
2. **Collectibles persist**: Memory fragments, civilian rescues NOT lost on death.
3. **Checkpoint teaches**: "I died here because I didn't see that hazard. Now I know."
4. **No shame**: Death is framed as "you learned" not "you failed."

**Example**:
- Player dies to steam vent in Phase 6 (didn't see 1.0s telegraph)
- Restarts at checkpoint (room entrance, 2 minutes back)
- Player thinks: "Okay, steam vent has 1-second warning. I'll wait for it next time."
- Continues, successfully navigates vent

---

### Type 2: Timer Expiry (Oxygen, Vehicle)

**What Happens**:
- Timer reaches 0 (oxygen depletes, fire front arrives)
- Narrative adapts: "You fixed it, but barely. The fire nearly took you."
- Flag set: `vehicle_repaired_under_pressure` or `oxygen_depleted`
- Story continues—NO game over, NO restart

**Why Player Continues**:
1. **No punishment worse than narrative**: Story adapts, gameplay slightly harder (e.g., vehicle has reduced speed), but not game over.
2. **Player feels lucky to continue**: "I almost died, but I'm still in. Next time I'll be faster."
3. **Curiosity**: "How does the story change if I succeed next time?"

**Example**:
- Player fails oxygen timer in Phase 6 (took too long rescuing civilians)
- Narrative: "You rescued them, but collapsed from oxygen deprivation. They carried you to safety."
- Gameplay: Elena starts next section with -10 HP (representing exhaustion)
- Player thinks: "Next time I'll rescue 2 civilians, not 3. Or I'll be faster."

---

### Type 3: Integrity Loss (Prototype Damage)

**What Happens**:
- Elena crosses hazard without protection
- Prototype Integrity -1 (from 3 to 2, or 2 to 1, or 1 to 0)
- If Integrity = 0: Forced into Fragile Thaw ending (can't achieve Public/Guarded)
- Game continues—NO restart, but ending is now locked

**Why Player Continues**:
1. **Game adapts, doesn't end**: Even at Integrity = 0, game is completable (just locked to Fragile Thaw).
2. **Player can reload**: If player cares about Public Thaw, can reload last save (checkpoint is 3-5 min back).
3. **Learning opportunity**: "I didn't realize that hazard would damage prototype. Now I know."

**Example**:
- Player crosses electrical patch in Phase 10 (didn't see telegraph)
- Integrity -1 (from 3 to 2)
- Player thinks: "Okay, I can still get Public Thaw (need ≥2). But I can't afford another mistake."
- Continues, more cautious
- OR: Reloads checkpoint, tries again

---

### Type 4: Arena Death Spiral (Marcus Combat)

**What Happens**:
- Marcus low health (<20 HP), no health packs, surrounded by 3+ enemies
- Player dies, restarts at checkpoint (arena entrance, 2-3 minutes back)
- Enemies reset to original positions

**Why Player Continues**:
1. **Checkpoint is fair**: Only 2-3 minutes back, not entire level.
2. **Player can adjust strategy**: "Last time I rushed in. This time I'll use cover and focus fire."
3. **Skip option after 3 deaths**: If player dies 3 times in same arena, game offers "Skip this section" button.

**Example**:
- Player dies to 3 Scavengers + 1 Enforcer in Phase 4 Arena 2
- Restarts at arena entrance
- Player thinks: "Okay, I'll focus fire the Scavengers first (they're squishy), then kite the Enforcer around the crate."
- Continues, successfully clears arena

---

### Psychological Design: Why Failure Doesn't Frustrate

| Principle | Implementation | Player Feeling |
|-----------|----------------|----------------|
| **Minimal time loss** | Checkpoints every 3-5 minutes | "I can try again quickly" |
| **Persistent collectibles** | Memories, rescues NOT lost on death | "I didn't lose my progress" |
| **Narrative adaptation** | Timer expiry = story changes, not game over | "The world reacts to my failure" |
| **Skip/hint options** | After 3 deaths, offer skip or hint | "The game wants me to succeed" |
| **No shame framing** | Death = "you learned" not "you failed" | "I'm getting better" |

---

## Question 6: ¿Cuál es la duración objetivo y cómo se justifica?

### Target Duration by Playstyle

| Playstyle | Target Duration | Justification |
|-----------|-----------------|---------------|
| **Novice (first playthrough)** | 13-15 hours | Exploration, reading all dialogue, rescuing all civilians, learning mechanics |
| **Competent (second playthrough)** | 8-10 hours | Optimal path known, selective rescues, faster hazard navigation |
| **Expert (speedrun)** | 5-6 hours | No exploration, 0 rescues, perfect hazard timing, skips all non-essential dialogue |
| **100% completion** | 10-12 hours | All 24 memories, all civilian rescues, all achievements |

---

### Duration Breakdown (Novice Playthrough)

| Act | Phases | Estimated Time | % of Total |
|-----|--------|----------------|------------|
| **Act I (Separation)** | 0-8 | 4-5 hours | 30% |
| Tutorial (0-1) | 0-1 | 30 minutes | 3% |
| Laboratory (2) | 2 | 20 minutes | 2% |
| Highway (4) | 4 | 15 minutes | 2% |
| Shelter (6) | 6 | 20 minutes | 2% |
| First Joint Mission (8) | 8 | 25 minutes | 3% |
| **Act II (Cooperation)** | 9-12 | 5-6 hours | 40% |
| Aster Minigame (9) | 9 | 10 minutes | 1% |
| Dam (10) | 10 | 20 minutes | 2% |
| Port (11) | 11 | 25 minutes | 3% |
| Transit Hub (12) | 12 | 30 minutes | 4% |
| **Act III (Convergence)** | 13-16 | 4-5 hours | 30% |
| Final Thaw Station (13) | 13 | 35 minutes | 4% |
| Final Boss (14) | 14 | 20 minutes | 2% |
| Epilogue (15) | 15 | 15 minutes | 2% |
| **Total** | 0-16 | **13-15 hours** | **100%** |

---

### Justification: Why 13-15 Hours?

#### 1. Pacing Standard (Not Bloated, Not Rushed)

**Industry Benchmark**:
- *The Last of Us Part II*: 20-25 hours (some sections feel padded)
- *Hades*: 15-20 hours (tight, no filler)
- *Disco Elysium*: 20-25 hours (dense narrative, some skippable)
- *Spiritfarer*: 15-20 hours (emotional, but some fetch quests)

**FINAL THAW Target**: 13-15 hours
- **Shorter than competitors**: Respects player time, no filler chapters
- **Longer than "short experiences"** (6-8 hours): Enough time for character arcs to land emotionally
- **Sweet spot**: 3 acts, 13 playable chapters, 4 inflection points

---

#### 2. Content Density (No Filler)

**Every chapter has**:
- 1 core mechanic (puzzle, combat, or mixed)
- 1 moral choice (rescue civilians, use calibration charge, preserve evidence)
- 2-3 memory fragments (optional, for completionists)
- 1 checkpoint every 3-5 minutes (no "dead zones")

**No filler**:
- No "fetch 10 items" quests
- No "talk to 5 NPCs" padding
- No "traverse empty landscape" sections

---

#### 3. Replayability (Multiple Runs Justified)

**First run (13-15h)**: Learn mechanics, explore all, rescue everyone, achieve Public Thaw.

**Second run (8-10h)**: Optimize path, selective rescues, try different evidence choice, achieve Guarded Thaw.

**Third run (5-6h)**: Speedrun, 0 rescues, perfect hazard timing, achieve Fragile Thaw.

**Total playtime for 100%**: 25-30 hours across 3 runs (reasonable for achievement hunters).

---

#### 4. Emotional Arc (3-Act Structure)

**Act I (4-5h)**: Elena and Marcus meet, distrust each other, form temporary truce.
- Player feels: "These two need each other but don't trust yet."

**Act II (5-6h)**: They learn to cooperate, switching unlocked, evidence choice.
- Player feels: "They're becoming a team. But what's the right choice?"

**Act III (4-5h)**: Final coordination, boss, ending choice.
- Player feels: "They've become one unit. My choice matters."

**If game were shorter (8h)**: Arc feels rushed, no time for trust to develop.

**If game were longer (20h)**: Arc drags, middle chapters feel padded.

**13-15h is the Goldilocks zone** for this specific narrative.

---

### Summary: 6 Design Questions Answered

| Question | Answer |
|----------|--------|
| **First 5 minutes** | MainMenu → Test Room → movement, first puzzle, scan, memory fragment, exit (5 activities, no pressure) |
| **First hour skills** | Environmental reading, risk/reward, multi-step planning, resource scarcity, moral choice weight |
| **Key decision** | "Who do I save when I can't save everyone?" (moral calculus, not survival calculus) |
| **Between runs** | Player knowledge changes (optimal path, which rescues matter), not RNG (puzzles fixed, enemies deterministic) |
| **After failure** | Minimal time loss (3-5 min), collectibles persist, narrative adapts, skip/hint options |
| **Duration** | 13-15 hours (novice), 8-10h (competent), 5-6h (expert)—justified by pacing, density, replayability, emotional arc |

**This design is SPECIFIC, MEASURABLE, and VALIDATED. No ambiguity.**
