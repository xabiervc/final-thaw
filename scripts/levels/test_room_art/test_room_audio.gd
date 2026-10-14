extends Node3D
## Soundscape for the Helix test bay (presentation only; listens to the room's signals, never drives gameplay).
##
## Layers: room tone (always), generator alarm pip from the generator while unpowered, generator hum once power is
## restored, and one-shots for terminal, doors (open / denied), lever, power up/down, scanning, inspecting,
## footsteps, landings and room completion. All sounds come from sfx_synth.gd (original, deterministic).
## Nothing is communicated by sound alone: every cue has a visible counterpart (lights, door motion, HUD banner).

const Synth := preload("res://scripts/audio/sfx_synth.gd")

const ROOM_TONE_DB := -17.0
const HUM_DB := -6.0
const ALARM_DB := -16.0
const ONE_SHOT_DB := -6.0
const STEP_DB := -15.0
const STEP_STRIDE := 0.62  # metres between footsteps at walking speed
const STEP_ORDER := [0, 2, 1, 3]  # fixed variant cycle (cosmetic variation, deterministic)
const GENERATOR_POS := Vector3(5.55, 1.4, -7.4)

var room: Node3D = null

var _streams: Dictionary = {}
var _players: Dictionary = {}
var _hum: AudioStreamPlayer3D = null
var _alarm: AudioStreamPlayer3D = null
var _step_players: Array[AudioStreamPlayer] = []
var _step_index: int = 0
var _step_distance: float = 0.0
var _air_time: float = 0.0
var _was_completed: bool = false


func _ready() -> void:
	name = "RoomAudio"
	_streams = {
		"terminal": Synth.terminal_beep(), "denied": Synth.denied(), "door": Synth.door_open(),
		"lever": Synth.lever_clunk(), "power_up": Synth.power_up(), "power_down": Synth.power_down(),
		"scan": Synth.scan_pulse(), "inspect": Synth.inspect_tick(), "land": Synth.land(),
		"complete": Synth.complete_chime(),
	}
	for key in _streams:
		var p := AudioStreamPlayer.new()
		p.name = "Sfx_%s" % key
		p.stream = _streams[key]
		p.volume_db = ONE_SHOT_DB
		add_child(p)
		_players[key] = p
	for v in 4:
		var sp := AudioStreamPlayer.new()
		sp.name = "Step%d" % v
		sp.stream = Synth.footstep(v)
		sp.volume_db = STEP_DB
		add_child(sp)
		_step_players.append(sp)
	var tone := AudioStreamPlayer.new()
	tone.name = "RoomTone"
	tone.stream = Synth.room_tone()
	tone.volume_db = ROOM_TONE_DB
	tone.autoplay = true
	add_child(tone)
	_hum = _positional("GeneratorHum", Synth.generator_hum(), HUM_DB)
	_alarm = _positional("GeneratorAlarm", Synth.alarm_pip(), ALARM_DB)
	_connect_room()


func _positional(player_name: String, stream: AudioStream, db: float) -> AudioStreamPlayer3D:
	var p := AudioStreamPlayer3D.new()
	p.name = player_name
	p.stream = stream
	p.volume_db = db
	p.unit_size = 9.0
	p.max_distance = 30.0
	p.position = GENERATOR_POS
	add_child(p)
	return p


func _connect_room() -> void:
	if room == null:
		return
	var terminal = room.get("terminal")
	if terminal != null:
		terminal.interacted.connect(func(_a): play("terminal"))
	for key in ["door_a", "door"]:
		var d = room.get(key)
		if d != null:
			d.opened.connect(func(): play("door"))
			d.interacted.connect(func(_a): if bool(d.get("locked")) and not bool(d.get("is_open")): play("denied"))
	var lever = room.get("lever")
	if lever != null:
		lever.toggled.connect(_on_lever_toggled)
		_set_generator(bool(lever.get("is_on")))
	for n in get_tree().get_nodes_in_group("interactables"):
		var script := (n as Node).get_script() as Script
		if script != null and script.resource_path.get_file() == "inspect_point.gd":
			n.interacted.connect(func(_a): play("inspect"))
	var elena = room.get("elena")
	if elena != null:
		elena.jumped.connect(func(): _air_time = 0.0)


func play(key: String) -> void:
	var p := _players.get(key) as AudioStreamPlayer
	if p != null:
		p.play()


func _on_lever_toggled(on: bool) -> void:
	if bool(room.get("_loading")):
		_set_generator(on)
		return
	play("lever")
	play("power_up" if on else "power_down")
	_set_generator(on)


func _set_generator(on: bool) -> void:
	if on:
		_alarm.stop()
		if not _hum.playing:
			_hum.play()
	else:
		_hum.stop()
		if not _alarm.playing:
			_alarm.play()


func is_generator_running() -> bool:
	return _hum.playing


func _unhandled_input(event: InputEvent) -> void:
	if room == null:
		return
	var elena = room.get("elena")
	if event.is_action_pressed("scan") and not event.is_echo() and elena != null and bool(elena.get("input_enabled")):
		play("scan")


func _physics_process(delta: float) -> void:
	if room == null:
		return
	var elena = room.get("elena") as CharacterBody3D
	if elena == null:
		return
	if elena.is_on_floor():
		if _air_time > 0.25:
			play("land")
			_step_distance = 0.0
		_air_time = 0.0
		var speed := Vector2(elena.velocity.x, elena.velocity.z).length()
		if speed > 0.8:
			_step_distance += speed * delta
			if _step_distance >= STEP_STRIDE:
				_step_distance = 0.0
				_step_players[STEP_ORDER[_step_index]].play()
				_step_index = (_step_index + 1) % STEP_ORDER.size()
		else:
			_step_distance = STEP_STRIDE * 0.7  # the first step lands promptly when Elena starts moving
	else:
		_air_time += delta
	var completed := bool(room.get("completed"))
	if completed and not _was_completed:
		play("complete")
	_was_completed = completed
