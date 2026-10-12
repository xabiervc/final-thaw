extends Node3D

const B = preload("res://scripts/components/build_util.gd")
const ElenaScript = preload("res://scripts/characters/elena_controller.gd")
const TerminalScript = preload("res://scripts/components/powered_terminal.gd")
const NodeScript = preload("res://scripts/components/connection_node.gd")
const JunctionScript = preload("res://scripts/components/junction_box.gd")
const ArmScript = preload("res://scripts/components/robotic_arm.gd")
const CheckpointScript = preload("res://scripts/components/checkpoint.gd")
const FragmentScript = preload("res://scripts/components/memory_fragment.gd")
const DoorScript = preload("res://scripts/components/door.gd")
const ManagerScript = preload("res://scripts/components/interaction_manager.gd")
const ScanScript = preload("res://scripts/components/scan_system.gd")
const CameraScript = preload("res://scripts/components/follow_camera.gd")
const PanelScript = preload("res://scripts/ui/narrative_panel.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")

const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const ROOM_ID := "abandoned_lab"
const START := Vector3(2.0, 0.1, 3.0)
const DIVIDER_1 := 16.0
const DIVIDER_2 := 34.0
const END_X := 42.0

const ENTRY = [
	"Los sistemas están apagados. Tengo que devolver la energía.",
	"Un brazo robótico bloquea el paso. El terminal lo controla.",
]
const DONE = [
	"Energía restaurada. La instalación me recuerda.",
	"Brazo fijado. Solo un ángulo es seguro.",
]

var elena = null
var manager = null
var scanner = null
var hud = null
var panel = null
var grid_material = null
var doors: Array = []
var r1_nodes: Array = []
var r1_junction = null
var r1_lamps: Array = []
var r1_done: bool = false
var arm = null
var arm_latched: bool = false
var respawn: Vector3 = START
var finished: bool = false

func _ready() -> void:
	GameManager.prototype_integrity = 3
	GameManager.has_prototype = false
	GameManager.memory_fragments_collected = []
	GameManager.current_checkpoint_id = ""
	_build_environment()
	_build_shell()
	_build_doors_and_checkpoints()
	_build_room1()
	_build_room2()
	_build_player()
	_build_ui()
	panel.call("show_message", ENTRY[0], 9.0)

func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.35, 0.42, 0.5)
	env.ambient_light_energy = 0.3
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.fog_enabled = true
	env.fog_light_color = Color(0.08, 0.11, 0.15)
	env.fog_density = 0.012
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60.0, -30.0, 0.0)
	sun.light_energy = 0.35
	sun.light_color = Color(0.7, 0.8, 1.0)
	sun.shadow_enabled = true
	add_child(sun)
	r1_lamps.append(_add_lamp(Vector3(4.0, 3.0, 0.0), Color(1.0, 0.85, 0.6), 0.0))
	r1_lamps.append(_add_lamp(Vector3(11.0, 3.0, 0.0), Color(0.8, 0.9, 1.0), 0.0))
	_add_lamp(Vector3(20.0, 3.0, 0.0), Color(0.7, 0.85, 1.0), 1.0)
	_add_lamp(Vector3(29.0, 3.0, 0.0), Color(1.0, 0.8, 0.55), 1.0)
	_add_lamp(Vector3(38.0, 3.0, 0.0), Color(0.5, 1.0, 0.8), 1.0)

func _add_lamp(pos: Vector3, color: Color, energy: float) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = 10.0
	add_child(l)
	return l

func _grid_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = "shader_type spatial;\nvarying vec3 wpos;\nvoid vertex() {\n\twpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;\n}\nvoid fragment() {\n\tvec2 g = abs(fract(wpos.xz - 0.5) - 0.5) / max(fwidth(wpos.xz), vec2(0.0001));\n\tfloat line = 1.0 - clamp(min(g.x, g.y), 0.0, 1.0);\n\tvec3 base = vec3(0.13, 0.16, 0.18);\n\tALBEDO = mix(base, vec3(0.28, 0.36, 0.40), line * 0.9);\n\tROUGHNESS = 0.75;\n}\n"
	var sm := ShaderMaterial.new()
	sm.shader = shader
	return sm

