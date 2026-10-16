extends Node
## The new end of Phase 1, walked with the real body and the real input actions (tests/support/route_bot.gd): from the start
## of play through the shift archive, the code lock, the stair to P-2, the dead workshop FIRST (the door is found before the key
## and before the power), the spares store, the substation, back to the door, across the threshold into the second building,
## observed, noticed, and out again: gallery, stair, south band, S1, the pit, the evacuation gallery, the yard, the north gate
## and the ending. Elena is never moved by the test. The recovery unit is disabled here (its chase of this route is
## tests/test_phase1_transfer_escape.gd); the Aster prerequisites (maintenance and the restricted record) are set through
## the real handlers, because the physical walk to control and the archive is tests/test_phase1_playthrough.gd.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_transfer_route.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const RouteBot := preload("res://tests/support/route_bot.gd")
const State := preload("res://scripts/phase1/phase1_transfer_state.gd")
const CircuitModel := preload("res://scripts/prototypes/phase1_circuit_model.gd")

var passed := 0
var failed := 0
var scene: Node3D
var bot
var results_seen: Dictionary = {}


func _ready() -> void:
	get_tree().create_timer(900.0).timeout.connect(func(): push_error("transfer route watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _leg(result: Dictionary) -> bool:
	_expect(bool(result["ok"]), "%s%s" % [result["label"], "" if result["ok"] else " -> %s %s" % [result.get("kind", ""), result.get("detail", "")]])
	return bool(result["ok"])


## A walk that must be refused by the world: the bot ends STUCK or TIMEOUT short of the target.
func _blocked(label: String, target: Vector3, max_reach: float, axis: String = "x") -> void:
	var result: Dictionary = await bot.walk(label, [target], {"min_y": -4.6, "timeout": 5.0})
	var coordinate: float = scene.player.global_position.x if axis == "x" else scene.player.global_position.z
	var held: bool = not bool(result["ok"]) and str(result.get("kind", "")) in ["STUCK", "TIMEOUT"]
	_expect(held and (coordinate < max_reach if axis == "x" else coordinate < max_reach), "%s (stopped at %s)" % [label, scene.player.global_position])


func _key(action: String) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	await get_tree().physics_frame
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event(up)
	await get_tree().physics_frame


func _enter_code(code: String) -> void:
	var lock = scene.transfer.lock
	for i in 4:
		while lock.index != i:
			await _key("move_right")
		var target := int(code[i])
		while lock.digits[i] != target:
			await _key("move_up" if (target - lock.digits[i] + 10) % 10 <= 5 else "move_down")
	await _key("interact")


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	scene.set("spawn_unit_enabled", false)
	scene.set("ending_override", func(r): results_seen = r)
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame
	bot = RouteBot.new()
	add_child(bot)
	bot.player = scene.player
	bot.before_step = func(): scene.player.set("orbit_yaw", 0.0)
	var ok: bool = await _prerequisites_and_drawer() and await _down_and_door_first() and await _spares_and_back() and await _substation() and await _cross() and await _escape()
	bot.release_all()
	_expect(ok, "END: the transfer route was walked from the first room to the ending without teleporting Elena")
	print("Phase 1 transfer route: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _prerequisites_and_drawer() -> bool:
	# The Aster side through the real handlers: maintenance ON (queues the audit, powers the pit's circuit) and the record read.
	scene.call("_toggle_maintenance")
	scene.circuit.set_isolated(true)
	scene.circuit.select_destination(CircuitModel.ARCHIVE)
	scene.call("_consult_archive")
	_expect(scene.mission.restricted_record_read and scene.circuit.maintenance_on and not scene.lift.powered, "Aster side done (maintenance ON, record read); the lift is still dead without the auxiliary supply")
	if not _leg(await bot.walk("tunnel -> A -> the north-west rooms", [Vector3(-0.5, 0, 6), Vector3(3, 0, 6.5), Vector3(6.2, 0, 6.8), Vector3(6.8, 0, 3.0), Vector3(6.8, 0, -2.0), Vector3(1.8, 0, -4.3), Vector3(1.8, 0, -6.0), Vector3(1.8, 0, -8.4)], {"min_y": -0.5})):
		return false
	await bot.interact("shift board")
	if not _leg(await bot.walk("board -> recorder", [Vector3(1.15, 0, -6.4)], {"min_y": -0.5})):
		return false
	await bot.interact("pressure recorder")
	_expect(scene.notes.has("shift_order") and scene.notes.has("pressure_values"), "both clues read, one at each end of the archive")
	if not _leg(await bot.walk("archive -> dispatch -> drawer", [Vector3(1.8, 0, -5.8), Vector3(1.8, 0, -4.3), Vector3(5.2, 0, -4.3), Vector3(5.2, 0, -6.0), Vector3(5.3, 0, -8.0)], {"min_y": -0.5})):
		return false
	await bot.interact("drawer")
	await _enter_code(State.solution())
	await bot.wait(0.8)
	await bot.interact("drawer (take)")
	_expect(scene.transfer.state.has_item(State.SERVICE_KEY) and scene.transfer.state.has_item(State.INSULATED_BRIDGE), "the drawer opened with the deduced code gave the service items")
	return true


func _down_and_door_first() -> bool:
	if not _leg(await bot.walk("dispatch -> nave -> the stair down to P-2", [Vector3(5.3, 0, -6.0), Vector3(5.2, 0, -4.3), Vector3(6.8, 0, -2.0), Vector3(8.6, 0, 0.6), Vector3(8.6, 0, 10.0), Vector3(7.6, 0, 10.8), Vector3(7.6, 0, 12.2), Vector3(9.2, -0.45, 12.4), Vector3(11.2, -2, 12.4), Vector3(14.8, -4, 12.4), Vector3(26.9, -4, 12.4)], {"min_y": -4.6})):
		return false
	_expect(not scene.lift.powered, "P-2 is reached with the elevator dead")
	if not _leg(await bot.walk("gallery -> dead workshop (the door side)", [Vector3(26.9, -4, 14.2), Vector3(28.7, -4, 16.8)], {"min_y": -4.6})):
		return false
	await _blocked("the concealed panel is solid before it is inspected", Vector3(31.0, -4, 17.2), 29.7)
	await bot.interact("the anomaly in the wall")
	_expect(scene.transfer.state.hidden_door_discovered and scene.notes.has("hidden_door"), "inspecting the anomaly reveals the door and notes it")
	await bot.interact("the transfer door (nothing in hand)")
	_expect(not scene.transfer.state.transfer_door_open and scene.hud.get("_banner_body").text.count(GameText.t("door_state_missing")) == 2, "the door is found before the key and before the power: it stays shut and names the two missing pieces")
	await _blocked("the revealed door leaf is solid", Vector3(31.0, -4, 17.2), 29.8)
	if not _leg(await bot.walk("door -> the maintenance note", [Vector3(25.5, -4, 16.3)], {"min_y": -4.6})):
		return false
	await bot.interact("the maintenance note")
	_expect(scene.transfer.state.maintenance_note_read and scene.notes.has("maintenance_note"), "the note says where the key was put")
	return true


func _spares_and_back() -> bool:
	if not _leg(await bot.walk("dead workshop -> gallery -> spares store -> the dry cabinet", [Vector3(26.9, -4, 14.2), Vector3(26.9, -4, 12.4), Vector3(17.0, -4, 12.4), Vector3(17.0, -4, 14.5), Vector3(16.2, -4, 16.6)], {"min_y": -4.6})):
		return false
	await bot.interact("a flooded locker (decoy)")
	_expect(not scene.transfer.state.cabinet_opened and scene.hud.get("_banner_title").text == GameText.t("ex_wet_locker_title"), "the decoy lockers explain themselves and give nothing")
	if not _leg(await bot.walk("to the dry cabinet's anchor", [Vector3(17.0, -4, 19.1)], {"min_y": -4.6})):
		return false
	await bot.interact("the dry cabinet")
	_expect(scene.transfer.state.has_item(State.TRANSFER_KEY) and scene.notes.has("transfer_key"), "the raised cabinet with the door's symbol gave the transfer key")
	if not _leg(await bot.walk("spares -> gallery -> dead workshop -> door", [Vector3(17.0, -4, 14.5), Vector3(17.0, -4, 12.4), Vector3(26.9, -4, 12.4), Vector3(26.9, -4, 14.2), Vector3(28.7, -4, 16.9)], {"min_y": -4.6})):
		return false
	await bot.interact("the transfer door (key and record, no power)")
	_expect(not scene.transfer.state.transfer_door_open and scene.hud.get("_banner_body").text.count(GameText.t("door_state_missing")) == 1, "key and record without power: shut, one missing piece named")
	return true


func _substation() -> bool:
	if not _leg(await bot.walk("door -> gallery -> the substation door (locked)", [Vector3(26.9, -4, 14.2), Vector3(26.9, -4, 12.4), Vector3(22.0, -4, 12.4)], {"min_y": -4.6})):
		return false
	await _blocked("the locked substation door is solid", Vector3(22.0, -4, 16.0), 13.5, "z")
	await bot.interact("substation door (service key)")
	_expect(scene.transfer.state.substation_unlocked, "the service key (not the transfer key) opens the substation")
	if not _leg(await bot.walk("into the substation -> terminal", [Vector3(22.0, -4, 14.2), Vector3(21.6, -4, 18.6)], {"min_y": -4.6})):
		return false
	await bot.interact("LIFT AUX terminal")
	if not _leg(await bot.walk("terminal -> disconnector", [Vector3(23.1, -4, 17.5)], {"min_y": -4.6})):
		return false
	await bot.interact("disconnector")
	await bot.wait(1.0)
	_expect(scene.transfer.state.power_restored and scene.lift.powered, "the disconnector restores power; with maintenance ON the lift now has both supplies")
	return true


func _cross() -> bool:
	if not _leg(await bot.walk("substation -> gallery -> dead workshop -> door", [Vector3(22.0, -4, 14.2), Vector3(22.0, -4, 12.4), Vector3(26.9, -4, 12.4), Vector3(26.9, -4, 14.2), Vector3(28.7, -4, 16.9)], {"min_y": -4.6})):
		return false
	await bot.interact("the transfer door (everything in hand)")
	await bot.wait(2.2)
	_expect(scene.transfer.state.transfer_door_open and scene.phase == "investigation", "with all four prerequisites the door opens (and nothing has started yet)")
	if not _leg(await bot.walk("through the transfer door into the vestibule", [Vector3(30.4, -4, 17.2), Vector3(33.0, -4, 17.2)], {"min_y": -4.6})):
		return false
	await bot.wait(0.3)
	_expect(scene.transfer.crossed and scene.notes.has("second_building"), "crossing the door is crossing into the second building (field note recorded)")
	_expect(not scene.transfer.detected, "she is not noticed the moment she steps in")
	if not _leg(await bot.walk("vestibule -> the window", [Vector3(34.7, -4, 18.9)], {"min_y": -4.6})):
		return false
	await bot.interact("the window over the bay")
	_expect(scene.notes.has("second_building") and not scene.transfer.detected, "the window is examined before the staff notice her")
	var waited := 0.0
	while not scene.transfer.detected and waited < 40.0:
		await bot.wait(0.5)
		waited += 0.5
	_expect(scene.transfer.detected and scene.phase == "containment" and scene.mission.containment_active, "the staff notice her (%.1f s inside the vestibule): Containment starts from the second building" % scene.transfer.in_vestibule_time)
	_expect(scene.checkpoint_index == scene.CP_B2, "the first checkpoint of the escape is B2")
	return true


func _escape() -> bool:
	if not _leg(await bot.walk("vestibule -> transfer door -> dead workshop -> gallery", [Vector3(31.0, -4, 17.2), Vector3(29.0, -4, 17.2), Vector3(27.4, -4, 15.5), Vector3(26.9, -4, 13.7), Vector3(26.9, -4, 12.4), Vector3(14.8, -4, 12.4)], {"min_y": -4.6, "run": true})):
		return false
	if not _leg(await bot.walk("stair up -> south band -> S1", [Vector3(11.2, -2, 12.4), Vector3(8.4, -0.1, 12.4), Vector3(7.6, 0, 12.0), Vector3(7.6, 0, 10.6), Vector3(8.6, 0, 10.0), Vector3(22.5, 0, 10.0), Vector3(23.2, 0, 12.4), Vector3(25, 0, 12.4), Vector3(25, 0, 11.6)], {"min_y": -4.6, "run": true})):
		return false
	_expect(scene.checkpoint_index == scene.CP_B2, "the pit checkpoint is not triggered from P-2 (it needs the pit's level)")
	if not _leg(await bot.walk("S1 down -> pit -> evacuation gallery -> east mouth -> yard", [Vector3(25, -1, 9.5), Vector3(25, -2, 7.2), Vector3(27, -2, 6.0), Vector3(29.5, -2, 6.0), Vector3(33.2, -2, 6.0), Vector3(36.0, -2, 6.0)], {"min_y": -2.5, "run": true})):
		return false
	_expect(scene.checkpoint_index >= scene.CP_P1, "the pit checkpoint is set once she is in the pit")
	await bot.wait(0.3)
	_expect(scene.in_yard and scene.notes.has("parking"), "the yard is entered in the same scene")
	await bot.wait(4.0)
	if not _leg(await bot.walk("yard route A -> convergence", [Vector3(38.5, -2, 6.0), Vector3(43, -2, 4.5), Vector3(52, -2, 4.5), Vector3(61, -2, 4.5), Vector3(68, -2, 4.0), Vector3(70.5, -2, 1.2)], {"min_y": -2.5})):
		return false
	if not _leg(await bot.walk("O3 aperture -> egress enclosure -> emergency lane", [Vector3(72.95, -2, 0.6), Vector3(72.95, -2, -2.4), Vector3(72.95, -2, -10.0), Vector3(72.7, -2, -14.2)], {"min_y": -2.5})):
		return false
	if not _leg(await bot.walk("through the pedestrian emergency lane", [Vector3(72.7, -2, -15.6), Vector3(72.7, -1.7, -17.2)], {"min_y": -2.5})):
		return false
	var end_wait := 0.0
	while results_seen.is_empty() and end_wait < 60.0:
		await bot.wait(0.5)
		end_wait += 0.5
	_expect(not results_seen.is_empty() and int(results_seen["catches"]) == 0, "the ending plays and reports the results (%.0f s)" % end_wait)
	_expect(not get_tree().paused, "the game is not left paused after the ending")
	return true
