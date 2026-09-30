# FINAL THAW — Technical Excellence Standards
## Target: Performance of Hades, Polish of Celeste

**Goal**: 60 FPS locked on minimum spec, <100ms input latency, <2s scene transitions, zero bugs in release build.

---

## Performance Targets

### Minimum Specification

**Target Hardware**:
- GPU: GTX 1060 6GB / RX 580 8GB
- CPU: Intel i5-8400 / AMD Ryzen 5 2600
- RAM: 16 GB
- Storage: SSD (HDD acceptable with longer load times)
- OS: Windows 10 64-bit

**Performance Requirements**:
- 60 FPS locked (no dips below 58 FPS)
- <100ms input latency (from input to on-screen response)
- <2 second scene transitions
- <500 MB VRAM usage
- <4 GB system RAM usage
- 0 crashes, 0 softlocks, 0 corrupted saves

---

### Recommended Specification

**Target Hardware**:
- GPU: RTX 3060 / RX 6700 XT
- CPU: Intel i7-10700K / AMD Ryzen 7 3700X
- RAM: 32 GB
- Storage: NVMe SSD

**Performance Requirements**:
- 60 FPS locked
- Optional 120 FPS mode (unlocked)
- <50ms input latency
- <1 second scene transitions
- Enhanced visual settings (higher resolution textures, more particles, better shadows)

---

## Optimization Strategies

### Rendering

**Batching**:
- Use Godot 4.x batching for 2D sprites
- Combine static sprites into atlases where possible
- Limit unique materials/shaders per scene (<10 per visible area)

**Level of Detail (LOD)**:
- Background elements: reduce detail at distance
- Particle systems: scale count based on GPU performance tier
- Shadows: dynamic resolution, lower for distant objects

**Culling**:
- Occlusion culling for indoor scenes
- Distance culling for particles, decorative elements
- Frustum culling enabled (Godot default)

**Post-Processing**:
- Limit to essential effects only (bloom, color correction)
- Provide quality tiers: Low, Medium, High, Ultra
- Low = disabled, Medium = 50% resolution, High = full, Ultra = +ambient occlusion

---

### Physics

**Physics Ticks**:
- Fixed at 60 Hz (matches display refresh)
- Do NOT increase for "smoothness"—use interpolation instead
- Limit active physics bodies per scene (<100 active at once)

**Collision Layers**:
- Use layers/masks efficiently (don't check collisions that can't happen)
- Disable collision for off-screen objects
- Use Area2D for triggers, not physics bodies

**Character Movement**:
- Use CharacterBody2D with move_and_slide()
- Avoid continuous collision detection unless necessary
- Cache collision results, don't query every frame

---

### Memory Management

**Resource Loading**:
- Load scenes asynchronously (use ResourceLoader.load_interactive())
- Unload unused resources (ResourceLoader.unload())
- Pool frequently instantiated objects (enemies, particles, projectiles)

**Texture Memory**:
- Use VRAM compression (Godot 4.x Basis Universal or ETC2)
- Limit texture sizes (max 2048x2048 for hero assets, 512x512 for most)
- Use texture atlases for UI elements

**Audio Memory**:
- Stream long audio (music, ambient) instead of loading fully
- Compress SFX appropriately (44.1kHz, 16-bit for most, 22kHz for distant/quiet)
- Limit simultaneous audio voices (<32 active)

---

### Code Quality

**GDScript Best Practices**:
- Use static typing where possible (`var health: int = 100`)
- Avoid `_process()` for logic that can be `_physics_process()` or timer-based
- Cache node references in `_ready()`, don't call `get_node()` every frame
- Use signals for decoupled communication (not `get_node().some_function()`)
- Profile with Godot 4.x profiler, optimize hot paths only

**Example Good Pattern**:
```gdscript
# GOOD: Cached reference, typed, physics-based
var health: int = 100
var health_bar: ProgressBar

func _ready():
    health_bar = $HealthBar

func _physics_process(_delta):
    if health <= 0:
        die()

func take_damage(amount: int):
    health -= amount
    health_bar.value = health
```

**Example Bad Pattern**:
```gdscript
# BAD: Uncached, untyped, process every frame
var health = 100

func _process(delta):
    var bar = get_node("HealthBar")  # Called every frame!
    bar.value = health
    if health <= 0:
        die()
```

---

## Input Latency Optimization

### Target: <100ms end-to-end

**Sources of Latency**:
1. Input polling: ~8ms (Godot default)
2. Game logic processing: <16ms (one physics frame)
3. Rendering: <16ms (one frame at 60 FPS)
4. Display lag: varies (10-50ms typical)

