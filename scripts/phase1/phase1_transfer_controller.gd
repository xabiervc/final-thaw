extends RefCounted
## Scene-side owner of the expanded Phase 1 chains (docs/design/fase1_fase2_mapa_progresion.md v2.1): it turns the model in
## phase1_transfer_state.gd into hotspots, banners, field notes, sound and the animated fixtures of phase1_expansion.gd.
## The canonical scene (phase1_canonical_greybox.gd) owns one instance and forwards its hotspot/interact/refresh calls.
##
## Boundaries that must hold (tests/test_phase1_transfer_chain.gd):
##  - Nothing here touches the circuit model, the protection history, SERVICE_OVERRIDE or the Aster field-note derivations.
##    The restricted record is only READ from the mission state (RESTRICTED_RECORD_READ); it is never written here.
##  - The lift is powered by the auxiliary supply AND the Aster maintenance switch (see update_lift()).
##  - Nothing is granted by a shortcut: items come from the drawer and the dry cabinet, power from the disconnector,
##    the door from its four prerequisites. The only seams are the explicit test methods at the end of this file.

const T := preload("res://scripts/game/game_text.gd")
const State := preload("res://scripts/phase1/phase1_transfer_state.gd")
const Expansion := preload("res://scripts/phase1/phase1_expansion.gd")
const Synth := preload("res://scripts/audio/sfx_synth.gd")
const GSynth := preload("res://scripts/audio/game_synth.gd")
const LockPanel := preload("res://scripts/ui/code_lock_panel.gd")

## After crossing the transfer door Elena has this long in the vestibule before the staff notice her (seconds), and the
## radius around the bay door that makes them notice her at once. Both are deterministic: no hidden randomness.
const OBSERVE_TIME := 22.0
const BAY_DOOR_AT := Vector2(31.2, 19.8)
const BAY_DOOR_RADIUS := 2.3
const FIRST_LINE_DELAY := 0.8
const SECOND_LINE_DELAY := 6.0

var host = null                  # the canonical scene
var state = State.new()
var fx = null                    # Expansion (host.building.expansion)
var lock = null                  # CodeLockPanel
var crossed: bool = false        # Elena is inside the second building (Phase 1 -> Phase 2 threshold)
var detected: bool = false       # the staff noticed her (the escape begins)
var in_vestibule_time: float = 0.0
var _lines_said: Dictionary = {}
var _hum: AudioStreamPlayer3D
var _pump_audio: AudioStreamPlayer3D
var _draught: AudioStreamPlayer3D
var _active_hum: AudioStreamPlayer3D
var _player_was_enabled: bool = true


func setup(scene) -> void:
	host = scene
	fx = host.building.expansion
	lock = LockPanel.new()
	lock.name = "DrawerLock"
	host.add_child(lock)
	lock.submitted.connect(_on_code)
	lock.cancelled.connect(_on_lock_cancelled)
	_build_audio()
	fx.start_streamer(host)
	refresh()


func _build_audio() -> void:
	_hum = _player3d(Synth.generator_hum(), Vector3(20.7, Expansion.Y_B2 + 1.2, 14.45), 5.0, 16.0, -9.0)
	_pump_audio = _player3d(Synth.generator_hum(), Vector3(21.6, Expansion.Y_B2 + 0.8, 9.55), 4.0, 12.0, -11.0)
	_pump_audio.pitch_scale = 1.6
	# The draught from the concealed joint: a very quiet loop, only audible close to the east wall of the dead workshop.
	_draught = _player3d(GSynth.exterior_wind(), Vector3(Expansion.TRANSFER_X - 0.4, Expansion.Y_B2 + 1.0, 17.2), 2.2, 7.0, -17.0)
	_draught.play()
	_active_hum = _player3d(Synth.generator_hum(), Vector3(33.0, Expansion.Y_B2 + 1.6, 17.0), 5.0, 18.0, -13.0)
	_active_hum.pitch_scale = 0.8


func _player3d(stream: AudioStream, at: Vector3, unit_size: float, max_distance: float, volume_db: float) -> AudioStreamPlayer3D:
	var p := AudioStreamPlayer3D.new()
	p.stream = stream
	p.bus = "SFX"
	p.unit_size = unit_size
	p.max_distance = max_distance
	p.volume_db = volume_db
	p.position = at
	host.add_child(p)
	return p


