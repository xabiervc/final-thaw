extends Node3D
## FINAL THAW — Phase 1 "The Ghost Protocol" and Phase 2 "Containment", one continuous scene.
##
## Intro cinematic -> investigation (west tunnel, A/B/C, S1 down to the pit: schematic, tampered A->T bridge,
## maintenance; lift to M, S2 to control E: isolate / select / check / rearm; archive F) -> the record is read ->
## opening G's outer leaf sends the service audit queued by maintenance -> Containment: the recovery unit comes
## along the exterior gantry; Elena retreats unseen through F/E/S2/M, takes the lift down (telemetry reports the
## lift), R1 closes, the unit reacquires her by real line of sight -> run: S1, the pit, the evacuation gallery ->
## the service yard (Phase 2 set piece in the same scene: facility response, two routes, noise devices, the stuck
## O3 gate, the emergency lane) -> crossing the north gate -> ending cinematic -> results -> main menu.
##
## Ownership: the circuit model decides every circuit outcome (FASE1_LOGIC_CONTRACT.md, unchanged); mission flags
## live in phase1_mission_state.gd; Elena's knowledge in field_notes.gd; none of it touches the save file.
## Every player-facing string comes from data/game_text.json (ES/EN).

const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
const CircuitModel = preload("res://scripts/prototypes/phase1_circuit_model.gd")
const ServiceLift = preload("res://scripts/prototypes/service_lift.gd")
const FacilityMaterials = preload("res://scripts/levels/test_room_art/facility_materials.gd")
const HudScript = preload("res://scripts/ui/prompt_hud.gd")
const PanelScript = preload("res://scripts/ui/narrative_panel.gd")
const Building = preload("res://scripts/phase1/phase1_building.gd")
const Parking = preload("res://scripts/phase2/phase2_parking.gd")
const MissionState = preload("res://scripts/phase1/phase1_mission_state.gd")
const UnitScript = preload("res://scripts/phase1/phase1_recovery_unit.gd")
const FieldNotes = preload("res://scripts/game/field_notes.gd")
const Cinema = preload("res://scripts/game/cinematic_director.gd")
const Music = preload("res://scripts/game/music_director.gd")
const Synth = preload("res://scripts/audio/sfx_synth.gd")
const GSynth = preload("res://scripts/audio/game_synth.gd")
const T = preload("res://scripts/game/game_text.gd")

const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const SPAWN := Vector3(-2.3, 0.0, 6.0)
const INTRO_START := Vector3(-2.75, 0.0, 6.0)
const INTERACTION_REACH := 1.8
const SCAN_CHARGE_TIME := 0.9
const SCAN_REVEAL_TIME := 3.0
const SCAN_COOLDOWN := 4.0
const UNIT_DELAY := 1.6
const FALL_MARGIN := 2.5
## R1 sector shutter: opening (bottom edge height, m), manual release rate and the rate the unit forces it.
const R1_FULL := 2.35
const R1_CRANK_RATE := 0.17
const R1_FORCE_RATE := 0.9
const R1_CROUCH_CLEAR := 1.1
## Noise devices in the yard: delay before the noise starts, how long it lasts, how far the unit hears it.
const COMPRESSOR_DELAY := 2.0
const COMPRESSOR_TIME := 8.0
const NOISE_RADIUS := 22.0
const SHUTTER_TIME := 2.4
## The pursuit camera is used while the unit is alerted/chasing, and kept this long after contact is lost.
const PURSUIT_HOLD := 2.5
## Checkpoints: Elena's restore point and the route node the unit restarts from (always well behind her, never
## with a fresh line of sight to the restore point).
const CHECKPOINTS := [
	{"id": "F", "pos": Vector3(6.0, 6.0, -6.2), "unit": "gantry_far"},
	{"id": "M", "pos": Vector3(10.2, 3.0, -5.6), "unit": "f_mid"},
	{"id": "P0", "pos": Vector3(25.0, 0.0, 0.4), "unit": "lift_m"},
	{"id": "P-1", "pos": Vector3(25.0, -2.0, 6.8), "unit": "lift_p0"},
	{"id": "YARD", "pos": Vector3(35.6, -2.0, 6.0), "unit": "pit_w"},
	{"id": "JOIN", "pos": Vector3(70.0, -2.0, 2.4), "unit": "yard_dec"},
	{"id": "EGRESS", "pos": Vector3(72.95, -2.0, -4.0), "unit": "ya_2"},
]
const HINTS := {
	"explore": ["hint_explore_1", "hint_explore_2", "hint_explore_3"],
	"lift": ["hint_lift_1", "hint_lift_2"],
	"circuit": ["hint_circuit_1", "hint_circuit_2", "hint_circuit_3"],
	"record": ["hint_record_1"],
	"leave": ["hint_leave_1"],
	"escape": ["hint_escape_1", "hint_escape_2"],
	"yard": ["hint_yard_1", "hint_yard_2"],
}

## Test and chapter seams.
@export var play_intro: bool = true
var spawn_unit_enabled: bool = true
## Called with the results instead of showing the results screen and returning to the menu (tests).
var ending_override: Callable = Callable()

var materials = FacilityMaterials.new()
var circuit = CircuitModel.new()
var mission = MissionState.new()
var notes = FieldNotes.new()
var building = null
var parking = null
var lift = null
var player: CharacterBody3D
var hud: CanvasLayer
var subtitles: CanvasLayer
var pause_menu: PauseMenu
var cinema = null
var music = null
var unit: CharacterBody3D = null
## "intro" -> "investigation" -> "containment" (quiet) -> "run" (seen) -> "escaped" -> "ended".
var phase: String = "intro"
var checkpoint_index: int = -1
var catches: int = 0
var hints_used: int = 0
var elapsed: float = 0.0
var in_yard: bool = false
var results: Dictionary = {}

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
var _caught_left := 0.0
var _alarm_t := 0.0
var _pursuit_left := 0.0
var _hint_stage := ""
var _hint_step := 0
var _compressor_left := -1.0
var _compressor_used := false
var _shutter_used := false
var _play_started := false
var _sfx: Dictionary = {}
var _alarm_loop: AudioStreamPlayer
var _compressor_audio: AudioStreamPlayer3D
var _shutter_audio: AudioStreamPlayer3D
var _steps: Array[AudioStreamPlayer] = []
var _step_dist := 0.0
var _step_i := 0


