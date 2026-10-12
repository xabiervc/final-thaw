extends Node3D

const B = preload("res://scripts/components/build_util.gd")
const ElenaScript = preload("res://scripts/characters/elena_controller.gd")
const TerminalScript = preload("res://scripts/components/powered_terminal.gd")
const NodeScript = preload("res://scripts/components/connection_node.gd")
const JunctionScript = preload("res://scripts/components/junction_box.gd")
const ArmScript = preload("res://scripts/components/robotic_arm.gd")
const PlatformScript = preload("res://scripts/components/moving_platform.gd")
const ButtonScript = preload("res://scripts/components/push_button.gd")
const HazardScript = preload("res://scripts/components/hazard_zone.gd")
const CarrierScript = preload("res://scripts/components/prototype_carrier.gd")
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
const DIVIDER_3 := 60.0
const END_X := 86.0
const LOAD_SAFE_X := 81.5

const ENTRY = [
	"Los sistemas están apagados. Tengo que devolver la energía.",
	"Un brazo robótico bloquea el paso. El terminal lo controla.",
	"La plataforma sigue un ciclo de diez segundos. Hay que observar el patrón.",
	"Mantén el prototipo con energía. Evita los peligros.",
]
const DONE = [
	"Energía restaurada. La instalación me recuerda.",
	"Brazo fijado. Solo un ángulo es seguro.",
	"Al otro lado. El laboratorio sigue vivo bajo el polvo.",
]

var elena = null
var manager = null
var scanner = null
var hud = null
var panel = null
var grid_material = null
var overlay_layer = null
var doors: Array = []
var hazards: Array = []
var r1_nodes: Array = []
var r1_junction = null
var r1_lamps: Array = []
var r1_done: bool = false
var arm = null
var arm_latched: bool = false
var p1 = null
var p2 = null
var falls: int = 0
var bridge_up: bool = false
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
	_build_room3()
	_build_room4()
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
	_add_lamp(Vector3(38.0, 3.0, 0.0), Color(0.7, 0.85, 1.0), 1.0)
	_add_lamp(Vector3(47.0, 3.0, 0.0), Color(1.0, 0.85, 0.6), 1.0)
	_add_lamp(Vector3(56.0, 3.0, 0.0), Color(0.7, 0.85, 1.0), 1.0)
	_add_lamp(Vector3(64.0, 3.0, 0.0), Color(0.5, 1.0, 0.8), 1.0)
	_add_lamp(Vector3(72.0, 3.0, 0.0), Color(0.6, 0.8, 1.0), 1.0)
	_add_lamp(Vector3(80.0, 3.0, 0.0), Color(1.0, 0.8, 0.6), 1.0)

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

func _add_floor(x0: float, x1: float) -> void:
	var w := x1 - x0
	var body := StaticBody3D.new()
	body.position = Vector3((x0 + x1) * 0.5, -0.25, 0.0)
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(w, 0.5, 12.0)
	shape.shape = box
	body.add_child(shape)
	var mesh_node := MeshInstance3D.new()
	var res := BoxMesh.new()
	res.size = Vector3(w, 0.5, 12.0)
	mesh_node.mesh = res
	mesh_node.material_override = grid_material
	body.add_child(mesh_node)
	add_child(body)

func _build_shell() -> void:
	grid_material = _grid_material()
	_add_floor(0.0, 40.0)
	_add_floor(46.0, 52.0)
	_add_floor(58.0, END_X)

	var wall := Color(0.22, 0.26, 0.3)
	B.solid_box(self, Vector3(END_X + 0.5, 3.2, 0.5), Vector3(END_X * 0.5, 1.6, -6.25), wall)
	B.solid_box(self, Vector3(END_X + 0.5, 0.9, 0.5), Vector3(END_X * 0.5, 0.45, 6.25), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 12.5), Vector3(-0.25, 1.6, 0.0), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 12.5), Vector3(END_X + 0.25, 1.6, 0.0), wall)
	for dx in [DIVIDER_1, DIVIDER_2, DIVIDER_3]:
		B.solid_box(self, Vector3(0.6, 3.2, 4.6), Vector3(dx, 1.6, -3.7), wall)
		B.solid_box(self, Vector3(0.6, 3.2, 4.6), Vector3(dx, 1.6, 3.7), wall)

