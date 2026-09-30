# Guide: Updating Phase Prompts to Award-Level Standards

## Current Status

✅ **Updated**:
- Phase 0: `phase_00_technical_foundation_award.md`
- Phase 1: `phase_01_elena_movement_award.md`

⏳ **Remaining** (Phases 2-16):
- Need to add award-level standards to each
- Use this guide as template

---

## Universal Enhancements (Apply to ALL Phases)

### Header Addition
Add this to the top of every phase prompt:

```markdown
**AWARD-LEVEL TARGET**: This implementation must meet The Game Awards / D.I.C.E. / BAFTA standards. 60 FPS locked is non-negotiable. All accessibility features must be implemented from day one. This phase must feel as polished as [reference game: Hades/Celeste/Portal 2/The Last of Us].
```

### Performance Requirements
Add to every phase:

```markdown
## Performance Requirements
- **FPS**: 60 locked (use Godot profiler to verify)
- **Frame time**: <16.67ms per frame
- **Input latency**: <50ms (test with high-speed camera or input lag tester)
- **Memory**: <500MB RAM during gameplay
- **Load time**: <2 seconds between scenes
```

### Accessibility Requirements
Add to every phase:

```markdown
## Accessibility Requirements
- **Input**: All actions work with keyboard, controller, and remapped bindings
- **Visual**: All UI scalable 75%-200%, high contrast mode compatible
- **Audio**: Subtitle support for all dialogue/SFX, visual alternatives for audio cues
- **Motor**: No timing-critical inputs (<500ms windows), toggle/hold options
- **Cognitive**: Clear objectives, optional hints, no softlocks possible
```

### Testing Checklist
Add to every phase:

```markdown
## Testing Checklist
- [ ] 60 FPS maintained (profiler verification)
- [ ] No parser errors or runtime warnings
- [ ] All inputs work with keyboard AND controller
- [ ] Save/load preserves all state
- [ ] Accessibility options functional (scale, contrast, remap)
- [ ] No softlocks or progression blockers
- [ ] All acceptance criteria documented with PASS/FAIL evidence
```

---

## Phase-Specific Enhancements

### Phase 2: Abandoned Laboratory Puzzles

**Add to prompt**:

```markdown
## Award-Level Puzzle Design (Portal 2 Standard)

### Puzzle Structure
Each of 4 rooms must follow: **Teach → Test → Twist → Master**

**Room 1 (Power Restoration)**:
- Teach: Show terminal connection sequence (3 nodes, obvious path)
- Test: Player replicates sequence
- Twist: One node is broken, must reroute
- Master: Sequence must be done under time pressure (optional, +50% time accessibility)

**Room 2 (Robotic Arm)**:
- Teach: Arm cycles through 3 positions, only one allows passage
- Test: Player waits for correct position, moves through
- Twist: Arm malfunctions, cycles faster/slower unpredictably
- Master: Must activate button to call arm, time movement

**Room 3 (Moving Platform)**:
- Teach: Platform moves on fixed cycle, ride it across gap
- Twist: Platform stops mid-way, must call from other side
- Master: Platform has weight limit, must move quickly but not panic

**Room 4 (Prototype Calibration)**:
- Teach: Walk through hazard zones, prototype glows when damaged
- Test: Navigate 3 hazard zones without damage
- Twist: Hazards activate/deactivate on cycle, must time movement
- Master: Navigate while carrying prototype (slower movement)

### Puzzle Accessibility
- **Hints**: 3 charges per room, highlights next correct step
- **Undo**: Can reverse last 3 actions before committing
- **No softlocks**: Wrong input resets local mechanism only, not entire room
- **Visual feedback**: Correct connections glow blue, incorrect spark/fizzle immediately
- **Time limits**: Optional (+50% time accessibility setting)

### Narrative Integration
- Short skippable message on room entry (context, not exposition)
- Message on puzzle completion (progress, stakes)
- Final room reveals Helix conspiracy (partial transmission to Final Thaw Station)

### Testing
- [ ] All 4 rooms completable without developer intervention
- [ ] Puzzle solutions fixed, readable, deterministic (no randomness)
- [ ] Save/load in middle of puzzle works correctly
- [ ] Hint system functional, 3 charges regenerate on room reload
- [ ] 60 FPS maintained during puzzle solving
```

---

### Phase 3: Marcus Combat Fundamentals

**Add to prompt**:

```markdown
## Award-Level Combat (Hades + Devil May Cry Standard)

### Combat Flow
- **Combo system**: 3-hit base (Light→Light→Heavy launch)
- **Combo extensions**: Juggle with aerial attacks or environmental throws
- **Style meter**: D→C→B→A→S based on hit variety, environmental use, no-damage streaks
- **Perfect dodge**: 150ms window triggers slow-mo (2 seconds), guarantees counter
- **Parry**: Block within 200ms of impact = deflect, stagger, critical opportunity

### Enemy AI (Scavenger)
- **State machine**: Idle → Approach → Windup (0.5s telegraph) → Strike → Recovery (0.3s punishable) → Hitstun → Defeated
- **Flanking**: 3+ enemies automatically surround player
- **Telegraph**: Visible windup animation, audio cue (grunt/shout)
- **Adaptive**: If player kills quickly, enemies become cautious. If player passive, enemies become aggressive.

### Environmental Combat
- **Throwable objects**: 3 tiers (debris=10 dmg, crates=25 dmg, fuel canisters=40 dmg + AoE)
- **Wall splat**: Knock into wall = 1.5s stun + 15 damage
- **Ledge finisher**: Knock off platform = instant kill (small enemies) or major damage (large)

### Visual Feedback
- **Hit impact**: Screen shake (2-3 pixels), hit flash (100ms white), damage numbers (optional)
- **Enemy reactions**: Knockback on hit, stagger on heavy, launch on combo ender
- **Player reactions**: Hitstun animation, invincibility frames after hit (0.5s)

### Audio Feedback
- **Attack sounds**: Light = sharp crack, Heavy = deep thud
- **Enemy vocalizations**: Grunts on hit, shouts on attack, death cries
- **Combat music**: Adaptive layers (0-2 enemies = minimal, 3-5 = full percussion)

### Accessibility
- **Slow-mo mode**: 0.5x, 0.75x options (always available, no penalty)
- **Aim assist**: 0-100% slider for targeting
- **Reduced camera shake**: Toggle in options
- **Colorblind-safe**: Enemy telegraphs use animation + audio, not color alone

### Testing
- [ ] Marcus completes arena with all combat options (light, heavy, dodge, block, grab, throw)
- [ ] Enemy telegraphs readable, AI deterministic
- [ ] Hitbox system no double-dipping (one attack = one hit)
- [ ] Style meter functional, D→S progression clear
- [ ] 60 FPS maintained during combat (particles, screen shake, multiple enemies)
```

---

### Phase 8: First Joint Mission

**Add to prompt**:

```markdown
## Award-Level Escort Design (Last of Us Standard)

### Elena Follower AI
- **Pathfinding**: Authored waypoints (not dynamic NavAgent2D unless stable)
- **Safe routes**: Elena only moves on pre-approved paths, never wanders into combat
- **Waiting points**: Named safe zones where Elena waits for Marcus to clear arena
- **Stuck prevention**: If Elena pathfinding fails, teleport to Marcus after 5 seconds (with narrative excuse: "I'll catch up!")

### Arena Design
- **2-3 combat arenas**: Marcus fights, Elena stays at safe point
- **Protected terminals**: Elena operates terminal only after arena cleared
- **Gate events**: Marcus clears → Elena moves to terminal → Terminal opens gate → Both progress

### Elena Safety System
- **Default**: Enemies target Marcus only, Elena invulnerable at safe points
- **Exceptional proximity warning**: If enemy crosses defined boundary toward Elena:
  - HUD shows "Elena in danger!" with 3-second countdown
  - If enemy reaches Elena: Elena Safety -1 (max once per event)
  - Prevent multiple decrements from single event (1-second cooldown)

### Dialogue (Skippable, Non-Blocking)
- **First contact**: Elena distrustful ("You're Helix. Stay back."), Marcus explains ("Not anymore.")
- **Arena transitions**: Short exchanges building trust ("Why help me?" / "Because they lied to me too.")
- **Toxic rain exit**: Agreement to temporary truce ("We escape together, then decide.")

### Visual Storytelling
- **Toxic rain particles**: Stylized, readable (not obscuring gameplay)
- **Fade transition**: Act I complete, save checkpoint
- **HUD update**: Elena Safety counter explained at first display

### Testing
- [ ] Elena never stuck in normal gameplay
- [ ] Elena never attacked by spawned enemies (safe points work)
- [ ] Every arena/gate state replayable after death or save/load
- [ ] Elena Safety changes only through defined events (documented)
- [ ] Dialogue skippable, non-blocking during combat
- [ ] 60 FPS maintained during toxic rain sequence
```