## True while the code lock is open: the scene must not run its own interactions then.
func modal_open() -> bool:
	return lock != null and (lock.is_open or lock.recently_closed())


# --- hotspots ---------------------------------------------------------------------------------------------------------------

func hotspots() -> Array:
	var drawer_verb := "verb_enter_code"
	if state.drawer_open:
		drawer_verb = "verb_examine" if state.drawer_emptied else "verb_take"
	var door_verb := "verb_unlock" if state.has_item(State.SERVICE_KEY) else "verb_examine"
	var terminal_verb := "verb_insert" if (state.has_item(State.INSULATED_BRIDGE) and not state.bridge_inserted) else "verb_examine"
	return [
		{"id": "shift_board", "at": Expansion.BOARD_AT, "verb": "verb_read", "name": "hs_shift_board"},
		{"id": "pressure_strip", "at": Expansion.STRIP_AT, "verb": "verb_read", "name": "hs_pressure_strip"},
		{"id": "dispatch_note", "at": Expansion.DISPATCH_NOTE_AT, "verb": "verb_read", "name": "hs_dispatch_note"},
		{"id": "drawer", "at": Expansion.DRAWER_AT, "verb": drawer_verb, "name": "hs_drawer"},
		{"id": "substation_door", "at": Expansion.SUBSTATION_DOOR_AT, "verb": door_verb, "name": "hs_substation_door"},
		{"id": "terminal", "at": Expansion.TERMINAL_AT, "verb": terminal_verb, "name": "hs_terminal"},
		{"id": "disconnector", "at": Expansion.DISCONNECTOR_AT, "verb": "verb_operate", "name": "hs_disconnector"},
		{"id": "aux_pump", "at": Expansion.AUX_PUMP_AT, "verb": "verb_examine", "name": "hs_aux_pump"},
		{"id": "wet_locker", "at": Expansion.LOCKER_AT, "verb": "verb_examine", "name": "hs_wet_locker"},
		{"id": "dry_cabinet", "at": Expansion.CABINET_AT, "verb": "verb_examine" if state.cabinet_opened else "verb_open", "name": "hs_dry_cabinet"},
		{"id": "wall_seam", "at": Expansion.SEAM_AT, "verb": "verb_examine", "name": "hs_wall_seam"},
		{"id": "maintenance_note", "at": Expansion.NOTE_AT, "verb": "verb_read", "name": "hs_maintenance_note"},
		{"id": "transfer_door", "at": Expansion.SEAM_AT, "verb": "verb_use", "name": "hs_transfer_door"},
		{"id": "bay_window", "at": Expansion.WINDOW_AT, "verb": "verb_examine", "name": "hs_bay_window"},
	]


## Which of the controller's hotspots are on offer now (the scene asks only about ids this controller owns).
func owns(id: String) -> bool:
	for h in hotspots():
		if str(h["id"]) == id:
			return true
	return false


func available(id: String) -> bool:
	if modal_open():
		return false
	match id:
		"substation_door":
			return not state.substation_unlocked
		"terminal", "disconnector":
			return state.substation_unlocked
		"wall_seam":
			return not state.hidden_door_discovered
		"transfer_door":
			return state.hidden_door_discovered and not state.transfer_door_open
		"bay_window":
			return state.transfer_door_open
	return true


func interact(id: String) -> bool:
	match id:
		"shift_board":
			_show("ex_shift_board_title", "ex_shift_board_body", "info", "shift_order")
		"pressure_strip":
			_show("ex_pressure_strip_title", "ex_pressure_strip_body", "info", "pressure_values")
		"dispatch_note":
			_show("ex_dispatch_note_title", "ex_dispatch_note_body", "info")
		"drawer":
			_use_drawer()
		"substation_door":
			_use_substation_door()
		"terminal":
			_use_terminal()
		"disconnector":
			_use_disconnector()
		"aux_pump":
			_show("ex_aux_pump_title", "ex_aux_pump_body", "info")
		"wet_locker":
			_show("ex_wet_locker_title", "ex_wet_locker_body", "info")
		"dry_cabinet":
			_use_cabinet()
		"wall_seam":
			_use_seam()
		"maintenance_note":
			state.read_maintenance_note()
			_show("ex_maint_note_title", "ex_maint_note_body", "warn", "maintenance_note")
		"transfer_door":
			_use_transfer_door()
		"bay_window":
			_show("ex_window_title", "ex_window_body", "warn", "second_building")
		_:
			return false
	return true