func _build_doors_and_checkpoints() -> void:
	var names := ["Puerta del laboratorio", "Compuerta del brazo", "Puerta de las plataformas"]
	var xs := [DIVIDER_1, DIVIDER_2, DIVIDER_3]
	var messages := [
		"La puerta está bloqueada. El circuito no tiene energía.",
		"La compuerta no se abre: el brazo no está en la posición segura.",
		"La puerta está bloqueada.",
	]
	for i in 3:
		var d = DoorScript.new()
		d.display_name = names[i]
		d.save_id = "door%d" % i
		d.position = Vector3(xs[i], 0.0, 0.0)
		d.interaction_range = 3.0
		d.locked = i < 2
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

func _build_room3() -> void:
	var rail := Color(0.28, 0.3, 0.34)
	for gx in [43.0, 55.0]:
		B.solid_box(self, Vector3(6.0, 1.0, 3.5), Vector3(gx, 0.5, 4.25), rail)
		B.solid_box(self, Vector3(6.0, 1.0, 3.5), Vector3(gx, 0.5, -4.25), rail)

	p1 = PlatformScript.new()
	p1.save_id = "r3_p1"
	p1.end_a = Vector3(41.5, -0.2, 0.0)
	p1.end_b = Vector3(44.5, -0.2, 0.0)
	p1.plat_size = Vector3(3.0, 0.4, 5.0)
	p1.auto_cycle = true
	p1.powered = false
	add_child(p1)

	p2 = PlatformScript.new()
	p2.save_id = "r3_p2"
	p2.end_a = Vector3(53.5, -0.2, 0.0)
	p2.end_b = Vector3(56.5, -0.2, 0.0)
	p2.plat_size = Vector3(3.0, 0.4, 5.0)
	p2.auto_cycle = false
	p2.powered = true
	p2.initial_idx = 1
	add_child(p2)

	_add_button("Plataforma 1", "Llamar", Vector3(38.5, 0.0, 1.5), self).pressed.connect(_call_platform.bind(p1, 0))
	_add_button("Plataforma 1", "Llamar", Vector3(47.5, 0.0, 1.5), self).pressed.connect(_call_platform.bind(p1, 1))
	_add_button("Plataforma 1", "Parada de emergencia", Vector3(38.5, 0.0, -1.5), self).pressed.connect(_toggle_pause.bind(p1))
	_add_button("Plataforma 1", "Parada de emergencia", Vector3(47.5, 0.0, -1.5), self).pressed.connect(_toggle_pause.bind(p1))
	_add_button("Plataforma 1", "Enviar", Vector3(0.0, 0.2, 0.0), p1).pressed.connect(_send_platform.bind(p1))

	_add_button("Plataforma 2", "Llamar", Vector3(50.5, 0.0, 1.5), self).pressed.connect(_call_platform.bind(p2, 0))
	_add_button("Plataforma 2", "Llamar", Vector3(59.0, 0.0, 1.5), self).pressed.connect(_call_platform.bind(p2, 1))
	_add_button("Plataforma 2", "Parada de emergencia", Vector3(50.5, 0.0, -1.5), self).pressed.connect(_toggle_pause.bind(p2))
	_add_button("Plataforma 2", "Parada de emergencia", Vector3(59.0, 0.0, -1.5), self).pressed.connect(_toggle_pause.bind(p2))
	_add_button("Plataforma 2", "Enviar", Vector3(0.0, 0.2, 0.0), p2).pressed.connect(_send_platform.bind(p2))

	_add_fragment("lab_f3", Vector3(49.0, 0.0, 0.0), "Fragmento de memoria: las cifras de refugiados subían cada semana. Dejé de leerlas.")

func _build_room4() -> void:
	var specs := [
		{"id": "r4_h1", "pos": Vector3(66.0, 0.0, 2.0), "size": Vector2(3.0, 3.0), "fake": false, "phase": 0.0},
		{"id": "r4_h2", "pos": Vector3(71.0, 0.0, -2.0), "size": Vector2(3.0, 8.0), "fake": false, "phase": 2.0},
		{"id": "r4_h3", "pos": Vector3(76.0, 0.0, 2.0), "size": Vector2(3.0, 8.0), "fake": false, "phase": 4.0},
		{"id": "r4_h4", "pos": Vector3(81.0, 0.0, 0.0), "size": Vector2(3.0, 6.0), "fake": true, "phase": 0.0},
	]
	for s in specs:
		var h = HazardScript.new()
		h.save_id = s["id"]
		h.zone_size = s["size"]
		h.fake = s["fake"]
		h.phase_offset = s["phase"]
		h.position = s["pos"]
		h.damaged.connect(_on_hazard_damaged)
		add_child(h)
		hazards.append(h)
	_add_fragment("lab_f4", Vector3(73.5, 0.0, -5.0), "Fragmento de memoria: si Iris hubiera vivido, ¿habría querido este mundo? Tengo que decidirlo yo.")

