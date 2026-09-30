You are continuing FINAL THAW in Godot 4.x. Read CLAUDE.md and inspect the existing project before editing. Phase 0 is complete with award-level technical foundation: 60 FPS locked, comprehensive Input Map, GameManager with robust save/load, accessible MainMenu and HUD.

**AWARD-LEVEL TARGET**: This movement system must feel as polished as *Hades* or *Celeste*. Smooth, responsive, predictable. No floatiness, no stiffness. Every input must have immediate, clear feedback.

GOAL
Implement Elena Vast's reusable movement, interaction, and scan foundation with award-winning polish.

CONTEXT
Elena is an atmospheric systems scientist. Her gameplay focuses on navigation, observation, environmental systems, terminals, and non-lethal puzzle interaction. Movement must feel intentional and readable—she's not a soldier, she's a scientist who moves with purpose.

## DELIVERABLES

### 1. Elena Character Scene (`scenes/characters/elena_character.tscn`)

Create CharacterBody2D with:
- **Collision**: CapsuleShape2D (width: 48px, height: 96px) or custom shape matching sprite
- **Sprite**: Placeholder (64x128px rectangle, blue color #4A90E2) with simple idle animation (subtle breathing: scale 1.0 to 1.02, 1.5 second loop)
- **Ground shadow**: Ellipse (40x20px, semi-transparent black #40000000), offset 10px below sprite, always visible for spatial clarity
- **Camera2D**: As child, smooth follow enabled (drag margin: 0.2), zoom: 1.0
- **InteractionArea**: Area2D child, collision shape 80px radius around character, detects interactables
- **ScanArea**: Area2D child, collision shape 200px radius, detects scan targets
- **AnimationTree**: For future animations (idle, walk, run, interact, scan)
- **AudioStreamPlayer2D**: For footstep sounds (to be added in Phase 2)

### 2. Elena Movement Script (`scripts/characters/elena_controller.gd`)

**Movement Constants** (exposed as @export for tuning):
```gdscript
@export var ACCELERATION: float = 30.0
@export var DECELERATION: float = 25.0
@export var MAX_SPEED: float = 300.0
@export var MIN_SPEED: float = 5.0  # Prevents sticking at low velocities
```

**Movement Implementation**:
- Read Input Map actions: `move_up`, `move_down`, `move_left`, `move_right`
- Calculate input vector, normalize if length > 1.0 (prevents faster diagonals)
- Apply acceleration/deceleration (not instant start/stop)
- Clamp velocity to MAX_SPEED
- Snap to grid when velocity < MIN_SPEED (prevents micro-sliding)
- Collision detection: Move and slide with wall collision

**Facing Direction**:
- Track last movement direction as `facing_vector` (Vector2)
- Update sprite flip_h based on facing_vector.x
- Used for interaction prompts, scan direction, future animations

**Boundary Collision**:
- Room boundaries defined by TileMap collision or static bodies
- Elena cannot leave playable area
- Test: Walk into every wall, verify collision is solid and consistent

**Performance**:
- Movement runs in `_physics_process(delta)`
- No allocations in movement loop (reuse vectors)
- Target: <0.1ms per frame for movement logic

### 3. Isometric/Top-Down Presentation

**Control Scheme** (document in comments):
- **Option A (Top-Down)**: Input directions map directly to screen directions (Up = screen up). Simplest, most intuitive for 2D.
- **Option B (Isometric)**: Input directions map to isometric axes (Up = up-right on screen). More immersive for 2.5D look.
- **Decision**: Use **Option A (Top-Down)** for clarity and accessibility. Document rationale in CLAUDE.md.

**Camera**:
- Follow Elena smoothly with drag margin
- Zoom level ensures Elena is ~10-15% of screen height
- No camera shake or rotation (reserved for combat/damage)

### 4. Interactable Component (`scripts/components/interactable.gd`)

**Interface** (all interactables must implement):
```gdscript
@export var display_name: String = ""  # Shown in prompt
@export var prompt_text: String = "Interact"  # Action verb
@export var enabled: bool = true  # Can be disabled temporarily
@export var interaction_range: float = 80.0  # Max distance for interaction

func interact(actor: Node2D) -> void:
    # Override in subclass
    pass

func get_prompt() -> String:
    return prompt_text if enabled else ""
```

**Base Interactable Scene** (`scenes/components/interactable_base.tscn`):
- Area2D with collision shape (configurable radius)
- Interactable script attached
- Visual indicator (sprite or label) showing interactable state
- Group: "interactables" for easy querying

**Example Interactables** (create at least 3 for test room):
1. **Terminal** (`terminal_interactable.gd`):
   - Prompt: "Access Terminal"
   - On interact: Open dialogue panel, show message
   - Visual: Screen glow when active

2. **Lever** (`lever_interactable.gd`):
   - Prompt: "Pull Lever"
   - On interact: Toggle state (on/off), animate lever rotation
   - Visual: Lever position changes, connected door/light responds

3. **Door** (`door_interactable.gd`):
   - Prompt: "Open Door" or "Locked"
   - On interact: Play open animation, change collision, update state
   - Visual: Door slides/fades open, sound effect

### 5. Nearest-Target Selection System

**Interaction Manager** (`scripts/components/interaction_manager.gd`):
- Attached to Elena as child node
- Monitors InteractionArea for nearby interactables
- Selects nearest interactable within range
- Tie-breaker: Stable node order (first in tree wins)

**Selection Logic**:
```gdscript
func get_nearest_interactable() -> Node2D:
    var interactables = InteractionArea.get_overlapping_bodies()
    var nearest = null
    var nearest_dist = INF
    
    for interactable in interactables:
        if not interactable.enabled:
            continue
        var dist = global_position.distance_to(interactable.global_position)
        if dist < nearest_dist:
            nearest = interactable
            nearest_dist = dist
    
    return nearest
```

**Prompt Display**:
- Show prompt UI element when nearest interactable is in range
- Format: "[E] {prompt_text} - {display_name}" (e.g., "[E] Access - Security Terminal")
- Position: Above Elena or near interactable (choose one, be consistent)
- Visibility: Fade in/out over 0.2 seconds (no popping)

### 6. Scan Input System

**Scan Functionality** (`scripts/components/scan_system.gd`):
- Activated by `scan` input (Q or Controller LB)
- Highlights all interactables within 200px radius
- Visual effect: Expanding ring pulse from Elena (2 second animation)
- Highlighted interactables: Brighter, outlined, or different color
- No cooldown, no state change—purely informational

**Visual Feedback**:
- Scan ring: Sprite with gradient texture, scales from 1.0 to 3.0 over 0.5 seconds, fades out
- Highlighted interactables: Emission color (cyan #00FFFF), intensity 0.5
- Audio: Subtle ping sound (to be added in Phase 2)

**Accessibility**:
- Scan works with visual indicators only (no audio required)
- Highlighted interactables also show text label "[SCANNED]" for screen readers
- Can be toggled off in options for players who find it distracting

### 7. Elena Test Room (`scenes/levels/elena_test_room.tscn`)

**Environment**:
- Floor: Colored rectangle (1920x1080px, neutral gray #808080)
- Walls: StaticBody2D with collision (invisible or debug texture)
- Lighting: DirectionalLight2D, even illumination, no dark corners
- Readability markers: Grid lines or subtle texture for movement reference

**Interactables Placement** (at least 3):
1. **Terminal**: Center-left, tests basic interaction
2. **Lever**: Center-right, tests state toggle (connects to door)
3. **Locked Door**: Far right, tests conditional interaction (requires lever pull)

**Scan Targets**:
- Place 5-10 interactables around room (some obvious, some hidden)
- Test scan highlights all within 200px
- Verify scan doesn't trigger interactions accidentally

**Instruction Panel**:
- UI label in corner: "WASD to move. E to interact. Q to scan."
- Always visible, high contrast text

### 8. GameManager Integration

**Update `game_manager.gd`**:
- Add `active_character_id` property (String, default "elena")
- Add `set_active_character(character_id: String)` function
- Add `get_active_character() -> String` function
- Emit `character_switched(character_id: String)` signal on change

**Purpose**: Prepares for Phase 8 (first joint mission) and Phase 12 (free switching). Do NOT implement switching yet—just infrastructure.

---

## ACCEPTANCE CRITERIA (MUST PASS)

1. **Movement smoothness**: Elena accelerates over ~0.3 seconds to max speed, decelerates similarly. No instant stops/starts. PASS/FAIL with profiler screenshot

2. **Normalized diagonals**: Diagonal movement speed equals cardinal movement speed (within 1%). Measure with debug overlay. PASS/FAIL

3. **Boundary collision**: Elena cannot leave room through any wall. Test all 4 walls + corners. PASS/FAIL

4. **Ground shadow**: Always visible, offset correctly, provides clear spatial reference. Screenshot evidence. PASS/FAIL

5. **Interaction prompt**: Appears at consistent distance (80px), shows correct text, disappears when out of range. Test all 3 interactables. PASS/FAIL

6. **Nearest-target selection**: When multiple interactables in range, prompt shows nearest. Move between two close interactables, verify prompt switches correctly. PASS/FAIL

7. **Scan system**: Highlights all interactables within 200px, visual ring effect works, no state changes. Test with 5+ interactables. PASS/FAIL

8. **Performance**: 60 FPS maintained in test room with all systems active. Profiler shows <0.5ms for movement logic. PASS/FAIL

9. **Save/load**: Elena's position, interactable states (lever on/off, door open/closed) persist after save/load. PASS/FAIL

10. **Accessibility**: All interactables navigable with keyboard (Tab cycle) and controller (D-pad). Focus visible. Screen reader can read all prompts. PASS/FAIL

---

## DO NOT

- Implement combat, attacks, or damage (Phase 3)
- Add complex animations beyond idle breathing (Phase 2+)
- Create final art—use placeholders only
- Implement character switching (Phase 12)
- Add randomness to movement or interaction
- Hardcode values that should be @export variables

---

## FINISH BY REPORTING

1. **Changed files**: List all new/modified files with descriptions
2. **Test results**: For each acceptance criterion, state PASS/FAIL with evidence (screenshots, profiler data)
3. **Known limitations**: Any unresolved issues, TODOs, or technical debt
4. **Performance metrics**: FPS in test room, movement logic time, interaction check time
5. **Commit message**: Propose this exact message:

```
Phase 1: Elena movement and observation complete

Award-level movement system with:
- Smooth acceleration/deceleration, normalized diagonals
- Deterministic nearest-target interaction selection
- Scan system with visual feedback (no state changes)
- 3 test interactables (terminal, lever, door)
- GameManager integration for future character switching
- Full accessibility (keyboard + controller navigation)

All 10 acceptance criteria PASS. 60 FPS maintained. Ready for Phase 2.
```