# --- feedback helpers ---------------------------------------------------------------------------------------------------------

func _show(title_key: String, body_key: String, role: String, note_id: String = "") -> void:
	host._sound("tick")
	host._banner(T.t(title_key), T.t(body_key), role, 7.0)
	if note_id != "":
		host.notes.add(note_id)
	host._log("clue", title_key)


func _banner(title_key: String, body: String, role: String, seconds: float = 6.0) -> void:
	host._banner(T.t(title_key), body, role, seconds)


# --- chain A: drawer, substation, power -------------------------------------------------------------------------------------------

func _use_drawer() -> void:
	if not state.drawer_open:
		_open_lock()
		return
	var got: Array[String] = state.take_drawer_items()
	if got.is_empty():
		host._sound("tick")
		_banner("hs_drawer", T.t("ban_drawer_empty_body"), "info", 3.0)
		return
	fx.empty_drawer()
	host._sound("clunk")
	_banner("ban_drawer_take_title", T.t("ban_drawer_take_body"), "ok", 5.0)
	host._log("items", "SERVICE_KEY + INSULATED_BRIDGE")
	refresh()


func _open_lock() -> void:
	_player_was_enabled = bool(host.player.get("input_enabled"))
	host.player.set("input_enabled", false)
	host.player.velocity = Vector3.ZERO
	lock.open()
	host._sound("beep")


func _on_lock_cancelled() -> void:
	_unfreeze()


func _unfreeze() -> void:
	if host != null and host.player != null:
		host.player.set("input_enabled", _player_was_enabled)


## The lock panel submitted a code. The model decides; the panel only reports.
func _on_code(code: String) -> void:
	var result: String = state.try_drawer_code(code)
	host._log("drawer", "%s (%s)" % [result, code])
	match result:
		"ok":
			lock.show_status(T.t("ban_drawer_open_title"))
			lock.close()
			_unfreeze()
			fx.open_drawer(host)
			host._sound("clunk")
			host.get_tree().create_timer(0.35).timeout.connect(func():
				if is_instance_valid(host):
					host._sound("door"))
			_banner("ban_drawer_open_title", T.t("ban_drawer_open_body"), "ok", 7.0)
			host.notes.add("drawer_open", "event")
			refresh()
		"wrong":
			host._sound("denied")
			lock.show_status(T.t("ban_drawer_wrong_title") + ": " + T.t("ban_drawer_wrong_body"))
		_:
			host._sound("denied")


func _use_substation_door() -> void:
	var result: String = state.try_unlock_substation()
	host._log("substation", result)
	if result == "no_key":
		host._sound("denied")
		_banner("ban_sub_locked_title", T.t("ban_sub_locked_body"), "warn", 5.0)
	elif result == "ok":
		fx.open_substation_door(host)
		host._sound("door")
		_banner("ban_sub_open_title", T.t("ban_sub_open_body"), "ok", 5.0)
		refresh()


func _use_terminal() -> void:
	if state.has_item(State.INSULATED_BRIDGE) and not state.bridge_inserted:
		var result: String = state.try_insert_bridge()
		host._log("terminal", result)
		if result == "ok":
			fx.insert_bridge()
			host._sound("clunk")
			_banner("ban_bridge_ok_title", T.t("ban_bridge_ok_body"), "ok", 6.0)
			refresh()
		return
	var body := T.t("ex_terminal_body")
	if not state.bridge_inserted and not state.has_item(State.INSULATED_BRIDGE):
		body += "\n" + T.t("ex_terminal_nobridge")
	host._sound("tick")
	host._banner(T.t("ex_terminal_title"), body, "info", 7.0)


func _use_disconnector() -> void:
	var result: String = state.try_throw_disconnector()
	host._log("disconnector", result)
	match result:
		"open_circuit":
			host._sound("denied")
			_banner("ban_disc_blocked_title", T.t("ban_disc_blocked_body"), "warn", 5.0)
		"restored":
			_power_restored()


