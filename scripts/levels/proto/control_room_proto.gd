extends Node3D
## Entrega B, paso 6: escena prototipo AISLADA del puzle de registros y cableado.
## Sala de control con geometria simple (sin arte): dos registros, tres cuadros, tres trazas
## de cableado y una compuerta. Une las reglas, las pistas, la telemetria y los componentes
## de los pasos anteriores; no decide nada por su cuenta.
##
## Ejecutar desde el editor con "Run Current Scene" sobre
## res://scenes/levels/proto/control_room_proto.tscn. No esta enlazada desde ningun menu y
## no modifica elena_test_room.gd ni abandoned_lab.gd.
##
## La solicitud manual de pista es un boton TEMPORAL de HUD que se usa con el raton (D10).
## Los avisos de la puerta ("Abrir puerta", "Puerta bloqueada") siguen inline en door.gd.

const B = preload("res://scripts/components/build_util.gd")
const ElenaScript = preload("res://scripts/characters/elena_controller.gd")
const DoorScript = preload("res://scripts/components/door.gd")
const ManagerScript = preload("res://scripts/components/interaction_manager.gd")
const ScanScript = preload("res://scripts/components/scan_system.gd")
const CameraScript = preload("res://scripts/components/follow_camera.gd")
const PanelScript = preload("res://scripts/ui/narrative_panel.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")
const LogScript = preload("res://scripts/components/log_terminal.gd")
const BreakerScript = preload("res://scripts/components/breaker_panel.gd")
const TraceScript = preload("res://scripts/components/conduit_trace.gd")
const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")
const HintsScript = preload("res://scripts/vertical_slice/control_room_hints.gd")
const TelemetryScript = preload("res://scripts/vertical_slice/control_room_telemetry.gd")

const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const VERSION := "proto-1"
const START := Vector3(-5.5, 0.1, 3.5)
const HINT_SECONDS := 14.0
const MODE_NAMES: Array[String] = ["off", "contextual", "full"]
## Interruptores de dificultad: todos apagados en esta prueba (no existen en este prototipo).
const FLAGS := {"drain_zones": false, "energy_timer": false, "decoy_lever": false, "lane_trap": false, "final_sprint": false}

@export_enum("Off", "Contextual", "Full solution") var hint_mode: int = 1
@export var telemetry_enabled: bool = false
@export var telemetry_dir: String = "user://telemetry"

var rules = null
var hints = null
var telemetry = null
var elena = null
var manager = null
var scanner = null
var hud = null
var panel = null
var door = null
var gate_lamp: MeshInstance3D = null
var logs: Dictionary = {}
var breakers: Dictionary = {}
var traces: Array = []

var _clock_t: float = 0.0
var _hint_clear_at: float = -1.0
var _hint_button: Button = null


func _ready() -> void:
	rules = RulesScript.new()
	hints = HintsScript.new()
	hints.mode = hint_mode
	hints.reset(0.0)
	telemetry = TelemetryScript.new()
	telemetry.enabled = telemetry_enabled
	telemetry.base_dir = telemetry_dir
	telemetry.start_session(MODE_NAMES[clampi(hint_mode, 0, 2)], FLAGS, VERSION)
	_build_environment()
	_build_room()
	_build_props()
	_build_player()
	_build_ui()


## Segundos desde que empezo la sala; es el reloj de reglas, pistas y telemetria.
func now() -> float:
	return _clock_t


func _clock() -> float:
	return _clock_t


func _text(key: String) -> String:
	return NarrativeTextManager.get_control_room_text(key)


func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.03, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.35, 0.42, 0.5)
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-60.0, -30.0, 0.0)
	sun.light_energy = 0.6
	sun.light_color = Color(0.75, 0.85, 1.0)
	sun.shadow_enabled = true
	add_child(sun)
	_add_lamp(Vector3(-3.0, 3.0, 0.0), Color(1.0, 0.85, 0.6), 1.0)
	_add_lamp(Vector3(4.0, 3.0, 0.0), Color(0.7, 0.85, 1.0), 1.0)


