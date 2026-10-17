extends Node
## Ejecutar: godot --headless --path . res://tests/test_phase_0.tscn

var passed := 0
var failed := 0

func check(name: String, cond: bool) -> void:
	if cond:
		passed += 1
		print("PASS  ", name)
	else:
		failed += 1
		print("FAIL  ", name)

func _ready() -> void:
	await get_tree().process_frame
	await _run()
	print("=== %d passed, %d failed ===" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)

func _run() -> void:
	check("01 GameManager autoload existe", get_node_or_null("/root/GameManager") != null)

	var actions := ["move_up","move_down","move_left","move_right","attack_primary","attack_secondary",
		"dodge","interact","scan","pause","quick_save","quick_load","toggle_captions",
		"increase_font","decrease_font","toggle_colorblind_mode"]
	var missing := actions.filter(func(a): return not InputMap.has_action(a))
	check("02 Input Map tiene las 16 acciones", missing.is_empty())

	# Checks 03-05 and 10 exercised the Phase 0 graybox room (test_room.tscn), removed in e31d1b6.
	# Movement, interaction and HUD are covered by test_vertical_slice, test_first_room_rules and the control room tests.

	GameManager.civilian_aid = 7
	GameManager.font_scale = 1.5
	var saved: bool = GameManager.save_game(99)
	GameManager.civilian_aid = 0
	GameManager.font_scale = 1.0
	var loaded: bool = GameManager.load_game(99)
	check("06 Guardar y cargar conserva datos", saved and loaded and GameManager.civilian_aid == 7)
	check("08 Escala de fuente persiste", is_equal_approx(GameManager.font_scale, 1.5))

	var f := FileAccess.open(GameManager.save_path(99), FileAccess.READ)
	var container = JSON.parse_string(f.get_as_text())
	f.close()
	container["payload"] = str(container["payload"]).replace("civilian_aid", "civilian_aidX")
	var w := FileAccess.open(GameManager.save_path(99), FileAccess.WRITE)
	w.store_string(JSON.stringify(container))
	w.close()
	check("07 CRC32 detecta corrupcion", GameManager.load_game(99) == false)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.save_path(99)))

	var menu = load("res://scenes/ui/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	var escape_button: Node = menu.get_node_or_null("CenterContainer/Panel/MarginContainer/VBoxContainer/SecondaryRow/EscapeButton")
	check(
		"09 MainMenu tiene 6 botones e incluye el acceso al escape",
		get_tree().get_nodes_in_group("menu_button").size() == 6 and escape_button is Button
	)
	menu.queue_free()
	await get_tree().process_frame

	var before: bool = DebugManager.god_mode
	DebugManager.toggle_god_mode()
	var toggled: bool = DebugManager.god_mode != before
	DebugManager.toggle_god_mode()
	check("11 DebugManager alterna god mode", toggled and DebugManager.god_mode == before)
