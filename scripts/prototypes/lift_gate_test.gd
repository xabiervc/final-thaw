extends Node3D
## Manual scene for the lift gate. Not a mission scene: a lower and an upper landing joined by the service lift, Elena with
## the orbit camera, and the controls needed to try every rule by hand.
## Run: godot --path . res://scenes/prototypes/lift_gate_test.tscn
## WASD move, Space jump, E call or send, P cut or restore power, R back to the lower landing, Esc release mouse / menu.
const Rig = preload("res://scripts/prototypes/lift_test_rig.gd")
const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const CALL_REACH := 2.2

var lift = null
var player: CharacterBody3D
var label: Label
var prompt: Label
var falls: int = 0


func _ready() -> void:
	var env := Environment.new()
	env.background_color = Color(0.03, 0.04, 0.06)
	env.background_mode = Environment.BG_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.7, 0.8)
	env.ambient_light_energy = 0.6
	var holder := WorldEnvironment.new()
	holder.environment = env
	add_child(holder)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, 25.0, 0.0)
	sun.light_energy = 0.8
	add_child(sun)
	lift = Rig.build(self)
	player = Player.new()
	player.position = Vector3(0.0, 0.2, 6.0)
	add_child(player)
	var layer := CanvasLayer.new()
	add_child(layer)
	label = Label.new()
	label.position = Vector2(16.0, 16.0)
	label.add_theme_constant_override("outline_size", 6)
	layer.add_child(label)
	prompt = Label.new()
	prompt.position = Vector2(16.0, 640.0)
	prompt.add_theme_font_size_override("font_size", 22)
	prompt.add_theme_constant_override("outline_size", 6)
	layer.add_child(prompt)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _controls() -> Array:
	return [
		{"name": "Llamar al ascensor (nivel inferior)", "at": Vector3(2.6, 0.0, 3.5), "action": "lower"},
		{"name": "Llamar al ascensor (nivel superior)", "at": Vector3(2.6, 3.0, -3.0), "action": "upper"},
		{"name": "Enviar el ascensor", "at": Vector3(1.0, lift.platform_y, 0.0), "action": "send"},
	]


func _physics_process(_delta: float) -> void:
	var best: Dictionary = {}
	var best_distance: float = CALL_REACH
	for control in _controls():
		var d: float = player.position.distance_to(control["at"])
		if d < best_distance:
			best_distance = d
			best = control
	prompt.text = "[E] " + str(best["name"]) if not best.is_empty() else ""
	if not best.is_empty() and Input.is_action_just_pressed("interact"):
		var accepted: bool = false
		match str(best["action"]):
			"send":
				accepted = lift.send()
			_:
				accepted = lift.call_to(str(best["action"]))
		if not accepted:
			prompt.text = "El ascensor no tiene energía"
	if player.position.y < -5.0:
		falls += 1
		_respawn()
	label.text = "PRUEBA DEL ASCENSOR (no es una misión)\nEstado: %s   |   Energía: %s   |   Cubierta a %.2f m   |   Caídas: %d\nE llamar o enviar · P cortar o restaurar energía · R volver abajo · Esc menú" % [lift.describe(), "sí" if lift.powered else "NO", lift.platform_y, falls]


func _respawn() -> void:
	player.position = Vector3(0.0, 0.2, 6.0)
	player.velocity = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo:
		if key.physical_keycode == KEY_P:
			lift.set_powered(not lift.powered)
			return
		if key.physical_keycode == KEY_R:
			_respawn()
			return
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file(MENU_PATH)