func _ready() -> void:
	_environment()
	building = Building.new(self, materials)
	building.build()
	parking = building.parking
	_build_lift()
	_build_scan_parts()
	_build_actors()
	_build_audio()
	_refresh_state_fixtures()
	notes.noted.connect(_on_note)
	GameManager.stats_changed.connect(_apply_options)
	_apply_options()
	_log("slice_ready", "Phase 1+2 · P-1 -2 / P0 0 / M +3 / P2 +6 · yard x34..76")
	if play_intro:
		_play_intro()
	else:
		_begin_play()


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if get_tree() != null:
		get_tree().paused = false


func _environment() -> void:
	# A 2048 directional shadow atlas is enough for this compact interior (4096 cost ~3 ms on the HD 630).
	RenderingServer.directional_shadow_atlas_set_size(2048, true)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.04, 0.06)
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
	player.position = INTRO_START if play_intro else SPAWN
	add_child(player)
	player.visual.rotation.y = PI * 0.5  # facing the opening into A
	player.set("orbit_yaw", -PI * 0.5)
	hud = HudScript.new()
	hud.name = "PromptHUD"
	add_child(hud)
	# The legend lists what really works here (no quick save: mission state is session-only by contract).
	hud.call("set_legend_actions", ["move", "run", "crouch", "jump", "interact", "scan", "hint", "pause"])
	subtitles = PanelScript.new()
	subtitles.name = "Subtitles"
	add_child(subtitles)
	pause_menu = PauseMenu.new()
	pause_menu.name = "PauseMenu"
	pause_menu.host = self
	add_child(pause_menu)
	cinema = Cinema.new()
	cinema.name = "Cinematics"
	add_child(cinema)
	music = Music.new()
	music.name = "Music"
	add_child(music)


func _build_audio() -> void:
	GameSettings.ensure_buses()
	var streams := {"beep": Synth.terminal_beep(), "denied": Synth.denied(), "door": Synth.door_open(), "clunk": Synth.lever_clunk(),
		"power_up": Synth.power_up(), "power_down": Synth.power_down(), "scan": Synth.scan_pulse(), "tick": Synth.inspect_tick(),
		"land": Synth.land(), "chime": Synth.complete_chime(), "pa": GSynth.pa_chime(), "note": GSynth.note_tick(),
		"gate": GSynth.gate_clank()}
	for key in streams:
		var p := AudioStreamPlayer.new()
		p.stream = streams[key]
		p.volume_db = -7.0
		p.bus = "SFX"
		add_child(p)
		_sfx[key] = p
	_alarm_loop = AudioStreamPlayer.new()
	_alarm_loop.stream = Synth.alarm_pip()
	_alarm_loop.volume_db = -16.0
	_alarm_loop.bus = "SFX"
	add_child(_alarm_loop)
	var tone := AudioStreamPlayer.new()
	tone.stream = Synth.room_tone()
	tone.volume_db = -18.0
	tone.bus = "SFX"
	tone.autoplay = true
	add_child(tone)
	for v in 4:
		var s := AudioStreamPlayer.new()
		s.stream = Synth.footstep(v)
		s.volume_db = -15.0
		s.bus = "SFX"
		add_child(s)
		_steps.append(s)
	_compressor_audio = AudioStreamPlayer3D.new()
	_compressor_audio.stream = GSynth.compressor_run()
	_compressor_audio.bus = "SFX"
	_compressor_audio.unit_size = 9.0
	_compressor_audio.max_distance = 45.0
	_compressor_audio.position = Parking.COMPRESSOR_NOISE_AT + Vector3(0.0, 1.0, 0.0)
	add_child(_compressor_audio)
	_shutter_audio = AudioStreamPlayer3D.new()
	_shutter_audio.stream = GSynth.shutter_roll()
	_shutter_audio.bus = "SFX"
	_shutter_audio.unit_size = 9.0
	_shutter_audio.max_distance = 45.0
	_shutter_audio.position = Parking.DOCK_SHUTTER_AT + Vector3(0.0, 1.5, 0.0)
	add_child(_shutter_audio)


func _sound(key: String) -> void:
	var p := _sfx.get(key) as AudioStreamPlayer
	if p != null:
		p.play()


## Options that change gameplay take effect immediately (also from the pause menu).
func _apply_options() -> void:
	if player != null:
		player.set("run_drain", GameSettings.tuning("run_drain"))
	_refresh_state_fixtures()


# --- intro and start of play -----------------------------------------------------------------------------------

func _play_intro() -> void:
	phase = "intro"
	player.set("input_enabled", false)
	player.set("look_locked", true)
	hud.call("set_hud_visible", false)
	music.set_mode("investigation")
	cinema.finished.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	cinema.play(_intro_shots(), self)
	_log("intro", "%.0f s" % Cinema.total_duration(_intro_shots()))


func _look(from: Vector3, at: Vector3) -> Transform3D:
	return Transform3D(Basis.IDENTITY, from).looking_at(at, Vector3.UP)


## ~50 s. Who Elena is, why she is here, what she suspects, why it matters, the plan and the immediate objective.
func _intro_shots() -> Array:
	return [
		{"black": true, "duration": 6.5, "title": T.t("intro_card_name"), "subtitle": T.t("intro_card_role")},
		{"duration": 9.0, "from": _look(Vector3(-22.0, 2.4, 6.0), Vector3(-6.0, 6.5, -7.5)), "to": _look(Vector3(-17.0, 3.4, 3.0), Vector3(-3.0, 6.6, -7.5)),
			"fov": 52.0, "fade_in": 1.5, "lines": [[0.6, T.t("intro_line_1")]]},
		{"duration": 9.5, "from": _look(Vector3(5.0, 1.7, 3.6), Vector3(14.5, 3.4, -3.0)), "to": _look(Vector3(8.4, 1.4, 2.6), Vector3(14.5, 4.2, -3.0)),
			"fov": 55.0, "lines": [[0.4, T.t("intro_line_2")]]},
		{"duration": 8.5, "from": _look(Vector3(17.6, -0.2, 7.2), Vector3(21.5, -1.5, 4.2)), "to": _look(Vector3(19.4, -0.7, 6.4), Vector3(21.5, -1.4, 4.2)),
			"fov": 50.0, "lines": [[0.4, T.t("intro_line_3")]]},
		{"duration": 9.0, "from": _look(Vector3(5.8, 1.5, 6.7), Vector3(-1.5, 1.1, 6.0)), "to": _look(Vector3(5.1, 1.55, 6.9), Vector3(0.0, 1.2, 6.0)),
			"fov": 55.0, "lines": [[0.3, T.t("intro_line_4")]], "on_start": _intro_walk},
		{"duration": 5.0, "fov": 65.0, "lines": [[0.2, T.t("intro_line_5")]], "on_start": _intro_settle},
		{"black": true, "duration": 3.5, "title": "FINAL THAW", "subtitle": T.t("intro_title_sub")},
	]


