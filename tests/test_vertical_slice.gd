extends Node

const Rules = preload("res://scripts/vertical_slice/shelter_rules.gd")
const SoundCueHUDScript = preload("res://scripts/ui/sound_cue_hud.gd")
var failed: int = 0

func _ready() -> void:
	_check_rules()
	_check_rule_signals()
	_check_oxygen_states()
	_check_state_restore()
	_check_shelter_text_fallbacks()
	_check_menu_text_contract()
	_check_hud_text_contract()
	_check_prompt_text_contract()
	_check_accessibility_text_contract()
	_check_accessibility_manager()
	_check_colorblind_palettes()
	_check_input_remapping()
	_check_sound_cues()
	_check_rescue_persistence()
	print("Vertical slice rules: %s" % ("PASS" if failed == 0 else "FAIL (%d)" % failed))
	get_tree().quit(1 if failed > 0 else 0)

func _expect(condition: bool, label: String) -> void:
	if not condition:
		failed += 1
		push_error("FAIL: " + label)
	else:
		print("PASS: ", label)

func _check_rules() -> void:
	var rules = Rules.new()
	_expect(not rules.open_valves(), "No valves before power")
	_expect(not rules.rescue(), "No rescue before access")
	_expect(not rules.can_exit(), "Exit blocked before valves")
	_expect(rules.activate_power(), "Power switches on")
	_expect(not rules.activate_power(), "Power is idempotent")
	_expect(rules.open_valves(), "Valves open after power")
	_expect(rules.can_exit(), "Exit available after valves")
	_expect(rules.rescue(), "Rescue works once")
	_expect(not rules.rescue(), "Rescue cannot be repeated")
	rules.drain_oxygen(30.0)
	_expect(rules.oxygen == 0.0 and not rules.can_exit(), "Oxygen expires and blocks exit")
	_expect(not rules.rescue(), "Rescue blocked without oxygen")
	rules.reset()
	_expect(rules.oxygen == rules.oxygen_max and not rules.power_on and not rules.rescued, "Retry resets room")

func _check_rule_signals() -> void:
	var rules = Rules.new()
	# GDScript lambdas capture locals by value, so the counters live in a dictionary
	var counts := {"power": 0, "valve": 0, "rescue": 0, "depleted": 0, "reset": 0}

	rules.power_activated.connect(func(): counts["power"] += 1)
	rules.valves_opened.connect(func(): counts["valve"] += 1)
	rules.civilian_rescued.connect(func(): counts["rescue"] += 1)
	rules.oxygen_depleted.connect(func(): counts["depleted"] += 1)
	rules.state_reset.connect(func(): counts["reset"] += 1)

	rules.activate_power()
	rules.activate_power()
	rules.open_valves()
	rules.open_valves()
	rules.rescue()
	rules.rescue()
	rules.drain_oxygen(30.0)
	rules.reset()

	_expect(counts["power"] == 1, "Power signal emitted once")
	_expect(counts["valve"] == 1, "Valve signal emitted once")
	_expect(counts["rescue"] == 1, "Rescue signal emitted once")
	_expect(counts["depleted"] == 1, "Oxygen depletion signal emitted once")
	_expect(counts["reset"] == 1, "Reset signal emitted once")

func _check_oxygen_states() -> void:
	var rules = Rules.new()
	_expect(rules.oxygen_state() == "normal", "Full oxygen is normal")
	rules.oxygen = rules.oxygen_max * 0.4
	_expect(rules.oxygen_state() == "warning", "Forty percent oxygen is warning")
	rules.oxygen = rules.oxygen_max * 0.2
	_expect(rules.oxygen_state() == "critical", "Twenty percent oxygen is critical")
	rules.oxygen = 0.0
	_expect(rules.oxygen_state() == "critical", "Empty oxygen is critical")

func _check_state_restore() -> void:
	var rules = Rules.new()
	rules.restore(true, true, true)
	_expect(rules.power_on and rules.valves_open and rules.rescued, "Shelter state restores from persistent flags")
	_expect(rules.can_exit(), "Restored state permits exit")