func _add_button(label: String, prompt: String, pos: Vector3, parent: Node) -> Node3D:
	var b = ButtonScript.new()
	b.display_name = label
	b.prompt_text = prompt
	b.position = pos
	parent.add_child(b)
	return b

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
	var carrier = CarrierScript.new()
	elena.add_child(carrier)
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
	var ex: float = elena.global_position.x
	if elena.is_on_floor() and ex > 46.5 and ex < 51.5:
		respawn = Vector3(48.0, 0.1, 0.0)
	if not finished and ex > END_X - 2.5:
		_finish_part()

func _update_hud() -> void:
	var room := 0
	var ex: float = elena.global_position.x
	if ex >= DIVIDER_3:
		room = 3
	elif ex >= DIVIDER_2:
		room = 2
	elif ex >= DIVIDER_1:
		room = 1
	hud.call("set_objective", "FASE 2 / LABORATORIO ABANDONADO  -  Sala %d de 4" % (room + 1))
	var status := "Fragmentos de memoria: %d/4" % GameManager.memory_fragments_collected.size()
	if GameManager.has_prototype:
		status = "Prototipo: integridad %d/3   |   " % GameManager.prototype_integrity + status
	hud.call("set_status", status)
	if room == 0:
		var parts: Array = []
		for n in r1_nodes:
			parts.append("Nodo %d %s" % [n.index, ("[OK]" if n.connected else "[ ]")])
		var junction_ok: bool = r1_junction.pairing == r1_junction.correct_pairing
		parts.append("Unión (Entrada A -> Salida 2) %s" % ("[OK]" if junction_ok else "[ ]"))
		parts.append("Puerta %s" % ("[ABIERTA]" if r1_done else "[BLOQUEADA]"))
		hud.call("set_hint", "Diagrama: " + " -> ".join(parts) + "\nConecta los nodos en orden, ajusta la unión y verifica el circuito en el terminal.")
	elif room == 1:
		var moving := ""
		if arm.is_moving:
			moving = " (en movimiento)"
		hud.call("set_hint", "Terminal: cada pulsación gira el brazo 90° (2 s). Solo el ángulo seguro desbloquea la compuerta.\nPosición actual: %d°%s" % [arm.index * 90, moving])
	elif room == 2:
		hud.call("set_hint", "Plataforma 1: ciclo de 10 s (también se llama con el botón). Plataforma 2: llámala, súbete y pulsa Enviar.\nHay parada de emergencia en cada orilla. Caídas: %d/3 (a la tercera aparece una pasarela)." % falls)
	else:
		hud.call("set_hint", "Las zonas de peligro parpadean 1 s antes de activarse. Una zona parece peligrosa pero es estable.\nCada zona activa que cruces cuesta 1 de integridad (una vez por zona). Hay carriles seguros.")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file(MENU_PATH)
		return
	if event.is_action_pressed("quick_load") and not event.is_echo():
		_load_room()
		return
	if finished:
		if event.is_action_pressed("interact") and not event.is_echo():
			get_tree().change_scene_to_file(MENU_PATH)
		return
	if event.is_action_pressed("quick_save") and not event.is_echo():
		_save_room()
		panel.call("show_message", "Partida guardada.", 3.0)

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
		p1.set_powered(true)
		panel.call("show_message", "Posición segura alcanzada. La compuerta se desbloquea y, al fondo, se activa una plataforma.", 5.0)

func _refresh_arm_door() -> void:
	if doors[1].is_open:
		return
	doors[1].set_locked(not (arm.index == 3 and not arm.is_moving))

func _call_platform(p, target: int) -> void:
	if not p.powered:
		panel.call("show_message", "La plataforma no tiene energía. Fija el brazo de la sala 2 en la posición segura.", 4.0)
		return
	if p.paused:
		panel.call("show_message", "La parada de emergencia está activa. Pulsa el botón de nuevo para reanudar.", 4.0)
		return
	if p.moving:
		panel.call("show_message", "La plataforma ya se está moviendo.", 2.5)
		return
	if p.idx == target:
		panel.call("show_message", "La plataforma ya está en este extremo.", 2.5)
		return
	p.request_move(target)

func _send_platform(p) -> void:
	_call_platform(p, 1 - p.idx)

