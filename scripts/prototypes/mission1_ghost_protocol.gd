extends Node3D
## Prototipo de la Fase 1: El protocolo fantasma.
## Puzle de investigacion: deducir que el circuito B fue desviado, reconectarlo y restaurar energia.
## Escena aislada; no modifica el laboratorio, el arte final ni los contratos de Fase 0.
## Reutiliza el controlador de Elena (modelo MPFB + capa de pose si estan disponibles).
## Ejecutar: godot --path . res://scenes/prototypes/mission1_ghost_protocol.tscn
## Controles: WASD mover, Espacio saltar, E interactuar, Q mantener para escanear, Esc menu.

const B = preload("res://scripts/components/build_util.gd")
const ElenaScript = preload("res://scripts/characters/elena_controller.gd")
const CameraScript = preload("res://scripts/components/follow_camera.gd")
const ScanSfx = preload("res://scripts/audio/sfx_synth.gd")

const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const ROOM_ID := "mission1_ghost_protocol"

const FLOOR_COLOR := Color(0.11, 0.13, 0.16)
const WALL_COLOR := Color(0.16, 0.19, 0.23)
const CYAN := Color(0.3, 0.95, 0.9)
const AMBER := Color(0.95, 0.65, 0.2)
const DANGER := Color(0.95, 0.2, 0.15)
const SAFE_GREEN := Color(0.45, 0.9, 0.5)

const INTERACT_RANGE := 2.6
const SCAN_CHARGE_TIME := 0.9
const SCAN_REVEAL_TIME := 3.0
const SCAN_COOLDOWN := 4.0

const SPAWN := Vector3(2.0, 0.2, 3.0)
const PANEL_POS := Vector3(6.0, 1.6, -6.0)
const CABLE_CUT_POS := Vector3(10.0, 0.3, -2.0)
const JUNCTION_POS := Vector3(12.0, 0.0, 1.0)
const TERMINAL_POS := Vector3(16.0, 0.0, -4.0)
const LEVER_POS := Vector3(20.0, 0.0, 2.0)
const DOOR_POS := Vector3(23.0, 0.0, 0.0)

var elena: CharacterBody3D
var camera: Camera3D
var hud: Label
var prompt: Label
var message: Label
var scan_charge: float = 0.0
var scan_reveal_left: float = 0.0
var scan_cooldown_left: float = 0.0
var scan_markers: Array = []
var cable_path_markers: Array = []
var panel_marker: MeshInstance3D
var terminal_marker: MeshInstance3D
var door_mesh: MeshInstance3D
var door_light: OmniLight3D
var terminal_screen: MeshInstance3D
var junction_cable: MeshInstance3D
var sfx_player: AudioStreamPlayer
var scan_stream: AudioStream
var denied_stream: AudioStream
var power_up_stream: AudioStream
var chime_stream: AudioStream
var terminal_stream: AudioStream

var b_diverted: bool = true
var power_on: bool = false
var record_read: bool = false
var evidence_found: bool = false
var door_open: bool = false
var finished: bool = false
var elapsed: float = 0.0
var wrong_attempts: int = 0
var message_left: float = 0.0
var current_hotspot: String = ""


class Hotspot:
	var id: String
	var pos: Vector3
	var label: String
	func _init(p_id: String, p_pos: Vector3, p_label: String) -> void:
		id = p_id
		pos = p_pos
		label = p_label

var hotspots: Array = []


func _ready() -> void:
	_ensure_action("scan", KEY_TAB)
	_build_room()
	_build_player()
	_build_scan_markers()
	_build_audio()
	_build_ui()
	_build_hotspots()
	_show_message("La energía está cortada. Encuentra qué se ha manipulado y restaura el sistema.", 7.0)


func _build_hotspots() -> void:
	hotspots = [
		Hotspot.new("junction", JUNCTION_POS, "Caja de unión"),
		Hotspot.new("terminal", TERMINAL_POS, "Terminal de registro"),
		Hotspot.new("lever", LEVER_POS, "Palanca del generador"),
		Hotspot.new("door", DOOR_POS, "Compuerta de salida"),
	]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file(MENU_PATH)