---

### Phase 12: Transit Hub (Character Switching)

**Add to prompt**:

```markdown
## Award-Level Character Switching (It Takes Two Single-Player Standard)

### Switching Mechanics
- **Instant swap**: <100ms transition, no loading
- **Position lock**: Inactive character freezes, invulnerable, subtle idle animation (breathing, scanning)
- **Contextual lockout**: Cannot switch during scripted sequences, mid-air, or combat arenas (clear UI: "Cannot switch now")
- **Character cameras**: Elena = higher, wider FOV (puzzle readability). Marcus = lower, tighter FOV (combat intensity)

### Room 1: Security Terminal
- **Elena**: Timed terminal interaction (30 seconds, visible progress bar)
- **Marcus**: Protects from fixed waves (3-5 enemies, deterministic spawns)
- **Failure**: Timer resets (not game over), Elena says "Again!"
- **Success**: Security disabled, gate opens

### Room 2: Heavy Object + Lift
- **Marcus**: Moves heavy object (crate, boulder) to create access
  - Controlled movement (not physics-based, avoids softlocks)
  - Collision-safe (object doesn't get stuck in geometry)
- **Elena**: Powers lift after object moved
  - Terminal interaction, visible progress
  - Lift rises, both characters can proceed

### Room 3: Lighting + Stealth
- **Elena**: Controls lighting (terminal toggles lights on/off)
- **Marcus**: Stealth takedowns in darkness
  - Only works on unaware enemies (no lights)
  - Some enemies immune (have lights/radios)
  - Visual difference: Lights on = full visibility, lights off = darkness (Elena terminal highlighted)

### Narrative Dialogue
- **Growing respect**: "Your methods are crude, but effective." / "Your plans need someone to watch your back."
- **Core disagreement**: "If we deploy through Helix, we stabilise climate and hand them the queue." / "If we delay to expose them, people die while we argue."

### Evidence Choice (Binary, Saved)
- **Preserve evidence**: Delays activation, exposes Helix conspiracy
- **Erase evidence**: Prioritizes immediate activation, Helix controls narrative
- **Clear UI**: "Preserve Evidence" vs. "Erase Evidence" with consequences explained
- **Saved to GameManager**: `story_flags["evidence_choice"] = "preserve"` or `"erase"`

### Testing
- [ ] Switching never leaves character unusable, stuck, duplicated, or without camera
- [ ] Each room requires both protagonists meaningfully
- [ ] Security timer, heavy object, lighting, stealth all functional
- [ ] Narrative choice clear, saved correctly
- [ ] 60 FPS maintained during switching transitions
```

---

### Phase 13: Final Thaw Station

**Add to prompt**:

```markdown
## Award-Level Level Design (Longest Chapter, 20-35 Minutes)

### Level Structure (5-6 Sections)
1. **Security Surveillance + Patrol Combat**: Elena disables cameras, Marcus clears patrols
2. **Power Reroute + Defensive Encounter**: Elena reroutes power, Marcus defends from waves
3. **Barricade Clearing + Atmospheric Calibration**: Marcus breaks barricades, Elena calibrates atmosphere
4. **Rapid Switching Section**: Elena stabilizes system, Marcus prevents sabotage waves
5. **Optional Rescue Routes**: Researchers to save, equipment to repair (increments Civilian Aid or opens shortcut)
6. **Evidence Discovery + Final Choice**: See Helix engineered earlier Aster failure, choose preserve/erase (overwrites Phase 12 choice)

### Weather Stages
- **Light snow**: Minimal visual effect, no mechanical impact
- **Blizzard**: Moderate particles, slightly reduced visibility (accessibility: reduce intensity option)
- **Extreme storm**: Heavy particles, wind effects (accessibility: reduce to blizzard or light snow)

**Accessibility**: Never obscure critical interactables or hazards. Always provide audio/visual alternatives.

### Enemy Placements
- **All existing types**: Scavenger, Enforcer, Marksman, Shield (no new classes)
- **Deliberate placements**: Each arena designed, not random spawns
- **Escalating difficulty**: Early sections = 2-3 enemies, late sections = 5-7 enemies

### Optional Aid
- **Researcher rescues**: Hidden in side rooms, increment Civilian Aid
- **Equipment repairs**: Fix generators, terminals, opens shortcuts
- **Never blocks main path**: Optional only, main path always completable without

### Testing
- [ ] Level is coherent 20-35 minute chapter (not bloated, not rushed)
- [ ] Weather readable, doesn't lower determinism
- [ ] Optional aid never blocks main path, persists correctly
- [ ] Evidence choice unmistakable, saved correctly
- [ ] 60 FPS maintained during extreme storm + multiple enemies + particles
```