## PowerRestored: relays, transformer hum, lights by sectors, the auxiliary pump and the lift indicator. Aster's own state
## machine is not touched; the lift is the only meeting point (it needs the maintenance circuit as well).
func _power_restored() -> void:
	fx.throw_disconnector(host)
	fx.energize_lights(host)
	fx.start_pump_vibration(host)
	host._sound("power_up")
	for delay in [0.3, 0.75, 1.2]:
		host.get_tree().create_timer(delay).timeout.connect(func():
			if is_instance_valid(host):
				host._sound("clunk"))
	_hum.play()
	_pump_audio.play()
	update_lift()
	var body := T.t("ban_power_body")
	if not host.circuit.maintenance_on:
		body += " " + T.t("ban_power_lift_maint")
	_banner("ban_power_title", body, "ok", 9.0)
	host.notes.add("aux_power", "event")
	host._log("mission", "PowerRestored")
	if host.circuit.maintenance_on and not host.mission.restricted_record_read:
		host._set_objective(T.t("obj_go_control"))
	elif not host.mission.restricted_record_read:
		host._set_objective(T.t("obj_aux_restored"))
	refresh()


## The lift runs only with the auxiliary supply and the Aster maintenance switch together.
func update_lift() -> void:
	var on: bool = state.lift_powered(host.circuit.maintenance_on)
	host.lift.set_powered(on)
	fx.set_lift_indicator(on)


# --- chain B: seam, note, cabinet, door ---------------------------------------------------------------------------------------------

func _use_seam() -> void:
	if state.discover_hidden_door():
		fx.reveal_hidden_door(host)
		host._sound("clunk")
		host._banner(T.t("ex_seam_title"), T.t("ex_seam_body"), "warn", 9.0)
		host.notes.add("hidden_door", "event")
		host._log("mission", "HiddenDoorDiscovered")
		refresh()


func _use_cabinet() -> void:
	if state.cabinet_opened:
		host._sound("tick")
		_banner("hs_dry_cabinet", T.t("ex_cabinet_done_body"), "info", 3.5)
		return
	if state.try_open_dry_cabinet() == "ok":
		fx.open_cabinet(host)
		host._sound("door")
		_banner("ban_cabinet_title", T.t("ban_cabinet_body"), "ok", 8.0)
		host.notes.add("transfer_key", "event")
		host._log("items", "TRANSFER_KEY")
		host.get_tree().create_timer(1.4).timeout.connect(func():
			if is_instance_valid(host):
				fx.take_cabinet_key())
		refresh()


## "KEY: OK / POWER: MISSING / ..." as words, so the state is never carried by colour alone.
func door_checklist() -> String:
	var record: bool = host.mission.restricted_record_read
	var rows: Array[String] = []
	for entry in [["door_item_key", state.has_item(State.TRANSFER_KEY)], ["door_item_power", state.power_restored], ["door_item_record", record]]:
		rows.append("%s: %s" % [T.t(str(entry[0])), T.t("door_state_ok" if bool(entry[1]) else "door_state_missing")])
	return "\n".join(PackedStringArray(rows))


func _use_transfer_door() -> void:
	var record: bool = host.mission.restricted_record_read
	var result: String = state.try_open_transfer_door(record)
	host._log("transfer_door", result)
	if result == "ok":
		_open_transfer()
	elif result != "already":
		host._sound("denied")
		host._banner(T.t("ban_door_locked_title"), T.t("ban_door_locked_body", {"list": door_checklist()}), "warn", 9.0)
		refresh()


func _open_transfer() -> void:
	fx.open_transfer_door(host)
	fx.light_active_building(host)
	_active_hum.play()
	host._sound("door")
	_banner("ban_door_open_title", T.t("ban_door_open_body"), "ok", 8.0)
	host._log("mission", "TRANSFER_DOOR_OPEN")
	host.music.set_mode("tension")
	refresh()


# --- the threshold: crossing, observing, being noticed ---------------------------------------------------------------------------------

