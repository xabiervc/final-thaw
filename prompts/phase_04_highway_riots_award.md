You are continuing FINAL THAW in Godot 4.x. Phases 0-3 complete with award-level foundation, Elena movement, puzzles, and Marcus combat.

**AWARD TARGET**: Combat arenas must match *Hades* flow—readable, fair, expressive. Every encounter teaches something new. No randomness, no cheap deaths.

GOAL: Build Marcus's Act I highway combat chapter. 4 arenas, enemy Enforcers, ArenaController, breakable barricades, environmental throws, score summary.

## DELIVERABLES

### 1. Highway Level (`scenes/levels/highway_level.tscn`)
- **Environment**: 4 arenas (800x600px each) connected by short traversal sections (200px corridors)
- **Art direction**: Cracked asphalt (#404040), guardrails (gray #808080), abandoned vehicles (placeholders), debris scattered, orange haze overlay (#40FF8000, 20% opacity)
- **Lighting**: DirectionalLight2D with orange tint (#FFA500), volumetric fog placeholder
- **Traversal**: Corridors have collision, no enemies, safe zones for breathing

### 2. Enemy Enforcer (`scenes/enemies/enemy_enforcer.tscn`)
- **Stats**: Health 100, max_speed 150 px/s (slower than Scavenger), damage 20 per hit
- **Block pattern**: Every 3s, raises shield (1.5s duration, 70% frontal damage reduction). Telegraph: Shield glow blue (#4A90E2) for 0.5s before activation
- **Counter pattern**: If player hits during Enforcer's windup, counter-attacks immediately (15 damage, unavoidable). Telegraph: Red flash (#E24A4A), 0.2s window
- **Flank weakness**: Attacks from behind (180° arc) deal 100% damage (no reduction)
- **Environmental weakness**: Throwables deal 2x damage (light=20, heavy=50, explosive=80)
- **AI**: APPROACH (slow, deliberate) → WINDUP (1.0s, red glow) → STRIKE (0.3s, 20 damage) → RECOVERY (0.5s, vulnerable) → BLOCK (optional, 1.5s) → repeat

### 3. ArenaController (`scripts/components/arena_controller.gd`)
```gdscript
@export var enemy_waves: Array[EnemyWave]  # Define in inspector
@export var doors: Array[Node2D]  # Arena exit doors
var current_wave: int = 0
var enemies_defeated: int = 0

func start_combat():
    doors.forEach(func(d): d.locked = true)
    spawn_wave(current_wave)

func on_enemy_defeated():
    enemies_defeated += 1
    if enemies_defeated >= enemy_waves[current_wave].enemy_count:
        current_wave += 1
        if current_wave < enemy_waves.size():
            spawn_wave(current_wave)  # Next wave
        else:
            end_combat()  # All waves clear

func end_combat():
    doors.forEach(func(d): d.locked = false)
    emit_signal("arena_complete")
```
- **Fixed spawn lists**: No randomness—enemies spawn at predefined positions
- **Locked exits**: Doors locked while combat active, unlock when all waves defeated
- **Checkpoint**: After arena complete, auto-save and set checkpoint

### 4. Arena Progression
- **Arena 1**: 3 Scavengers (single wave). Teaches basic combat.
- **Arena 2**: 2 Scavengers + 1 Enforcer (two waves: Scavengers first, then Enforcer). Teaches Enforcer block/counter.
- **Arena 3**: 2 Scavengers + 2 Enforcers + 5 throwables (two waves: mixed). Teaches environmental combat and flank positioning.
- **Arena 4**: 3 Scavengers + 2 Enforcers + fuel canisters + breakable barricade (three waves). Final test combining all mechanics.

### 5. Breakable Barricades (`scenes/components/breakable_barricade.tscn`)
- **Health**: 50 (breaks in 5 light attacks, 3 heavy, 2 explosive throws)
- **Visual**: Wooden planks (#8B4513), cracks appear at 50% health (25 HP), sparks on hit
- **Destruction**: When health ≤ 0, planks scatter (particle effect), collision disabled, path opens
- **At least one reveals optional shortcut**: Secret area with memory fragment or extra throwables. Never blocks critical path.

### 6. Environmental Throws (Expanded)
- **Pipes**: Light (10 damage, 400 force), cylindrical shape, rolls after throw
- **Signs**: Medium (15 damage, 500 force), flat shape, spins in air
- **Car parts**: Heavy (25 damage, 600 force), irregular shape, high impact
- **Fuel canisters**: Explosive (40 damage + 50px radius AoE, 2s fuse after throw, visible timer)

### 7. Route-Clearing Score Summary
- **Time**: <30s=S, <45s=A, <60s=B, <90s=C, >90s=D
- **Damage taken**: 0="No Damage" (+500), <20="Minimal" (+200), <40="Moderate" (+100)
- **Environmental throws**: Each +100 pts
- **Clean clear**: All S ratings = "Perfect Clear" (+1000 pts)
- **Display**: UI panel after Arena 4, shows total score, letter grade, breakdown

### 8. Narrative
- **Start**: "Helix patrols. Displaced groups. Everyone fighting over scraps. Just another day."
- **Between sections**: Short messages ("This highway used to connect cities. Now it connects graves." / "Marcus's old unit insignia on that barricade. He remembers the orders.")
- **Ending**: "Route clear. But the proof... his old unit. Reassigned. 'Terminate if capture fails.' Elena's name on the order."
- **Evidence flag**: `GameManager.story_flags["marcus_evidence_found"] = true`

## ACCEPTANCE CRITERIA
1. All 4 arenas completable fresh and after checkpoint load. PASS/FAIL
2. Enforcer block/counter patterns readable, consistent, punishable. PASS/FAIL
3. ArenaController spawns fixed waves, locks/unlocks doors correctly. PASS/FAIL
4. Breakable barricades destroy at 50 HP, at least one reveals optional shortcut. PASS/FAIL
5. Environmental throws deal correct damage (10/15/25/40+AoE). PASS/FAIL
6. Score summary displays correctly with all categories. PASS/FAIL
7. Narrative messages skippable, evidence flag set. PASS/FAIL
8. 60 FPS locked with 5 enemies, all effects. PASS/FAIL

**Commit**: `Phase 4: highway riots combat complete`
