extends Node3D

const B = preload("res://scripts/components/build_util.gd")
const ElenaScript = preload("res://scripts/characters/elena_controller.gd")
const TerminalScript = preload("res://scripts/components/terminal.gd")
const LeverScript = preload("res://scripts/components/lever.gd")
const DoorScript = preload("res://scripts/components/door.gd")
const InspectScript = preload("res://scripts/components/inspect_point.gd")
const ManagerScript = preload("res://scripts/components/interaction_manager.gd")
const ScanScript = preload("res://scripts/components/scan_system.gd")
const CameraScript = preload("res://scripts/components/follow_camera.gd")
const PanelScript = preload("res://scripts/ui/narrative_panel.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")

const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const NEXT_PATH := "res://scenes/levels/abandoned_lab.tscn"
const ROOM_ID := "elena_test_room"
const START := Vector3(-9.0, 0.1, 5.0)

var elena = null
var manager = null
var scanner = null
var hud = null
var panel = null
var terminal = null
var lever = null
var door = null
var completed: bool = false

func _ready() -> void:
	_build_environment()
	_build_room()
	_build_props()
	_build_player()
	_build_ui()
	panel.call("show_message", "Sala de pruebas de Elena. Examina el terminal y busca la forma de abrir la puerta del este.", 9.0)

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.05, 0.07)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.35, 0.42, 0.5)
	env.ambient_light_energy = 0.6
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.1, 0.14, 0.18)
	env.fog_density = 0.01
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60.0, -30.0, 0.0)
	sun.light_energy = 0.9
	sun.light_color = Color(0.75, 0.85, 1.0)
	sun.shadow_enabled = true
	add_child(sun)
	_add_lamp(Vector3(-6.0, 3.0, 0.0), Color(1.0, 0.85, 0.6), 1.2)
	_add_lamp(Vector3(2.0, 3.0, 2.0), Color(0.7, 0.85, 1.0), 1.0)
	_add_lamp(Vector3(10.5, 2.6, 0.0), Color(0.5, 1.0, 0.8), 1.0)

func _add_lamp(pos: Vector3, color: Color, energy: float) -> void:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = 9.0
	add_child(l)

func _grid_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial;\nvarying vec3 wpos;\nvoid vertex() {\n\twpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;\n}\nvoid fragment() {\n\tvec2 g = abs(fract(wpos.xz - 0.5) - 0.5) / max(fwidth(wpos.xz), vec2(0.0001));\n\tfloat line = 1.0 - clamp(min(g.x, g.y), 0.0, 1.0);\n\tvec3 base = vec3(0.13, 0.16, 0.18);\n\tALBEDO = mix(base, vec3(0.28, 0.36, 0.40), line * 0.9);\n\tROUGHNESS = 0.75;\n}\n"
	var sm := ShaderMaterial.new()
	sm.shader = shader
	return sm

func _build_room() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.position = Vector3(0.0, -0.25, 0.0)
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(24.0, 0.5, 16.0)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	var floor_mesh := MeshInstance3D.new()
	var floor_res := BoxMesh.new()
	floor_res.size = Vector3(24.0, 0.5, 16.0)
	floor_mesh.mesh = floor_res
	floor_mesh.material_override = _grid_material()
	floor_body.add_child(floor_mesh)
	add_child(floor_body)

	var wall := Color(0.22, 0.26, 0.3)
	B.solid_box(self, Vector3(25.0, 3.2, 0.5), Vector3(0.0, 1.6, -8.25), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 17.0), Vector3(-12.25, 1.6, 0.0), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 17.0), Vector3(12.25, 1.6, 0.0), wall)
	B.solid_box(self, Vector3(25.0, 0.9, 0.5), Vector3(0.0, 0.45, 8.25), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 6.6), Vector3(8.5, 1.6, -4.7), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 6.6), Vector3(8.5, 1.6, 4.7), wall)

	B.box(self, Vector3(0.2, 2.6, 0.2), Vector3(11.0, 1.3, -1.2), Color(0.2, 0.9, 0.6), 2.0)
	B.box(self, Vector3(0.2, 2.6, 0.2), Vector3(11.0, 1.3, 1.2), Color(0.2, 0.9, 0.6), 2.0)
	B.box(self, Vector3(0.2, 0.2, 2.6), Vector3(11.0, 2.6, 0.0), Color(0.2, 0.9, 0.6), 2.0)
	B.label3d(self, "PUNTO DE CONTROL", Vector3(11.0, 3.2, 0.0), 40, Color(0.5, 1.0, 0.8))

	B.solid_box(self, Vector3(1.2, 0.8, 1.0), Vector3(0.0, 0.4, -5.3), Color(0.3, 0.27, 0.23))
	B.solid_box(self, Vector3(1.2, 1.2, 1.0), Vector3(2.0, 0.6, -5.3), Color(0.3, 0.27, 0.23))