## Called every physics frame while Elena investigates. The vestibule is the Phase 1 -> Phase 2 threshold: crossing it closes
## the investigation; the staff notice her after OBSERVE_TIME or as soon as she nears the bay door.
func process(delta: float) -> void:
	if not state.transfer_door_open or detected:
		return
	var p: Vector3 = host.player.global_position
	var inside: bool = Expansion.VESTIBULE.grow(-0.2).has_point(Vector2(p.x, p.z)) and p.y < -3.0
	if not crossed:
		if inside:
			crossed = true
			in_vestibule_time = 0.0
			host.notes.add("second_building", "event")
			host._set_objective(T.t("obj_observe"))
			host._log("mission", "CROSSED into the second building")
		return
	if not inside:
		return  # the staff can only notice her while she is in their vestibule
	in_vestibule_time += delta
	if in_vestibule_time >= FIRST_LINE_DELAY and not _lines_said.has("1"):
		_lines_said["1"] = true
		host._say("staff_1", T.t("line_staff_1"), 5.0)
	if in_vestibule_time >= SECOND_LINE_DELAY and not _lines_said.has("2"):
		_lines_said["2"] = true
		host._say("staff_2", T.t("line_staff_2"), 4.0)
	var near_bay := Vector2(p.x, p.z).distance_to(BAY_DOOR_AT) < BAY_DOOR_RADIUS
	if in_vestibule_time >= OBSERVE_TIME or near_bay:
		_noticed()


func _noticed() -> void:
	if detected:
		return
	detected = true
	host._say("staff_3", T.t("line_staff_3"), 4.0)
	fx.open_bay_door(host)
	host.begin_transfer_containment()


# --- display state ---------------------------------------------------------------------------------------------------------------------

## Keeps every visible fixture equal to the model: reader text and lamp, lift indicator and the lift's own power.
func refresh() -> void:
	if fx == null or host == null:
		return
	var record: bool = host.mission.restricted_record_read
	var key_ok := state.has_item(State.TRANSFER_KEY)
	var parts := {"key": T.t("reader_ok" if key_ok else "reader_missing"), "power": T.t("reader_ok" if state.power_restored else "reader_missing"),
		"record": T.t("reader_ok" if record else "reader_missing")}
	var lamp := Color(0.95, 0.2, 0.1)
	if key_ok and state.power_restored and record:
		lamp = Color(0.98, 0.72, 0.2)
	if state.transfer_door_open:
		lamp = Color(0.3, 0.95, 0.45)
	fx.set_reader(T.t("reader_body", parts).split("\n"), lamp)
	update_lift()


## Stage of the hint ladder the chain is in (the scene merges it with the Aster stages).
func hint_stage(maintenance_on: bool) -> String:
	if host.mission.restricted_record_read and not state.transfer_door_open:
		return "transfer"
	if maintenance_on and not state.power_restored:
		return "aux"
	return ""


# --- test seams (explicit, named, never used by the game) ---------------------------------------------------------------------------------

## The whole auxiliary-power chain as a player leaves it (drawer emptied, substation open, bridge fitted, disconnector closed),
## without walking it. For tests that start from "investigation under way"; the chain itself is tested step by step elsewhere.
func complete_power_chain_for_test() -> void:
	apply_state_for_test({"DRAWER_OPEN": true, "DRAWER_EMPTIED": true, "SUBSTATION_UNLOCKED": true, "BRIDGE_INSERTED": true, "PowerRestored": true})


## Applies a complete saved/starting state without animation. Used by tests that need the end state of a chain.
func apply_state_for_test(snapshot: Dictionary) -> void:
	state.from_dict(snapshot)
	if state.drawer_open:
		fx.open_drawer(host, true)
		if state.drawer_emptied:
			fx.empty_drawer()
	if state.substation_unlocked:
		fx.open_substation_door(host, true)
	if state.bridge_inserted:
		fx.insert_bridge()
	if state.power_restored:
		fx.throw_disconnector(host, true)
		fx.energize_lights(host, true)
	if state.hidden_door_discovered:
		fx.reveal_hidden_door(host, true)
	if state.cabinet_opened:
		fx.open_cabinet(host, true)
		fx.take_cabinet_key()
	if state.transfer_door_open:
		fx.open_transfer_door(host, true)
		fx.light_active_building(host, true)
	refresh()
