You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing systems before editing. Phases 0–2 are complete with award-level foundation, Elena movement, and laboratory puzzles.

**AWARD-LEVEL TARGET**: Combat must feel as responsive and readable as *Hades* or *Devil May Cry*. Every attack has purpose, every enemy telegraph is clear, every system supports player expression. 60 FPS locked even with 10+ enemies, particles, and camera shake.

GOAL
Implement Marcus Reyes and deterministic isometric beat-'em-up combat foundation.

## CONTEXT
Marcus is a former police officer. His gameplay is direct action, protection, crowd control, environmental mastery. Combat must feel weighty but responsive—like a tired professional who moves efficiently, not a superhero.

---

## COMBAT DESIGN PHILOSOPHY (Hades + DMC Standard)

**Every combat system must**:
1. **Be readable**: Player always knows why they took damage (saw telegraph, missed dodge, etc.)
2. **Allow expression**: Multiple viable playstyles (aggressive rushdown, defensive counter, environmental mastery, crowd control)
3. **Reward mastery**: Skill ceiling high enough for speedrunners, floor low enough for casual players
4. **Stay deterministic**: No random crits, no RNG damage, no guesswork—pure skill

**No**:
- Random critical hits
- Unblockable attacks without clear telegraph
- Enemies that hit from off-screen without warning
- Damage fall-off based on RNG

---

## DELIVERABLES

### 1. Marcus Character Scene (`scenes/characters/marcus_character.tscn`)