func _toggle_pause(p) -> void:
	if not p.powered:
		panel.call("show_message", "La plataforma no tiene energía.", 3.0)
		return
	p.toggle_pause()
	if p.paused:
		panel.call("show_message", "Parada de emergencia activada. La plataforma se detiene.", 3.0)
	else:
		panel.call("show_message", "Plataforma reanudada.", 3.0)

func _on_hazard_damaged(_hazard) -> void:
	GameManager.prototype_integrity = clampi(GameManager.prototype_integrity - 1, 0, 3)
	GameManager.stats_changed.emit()
	panel.call("show_message", "Peligro. El prototipo sufre daños. Integridad: %d/3." % GameManager.prototype_integrity, 4.0)

func _on_checkpoint(cp, i: int) -> void:
	GameManager.current_checkpoint_id = "lab_cp%d" % i
	respawn = Vector3(cp.global_position.x + 0.5, 0.1, 0.0)
	if i < 2:
		panel.call("show_message", DONE[i] + " " + ENTRY[i + 1], 11.0)
	else:
		GameManager.has_prototype = true
		for h in hazards:
			h.reset_hit()
		panel.call("show_message", DONE[2] + " Recibes el prototipo Aster. " + ENTRY[3], 12.0)
	_save_room()

func _on_fell() -> void:
	var ex: float = elena.global_position.x
	if ex >= DIVIDER_2 and ex < DIVIDER_3:
		falls += 1
		if falls >= 3 and not bridge_up:
			_deploy_bridge(true)
		else:
			panel.call("show_message", "Has caído al foso. No pasa nada: vuelves al último punto seguro. Caídas: %d/3." % falls, 4.0)
	elena.global_position = respawn
	elena.velocity = Vector3.ZERO

func _deploy_bridge(announce: bool) -> void:
	if bridge_up:
		return
	bridge_up = true
	var color := Color(0.5, 0.45, 0.2)
	B.solid_box(self, Vector3(6.0, 0.4, 1.0), Vector3(43.0, -0.18, 2.0), color)
	B.solid_box(self, Vector3(6.0, 0.4, 1.0), Vector3(55.0, -0.18, 2.0), color)
	if announce:
		panel.call("show_message", "Tras varias caídas, se despliega una pasarela de emergencia junto a la barandilla.", 6.0)

func _finish_part() -> void:
	finished = true
	elena.input_enabled = false
	manager.active = false
	GameManager.current_phase = maxi(GameManager.current_phase, 2)
	_save_room()
	var integrity: int = GameManager.prototype_integrity
	var verdict := "Prototipo dañado. Aún puede funcionar."
	if integrity == 3:
		verdict = "Prototipo estable. Calibración perfecta."
	overlay_layer = CanvasLayer.new()
	overlay_layer.layer = 30
	add_child(overlay_layer)
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.72)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_layer.add_child(bg)
	var lbl := Label.new()
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.text = "FASE 2 COMPLETADA\n\n%s\nIntegridad del prototipo: %d/3\nFragmentos de memoria: %d/4\nCaídas en los fosos: %d\n\nLa Fase 3 todavía no está disponible.\n\nE: volver al menú   |   F3: cargar partida" % [verdict, integrity, GameManager.memory_fragments_collected.size(), falls]
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_layer.add_child(lbl)

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
		"falls": falls,
		"bridge": bridge_up,
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
	finished = false
	if overlay_layer != null:
		overlay_layer.queue_free()
		overlay_layer = null
	elena.input_enabled = true
	manager.active = true
	for n in _saveables():
		var sid := str(n.get("save_id"))
		if sid != "" and data.has(sid):
			n.call("apply_state", data[sid])
	var lv = data.get("_level", {})
	if typeof(lv) == TYPE_DICTIONARY:
		_set_power(bool(lv.get("r1_done", false)), false)
		arm_latched = bool(lv.get("arm_latched", false))
		p1.set_powered(arm_latched)
		falls = int(lv.get("falls", 0))
		if bool(lv.get("bridge", false)):
			_deploy_bridge(false)
		var r = lv.get("respawn", null)
		if r is Array and r.size() == 3:
			respawn = Vector3(float(r[0]), float(r[1]), float(r[2]))
	_refresh_arm_door()
	var p = data.get("player", null)
	if p is Array and p.size() == 3:
		var px := minf(float(p[0]), LOAD_SAFE_X)
		elena.global_position = Vector3(px, float(p[1]), float(p[2]))
	elena.velocity = Vector3.ZERO
	panel.call("show_message", "Partida cargada.", 3.0)