## Elena walks out of the tunnel (camera-space "forward": the gameplay yaw faces +x) for a few metres and stops.
func _intro_walk() -> void:
	_sound("door")
	player.set("scripted_input", Vector2(0.0, -0.42))
	get_tree().create_timer(2.6).timeout.connect(func():
		if phase == "intro":
			player.set("scripted_input", Vector2.ZERO))


## Last intro shot: from the current shot to the gameplay camera behind Elena (computed now, she has moved).
func _intro_settle() -> void:
	player.set("scripted_input", Vector2.ZERO)
	var shot: Dictionary = cinema._shots[cinema.shot_index]
	shot["from"] = cinema.camera.global_transform
	var view: Camera3D = player.get("view")
	shot["to"] = view.global_transform


func _on_intro_finished(skipped: bool) -> void:
	_log("intro_end", "skipped" if skipped else "played")
	_begin_play()


## The single place gameplay starts (after the intro, after a skip, or directly in tests). Idempotent.
func _begin_play() -> void:
	if _play_started:
		return
	_play_started = true
	phase = "investigation"
	player.set("scripted_input", Vector2.ZERO)
	player.set("input_enabled", true)
	player.set("look_locked", false)
	player.call("set_camera_mode", "explore", true)
	var view: Camera3D = player.get("view")
	view.make_current()
	hud.call("set_hud_visible", true)
	get_tree().paused = false
	music.set_mode("investigation")
	_set_objective(T.t("obj_investigate"))
	notes.add("anomaly", "event")