func _build_shell() -> void:
	var floor_body := StaticBody3D.new()
	floor_body.position = Vector3(END_X * 0.5, -0.25, 0.0)
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(END_X, 0.5, 12.0)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	var floor_mesh := MeshInstance3D.new()
	var floor_res := BoxMesh.new()
	floor_res.size = Vector3(END_X, 0.5, 12.0)
	floor_mesh.mesh = floor_res
	floor_mesh.material_override = _grid_material()
	floor_body.add_child(floor_mesh)
	add_child(floor_body)

	var wall := Color(0.22, 0.26, 0.3)
	B.solid_box(self, Vector3(END_X + 0.5, 3.2, 0.5), Vector3(END_X * 0.5, 1.6, -6.25), wall)
	B.solid_box(self, Vector3(END_X + 0.5, 0.9, 0.5), Vector3(END_X * 0.5, 0.45, 6.25), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 12.5), Vector3(-0.25, 1.6, 0.0), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 12.5), Vector3(END_X + 0.25, 1.6, 0.0), wall)
	for dx in [DIVIDER_1, DIVIDER_2]:
		B.solid_box(self, Vector3(0.6, 3.2, 4.6), Vector3(dx, 1.6, -3.7), wall)
		B.solid_box(self, Vector3(0.6, 3.2, 4.6), Vector3(dx, 1.6, 3.7), wall)

func _build_doors_and_checkpoints() -> void:
	var names := ["Puerta del laboratorio", "Compuerta del brazo"]
	var xs := [DIVIDER_1, DIVIDER_2]
	var messages := [
		"La puerta está bloqueada. El circuito no tiene energía.",
		"La compuerta no se abre: el brazo no está en la posición segura.",
	]
	for i in 2:
		var d = DoorScript.new()
		d.display_name = names[i]
		d.save_id = "door%d" % i
		d.position = Vector3(xs[i], 0.0, 0.0)
		d.interaction_range = 3.0
		d.locked_message = messages[i]
		add_child(d)
		doors.append(d)
		var cp = CheckpointScript.new()
		cp.checkpoint_id = "lab_cp%d" % i
		cp.save_id = "cp%d" % i
		cp.position = Vector3(xs[i] + 2.0, 0.0, 0.0)
		cp.reached.connect(_on_checkpoint.bind(i))
		add_child(cp)

func _build_room1() -> void:
	B.solid_box(self, Vector3(0.6, 2.0, 5.0), Vector3(8.5, 1.0, 1.5), Color(0.3, 0.27, 0.23))
	var coords := [Vector3(3.5, 0.0, -2.0), Vector3(6.5, 0.0, 3.8), Vector3(11.0, 0.0, -3.6)]
	for i in 3:
		var n = NodeScript.new()
		n.index = i + 1
		n.display_name = "Nodo %d" % (i + 1)
		n.save_id = "r1_n%d" % (i + 1)
		n.position = coords[i]
		add_child(n)
		if i == 0:
			n.set_connected(true)
		n.interacted.connect(_on_node_used.bind(n))
		r1_nodes.append(n)
	r1_junction = JunctionScript.new()
	r1_junction.display_name = "Caja de unión"
	r1_junction.save_id = "r1_j"
	r1_junction.position = Vector3(13.0, 0.0, 3.0)
	add_child(r1_junction)
	var t1 = TerminalScript.new()
	t1.display_name = "Terminal de energía"
	t1.prompt_text = "Verificar circuito"
	t1.save_id = "r1_t"
	t1.position = Vector3(14.0, 0.0, -3.6)
	t1.activated.connect(_on_r1_terminal)
	add_child(t1)
	_add_fragment("lab_f1", Vector3(4.0, 0.0, -5.0), "Fragmento de memoria: Iris me pidió que me quedara una noche más. Yo tenía una reunión.")