func _physics_process(delta: float) -> void:
	if not finished:
		elapsed += delta
	_update_hotspot()
	_update_scan(delta)
	_update_hud(delta)
	if not finished and elena.global_position.x >= DOOR_POS.x - 0.5 and door_open():
		_finish()


func _update_hotspot() -> void:
	current_hotspot = ""
	var best_range := INTERACT_RANGE
	for hotspot in hotspots:
		var distance: float = elena.global_position.distance_to(hotspot.pos)
		if distance < best_range:
			best_range = distance
			current_hotspot = hotspot.id
			prompt.text = "E: " + hotspot.label
	if current_hotspot == "":
		prompt.text = ""
	if current_hotspot != "" and Input.is_action_just_pressed("interact"):
		_use_hotspot(current_hotspot)


func _use_hotspot(id: String) -> void:
	match id:
		"junction":
			_use_junction()
		"terminal":
			_use_terminal()
		"lever":
			_use_lever()
		"door":
			_use_door()


func _use_junction() -> void:
	if not b_diverted:
		_show_message("El circuito B ya vuelve a su panel.", 3.0)
		return
	b_diverted = false
	_play_sfx(terminal_stream, -6.0)
	junction_cable.material_override = _emissive_material(CYAN, 1.2)
	if power_on:
		_apply_power()
	_show_message("El cable B vuelve a su panel. El circuito sigue apagado.", 4.0)


func _use_terminal() -> void:
	if b_diverted:
		_show_message("El terminal recibe alimentación de un cable desviado. El registro está incompleto.", 5.0)
		return
	if not power_on:
		_show_message("El terminal no tiene energía.", 3.0)
		return
	record_read = true
	evidence_found = true
	_play_sfx(terminal_stream, -6.0)
	terminal_screen.material_override = _emissive_material(CYAN, 2.0)
	_show_message("Registro completo: prueba del Aster desviada. Resultado retenido. Recomendación de despliegue suprimida.", 7.0)


func _use_lever() -> void:
	if power_on:
		_show_message("El generador ya está activo.", 3.0)
		return
	power_on = true
	_play_sfx(power_up_stream, -6.0)
	_apply_power()
	if b_diverted:
		wrong_attempts += 1
		_show_message("Las luces se encienden, pero la compuerta sigue bloqueada: el circuito B es inconsistente.", 6.0)
	else:
		_show_message("Energía restaurada. La compuerta se desbloquea.", 5.0)


func _apply_power() -> void:
	door_light.light_color = SAFE_GREEN
	door_light.light_energy = 1.5
	door_mesh.material_override = _emissive_material(SAFE_GREEN, 1.5)


func door_open() -> bool:
	return power_on and not b_diverted


func _use_door() -> void:
	if door_open():
		return
	_play_sfx(denied_stream, -6.0)
	if b_diverted:
		_show_message("La compuerta está bloqueada: el circuito B no llega a la puerta.", 4.0)
	else:
		_show_message("La compuerta está bloqueada: no hay energía.", 4.0)


func _finish() -> void:
	finished = true
	_play_sfx(chime_stream, -4.0)
	_show_message("EVIDENCIA RECUPERADA\nLa prueba del Aster fue desviada y su resultado oculto.\nLa activación del sistema ha despertado la contención de Helix.\n\nTiempo: %s   |   Intentos fallidos: %d\nEsc para volver al menú." % [_format_time(elapsed), wrong_attempts], 600.0)


func _format_time(seconds: float) -> String:
	return "%d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]


# --- Escaner ------------------------------------------------------------------------------------------