# --- frame ------------------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if player == null or phase == "intro" or phase == "ended":
		return
	if phase == "escaped":
		return
	elapsed += delta
	if _caught_left > 0.0:
		_caught_left -= delta
		if _caught_left <= 0.0:
			_restore_checkpoint()
		return
	_update_interaction_prompt()
	_update_scanner(delta)
	if not _hotspot_id.is_empty() and Input.is_action_just_pressed("interact"):
		_interact(_hotspot_id)
	if InputMap.has_action("hint") and Input.is_action_just_pressed("hint"):
		_show_hint()
	_track_safety(delta)
	_story_beats()
	_footsteps(delta)
	if phase != "investigation":
		_update_escape(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and player != null and phase in ["investigation", "containment", "run"] and not pause_menu.is_open:
		get_viewport().set_input_as_handled()
		pause_menu.open()


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


## Optional, short reactions (docs/narrative_complete.md N1-01/N1-02/N2-01); never block movement.
func _story_beats() -> void:
	var p := player.global_position
	if not _said.has("N1-01") and p.x > 8.5 and p.y > -0.5 and p.y < 1.0:
		_say("N1-01", T.t("line_n1_01"), 4.5)
	if phase != "investigation" and unit != null and not _said.has("N2-01"):
		var d := unit.global_position.distance_to(p)
		if d < 16.0 and bool(unit.call("line_clear", unit.global_position + Vector3(0, 1.7, 0), p + Vector3(0, 1.2, 0))):
			_say("N2-01", T.t("line_n2_01"), 4.0)
			notes.add("unit")
	if in_yard and not notes.has("parking_devices"):
		if p.distance_to(Parking.DOCK_PANEL_AT) < 6.0 or p.distance_to(Parking.COMPRESSOR_PANEL_AT) < 6.0:
			notes.add("parking_devices")


## A spoken line: subtitled only if the player wants subtitles (the same facts are also in the world and notes).
func _say(id: String, text: String, seconds: float) -> void:
	_said[id] = true
	if GameSettings.subtitles_enabled():
		subtitles.call("show_message", text, seconds)
	_log("line", id)


## Facility public address: a chime (always) and its words as a subtitle.
func _announce(key: String) -> void:
	_sound("pa")
	if GameSettings.subtitles_enabled():
		subtitles.call("show_message", T.t("pa_prefix") + T.t(key), 5.0)
	_log("pa", key)


# --- interactions ------------------------------------------------------------------------------------------------

func _hotspots() -> Array:
	var deck := Vector3(26.0, float(lift.platform_y), -3.0)
	return [
		{"id": "access_plan", "at": Vector3(0.45, 0.0, 9.0), "verb": "verb_examine", "name": "hs_access_plan"},
		{"id": "official_report", "at": Vector3(13.6, 6.0, -7.6), "verb": "verb_read", "name": "hs_official_report"},
		{"id": "maintenance", "at": Building.MAINTENANCE_AT, "verb": "verb_operate", "name": "hs_maintenance"},
		{"id": "schematic", "at": Building.SCHEMATIC_AT, "verb": "verb_examine", "name": "hs_schematic"},
		{"id": "bridge", "at": Building.BRIDGE_AT, "verb": "verb_examine", "name": "hs_bridge"},
		{"id": "workshop_tag", "at": Vector3(21.0, 0.0, -6.0), "verb": "verb_examine", "name": "hs_workshop_tag"},
		{"id": "lift_lower", "at": Building.LIFT_CALL_P0_AT, "verb": "verb_call", "name": "hs_lift"},
		{"id": "lift_upper", "at": Building.LIFT_CALL_M_AT, "verb": "verb_call", "name": "hs_lift"},
		{"id": "lift_deck", "at": deck, "verb": "verb_send", "name": "hs_lift_deck"},
		{"id": "selector", "at": Building.SELECTOR_AT, "verb": "verb_operate", "name": "hs_selector"},
		{"id": "isolator", "at": Building.ISOLATOR_AT, "verb": "verb_operate", "name": "hs_isolator"},
		{"id": "rearm", "at": Building.REARM_AT, "verb": "verb_rearm", "name": "hs_rearm"},
		{"id": "diagnostic", "at": Building.DIAGNOSTIC_AT, "verb": "verb_consult", "name": "hs_diagnostic"},
		{"id": "archive", "at": Building.ARCHIVE_AT, "verb": "verb_consult", "name": "hs_archive"},
		{"id": "g_inner", "at": Building.G_INNER_AT, "verb": "verb_close" if _g_inner_open else "verb_open", "name": "hs_g_inner"},
		{"id": "g_outer", "at": Building.G_OUTER_AT + Vector3(0.75, 0.0, 0.0), "verb": "verb_open", "name": "hs_g_outer"},
		{"id": "r1_crank", "at": Building.R1_CRANK_AT, "verb": "verb_stop_release" if _r1_cranking else "verb_release", "name": "hs_r1"},
		{"id": "compressor", "at": Parking.COMPRESSOR_PANEL_AT, "verb": "verb_start", "name": "hs_compressor"},
		{"id": "dock_panel", "at": Parking.DOCK_PANEL_AT, "verb": "verb_raise", "name": "hs_dock"},
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
	hud.call("set_prompt", "" if best.is_empty() else "[E] %s - %s" % [T.t(str(best["verb"])), T.t(str(best["name"]))])


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
		"compressor":
			return in_yard and not _compressor_used
		"dock_panel":
			return in_yard and not _shutter_used
	return true


func _interact(id: String) -> void:
	player.call("play_gesture", "interact", 0.7)
	match id:
		"access_plan":
			_examine("access_plan", "ex_access_plan_title", "ex_access_plan_body", "info")
		"official_report":
			_examine("official_report", "ex_official_report_title", "ex_official_report_body", "warn")
		"maintenance":
			_toggle_maintenance()
		"schematic":
			_examine("schematic", "ex_schematic_title", "ex_schematic_body", "info")
		"bridge":
			_examine("bridge", "ex_bridge_title", "ex_bridge_body", "warn")
		"workshop_tag":
			_examine("workshop_tag", "ex_workshop_tag_title", "ex_workshop_tag_body", "warn")
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
				_banner(T.t("ban_lift_off_title"), T.t("ban_lift_off_body"), "warn", 3.0)
		"selector":
			_circuit_action("selector")
		"isolator":
			_circuit_action("isolator")
		"rearm":
			_request_rearm()
		"diagnostic":
			_sound("beep")
			_banner(T.t("ban_diagnostic_title"), _diagnostic_text(), "info", 7.0)
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
				_announce("pa_r1_release")
				unit.call("respond", Vector3(29.0, 0.0, 3.2))  # telemetry: sector R1 breached -> search the east return
		"compressor":
			_start_compressor()
		"dock_panel":
			_raise_dock_shutter()


func _examine(id: String, title_key: String, body_key: String, role: String) -> void:
	_sound("tick")
	_banner(T.t(title_key), T.t(body_key), role, 7.0)
	notes.add(id)
	_log("clue", id)


func _toggle_maintenance() -> void:
	var was: bool = circuit.maintenance_on
	circuit.set_maintenance(not was)
	lift.set_powered(circuit.maintenance_on)
	if mission.on_maintenance(was, circuit.maintenance_on):
		_log("mission", "SERVICE_OVERRIDE queued")
		notes.add("maintenance_risk", "event")
	_sound("power_up" if circuit.maintenance_on else "power_down")
	for l in building.service_lights:
		l.visible = true
		var tw := create_tween()
		tw.tween_property(l, "light_energy", 1.0 if circuit.maintenance_on else 0.0, 1.2)
		if not circuit.maintenance_on:
			tw.tween_callback(func(): l.visible = false)  # a dark light still costs a pass on Compatibility
	if circuit.maintenance_on:
		_banner(T.t("ban_maint_on_title"), T.t("ban_maint_on_body"), "ok", 6.5)
	else:
		_banner(T.t("ban_maint_off_title"), T.t("ban_maint_off_body"), "warn", 4.0)
	if circuit.maintenance_on and phase == "investigation" and not mission.restricted_record_read:
		_set_objective(T.t("obj_go_control"))
	_refresh_state_fixtures()
	_log("maintenance", "on" if circuit.maintenance_on else "off")


func _circuit_action(which: String) -> void:
	var was_available: bool = circuit.protection_available
	var title := ""
	if which == "selector":
		var target: String = CircuitModel.ARCHIVE if circuit.destination == CircuitModel.TRIAL else CircuitModel.TRIAL
		circuit.select_destination(target)
		title = T.t("ban_selector_title", {"target": _dest(target)})
		_log("selector", target)
	else:
		circuit.set_isolated(not circuit.trial_isolated)
		title = T.t("ban_isolated_title" if circuit.trial_isolated else "ban_connected_title")
		_log("isolator", "isolated" if circuit.trial_isolated else "connected")
	_sound("clunk")
	if was_available and not circuit.protection_available:
		_trip_feedback()
	else:
		_banner(title, T.t("ban_check_panel"), "info", 3.0)
	_refresh_state_fixtures()


## The trip: alarm pip, every light dips, the column's protection ring changes. Nothing is lost.
func _trip_feedback() -> void:
	_sound("denied")
	_banner(T.t("ban_trip_title"), T.t("ban_trip_body"), "danger", 5.0)
	notes.add("trip", "event")
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
		_banner(T.t("ban_rearm_ok_title"), T.t("ban_rearm_ok_body"), "ok", 4.0)
	else:
		_banner(T.t("ban_rearm_no_title"), T.t("ban_rearm_no_body"), "warn", 4.0)
	_log("rearm", "accepted" if ok else "rejected")
	_refresh_state_fixtures()


func _consult_archive() -> void:
	if not circuit.consult():
		_sound("denied")
		_banner(T.t("ban_archive_no_title"), T.t("ban_archive_no_body"), "warn", 5.0)
		_log("archive", "refused")
		return
	_sound("beep")
	if mission.on_record_read():
		_log("mission", "RESTRICTED_RECORD_READ")
	notes.add("record")
	subtitles.call("show_message", T.t("archive_record"), 13.0)  # a document on screen, not dialogue: always shown
	building.archive_text.text = T.t("archive_screen_read")
	_set_objective(T.t("obj_leave_g"))
	_log("archive", "read")


func _call_lift(level: String) -> void:
	var ok: bool = lift.call_to(level)
	_sound("clunk" if ok else "denied")
	_log("lift_call", "%s:%s" % [level, "accepted" if ok else "refused"])
	if not ok:
		_banner(T.t("ban_lift_off_title"), T.t("ban_lift_call_off_body"), "warn", 3.5)


func _toggle_g_inner() -> void:
	_g_inner_open = not _g_inner_open
	_sound("door")
	var door: StaticBody3D = building.g_inner_door
	var tw := create_tween()
	tw.tween_property(door, "position:z", -8.9 if _g_inner_open else -7.25, 0.7)
	_log("g_inner", "open" if _g_inner_open else "closed")


## Elena does not leave without the evidence (a character decision, not a lock): the outer leaf is only operated
## once the record has been read. The audit itself needs the queued SERVICE_OVERRIDE (mission contract).
func _open_g_outer() -> void:
	if not mission.restricted_record_read:
		_sound("denied")
		_say("not_yet", T.t("line_not_yet"), 3.5)
		_log("g_outer", "not without the record")
		return
	match mission.on_open_g():
		"locked":
			_sound("denied")
			_banner(T.t("ban_g_locked_title"), T.t("ban_g_locked_body"), "warn", 4.0)
			_log("g_outer", "locked")
		"containment":
			_begin_containment()
		_:
			pass


# --- Containment, escape, yard and ending ---------------------------------------------------------------------------

func _begin_containment() -> void:
	_g_outer_open = true
	phase = "containment"
	_log("mission", "AUDIT_SENT · CONTAINMENT")
	_sound("door")
	var tw := create_tween()
	tw.tween_property(building.g_outer_door, "position:z", -9.0, 1.1)
	building.g_status_lamp.material_override = building.b.flat(GamePalette.color("danger"), 0.4, 0.0, 3.0)
	for a in building.alarm_lights:
		a.visible = true
	_alarm_loop.play()
	parking.reader_mouth.text = T.t("reader_active_interior")
	parking.reader_mouth.modulate = GamePalette.color("danger")
	_topple_o1()
	_close_r1()
	lift.departed.connect(_on_lift_departed)
	_set_checkpoint(0)
	_set_objective(T.t("obj_retreat"))
	_banner(T.t("ban_containment_title"), T.t("ban_containment_body"), "danger", 4.5)
	get_tree().create_timer(0.9).timeout.connect(func(): _announce("pa_containment"))
	notes.add("containment", "event")
	notes.add("exit_plan")
	music.set_mode("tension")
	if spawn_unit_enabled:
		get_tree().create_timer(UNIT_DELAY).timeout.connect(_spawn_unit)


func _spawn_unit() -> void:
	unit = UnitScript.new()
	unit.name = "RecoveryUnit"
	add_child(unit)
	unit.lift = lift
	unit.player = player
	unit.exposure = parking.exposure_at
	unit.call("activate", "gantry_far")
	unit.caught_player.connect(_on_caught)
	unit.reacquired.connect(_on_reacquired)
	unit.lost_contact.connect(_on_lost_contact)
	unit.state_changed.connect(_on_unit_state)
	_log("unit", "enters from the service tower (gantry)")


func _on_unit_state(s: String) -> void:
	_log("unit", "%s at %s · Elena at %s" % [s, _fmt(unit.global_position), _fmt(player.global_position)])
	if s in ["alert", "chase"]:
		_pursuit_left = PURSUIT_HOLD
		player.call("set_camera_mode", "pursuit")
		music.set_mode("chase")


func _on_reacquired() -> void:
	phase = "run"
	if not in_yard:
		_set_objective(T.t("obj_run_s1"))
	_sound("land")
	_log("mission", "reacquired at %s -> run" % player.global_position)


func _on_lost_contact() -> void:
	_banner(T.t("ban_lost_title"), T.t("ban_lost_body"), "ok", 2.5)
	_log("unit", "lost contact")


func _on_caught() -> void:
	if _caught_left > 0.0:
		return
	catches += 1
	_caught_left = 1.2
	player.set("input_enabled", false)
	player.velocity = Vector3.ZERO
	player.call("play_gesture", "caught", 1.2)
	_sound("denied")
	_banner(T.t("ban_caught_title"), T.t("ban_caught_body"), "danger", 2.5)
	_log("caught", "#%d at %s" % [catches, player.global_position])


func _restore_checkpoint() -> void:
	var cp: Dictionary = CHECKPOINTS[maxi(0, checkpoint_index)]
	player.global_position = cp["pos"]
	player.velocity = Vector3.ZERO
	player.set("input_enabled", true)
	if bool(player.get("is_crouching")):
		player.call("_set_crouching", false)
	player.call("set_camera_mode", "explore")
	_pursuit_left = 0.0
	if unit != null:
		unit.call("reset_to", cp["unit"])
	if phase == "run":
		phase = "containment"
	music.set_mode("tension")
	_log("checkpoint_restored", str(cp["id"]))


func _set_checkpoint(i: int) -> void:
	if i <= checkpoint_index:
		return
	checkpoint_index = i
	_log("checkpoint", str(CHECKPOINTS[i]["id"]))
	if i > 0:
		hud.call("show_note", T.t("hud_checkpoint"))


func _update_escape(delta: float) -> void:
	var p := player.global_position
	if p.y > 2.4 and p.y < 4.0 and checkpoint_index < 1:
		_set_checkpoint(1)
		_set_objective(T.t("obj_go_down"))
	elif p.y > -0.5 and p.y < 1.0 and p.x > 23.0 and p.z > -2.0 and p.z < 1.0 and checkpoint_index < 2:
		_set_checkpoint(2)
	elif p.y < -1.5 and p.x < 34.0 and checkpoint_index < 3:
		_set_checkpoint(3)
		_set_objective(T.t("obj_gallery"))
	if not in_yard and parking.in_yard(p):
		_enter_yard()
	if in_yard:
		if checkpoint_index < 5 and Vector2(p.x - 70.5, p.z - 1.2).length() < 2.6:
			_set_checkpoint(5)
		if checkpoint_index < 6 and p.x > Parking.ENCLOSURE_X + 0.3 and p.z < Parking.BARRIER_Z - 0.6:
			_set_checkpoint(6)
	_maybe_drop_o3(p)
	_update_r1(delta)
	_update_devices(delta)
	_update_pursuit(delta)
	_alarm_t += delta
	for a in building.alarm_lights:
		a.light_energy = 0.4 + 0.6 * absf(sin(_alarm_t * PI / 1.6)) if not AccessibilityManager.is_reduced_motion() else 0.7
	if in_yard and parking.crossed_exit(p):
		_begin_ending()


## Camera, music and the stealth readout follow the unit's real state.
func _update_pursuit(delta: float) -> void:
	if unit == null:
		return
	var s: String = str(unit.call("display_state"))
	if s in ["alert", "chase"]:
		_pursuit_left = PURSUIT_HOLD
	else:
		_pursuit_left -= delta
		if _pursuit_left <= 0.0 and str(player.get("camera_mode")) == "pursuit":
			player.call("set_camera_mode", "explore")
			music.set_mode("tension")
	# The readout uses the unit's own factors: crouching x0.55, darkness down to x0.6 of its vision range.
	var e: float = parking.exposure_at(player.global_position) if in_yard else 1.0
	var f: float = (UnitScript.CROUCH_VISION_FACTOR if bool(player.get("is_crouching")) else 1.0) * lerpf(UnitScript.DARK_VISION_FACTOR, 1.0, e)
	hud.call("set_visibility", 0 if f < 0.45 else (1 if f < 0.8 else 2))


## Phase 2 set piece begins: the facility's response is visible across the yard (N2-05).
func _enter_yard() -> void:
	in_yard = true
	_set_checkpoint(4)
	_set_objective(T.t("obj_yard"))
	notes.add("parking")
	_announce("pa_yard")
	# The service camera over the mouth reports the exit: the unit is sent to that PLACE (it still has to see her).
	parking.camera_led.material_override = building.b.flat(GamePalette.color("danger"), 0.4, 0.0, 2.5)
	if unit != null:
		unit.call("respond", Parking.MOUTH_CAMERA_REPORTS)
	parking.reader_mouth.text = T.t("reader_active_exterior")
	parking.reader_gate.text = T.t("reader_active_exterior")
	var tw := create_tween()
	for i in parking.floodlights.size():
		tw.tween_interval(0.45)
		tw.tween_callback(func(): parking.set_floodlight(i, true); _sound("clunk"))
	tw.tween_interval(0.6)
	tw.tween_property(parking.boom, "rotation:z", 0.0, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): _sound("gate"))
	_log("yard", "entered · facility response")


func _start_compressor() -> void:
	_compressor_used = true
	_compressor_left = COMPRESSOR_DELAY + COMPRESSOR_TIME
	parking.compressor_lamp.material_override = building.b.flat(GamePalette.color("warn"), 0.4, 0.0, 2.0)
	_sound("beep")
	_banner(T.t("ban_compressor_title"), T.t("ban_compressor_body"), "warn", 3.5)
	_log("device", "compressor armed")


func _raise_dock_shutter() -> void:
	_shutter_used = true
	parking.dock_lamp.material_override = building.b.flat(GamePalette.color("warn"), 0.4, 0.0, 2.0)
	_sound("clunk")
	_shutter_audio.play()
	if parking.dock_shutter != null:
		create_tween().tween_property(parking.dock_shutter, "position:y", Parking.Y + 2.0, SHUTTER_TIME)
	_banner(T.t("ban_dock_title"), T.t("ban_dock_body"), "warn", 3.5)
	_noise(Parking.DOCK_SHUTTER_AT, "dock shutter")


func _update_devices(delta: float) -> void:
	if _compressor_left < 0.0:
		return
	var before := _compressor_left
	_compressor_left -= delta
	if before > COMPRESSOR_TIME and _compressor_left <= COMPRESSOR_TIME:
		_compressor_audio.play()
		_noise(Parking.COMPRESSOR_NOISE_AT, "compressor")
	if _compressor_left <= 0.0:
		_compressor_audio.stop()
		_compressor_left = -1.0


func _noise(at: Vector3, label: String) -> void:
	var heard := false
	if unit != null:
		heard = bool(unit.call("hear_noise", at, NOISE_RADIUS))
	_log("noise", "%s · unit %s" % [label, "investigates" if heard else "did not react"])


## Containment seals the sector at R1: the shutter comes down between the service gallery and the east return.
func _close_r1() -> void:
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_method(_set_r1_opening, R1_FULL, 0.0, 2.8)
	building.r1_beacon.material_override = building.b.flat(GamePalette.color("danger"), 0.4, 0.0, 2.6)


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
		_announce("pa_lift")
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
			var note := T.t("hud_r1_crouch") if r1_opening >= R1_CROUCH_CLEAR and r1_opening < 1.8 else ""
			hud.call("set_status", T.t("hud_r1_progress", {"pct": pct}) + note)
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


## Elena is beyond the perimeter: the unit stops at the sector boundary; the ending cinematic plays (N2-06).
func _begin_ending() -> void:
	if phase == "escaped" or phase == "ended":
		return
	phase = "escaped"
	mission.exit_reached = true
	if unit != null:
		unit.call("halt")
	_alarm_loop.stop()
	hud.call("set_prompt", "")
	results = {
		"time": elapsed, "catches": catches, "hints": hints_used, "notes": notes.count(),
		"notes_total": FieldNotes.ORDER.size(), "difficulty": GameSettings.difficulty(),
		"spotted": int(unit.get("times_spotted")) if unit != null else 0,
	}
	_log("mission", "EXIT · %s" % [results])
	player.set("input_enabled", false)
	player.set("look_locked", true)
	player.set("scripted_run", true)
	player.set("scripted_input", Vector2(0.0, -1.0))
	player.set("movement_basis", Basis.IDENTITY)
	player.set("orbit_yaw", 0.0)
	hud.call("set_hud_visible", false)
	music.set_mode("release")
	cinema.finished.connect(_on_ending_finished, CONNECT_ONE_SHOT)
	cinema.play(_ending_shots(), self)


func _ending_shots() -> Array:
	var gate := Vector3((Parking.GATE_X0 + Parking.GATE_X1) * 0.5, Parking.Y, Parking.Z0)
	return [
		{"duration": 3.6, "from": _look(gate + Vector3(-1.4, 1.1, 5.5), gate + Vector3(0.6, 1.4, -8.0)), "to": _look(gate + Vector3(-1.0, 1.3, 4.2), gate + Vector3(0.4, 2.2, -9.0)),
			"fov": 58.0, "lines": [[0.4, T.t("pa_prefix") + T.t("pa_exit")]], "on_start": func(): _sound("pa")},
		{"duration": 6.5, "fov": 50.0, "lines": [[0.6, T.t("line_n2_06")]], "on_start": _ending_look_back},
		{"duration": 7.0, "fov": 55.0, "fade_out": 1.5, "lines": [[0.5, T.t("end_line_1")]], "on_start": _ending_street},
		{"black": true, "duration": 7.5, "subtitle": T.t("end_card_1")},
		{"black": true, "duration": 7.5, "subtitle": T.t("end_card_2")},
		{"black": true, "duration": 5.0, "title": "FINAL THAW", "subtitle": T.t("end_card_3")},
	]


## From the top of the ramp, back down at the yard: the unit stands at the sector boundary; the perimeter lights
## change in sequence and the readers show the exterior protocol (coordinated facility response, N2-05/N2-06).
func _ending_look_back() -> void:
	player.set("scripted_run", false)
	player.set("scripted_input", Vector2.ZERO)
	var target := Vector3(71.4, -1.0, -8.0)
	if unit != null:
		target = unit.global_position + Vector3(0.0, 1.2, 0.0)
	var shot: Dictionary = cinema._shots[cinema.shot_index]
	shot["from"] = _look(Vector3(70.2, 2.3, -24.5), target)
	shot["to"] = _look(Vector3(70.6, 2.1, -22.8), target)
	cinema.camera.global_transform = shot["from"]
	var tw := create_tween()
	for i in parking.floodlights.size():
		tw.tween_interval(0.35)
		tw.tween_callback(func(): parking.set_floodlight(i, false))
	for i in parking.floodlights.size():
		tw.tween_interval(0.25)
		tw.tween_callback(func(): parking.set_floodlight(i, true); _sound("clunk"))


func _ending_street() -> void:
	player.set("scripted_input", Vector2(-0.55, 0.0))
	var p := player.global_position
	var shot: Dictionary = cinema._shots[cinema.shot_index]
	shot["from"] = _look(Vector3(p.x - 9.0, 1.9, -29.5), p + Vector3(0.0, 1.3, 0.0))
	shot["to"] = _look(Vector3(p.x - 7.0, 1.7, -29.0), p + Vector3(-4.0, 1.2, 0.0))
	cinema.camera.global_transform = shot["from"]


func _on_ending_finished(skipped: bool) -> void:
	_log("ending", "skipped" if skipped else "played")
	player.set("scripted_input", Vector2.ZERO)
	phase = "ended"
	if ending_override.is_valid():
		ending_override.call(results)
		return
	_show_results()


func _show_results() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 70
	add_child(layer)
	var parts := UiKit.modal(layer, UiKit.CYAN, 560.0)
	var box: VBoxContainer = parts[1]
	box.add_child(UiKit.heading(T.t("res_title"), 26))
	var mins := floori(float(results["time"]) / 60.0)
	var secs := int(results["time"]) % 60
	for line in [
		T.t("res_time", {"m": mins, "s": "%02d" % secs}),
		T.t("res_notes", {"n": results["notes"], "total": results["notes_total"]}),
		T.t("res_catches", {"n": results["catches"]}),
		T.t("res_hints", {"n": results["hints"]}),
		T.t("res_difficulty", {"d": T.t("opt_diff_" + str(results["difficulty"]))}),
	]:
		box.add_child(UiKit.label(line, 17))
	var note := UiKit.label(T.t("res_demo_end"), 15, UiKit.TEXT_DIM)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)
	var back := UiKit.button(T.t("res_back"))
	back.pressed.connect(quit_to_menu)
	box.add_child(back)
	back.grab_focus.call_deferred()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# --- pause menu host interface ------------------------------------------------------------------------------------

