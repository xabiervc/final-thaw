extends Node

## Central runtime access to localized NarrativeText resources.
## This script is an autoload; do not give it a class_name matching the autoload.

static var texts: Resource
static var current_locale: String = "es"

static func _initialize() -> void:
	if texts == null:
		set_locale("es")

static func set_locale(locale: String) -> void:
	current_locale = locale
	var path := "res://data/narrative_text_%s.tres" % locale
	if not ResourceLoader.exists(path):
		path = "res://data/narrative_text.tres"
	var loaded: Resource = ResourceLoader.load(path)
	if loaded == null:
		push_error("NarrativeText resource could not be loaded: %s" % path)
		texts = null
		return
	texts = loaded

static func _text(property_name: String, fallback: String = "") -> String:
	_initialize()
	if texts == null:
		return fallback
	var value: Variant = texts.get(property_name)
	return str(value) if value != null else fallback

static func get_option(property_name: String, fallback: String = "") -> String:
	return _text(property_name, fallback)

static func get_menu_title() -> String:
	return _text("menu_title", "Final Thaw")

static func get_menu_context() -> String:
	return _text("menu_context")

static func get_menu_start_button() -> String:
	return _text("menu_start_button", "Start Demo")

static func get_menu_options_button() -> String:
	return _text("menu_options_button", "Options")

static func get_menu_credits_button() -> String:
	return _text("menu_credits_button", "Credits")

static func get_hud_oxygen_label(value: float) -> String:
	return _text("hud_oxygen_label", "Oxygen: %d%%") % int(value)

static func get_hud_civilian_aid(value: int) -> String:
	return _text("hud_civilian_aid", "Civilian aid %d/10") % value

static func get_hud_prototype_integrity(value: int) -> String:
	return _text("hud_prototype_integrity", "Prototype %d/3") % value

static func get_hud_elena_safety(value: int) -> String:
	return _text("hud_elena_safety", "Elena %d/3") % value

static func get_hud_fps(value: int) -> String:
	return _text("hud_fps", "FPS: %d") % value

static func get_hud_civilian_state(trapped: bool, rescued: bool, dead: bool) -> String:
	if dead:
		return _text("hud_civilian_dead", "Civilian: Deceased")
	if rescued:
		return _text("hud_civilian_rescued", "Civilian: Rescued")
	return _text("hud_civilian_trapped", "Civilian: Trapped")

static func get_hud_objective(has_power: bool, valves_open: int, civilian_exists: bool, civilian_trapped: bool) -> String:
	if not has_power:
		return _text("hud_objective_start", "Objective: Activate the generator.")
	if valves_open < 2:
		return _text("hud_objective_power_on", "Objective: Open the valves.")
	if civilian_exists and civilian_trapped:
		return _text("hud_objective_valves_open", "Objective: Decide whether to rescue the civilian.")
	return _text("hud_objective_exit", "Objective: Reach the exit.")

static func get_interact_power_console(is_on: bool) -> String:
	return _text("interact_power_console_on", "Generator running") if is_on else _text("interact_power_console_off", "Activate generator")

static func get_interact_valve(is_open: bool) -> String:
	return _text("interact_valve_open", "Valve open") if is_open else _text("interact_valve_closed", "Open valve")

static func get_interact_civilian(is_trapped: bool) -> String:
	return _text("interact_civilian_trapped", "Rescue") if is_trapped else _text("interact_civilian_rescued", "Safe")

static func get_random_civilian_rescue_line() -> String:
	_initialize()
	if texts == null:
		return ""
	var lines: Array = texts.get("civilian_rescue_lines")
	return str(lines.pick_random()) if not lines.is_empty() else ""

static func get_end_title(success: bool) -> String:
	return _text("end_title_success", "Demo Complete") if success else _text("end_title_failure", "Demo Failed")

static func get_end_elena(alive: bool) -> String:
	return _text("end_elena_alive", "Elena: Survived") if alive else _text("end_elena_dead", "Elena: Did not survive")

static func get_end_civilian(rescued: bool, dead: bool, unknown: bool) -> String:
	if unknown:
		return _text("end_civilian_unknown", "Civilian: Status unknown")
	return get_hud_civilian_state(false, rescued, dead)

static func get_end_power_restored() -> String:
	return _text("end_power_restored")

static func get_end_valves_opened() -> String:
	return _text("end_valves_opened")

static func get_end_civilian_rescued() -> String:
	return _text("end_civilian_rescued")

static func get_end_civilian_not_rescued() -> String:
	return _text("end_civilian_not_rescued")

static func get_end_button_menu() -> String:
	return _text("end_button_menu", "Back to Menu")

static func get_end_button_restart() -> String:
	return _text("end_button_restart", "Restart Demo")

static func get_prompt_instructions() -> String:
	return _text("prompt_instructions", "WASD / arrows: move   |   E: interact   |   Q / Tab: scan   |   F2: save   F3: load   |   ESC: menu")

static func get_prompt_condition(stamina: int, state: String, aster_loaded: bool) -> String:
	var state_text := _text("condition_state_%s" % state, state.to_upper())
	var text: String = _text("prompt_condition", "STAMINA %d%%  |  %s") % [stamina, state_text]
	if aster_loaded:
		text += "  |  " + _text("prompt_aster_load", "Aster load")
	return text

static func get_options_text_scale() -> String:
	return _text("options_text_scale", "Text scale: %.2f")

static func get_options_back_button() -> String:
	return _text("options_back_button", "Back")