func _update_scan(delta: float) -> void:
	scan_cooldown_left = maxf(0.0, scan_cooldown_left - delta)
	if scan_reveal_left > 0.0:
		scan_reveal_left -= delta
		if scan_reveal_left <= 0.0:
			for marker in scan_markers:
				marker.visible = false
		return
	if Input.is_action_pressed("scan") and scan_cooldown_left <= 0.0 and not finished:
		scan_charge += delta
		if scan_charge >= SCAN_CHARGE_TIME:
			scan_charge = 0.0
			scan_reveal_left = SCAN_REVEAL_TIME
			scan_cooldown_left = SCAN_COOLDOWN
			_play_sfx(scan_stream, -4.0)
			for marker in scan_markers:
				marker.visible = true
	else:
		scan_charge = 0.0


# --- Construccion --------------------------------------------------------------------------------------

func _build_room() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.36, 0.44)
	env.ambient_light_energy = 0.4
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	sun.light_energy = 0.5
	sun.light_color = Color(0.75, 0.85, 1.0)
	sun.shadow_enabled = true
	add_child(sun)

	B.solid_box(self, Vector3(26.0, 0.5, 16.0), Vector3(12.0, -0.25, 0.0), FLOOR_COLOR)
	B.solid_box(self, Vector3(26.0, 4.0, 0.6), Vector3(12.0, 2.0, -8.3), WALL_COLOR)
	B.solid_box(self, Vector3(26.0, 0.9, 0.6), Vector3(12.0, 0.45, 8.3), WALL_COLOR)
	B.solid_box(self, Vector3(0.6, 4.0, 16.0), Vector3(-1.3, 2.0, 0.0), WALL_COLOR)
	B.solid_box(self, Vector3(0.6, 4.0, 16.0), Vector3(25.3, 2.0, 0.0), WALL_COLOR)

	_add_sign("CIRCUITO A: LUCES", Vector3(4.0, 2.2, -6.0))
	_add_sign("CIRCUITO B: COMPUERTA", Vector3(6.0, 2.2, -6.0))
	_add_sign("CIRCUITO C: REGISTRO", Vector3(8.0, 2.2, -6.0))
	_add_sign("Mantén Q para escanear", Vector3(3.0, 3.2, 0.0))
	_add_sign("SALIDA", Vector3(23.0, 3.2, 0.0))

	var panel := MeshInstance3D.new()
	var panel_box := BoxMesh.new()
	panel_box.size = Vector3(6.0, 2.4, 0.3)
	panel.mesh = panel_box
	panel.position = PANEL_POS
	panel.material_override = _plain_material(WALL_COLOR)
	add_child(panel)
	panel_marker = _make_marker(PANEL_POS + Vector3(0.0, 0.4, 0.6), CYAN, 0.2)

	junction_cable = MeshInstance3D.new()
	var cable_box := BoxMesh.new()
	cable_box.size = Vector3(3.0, 0.15, 0.15)
	junction_cable.mesh = cable_box
	junction_cable.position = Vector3(13.5, 0.3, -1.5)
	junction_cable.material_override = _emissive_material(AMBER, 0.8)
	add_child(junction_cable)

	terminal_screen = MeshInstance3D.new()
	var screen_box := BoxMesh.new()
	screen_box.size = Vector3(0.9, 0.6, 0.1)
	terminal_screen.mesh = screen_box
	terminal_screen.position = TERMINAL_POS + Vector3(0.0, 1.2, -0.3)
	terminal_screen.material_override = _emissive_material(DANGER, 1.0)
	add_child(terminal_screen)
	terminal_marker = _make_marker(TERMINAL_POS + Vector3(0.0, 1.6, 0.0), CYAN, 0.2)

	door_mesh = MeshInstance3D.new()
	var door_box := BoxMesh.new()
	door_box.size = Vector3(0.3, 3.0, 4.0)
	door_mesh.mesh = door_box
	door_mesh.position = DOOR_POS + Vector3(0.0, 1.5, 0.0)
	door_mesh.material_override = _plain_material(Color(0.3, 0.35, 0.4))
	add_child(door_mesh)
	door_light = OmniLight3D.new()
	door_light.position = DOOR_POS + Vector3(-0.8, 2.2, 0.0)
	door_light.light_color = DANGER
	door_light.light_energy = 0.8
	door_light.omni_range = 4.0
	add_child(door_light)

	for x in [5.0, 12.0, 19.0]:
		var lamp := OmniLight3D.new()
		lamp.position = Vector3(x, 3.4, 0.0)
		lamp.light_color = Color(1.0, 0.85, 0.6)
		lamp.light_energy = 0.0
		lamp.omni_range = 12.0
		add_child(lamp)