func pause_notes() -> Array:
	return notes.entries()


func can_retry() -> bool:
	return phase in ["containment", "run"] and checkpoint_index >= 0 and _caught_left <= 0.0


func retry_from_checkpoint() -> void:
	if can_retry():
		_log("retry", "from pause menu")
		_restore_checkpoint()


func quit_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)


# --- scanner ----------------------------------------------------------------------------------------------------

func _build_scan_parts() -> void:
	var glow: Material = building.b.flat(GamePalette.color("info"), 0.3, 0.0, 2.4)
	# Continuity A -> T: the bridge, both terminals and the cable that climbs from T to the column's trial node.
	_scan_parts.append(building.b.visual("ScanBridge", Vector3(2.7, 0.06, 0.16), Vector3(21.5, Building.Y_P1 + 0.62, 4.2), glow, false))
	_scan_parts.append(building.b.visual("ScanTerminalA", Vector3(0.55, 0.06, 0.45), Vector3(20.2, Building.Y_P1 + 0.72, 4.2), glow, false))
	_scan_parts.append(building.b.visual("ScanTerminalT", Vector3(0.55, 0.06, 0.45), Vector3(22.8, Building.Y_P1 + 0.72, 4.2), glow, false))
	_scan_parts.append(building.b.visual("ScanSchematicA", Vector3(0.05, 0.08, 2.0), Vector3(27.88, Building.Y_P1 + 0.58, 2.9), glow, false))
	_scan_parts.append(building.b.visual("ScanTRiser", Vector3(0.08, 2.2, 0.08), Vector3(22.8, Building.Y_P1 + 1.8, 1.05), glow, false))
	_scan_parts.append(building.b.screen_text("ScanBridgeLabel", T.t("scan_bridge_label"), Vector3(21.5, Building.Y_P1 + 1.35, 4.45), "+z", 22, GamePalette.color("info")))
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
			if phase == "investigation" and player.global_position.y < -1.0 and player.global_position.distance_to(Building.BRIDGE_AT) < 7.0:
				notes.add("scan_bridge")
				if notes.has("schematic") and not _said.has("N1-02"):
					_say("N1-02", T.t("line_n1_02"), 3.5)
	else:
		_scan_charge = 0.0


