extends Node3D
## Canonical Phase 1 slice, "The Ghost Protocol" -> "Containment" (FASE1_* design documents, geometry v3.0).
##
## One continuous playthrough: west entry tunnel -> A/B/C -> S1 down to D1/D2 (schematic, tampered A->T bridge,
## maintenance) -> S1 up, east return -> lift to M -> S2 to P2 (control E, archive F) -> G airlock. Opening G's
## outer leaf with the queued service audit starts Containment: the recovery unit comes along the exterior gantry,
## Elena retreats through F/E and the pump room past STAFF-M1 (quiet evasion), takes the lift down, the unit follows
## by the same lift and reacquires her by real line of sight around R1 (run), and she escapes by S1, the P-1 drainage
## gallery and the east service mouth straight into the parking area, where Phase 2 continues the same pursuit.
##
## Contracts kept: the circuit model (phase1_circuit_model.gd, FASE1_LOGIC_CONTRACT.md) decides every circuit outcome;
## mission flags live in phase1_mission_state.gd and never touch the circuit or the save file.

const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
const CircuitModel = preload("res://scripts/prototypes/phase1_circuit_model.gd")
const ServiceLift = preload("res://scripts/prototypes/service_lift.gd")
const FacilityMaterials = preload("res://scripts/levels/test_room_art/facility_materials.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")
const PanelScript = preload("res://scripts/ui/narrative_panel.gd")
const Building = preload("res://scripts/phase1/phase1_building.gd")
const MissionState = preload("res://scripts/phase1/phase1_mission_state.gd")
const UnitScript = preload("res://scripts/phase1/phase1_recovery_unit.gd")
const StaffScript = preload("res://scripts/phase1/phase1_staff.gd")
const Handoff = preload("res://scripts/phase1/phase1_handoff.gd")
const Synth = preload("res://scripts/audio/sfx_synth.gd")

const CHASE_SCENE := "res://scenes/prototypes/phase2_parking_chase.tscn"
const SPAWN := Vector3(-2.3, 0.0, 6.0)
const INTERACTION_REACH := 1.8
const SCAN_CHARGE_TIME := 0.9
const SCAN_REVEAL_TIME := 3.0
const SCAN_COOLDOWN := 4.0
const UNIT_DELAY := 1.6
const EXIT_X := 35.0
const FALL_MARGIN := 2.5
## R1 sector shutter: opening (bottom edge height, m), manual release rate and the rate the unit forces it.
const R1_FULL := 2.35
const R1_CRANK_RATE := 0.17
const R1_FORCE_RATE := 0.9
const R1_CROUCH_CLEAR := 1.1
## N1-03 (docs/narrative_complete.md): proposed terminal copy, pending narrative approval. Context, not a key.
const ARCHIVE_RECORD := "ENSAYO ASTER — RESULTADO RETENIDO.\nRECOMENDACIÓN DE DESPLIEGUE: SUPRIMIDA.\n\nActa oficial: alimentación exclusiva del nodo T.\nTelemetría de bornes: corriente simultánea en A y T durante la ventana de ensayo."
## Requested hints (H): three steps that explain relationships and never name a control.
const HINTS := [
	"El esquema del foso describe cómo debería repartirse la energía. Compáralo con lo que hay físicamente entre A y T.",
	"Si A y T están unidos por un puente, pedir ARCHIVO mientras el ensayo sigue conectado es pedir dos cosas a la vez.",
	"La protección no vuelve sola tras un disparo. Elimina primero la doble demanda; después, comprueba el estado.",
]
## Escape checkpoints: Elena's restore point and the route node the unit restarts from (always well behind her).
const CHECKPOINTS := [
	{"id": "F", "pos": Vector3(6.0, 6.0, -6.2), "unit": "gantry_far"},
	{"id": "M", "pos": Vector3(10.2, 3.0, -5.6), "unit": "f_mid"},
	{"id": "P0", "pos": Vector3(25.0, 0.0, 0.4), "unit": "lift_m"},
	{"id": "P-1", "pos": Vector3(25.0, -2.0, 6.8), "unit": "lift_p0"},
]

var materials = FacilityMaterials.new()
var circuit = CircuitModel.new()
var mission = MissionState.new()
var building = null
var lift = null
var player: CharacterBody3D
var hud: CanvasLayer
var subtitles: CanvasLayer
var unit: CharacterBody3D = null
var staff: CharacterBody3D = null
## "investigation" -> "containment" (quiet evasion) -> "run" -> "exited".
var phase: String = "investigation"
var checkpoint_index: int = -1
var catches: int = 0
var hints_used: int = 0
var clues_seen: Dictionary = {}
## Test seams: route tests can run the escape without the unit, and capture the handoff instead of changing scene.
var spawn_unit_enabled: bool = true
var handoff_override: Callable = Callable()

var _hotspot_id := ""
var _g_inner_open := false
var _g_outer_open := false
var _scan_charge := 0.0
var _scan_reveal_left := 0.0
var _scan_cooldown_left := 0.0
var _scan_parts: Array[Node3D] = []
var _safe_point: Vector3 = SPAWN
var _safe_left := 0.0
var _said: Dictionary = {}
var _o3_dropped := false
var r1_opening: float = R1_FULL
var _r1_cranking := false
var _r1_reported := false
var _rider_send := false
var _handoff_started := false
var _caught_left := 0.0
var _alarm_t := 0.0
var _parking_request := false
var _sfx: Dictionary = {}
var _alarm_loop: AudioStreamPlayer
var _steps: Array[AudioStreamPlayer] = []
var _step_dist := 0.0
var _step_i := 0


