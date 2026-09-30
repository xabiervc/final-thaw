You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect existing systems before editing. Phases 0–2 are complete.

**AWARD-LEVEL TARGET**: This implementation must meet The Game Awards / D.I.C.E. / BAFTA standards. Combat must feel as responsive and readable as *Hades* or *Devil May Cry*. 60 FPS locked is non-negotiable. All accessibility features must be implemented from day one.

GOAL
Implement Marcus Reyes and a compact, deterministic isometric beat-'em-up combat foundation with award-winning flow and polish.

## CONTEXT

Marcus is a former police officer. His gameplay is direct action, protection, crowd control, cover, grabs, and environmental use. Combat must feel readable and weighty, but stay technically modest.

## DELIVERABLES

### 1. Marcus Character Scene (`scenes/characters/marcus_character.tscn`)

**Structure**:
```
Marcus (CharacterBody2D)
├─ CollisionShape2D (capsule, 48x64 pixels)
├─ Sprite (placeholder: orange rectangle, 64x64)
├─ Shadow (ellipse, slightly offset)
├─ Camera2D (smooth follow, drag margin 0.1)
├─ HealthComponent (see below)
├─ HitboxHurtbox (see below)
└─ StateMachine (idle, move, light_attack, heavy_attack, combo, dodge, block, hitstun, grab, throw, defeated)
```

**Requirements**:
- Health: 100 HP base, visible health bar in HUD
- Stamina: 50 points, regenerates 5/sec, used for dodge/block/sprint
- Movement: Same smooth acceleration/deceleration as Elena (Phase 1)

### 2. Combat State Machine

**States**:
- **idle**: No input, standing still
- **move**: Moving with input vector
- **light_attack**: Fast attack (200ms startup, 100ms active, 300ms recovery), 15 damage
- **heavy_attack**: Slow attack (400ms startup, 200ms active, 500ms recovery), 30 damage, launches
- **combo**: Light→Light→Heavy sequence (auto-chains if input timed correctly)
- **dodge**: Invincibility frames (150ms perfect dodge window), 15 stamina cost
- **block**: Reduces 60% frontal damage, drains 10 stamina/sec, breaks after 3 seconds continuous
- **hitstun**: 0.5s invincibility after taking damage
- **grab**: Grabs throwable object or enemy (1.5s windup, ungrabable)
- **throw**: Throws grabbed object/enemy in facing direction (40 damage + knockback)
- **defeated**: HP <= 0, plays death animation, triggers checkpoint reload

**Code Structure**:
```gdscript
# scripts/characters/marcus.gd
extends CharacterBody2D

enum State { IDLE, MOVE, LIGHT_ATTACK, HEAVY_ATTACK, COMBO, DODGE, BLOCK, HITSTUN, GRAB, THROW, DEFEATED }
var current_state: State = State.IDLE
var health: int = 100
var stamina: int = 50
var combo_count: int = 0
var style_meter: float = 1.0  # 1.0-3.0 multiplier

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            handle_idle_input()
        State.MOVE:
            handle_movement()
        State.LIGHT_ATTACK:
            handle_attack("light")
        State.HEAVY_ATTACK:
            handle_attack("heavy")
        State.DODGE:
            handle_dodge()
        State.BLOCK:
            handle_block()
        # ... etc
```

### 3. Combo System

**Three-Hit Base Combo**:
- Input: Light → Light → Heavy (within 1.5s windows)
- Effect: 15 dmg → 15 dmg → 30 dmg + launch
- Combo extensions: After launch, can juggle with aerial attacks or environmental throws

**Style Meter** (D → C → B → A → S):
- **D (1.0x)**: Base damage, no variety
- **C (1.2x)**: 5+ hit combo, some variety
- **B (1.5x)**: 10+ hit combo, environmental use
- **A (2.0x)**: 15+ hit combo, no damage taken
- **S (3.0x)**: 20+ hit combo, perfect dodge used, environmental kills

**Visual Feedback**:
- Combo counter: "12 HIT COMBO" (top-center, fades after 3s)
- Style meter: Letter grade (D/C/B/A/S) with multiplier (1.0x-3.0x)
- Damage numbers: Optional (toggle in accessibility)

### 4. Dodge & Parry System

**Dodge Mechanics**:
- Input: `dodge` action (Space or Controller B)
- Cost: 15 stamina
- Invincibility: 150ms perfect dodge window (triggers slow-mo 2s), 500ms total i-frames
- Directional: Toward enemy = short aggressive roll (200 pixels), away = long defensive retreat (400 pixels)

**Perfect Dodge**:
- Window: 150ms before attack connects
- Effect: Triggers slow-mo (2 seconds), guarantees counter-attack opportunity
- Visual: Screen desaturates, enemy freezes briefly, Marcus glows
- Audio: Time-slow "whoosh" sound

**Parry System**:
- Input: Block within 200ms of impact
- Effect: Deflects attack, staggers enemy 1.5s, opens for critical hit (2x damage)
- Visual: Marcus weapon/arms flash white, enemy sparks
- Audio: Metal "clang" sound

