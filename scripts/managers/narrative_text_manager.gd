extends Node
class_name NarrativeTextManager

## Singleton para acceder a los textos de narrativa desde cualquier escena.
## Usa el recurso data/narrative_text.tres y permite sobrescribir valores en tiempo de ejecución.

static var texts: NarrativeText

static func _initialize() -> void:
	if texts != null:
		return
	var path = "res://data/narrative_text.tres"
	if ResourceLoader.exists(path):
		texts = ResourceLoader.load(path) as NarrativeText
	else:
		texts = NarrativeText.new()

static func get_menu_title() -> String:
	_initialize()
	return texts.menu_title

static func get_menu_context() -> String:
	_initialize()
	return texts.menu_context

static func get_menu_start_button() -> String:
	_initialize()
	return texts.menu_start_button

static func get_hud_oxygen_label(value: float) -> String:
	_initialize()
	return texts.hud_oxygen_label % int(value)

static func get_hud_civilian_state(trapped: bool, rescued: bool, dead: bool) -> String:
	_initialize()
	if dead:
		return texts.hud_civilian_dead
	if rescued:
		return texts.hud_civilian_rescued
	return texts.hud_civilian_trapped

static func get_hud_objective(has_power: bool, valves_open: int, civilian_exists: bool, civilian_trapped: bool) -> String:
	_initialize()
	if not has_power:
		return texts.hud_objective_start
	if valves_open < 2:
		return texts.hud_objective_power_on
	if civilian_exists and civilian_trapped:
		return texts.hud_objective_valves_open
	return texts.hud_objective_exit

static func get_interact_power_console(is_on: bool) -> String:
	_initialize()
	return texts.interact_power_console_on if is_on else texts.interact_power_console_off

static func get_interact_valve(is_open: bool) -> String:
	_initialize()
	return texts.interact_valve_open if is_open else texts.interact_valve_closed

static func get_interact_civilian(is_trapped: bool) -> String:
	_initialize()
	return texts.interact_civilian_trapped if is_trapped else texts.interact_civilian_rescued

static func get_random_civilian_rescue_line() -> String:
	_initialize()
	if texts.civilian_rescue_lines.is_empty():
		return ""
	return texts.civilian_rescue_lines.pick_random()

static func get_end_title(success: bool) -> String:
	_initialize()
	return texts.end_title_success if success else texts.end_title_failure

static func get_end_elena(alive: bool) -> String:
	_initialize()
	return texts.end_elena_alive if alive else texts.end_elena_dead

static func get_end_civilian(rescued: bool, dead: bool, unknown: bool) -> String:
	_initialize()
	if unknown:
		return texts.end_civilian_unknown
	return texts.hud_civilian_rescued if rescued else texts.hud_civilian_dead if dead else texts.hud_civilian_trapped

static func get_end_power_restored() -> String:
	_initialize()
	return texts.end_power_restored

static func get_end_valves_opened() -> String:
	_initialize()
	return texts.end_valves_opened

static func get_end_civilian_rescued() -> String:
	_initialize()
	return texts.end_civilian_rescued

static func get_end_civilian_not_rescued() -> String:
	_initialize()
	return texts.end_civilian_not_rescued

static func get_end_button_menu() -> String:
	_initialize()
	return texts.end_button_menu

static func get_end_button_restart() -> String:
	_initialize()
	return texts.end_button_restart