**Optimization**:
- Use `_input()` or `_unhandled_input()` for immediate response
- Avoid input buffering unless necessary (fighting game precision)
- Render at same rate as physics (60 Hz locked)
- Disable V-Sync if it adds >1 frame latency (provide option)
- Use "Low Latency Mode" in graphics drivers (NVIDIA Reflex equivalent)

**Testing**:
- Use high-speed camera (240 FPS) to measure input-to-response
- Compare with reference titles (Hades, Celeste, Super Meat Boy)
- Target: <100ms total, <50ms is excellent

---

## Scene Transition Optimization

### Target: <2 seconds (loading + fade)

**Strategies**:
- Preload next scene in background (use loading screen with tips)
- Use animated wipes/fades to mask loading time
- Split large levels into connected sub-scenes
- Keep persistent objects (GameManager, player) in autoloads, not scenes

**Example Loading Pattern**:
```gdscript
func transition_to_scene(scene_path: String):
    # Show loading screen
    $LoadingScreen.visible = true
    
    # Preload in background
    var loader = ResourceLoader.load_interactive(scene_path)
    while loader.poll() == ERR_FILE_EOF:
        # Update loading bar
        var progress = loader.get_progress()
        $LoadingScreen/ProgressBar.value = progress * 100
        await get_tree().process_frame
    
    # Scene loaded, transition
    var scene = loader.get_resource().instantiate()
    get_tree().current_scene.call_deferred("free")
    get_tree().root.add_child(scene)
    
    # Hide loading screen
    $LoadingScreen.visible = false
```

**Loading Screen Content**:
- Progress bar (required)
- Gameplay tips (optional, skippable)
- Story context / character bios (optional, enriches experience)
- Estimated time remaining (nice-to-have)

---

## Save System Reliability

### Target: Zero corrupted saves, zero lost progress

**Implementation**:
```gdscript
# Autosave every 30 seconds + manual + checkpoint
var autosave_timer: Timer
var save_path: String = "user://savegame.json"
var backup_path: String = "user://savegame.json.bak"

func _ready():
    autosave_timer = Timer.new()
    autosave_timer.wait_time = 30.0
    autosave_timer.autostart = true
    autosave_timer.timeout.connect(_on_autosave)
    add_child(autosave_timer)

func save_game() -> bool:
    var save_data = GameManager.get_save_data()
    var json_string = JSON.stringify(save_data, "  ")
    
    # Write to temp file first
    var temp_path = save_path + ".tmp"
    var file = FileAccess.open(temp_path, FileAccess.WRITE)
    if not file:
        push_error("Failed to open save file for writing")
        return false
    
    file.store_string(json_string)
    file.close()
    
    # Backup existing save
    if FileAccess.file_exists(save_path):
        DirAccess.copy_absolute(save_path, backup_path)
    
    # Atomic rename (prevents corruption if game crashes mid-write)
    DirAccess.rename_absolute(temp_path, save_path)
    
    return true

func load_game() -> Dictionary:
    # Try main save first
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            var json = JSON.new()
            var error = json.parse(json_string)
            if error == OK:
                return json.data
    
    # Fallback to backup
    if FileAccess.file_exists(backup_path):
        var file = FileAccess.open(backup_path, FileAccess.READ)
        if file:
            var json_string = file.get_as_text()
            var json = JSON.new()
            var error = json.parse(json_string)
            if error == OK:
                push_warning("Loaded from backup save file")
                return json.data
    
    # No valid save, return empty
    push_warning("No valid save file found, starting new game")
    return {}
```

**Testing**:
- Normal save/load cycle (100+ times)
- Corrupted save file (manually corrupt JSON, verify graceful fallback)
- Missing save file (delete, verify new game starts)
- Multiple save slots (verify no cross-contamination)
- Save during scene transition (verify no crash)
- Save during combat (verify state is consistent on load)

---

## Bug Prevention & QA

### Target: Zero bugs in release build

**Development Process**:
- Every feature has test checklist in CLAUDE.md
- Manual testing after every phase
- Automated tests for critical systems (save/load, consequence tracking, ending calculation)
- No feature merges without QA sign-off