func _build_room2() -> void:
	var wall := Color(0.22, 0.26, 0.3)
	B.solid_box(self, Vector3(0.6, 3.2, 4.0), Vector3(25.0, 1.6, -4.0), wall)
	B.solid_box(self, Vector3(0.6, 3.2, 4.0), Vector3(25.0, 1.6, 4.0), wall)
	arm = ArmScript.new()
	arm.save_id = "r2_arm"
	arm.position = Vector3(25.0, 0.0, 0.0)
	arm.settled.connect(_on_arm_settled)
	add_child(arm)
	var t2 = TerminalScript.new()
	t2.display_name = "Control del brazo"
	t2.prompt_text = "Girar brazo"
	t2.save_id = "r2_t"
	t2.position = Vector3(21.0, 0.0, -4.0)
	t2.activated.connect(_on_arm_terminal)
	add_child(t2)
	var frag = _add_fragment("lab_f2", Vector3(22.5, 0.0, 0.0), "Fragmento de memoria: el laboratorio olía a café frío el día que Selene me enseñó a calibrar el Aster.")
	frag.blocked_check = Callable(self, "_fragment_blocked")

func _add_fragment(id: String, pos: Vector3, text: String) -> Node3D:
	var f = FragmentScript.new()
	f.fragment_id = id
	f.save_id = id
	f.memory_text = text
	f.position = pos
	add_child(f)
	return f

func _fragment_blocked() -> bool:
	return arm.is_moving or arm.index == 3

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
	cam.limit_min = Vector2(8.0, -1.5)
	cam.limit_max = Vector2(END_X - 8.0, 1.5)
	add_child(cam)

func _build_ui() -> void:
	hud = HudScript.new()
	add_child(hud)
	panel = PanelScript.new()
	add_child(panel)

func _process(_delta: float) -> void:
	var t = manager.current_target
	var line := ""
	if t != null and is_instance_valid(t):
		line = str(t.call("get_prompt_line"))
	hud.call("set_prompt", line)
	_update_hud()
	if not finished and elena.global_position.x > END_X - 2.5:
		_finish_part()

func _update_hud() -> void:
	var room := 0
	if elena.global_position.x >= DIVIDER_1:
		room = 1
	hud.call("set_objective", "FASE 2 / LABORATORIO ABANDONADO  -  Sala %d de 4" % (room + 1))
	hud.call("set_status", "Fragmentos de memoria: %d/4" % GameManager.memory_fragments_collected.size())
	if room == 0:
		var parts: Array = []
		for n in r1_nodes:
			parts.append("Nodo %d %s" % [n.index, ("[OK]" if n.connected else "[ ]")])
		var junction_ok: bool = r1_junction.pairing == r1_junction.correct_pairing
		parts.append("Unión (Entrada A -> Salida 2) %s" % ("[OK]" if junction_ok else "[ ]"))
		parts.append("Puerta %s" % ("[ABIERTA]" if r1_done else "[BLOQUEADA]"))
		hud.call("set_hint", "Diagrama: " + " -> ".join(parts) + "\nConecta los nodos en orden, ajusta la unión y verifica el circuito en el terminal.")
	else:
		var moving := ""
		if arm.is_moving:
			moving = " (en movimiento)"
		hud.call("set_hint", "Terminal: cada pulsación gira el brazo 90° (2 s). Solo el ángulo seguro desbloquea la compuerta.\nPosición actual: %d°%s" % [arm.index * 90, moving])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file(MENU_PATH)
		return
	if finished:
		if event.is_action_pressed("interact") and not event.is_echo():
			get_tree().change_scene_to_file(MENU_PATH)
		return
	if event.is_action_pressed("quick_save") and not event.is_echo():
		_save_room()
		panel.call("show_message", "Partida guardada.", 3.0)
	elif event.is_action_pressed("quick_load") and not event.is_echo():
		_load_room()

func _on_node_used(_actor, node) -> void:
	if r1_done:
		return
	if node.connected:
		panel.call("show_message", "Este nodo ya está conectado.", 3.0)
		return
	var prev = r1_nodes[node.index - 2]
	if prev.connected:
		node.set_connected(true)
		panel.call("show_message", "Nodo %d conectado." % node.index, 3.0)
	else:
		node.flash_error()
		panel.call("show_message", "Conecta primero el nodo anterior.", 3.0)