func _check_shelter_text_fallbacks() -> void:
	_expect(not NarrativeTextManager.get_shelter_intro().is_empty(), "Shelter intro fallback exists")
	_expect(not NarrativeTextManager.get_shelter_scan().is_empty(), "Shelter scan fallback exists")
	_expect(not NarrativeTextManager.get_shelter_power_restored().is_empty(), "Power restored fallback exists")
	_expect(not NarrativeTextManager.get_shelter_power_already_on().is_empty(), "Power already-on fallback exists")
	_expect(not NarrativeTextManager.get_shelter_valves_opened().is_empty(), "Valves opened fallback exists")
	_expect(not NarrativeTextManager.get_shelter_valves_need_power().is_empty(), "Valves need-power fallback exists")
	_expect(not NarrativeTextManager.get_shelter_civilian_rescued().is_empty(), "Civilian rescued fallback exists")
	_expect(not NarrativeTextManager.get_shelter_civilian_blocked().is_empty(), "Civilian blocked fallback exists")
	_expect(not NarrativeTextManager.get_shelter_exit_blocked().is_empty(), "Exit blocked fallback exists")
	_expect(not NarrativeTextManager.get_shelter_oxygen_empty().is_empty(), "Oxygen empty fallback exists")
	_expect(not NarrativeTextManager.get_shelter_exit_prompt(false).is_empty(), "Locked exit prompt fallback exists")
	_expect(not NarrativeTextManager.get_shelter_exit_prompt(true).is_empty(), "Ready exit prompt fallback exists")
	_expect(not NarrativeTextManager.get_shelter_hud(true, true, 12.0, 3).is_empty(), "Shelter HUD fallback exists")
	_expect(not NarrativeTextManager.get_shelter_exit_title(true, 3).is_empty(), "Shelter exit title fallback exists")

func _check_menu_text_contract() -> void:
	_expect(not NarrativeTextManager.get_shelter_civilian_state_short().is_empty(), "Menu civilian state fallback exists")
	_expect(not NarrativeTextManager.get_shelter_previous_state().is_empty(), "Menu previous-state fallback exists")
	_expect(not NarrativeTextManager.get_menu_options_button().is_empty(), "Menu options fallback exists")
	_expect(not NarrativeTextManager.get_menu_credits_button().is_empty(), "Menu credits fallback exists")
	_expect(not NarrativeTextManager.get_menu_escape_button().is_empty(), "Conduit escape entry fallback exists")
	_expect(not NarrativeTextManager.get_options_text_scale().is_empty(), "Options text-scale fallback exists")
	_expect(not NarrativeTextManager.get_options_back_button().is_empty(), "Options back fallback exists")
	_expect(not NarrativeTextManager.get_credits_title().is_empty(), "Credits title fallback exists")
	_expect(not NarrativeTextManager.get_options_remap_title().is_empty(), "Remap title fallback exists")
	_expect(not NarrativeTextManager.get_options_press_key().is_empty(), "Press-key fallback exists")

func _check_hud_text_contract() -> void:
	_expect(not NarrativeTextManager.get_hud_civilian_aid(4).is_empty(), "HUD civilian aid fallback exists")
	_expect(not NarrativeTextManager.get_hud_prototype_integrity(3).is_empty(), "HUD prototype integrity fallback exists")
	_expect(not NarrativeTextManager.get_hud_elena_safety(3).is_empty(), "HUD Elena safety fallback exists")
	_expect(not NarrativeTextManager.get_hud_fps(60).is_empty(), "HUD FPS fallback exists")

func _check_prompt_text_contract() -> void:
	_expect(not NarrativeTextManager.get_prompt_instructions().is_empty(), "Prompt instructions fallback exists")
	_expect(not NarrativeTextManager.get_prompt_condition(80, "estable", false).is_empty(), "Prompt condition fallback exists")
	_expect(not NarrativeTextManager.get_prompt_condition(20, "critica", true).is_empty(), "Loaded critical condition fallback exists")

func _check_accessibility_text_contract() -> void:
	_expect(not NarrativeTextManager.get_options_high_contrast().is_empty(), "High contrast fallback exists")
	_expect(not NarrativeTextManager.get_options_reduced_motion().is_empty(), "Reduced motion fallback exists")
	_expect(not NarrativeTextManager.get_options_subtitle_background().is_empty(), "Subtitle background fallback exists")
	_expect(not NarrativeTextManager.get_options_subtitle_none().is_empty(), "Subtitle none fallback exists")
	_expect(not NarrativeTextManager.get_options_subtitle_dim().is_empty(), "Subtitle dim fallback exists")
	_expect(not NarrativeTextManager.get_options_subtitle_solid().is_empty(), "Subtitle solid fallback exists")
	_expect(not NarrativeTextManager.get_options_colorblind_mode().is_empty(), "Colorblind mode fallback exists")
	_expect(not NarrativeTextManager.get_options_colorblind_none().is_empty(), "Colorblind none fallback exists")
	_expect(not NarrativeTextManager.get_options_colorblind_deuteranopia().is_empty(), "Deuteranopia fallback exists")
	_expect(not NarrativeTextManager.get_options_colorblind_protanopia().is_empty(), "Protanopia fallback exists")
	_expect(not NarrativeTextManager.get_options_colorblind_tritanopia().is_empty(), "Tritanopia fallback exists")