## Reveals continuity and, during Containment, where the unit is and what it can see.
## It never marks a control or a correct action.
func _set_scan(on: bool) -> void:
	for part in _scan_parts:
		part.visible = on and phase == "investigation"
	if unit != null:
		unit.call("set_revealed", on)
	if on and phase == "investigation":
		hud.call("show_banner", T.t("ban_scan_title"), T.t("ban_scan_body"), GamePalette.color("info"), SCAN_REVEAL_TIME)
	elif on:
		hud.call("show_banner", T.t("ban_scan_unit_title"), T.t("ban_scan_unit_body"), GamePalette.color("info"), SCAN_REVEAL_TIME)


# --- field notes, hints, state fixtures and text ------------------------------------------------------------------

func _on_note(id: String, kind: String) -> void:
	_log("note", "%s (%s)" % [id, kind])
	if phase == "intro" or id == "anomaly":
		return
	_sound("note")
	var title := T.t("note_%s_title" % id)
	if kind == "inference":
		_banner(T.t("ban_inference_" + id), title, "info", 5.0)
	hud.call("show_note", T.t("hud_note_added", {"title": title}))


func _hint_stage_now() -> String:
	if in_yard:
		return "yard"
	if phase != "investigation":
		return "escape"
	if mission.restricted_record_read:
		return "leave"
	if bool(circuit.outputs()["archive"]):
		return "record"
	if circuit.maintenance_on and player.global_position.y > 5.0:
		return "circuit"
	if notes.has("hypothesis") or notes.has("schematic"):
		return "lift" if not circuit.maintenance_on else "circuit"
	return "explore"