func _add_lamp(pos: Vector3, color: Color, energy: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = pos
	lamp.light_color = color
	lamp.light_energy = energy
	lamp.omni_range = 10.0
	add_child(lamp)


func _build_room() -> void:
	var wall := Color(0.22, 0.26, 0.3)
	B.solid_box(self, Vector3(20.0, 0.5, 13.0), Vector3(1.0, -0.25, 0.0), Color(0.16, 0.19, 0.21))
	B.solid_box(self, Vector3(20.5, 3.2, 0.5), Vector3(1.5, 1.6, -6.25), wall)
	B.solid_box(self, Vector3(20.5, 0.9, 0.5), Vector3(1.5, 0.45, 6.25), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 13.0), Vector3(-8.25, 1.6, 0.0), wall)
	B.solid_box(self, Vector3(0.5, 3.2, 13.0), Vector3(11.25, 1.6, 0.0), wall)
	B.solid_box(self, Vector3(0.6, 3.2, 4.6), Vector3(8.25, 1.6, -3.7), wall)
	B.solid_box(self, Vector3(0.6, 3.2, 4.6), Vector3(8.25, 1.6, 3.7), wall)


func _build_props() -> void:
	_make_log(RulesScript.LOG_BEFORE, "cr_log_before_title", "cr_log_before_body", Vector3(-6.8, 0.0, -1.0))
	_make_log(RulesScript.LOG_AFTER, "cr_log_after_title", "cr_log_after_body", Vector3(-6.8, 0.0, 1.0))

	_make_breaker(RulesScript.BREAKER_A, Vector3(-3.0, 0.0, -5.3), Color(0.7, 0.7, 0.75), Color(0.3, 0.6, 1.0))
	_make_breaker(RulesScript.BREAKER_B, Vector3(0.0, 0.0, -5.3), Color(1.0, 0.65, 0.1), Color(1.0, 0.65, 0.1))
	_make_breaker(RulesScript.BREAKER_C, Vector3(3.0, 0.0, -5.3), Color(0.2, 0.9, 0.4), Color(0.2, 1.0, 0.4))

	B.box(self, Vector3(0.5, 0.6, 0.5), Vector3(-6.5, 0.3, -2.2), Color(0.35, 0.35, 0.4), 0.4)
	B.box(self, Vector3(0.9, 0.8, 0.9), Vector3(0.0, 0.4, 2.7), Color(0.3, 0.32, 0.36))
	_make_trace("a", Vector3(-3.0, 0.0, -4.8), PackedVector3Array([Vector3.ZERO, Vector3(0.0, 0.0, 2.6), Vector3(-3.5, 0.0, 2.6)]), "cr_trace_a", Color(0.6, 0.8, 1.0))
	_make_trace("b", Vector3(0.0, 0.0, -4.8), PackedVector3Array([Vector3.ZERO, Vector3(0.0, 0.0, 7.0)]), "cr_trace_b", Color(1.0, 0.65, 0.1))
	_make_trace("c", Vector3(3.0, 0.0, -4.8), PackedVector3Array([Vector3.ZERO, Vector3(0.0, 0.0, 3.8), Vector3(5.0, 0.0, 3.8)]), "cr_trace_c", Color(0.2, 0.9, 0.4))

	gate_lamp = B.box(self, Vector3(0.3, 0.3, 0.3), Vector3(7.7, 2.2, -2.0), Color(0.1, 0.12, 0.14))
	door = DoorScript.new()
	door.display_name = _text("cr_trace_c")
	door.locked_message = _text("cr_gate_locked")
	door.interaction_range = 3.0
	door.position = Vector3(8.25, 0.0, 0.0)
	add_child(door)
	door.interacted.connect(_on_door_interacted)
	door.opened.connect(_on_door_opened)


func _make_log(log_id: String, title_key: String, body_key: String, pos: Vector3) -> void:
	var terminal = LogScript.new()
	terminal.log_id = log_id
	terminal.title_text = _text(title_key)
	terminal.body_text = _text(body_key)
	terminal.display_name = terminal.title_text
	terminal.prompt_text = _text("cr_prompt_read_log")
	terminal.rules = rules
	terminal.position = pos
	add_child(terminal)
	terminal.log_read.connect(_on_log_read)
	logs[log_id] = terminal


func _make_breaker(breaker_id: String, pos: Vector3, band: Color, lamp_on: Color) -> void:
	var panel_node = BreakerScript.new()
	panel_node.breaker_id = breaker_id
	panel_node.display_name = breaker_id
	panel_node.prompt_text = _text("cr_prompt_use_breaker")
	panel_node.band_color = band
	panel_node.lamp_on_color = lamp_on
	panel_node.text_lamp = _text("cr_breaker_a_response")
	panel_node.text_burned = _text("cr_breaker_b_response")
	panel_node.text_pressure = _text("cr_breaker_c_response")
	panel_node.text_cooldown = _text("cr_breaker_b_cooldown")
	panel_node.rules = rules
	panel_node.clock = Callable(self, "_clock")
	panel_node.position = pos
	add_child(panel_node)
	panel_node.used.connect(_on_breaker_used)
	breakers[breaker_id] = panel_node