func _ready() -> void:
	_environment()
	building = Building.new(self, materials)
	building.build()
	_build_lift()
	_build_scan_parts()
	_build_actors()
	_build_audio()
	_refresh_state_fixtures()
	_set_objective("Investiga la anomalía eléctrica de la instalación")
	_log("slice_ready", "Fase 1 canónica v3.0 · P-1 -2 / P0 0 / M +3 / P2 +6")


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _environment() -> void:
	# A 2048 directional shadow atlas is enough for this compact interior (4096 cost ~3 ms on the HD 630).
	RenderingServer.directional_shadow_atlas_set_size(2048, true)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.015, 0.02, 0.028)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.36, 0.43, 0.52)
	env.ambient_light_energy = 0.52
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_hdr_threshold = 1.2
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, 205.0, 0.0)
	sun.light_color = Color(0.62, 0.72, 0.86)
	sun.light_energy = 0.35
	sun.shadow_enabled = true
	# One orthogonal shadow pass instead of four PSSM splits: the interior is compact (measured on the HD 630).
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = 30.0
	add_child(sun)


func _build_lift() -> void:
	lift = ServiceLift.new()
	lift.name = "ServiceLift"
	lift.position = Vector3(26.0, 0.0, -3.0)
	lift.lower_y = Building.Y_P0
	lift.upper_y = Building.Y_M
	lift.powered = false
	add_child(lift)
	lift.state_changed.connect(func(_d): _refresh_lift_gates())
	lift.departed.connect(func(_o, _d): _rider_send = false)
	lift.hold_departure = func() -> bool: return player != null and _player_on_deck() and not _rider_send
	_refresh_lift_gates()


func _build_actors() -> void:
	player = Player.new()
	player.name = "Elena"
	player.position = SPAWN
	add_child(player)
	player.visual.rotation.y = PI * 0.5  # facing the opening into A
	player.set("orbit_yaw", -PI * 0.5)
	hud = HudScript.new()
	hud.name = "PromptHUD"
	add_child(hud)
	# Phase 1 has no quick save (mission state is session-only by contract): the legend lists what really works.
	hud.call("set_legend_actions", ["move", "run", "crouch", "jump", "interact", "scan", "hint", "pause"])
	subtitles = PanelScript.new()
	subtitles.name = "Subtitles"
	add_child(subtitles)
	staff = StaffScript.new()
	staff.name = "StaffM1"
	add_child(staff)
	staff.player = player
	staff.alerted.connect(_on_staff_alerted)


func _build_audio() -> void:
	var streams := {"beep": Synth.terminal_beep(), "denied": Synth.denied(), "door": Synth.door_open(), "clunk": Synth.lever_clunk(),
		"power_up": Synth.power_up(), "power_down": Synth.power_down(), "scan": Synth.scan_pulse(), "tick": Synth.inspect_tick(),
		"land": Synth.land(), "chime": Synth.complete_chime()}
	for key in streams:
		var p := AudioStreamPlayer.new()
		p.stream = streams[key]
		p.volume_db = -7.0
		add_child(p)
		_sfx[key] = p
	_alarm_loop = AudioStreamPlayer.new()
	_alarm_loop.stream = Synth.alarm_pip()
	_alarm_loop.volume_db = -14.0
	add_child(_alarm_loop)
	var tone := AudioStreamPlayer.new()
	tone.stream = Synth.room_tone()
	tone.volume_db = -18.0
	tone.autoplay = true
	add_child(tone)
	for v in 4:
		var s := AudioStreamPlayer.new()
		s.stream = Synth.footstep(v)
		s.volume_db = -15.0
		add_child(s)
		_steps.append(s)


func _sound(key: String) -> void:
	var p := _sfx.get(key) as AudioStreamPlayer
	if p != null:
		p.play()


