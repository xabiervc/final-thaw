extends Node2D

const PlayerScript = preload("res://scripts/entities/player.gd")
const RulesScript = preload("res://scripts/vertical_slice/first_room_rules.gd")

const ROOM_SIZE := Vector2(1280.0, 720.0)
const WALL_THICKNESS := 32.0
const PLAYER_START := Vector2(170.0, 500.0)
const INTERACT_DISTANCE := 115.0

var rules = RulesScript.new()
var player: CharacterBody2D
var objective_label: Label
var prompt_label: Label
var status_label: Label
var console_node: Area2D
var exit_node: Area2D
var exit_message: Label
var completed := false

func _ready() -> void:
	_create_room()
	_create_console()
	_create_exit()
	_create_player()
	_create_hud()
	_update_room_state()

func _create_room() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("17232d")
	backdrop.size = ROOM_SIZE
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var rear_panel := ColorRect.new()
	rear_panel.color = Color("263946")
	rear_panel.position = Vector2(40.0, 70.0)
	rear_panel.size = Vector2(1200.0, 430.0)
	rear_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rear_panel)
	var floor_visual := ColorRect.new()
	floor_visual.color = Color("46545a")
	floor_visual.position = Vector2(0.0, 570.0)
	floor_visual.size = Vector2(ROOM_SIZE.x, 150.0)
	floor_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_visual)
	_add_wall(Vector2(0.0, 0.0), Vector2(ROOM_SIZE.x, WALL_THICKNESS))
	_add_wall(Vector2(0.0, ROOM_SIZE.y - WALL_THICKNESS), Vector2(ROOM_SIZE.x, WALL_THICKNESS))
	_add_wall(Vector2(0.0, WALL_THICKNESS), Vector2(WALL_THICKNESS, ROOM_SIZE.y - WALL_THICKNESS * 2.0))
	_add_wall(Vector2(ROOM_SIZE.x - WALL_THICKNESS, WALL_THICKNESS), Vector2(WALL_THICKNESS, ROOM_SIZE.y - WALL_THICKNESS * 2.0))
	var room_title := _make_label(self, Vector2(48.0, 36.0), "REFUGIO DE EMERGENCIA  /  SALA DE CONTROL", 20, Color("d8e4e8"))
	room_title.z_index = 5
	_add_detail_line(Vector2(70.0, 150.0), Vector2(1210.0, 150.0), Color("536d7a"))
	_add_detail_line(Vector2(70.0, 510.0), Vector2(1210.0, 510.0), Color("536d7a"))

