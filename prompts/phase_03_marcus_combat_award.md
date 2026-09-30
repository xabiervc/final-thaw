You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing systems before editing. Phases 0-2 are complete with award-level foundation, Elena movement, and puzzle design.

**AWARD-LEVEL TARGET**: Combat must feel like *Hades* meets *Devil May Cry*: responsive, readable, expressive. Every attack has purpose. Player can develop personal style. No button-mashing, no cheap hits.

GOAL
Implement Marcus Reyes and compact, deterministic isometric beat-'em-up combat foundation suitable for later levels.

## CONTEXT
Marcus is a former police officer. His gameplay is direct action, protection, crowd control, environmental mastery. Combat must feel readable and weighty—every hit matters, every decision counts.

**Emotional beat**: Marcus is rediscovering his purpose. He was a cop who refused orders to protect assets over civilians. Now he's choosing to protect again. Combat is his redemption.

---

## DELIVERABLES

### 1. Marcus Character Scene (`scenes/characters/marcus_character.tscn`)

Create CharacterBody2D with:
- **Collision**: CapsuleShape2D (width: 56px, height: 104px) or custom shape matching sprite
- **Sprite**: Placeholder (72x136px rectangle, orange color #E26A4A) with idle animation (subtle weight shift, 2.0 second loop)
- **Ground shadow**: Ellipse (48x24px, semi-transparent black #40000000), offset 12px below sprite
- **Camera2D**: As child, smooth follow (drag margin: 0.2), zoom: 1.0 (slightly tighter than Elena for combat intensity)
- **Health component**: `scripts/components/health.gd` with `current_health`, `max_health`, `invincible` flags
- **State machine**: `scripts/components/combat_state_machine.gd` tracking current state (idle, move, attack, dodge, block, hitstun, defeated)
- **AudioStreamPlayer2D**: For combat sounds (footsteps, attacks, grunts)
- **AnimationTree**: For attack, dodge, block, hit, idle animations

### 2. Marcus Movement Script (`scripts/characters/marcus_controller.gd`)

**Movement Constants** (matching Elena for consistency):
```gdscript
@export var ACCELERATION: float = 30.0
@export var DECELERATION: float = 25.0
@export var MAX_SPEED: float = 300.0
@export var SPRINT_MULTIPLIER: float = 1.5  # Sprint is 50% faster
```

**Additional Combat Movement**:
- **Sprint**: Hold `sprint` input (Shift or L3) for 1.5x speed
- **Dodge**: Press `dodge` (Space or B) for invincibility frames (see below)
- **Block**: Hold `block` (Mouse Middle or LT) for damage reduction

**Performance**: Same as Elena—<0.1ms per frame for movement logic.

---

### 3. Combat State Machine (`scripts/components/combat_state_machine.gd`)

**States** (enum):
```gdscript
enum CombatState {
    IDLE,           # Standing, can move/attack
    MOVING,         # Walking/running, can attack
    LIGHT_ATTACK,   # In light attack animation
    HEAVY_ATTACK,   # In heavy attack animation
    COMBO,          # In combo sequence
    DODGE,          # Dodging (invincible)
    BLOCK,          # Blocking (reduced damage)
    HITSTUN,        # Just got hit (can't act)
    GRAB,           # Grabbing enemy/object
    THROW,          # Throwing grabbed object
    DEFEATED        # Health = 0
}
```

**State Transitions** (deterministic, no randomness):
- IDLE → MOVING (on movement input), LIGHT_ATTACK (on light input), DODGE (on dodge input), BLOCK (on block input)
- MOVING → IDLE (on stop), LIGHT_ATTACK, HEAVY_ATTACK, DODGE
- LIGHT_ATTACK → IDLE (after animation completes, ~0.3s), COMBO (on second light input within 0.5s)
- DODGE → IDLE (after 0.4s, invincibility lasts first 0.15s = "perfect dodge window")
- BLOCK → IDLE (on release or after 3s continuous = "guard break")
- HITSTUN → IDLE (after 0.5s, or 1.0s for heavy hits)

**Implementation**:
- State machine runs in `_physics_process(delta)`
- Each state has `enter()`, `update(delta)`, `exit()` functions
- State changes emit `state_changed(new_state: CombatState)` signal

---

### 4. Three-Hit Combo System (`scripts/components/combo_system.gd`)

**Combo Data Structure**:
```gdscript
struct AttackData {
    var startup: float      # Frames before hit activates (e.g., 0.1s)
    var active: float       # Frames where hit can connect (e.g., 0.1s)
    var recovery: float     # Frames after hit before can act again (e.g., 0.2s)
    var damage: int         # Base damage (e.g., 10, 20, 30 for 3-hit combo)
    var knockback: float    # Knockback force (e.g., 200, 300, 400)
    var hitbox: Shape2D     # Hitbox shape for this attack
}
```

**Combo Sequence**:
1. **First hit (Light)**: Quick jab, 10 damage, 200 knockback, 0.3s total duration
2. **Second hit (Light)**: Cross, 15 damage, 250 knockback, 0.4s total duration
3. **Third hit (Heavy)**: Uppercut launch, 25 damage, 400 knockback (launches enemy), 0.6s total duration

**Input Buffering** (deterministic, no random crits):
- Buffer window: 0.5s after each hit
- If player presses light within 0.5s of hit 1 → auto-start hit 2
- If player presses light within 0.5s of hit 2 → auto-start hit 3
- If player presses heavy within 0.5s of hit 2 → launch heavy attack instead of hit 3
- No random critical hits—all damage fixed

**Combo Extensions** (after launch on hit 3):
- **Aerial attack**: Press light while enemy airborne → Marcus jumps slightly, hits enemy down (20 damage)
- **Environmental throw**: If enemy near wall/throwable, press grab during launch → Marcus throws enemy into object (25 damage + object damage)

**Visual Feedback**:
- Combo counter UI: "Hit 1", "Hit 2", "Hit 3" above Marcus (0.5s display)
- Hit sparks on impact (color: white #FFFFFF)
- Screen shake on heavy hits (2-3 pixels, 0.2s duration)

---

### 5. Dodge System (`scripts/components/dodge_system.gd`)

**Dodge Mechanics**:
- **Duration**: 0.4s total
- **Invincibility window**: First 0.15s ("perfect dodge" = 150ms frame-perfect window)
- **Distance**: 120px in movement direction (or 180px if sprinting)
- **Cooldown**: 0.3s after dodge completes (prevents spam)

**Perfect Dodge Bonus** (award-level polish):
- If dodge input within 0.15s of enemy attack impact → "PERFECT DODGE" text appears
- Triggers slow-motion: 2.0s at 0.5x speed (player can still act)
- Next attack guaranteed to hit (auto-aim, no dodge possible)
- Visual: Screen desaturates, time scale = 0.5, audio pitch drops

**Directional Dodge**:
- Dodging toward enemy = short (80px), aggressive roll (0.3s)
- Dodging away = long (150px), defensive retreat (0.5s)
- Dodging sideways = medium (120px), neutral (0.4s)

**Visual Feedback**:
- Dodge trail: Semi-transparent afterimage follows Marcus (0.2s fade)
- Dust particles at start/end positions
- Audio: Roll sound (pitch varies by direction)

---

### 6. Block/Parry System (`scripts/components/block_parry_system.gd`)

**Block**:
- **Damage reduction**: 60% frontal damage (attacks from behind = full damage)
- **Stamina cost**: 5 stamina per second (max stamina = 100)
- **Guard break**: After 3s continuous blocking (20s stamina drain), Marcus is stunned for 1.0s
- **Visual**: Marcus raises arms, blue shield effect in front (120° arc, 80px radius)

**Parry** (advanced technique):
- **Window**: Press block within 0.2s (200ms) of attack impact
- **Effect**: Deflect attack, stagger enemy for 1.5s, next attack is guaranteed critical (2x damage)
- **Visual**: Bright flash (white #FFFFFF, 0.1s), "PARRY!" text appears
- **Audio**: Sharp metallic clang (pitch +20%)

**Stamina System**:
- Max stamina: 100
- Regen: 10 stamina per second (not while blocking)
- Cost: Dodge = 20, Block = 5/sec, Parry = 0 (free if timed right)
- Visual: Stamina bar below health (green #4A90E2, depletes to red #E24A4A)

---

### 7. Hitbox/Hurtbox System (`scripts/components/hitbox.gd`, `scripts/components/hurtbox.gd`)

**Hitbox** (on attacks):
```gdscript
@export var damage: int = 10
@export var knockback: float = 200.0
@export var hitstun: float = 0.5  # Seconds enemy is stunned
@export var active_frames: float = 0.1  # How long hitbox is active

func _on_body_entered(body):
    if body is Enemy:
        body.take_damage(damage, knockback, hitstun)
        # Prevent double hits from same attack
        set_deferred("disabled", true)
        get_tree().create_timer(active_frames).connect("timeout", Callable(self, "enable"))
```

**Hurtbox** (on characters):
```gdscript
func take_damage(amount: int, knockback_force: float, stun_time: float):
    current_health -= amount
    if current_health <= 0:
        die()
    else:
        enter_hitstun(stun_time)
        apply_knockback(knockback_force)
        emit_signal("health_changed", current_health, max_health)
```

**Debugging**:
- Toggle hitbox visualization (F4 in debug mode)
- Hitboxes show as red wireframes, hurtboxes as green
- Console log: "Marcus hit Scavenger for 10 damage (25 health remaining)"

---

### 8. Enemy: Scavenger (`scenes/enemies/enemy_scavenger.tscn`)

**Stats**:
- Health: 50 (dies in 5 light attacks, 3 heavy attacks)
- Damage: 10 per hit (Marcus max health = 100, dies in 10 hits)
- Speed: 200 px/s (slower than Marcus sprint)

**AI State Machine** (deterministic, no randomness):
```gdscript
enum AIState {
    IDLE,           # Standing, scanning for player
    APPROACH,       # Moving toward player
    WINDUP,         # Preparing attack (0.5s telegraph)
    STRIKE,         # Attacking (0.2s active)
    RECOVERY,       # Post-attack (0.3s vulnerable)
    HITSTUN,        # Just got hit
    DEFEATED        # Health = 0
}
```

**Behavior**:
- **IDLE**: Scan for player within 400px. If seen → APPROACH.
- **APPROACH**: Move directly toward player. Stop at 80px range → WINDUP.
- **WINDUP**: Raise weapon (0.5s telegraph, red glow #E24A4A). Player can dodge/parry. → STRIKE.
- **STRIKE**: Swing weapon (0.2s active, hitbox 90° arc, 80px range). → RECOVERY.
- **RECOVERY**: Lower weapon (0.3s). Can't act. → IDLE.
- **HITSTUN**: Flash white, can't move (0.5s). → IDLE.

**Telegraph**:
- Windup: Enemy glows red, weapon raises, audio charge sound (rising pitch)
- Strike: Weapon swings, white flash, whoosh sound
- Recovery: Enemy slumps, gray color, vulnerable

**Health Bar**:
- Position: Above enemy (red bar #E24A4A, 60x8px)
- Visibility: Always visible in combat, fades after 2s out of combat
- Damage numbers: Pop up on hit (white text, 0.5s fade)

---

### 9. Grab/Throwable Object System (`scripts/components/grab_system.gd`, `scenes/components/throwable_object.tscn`)

**Grab Mechanics**:
- **Input**: Press `grab` (G or Y) near grabbable object/enemy
- **Range**: 60px in front of Marcus
- **Grabbable objects**: Crates, barrels, pipes, signs, car parts, fuel canisters
- **Grabbed state**: Object attaches to Marcus's hands, moves with him
- **Movement**: Marcus can walk while holding (speed reduced to 0.7x)

**Throw Mechanics**:
- **Input**: Press `attack_light` or `attack_heavy` while holding
- **Direction**: Throw in facing direction (or toward crosshair if using mouse)
- **Force**: Light throw = 400 force, heavy throw = 600 force
- **Trajectory**: Parabolic arc (visualized with dotted line while holding)

**Damage** (deterministic):
- **Light object** (crate, pipe): 10 damage on impact
- **Heavy object** (barrel, car part): 25 damage on impact
- **Fuel canister**: 40 damage + 50px radius explosion (affects all nearby)

**Object Behavior After Throw**:
- Light objects: Settle after 1s, can be re-grabbed
- Heavy objects: Settle after 2s, can be re-grabbed
- Fuel canisters: Explode on impact, destroyed (can't re-grab)

**Visual Feedback**:
- Grab: Marcus lifts object (visible in hands), strain grunt
- Throw: Marcus throws (animation varies by object), throw grunt
- Impact: Object hits enemy/wall, dust/debris particles, impact sound

---

### 10. Combat Arena (`scenes/levels/marcus_combat_arena.tscn`)

**Environment**:
- Arena size: 800x600px (fits ~5 enemies comfortably)
- Walls: StaticBody2D with collision (invisible or debug texture)
- Floor: Colored rectangle (neutral gray #606060)
- Lighting: DirectionalLight2D, even illumination

**Throwables** (5-7 objects):
- 3 crates (light, 10 damage)
- 2 barrels (heavy, 25 damage)
- 1 fuel canister (explosive, 40 damage + AoE)
- 1 pipe (light, can be used as melee weapon—15 damage)

**Enemies** (3-5 Scavengers):
- Spawn at fixed positions (corners + center)
- Wave system: First 2 spawn at start, remaining 1-2 spawn after 5s or when first 2 defeated
- Arena lock: Doors close when combat starts, open when all defeated

**Encounter Flow**:
1. Marcus enters arena, doors close (lock until combat complete)
2. Wave 1 spawns (2 Scavengers), combat begins
3. After 5s or Wave 1 defeat, Wave 2 spawns (1-3 Scavengers)
4. All enemies defeated → doors open, arena complete
5. Score summary appears (see below)

**Score Summary** (feedback only, not story gate):
- Time: <30s = S, <45s = A, <60s = B, <90s = C, >90s = D
- Damage taken: 0 = "No Damage" bonus (+500 pts), <20 = "Minimal" (+200), <40 = "Moderate" (+100)
- Environmental throws: Each = +100 pts
- Clean clear: All S ratings = "Perfect Clear" (+1000 pts)
- Total score displayed with letter grade

---

### 11. Hit Feedback & Polish

**Hit Flash**:
- Enemy turns white (#FFFFFF) for 0.1s on hit
- Stacks up to 3 times (rapid hits = longer flash)
- Toggleable in options (reduced motion)

**Camera Shake**:
- Heavy hits: 3px shake, 0.2s duration
- Explosions: 5px shake, 0.4s duration
- Toggleable in options (reduced motion)

**Particles**:
- Hit sparks: White particles (5-10, spread 45°, lifespan 0.3s)
- Blood/decal: Red splatter on fatal hits (toggleable for gore sensitivity)
- Dust: On dodges, throws, heavy landings

**Damage Numbers** (optional, toggleable):
- Font: Bold, 18px, white with black outline
- Position: Above enemy head, floats upward (50px over 0.5s)
- Format: "10", "25", "40" (no decimals)
- Crits: Larger font (24px), yellow color #FFFF00 (not used in base game, reserved for future)

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Movement**: Marcus moves smoothly, sprint is 1.5x speed, dodge has invincibility frames. PASS/FAIL with profiler

2. **Three-hit combo**: Light→Light→Heavy works, launches enemy on hit 3, input buffering respects 0.5s windows. PASS/FAIL

3. **Perfect dodge**: 150ms window triggers 2s slow-mo, guaranteed next hit. PASS/FAIL with frame-perfect test

4. **Block/parry**: Block reduces 60% frontal damage, parry within 200ms staggers enemy, guarantees crit. PASS/FAIL

5. **Hitbox system**: No double hits from single attack, damage numbers match expected values, knockback consistent. PASS/FAIL

6. **Enemy AI**: Scavenger cycles through IDLE→APPROACH→WINDUP→STRIKE→RECOVERY deterministically, telegraphs readable. PASS/FAIL

7. **Grab/throw**: Marcus can grab crate, carry, throw in facing direction. Damage values correct (10/25/40). PASS/FAIL

8. **Arena combat**: 3-5 enemies spawn in waves, doors lock/unlock correctly, score summary displays. PASS/FAIL

9. **Hit feedback**: Hit flash, camera shake, particles all work, toggleable in options. PASS/FAIL

10. **Performance**: 60 FPS locked with 5 enemies, all particles, all effects. <1ms combat logic per frame. PASS/FAIL with profiler

---

## DO NOT

- Add randomization (all damage, timing, AI deterministic)
- Make enemies too tanky (5 light attacks = death for Scavenger)
- Create unavoidable attacks (all enemy moves telegraphed, dodgeable)
- Add complex combos beyond 3-hit base (save for later phases)
- Implement stamina costs for attacks (only dodge/block use stamina)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files
2. **Test results**: Each criterion PASS/FAIL with evidence
3. **Known limitations**: TODOs, technical debt
4. **Performance metrics**: FPS, combat logic time, memory
5. **Commit message**: Propose this exact message:

```
Phase 3: Marcus combat fundamentals complete

Award-level combat system with:
- 3-hit combo (Light→Light→Heavy launch), input buffering 0.5s
- Perfect dodge (150ms→2s slow-mo), parry (200ms→stagger+crit)
- Block (60% reduction), stamina system (100 max, 10/sec regen)
- Deterministic enemy AI (telegraphed, readable, no randomness)
- Grab/throw system (3 tiers: 10/25/40 damage)
- Style meter, hit flash, camera shake, damage numbers (all toggleable)
- 60 FPS locked with 5 enemies, <1ms combat logic

All 10 acceptance criteria PASS. Ready for Phase 4.
```