static func get_options_high_contrast() -> String:
	return _text("options_high_contrast", "High contrast")

static func get_options_reduced_motion() -> String:
	return _text("options_reduced_motion", "Reduce motion")

static func get_options_subtitle_background() -> String:
	return _text("options_subtitle_background", "Subtitle background")

static func get_options_subtitle_none() -> String:
	return _text("options_subtitle_none", "None")

static func get_options_subtitle_dim() -> String:
	return _text("options_subtitle_dim", "Dim")

static func get_options_subtitle_solid() -> String:
	return _text("options_subtitle_solid", "Solid")

static func get_options_colorblind_mode() -> String:
	return _text("options_colorblind_mode", "Colorblind mode")

static func get_options_colorblind_none() -> String:
	return _text("options_colorblind_none", "None")

static func get_options_colorblind_deuteranopia() -> String:
	return _text("options_colorblind_deuteranopia", "Deuteranopia")

static func get_options_colorblind_protanopia() -> String:
	return _text("options_colorblind_protanopia", "Protanopia")

static func get_options_colorblind_tritanopia() -> String:
	return _text("options_colorblind_tritanopia", "Tritanopia")

static func get_options_remap_title() -> String:
	return _text("options_remap_title", "Controls")

static func get_options_press_key() -> String:
	return _text("options_press_key", "Press a key...")

static func get_credits_title() -> String:
	return _text("credits_title", "FINAL THAW\nPhase 0 Prototype")

static func get_shelter_intro() -> String:
	return _text("shelter_intro", "E: generator, valves, rescue and exit. WASD/arrows to move. ESC: menu.")

static func get_shelter_scan() -> String:
	return _text("shelter_scan", "Route: generator -> valves -> optional rescue -> exit.")

static func get_shelter_power_restored() -> String:
	return _text("shelter_power_restored", "Generator activated.")

static func get_shelter_power_already_on() -> String:
	return _text("shelter_power_already_on", "Generator already active.")

static func get_shelter_valves_opened() -> String:
	return _text("shelter_valves_opened", "Valves open. Oxygen is draining.")

static func get_shelter_valves_need_power() -> String:
	return _text("shelter_valves_need_power", "Activate the generator first.")

static func get_shelter_civilian_rescued() -> String:
	return _text("shelter_civilian_rescued", "Civilian rescued. Civilian aid increased; game saved.")

static func get_shelter_civilian_blocked() -> String:
	return _text("shelter_civilian_blocked", "Open the valves to reach the civilian.")

static func get_shelter_exit_blocked() -> String:
	return _text("shelter_exit_blocked", "The exit is still blocked. Activate the generator and open the valves.")

static func get_shelter_oxygen_empty() -> String:
	return _text("shelter_oxygen_empty", "Out of oxygen. Restarting from the entrance; your saved rescue remains.")

static func get_shelter_exit_title(rescued: bool, civilian_aid: int) -> String:
	var rescued_text := _text("shelter_yes", "YES") if rescued else _text("shelter_no", "NO")
	return _text(
		"shelter_exit_title",
		"SHELTER CLEARED\nCivilian rescued: %s\nCivilian aid: %d/10\nPress E to return to menu"
	) % [rescued_text, civilian_aid]

static func get_shelter_exit_prompt(can_exit: bool) -> String:
	return _text("shelter_exit_ready", "Exit") if can_exit else _text("shelter_exit_locked", "Exit locked")

static func get_shelter_state_power(is_on: bool) -> String:
	return _text("shelter_state_on", "ON") if is_on else _text("shelter_state_off", "OFF")

static func get_shelter_state_valves(is_open: bool) -> String:
	return _text("shelter_state_open", "OPEN") if is_open else _text("shelter_state_closed", "CLOSED")

static func get_shelter_civilian_state_short() -> String:
	return _text("shelter_state_civilian_rescued", "Civilian rescued")

static func get_shelter_previous_state() -> String:
	return _text("shelter_previous_state", "Previous shelter run:")

static func get_shelter_hud(power_on: bool, valves_open: bool, oxygen: float, civilian_aid: int) -> String:
	var template := _text(
		"shelter_hud",
		"FINAL THAW | Generator %s | Valves %s | Oxygen %.0fs | Civilian aid %d/10"
	)
	return template % [
		get_shelter_state_power(power_on),
		get_shelter_state_valves(valves_open),
		oxygen,
		civilian_aid,
	]

const CONTROL_ROOM_KEYS: Array[String] = [
	"cr_log_before_title",
	"cr_log_before_body",
	"cr_log_after_title",
	"cr_log_after_body",
	"cr_breaker_a_response",
	"cr_breaker_b_response",
	"cr_breaker_b_cooldown",
	"cr_breaker_c_response",
	"cr_gate_locked",
	"cr_gate_open_prompt",
	"cr_prompt_read_log",
	"cr_prompt_use_breaker",
	"cr_trace_a",
	"cr_trace_b",
	"cr_trace_c",
	"cr_hint_level_1",
	"cr_hint_level_2",
	"cr_objective_start",
	"cr_objective_done",
	"cr_hint_button",
]

static func get_control_room_text(key: String) -> String:
	if not CONTROL_ROOM_KEYS.has(key):
		push_warning("Unknown control room text key: %s" % key)
		return ""
	var value := _text(key)
	if value.is_empty() and OS.is_debug_build():
		push_warning("Missing control room text: %s (%s)" % [key, current_locale])
	return value