func _make_trace(trace_id: String, origin: Vector3, route: PackedVector3Array, label_key: String, glow: Color) -> void:
	var trace = TraceScript.new()
	trace.trace_id = trace_id
	trace.label_text = _text(label_key)
	trace.route = route
	trace.glow_color = glow
	trace.position = origin
	add_child(trace)
	traces.append(trace)


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
	hud.call("set_objective", _text("cr_objective_start"))
	panel = PanelScript.new()
	add_child(panel)
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	_hint_button = Button.new()
	_hint_button.text = _text("cr_hint_button")
	_hint_button.focus_mode = Control.FOCUS_NONE
	_hint_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_hint_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_hint_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hint_button.offset_left = -140.0
	_hint_button.offset_top = -64.0
	_hint_button.offset_right = -20.0
	_hint_button.offset_bottom = -20.0
	_hint_button.visible = hint_mode != HintsScript.Mode.OFF
	_hint_button.pressed.connect(_request_hint)
	layer.add_child(_hint_button)


func _process(delta: float) -> void:
	_clock_t += delta
	var target = manager.current_target
	var line := ""
	if target != null and is_instance_valid(target):
		line = str(target.call("get_prompt_line"))
	hud.call("set_prompt", line)
	for event in hints.advance(_clock_t):
		_show_hint(event)
	telemetry.tick(_clock_t)
	if _hint_clear_at >= 0.0 and _clock_t >= _hint_clear_at:
		_hint_clear_at = -1.0
		hud.call("set_hint", "")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file(MENU_PATH)
		return
	if event.is_action_pressed("scan") and not event.is_echo():
		_log_scan()


## El escaner no emite senal por escaneo, asi que se mide aqui con la misma distancia que usa.
func _log_scan() -> void:
	var near := false
	var a: Vector3 = elena.global_position
	for trace in traces:
		var b: Vector3 = trace.global_position
		if Vector2(a.x - b.x, a.z - b.z).length() <= scanner.scan_radius:
			near = true
	telemetry.scan_used(near, _clock_t)
	if near:
		hints.notify_useful_action(_clock_t)


func _on_log_read(log_id: String, _first_time: bool) -> void:
	hints.notify_useful_action(_clock_t)
	telemetry.log_read(log_id, _clock_t)


func _on_breaker_used(breaker_id: String, result: Dictionary) -> void:
	var result_name := str(result.get("result", ""))
	hints.notify_breaker_result(result_name, _clock_t)
	if bool(result.get("accepted", false)):
		telemetry.breaker_used(breaker_id, bool(result.get("correct", false)), _clock_t)
	else:
		telemetry.notify_useful_action(_clock_t)
	if result_name == RulesScript.RESULT_LAMP:
		if not rules.pressure_on:
			_set_gate_lamp(Color(0.3, 0.6, 1.0))
	elif result_name == RulesScript.RESULT_PRESSURE:
		_set_gate_lamp(Color(0.2, 1.0, 0.4))
		door.set_locked(false)


func _on_door_interacted(_actor: Node3D) -> void:
	if not rules.is_gate_open():
		hints.notify_useful_action(_clock_t)
		telemetry.notify_useful_action(_clock_t)


func _on_door_opened() -> void:
	if not rules.open_gate():
		return
	hints.notify_solved()
	telemetry.gate_opened(_clock_t)
	telemetry.solved(_clock_t)
	hud.call("set_objective", _text("cr_objective_done"))
	hud.call("set_hint", "")
	_hint_clear_at = -1.0


func _request_hint() -> void:
	telemetry.notify_useful_action(_clock_t)
	for event in hints.request_hint(_clock_t):
		_show_hint(event)


func _show_hint(event: Dictionary) -> void:
	var level := int(event["level"])
	var text := _text(hints.text_key_for(level))
	if text.is_empty():
		return
	hud.call("set_hint", text)
	_hint_clear_at = _clock_t + HINT_SECONDS
	telemetry.hint_shown(level, str(event["trigger"]), _clock_t)


func _set_gate_lamp(color: Color) -> void:
	B.set_glow(gate_lamp, color, 3.0)


func _on_fell() -> void:
	elena.global_position = START
	elena.velocity = Vector3.ZERO