func _check_accessibility_manager() -> void:
	var previous_contrast: bool = GameManager.get_flag("accessibility_high_contrast")
	var previous_motion: bool = GameManager.get_flag("accessibility_reduced_motion")
	var previous_subtitle: int = GameManager.subtitle_size

	GameManager.set_flag("accessibility_high_contrast", true)
	GameManager.set_flag("accessibility_reduced_motion", true)
	GameManager.subtitle_size = 0
	_expect(AccessibilityManager.is_high_contrast(), "High contrast preference is readable")
	_expect(AccessibilityManager.is_reduced_motion(), "Reduced motion preference is readable")
	_expect(AccessibilityManager.animation_duration(0.2) == 0.0, "Reduced motion removes animation duration")
	_expect(AccessibilityManager.subtitle_panel_alpha() == 0.0, "None subtitle background has no panel alpha")

	GameManager.subtitle_size = 2
	_expect(AccessibilityManager.subtitle_panel_alpha() == 0.95, "Solid subtitle background has high panel alpha")

	GameManager.set_flag("accessibility_high_contrast", previous_contrast)
	GameManager.set_flag("accessibility_reduced_motion", previous_motion)
	GameManager.subtitle_size = previous_subtitle

func _check_colorblind_palettes() -> void:
	var previous_mode: int = GameManager.colorblind_mode
	var previous_contrast: bool = GameManager.get_flag("accessibility_high_contrast")

	GameManager.set_flag("accessibility_high_contrast", false)
	for mode in [0, 1, 2, 3]:
		GameManager.colorblind_mode = mode
		var palette: Dictionary = AccessibilityManager.shelter_palette()
		_expect(palette.has("locked") and palette.has("active") and palette.has("highlight"), "Palette exists for mode %d" % mode)
		_expect(palette.has("text") and palette.has("oxygen_normal"), "Text palette exists for mode %d" % mode)
		_expect(palette.has("oxygen_warning") and palette.has("oxygen_critical"), "Oxygen palette exists for mode %d" % mode)

	GameManager.colorblind_mode = previous_mode
	GameManager.set_flag("accessibility_high_contrast", previous_contrast)

func _check_input_remapping() -> void:
	var original_key: int = InputRemapManager.current_keycode("interact")
	var rebound: bool = InputRemapManager.rebind("interact", KEY_R)
	# 2026-10-15: bindings are stored in GameManager.settings (written to the JSON/CRC32 save), no longer in the
	# in-memory GameStateManager, which was never written to disk. Full save/reload is tested in test_game_systems.
	var bindings: Dictionary = GameManager.settings.get("bindings", {})
	var stored: Variant = (bindings.get("interact", {}) as Dictionary).get("key", KEY_NONE)
	_expect(rebound and InputRemapManager.current_keycode("interact") == KEY_R, "Interact can be rebound")
	_expect(stored is int and stored == KEY_R, "Interact rebinding persists")

	InputRemapManager.rebind("interact", original_key, false)
	bindings.erase("interact")
	_expect(InputRemapManager.current_keycode("interact") == original_key, "Interact original binding is restored")

func _check_sound_cues() -> void:
	var cue_hud: SoundCueHUD = SoundCueHUDScript.new()
	add_child(cue_hud)
	await get_tree().process_frame

	cue_hud.show_cue("generator")
	_expect(cue_hud._cue_label.text == NarrativeTextManager.get_sound_cue("generator"), "Generator cue displays localized text")
	_expect(cue_hud._cue_label.modulate.a == 1.0, "Generator cue is visible")

	cue_hud.show_cue("unknown_cue")
	_expect(cue_hud._cue_label.text == NarrativeTextManager.get_sound_cue("generator"), "Unknown cue does not clear current cue")

	cue_hud.queue_free()

func _check_rescue_persistence() -> void:
	var previous: int = GameManager.civilian_aid
	GameManager.civilian_aid = 2
	var saved: bool = GameManager.save_game(99)
	GameManager.civilian_aid = 0
	var loaded: bool = GameManager.load_game(99)
	_expect(saved and loaded and GameManager.civilian_aid == 2, "Civilian aid survives save/load")
	GameManager.civilian_aid = previous
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.save_path(99)))