func _add_wall(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos + size * 0.5
	body.collision_layer = 1
	body.collision_mask = 0
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	body.add_child(shape_node)
	add_child(body)
	var visual := ColorRect.new()
	visual.color = Color("718087")
	visual.position = pos
	visual.size = size
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.z_index = 2
	add_child(visual)

func _add_detail_line(start: Vector2, finish: Vector2, color: Color) -> void:
	var line := Line2D.new()
	line.points = PackedVector2Array([start, finish])
	line.width = 2.0
	line.default_color = color
	line.z_index = 3
	add_child(line)

func _create_console() -> void:
	console_node = Area2D.new()
	console_node.position = Vector2(500.0, 500.0)
	console_node.collision_layer = 4
	console_node.collision_mask = 0
	console_node.add_to_group("interactable")
	var shape_node := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 42.0
	shape_node.shape = shape
	console_node.add_child(shape_node)
	add_child(console_node)
	var panel := ColorRect.new()
	panel.color = Color("267b85")
	panel.position = Vector2(-42.0, -70.0)
	panel.size = Vector2(84.0, 110.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.z_index = 4
	console_node.add_child(panel)
	var screen := ColorRect.new()
	screen.name = "Screen"
	screen.color = Color("f0b64a")
	screen.position = Vector2(-28.0, -55.0)
	screen.size = Vector2(56.0, 26.0)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.z_index = 5
	console_node.add_child(screen)
	_make_label(console_node, Vector2(-70.0, 48.0), "CONSOLA", 16, Color("f1f3ef"))

func _create_exit() -> void:
	exit_node = Area2D.new()
	exit_node.position = Vector2(1110.0, 500.0)
	exit_node.collision_layer = 4
	exit_node.collision_mask = 0
	exit_node.add_to_group("interactable")
	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(95.0, 150.0)
	shape_node.shape = shape
	exit_node.add_child(shape_node)
	add_child(exit_node)
	var frame := ColorRect.new()
	frame.name = "Frame"
	frame.color = Color("9e474b")
	frame.position = Vector2(-47.0, -88.0)
	frame.size = Vector2(94.0, 176.0)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.z_index = 3
	exit_node.add_child(frame)
	var door := ColorRect.new()
	door.name = "Door"
	door.color = Color("652f39")
	door.position = Vector2(-35.0, -76.0)
	door.size = Vector2(70.0, 152.0)
	door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	door.z_index = 4
	exit_node.add_child(door)
	_make_label(exit_node, Vector2(-72.0, -116.0), "SALIDA", 18, Color("f1f3ef"))
	exit_message = _make_label(exit_node, Vector2(-94.0, 96.0), "BLOQUEADA", 14, Color("ffc0a8"))
	exit_message.name = "ExitState"

func _create_player() -> void:
	player = PlayerScript.new()
	player.position = PLAYER_START
	add_child(player)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(ROOM_SIZE.x)
	camera.limit_bottom = int(ROOM_SIZE.y)
	player.add_child(camera)
	camera.make_current()

func _create_hud() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	var panel := ColorRect.new()
	panel.color = Color(0.035, 0.055, 0.075, 0.92)
	panel.position = Vector2(24.0, 22.0)
	panel.size = Vector2(690.0, 132.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(panel)
	objective_label = _make_label(ui, Vector2(46.0, 38.0), "OBJETIVO  /  Restablece la energía para abrir la puerta", 22, Color("f2f5f4"))
	prompt_label = _make_label(ui, Vector2(46.0, 82.0), "", 18, Color("8ee5d1"))
	status_label = _make_label(ui, Vector2(46.0, 116.0), "E: interactuar  |  WASD/flechas: moverse", 16, Color("bac7cc"))
	var return_label := _make_label(ui, Vector2(1010.0, 24.0), "ESC: menú", 16, Color("d7e0e3"))
	return_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	return_label.size = Vector2(230.0, 28.0)
	var identity := _make_label(ui, Vector2(1100.0, 672.0), "ELENA", 17, Color("eef2f0"))
	identity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	identity.size = Vector2(140.0, 28.0)

func _make_label(parent: Node, pos: Vector2, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _process(_delta: float) -> void:
	if completed or player == null:
		return
	var target: Area2D = player.get_nearest_interactable()
	if target == console_node:
		prompt_label.text = "E  /  ACTIVAR CONSOLA" if not rules.power_restored else "ENERGÍA RESTABLECIDA"
	elif target == exit_node:
		prompt_label.text = "E  /  ABRIR SALIDA" if rules.can_open_exit() else "SALIDA BLOQUEADA — falta energía"
	else:
		prompt_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.change_scene("res://scenes/ui/main_menu.tscn")
		return
	if completed or not event.is_action_pressed("interact") or event.is_echo():
		return
	var target: Area2D = player.get_nearest_interactable()
	if target == console_node:
		var activated: bool = rules.activate_power()
		status_label.text = "Generador conectado. La puerta de salida ya tiene energía." if activated else "La energía ya está restablecida."
		_update_room_state()
	elif target == exit_node:
		if rules.can_open_exit():
			_complete_room()
		else:
			status_label.text = "Primero restablece la energía en la consola."

func _update_room_state() -> void:
	var screen := console_node.get_node("Screen") as ColorRect
	screen.color = Color("62f0c1") if rules.power_restored else Color("f0b64a")
	var door := exit_node.get_node("Door") as ColorRect
	var frame := exit_node.get_node("Frame") as ColorRect
	var opened := rules.can_open_exit()
	door.color = Color("285e59") if opened else Color("652f39")
	frame.color = Color("56c7a7") if opened else Color("9e474b")
	exit_message.text = "LISTA — E" if opened else "BLOQUEADA"
	exit_message.add_theme_color_override("font_color", Color("8ee5d1") if opened else Color("ffc0a8"))

func _complete_room() -> void:
	completed = true
	player.set_physics_process(false)
	objective_label.text = "SALA SUPERADA  /  Energía restaurada; salida abierta"
	prompt_label.text = "PRIMER OBJETIVO COMPLETADO"
	status_label.text = "Has restablecido la energía. Pulsa ESC para volver al menú."