## Hints follow where the player is in the investigation, from general to specific. They explain relationships;
## they never name the control to press or the full sequence.
func _show_hint() -> void:
	var stage := _hint_stage_now()
	if stage != _hint_stage:
		_hint_stage = stage
		_hint_step = 0
	var ladder: Array = HINTS[stage]
	var i := mini(_hint_step, ladder.size() - 1)
	_hint_step += 1
	hints_used += 1
	var text := T.t(str(ladder[i]), {"scan": HudScript.action_label("scan"), "crouch": HudScript.action_label("crouch")})
	subtitles.call("show_message", T.t("hint_prefix", {"i": i + 1, "n": ladder.size()}) + text, 8.0)
	_log("hint", "%s %d" % [stage, i + 1])


func _diagnostic_text() -> String:
	var info: Dictionary = circuit.inspect()
	var current := T.t("diag_archive_none")
	match str(info["current"]):
		"ARCHIVE_STABLE":
			current = T.t("diag_archive_stable")
		"RECOVERY_TRIPPED_FAULT_PRESENT":
			current = T.t("diag_tripped_fault")
		"RECOVERY_TRIPPED_REARM_PENDING":
			current = T.t("diag_tripped_rearm")
	return T.t("diag_body", {"current": current, "destination": _dest(str(info["destination"])),
		"trial": T.t("diag_isolated" if circuit.trial_isolated else "diag_connected"),
		"trip": T.t("diag_trip_double" if str(info["last_trip"]) != "" else "diag_trip_none")})