### 5. Hitbox/Hurtbox Components

**Hitbox** (on attacks):
```gdscript
# scripts/components/hitbox.gd
class_name Hitbox
extends Area2D

@export var damage: int = 15
@export var knockback: float = 200.0
@export var attack_type: String = "light"  # light, heavy, environmental

var has_hit: Array = []  # Prevents double-hitting same enemy

func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D and body not in has_hit:
        if body.has_method("take_damage"):
            body.take_damage(damage, knockback, global_position)
            has_hit.append(body)
            yield(get_tree().create_timer(0.5), "timeout")
            has_hit.clear()
```

**Hurtbox** (on characters):
```gdscript
# scripts/components/hurtbox.gd
class_name Hurtbox
extends Area2D

func take_damage(amount: int, knockback_force: float, source_position: Vector2) -> void:
    var character = get_parent()
    if character.has_method("apply_damage"):
        character.apply_damage(amount, knockback_force, source_position)
```

**Requirements**:
- No double-hits from single attack (has_hit array prevents)
- Easy to debug (print on hit, visible hitbox in debug mode)
- Knockback direction calculated from source_position

### 6. Enemy Scavenger AI

**State Machine**:
- **idle**: Patrols small area, looks for player
- **approach**: Moves toward player (300 pixels/sec)
- **windup**: 0.5s telegraph (arm raise, grunt audio)
- **strike**: Attacks (15 damage, 200 knockback)
- **recovery**: 0.3s punishable window (vulnerable)
- **hitstun**: 0.5s after taking damage
- **defeated**: HP <= 0, plays death animation

**AI Behavior**:
- **Flanking**: 3+ enemies automatically attempt surround (player back exposed = 50% damage increase)
- **Telegraph hierarchy**: Small enemy = 0.5s windup, visible arm raise
- **Adaptive aggression**: If player kills quickly, enemies become cautious (more blocking, slower approach). If player passive, enemies become aggressive (faster attacks, more risks)
- **Communication**: Enemies call out player position ("Behind you!", "He's low!", "Watch the left!")—diegetic audio cues

**Visual Feedback**:
- Health bar: Visible above enemy (red, depletes on damage)
- Telegraph: Arm raise + red flash before strike
- Hit reaction: Knockback on hit, stagger on heavy, launch on combo ender

### 7. Environmental Combat

**Throwable Objects** (3 tiers):
- **Light debris** (pipes, signs): 10 damage, light knockback
- **Crates/barrels**: 25 damage, medium knockback, can break on impact
- **Fuel canisters**: 40 damage + AoE (20 damage to nearby enemies), explosion visual/audio

**Grab/Throw System**:
- Marcus can grab eligible objects (Interactable + Throwable components)
- Carry: Object follows Marcus at offset (over shoulder visual)
- Throw: Object travels in facing direction (500 pixels/sec), damage on impact

**Environmental Kills**:
- **Wall splat**: Knock enemy into wall = 1.5s stun + 15 bonus damage
- **Ledge finisher**: Knock off elevated platform = instant kill (small enemies) or 50 damage (large)
- **Hazard use**: Lure enemies into fire, electricity, toxic water = environmental kill

### 8. Combat Arena (`scenes/levels/marcus_combat_arena.tscn`)

**Layout**:
- Walls: Collision boundaries (800x600 pixels)
- Floor: Neutral gray with subtle grid
- Spawn points: 3-5 fixed enemy spawn locations
- Throwable objects: 3-5 placed strategically (crates, barrels, fuel canister)
- Encounter start/end state: Gates lock on start, unlock on all enemies defeated

**Wave System**:
- Wave 1: 2 Scavengers (introduction)
- Wave 2: 3 Scavengers (crowd management)
- Wave 3: 2 Scavengers + 1 Enforcer (tank enemy, high HP, slow)

**Score Display**:
- Time: Seconds to clear arena
- Damage taken: HP lost
- Environmental throws: Count
- Clean-clear bonus: No damage taken = +500 points
- Total score: Displayed on arena clear

### 9. Hit Feedback & Polish

**Visual**:
- Hit flash: Enemy turns white for 100ms on hit
- Screen shake: 2-3 pixels on heavy hits (toggleable in accessibility)
- Particles: Blood/decal splatter on hit (toggleable for gore sensitivity)
- Damage numbers: Optional (stylized font, fades after 2s)

**Audio**:
- Attack sounds: Light = sharp crack, Heavy = deep thud
- Enemy vocalizations: Grunts on hit, shouts on attack, death cries
- Environmental: Glass shatters, metal screeches, wood splinters

**Camera**:
- Combat zoom: Camera pulls back slightly during combat (wider FOV)
- Shake on heavy hits (toggleable)
- Smooth follow, no jerky movements

### 10. Accessibility