---

### Phase 14: Final Boss

**Add to prompt**:

```markdown
## Award-Level Boss Design (Shadow of Colossus + Dark Souls Standard)

### Boss Arena Layout
- **Clear chamber**: Reactor/prototype center, three calibration panels, vents/overload panels, boss center zone, fixed reinforcement spawns, safe movement lanes
- **Visual readability**: No visual clutter, boss telegraphs clear, environmental hazards marked

### Boss State Machine (Deterministic, No Random)

**Phase 1 (100-75% health)**:
- Ranged energy blast (1.5s telegraph, dodgeable)
- Temporary shield barrier (3 seconds, flank to bypass)
- Reinforcement call (2 Scavengers, fixed spawn points)

**Phase 2 (75-50% health)**:
- All Phase 1 moves
- Reactor sabotage attempt (clear warning, Elena must counter)

**Phase 3 (50-25% health)**:
- All Phase 1-2 moves
- Enraged: Faster attacks (0.8s telegraphs), more aggressive positioning

**Phase 4 (25-0% health)**:
- All moves
- Desperation: Area-wide attacks (must dodge to safe lanes)

### Elena Calibration Interactions (3 Panels)
- **Each panel**: Visible progress bar (10 seconds to complete)
- **Interruption**: If Marcus takes damage during calibration, progress pauses (not resets)
- **Completion**: Creates boss vulnerability window (5 seconds, Marcus deals 2x damage)

### Marcus Protection Tasks
- **During calibration**: Marcus must prevent reinforcements from reaching Elena
- **Positioning**: Stand between Elena and spawn points, intercept enemies
- **Communication**: Elena calls out "Left!" / "Right!" for spawn directions (audio + visual indicators)

### Environmental Actions (Optional, Never Mandatory)
- **Vent steam**: Knocks boss back, 10 second cooldown
- **Overload stun**: Stuns boss 3 seconds, 1 charge per fight
- **Visibility**: Clear icons, cooldown timers, audio cues

### Boss Checkpoint Policy
- **Retry**: Resume at start of phase (not full fight restart)
- **Fair**: Each phase <2 minutes, total fight <8 minutes for skilled player

### Dialogue
- **Pre-fight**: Voss reveals motivation (Mumbai daughter, "I became the firebreak")
- **Mid-fight**: Elena/Marcus exchanges ("Almost there!" / "Keep her off me!")
- **Victory**: Voss defeated, transition to epilogue

### Testing
- [ ] Boss beatable through learned patterns, no random luck
- [ ] All attacks telegraphed, avoidable
- [ ] Calibration/switching requires both characters without input confusion
- [ ] Retry, save/load, victory transition stable
- [ ] 60 FPS maintained during boss + reinforcements + particles + calibration UI
```

---

### Phase 15: Epilogue and Endings

**Add to prompt**:

```markdown
## Award-Level Endings (The Last of Us Part II Standard)

### Ending Rules (Deterministic, Documented)

**Priority order**:
1. **Fragile Thaw** (priority if `elena_safety <= 1` OR `prototype_integrity <= 1`)
2. **Public Thaw** (if `civilian_aid >= 4` AND `prototype_integrity >= 2` AND `evidence_choice == "preserve"`)
3. **Guarded Thaw** (otherwise)

### Ending Cinematics (90+ Seconds Each, Fully Voiced)

**Public Thaw**:
- **0:00-0:15**: Aster activates, global stabilization waves
- **0:15-0:30**: Helix facilities opening, data released worldwide
- **0:30-0:45**: Communities rebuilding (solar panels, vertical farms)
- **0:45-1:00**: Elena at Iris's grave: "It's done. The protocol is free. You would have loved this world."
- **1:00-1:15**: Marcus at police memorial: "I'm not that person anymore. I hope you can forgive me."
- **1:15-1:30**: Global montage (children without masks, birds returning, first non-toxic snow)
- **Final shot**: Elena and Marcus on mountain, sunrise
- **Text**: "The climate stabilized over 17 years. Helix was disbanded. Recovery was not easy. But it was possible."

**Guarded Thaw**:
- **0:00-0:20**: Aster activates, protected zones bloom
- **0:20-0:40**: Helix checkpoints, ID scans, rationing
- **0:40-1:00**: Elena in lab: "I saved the climate. But not everyone."
- **1:00-1:15**: Marcus training resistance: "They control the cure. We take it back."
- **1:15-1:30**: Split screen (inside: clean park, outside: children behind fence)
- **Final shot**: Elena at terminal: "I can fix this. I have to."
- **Text**: "The climate stabilized. But access was controlled. Resistance formed within 3 years. Elena Vast disappeared 6 months later."

**Fragile Thaw**:
- **0:00-0:20**: Aster activates partially, some storms remain
- **0:20-0:40**: Communities adapting (makeshift shelters, rationing)
- **0:40-1:00**: Elena injured: "It's not enough. But it's something."
- **1:00-1:15**: Marcus distributing supplies: "We make do. We always have."
- **1:15-1:30**: Resilience montage (vertical farms in ruins, solar on rubble)
- **Final shot**: Elena and Marcus working together, prototype glowing faintly
- **Text**: "The climate improved, but not enough. Recovery took 40 years. They became symbols—not of victory, but of persistence."

### Final Statistics Screen
- Civilians aided: X/10
- Elena Safety: X/3
- Prototype Integrity: X/3
- Evidence decision: Preserve/Erase
- Ending title: Public/Guarded/Fragile Thaw

### Credits
- Scrolling text, 2-3 minutes
- Placeholders for team, advisors, voice actors
- Skippable after 30 seconds

### New Game Option
- Calls `GameManager.reset_new_game()`
- Clears/replaces save safely
- Returns to MainMenu or new start flow

### Testing
- [ ] Same saved inputs always result in same ending (deterministic)
- [ ] Priority rule for Fragile Thaw works correctly
- [ ] Credits skippable, New Game functional
- [ ] All epilogue text/buttons error-free
- [ ] 60 FPS maintained during cinematics
```

---

### Phase 16: QA and Release

**Add to prompt**:

```markdown
## Award-Level QA (Zero Bugs in Release)

### QA Checklist (`docs/qa_checklist.md`)

**Menus**:
- [ ] MainMenu navigable with keyboard + controller
- [ ] Options menu functional (all settings save/load correctly)
- [ ] Pause menu accessible during gameplay
- [ ] Credits scroll correctly, skippable

**Levels** (every chapter):
- [ ] Completable start-to-finish without softlocks
- [ ] All puzzles solvable, hints functional
- [ ] All combat arenas clearable
- [ ] All checkpoints trigger correctly
- [ ] Save/load at any point works

**Puzzles** (all types):
- [ ] Terminal puzzles: Connections clear, undo functional, hints work
- [ ] Power routing: Circuits color-coded, overload safe, visual indicators clear
- [ ] Water/valve: Flow visible, pressure gauges readable, no softlocks
- [ ] Platforms: Movement smooth, emergency stop functional, backup routes accessible

**Enemies** (all types):
- [ ] Scavenger: AI deterministic, telegraphs readable
- [ ] Enforcer: Block/counter pattern consistent, flank weakness clear
- [ ] Marksman: Line-of-sight reliable, projectiles dodgeable
- [ ] Shield: Frontal immunity clear, flank counterplay functional

**Bosses** (all):
- [ ] Riot Commander: Shield bash telegraphed, rear weak point accessible
- [ ] Transport Captain: Shockwave avoidable, crane interaction functional
- [ ] Helix Commander: All phases deterministic, calibration/switching clear

**Minigames**:
- [ ] Vehicle repair: Solution deducible, timeout outcome safe
- [ ] Aster calibration: Circuit solvable, hints functional

**Character Switching**:
- [ ] Never leaves character stuck, duplicated, or without camera
- [ ] Contextual lockouts clear ("Cannot switch now")
- [ ] Switching speed <100ms, no loading

**Save/Load/Checkpoints**:
- [ ] Autosave every 60 seconds
- [ ] Manual save (10 slots) functional
- [ ] Checkpoint save restores correctly
- [ ] Corrupt save detection + backup restore works

**Consequence Counters**:
- [ ] Elena Safety (0-3): Changes only through defined events
- [ ] Prototype Integrity (0-3): Changes only through defined hazards
- [ ] Civilian Aid (0-10): Increments once per rescue, no farming

**All Three Endings**:
- [ ] Public Thaw: Unlocks with correct conditions
- [ ] Guarded Thaw: Unlocks with correct conditions
- [ ] Fragile Thaw: Priority rule works (Elena Safety <=1 OR Integrity <=1)

**Controls**:
- [ ] All inputs remappable
- [ ] Keyboard, controller, mouse all functional
- [ ] One-handed control scheme tested

**Exported Builds**:
- [ ] Windows export runs without errors
- [ ] macOS/Linux exports (if templates available)
- [ ] No missing assets, no console errors

### QA Results (`docs/qa_results.md`)

**Template**:
```markdown
## Issues Found

