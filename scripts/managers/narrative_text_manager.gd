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

static func get_menu_title() -> String:
	return _text("menu_title", "Final Thaw")

static func get_menu_context() -> String:
	return _text("menu_context")

static func get_menu_start_button() -> String:
	return _text("menu_start_button", "Start Demo")

static func get_hud_oxygen_label(value: float) -> String:
	return _text("hud_oxygen_label", "Oxygen: %d%%") % int(value)

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

## Claves de texto del puzle de registros y cableado. Cada clave debe existir y no estar vacia en ES y EN.
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
