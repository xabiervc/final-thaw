extends Node2D

const Rules = preload("res://scripts/vertical_slice/shelter_rules.gd")
const PlayerScript = preload("res://scripts/entities/player.gd")

const BG := Color("182b39")
const WATER := Color("245975")
const LOCKED := Color("70505a")
const ACTIVE := Color("48ad99")
const TEXT := Color("eff4ee")

var rules = Rules.new()
var player: CharacterBody2D
var hud: Label
var hint: Label
var result: Label
var objects: Array[Area2D] = []
var ended: bool = false

func _ready() -> void:
	add_to_group("vertical_slice")
	var floor_rect := ColorRect.new()
	floor_rect.color = BG
	floor_rect.size = Vector2(2100, 800)
	add_child(floor_rect)
	for n in 3:
		var room := ColorRect.new()
		room.color = WATER if n > 0 else Color("30465a")
		room.position = Vector2(70 + n * 650, 110)
		room.size = Vector2(600, 550)
		add_child(room)
	_create_interactable("POWER", Vector2(280, 390))
	_create_interactable("VALVES", Vector2(930, 390))
	_create_interactable("CIVILIAN", Vector2(1510, 390))
	_create_interactable("EXIT", Vector2(1840, 390))
	player = PlayerScript.new()
	player.position = Vector2(125, 390)
	add_child(player)
	var camera := Camera2D.new()
	player.add_child(camera)
	camera.make_current()
	var ui := CanvasLayer.new()
	add_child(ui)
	hud = _label(ui, Vector2(24, 20), "")
	hint = _label(ui, Vector2(24, 56), "")
	result = _label(ui, Vector2(230, 245), "")
	result.visible = false
	_update_ui("E: energia, valvulas, rescate y salida. WASD/flechas para moverse.")

func _create_interactable(kind: String, location: Vector2) -> void:
	var area := Area2D.new()
	area.position = location
	area.set_meta("kind", kind)
	area.add_to_group("shelter_interactable")
	area.monitorable = true
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(90, 90)
	shape_node.shape = shape
	area.add_child(shape_node)
	var graphic := ColorRect.new()
	graphic.color = ACTIVE if kind == "POWER" else LOCKED
	graphic.position = Vector2(-45, -45)
	graphic.size = Vector2(90, 90)
	area.add_child(graphic)
	var label := Label.new()
	label.text = kind
	label.position = Vector2(-44, -82)
	label.add_theme_color_override("font_color", TEXT)
	area.add_child(label)
	add_child(area)
	objects.append(area)

func _label(parent: Node, pos: Vector2, value: String) -> Label:
	var label := Label.new()
	label.position = pos
	label.text = value
	label.add_theme_color_override("font_color", TEXT)
	label.add_theme_font_size_override("font_size", 20)
	parent.add_child(label)
	return label

func _process(delta: float) -> void:
	if ended:
		return
	if rules.valves_open:
		if rules.drain_oxygen(delta):
			_on_oxygen_empty()
		_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if ended:
		if event.is_action_pressed("interact"):
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
		return
	if event.is_action_pressed("scan"):
		_update_ui("Orden: energia -> valvulas -> rescate opcional -> salida.")
	elif event.is_action_pressed("interact"):
		var target := _closest_object()
		if target != null:
			_interact_with(str(target.get_meta("kind")))

func _closest_object() -> Area2D:
	var best: Area2D = null
	var distance := 110.0
	for item in objects:
		var candidate: float = player.global_position.distance_to(item.global_position)
		if candidate < distance:
			distance = candidate
			best = item
	return best

func _interact_with(kind: String) -> void:
	match kind:
		"POWER":
			_update_ui("Energia restaurada." if rules.activate_power() else "Energia ya conectada.")
		"VALVES":
			_update_ui("Valvulas abiertas. El oxigeno se agota." if rules.open_valves() else "Primero conecta la energia.")
		"CIVILIAN":
			if rules.rescue():
				GameManager.civilian_aid = mini(10, GameManager.civilian_aid + 1)
				GameManager.stats_changed.emit()
				GameManager.save_game(0)
				_update_ui("Civil rescatada. Ayuda civil +1; partida guardada.")
			else:
				_update_ui("Abre las valvulas para llegar a la civil.")
		"EXIT":
			if rules.can_exit():
				_finish("REFUGIO SUPERADO\nCivil rescatada: %s\nAyuda civil: %d/10\nE para volver al menu" % ["SI" if rules.rescued else "NO", GameManager.civilian_aid])
			else:
				_update_ui("La salida sigue bloqueada. Activa energia y valvulas.")

func _on_oxygen_empty() -> void:
	player.position = Vector2(125, 390)
	rules.reset()
	_update_ui("Sin oxigeno. Reinicio desde la entrada; tu rescate guardado permanece.")

func _update_ui(message: String = "") -> void:
	hud.text = "FINAL THAW | Energia %s | Valvulas %s | Oxigeno %.0fs | Ayuda civil %d/10" % ["ON" if rules.power_on else "OFF", "ABIERTAS" if rules.valves_open else "CERRADAS", rules.oxygen, GameManager.civilian_aid]
	if not message.is_empty():
		hint.text = message

func _finish(message: String) -> void:
	ended = true
	player.set_physics_process(false)
	GameManager.save_game(0)
	result.text = message
	result.visible = true