| ID | Severity | Description | Reproduction Steps | Resolution | Verified |
|----|----------|-------------|-------------------|------------|----------|
| 001 | Critical | Game crashes on loading Phase 13 | Load save from Phase 12 end | Fixed memory leak in weather system | ✅ |
| 002 | Major | Elena gets stuck in Room 3 of Phase 12 | Switch character while Elena moving | Added stuck detection + teleport | ✅ |

## Verification Status

- **Blockers**: 0 (must be 0 for release)
- **Major**: 0 (must be 0 for release)
- **Minor**: X (acceptable if documented, non-blocking)
- **Cosmetic**: X (acceptable)
```

### Performance Profiling
- **Godot Profiler**: Run on minimum spec hardware
- **Bottlenecks**: Excessive nodes/particles, unnecessary processing, expensive effects
- **Optimization**: Preserve gameplay behavior, only optimize verified bottlenecks

### Accessibility Verification
- **Input remapping**: All actions remappable, documented bindings
- **Text size**: Normal/large settings, UI scales 75%-200%
- **Camera shake**: Reduced/off option functional
- **Weather intensity**: Reduced/off option functional
- **Puzzle indicators**: Visual non-color-only (outline + pattern)

### Export Configuration
- **Windows**: Export preset configured, run-tested
- **macOS/Linux**: Only if templates + testing available (do not falsely claim untested builds work)

### Release Checklist (`docs/release_checklist.md`)

**Version**: 1.0.0

**Tested Platforms**:
- [ ] Windows 10/11 (64-bit)
- [ ] macOS 11+ (if tested)
- [ ] Linux Ubuntu 20.04+ (if tested)

**Known Issues**:
- [ ] List all minor/cosmetic issues (transparency)

**Store Assets**:
- [ ] Screenshots (10 minimum, variety of levels, combat, puzzles, endings)
- [ ] Trailer (2-3 minutes, gameplay + cinematics, no spoilers)
- [ ] Description (store page, compelling, accurate)
- [ ] Content warnings (violence, themes of loss, climate disaster)

**License**:
- [ ] Decide license (MIT, CC BY-NC-SA, or proprietary)
- [ ] Update README with license decision

**Release Sign-Off**:
- [ ] Lead developer approval
- [ ] QA lead approval
- [ ] No unresolved release-blocking issues

### Git Tagging
- **Clean working tree**: No uncommitted changes
- **Final version commit**: All QA checks pass
- **Annotated tag**: `v1.0.0` only after all checks pass
- **If blockers remain**: Do NOT tag, report instead

### Testing
- [ ] QA documentation reflects real verification (not assumptions)
- [ ] Full game can reach each ending using documented test steps
- [ ] Windows export created and run-tested (if tooling available)
- [ ] No knowingly unresolved release-blocking softlock, crash, or corrupt-save issue remains
```

---

## Next Steps

1. **Create `_award.md` versions** of all remaining phase prompts (2-16)
2. **Update `prompts/README.md`** to reference both original and award-level versions
3. **Add comparison table** showing what changed in each phase
4. **Test Phase 0 and 1 award prompts** in Claude Code, verify improvements
5. **Iterate** based on implementation feedback

---

## Summary

**Updated prompts now include**:
- Award-level performance targets (60 FPS, <16ms, <50ms input)
- Comprehensive accessibility (visual, audio, motor, cognitive)
- Specific polish requirements (hit feedback, audio layers, UI animation)
- Detailed testing checklists (12+ criteria per phase)
- Reference games for each system (Hades, Portal 2, Celeste, Last of Us, It Takes Two)
- Documentation requirements (QA results, performance metrics, known limitations)

**This ensures** every phase builds toward an award-worthy final product, not just a functional game.
