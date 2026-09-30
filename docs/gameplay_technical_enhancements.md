# FINAL THAW — Gameplay & Technical Excellence Standards

## Target Performance Metrics

| Platform | Resolution | FPS Target | Input Latency | Load Time |
|----------|------------|------------|---------------|-----------|
| Minimum PC (GTX 1060) | 1080p | 60 locked | <50ms | <3s |
| Recommended PC (RTX 3060) | 1440p | 60 locked | <30ms | <2s |
| High-end PC (RTX 4070+) | 4K | 60 locked | <20ms | <1s |
| Steam Deck | 800p | 60 locked | <50ms | <3s |

**Non-negotiable**: No frame drops, no stuttering, no input lag spikes. If a scene can't maintain 60 FPS, it must be optimized or cut.

---

## Combat System Enhancements

### Current State
Beat-'em-up foundation with light/heavy attacks, dodge, block, grabs, throws.

### Award-Level Standard

#### Combat Flow Principles (Hades + Devil May Cry)
1. **Every attack has purpose**: No filler moves. Each hit in combo serves different function (positioning, stagger, damage, launch)
2. **Player expression**: Multiple viable playstyles (aggressive rushdown, defensive counter, environmental mastery, crowd control)
3. **Enemy readability**: Every enemy has clear telegraph, punishable window, and counterplay. No cheap hits.
4. **Flow state**: Successful combat feels like dance—player enters rhythm, adapts to changes, exits victorious without feeling lucky

#### Specific Improvements

**Combo System**:
- **Three-hit base combo**: Light → Light → Heavy (launch)
- **Combo extensions**: After launch, juggle with aerial attacks or environmental throws
- **Combo rating**: Visible multiplier (1.0x - 3.0x) based on hit variety, environmental use, no-damage streaks
- **Style meter**: Persistent UI element showing current performance (D → C → B → A → S)

**Dodge Mechanics**:
- **Perfect dodge window**: 150ms frame where dodging through attack triggers slow-motion (2 seconds) and guarantees counter
- **Dodge cancel**: Can cancel light attack startup into dodge (costs stamina, prevents spam)
- **Directional dodge**: Dodging toward enemy = short, aggressive roll. Dodging away = longer, defensive retreat

**Block/Parry System**:
- **Block**: Reduces 60% frontal damage, drains stamina bar
- **Parry**: Press block within 200ms of impact = deflect, stagger enemy, open for critical hit
- **Guard break**: Holding block too long (>3 seconds continuous) causes guard break, 2 second vulnerability

**Environmental Combat**:
- **Throwable objects**: 3 tiers (light debris = 10 dmg, crates/barrels = 25 dmg, fuel canisters = 40 dmg + AoE)
- **Wall splat**: Knock enemy into wall = stun 1.5 seconds, bonus 15 damage
- **Ledge finisher**: Knock off elevated platform = instant kill on small enemies, major damage on large
- **Hazard use**: Lure enemies into fire, electricity, toxic water = environmental kill

**Enemy AI Improvements**:
- **Flanking behavior**: 3+ enemies automatically attempt surround. Player back exposed = 50% damage increase
- **Telegraph hierarchy**: Small enemy = 0.5s windup. Large enemy = 1.0s windup. Boss = 1.5s windup
- **Adaptive aggression**: If player kills quickly, remaining enemies become cautious (more blocking, slower approach). If player passive, enemies become aggressive (faster attacks, more risks)
- **Communication**: Enemies call out player position ("Behind you!", "He's low!", "Watch the left!")—diegetic audio cues

---

## Puzzle System Enhancements

### Current State
Environmental puzzles with terminals, valves, platforms, power routing.

### Award-Level Standard (Portal 2 + Outer Wilds)

#### Puzzle Design Philosophy
1. **Teach**: First instance of mechanic is safe, obvious, no time pressure
2. **Test**: Second instance requires player to apply knowledge with mild challenge
3. **Twist**: Third instance subverts expectation—mechanic works differently or combines with another
4. **Master**: Final instance requires full understanding, often under pressure or with multiple variables

#### Specific Improvements