func _refresh_state_fixtures() -> void:
	if building == null:
		return
	var info: Dictionary = circuit.inspect()
	var out: Dictionary = circuit.outputs()
	var current := T.t("diag_archive_none")
	match str(info["current"]):
		"ARCHIVE_STABLE":
			current = T.t("diag_archive_stable")
		"RECOVERY_TRIPPED_FAULT_PRESENT":
			current = T.t("diag_tripped_fault")
		"RECOVERY_TRIPPED_REARM_PENDING":
			current = T.t("diag_tripped_rearm")
	building.panel_text.text = T.t("panel_body", {"current": current, "destination": _dest(str(info["destination"])),
		"trial": T.t("panel_isolated" if circuit.trial_isolated else "panel_connected"),
		"protection": T.t("panel_available" if circuit.protection_available else "panel_tripped"),
		"trip": T.t("diag_trip_double" if str(info["last_trip"]) != "" else "panel_trip_none")})
	building.indicator_text.text = T.t("indicator", {
		"archive": T.t("ind_archive_on" if bool(out["archive"]) else "ind_archive_off"),
		"trial": T.t("ind_trial_on" if bool(out["trial"]) else "ind_trial_off")})
	if not mission.restricted_record_read:
		building.archive_text.text = T.t("archive_screen_on" if bool(out["archive"]) else "archive_screen_off")
	if bool(out["archive"]) and phase == "investigation":
		notes.add("archive_stable", "event")
	# Column rings (position + panel text are the non-colour cues): maintenance, archive supply, protection.
	var rings: Array = building.column_rings
	(rings[0] as MeshInstance3D).material_override = building.b.flat(Color(0.75, 0.9, 1.0) if circuit.maintenance_on else GamePalette.color("neutral"), 0.4, 0.2, 1.8 if circuit.maintenance_on else 0.0)
	(rings[1] as MeshInstance3D).material_override = building.b.flat(GamePalette.color("ok") if bool(out["archive"]) else GamePalette.color("neutral"), 0.4, 0.2, 1.8 if bool(out["archive"]) else 0.0)
	(rings[2] as MeshInstance3D).material_override = building.b.flat(GamePalette.color("danger") if not circuit.protection_available else GamePalette.color("neutral"), 0.4, 0.2, 2.2 if not circuit.protection_available else 0.0)
	building.switch_lamp.material_override = building.b.flat(GamePalette.color("ok") if circuit.maintenance_on else GamePalette.color("danger"), 0.4, 0.0, 1.5)
	for lamp in building.pump_lamps:
		lamp.material_override = building.b.flat(GamePalette.color("ok") if circuit.maintenance_on else Color(0.2, 0.2, 0.2), 0.4, 0.0, 1.4 if circuit.maintenance_on else 0.0)


## The facility's own labels are Spanish (diegetic); other languages show the translation next to them.
func _dest(value: String) -> String:
	return T.t("dest_" + value.to_lower())


func _refresh_lift_gates() -> void:
	if building == null or lift == null:
		return
	var open: Dictionary = lift.gates_open()
	for pair in [[building.lift_gate_lower, bool(open["south"])], [building.lift_gate_upper, bool(open["north"])]]:
		var gate: StaticBody3D = pair[0]
		(gate.get_child(0) as CollisionShape3D).set_deferred("disabled", pair[1])
		(gate.get_child(1) as MeshInstance3D).visible = not pair[1]


func _set_objective(text: String) -> void:
	if hud != null:
		hud.call("set_objective", "OBJETIVO  /  " + text)


func _banner(title: String, body: String, role: String, seconds: float) -> void:
	if hud != null:
		hud.call("show_banner", title, body, GamePalette.color(role), seconds)


func _fmt(p: Vector3) -> String:
	return "(%.1f, %.1f, %.1f)" % [p.x, p.y, p.z]


func _log(id: String, detail: String = "") -> void:
	print("[phase1 %.1fs] %s %s" % [Time.get_ticks_msec() / 1000.0, id, detail])