func _build_props() -> void:
	terminal = TerminalScript.new()
	terminal.display_name = "Terminal de seguridad"
	terminal.save_id = "terminal"
	terminal.position = Vector3(-5.0, 0.0, -1.0)
	add_child(terminal)

	lever = LeverScript.new()
	lever.display_name = "Palanca del generador"
	lever.save_id = "lever"
	lever.position = Vector3(3.5, 0.0, -1.0)
	add_child(lever)

	door = DoorScript.new()
	door.display_name = "Puerta de salida"
	door.save_id = "door"
	door.position = Vector3(8.5, 0.0, 0.0)
	door.interaction_range = 3.0
	add_child(door)

	_add_inspect("crate_a", 0, Vector3(-9.0, 0.0, -5.0), "Caja de suministros del laboratorio. Está vacía.")
	_add_inspect("console_b", 1, Vector3(-2.0, 0.0, 4.0), "Un monitor auxiliar muestra una transmisión parcial. Destino: Estación Final Thaw.")
	_add_inspect("barrel_c", 2, Vector3(1.0, 0.0, -6.6), "Detrás de las cajas, un barril con el sello de Helix.")
	_add_inspect("crate_d", 0, Vector3(5.5, 0.0, 5.0), "Una mochila abandonada con una manta térmica. Alguien se marchó con prisa.")
	_add_inspect("console_e", 1, Vector3(-10.5, 0.0, 0.5), "Un mapa de evacuación con la ruta norte tachada a mano.")
	_add_inspect("crate_f", 0, Vector3(6.2, 0.0, -5.0), "Material de campo del proyecto Aster, guardado a toda prisa.")

	lever.toggled.connect(_on_lever_toggled)
	door.opened.connect(_on_door_opened)

func _add_inspect(id: String, variant: int, pos: Vector3, text: String) -> void:
	var p = InspectScript.new()
	p.save_id = id
	p.variant = variant
	p.message = text
	p.display_name = "Objeto"
	p.position = pos
	add_child(p)

func _build_player() -> void:
	elena = ElenaScript.new()
	elena.position = START
	add_child(elena)
	elena.fell_off.connect(_on_fell)

	manager = ManagerScript.new()
	manager.actor = elena
	add_child(manager)

	scanner = ScanScript.new()
	scanner.actor = elena
	add_child(scanner)

	var cam = CameraScript.new()
	cam.target = elena
	cam.limit_min = Vector2(-5.0, -3.0)
	cam.limit_max = Vector2(5.0, 3.0)
	add_child(cam)

func _build_ui() -> void:
	hud = HudScript.new()
	add_child(hud)
	hud.call("set_objective", "OBJETIVO  /  Restablece la energía para abrir la puerta del este")
	panel = PanelScript.new()
	add_child(panel)

func _process(_delta: float) -> void:
	var t = manager.current_target
	var line := ""
	if t != null and is_instance_valid(t):
		line = str(t.call("get_prompt_line"))
	hud.call("set_prompt", line)
	if not completed and door.is_open and elena.global_position.x > 10.0:
		_complete_room()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file(MENU_PATH)
		return
	if event.is_action_pressed("quick_save") and not event.is_echo():
		_save_room()
		panel.call("show_message", "Partida guardada.", 3.0)
	elif event.is_action_pressed("quick_load") and not event.is_echo():
		_load_room()

func _on_lever_toggled(on: bool) -> void:
	door.call("set_locked", not on)
	if on:
		hud.call("set_objective", "OBJETIVO  /  Cruza la puerta del este")
	else:
		hud.call("set_objective", "OBJETIVO  /  Restablece la energía para abrir la puerta del este")

func _on_door_opened() -> void:
	hud.call("set_objective", "OBJETIVO  /  Llega al punto de control")

func _on_fell() -> void:
	elena.global_position = START

func _complete_room() -> void:
	completed = true
	elena.input_enabled = false
	hud.call("set_objective", "SALA SUPERADA  /  Energía restaurada")
	panel.call("show_message", "Primer sistema restaurado. Continuando hacia el laboratorio abandonado...", 6.0)
	GameManager.current_checkpoint_id = "elena_test_room_exit"
	_save_room()
	get_tree().create_timer(6.0).timeout.connect(_go_next)

func _go_next() -> void:
	get_tree().change_scene_to_file(NEXT_PATH)

func _save_room() -> void:
	var data := {}
	data["player"] = [elena.global_position.x, elena.global_position.y, elena.global_position.z]
	for n in get_tree().get_nodes_in_group("interactables"):
		var sid := str(n.get("save_id"))
		if sid != "" and sid != "<null>":
			data[sid] = n.call("get_state")
	GameManager.world_state[ROOM_ID] = data
	GameManager.save_game(0)

func _load_room() -> void:
	if not GameManager.load_game(0):
		panel.call("show_message", "No hay partida guardada.", 3.0)
		return
	var data = GameManager.world_state.get(ROOM_ID, null)
	if typeof(data) != TYPE_DICTIONARY:
		panel.call("show_message", "No hay datos de esta sala en la partida.", 3.0)
		return
	for n in get_tree().get_nodes_in_group("interactables"):
		var sid := str(n.get("save_id"))
		if sid != "" and data.has(sid):
			n.call("apply_state", data[sid])
	door.call("set_locked", not lever.is_on)
	var p = data.get("player", null)
	if p is Array and p.size() == 3:
		elena.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
		elena.velocity = Vector3.ZERO
	panel.call("show_message", "Partida cargada.", 3.0)