**Motor**:
- **Slow-mo mode**: 0.5x, 0.75x, 1.0x options (always available, no penalty)
- **Aim assist**: 0-100% slider for throwable targeting
- **Reduced camera shake**: Toggle in options
- **Toggle/hold**: All hold actions can be toggled (block, grab, aim)

**Visual**:
- **Colorblind-safe**: Enemy telegraphs use animation + audio, not color alone
- **High contrast**: Enemies outlined in bright colors
- **Reduced particles**: Option to reduce blood/gore

**Cognitive**:
- **Combat hints**: Optional ("Dodge now!", "Parry opportunity!")
- **Extended parry window**: +50ms option (200ms → 250ms)
- **Reduced enemy count**: Option to reduce waves (3 enemies → 2 enemies)

### 11. HUD Integration

**Combat HUD Elements**:
- Health bar: Marcus HP (100 max, red bar)
- Stamina bar: Marcus stamina (50 max, yellow bar)
- Combo counter: "12 HIT COMBO" (top-center)
- Style meter: Letter grade (D/C/B/A/S) with multiplier (1.0x-3.0x)
- Enemy health bars: Visible above each enemy
- Score display: Time, damage, environmental throws, total

**Accessibility**:
- All text scalable (75%-200%)
- High contrast mode compatible
- Colorblind-safe (icons + text, not color alone)

### 12. Testing Checklist

- [ ] Marcus completes arena with all combat options (light, heavy, dodge, block, grab, throw)
- [ ] Enemy telegraphs readable, AI deterministic (no randomness)
- [ ] Hitbox system no double-dipping (one attack = one hit)
- [ ] Style meter functional, D→S progression clear
- [ ] Perfect dodge triggers slow-mo, guarantees counter
- [ ] Parry deflects, staggers, opens for critical
- [ ] Environmental combat functional (throwables, wall splats, ledge finishers)
- [ ] Score display accurate (time, damage, bonuses)
- [ ] Accessibility options functional (slow-mo, aim assist, reduced shake)
- [ ] 60 FPS maintained during combat (particles, screen shake, multiple enemies)

---

## ACCEPTANCE CRITERIA (MUST ALL PASS)

1. **Movement Smooth**: Marcus accelerates/decelerates smoothly, same feel as Elena. Sprint functional. **PASS/FAIL**: [Test evidence]

2. **Combo System**: Light→Light→Heavy chains correctly, launches enemy. **PASS/FAIL**: [Test evidence]

3. **Style Meter**: D→S progression works, multiplier affects damage (1.0x-3.0x). **PASS/FAIL**: [Test evidence]

4. **Dodge**: Invincibility frames work, directional dodge functional, perfect dodge triggers slow-mo. **PASS/FAIL**: [Test evidence]

5. **Parry**: Block within 200ms deflects, staggers enemy, opens for critical. **PASS/FAIL**: [Test evidence]

6. **Hitbox System**: No double-hits from single attack, knockback direction correct. **PASS/FAIL**: [Test evidence]

7. **Enemy AI**: Scavenger state machine functional, flanking behavior works, adaptive aggression responsive. **PASS/FAIL**: [Test evidence]

8. **Environmental Combat**: Throwables deal correct damage, wall splats stun, ledge finishers kill. **PASS/FAIL**: [Test evidence]

9. **Visual Feedback**: Hit flash, screen shake, damage numbers (optional) all functional. **PASS/FAIL**: [Test evidence]

10. **Audio Feedback**: Attack sounds distinct, enemy vocalizations clear, environmental audio works. **PASS/FAIL**: [Test evidence]

11. **Accessibility**: Slow-mo mode functional, aim assist works, reduced shake toggle effective. **PASS/FAIL**: [Test evidence]

12. **Performance**: 60 FPS locked during combat (3+ enemies, particles, screen shake), <16ms frame time. **PASS/FAIL**: [Profiler screenshot]

---

## DO NOT

- Add randomness to combat (no random critical hits, no RNG damage)
- Make enemies unavoidable or instant-kill
- Create cheap hits (all enemy attacks must be telegraphed and dodgeable)
- Allow softlocks (enemies must always be defeatable)
- Use color-only telegraphs (always animation + audio)

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with brief descriptions
2. **Test results**: For each of 12 acceptance criteria, state PASS/FAIL with evidence
3. **Known limitations**: Any unresolved issues, TODOs, or technical debt
4. **Performance metrics**: FPS in combat arena, frame time, memory usage
5. **Commit message**: Propose this exact message:

```
Phase 3: Marcus combat fundamentals complete

Award-level implementation with:
- Hades+DMC combat flow (smooth, responsive, readable)
- Combo system with style meter (D-S, 1.0x-3.0x multiplier)
- Perfect dodge (150ms window, 2s slow-mo), parry system (200ms deflect)
- Enemy AI with flanking, adaptive aggression, diegetic communication
- Environmental combat (throwables, wall splats, ledge finishers)
- Accessibility (slow-mo, aim assist, reduced shake, colorblind-safe)
- 60 FPS locked, no double-hit bugs

All 12 acceptance criteria PASS. Ready for Phase 4.
```