**Terminal Puzzles**:
- **Visual programming**: Nodes and connections shown as glowing circuits, not abstract menus
- **Immediate feedback**: Wrong connection sparks/fizzes immediately, not after "submit"
- **Undo function**: Can reverse last 3 actions before committing (prevents softlocks from misclicks)
- **Hint system**: Hold hint button (3 charges per level) to highlight correct next step

**Power Routing Puzzles**:
- **Color-coded**: Red = emergency systems, blue = life support, yellow = machinery, green = safety
- **Load management**: Too many devices on one circuit = overload, brief blackout, reset required
- **Visual indicators**: Overloaded wires glow orange, spark. Correct routing = steady blue pulse
- **Consequence**: Wrong routing doesn't kill player, but locks optional rewards (memories, civilian rescues)

**Water/Valve Puzzles**:
- **Flow visualization**: Water current shown with particle streams, not just rising/falling
- **Pressure indicators**: Gauges show PSI, red zone = dangerous, green = safe
- **Backup systems**: If player floods area accidentally, emergency drains activate after 10 seconds (no softlock)
- **Multi-state**: Water can be too low (can't float platforms), too high (drowning hazard), or just right

**Moving Platform Puzzles**:
- **Call buttons**: Platforms can be summoned to specific floors, not just cycling
- **Weight sensitivity**: Platform moves slower with character on it (visible strain animation)
- **Emergency stop**: Can halt platform mid-travel (prevents instant death from mistimed jumps)
- **Backup routes**: Every platform puzzle has alternate path (ladder, destructible wall, vent) for accessibility

**Aster Calibration (Circuit Puzzle)**:
- **Rotational logic**: Each tile rotates 90°, must align to complete circuit
- **Power flow animation**: Electricity visibly travels through correct path, stops at breaks
- **Multiple solutions**: 2-3 valid configurations per puzzle (rewards experimentation)
- **Time pressure optional**: Base game = no timer. Hard mode = 60 second limit

---

## Character Switching System

### Current State
Switch between Elena and Marcus via input.

### Award-Level Standard (It Takes Two single-player + Tales from the Borderlands)

#### Switching Mechanics
- **Instant swap**: <100ms transition, no loading. Camera smoothly pans to inactive character's position
- **Position lock**: Inactive character freezes in place, invulnerable, with subtle idle animation (breathing, scanning)
- **Contextual lockout**: Cannot switch during scripted sequences, mid-air, or in combat arenas (clear UI feedback: "Cannot switch now")
- **Character-specific cameras**: Elena = slightly higher, wider FOV (puzzle readability). Marcus = lower, tighter FOV (combat intensity)

#### Emotional Integration
- **Switching = trust**: Early game, switching has 2 second cooldown (hesitation). Late game, instant (full trust)
- **Cross-character dialogue**: When switching, inactive character sometimes comments ("Your turn." / "Don't get killed.")
- **Shared upgrades**: Some abilities unlock for both (e.g., sprint, health upgrades). Others remain character-specific
- **Synergy moves**: Late-game puzzles require both characters active simultaneously (Elena hacks door while Marcus holds it open)

---

## Accessibility Implementation

### Visual Accessibility

**Colorblind Modes** (12 types):
- Deuteranopia (red-green), Protanopia (red-green), Tritanopia (blue-yellow)
- Full achromatopsia (monochrome) mode
- Custom color remapping: Player can reassign any UI color

**UI Scaling**:
- Range: 75% to 200% in 25% increments
- All text, icons, health bars scale proportionally
- Minimum text size: 16px at 100% scale (readable at 10 feet on 1080p)

**High Contrast Mode**:
- Black background, white/yellow foreground
- Outlines all characters/enemies in bright colors
- Removes all decorative effects (particles, bloom, depth of field)

**Reduced Motion**:
- Disables camera shake, screen tilt, motion blur
- Reduces particle density by 75%
- Slows weather effects (rain, snow) by 50%

**Screen Reader Support**:
- All UI text has aria-labels
- Menu navigation reads aloud (optional)
- Puzzle states describable via audio ("Valve 1: closed. Valve 2: open.")

---

### Audio Accessibility

**Subtitle Options**:
- Size: Small, Medium, Large, Extra Large
- Background: None, semi-transparent black, solid black
- Speaker labels: Color-coded per character, always shown
- Sound effect captions: [Footsteps left], [Gunshot distant], [Machine humming]

**Visual Sound Cues**:
- Directional indicators on screen edge (arrow points to sound source)
- Icons for critical sounds (footsteps, gunfire, alarms, dialogue)
- Customizable: Player can assign icons to specific sounds

**Audio Description**:
- Optional narration during cinematics describing visual action
- "Elena turns to Marcus, her face illuminated by terminal glow."
- Can be toggled per cinematic or always-on

---

### Motor Accessibility

**Full Control Remapping**:
- Every input rebinding (keyboard, mouse, controller)
- Multiple profiles (up to 5 save slots)
- Import/export profile codes for sharing

**Toggle vs. Hold**:
- All hold actions can be toggled (sprint, block, aim, scan)
- Customizable toggle duration (infinite, 5 seconds, 10 seconds)

**Auto-Run**:
- Press once to walk forward continuously
- Tap again to stop
- Useful for players who can't hold stick/WASD long-term

**Aim Assist** (for any targeting):
- Levels: Off, 25%, 50%, 75%, 100%
- Sticky reticle slows when over target
- Optional auto-lock on nearest enemy

**Slow Motion Mode**:
- Global time scale: 0.5x, 0.75x, 1.0x (normal), 1.25x (speedrun)
- Affects everything: movement, puzzles, combat, cinematics
- Always available, no penalty for using

**One-Handed Control Scheme**:
- Pre-configured mapping for single-hand keyboard or controller
- All actions accessible without chorded inputs
- Tested with actual one-handed players during development

---

### Cognitive Accessibility

**Puzzle Hint System**:
- Level 0 (Off): No hints
- Level 1 (Contextual): Subtle visual highlight on interactable after 30 seconds of inactivity
- Level 2 (Full): Arrow points to next objective, text hint appears

**Extended Time Limits**:
- All timed puzzles have +50% time option
- No penalty, no achievement lockout
- Purely optional

**Objective Marker**:
- Always-on option: Permanent arrow/minimap indicator
- Can be toggled per puzzle or always-on
- Color-coded: Main objective = gold, optional = blue, memory = purple

**Quest Log**:
- Detailed step-by-step breakdown of current objectives
- Can be expanded to show hints, maps, diagrams
- Searchable, filterable, bookmarkable

**Checkpoints**:
- Generous placement: Every 3-5 minutes of gameplay
- Manual save anytime (outside combat)
- Autosave every 60 seconds
- Death restarts at checkpoint, not level start

---

## Technical Excellence

### Performance Optimization

**Rendering**:
- Dynamic resolution scaling: Drops to 90% resolution if FPS dips below 60
- LOD system: 3 levels for all 3D models, seamless transitions
- Occlusion culling: Never render what camera can't see
- Batch rendering: Combine static geometry into single draw calls where possible

**Memory Management**:
- Asset streaming: Load next level's assets during current level's final minute
- Pooling: Object pools for particles, enemies, projectiles (no runtime allocation)
- Garbage collection: Manual GC triggers during loading screens, never during gameplay

**Input Pipeline**:
- DirectInput/XInput priority: Bypass OS input lag where possible
- Input buffering: Queue inputs during frame drops, execute on next frame
- Polling rate: 1000Hz for mouse, 125Hz minimum for controllers

---

### Save System

**Multiple Save Layers**:
1. **Autosave**: Every 60 seconds, stored in `user://autosave.json`
2. **Checkpoint save**: At every checkpoint, stored in `user://checkpoint.json`
3. **Manual save**: Player-triggered, 10 slots, stored in `user://manual_save_1-10.json`
4. **Cloud backup**: Mirror all saves to Steam Cloud / GOG Cloud

**Corruption Protection**:
- CRC32 checksums on all save files
- If corruption detected, auto-restore from backup
- Player notified: "Save file was corrupted. Restored from backup."

**Save File Size**:
- Target: <100KB per save
- Only store deltas (changes from default state), not full world state
- Compress with LZ4 (fast decompression, minimal CPU cost)

---

### Debug & QA Tools

**Built-In Debug Menu** (password-protected in release):
- Level select: Jump to any chapter
- God mode: Invincibility, infinite stamina
- Puzzle solver: Instant complete current puzzle
- Combat arena selector: Spawn any enemy, any wave
- Stats viewer: See all flags, counters, choices
- Clip viewer: Watch any cinematic, any ending

**Analytics Dashboard** (optional, anonymized):
- Puzzle completion times (mean, median, outliers)
- Death locations (heat map)
- Choice distribution (% preserve evidence, % rescue civilians)
- Average playtime per chapter
- Drop-off points (where players quit)

**Automated Testing**:
- Unit tests for all GameManager functions
- Integration tests for save/load cycles
- Performance tests: Automated playthroughs measuring FPS, memory, load times
- Regression tests: Critical path must complete without errors on every build

---

### Loading & Transitions

**Scene Loading**:
- Target: <2 seconds for any scene transition
- Progressive loading: Show gameplay while streaming assets (e.g., walking through corridor loads next room)
- Async loading: Never block main thread for I/O

**Transition Styling**:
- No generic "Loading..." screens
- Contextual transitions: Elevator doors closing, character walking through fog, camera panning to sky
- Audio during transitions: Ambient music, character monologue, or environmental sounds

**Fast Travel** (post-game):
- After beating game, unlock chapter select
- Instant travel to any previously completed level
- Useful for collectible hunting, speedrunning, achievement cleanup

---

## Polish & Juice

### Visual Feedback

**Hit Impact**:
- Screen shake (subtle, 2-3 pixels) on heavy hits
- Hit flash (enemy turns white for 100ms)
- Damage numbers (optional, stylized font)
- Blood/decal splatter (toggleable for gore sensitivity)

**Environmental Response**:
- Footsteps in snow leave prints (fade after 10 seconds)
- Raindrops ripple in puddles
- Wind moves vegetation, debris, character clothing
- Lightning briefly illuminates dark areas

**UI Animation**:
- All UI elements have entrance/exit animations (slide, fade, scale)
- Buttons have hover, press, disabled states
- Progress bars fill smoothly, not instantly
- Notifications slide in from edge, auto-dismiss after 5 seconds

---

### Audio Feedback

**Combat Audio**:
- Each weapon/attack has unique sound (light = sharp crack, heavy = deep thud)
- Enemy vocalizations: Grunts on hit, shouts on attack, death cries
- Environmental audio: Glass shatters, metal screeches, wood splinters

**Puzzle Audio**:
- Success chime: Pleasant major chord
- Failure buzz: Soft minor dissonance (not punishing)
- Progress ticks: Subtle click for each correct step
- Completion fanfare: Full orchestral sting (short, 2 seconds)

**Ambient Layers**:
- 3 layers minimum: Base (wind, machinery), Mid (distant sounds), Top (foreground details)
- Dynamic mixing: Combat raises Mid layer, puzzles raise Top layer
- Silence used intentionally: Key moments have NO music, only diegetic sound

---

### Controller Support

**Full Gamepad Parity**:
- Every action possible on keyboard is possible on controller
- No "keyboard-only" mechanics
- Vibration feedback: Light rumble for alerts, heavy for impacts

**Controller Layouts**:
- Default: Combat-focused (right stick = aim, triggers = attacks)
- Alternative: Puzzle-focused (right stick = camera, face buttons = interactions)
- Custom: Player can create hybrid layouts

**Gyro Aiming** (if controller supports):
- Optional fine-aim adjustment with gyro
- Sensitivity: 5 levels (1-5)
- Invert option for both axes

---

## Implementation Priority

### Phase 1 (Critical - Must Have for Release)
- 60 FPS locked on minimum spec
- Full control remapping
- Subtitle customization
- Save/load corruption protection
- Checkpoint system
- Basic colorblind mode

### Phase 2 (Important - Expected by Players)
- All accessibility options
- Multiple difficulty levels
- New Game+
- Controller vibration
- Style meter/combo system
- Memory fragments

### Phase 3 (Polish - Award Differentiators)
- Dynamic dialogue system
- Ending cinematics fully voiced
- Post-credits stinger
- Photo mode
- Developer commentary
- Speedrun mode

---

## Success Metrics

**Technical excellence is achieved when**:
- No crash reports in first 48 hours post-launch
- 95%+ of players complete the game (Steam achievement data)
- Speedrunners can complete Any% in <45 minutes
- 100% completion achievable in <8 hours
- No game-breaking bugs reported in first week
- Metacritic technical score: 9/10 or higher

**This is the standard. Nothing less.**
