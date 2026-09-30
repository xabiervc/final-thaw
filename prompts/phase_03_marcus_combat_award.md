You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing systems before editing. Phases 0-2 are complete with award-level foundation, Elena movement, and laboratory puzzles.

**AWARD-LEVEL TARGET**: Combat must feel as responsive as *Hades* or *Devil May Cry*. Every attack has purpose, player expression matters, enemies are readable, and flow state is achievable. No cheap hits, no randomness, no input lag.

GOAL
Implement Marcus Reyes and deterministic isometric beat-'em-up combat foundation.

## CONTEXT

Marcus is a former police officer. His gameplay is direct action, protection, crowd control, environmental mastery. Combat must feel weighty but responsive—every hit has impact, every dodge matters.

## DELIVERABLES

### 1. Marcus Character Scene (`scenes/characters/marcus_character.tscn`)

**CharacterBody2D with**:
- **Collision**: CapsuleShape2D (width: 56px, height: 104px) - slightly wider than Elena
- **Sprite**: Placeholder (64x128px rectangle, orange color #E28A4A) with idle animation (subtle weight shift, 2 second loop)
- **Ground shadow**: Ellipse (48x24px, #40000000), offset 12px below sprite
- **Health component**: `scripts/components/health.gd` with `current_health: int`, `max_health: int = 100`
- **State machine**: `scripts/characters/marcus_state_machine.gd` tracking: idle, move, light_attack, heavy_attack, combo, dodge, block, hitstun, grab, throw, defeated
- **Camera2D**: Slightly lower than Elena's (more combat intensity), zoom: 1.1, drag margin: 0.25
- **AudioStreamPlayer2D**: For combat sounds (grunts, hits, dodges)

### 2. Movement with Combat Enhancements

**Constants** (`scripts/characters/marcus_controller.gd`):
```gdscript
@export var ACCELERATION: float = 35.0  # Slightly higher than Elena (more aggressive)
@export var DECELERATION: float = 30.0
@export var MAX_SPEED: float = 320.0  # 7% faster than Elena
@export var SPRINT_MULTIPLIER: float = 1.4  # Hold sprint for 1.4x speed
@export var DODGE_SPEED: float = 600.0  # 2x normal speed during dodge
@export var DODGE_DURATION: float = 0.25  # 250ms dodge animation
@export var DODGE_INVINCIBILITY_FRAMES: float = 0.15  # 150ms i-frames at start
```

**Sprint**:
- Hold `sprint` input (Shift or L3) for 1.4x speed
- Stamina cost: 10 per second (stamina regenerates at 20 per second when not sprinting)
- Visual: Motion blur trail, heavier breathing audio

**Dodge**:
- Press `dodge` (Space or B) while moving
- Dash 120px in movement direction over 250ms
- Invincibility: First 150ms (60% of dodge)
- Cooldown: 0.5 seconds (prevents spam, but short enough for flow)
- Perfect dodge: If dodge input within 150ms of enemy attack windup → trigger slow-mo (2 seconds, 0.5x speed)

**Block**:
- Hold `block` (Mouse Middle or LT) to reduce 60% frontal damage
- Stamina cost: 15 per second while blocking
- Guard break: After 3 seconds continuous block, 2 second vulnerability (take 100% damage)
- Visual: Energy shield effect in front of Marcus (cyan tint)

### 3. Combat State Machine

**States** (all in `marcus_state_machine.gd`):
- **idle**: Standing still, no input
- **move**: Moving (with or without sprint)
- **light_attack**: Fast attack (200ms startup, 100ms active, 300ms recovery), 15 damage
- **heavy_attack**: Slow attack (400ms startup, 200ms active, 500ms recovery), 35 damage, launches
- **combo**: Chained attacks (Light→Light→Heavy = launch state)
- **dodge**: Invincible dash (see above)
- **block**: Damage reduction (see above)
- **hitstun**: 0.5 seconds after taking damage, cannot act
- **grab**: Grabbing enemy or object (500ms windup)
- **throw**: Throwing grabbed object/enemy (instant, direction = facing)
- **defeated**: Health <= 0, play death animation, respawn at checkpoint

**Input Buffering**:
- Queue next attack input during current attack's active/recovery frames
- Buffer window: 200ms (generous, allows flow combos)
- Example: Press Light during Light recovery → auto-queue next Light or Heavy

**Combo System**:
- **3-hit base**: Light → Light → Heavy (launch)
- **Aerial juggle**: After launch, can do Light attacks while enemy airborne (3 hits max)
- **Combo reset**: If no attack input for 2 seconds, combo counter resets
- **Visual**: Combo counter UI ("Combo x3", "Combo x5", etc.) in top-right

### 4. Hitbox/Hurtbox System

**Hitbox component** (`scripts/components/hitbox.gd`):
```gdscript
@export var damage: int = 15
@export var knockback: float = 200.0
@export var hitstun_duration: float = 0.5
@export var element_type: String = "physical"  # physical, fire, electric, etc.

func deal_damage(target: Node2D) -> void:
    if target.has_method("take_damage"):
        target.take_damage(damage, knockback, hitstun_duration, element_type)
```

**Hurtbox component** (`scripts/components/hurtbox.gd`):
- Detects overlapping hitboxes
- Calls `take_damage()` on parent health component
- Prevents double-hits: Track which hitboxes already hit this frame (use unique IDs)

**Health component** (`scripts/components/health.gd`):
```gdscript
@export var current_health: int = 100
@export var max_health: int = 100

func take_damage(amount: int, knockback: float, hitstun: float, element: String) -> void:
    current_health = max(0, current_health - amount)
    # Apply knockback velocity to parent CharacterBody2D
    # Trigger hitstun state in state machine
    # Emit signal for UI update
```

**Debug visualization**: Toggle with F4 to show hitboxes (green), hurtboxes (red), damage numbers (yellow)

### 5. Enemy Scavenger (`scenes/enemies/enemy_scavenger.tscn`)

**CharacterBody2D with**:
- **Sprite**: Placeholder (56x96px rectangle, gray #808080), smaller than Marcus
- **Health**: 50 HP (dies in 4 light attacks or 2 heavy)
- **State machine**: idle, approach, windup, strike, recovery, hitstun, defeated

**AI Behavior** (`scripts/enemies/scavenger_ai.gd`):
```gdscript
# Deterministic state machine
STATE_IDLE = 0
STATE_APPROACH = 1
STATE_WINDUP = 2
STATE_STRIKE = 3
STATE_RECOVERY = 4
STATE_HITSTUN = 5
STATE_DEFEATED = 6

# Constants
@export var DETECTION_RANGE: float = 400.0
@export var ATTACK_RANGE: float = 80.0
@export var WINDUP_DURATION: float = 0.5  # 500ms telegraph
@export var RECOVERY_DURATION: float = 0.8  # 800ms punishable window
@export var MOVE_SPEED: float = 180.0

# Behavior loop:
# 1. If player in detection range: approach
# 2. If in attack range: windup (500ms telegraph with red flash)
# 3. Strike (instant damage check)
# 4. Recovery (800ms, player can punish)
# 5. Repeat
```

**Visual telegraphs**:
- Windup: Enemy glows red, raises weapon (0.5s)
- Strike: Fast lunge animation (instant damage)
- Recovery: Stagger back, vulnerable (0.8s)
- Hitstun: Flash white, knockback (0.5s)

**Health bar**: Above enemy, red, 50px wide, fades out after 2 seconds not damaged

### 6. Grab/Throwable Object System

**Grabbable objects** (`scenes/objects/grabbable_object.tscn`):
- **Types**: Crate (25 damage), barrel (40 damage), debris (10 damage)
- **Physics**: RigidBody2D, but grabbed = kinematic (follows Marcus)
- **Interaction**: Hold `grab` (G or Y) near object to pick up
- **Carry**: Object attaches to Marcus (offset +40px on facing side)
- **Throw**: Press `attack_light` while holding → throw in facing direction
- **Throw physics**: Velocity 500px/s, arc trajectory (gravity -800px/s²)
- **Impact**: On collision, deal damage, then settle or break (if breakable)

**Enemy grab**:
- Works on Scavengers only (not Enforcers or bosses)
- Windup: 500ms (enemy can struggle, break free if Marcus takes damage)
- Throw: Instant takedown (50 damage, usually kills Scavenger)
- Stamina cost: 30 per grab

### 7. Combat Arena Test Scene (`scenes/levels/marcus_combat_arena.tscn`)

**Environment**:
- Floor: 1920x1080px rectangle, dark gray (#404040)
- Walls: StaticBody2D with collision (invisible or debug texture)
- Lighting: DirectionalLight2D, even illumination
- **Throwables**: 5 objects placed (2 crates, 2 barrels, 1 debris pile)

**Enemies**:
- 3-5 Scavengers with fixed spawn points
- Spawn wave 1: 2 enemies at start
- Spawn wave 2: +2 enemies when wave 1 defeated
- Spawn wave 3: +1 enemy when wave 2 defeated (optional, test scaling)

**Arena Controller** (`scripts/levels/arena_controller.gd`):
- Track enemy waves
- Lock exits while active (invisible walls)
- Unlock on all enemies defeated
- Show wave counter: "Wave 1/3" in corner
- Score display: Time, damage dealt, environmental throws, clean-clear bonus

### 8. Hit Feedback (Juice)

**Visual**:
- **Hit flash**: Enemy turns white (#FFFFFF) for 100ms on hit
- **Screen shake**: 2-3 pixels on heavy hits, 1 pixel on light (toggleable in options)
- **Damage numbers**: Float up from hit location (yellow #FFFF00, 24px, fade out over 1 second)
- **Blood/decal**: Optional splatter on kill (toggleable for gore sensitivity)

**Audio**:
- **Light attack**: Sharp crack (high pitch, short)
- **Heavy attack**: Deep thud (low pitch, longer)
- **Hit**: Meat impact + cloth tear (layered)
- **Enemy vocal**: Grunt on hit, death cry on defeat
- **Environmental**: Glass shatter, metal clang, wood splinter

**Camera**:
- **Shake on heavy hit**: 100ms, amplitude 3px (reduced motion option: 1px)
- **Slow-mo on perfect dodge**: 0.5x speed for 2 seconds (reduced motion: instant, no slow)

### 9. Accessibility in Combat

**Aim assist** (for targeting):
- Levels: Off, 25%, 50%, 75%, 100%
- Sticky reticle slows when over enemy
- Optional auto-lock on nearest (toggle)

**Slow-motion mode**:
- Global time scale: 0.5x, 0.75x, 1.0x (normal), 1.25x (speedrun)
- Affects everything: movement, attacks, enemy AI
- Always available, no penalty

**Reduced motion**:
- Disables camera shake, screen tilt, motion blur
- Reduces particle density by 75%
- Slows dodge slow-mo to instant (no time distortion)

**High contrast enemies**:
- Toggle: Enemies outlined in bright red (#FF0000)
- Health bars always visible (not fade-out)
- Telegraphs use patterns (stripes) in addition to color

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Movement feel**: Marcus accelerates over ~0.25 seconds to max speed, sprint feels faster (1.4x). No instant stops. Profiler: <0.15ms per frame for movement. PASS/FAIL

2. **Dodge timing**: 150ms i-frames at start, 250ms total duration. Perfect dodge (150ms window before attack) triggers 2s slow-mo. Test with timing tool. PASS/FAIL

3. **Block system**: 60% damage reduction frontal, 15 stamina/sec, guard break after 3s. Test with damage numbers visible. PASS/FAIL

4. **Combo system**: Light→Light→Heavy launches enemy. Aerial juggle works (3 hits max). Input buffer (200ms) allows smooth chains. Test with debug hitboxes. PASS/FAIL

5. **Hitbox/hurtbox**: No double-hits from single attack. Damage numbers match expected (15 light, 35 heavy). Test with F4 hitbox overlay. PASS/FAIL

6. **Enemy AI**: Scavenger approach→windup (500ms)→strike→recovery (800ms) loop is readable. Telegraphs visible (red flash). Punishable windows clear. Test with new player (no spoilers). PASS/FAIL

7. **Grab/throw**: Can grab crates/barrels, carry, throw in facing direction. Throw deals correct damage (25/40). Enemy grab works on Scavengers (50 damage takedown). Test all throwables. PASS/FAIL

8. **Arena flow**: 3 waves spawn correctly, exits lock during combat, unlock on clear. Score display accurate (time, damage, throws, bonus). Test full clear. PASS/FAIL

9. **Hit feedback**: Hit flash (100ms white), screen shake (2-3px), damage numbers (float up, fade 1s). All toggleable in options. Test with high-speed camera. PASS/FAIL

10. **Performance**: 60 FPS locked with 5 enemies, particles, screen shake, damage numbers. Profiler: <5ms per frame for all combat logic. PASS/FAIL

11. **Accessibility**: Aim assist (5 levels) works. Slow-mo mode (0.5x/0.75x) functional. Reduced motion disables shake/tilt. High contrast outlines enemies. Test all options. PASS/FAIL

12. **Save/load**: Marcus health, enemy states, arena progress persist after save/load. Test mid-combat save, quit, reload. PASS/FAIL

---

## DO NOT

- Add randomness (no random crits, no RNG damage)
- Make enemies tanky (Scavenger = 50 HP max, dies in 4 lights)
- Create long recovery animations (>1 second)
- Allow enemies to stun-lock Marcus (max 1 hitstun at a time)
- Spawn enemies on top of player (min 200px from Marcus on spawn)
- Make combat mandatory for progression (this is test arena, but prepare for story integration)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence (videos, profiler screenshots)
3. **Known limitations**: Any unresolved issues, TODOs, technical debt
4. **Performance metrics**: FPS in arena with 1/3/5 enemies, combat logic time per frame
5. **Commit message**: Propose this exact message:

```
Phase 3: Marcus combat fundamentals complete

Award-level combat system with:
- 3-hit combo (Light→Light→Heavy launch), aerial juggle, input buffering (200ms)
- Perfect dodge (150ms i-frames, 150ms window → 2s slow-mo)
- Parry/block (60% reduction, guard break 3s, 200ms parry window)
- Style meter (D→S rating, combo counter, environmental bonus)
- Hitbox/hurtbox system (no double-hits, debug overlay F4)
- Enemy Scavenger AI (deterministic, readable telegraphs, punishable windows)
- Grab/throw system (3 throwable tiers, enemy grab takedown)
- Hit feedback (flash, shake, damage numbers, all toggleable)
- Full accessibility (aim assist, slow-mo, reduced motion, high contrast)

All 12 acceptance criteria PASS. 60 FPS locked. Ready for Phase 4.
```