func _on_r1_terminal(_actor) -> void:
	if r1_done:
		panel.call("show_message", "El circuito ya está activo.", 3.0)
		return
	for n in r1_nodes:
		if not n.connected:
			panel.call("show_message", "El circuito está incompleto. Conecta los tres nodos.", 4.0)
			return
	if r1_junction.pairing != r1_junction.correct_pairing:
		r1_junction.spark_reset()
		panel.call("show_message", "Emparejamiento incorrecto. Saltan chispas y la unión se reinicia.", 4.0)
		return
	_set_power(true, true)
	panel.call("show_message", "Circuito verificado. Las luces vuelven.", 4.0)

func _set_power(on: bool, animate: bool) -> void:
	r1_done = on
	doors[0].set_locked(not on)
	var target := 1.3 if on else 0.0
	for l in r1_lamps:
		if animate:
			create_tween().tween_property(l, "light_energy", target, 1.0)
		else:
			l.light_energy = target

func _on_arm_terminal(_actor) -> void:
	if arm.is_moving:
		panel.call("show_message", "El brazo todavía se está moviendo.", 2.5)
		return
	arm.rotate_next()

func _on_arm_settled(index: int) -> void:
	_refresh_arm_door()
	if index == 3 and not arm_latched:
		arm_latched = true
		panel.call("show_message", "Posición segura alcanzada. La compuerta se desbloquea.", 4.0)

func _refresh_arm_door() -> void:
	if doors[1].is_open:
		return
	doors[1].set_locked(not (arm.index == 3 and not arm.is_moving))

func _on_checkpoint(cp, i: int) -> void:
	GameManager.current_checkpoint_id = "lab_cp%d" % i
	respawn = Vector3(cp.global_position.x + 0.5, 0.1, 0.0)
	if i == 0:
		panel.call("show_message", DONE[0] + " " + ENTRY[1], 11.0)
	else:
		panel.call("show_message", DONE[1], 8.0)
	_save_room()

func _on_fell() -> void:
	elena.global_position = respawn

func _finish_part() -> void:
	finished = true
	elena.input_enabled = false
	manager.active = false
	GameManager.current_phase = maxi(GameManager.current_phase, 2)
	_save_room()
	var layer := CanvasLayer.new()
	layer.layer = 30
	add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.72)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bg)
	var lbl := Label.new()
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.text = "FASE 2 - PARTE A COMPLETADA\n\nSalas 1 y 2 superadas.\nFragmentos de memoria: %d/4\nLas salas 3 y 4 todavía no están implementadas.\n\nE: volver al menú" % GameManager.memory_fragments_collected.size()
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(lbl)

func _saveables() -> Array:
	var out: Array = []
	for n in get_tree().get_nodes_in_group("interactables"):
		out.append(n)
	for n in get_tree().get_nodes_in_group("saveables"):
		out.append(n)
	return out

func _save_room() -> void:
	var data := {}
	data["player"] = [elena.global_position.x, elena.global_position.y, elena.global_position.z]
	for n in _saveables():
		var sid := str(n.get("save_id"))
		if sid != "" and sid != "<null>":
			data[sid] = n.call("get_state")
	data["_level"] = {
		"r1_done": r1_done,
		"arm_latched": arm_latched,
		"respawn": [respawn.x, respawn.y, respawn.z],
	}
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
	for n in _saveables():
		var sid := str(n.get("save_id"))
		if sid != "" and data.has(sid):
			n.call("apply_state", data[sid])
	var lv = data.get("_level", {})
	if typeof(lv) == TYPE_DICTIONARY:
		_set_power(bool(lv.get("r1_done", false)), false)
		arm_latched = bool(lv.get("arm_latched", false))
		var r = lv.get("respawn", null)
		if r is Array and r.size() == 3:
			respawn = Vector3(float(r[0]), float(r[1]), float(r[2]))
	_refresh_arm_door()
	var p = data.get("player", null)
	if p is Array and p.size() == 3:
		elena.global_position = Vector3(float(p[0]), float(p[1]), float(p[2]))
		elena.velocity = Vector3.ZERO
	panel.call("show_message", "Partida cargada.", 3.0)
