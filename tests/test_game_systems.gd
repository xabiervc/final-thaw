extends Node
## Game systems around the Phase 1/2 scene: localisation coverage, options with a real effect, settings and
## remap persistence (JSON/CRC32 save, test slot), conflict swap and defaults, pause menu, cinematic skip safety,
## colour-blind palette and field-notes derivation. Uses save slot 98 and never touches the player's own options.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_game_systems.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const SLOT := 98
const FieldNotes := preload("res://scripts/game/field_notes.gd")
const PromptHudScript := preload("res://scripts/ui/prompt_hud.gd")

var passed := 0
var failed := 0


func _ready() -> void:
	get_tree().create_timer(300.0).timeout.connect(func(): push_error("systems watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _frames(seconds: float) -> void:
	var t := 0.0
	while t < seconds:
		await get_tree().physics_frame
		t += get_physics_process_delta_time()


func _run() -> void:
	var saved_settings: Dictionary = GameManager.settings.duplicate(true)
	GameManager.settings_slot = SLOT
	_localisation()
	_field_notes()
	_palette()
	await _settings_and_remap()
	await _scene_systems()
	GameManager.settings = saved_settings
	InputRemapManager.reset_all()
	InputRemapManager.restore_all()
	GameSettings.apply()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.save_path(SLOT)))
	print("Game systems: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


# --- localisation -------------------------------------------------------------------------------------------------

func _localisation() -> void:
	var keys: Array = GameText.keys()
	_expect(keys.size() > 200, "the game text table loads (%d keys)" % keys.size())
	var incomplete: Array = []
	for k in keys:
		var e: Dictionary = GameText.entry(k)
		if str(e.get("es", "")).strip_edges().is_empty() or str(e.get("en", "")).strip_edges().is_empty():
			incomplete.append(k)
	_expect(incomplete.is_empty(), "every key has Spanish and English text %s" % [incomplete])
	# Every literal key used in the game code exists.
	var used := {}
	var re := RegEx.create_from_string("T\\.t\\(\"([a-z0-9_]+)\"\\s*[,)]")
	for path in ["res://scripts/prototypes/phase1_canonical_greybox.gd", "res://scripts/ui/options_panel.gd", "res://scripts/ui/pause_menu.gd",
			"res://scripts/game/cinematic_director.gd", "res://scripts/ui/prompt_hud.gd"]:
		var text := FileAccess.get_file_as_string(path)
		for m in re.search_all(text):
			used[m.get_string(1)] = true
	var missing: Array = []
	for k in used:
		if not GameText.has(k):
			missing.append(k)
	_expect(used.size() > 60 and missing.is_empty(), "every literal text key used in code exists (%d used) %s" % [used.size(), missing])
	var dynamic_missing: Array = []
	for id in FieldNotes.ORDER:
		for suffix in ["_title", "_body"]:
			if not GameText.has("note_" + id + suffix):
				dynamic_missing.append("note_" + id + suffix)
	for d in GameSettings.DIFFICULTIES:
		for k in ["opt_diff_" + d, "opt_diff_" + d + "_desc"]:
			if not GameText.has(k):
				dynamic_missing.append(k)
	for a in InputRemapManager.REMAPPABLE_ACTIONS:
		if not GameText.has("action_" + a):
			dynamic_missing.append("action_" + a)
	for k in ["ban_inference_hypothesis", "ban_inference_test_result", "ban_inference_conclusion", "dest_ensayo", "dest_archivo"]:
		if not GameText.has(k):
			dynamic_missing.append(k)
	_expect(dynamic_missing.is_empty(), "every composed key (notes, difficulty, actions, inferences) exists %s" % [dynamic_missing])
	var before := GameText.locale()
	NarrativeTextManager.set_locale("en")
	var en := GameText.t("obj_investigate")
	NarrativeTextManager.set_locale("es")
	var es := GameText.t("obj_investigate")
	NarrativeTextManager.set_locale(before)
	_expect(en != es and en.begins_with("Investigate"), "the language chosen in the menu changes the game text (%s / %s)" % [es, en])
	_expect(GameText.t("res_time", {"m": 3, "s": "07"}).contains("3:07"), "placeholders are filled")


# --- field notes ------------------------------------------------------------------------------------------------

func _field_notes() -> void:
	var n = FieldNotes.new()
	n.add("schematic")
	_expect(not n.has("hypothesis"), "the intended schematic alone does not form a hypothesis")
	n.add("trip", "event")
	_expect(not n.has("test_result"), "a trip without a hypothesis is not a confirmed test")
	n.add("scan_bridge")
	_expect(n.has("hypothesis") and n.has("test_result"), "schematic + measured continuity -> hypothesis; with the trip -> confirmed")
	_expect(not n.has("conclusion"), "no conclusion before the record is read")
	n.add("record")
	_expect(n.has("conclusion"), "the record leads to the conclusion")
	_expect(not n.add("record"), "notes are recorded once")
	var titles: Array = n.entries().map(func(e): return e["title"])
	_expect(titles.size() == n.count() and not titles.has(""), "pause-menu entries are titled and ordered")


# --- palette ------------------------------------------------------------------------------------------------------

func _palette() -> void:
	var before := GameManager.colorblind_mode
	GameManager.colorblind_mode = 0
	var std_ok := GamePalette.color("ok")
	var std_danger := GamePalette.color("danger")
	GameManager.colorblind_mode = 1
	var deut_ok := GamePalette.color("ok")
	var deut_danger := GamePalette.color("danger")
	GameManager.colorblind_mode = before
	_expect(not std_ok.is_equal_approx(deut_ok), "the deuteranopia palette changes the 'ok' colour (green -> blue)")
	# Under deuteranopia red and green collapse; the remapped pair must differ strongly in blue/brightness.
	_expect(absf(deut_ok.b - deut_danger.b) > 0.6, "deutan ok/danger differ in the blue channel, not only red/green")
	_expect(std_danger != std_ok, "standard palette distinguishes ok and danger")


# --- settings, persistence, remapping ---------------------------------------------------------------------------

func _settings_and_remap() -> void:
	# Options with an observable effect.
	GameSettings.set_value("game_speed", 0.5)
	_expect(is_equal_approx(Engine.time_scale, 0.5), "game speed 50 %% slows the engine time scale")
	GameSettings.set_value("game_speed", 0.73)
	_expect(is_equal_approx(float(GameSettings.get_value("game_speed")), 1.0), "invalid game speeds are rejected")
	GameSettings.set_value("game_speed", 1.0)
	GameSettings.set_value("music_volume", 0.0)
	_expect(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "music volume 0 mutes the Music bus")
	GameSettings.set_value("music_volume", 0.5)
	_expect(absf(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")) - linear_to_db(0.5)) < 0.1, "music volume sets the bus level")
	GameSettings.set_value("difficulty", "nonsense")
	_expect(GameSettings.difficulty() == "standard", "unknown difficulty values fall back to standard")
	# Remapping: primary key, conflict swap, persistence, defaults.
	InputRemapManager.reset_all()
	var jump_default := InputRemapManager.current_keycode("jump")
	var crouch_default := InputRemapManager.current_keycode("crouch")
	_expect(jump_default == KEY_SPACE and crouch_default == KEY_CTRL, "defaults: jump Space, crouch Ctrl")
	_expect(InputRemapManager.conflict_for_key("jump", KEY_CTRL) == "crouch", "a key already used by another action is reported as a conflict")
	InputRemapManager.rebind("jump", KEY_CTRL)
	_expect(InputRemapManager.current_keycode("jump") == KEY_CTRL and InputRemapManager.current_keycode("crouch") == KEY_SPACE, "binding a used key swaps the two actions")
	_expect(_action_has_key("crouch", KEY_C), "the secondary key of the other action (C for crouch) keeps working")
	_expect(not InputRemapManager.rebind("jump", KEY_ESCAPE), "Escape cannot be taken (it opens the menu)")
	InputRemapManager.rebind_pad("interact", JOY_BUTTON_A)
	_expect(InputRemapManager.current_pad_button("interact") == JOY_BUTTON_A and InputRemapManager.current_pad_button("jump") == JOY_BUTTON_X, "gamepad buttons swap the same way")
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_CTRL
	_expect(InputMap.action_has_event("jump", ev), "the change is in the real input map, not only in the UI")
	# Persistence through the save (JSON/CRC32), then restore over the defaults.
	GameSettings.set_value("camera_sensitivity", 1.6)
	_expect(GameManager.save_settings(), "options save to the test slot")
	InputRemapManager.reset_all()
	GameManager.settings = {}
	_expect(GameManager.load_game(SLOT), "the save loads back")
	InputRemapManager.restore_all()
	_expect(InputRemapManager.current_keycode("jump") == KEY_CTRL and InputRemapManager.current_keycode("crouch") == KEY_SPACE, "remapped keys persist across a reload")
	_expect(InputRemapManager.current_pad_button("interact") == JOY_BUTTON_A, "remapped gamepad buttons persist")
	_expect(is_equal_approx(GameSettings.look_sensitivity(), 1.6), "camera sensitivity persists")
	InputRemapManager.reset_all()
	_expect(InputRemapManager.current_keycode("jump") == KEY_SPACE and InputRemapManager.current_keycode("crouch") == KEY_CTRL and InputRemapManager.current_pad_button("interact") == JOY_BUTTON_X, "restore defaults puts every binding back")
	_expect(not GameManager.settings.has("bindings"), "restore defaults forgets the stored bindings")
	# A save from before this change (no "settings" key) still loads.
	var old := {"version": 1, "phase": 0, "font_scale": 1.25, "flags": {}}
	var payload := JSON.stringify(old)
	var f := FileAccess.open(GameManager.save_path(SLOT), FileAccess.WRITE)
	f.store_string(JSON.stringify({"payload": payload, "crc32": GameManager.crc32(payload.to_utf8_buffer())}))
	f.close()
	_expect(GameManager.load_game(SLOT) and GameManager.settings.is_empty() and GameSettings.difficulty() == "standard", "older saves without options load with default options")
	await get_tree().process_frame


func _action_has_key(action: String, key: int) -> bool:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and (e as InputEventKey).physical_keycode == key:
			return true
	return false


# --- pause menu and cinematic skip -------------------------------------------------------------------------------

func _scene_systems() -> void:
	var scene: Node3D = (load(SCENE) as PackedScene).instantiate()
	add_child(scene)
	await _frames(0.5)
	_expect(scene.phase == "intro" and scene.cinema.active, "the game starts with the intro cinematic")
	_expect(not bool(scene.player.get("input_enabled")), "the player has no control during the intro")
	var duration: float = scene.Cinema.total_duration(scene.call("_intro_shots"))
	_expect(duration >= 40.0 and duration <= 62.0, "the intro lasts about a minute or less (%.0f s)" % duration)
	await _frames(1.0)
	Input.action_press("interact")
	await _frames(1.0)
	Input.action_release("interact")
	await _frames(0.2)
	var view: Camera3D = scene.player.get("view")
	_expect(not scene.cinema.active and scene.phase == "investigation", "holding interact skips the intro")
	_expect(bool(scene.player.get("input_enabled")) and not bool(scene.player.get("look_locked")), "after the skip the player has control")
	_expect(get_viewport().get_camera_3d() == view, "after the skip the gameplay camera is current (not detached)")
	_expect(not get_tree().paused and scene.hud.visible, "after the skip the game is not paused and the HUD is visible")
	_expect(scene.notes.has("anomaly"), "skipping still records what Elena came to check")
	await _frames(0.5)
	_expect(not scene.cinema.active and scene.phase == "investigation", "the skip happens once: nothing restarts the intro")
	# Pause menu.
	var ev := InputEventAction.new()
	ev.action = "pause"
	ev.pressed = true
	Input.parse_input_event(ev)
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(scene.pause_menu.is_open and get_tree().paused, "the menu action opens the pause menu and pauses the game")
	_expect(not scene.call("can_retry"), "retry is not offered before there is a checkpoint")
	_expect(scene.pause_menu.find_children("Notes", "Button", true, false).size() == 1, "the pause menu offers the field notes")
	scene.pause_menu.close()
	await get_tree().process_frame
	_expect(not get_tree().paused and not scene.pause_menu.is_open, "resuming unpauses the game")
	# Gamepad, through the real input pipeline (injected device events, no hardware available in this environment).
	var yaw_before: float = scene.player.get("orbit_yaw")
	var z_before: float = scene.player.global_position.z
	var stick := InputEventJoypadMotion.new()
	stick.axis = JOY_AXIS_LEFT_Y
	stick.axis_value = -1.0
	Input.parse_input_event(stick)
	var look := InputEventJoypadMotion.new()
	look.axis = JOY_AXIS_RIGHT_X
	look.axis_value = 1.0
	Input.parse_input_event(look)
	await _frames(0.6)
	var moved: float = absf(scene.player.global_position.z - z_before) + absf(scene.player.velocity.x) + absf(scene.player.velocity.z)
	var turned: bool = absf(float(scene.player.get("orbit_yaw")) - yaw_before) > 0.3
	stick.axis_value = 0.0
	Input.parse_input_event(stick)
	look.axis_value = 0.0
	Input.parse_input_event(look)
	_expect(moved > 0.5, "the left stick moves Elena through the input map")
	_expect(turned, "the right stick turns the camera")
	var button := InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_X
	button.pressed = true
	Input.parse_input_event(button)
	await get_tree().process_frame
	await get_tree().physics_frame  # buffered device events are flushed on the physics tick
	var interact_on: bool = Input.is_action_pressed("interact")
	_expect(interact_on and PromptHudScript.using_pad, "the X / square button is 'interact', and the HUD switches to gamepad prompts")
	_expect(PromptHudScript.control_legend(["interact"]).contains("X /"), "the control legend shows the gamepad button")
	button.pressed = false
	Input.parse_input_event(button)
	var key := InputEventKey.new()
	key.physical_keycode = KEY_W
	key.pressed = true
	Input.parse_input_event(key)
	key.pressed = false
	Input.parse_input_event(key)
	await get_tree().process_frame
	await get_tree().physics_frame
	_expect(not PromptHudScript.using_pad, "pressing a key switches the prompts back to the keyboard")
	# Graphics quality changes the real rendering features of the scene.
	GameSettings.set_value("graphics", "performance")
	var perf_ok: bool = not scene._env.glow_enabled and not scene._sun.shadow_enabled
	GameSettings.set_value("graphics", "high")
	var high_ok: bool = scene._env.glow_enabled and scene._sun.shadow_enabled
	GameSettings.set_value("graphics", "balanced")
	var bal_ok: bool = not scene._env.glow_enabled and scene._sun.shadow_enabled
	_expect(perf_ok and high_ok and bal_ok, "graphics quality toggles glow and sun shadows in the running scene")
	# Subtitles option: dialogue lines respect it.
	GameSettings.set_value("subtitles", false)
	scene.call("_say", "test_line", "x", 2.0)
	var shown_off: bool = scene.subtitles.call("is_message_visible")
	GameSettings.set_value("subtitles", true)
	scene.call("_say", "test_line_2", "y", 2.0)
	var shown_on: bool = scene.subtitles.call("is_message_visible")
	_expect(not shown_off and shown_on, "the subtitles option hides and shows dialogue subtitles")
	scene.queue_free()
	await get_tree().process_frame