# --- frame ------------------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if _caught_left > 0.0:
		_caught_left -= delta
		if _caught_left <= 0.0:
			_restore_checkpoint()
		return
	_update_interaction_prompt()
	_update_scanner(delta)
	if not _hotspot_id.is_empty() and Input.is_action_just_pressed("interact"):
		_interact(_hotspot_id)
	if InputMap.has_action("hint") and Input.is_action_just_pressed("hint") and phase == "investigation":
		_show_hint()
	_track_safety(delta)
	_story_beats()
	_footsteps(delta)
	if phase != "investigation":
		_update_escape(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and player != null:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


## Safety net, not a mechanic: guard rails make falls impossible on the designed routes. If physics ever lets Elena
## drop below the lowest floor, she is put back where she last stood safely, with nothing lost.
func _track_safety(delta: float) -> void:
	_safe_left -= delta
	if player.is_on_floor() and _safe_left <= 0.0 and not bool(player.get("is_climbing")):
		_safe_left = 0.5
		_safe_point = player.global_position
	if player.global_position.y < Building.Y_P1 - FALL_MARGIN:
		_log("fall_recovered", "%s" % player.global_position)
		player.global_position = _safe_point + Vector3(0.0, 0.1, 0.0)
		player.velocity = Vector3.ZERO


func _footsteps(delta: float) -> void:
	if not player.is_on_floor():
		return
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	if speed < 0.6:
		_step_dist = 0.4
		return
	_step_dist += speed * delta
	var stride := 0.9 if bool(player.get("is_running")) else 0.62
	if _step_dist >= stride:
		_step_dist = 0.0
		var s := _steps[_step_i % _steps.size()]
		s.volume_db = -21.0 if bool(player.get("is_crouching")) else (-12.0 if bool(player.get("is_running")) else -15.0)
		s.play()
		_step_i += 1


## Optional, skippable reactions (docs/narrative_complete.md N1-01/N1-02/N2-01); never block movement.
func _story_beats() -> void:
	var p := player.global_position
	if not _said.has("N1-01") and p.x > 8.5 and p.y > -0.5 and p.y < 1.0:
		_say("N1-01", "Elena: «No deberían haber dejado el circuito en este estado.»", 4.5)
	if phase != "investigation" and unit != null and not _said.has("N2-01"):
		var d := unit.global_position.distance_to(p)
		if d < 16.0 and unit.call("line_clear", unit.global_position + Vector3(0, 1.7, 0), p + Vector3(0, 1.2, 0)):
			_say("N2-01", "Elena: «La auditoría ha activado el protocolo de contención.»", 4.0)


func _say(id: String, text: String, seconds: float) -> void:
	_said[id] = true
	subtitles.call("show_message", text, seconds)
	_log("line", id)


# --- interactions ------------------------------------------------------------------------------------------------

func _hotspots() -> Array:
	var deck := Vector3(26.0, float(lift.platform_y), -3.0)
	return [
		{"id": "maintenance", "at": Building.MAINTENANCE_AT, "verb": "Accionar", "name": "Interruptor de mantenimiento"},
		{"id": "schematic", "at": Building.SCHEMATIC_AT, "verb": "Examinar", "name": "Esquema de distribución"},
		{"id": "bridge", "at": Building.BRIDGE_AT, "verb": "Examinar", "name": "Conexión entre A y T"},
		{"id": "workshop_tag", "at": Vector3(21.0, 0.0, -6.0), "verb": "Examinar", "name": "Etiqueta de reparación"},
		{"id": "lift_lower", "at": Building.LIFT_CALL_P0_AT, "verb": "Llamar", "name": "Elevador"},
		{"id": "lift_upper", "at": Building.LIFT_CALL_M_AT, "verb": "Llamar", "name": "Elevador"},
		{"id": "lift_deck", "at": deck, "verb": "Enviar", "name": "Elevador · otro nivel"},
		{"id": "selector", "at": Building.SELECTOR_AT, "verb": "Accionar", "name": "Selector de recuperación"},
		{"id": "isolator", "at": Building.ISOLATOR_AT, "verb": "Accionar", "name": "Aislador del ensayo"},
		{"id": "rearm", "at": Building.REARM_AT, "verb": "Rearmar", "name": "Protección de recuperación"},
		{"id": "diagnostic", "at": Building.DIAGNOSTIC_AT, "verb": "Consultar", "name": "Terminal de diagnóstico"},
		{"id": "archive", "at": Building.ARCHIVE_AT, "verb": "Consultar", "name": "Archivo restringido"},
		{"id": "g_inner", "at": Building.G_INNER_AT, "verb": "Cerrar" if _g_inner_open else "Abrir", "name": "Puerta interior de G"},
		{"id": "g_outer", "at": Building.G_OUTER_AT + Vector3(0.75, 0.0, 0.0), "verb": "Abrir", "name": "Compuerta exterior de G"},
		{"id": "r1_crank", "at": Building.R1_CRANK_AT, "verb": "Detener desbloqueo" if _r1_cranking else "Desbloqueo de emergencia", "name": "Compuerta de sector"},
	]


func _update_interaction_prompt() -> void:
	var best: Dictionary = {}
	var best_d := INTERACTION_REACH
	var p := player.global_position
	for h in _hotspots():
		var at: Vector3 = h["at"]
		if absf(at.y - p.y) > 1.0:
			continue
		var d := Vector2(at.x - p.x, at.z - p.z).length()
		if d <= best_d and _available(str(h["id"])) and _reachable(at):
			best_d = d
			best = h
	_hotspot_id = str(best.get("id", ""))
	hud.call("set_prompt", "" if best.is_empty() else "[E] %s - %s" % [best["verb"], best["name"]])


## Line of sight from Elena's chest to the control: no operating anything through a wall.
## The ray stops 0.4 m short of the control, so the control's own body (a door leaf, a housing) never hides itself.
func _reachable(at: Vector3) -> bool:
	var from := player.global_position + Vector3(0.0, 1.2, 0.0)
	var to := at + Vector3(0.0, 1.0, 0.0)
	var span := to - from
	if span.length() > 0.5:
		to -= span.normalized() * 0.4
	var q := PhysicsRayQueryParameters3D.create(from, to, 1, [player.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _available(id: String) -> bool:
	match id:
		"lift_deck":
			var on_deck := absf(player.global_position.x - 26.0) < 1.4 and absf(player.global_position.z + 3.0) < 1.4
			return on_deck and absf(player.global_position.y - float(lift.platform_y)) < 0.5 and not lift.moving
		"g_outer":
			return not _g_outer_open
		"g_inner":
			return phase == "investigation" or not _g_inner_open
		"r1_crank":
			return phase != "investigation" and r1_opening < R1_FULL
	return true


func _interact(id: String) -> void:
	player.call("play_gesture", "interact", 0.7)
	match id:
		"maintenance":
			_toggle_maintenance()
		"schematic":
			clues_seen["schematic"] = true
			_sound("tick")
			_banner("Esquema de distribución prevista", "Una fuente auxiliar. Emergencia → diagnóstico. Mantenimiento → luces y elevador. Protección → selector: ENSAYO → T, ARCHIVO → A. Ramas independientes.", Color(0.55, 0.9, 0.95), 7.0)
			_log("clue", "schematic")
		"bridge":
			clues_seen["bridge"] = true
			_sound("tick")
			_banner("Conexión entre A y T", "Un puente de cable une los bornes A y T. Está apretado con abrazaderas nuevas y el suelo de debajo está quemado.", Color(1.0, 0.67, 0.25), 7.0)
			_log("clue", "tampered_bridge_A_to_T")
		"workshop_tag":
			clues_seen["workshop_tag"] = true
			_sound("tick")
			_banner("Etiqueta de reparación", "«Puente temporal A→T. Retirar tras ensayo.» Nadie lo retiró.", Color(0.95, 0.8, 0.5), 5.5)
			_log("clue", "workshop_tag")
		"lift_lower":
			_call_lift("lower")
		"lift_upper":
			_call_lift("upper")
		"lift_deck":
			_rider_send = true
			var ok: bool = lift.send()
			if not ok:
				_rider_send = false
			_log("lift_deck", "accepted" if ok else "refused")
			_sound("clunk" if ok else "denied")
			if not ok:
				_banner("Elevador sin alimentación", "El panel del elevador está apagado.", Color(1.0, 0.67, 0.25), 3.0)
		"selector":
			_circuit_action("selector")
		"isolator":
			_circuit_action("isolator")
		"rearm":
			_request_rearm()
		"diagnostic":
			_sound("beep")
			_banner("Terminal de diagnóstico", _diagnostic_text(), Color(0.5, 0.9, 0.95), 7.0)
			_log("inspect", "diagnostic")
		"archive":
			_consult_archive()
		"g_inner":
			_toggle_g_inner()
		"g_outer":
			_open_g_outer()
		"r1_crank":
			_r1_cranking = not _r1_cranking
			_sound("clunk")
			_log("r1_shutter", "release started" if _r1_cranking else "release stopped")
			if _r1_cranking and not _r1_reported and unit != null:
				_r1_reported = true
				unit.call("respond", Vector3(29.0, 0.0, 3.2))  # telemetry: sector R1 breached -> search the east return


func _toggle_maintenance() -> void:
	var was: bool = circuit.maintenance_on
	circuit.set_maintenance(not was)
	lift.set_powered(circuit.maintenance_on)
	if mission.on_maintenance(was, circuit.maintenance_on):
		_log("mission", "SERVICE_OVERRIDE queued")
	_sound("power_up" if circuit.maintenance_on else "power_down")
	for l in building.service_lights:
		l.visible = true
		var tw := create_tween()
		tw.tween_property(l, "light_energy", 1.0 if circuit.maintenance_on else 0.0, 1.2)
		if not circuit.maintenance_on:
			tw.tween_callback(func(): l.visible = false)  # a dark light still costs a pass on Compatibility
	building.switch_lamp.material_override = building.b.flat(Color(0.2, 0.95, 0.5) if circuit.maintenance_on else Color(0.95, 0.2, 0.1), 0.4, 0.0, 1.5)
	for lamp in building.pump_lamps:
		lamp.material_override = building.b.flat(Color(0.3, 1.0, 0.5) if circuit.maintenance_on else Color(0.2, 0.2, 0.2), 0.4, 0.0, 1.4 if circuit.maintenance_on else 0.0)
	_banner("Mantenimiento " + ("activo" if circuit.maintenance_on else "apagado"), "Luces de servicio, bombas y elevador " + ("con alimentación." if circuit.maintenance_on else "sin alimentación."), Color(0.45, 0.95, 0.65) if circuit.maintenance_on else Color(1.0, 0.67, 0.25), 4.0)
	if circuit.maintenance_on and phase == "investigation":
		_set_objective("Sube a control: el elevador ya tiene energía")
	_refresh_state_fixtures()
	_log("maintenance", "on" if circuit.maintenance_on else "off")


func _circuit_action(which: String) -> void:
	var was_available: bool = circuit.protection_available
	var title := ""
	if which == "selector":
		var target: String = CircuitModel.ARCHIVE if circuit.destination == CircuitModel.TRIAL else CircuitModel.TRIAL
		circuit.select_destination(target)
		title = "Selector en " + target
		_log("selector", target)
	else:
		circuit.set_isolated(not circuit.trial_isolated)
		title = "Ensayo " + ("aislado" if circuit.trial_isolated else "conectado")
		_log("isolator", "isolated" if circuit.trial_isolated else "connected")
	_sound("clunk")
	if was_available and not circuit.protection_available:
		_trip_feedback()
	else:
		_banner(title, "Comprueba el panel: estado actual y último disparo aparecen por separado.", Color(0.5, 0.9, 0.95), 3.0)
	_refresh_state_fixtures()


## The trip: alarm pip, every light dips, the column's protection ring goes red. Nothing is lost.
func _trip_feedback() -> void:
	_sound("denied")
	_banner("Protección disparada", "Demanda simultánea registrada. No se ha perdido nada: el sistema puede recuperarse.", Color(1.0, 0.3, 0.2), 5.0)
	_log("trip", str(circuit.last_trip))
	for node in find_children("*", "OmniLight3D", true, false):
		var l := node as OmniLight3D
		if l.light_energy <= 0.0:
			continue
		var e := l.light_energy
		var tw := create_tween()
		tw.tween_property(l, "light_energy", e * 0.25, 0.08)
		tw.tween_property(l, "light_energy", e, 0.6)


func _request_rearm() -> void:
	var ok: bool = circuit.rearm()
	_sound("power_up" if ok else "denied")
	if ok:
		_banner("Protección rearmada", "La protección vuelve a estar disponible. El último disparo sigue registrado.", Color(0.45, 0.95, 0.65), 4.0)
	else:
		_banner("Rearme rechazado", "La demanda simultánea sigue presente.", Color(1.0, 0.67, 0.25), 4.0)
	_log("rearm", "accepted" if ok else "rejected")
	_refresh_state_fixtures()


func _consult_archive() -> void:
	if not circuit.consult():
		_sound("denied")
		_banner("Archivo no disponible", "Sin suministro estable en ARCHIVO. El diagnóstico sigue funcionando con la emergencia.", Color(1.0, 0.67, 0.25), 5.0)
		_log("archive", "refused")
		return
	_sound("beep")
	if mission.on_record_read():
		_log("mission", "RESTRICTED_RECORD_READ")
	subtitles.call("show_message", ARCHIVE_RECORD, 11.0)
	building.archive_text.text = "REGISTRO ASTER\nRESULTADO RETENIDO\nDESPLIEGUE: SUPRIMIDO"
	_set_objective("Has visto lo que ocultaban. Sal por la esclusa G")
	_log("archive", "read")


func _call_lift(level: String) -> void:
	var ok: bool = lift.call_to(level)
	_sound("clunk" if ok else "denied")
	_log("lift_call", "%s:%s" % [level, "accepted" if ok else "refused"])
	if not ok:
		_banner("Elevador sin alimentación", "El panel de llamada no responde. Algo en el circuito de mantenimiento está apagado.", Color(1.0, 0.67, 0.25), 3.5)


func _toggle_g_inner() -> void:
	_g_inner_open = not _g_inner_open
	_sound("door")
	var door: StaticBody3D = building.g_inner_door
	var tw := create_tween()
	tw.tween_property(door, "position:z", -8.9 if _g_inner_open else -7.25, 0.7)
	_log("g_inner", "open" if _g_inner_open else "closed")


func _open_g_outer() -> void:
	match mission.on_open_g():
		"locked":
			_sound("denied")
			_banner("Compuerta exterior bloqueada", "La esclusa no tiene ninguna orden de servicio pendiente.", Color(1.0, 0.67, 0.25), 4.0)
			_log("g_outer", "locked")
		"containment":
			_begin_containment()
		_:
			pass


# --- Containment, escape and handoff --------------------------------------------------------------------------------

func _begin_containment() -> void:
	_g_outer_open = true
	phase = "containment"
	_log("mission", "AUDIT_SENT · CONTAINMENT")
	_sound("door")
	var tw := create_tween()
	tw.tween_property(building.g_outer_door, "position:z", -9.0, 1.1)
	building.g_status_lamp.material_override = building.b.flat(Color(1.0, 0.1, 0.05), 0.4, 0.0, 3.0)
	for a in building.alarm_lights:
		a.visible = true
	_alarm_loop.play()
	building.exit_reader.text = "PROTOCOLO DE CONTENCIÓN: ACTIVO\nSECTOR EXTERIOR"
	building.exit_reader.modulate = Color(1.0, 0.45, 0.35)
	staff.call("set_containment", true)
	_topple_o1()
	_close_r1()
	lift.departed.connect(_on_lift_departed)
	_set_checkpoint(0)
	_set_objective("Retrocede y aléjate de G sin que te vean")
	_banner("PROTOCOLO DE CONTENCIÓN", "La esclusa ha enviado la auditoría. Algo se mueve en la pasarela exterior.", Color(1.0, 0.35, 0.25), 4.0)
	if not handoff_override.is_valid():
		ResourceLoader.load_threaded_request(CHASE_SCENE)
		_parking_request = true
	if spawn_unit_enabled:
		get_tree().create_timer(UNIT_DELAY).timeout.connect(_spawn_unit)


func _spawn_unit() -> void:
	unit = UnitScript.new()
	unit.name = "RecoveryUnit"
	add_child(unit)
	unit.lift = lift
	unit.player = player
	unit.call("activate", "gantry_far")
	unit.caught_player.connect(_on_caught)
	unit.reacquired.connect(_on_reacquired)
	unit.state_changed.connect(func(s): _log("unit", "%s at %s · Elena at %s" % [s, _fmt(unit.global_position), _fmt(player.global_position)]))
	_log("unit", "enters from the service tower (gantry)")


func _on_reacquired() -> void:
	phase = "run"
	_set_objective("¡Corre! Baja por S1 a la galería de descarga")
	_sound("land")
	_log("mission", "reacquired at %s -> run" % player.global_position)


func _on_staff_alerted(seen_at: Vector3) -> void:
	_log("staff", "alerted at %s" % seen_at)
	subtitles.call("show_message", "Operario: «¡Hay alguien en bombas!»", 3.0)
	if unit != null:
		unit.call("report", seen_at)


func _on_caught() -> void:
	if _caught_left > 0.0:
		return
	catches += 1
	_caught_left = 1.2
	player.set("input_enabled", false)
	player.velocity = Vector3.ZERO
	player.call("play_gesture", "caught", 1.2)
	_sound("denied")
	_banner("Te ha atrapado", "Vuelves al último punto seguro. Lo que has descubierto sigue contigo.", Color(1.0, 0.35, 0.25), 2.5)
	_log("caught", "#%d at %s" % [catches, player.global_position])


func _restore_checkpoint() -> void:
	var cp: Dictionary = CHECKPOINTS[maxi(0, checkpoint_index)]
	player.global_position = cp["pos"]
	player.velocity = Vector3.ZERO
	player.set("input_enabled", true)
	if unit != null:
		unit.call("reset_to", cp["unit"])
	if phase == "run":
		phase = "containment"
	_log("checkpoint_restored", str(cp["id"]))


func _set_checkpoint(i: int) -> void:
	if i <= checkpoint_index:
		return
	checkpoint_index = i
	_log("checkpoint", str(CHECKPOINTS[i]["id"]))


func _update_escape(delta: float) -> void:
	var p := player.global_position
	if p.y > 2.4 and p.y < 4.0 and checkpoint_index < 1:
		_set_checkpoint(1)
	elif p.y > -0.5 and p.y < 1.0 and p.x > 23.0 and p.z > -2.0 and p.z < 1.0 and checkpoint_index < 2:
		_set_checkpoint(2)
	elif p.y < -1.5 and checkpoint_index < 3:
		_set_checkpoint(3)
	_maybe_drop_o3(p)
	_update_r1(delta)
	_alarm_t += delta
	for a in building.alarm_lights:
		a.light_energy = 0.4 + 0.6 * absf(sin(_alarm_t * PI / 1.6)) if not AccessibilityManager.is_reduced_motion() else 0.7
	if not _handoff_started and p.x > EXIT_X and p.y < -1.0:
		_begin_handoff()


## Containment seals the sector at R1: the shutter comes down between the service gallery and the east return.
func _close_r1() -> void:
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_method(_set_r1_opening, R1_FULL, 0.0, 2.8)
	building.r1_beacon.material_override = building.b.flat(Color(1.0, 0.25, 0.1), 0.4, 0.0, 2.6)


func _set_r1_opening(v: float) -> void:
	r1_opening = clampf(v, 0.0, R1_FULL)
	var shutter: StaticBody3D = building.r1_shutter
	shutter.position.y = Building.R1_CLOSED_Y + r1_opening


func _player_on_deck() -> bool:
	var p := player.global_position
	return absf(p.x - 26.0) < 1.5 and absf(p.z + 3.0) < 1.5 and absf(p.y - float(lift.platform_y)) < 0.6


## Containment telemetry: when Elena rides the service lift, the protocol learns which landing it went to.
func _on_lift_departed(_origin: String, destination: String) -> void:
	if unit == null or phase == "investigation":
		return
	if _player_on_deck():
		var landing := Vector3(26.0, Building.Y_P0, -0.9) if destination == "lower" else Vector3(26.0, Building.Y_M, -5.6)
		unit.call("respond", landing)
		_log("telemetry", "lift used -> unit sent to the %s landing" % destination)


func _update_r1(delta: float) -> void:
	if r1_opening >= R1_FULL:
		_r1_cranking = false
		return
	if _r1_cranking:
		if player.global_position.distance_to(Building.R1_CRANK_AT) > 2.3:
			_r1_cranking = false
			hud.call("set_status", "")
		else:
			_set_r1_opening(r1_opening + R1_CRANK_RATE * delta)
			var pct := int(round(100.0 * r1_opening / R1_FULL))
			var note := "  ·  ya cabes agachada" if r1_opening >= R1_CROUCH_CLEAR and r1_opening < 1.8 else ""
			hud.call("set_status", "Compuerta de sector: %d %%%s" % [pct, note])
			if r1_opening >= R1_FULL:
				hud.call("set_status", "")
	if unit != null and unit.global_position.distance_to(Vector3(29.0, unit.global_position.y, 1.05)) < 1.9 and absf(unit.global_position.y) < 0.8:
		_set_r1_opening(r1_opening + R1_FORCE_RATE * delta)  # the unit has override authority and forces it


func _topple_o1() -> void:
	var shelf: StaticBody3D = building.o1_shelf
	var tw := create_tween()
	tw.tween_interval(0.35)
	tw.tween_property(shelf, "rotation:x", PI * 0.5, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(shelf, "position", Vector3(8.0, Building.Y_P2 + 0.225, -8.35), 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): _sound("clunk"); _log("obstacle", "O1 shelf down"))


## O3: a cable tray tears loose in the service gallery once Elena has stepped off the lift, never on top of her.
func _maybe_drop_o3(p: Vector3) -> void:
	if _o3_dropped or p.y > 1.0 or p.y < -0.5 or p.x < 24.0 or p.z < -1.3:
		return
	var footprint := Rect2(26.9, -0.3, 1.6, 0.8)
	if footprint.grow(0.9).has_point(Vector2(p.x, p.z)):
		return
	_o3_dropped = true
	var tray: StaticBody3D = building.b.body("O3FallenTray", Vector3(1.4, 0.55, 0.6), Vector3(27.7, 2.8, 0.1), materials.get_material("steel"), 1, true, false)
	tray.rotation.y = 0.1
	var tw := create_tween()
	tw.tween_property(tray, "position:y", 0.275, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): _sound("clunk"))
	_log("obstacle", "O3 tray down")


## Phase 1 ends at the east service mouth: Phase 2 starts at once in the parking area with the same pursuit,
## the same mission flags and Elena's momentum (no closing scene, no teleport back, no restart of the corridor).
func _begin_handoff() -> void:
	_handoff_started = true
	mission.exit_reached = true
	var unit_gap := 12.0
	if unit != null:
		unit_gap = clampf(unit.global_position.distance_to(player.global_position), 4.0, 30.0)
	Handoff.store({
		"from": "phase1",
		"mission": mission.to_dict(),
		"circuit": {"last_trip": str(circuit.last_trip), "archive_read": mission.restricted_record_read},
		"stamina": float(player.get("condition").stamina),
		"velocity": player.velocity,
		"facing": float(player.visual.rotation.y),
		"unit_state": str(unit.get("state")) if unit != null else "sweep",
		"unit_gap": unit_gap,
		"catches": catches,
	})
	_log("handoff", "phase2 · unit %s at %.1f m" % [str(unit.get("state")) if unit != null else "none", unit_gap])
	if handoff_override.is_valid():
		handoff_override.call(Handoff.peek())
		return
	var packed: PackedScene = null
	if _parking_request:
		packed = ResourceLoader.load_threaded_get(CHASE_SCENE) as PackedScene
	if packed == null:
		packed = load(CHASE_SCENE) as PackedScene
	get_tree().change_scene_to_packed.call_deferred(packed)


# --- scanner ----------------------------------------------------------------------------------------------------

func _build_scan_parts() -> void:
	var glow: Material = building.b.flat(Color(0.3, 1.0, 0.92), 0.3, 0.0, 2.4)
	# Continuity A -> T: the bridge, both terminals and the cable that climbs from T to the column's trial node.
	_scan_parts.append(building.b.visual("ScanBridge", Vector3(2.7, 0.06, 0.16), Vector3(21.5, Building.Y_P1 + 0.62, 4.2), glow, false))
	_scan_parts.append(building.b.visual("ScanTerminalA", Vector3(0.55, 0.06, 0.45), Vector3(20.2, Building.Y_P1 + 0.72, 4.2), glow, false))
	_scan_parts.append(building.b.visual("ScanTerminalT", Vector3(0.55, 0.06, 0.45), Vector3(22.8, Building.Y_P1 + 0.72, 4.2), glow, false))
	_scan_parts.append(building.b.visual("ScanSchematicA", Vector3(0.05, 0.08, 2.0), Vector3(27.88, Building.Y_P1 + 0.58, 2.9), glow, false))
	_scan_parts.append(building.b.visual("ScanTRiser", Vector3(0.08, 2.2, 0.08), Vector3(22.8, Building.Y_P1 + 1.8, 1.05), glow, false))
	_scan_parts.append(building.b.screen_text("ScanBridgeLabel", "CONTINUIDAD A → T\n(no figura en el esquema)", Vector3(21.5, Building.Y_P1 + 1.35, 4.45), "+z", 22, Color(0.35, 1.0, 0.95)))
	for part in _scan_parts:
		part.visible = false
		if part is Label3D:
			(part as Label3D).no_depth_test = true


func _update_scanner(delta: float) -> void:
	_scan_cooldown_left = maxf(0.0, _scan_cooldown_left - delta)
	if _scan_reveal_left > 0.0:
		_scan_reveal_left -= delta
		if _scan_reveal_left <= 0.0:
			_set_scan(false)
		return
	if Input.is_action_pressed("scan") and _scan_cooldown_left <= 0.0:
		_scan_charge += delta
		if _scan_charge >= SCAN_CHARGE_TIME:
			_scan_charge = 0.0
			_scan_reveal_left = SCAN_REVEAL_TIME
			_scan_cooldown_left = SCAN_COOLDOWN
			_set_scan(true)
			_sound("scan")
			player.call("play_gesture", "scan", 1.0)
			_log("scan", "%s" % player.global_position)
			if clues_seen.has("schematic") and player.global_position.y < -1.0 and not _said.has("N1-02"):
				_say("N1-02", "Elena: «Este puente no figura en el esquema.»", 3.5)
	else:
		_scan_charge = 0.0


## Reveals continuity and, during Containment, where the unit is and what it and the operator can see.
## It never marks a control or a correct action.
func _set_scan(on: bool) -> void:
	for part in _scan_parts:
		part.visible = on and phase == "investigation"
	if unit != null:
		unit.call("set_revealed", on)
	if staff != null:
		staff.call("set_revealed", on)
	if on and phase == "investigation":
		hud.call("show_banner", "TRAZAS", "Continuidad detectada entre A y T. Compárala con el esquema.", Color(0.35, 1.0, 0.95), SCAN_REVEAL_TIME)
	elif on:
		hud.call("show_banner", "ESCÁNER", "Unidad y campos de visión revelados.", Color(0.35, 1.0, 0.95), SCAN_REVEAL_TIME)


# --- state fixtures and text ----------------------------------------------------------------------------------------

func _diagnostic_text() -> String:
	var info: Dictionary = circuit.inspect()
	var current := "ARCHIVO SIN SUMINISTRO"
	match str(info["current"]):
		"ARCHIVE_STABLE":
			current = "ARCHIVO ESTABLE"
		"RECOVERY_TRIPPED_FAULT_PRESENT":
			current = "PROTECCIÓN DISPARADA · FALLO PRESENTE"
		"RECOVERY_TRIPPED_REARM_PENDING":
			current = "PROTECCIÓN DISPARADA · REARME PENDIENTE"
	return "Estado actual: %s\nDestino: %s · Ensayo: %s\nÚltimo disparo: %s" % [current, str(info["destination"]),
		"aislado" if circuit.trial_isolated else "conectado", "DEMANDA SIMULTÁNEA" if str(info["last_trip"]) != "" else "ninguno"]


func _refresh_state_fixtures() -> void:
	var info: Dictionary = circuit.inspect()
	var out: Dictionary = circuit.outputs()
	building.panel_text.text = "ESTADO ACTUAL\n%s\n\nDESTINO  %s     ENSAYO  %s\nPROTECCIÓN  %s\nÚLTIMO DISPARO  %s" % [
		_diagnostic_text().get_slice("\n", 0).trim_prefix("Estado actual: "), str(info["destination"]),
		"AISLADO" if circuit.trial_isolated else "CONECTADO", "DISPONIBLE" if circuit.protection_available else "DISPARADA",
		"DEMANDA SIMULTÁNEA" if str(info["last_trip"]) != "" else "NINGUNO"]
	building.indicator_text.text = "ARCHIVO %s  ·  ENSAYO %s" % ["■ ESTABLE" if bool(out["archive"]) else "□ SIN SUMINISTRO", "■ DEMANDA" if bool(out["trial"]) else "□ SIN DEMANDA"]
	if not mission.restricted_record_read:
		building.archive_text.text = "ARCHIVO\n" + ("SUMINISTRO ESTABLE" if bool(out["archive"]) else "SIN SUMINISTRO")
	# Column rings (shape-independent cue + text on the panel): maintenance, archive supply, protection.
	var rings: Array = building.column_rings
	(rings[0] as MeshInstance3D).material_override = building.b.flat(Color(0.75, 0.9, 1.0) if circuit.maintenance_on else Color(0.15, 0.17, 0.18), 0.4, 0.2, 1.8 if circuit.maintenance_on else 0.0)
	(rings[1] as MeshInstance3D).material_override = building.b.flat(Color(0.3, 1.0, 0.4) if bool(out["archive"]) else Color(0.15, 0.17, 0.18), 0.4, 0.2, 1.8 if bool(out["archive"]) else 0.0)
	(rings[2] as MeshInstance3D).material_override = building.b.flat(Color(1.0, 0.18, 0.1) if not circuit.protection_available else Color(0.15, 0.17, 0.18), 0.4, 0.2, 2.2 if not circuit.protection_available else 0.0)


func _refresh_lift_gates() -> void:
	if building == null or lift == null:
		return
	var open: Dictionary = lift.gates_open()
	for pair in [[building.lift_gate_lower, bool(open["south"])], [building.lift_gate_upper, bool(open["north"])]]:
		var gate: StaticBody3D = pair[0]
		(gate.get_child(0) as CollisionShape3D).set_deferred("disabled", pair[1])
		(gate.get_child(1) as MeshInstance3D).visible = not pair[1]


func _show_hint() -> void:
	var i := mini(hints_used, HINTS.size() - 1)
	hints_used += 1
	subtitles.call("show_message", "Pista %d/%d: %s" % [i + 1, HINTS.size(), HINTS[i]], 8.0)
	_log("hint", str(i + 1))


func _set_objective(text: String) -> void:
	if hud != null:
		hud.call("set_objective", "OBJETIVO  /  " + text)


func _banner(title: String, body: String, accent: Color, seconds: float) -> void:
	if hud != null:
		hud.call("show_banner", title, body, accent, seconds)


func _fmt(p: Vector3) -> String:
	return "(%.1f, %.1f, %.1f)" % [p.x, p.y, p.z]


func _log(id: String, detail: String = "") -> void:
	print("[phase1 %.1fs] %s %s" % [Time.get_ticks_msec() / 1000.0, id, detail])