**Bug Tracking**:
- Use GitHub Issues with labels: `bug`, `critical`, `major`, `minor`, `qa-verified`
- Critical bugs: crashes, softlocks, save corruption, progression blockers
- Major bugs: gameplay breaking (can't complete puzzle, enemy AI broken)
- Minor bugs: visual glitches, typos, audio issues

**QA Checklist Template** (per phase):
```markdown
## Phase X QA Checklist

### Functional
- [ ] All new features work as specified
- [ ] No console errors or warnings
- [ ] Save/load works correctly
- [ ] All inputs respond correctly

### Performance
- [ ] 60 FPS stable in new areas
- [ ] No memory leaks (profile after 30 min play)
- [ ] Scene transitions <2 seconds

### Compatibility
- [ ] Tested on minimum spec hardware
- [ ] Tested on recommended spec hardware
- [ ] Tested with all accessibility options

### Edge Cases
- [ ] Tested rapid input sequences
- [ ] Tested save/load during edge states (mid-combat, mid-puzzle)
- [ ] Tested death/retry multiple times
- [ ] Tested with all difficulty settings
```

**Release QA** (Phase 16):
- Full game playthrough (all three endings)
- Speedrun test (verify no sequence breaks)
- 100% completion test (all memory fragments, all rescues)
- Accessibility audit (all options functional)
- Performance audit (all quality presets)
- Compatibility test (Windows 10/11, macOS, Linux if applicable)

---

## Polish Standards

### Target: Celeste-level polish

**Animation**:
- All character movement has acceleration/deceleration (no instant starts/stops)
- Idle animations for both characters (Elena fidgets with prototype, Marcus scans perimeter)
- Hit reactions have weight and impact (no damage numbers floating alone)
- Environmental animations (wind in vegetation, water flow, particle drift)

**Audio**:
- Every interaction has appropriate sound (footsteps on different surfaces, UI clicks, puzzle completions)
- Audio variations (no same sound >3 times in a row without variation)
- Ambient layers per location (wind, machinery, distant storms, wildlife)
- Music transitions are smooth (crossfade, not hard cuts)

**Visual**:
- Screen shake is optional and meaningful (not constant)
- Hit stop on heavy impacts (2-3 frames, not excessive)
- Particle effects have variety (not same particle repeated)
- Lighting changes tell story (darker in danger, brighter after puzzle solve)

**UI**:
- All buttons have hover/press states
- All transitions are animated (fades, slides, not instant pops)
- All text is readable (font size, contrast, line spacing)
- All menus are navigable with keyboard AND controller

**Camera**:
- Smooth follow (not locked, not laggy)
- Boundary clamping (never show outside level)
- Dynamic framing for important moments (boss intros, puzzle completions)
- Optional camera shake (toggle in settings)

---

## Debug Tools

### Target: Comprehensive tools for QA and accessibility

**Developer Console** (release-build disabled):
- `god_mode` - invincibility
- `noclip` - walk through walls
- `give_all_fragments` - unlock all memory fragments
- `unlock_all_levels` - access any level from menu
- `set_ending [public|guarded|fragile]` - force ending for testing
- `fps` - show FPS counter
- `input_latency` - show input latency estimate

**Level Select**:
- Available in debug builds
- All levels accessible from start
- Checkpoints can be toggled

**Combat Arena Selector**:
- Test combat encounters in isolation
- Configurable enemy count, types
- Stats tracking (DPS, time to clear, damage taken)

**Puzzle Solver**:
- Optional hint overlay for puzzles
- Skip puzzle button (debug only, not in release)

**Save State Viewer**:
- View current save data in real-time
- Export/import save for testing
- Force set values (for testing ending conditions)

---

## Profiling & Monitoring

### Tools

**Godot 4.x Built-in**:
- Profiler (CPU time per function)
- Memory monitor (RAM, VRAM usage)
- Visual debugger (collision shapes, navigation, etc.)

**External**:
- NVIDIA Nsight / AMD Radeon GPU Profiler
- OBS for recording (60 FPS verification)
- High-speed camera for input latency

**Metrics to Track**:
- FPS (1% low, 0.1% low, average)
- Frame time (not just FPS)
- Memory usage over time (look for leaks)
- Draw calls per frame
- Active physics bodies
- Active audio voices

**Performance Budgets**:
- CPU frame time: <16ms (60 FPS)
- GPU frame time: <16ms
- Physics: <3ms
- Audio: <1ms
- Rendering: <10ms
- Game logic: <3ms

---

## Release Readiness

### Definition of "Done"

A feature is not done until:
- [ ] Implemented and tested
- [ ] Performance profiled (meets budgets)
- [ ] Accessibility verified (all relevant options work)
- [ ] Documented in CLAUDE.md / README
- [ ] QA sign-off (no known bugs)
- [ ] Localized (all text externalized)

### Release Checklist

- [ ] All phases complete and QA verified
- [ ] Zero critical bugs
- [ ] Zero major bugs
- [ ] Minor bugs documented and accepted
- [ ] Performance targets met on minimum spec
- [ ] All accessibility features functional
- [ ] Save/load tested 100+ times with no corruption
- [ ] All three endings verified with test saves
- [ ] Export builds tested on target platforms
- [ ] Credits complete and accurate
- [ ] Legal requirements met (licenses, attributions)
- [ ] Store page assets prepared (screenshots, trailer, description)

---

## Commitment

FINAL THAW will be technically excellent. No excuses.

60 FPS is not optional. Input latency is not acceptable. Bugs are not "part of the process."

Every player deserves a game that works. We will deliver that.
