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

func _new_room() -> Node:
	var room = load("res://scenes/levels/test_room.tscn").instantiate()
	add_child(room)
	return room

func _run() -> void:
	check("01 GameManager autoload existe", get_node_or_null("/root/GameManager") != null)

	var actions := ["move_up","move_down","move_left","move_right","attack_primary","attack_secondary",
		"dodge","interact","scan","pause","quick_save","quick_load","toggle_captions",
		"increase_font","decrease_font","toggle_colorblind_mode"]
	var missing := actions.filter(func(a): return not InputMap.has_action(a))
	check("02 Input Map tiene las 16 acciones", missing.is_empty())

	var room = _new_room()
	await get_tree().process_frame
	var p = room.player
	var x0: float = p.position.x
	Input.action_press("move_right")
	for i in 20:
		await get_tree().physics_frame
	Input.action_release("move_right")
	check("03 El jugador se mueve con move_right", p.position.x > x0 + 10.0)

	p.position = room.interactables[0].position
	for i in 4:
		await get_tree().physics_frame
	var did: bool = p.try_interact()
	check("04 Interaccion con objeto cercano", did and room.interactables[0].interact_count == 1)

	var old_aid: int = GameManager.civilian_aid
	GameManager.civilian_aid = 4
	room.hud.refresh()
	check("05 HUD refleja civilian_aid", room.hud.aid_label.text.contains("4/10"))
	GameManager.civilian_aid = old_aid

	check("10 Test room tiene 3 interactuables", room.interactables.size() == 3)
	room.queue_free()
	await get_tree().process_frame

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
	check("09 MainMenu tiene 5 botones", get_tree().get_nodes_in_group("menu_button").size() == 5)
	menu.queue_free()
	await get_tree().process_frame

	var before: bool = DebugManager.god_mode
	DebugManager.toggle_god_mode()
	var toggled: bool = DebugManager.god_mode != before
	DebugManager.toggle_god_mode()
	check("11 DebugManager alterna god mode", toggled and DebugManager.god_mode == before)