func _add_sign(text: String, pos: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 40
	label.pixel_size = 0.008
	label.outline_size = 10
	label.modulate = Color(0.85, 0.92, 1.0)
	add_child(label)


func _build_player() -> void:
	elena = ElenaScript.new()
	elena.position = SPAWN
	add_child(elena)
	camera = CameraScript.new()
	camera.target = elena
	camera.limit_min = Vector2(2.0, -6.0)
	camera.limit_max = Vector2(22.0, 6.0)
	add_child(camera)


func _build_scan_markers() -> void:
	panel_marker = _make_marker(PANEL_POS + Vector3(0.0, 0.4, 0.6), CYAN, 0.2)
	terminal_marker = _make_marker(TERMINAL_POS + Vector3(0.0, 1.6, 0.0), CYAN, 0.2)
	scan_markers.append(panel_marker)
	scan_markers.append(terminal_marker)
	for i in 5:
		var t: float = float(i) / 4.0
		var pos: Vector3 = Vector3(lerpf(CABLE_CUT_POS.x, TERMINAL_POS.x, t), 0.35, lerpf(CABLE_CUT_POS.z, TERMINAL_POS.z, t))
		var marker := _make_marker(pos, AMBER, 0.12)
		cable_path_markers.append(marker)
		scan_markers.append(marker)


func _make_marker(pos: Vector3, color: Color, radius: float) -> MeshInstance3D:
	var marker := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	marker.mesh = sphere
	marker.position = pos
	marker.visible = false
	marker.material_override = _emissive_material(color, 2.0)
	add_child(marker)
	return marker


func _build_audio() -> void:
	scan_stream = ScanSfx.scan_pulse()
	denied_stream = SfxSynth.denied()
	power_up_stream = SfxSynth.power_up()
	chime_stream = SfxSynth.complete_chime()
	terminal_stream = SfxSynth.terminal_beep()
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)


func _play_sfx(stream: AudioStream, volume_db: float) -> void:
	if stream == null:
		return
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	hud = Label.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE, 16)
	hud.grow_vertical = Control.GROW_DIRECTION_BEGIN
	hud.add_theme_font_size_override("font_size", 15)
	layer.add_child(hud)
	message = Label.new()
	message.custom_minimum_size = Vector2(900.0, 0.0)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, 40)
	message.add_theme_font_size_override("font_size", 22)
	layer.add_child(message)
	prompt = Label.new()
	prompt.custom_minimum_size = Vector2(300.0, 0.0)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE, 110)
	prompt.add_theme_font_size_override("font_size", 24)
	prompt.add_theme_color_override("font_color", AMBER)
	layer.add_child(prompt)


func _plain_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	return material


func _emissive_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _show_message(text: String, seconds: float) -> void:
	message.text = text
	message_left = seconds


func _update_hud(delta: float) -> void:
	if message_left > 0.0:
		message_left -= delta
		if message_left <= 0.0:
			message.text = ""
	var scan_line := "listo"
	if scan_reveal_left > 0.0:
		scan_line = "activo %.1f s" % scan_reveal_left
	elif scan_charge > 0.0:
		scan_line = "escaneando %d%%" % int(scan_charge / SCAN_CHARGE_TIME * 100.0)
	elif scan_cooldown_left > 0.0:
		scan_line = "recarga %.1f s" % scan_cooldown_left
	hud.text = "WASD mover · Espacio saltar · E interactuar · Q escáner\nEscáner: %s   |   Energía: %s   |   Circuito B: %s" % [scan_line, "activado" if power_on else "apagado", "desviado" if b_diverted else "conectado"]