**CharacterBody2D with**:
- **Collision**: CapsuleShape2D (width: 48px, height: 96px)
- **Sprite**: Placeholder (64x128px rectangle, orange color #E28C4A) with idle animation (subtle breathing, 1.5 second loop)
- **Ground shadow**: Ellipse (40x20px, semi-transparent black), offset 10px below sprite
- **Camera2D**: Smooth follow, drag margin 0.2, zoom 1.0
- **CombatState**: State machine child node (idle, move, attack, dodge, block, hitstun, defeated)
- **Health component**: `max_health: int = 100`, `current_health: int`, `is_invulnerable: bool`
- **Hitbox/Hurtbox**: Area2D children for attack detection
- **AudioStreamPlayer2D**: For attack sounds, hit sounds, footstep sounds

### 2. Movement with Combat Enhancements

**Constants**:
```gdscript
@export var ACCELERATION: float = 35.0  # Slightly higher than Elena for aggression
@export var DECELERATION: float = 30.0
@export var MAX_SPEED: float = 320.0    # Slightly faster than Elena
@export var SPRINT_MULTIPLIER: float = 1.4
@export var DODGE_SPEED: float = 800.0  # Burst speed during dodge
```

**Enhancements**:
- **Sprint**: Hold `sprint` input → movement speed ×1.4, stamina drain (if stamina system added later)
- **Dodge**: Tap `dodge` input → 0.3 second burst at DODGE_SPEED in movement direction
  - Invincibility frames: 0.15 seconds (150ms) from dodge start
  - Cooldown: 0.5 seconds (prevents spam)
  - Visual: Motion blur trail, temporary transparency (50% opacity)
- **Block**: Hold `block` input → 60% frontal damage reduction, stamina drain (optional)
  - Frontal: 90-degree cone in facing direction
  - Can't move while blocking (or very slow: 30% speed)

### 3. Combat State Machine (`scripts/components/combat_state_machine.gd`)

**States**:
- `IDLE`: No input, standing still
- `MOVE`: Moving, not attacking
- `LIGHT_ATTACK`: Three-hit combo sequence
- `HEAVY_ATTACK`: Slower, higher damage, launches enemy
- `COMBO`: Chaining attacks together
- `DODGE`: Invincible burst movement
- `BLOCK`: Damage reduction, frontal cone
- `HITSTUN`: Just took damage, brief stun (0.3 seconds)
- `GRAB`: Grabbing enemy or object
- `THROW`: Throwing grabbed object/enemy
- `DEFEATED`: Health ≤ 0, death animation

**Transitions**:
- IDLE → MOVE (on movement input)
- IDLE/MOVE → LIGHT_ATTACK (on light attack input)
- IDLE/MOVE → HEAVY_ATTACK (on heavy attack input)
- ANY → DODGE (on dodge input, if not in hitstun/defeated)
- ANY → BLOCK (on block hold)
- HITSTUN → IDLE (after 0.3 seconds)
- ANY → DEFEATED (when health ≤ 0)

**Implementation**:
```gdscript
enum State { IDLE, MOVE, LIGHT_ATTACK, HEAVY_ATTACK, COMBO, DODGE, BLOCK, HITSTUN, GRAB, THROW, DEFEATED }

var current_state: State = State.IDLE
var combo_count: int = 0  # 0-2 for three-hit combo
var combo_timer: float = 0.0  # Resets if no input within 1.0 second

func _physics_process(delta):
    match current_state:
        State.IDLE: _process_idle(delta)
        State.MOVE: _process_move(delta)
        State.LIGHT_ATTACK: _process_light_attack(delta)
        State.HEAVY_ATTACK: _process_heavy_attack(delta)
        State.DODGE: _process_dodge(delta)
        State.BLOCK: _process_block(delta)
        State.HITSTUN: _process_hitstun(delta)
        State.DEFEATED: _process_defeated(delta)
```

### 4. Three-Hit Combo System

**Combo Data** (use Resource for data-driven design):
```gdscript
class_name AttackData extends Resource

@export var startup_frames: int = 5      # Frames before active
@export var active_frames: int = 8       # Frames that can hit
@export var recovery_frames: int = 12    # Frames after active
@export var damage: int = 10
@export var knockback: float = 200.0
@export var hitstun_duration: float = 0.3
```

**Combo Sequence**:
- **Hit 1 (Light)**: Fast startup (5 frames), low damage (10), small knockback (200)
- **Hit 2 (Light)**: Same as Hit 1, but can only be input if Hit 1 connected
- **Hit 3 (Heavy)**: Slower startup (8 frames), high damage (25), launches enemy (knockback 500)

**Input Buffering**:
- Window: 0.5 seconds after each hit to input next attack
- If no input: Reset to IDLE after recovery frames
- If input during window: Queue next attack, execute immediately after recovery

**Implementation**:
```gdscript
func _process_light_attack(delta):
    attack_timer += delta
    
    if attack_timer < startup_time:
        # Startup: Can't hit yet, can cancel into dodge
        return
    elif attack_timer < startup_time + active_time:
        # Active: Check for hits
        var hits = attack_area.get_overlapping_bodies()
        for hit in hits:
            if hit.is_in_group("enemies") and not hit in already_hit_this_attack:
                hit.take_damage(damage, knockback, hitstun_duration)
                already_hit_this_attack.append(hit)
    else:
        # Recovery: Can't cancel, must wait out
        if attack_timer > total_attack_time:
            current_state = State.IDLE
            combo_count += 1
            if combo_count > 2:
                combo_count = 0  # Reset after three hits
```

### 5. Hitbox/Hurtbox System (`scripts/components/hitbox.gd`, `scripts/components/hurtbox.gd`)

**Hitbox** (on attacker):
- Area2D that detects overlaps with hurtboxes
- Active only during attack's active frames
- Prevents double-hits: Track `already_hit_this_attack` array
- Signal: `hit_registered(target: Node2D, damage: int, knockback: float)`

**Hurtbox** (on player/enemy):
- Area2D that detects overlaps with hitboxes
- On hit: Call `take_damage()` on parent character
- Signal: `damage_taken(amount: int, source: Node2D)`

**Implementation**:
```gdscript
# hitbox.gd
func _on_area_entered(area: Area2D):
    if area.is_in_group("hurtboxes"):
        var target = area.get_parent()
        if target.is_in_group("enemies") or target.is_in_group("player"):
            # Check if already hit this target in this attack
            if not target in already_hit:
                already_hit.append(target)
                target.hurtbox.take_damage(damage, knockback, hitstun_duration)
                emit_signal("hit_registered", target, damage, knockback)

# hurtbox.gd
func take_damage(amount: int, knockback: float, hitstun_duration: float):
    if get_parent().is_invulnerable:
        return
    
    get_parent().current_health -= amount
    get_parent().emit_signal("health_changed", get_parent().current_health)
    get_parent().apply_knockback(knockback)
    get_parent().enter_hitstun(hitstun_duration)
```

### 6. Health Component (`scripts/components/health.gd`)

**Properties**:
- `max_health: int = 100`
- `current_health: int = 100`
- `is_invulnerable: bool = false` (for dodge I-frames, hitstun)
- `on_health_changed`: Signal
- `on_death`: Signal

**Functions**:
- `take_damage(amount: int, knockback: float, hitstun_duration: float)`
- `heal(amount: int)` (for future power-ups)
- `set_invulnerable(duration: float)` (for dodge I-frames)

### 7. Enemy: Scavenger (`scenes/enemies/enemy_scavenger.tscn`)

**CharacterBody2D with**:
- **Sprite**: Placeholder (red rectangle #E24A4A, 64x128px)
- **Health**: 50 HP (dies in 5 light attacks or 2 heavy)
- **AI State Machine**: idle, approach, windup, strike, recovery, hitstun, defeated

**AI Behavior**:
- **Idle**: Patrol small area, detect player within 300px
- **Approach**: Move toward player at 200px/s
- **Windup**: 0.5 second telegraph (raise arms, red flash)
- **Strike**: Lunge forward 100px, deal 15 damage if hits
- **Recovery**: 0.3 second vulnerable window after strike
- **Hitstun**: 0.3 seconds when hit, can't act
- **Defeated**: Fall animation, ragdoll or fade out

**Implementation**:
```gdscript
enum State { IDLE, APPROACH, WINDUP, STRIKE, RECOVERY, HITSTUN, DEFEATED }

var state: State = State.IDLE
var target: Node2D = null
var attack_range: float = 60.0
var detection_range: float = 300.0

func _physics_process(delta):
    match state:
        State.IDLE:
            _process_idle(delta)
        State.APPROACH:
            _process_approach(delta)
        State.WINDUP:
            _process_windup(delta)
        State.STRIKE:
            _process_strike(delta)
        State.RECOVERY:
            _process_recovery(delta)
        State.HITSTUN:
            _process_hitstun(delta)
        State.DEFEATED:
            _process_defeated(delta)

func _process_idle(delta):
    # Look for player
    var players = get_tree().get_nodes_in_group("player")
    for player in players:
        if global_position.distance_to(player.global_position) < detection_range:
            target = player
            state = State.APPROACH
            return

func _process_approach(delta):
    if target == null or target.is_in_group("defeated"):
        state = State.IDLE
        return
    
    var dist = global_position.distance_to(target.global_position)
    if dist < attack_range:
        state = State.WINDUP
        return
    
    # Move toward target
    var direction = (target.global_position - global_position).normalized()
    velocity = direction * 200.0
    move_and_slide()
```

**Telegraph**:
- Visual: Enemy flashes red 0.5 seconds before strike
- Audio: Growl or weapon charge sound
- Animation: Arms raise, body leans back

**Hit Reaction**:
- Flash white 0.1 seconds on hit
- Knockback: Push back 100-300px depending on attack
- Hitstun: Can't act for 0.3 seconds

### 8. Grab/Throw System (`scripts/components/grab_system.gd`)

**Grab**:
- Input: `grab` button (G or Controller Y)
- Range: 80px in front of Marcus
- Valid targets: Enemies in hitstun, throwable objects (crates, barrels)
- State: `is_holding: bool`, `held_object: Node2D`

**Carry**:
- Held object follows Marcus with 0.2 second delay
- Marcus moves at 70% speed while holding
- Can't attack while holding (must throw first)

**Throw**:
- Input: `attack_light` or `attack_heavy` while holding
- Light throw: Toss forward 200px, 10 damage
- Heavy throw: Toss forward 400px, 25 damage, small AoE on impact
- Object settles or breaks after throw (configurable)

**Implementation**:
```gdscript
func try_grab():
    var candidates = grab_area.get_overlapping_bodies()
    for candidate in candidates:
        if candidate.is_in_group("enemies") and candidate.state == State.HITSTUN:
            held_object = candidate
            candidate.state = State.GRABBED
            is_holding = true
            return
        elif candidate.is_in_group("throwable") and not candidate.is_held:
            held_object = candidate
            candidate.is_held = true
            is_holding = true
            return

func throw(direction: Vector2, power: float):
    if held_object == null:
        return
    
    held_object.state = State.THROWN
    held_object.velocity = direction * power
    held_object.is_held = false
    held_object = null
    is_holding = false
```

### 9. Combat Arena Test Scene (`scenes/levels/marcus_combat_arena.tscn`)

**Environment**:
- Size: 80x60 tiles (1280x960px)
- Walls: StaticBody2D with collision (invisible or debug texture)
- Floor: Neutral gray, non-distracting
- Lighting: Even, no dark corners

**Enemies**:
- 3-5 Scavengers, spawned at start
- Spawn points: 5 positions around arena
- Aggro: All target Marcus on spawn

**Throwable Objects**:
- 5-10 crates/barrels scattered around arena
- Can be grabbed, carried, thrown
- Break on impact (particle effect, sound)

**Encounter Controller**:
- `is_active: bool` (true when enemies alive)
- Lock exits while active (invisible walls)
- On all enemies defeated: Unlock exits, show "Clear" message, play victory sound

**Score Display** (optional, feedback only):
- Time to clear
- Damage taken
- Environmental throws
- Combo rating (D-S based on performance)

### 10. Hit Feedback (Juice)

**Visual**:
- **Hit flash**: Enemy turns white for 0.1 seconds on hit
- **Camera shake**: 2-3 pixel shake on heavy hits (toggleable in options)
- **Damage numbers**: Pop up at hit location (optional, stylized font)
- **Blood/decal splatter**: On enemy death (toggleable for gore sensitivity)

**Audio**:
- **Attack sounds**: Light = sharp crack (0.1s), Heavy = deep thud (0.2s)
- **Hit sounds**: Meaty impact, varies by enemy type
- **Enemy vocalizations**: Grunt on hit (0.1s), death cry (0.3s)

**Particles**:
- **Hit sparks**: On metal enemies or deflected attacks
- **Blood droplets**: On organic enemies (8-12 particles, fade over 2s)
- **Dust clouds**: On heavy impacts or throws

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Combo system**: Three-hit combo executes correctly, input buffering works, combo resets after 1.0 second no input. Test 20+ combos. PASS/FAIL

2. **Dodge**: 150ms invincibility window verified (use debug overlay). Dodge cancels attack startup. Cooldown prevents spam. PASS/FAIL

3. **Block**: 60% frontal damage reduction (test with known damage values). 90-degree cone accurate. Can't move while blocking (or 30% speed). PASS/FAIL

4. **Hitbox system**: No double-hits from single attack. Already_hit tracking works. Multiple enemies can be hit with AoE attacks. PASS/FAIL

5. **Enemy AI**: Scavenger approaches, winds up (0.5s telegraph), strikes, recovers (0.3s vulnerable). Hitstun 0.3 seconds. All states transition correctly. PASS/FAIL

6. **Grab/throw**: Can grab hitstun enemies and throwables. Carry slows Marcus to 70% speed. Light throw 200px/10 dmg, heavy throw 400px/25 dmg. Objects break/settle correctly. PASS/FAIL

7. **Performance**: 60 FPS locked with 5 enemies, 10 throwables, particles active. Profiler shows <2ms for combat logic. PASS/FAIL

8. **Hit feedback**: Hit flash, camera shake, damage numbers all functional. Camera shake toggleable in options. Gore toggleable. PASS/FAIL

9. **Arena flow**: Enemies spawn, aggro Marcus. Exits locked while active. All defeated = exits unlock, "Clear" message. Victory sound plays. PASS/FAIL

10. **Save/load**: Marcus health, enemy states, arena state persist after save/load. No corruption. PASS/FAIL

---

## DO NOT

- Add final art—placeholders only
- Add randomness to damage or AI behavior
- Make enemies that can't be telegraphed
- Add more than 5 enemies in test arena (performance)
- Create unblockable attacks without clear 1.5s+ telegraph
- Allow softlocks (enemies stuck in walls, etc.)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files
2. **Test results**: Each acceptance criterion PASS/FAIL with evidence
3. **Known limitations**: Unresolved issues, TODOs
4. **Performance metrics**: FPS in arena, combat logic time, particle cost
5. **Commit message**: Propose this exact message:

```
Phase 3: Marcus combat fundamentals complete

Award-level combat system with:
- Three-hit combo with input buffering and attack data resources
- Perfect dodge (150ms i-frames), block (60% frontal reduction)
- Deterministic hitbox/hurtbox system (no double-hits)
- Enemy Scavenger with telegraphed AI (idle-approach-windup-strike-recovery)
- Grab/throw system for enemies and environmental objects
- Hit feedback (flash, camera shake, damage numbers, particles)
- Combat arena with encounter controller and score display

All 10 acceptance criteria PASS. 60 FPS locked. Ready for Phase 4.
```
