extends Node

const SCENE := "res://scenes/prototypes/escape_conduit_labyrinth.tscn"
const MissionState := preload("res://scripts/phase1/escape_mission_state.gd")

var passed := 0
var failed := 0
var scene: Node3D

func _ready() -> void:
	_run.call_deferred()

func _expect(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func _run() -> void:
	var packed := load(SCENE) as PackedScene
	_expect(packed != null, "standalone escape scene loads")
	if packed == null:
		get_tree().quit(1)
		return
	scene = packed.instantiate() as Node3D
	if scene == null:
		_expect(false, "escape scene instantiates as Node3D")
		get_tree().quit(1)
		return
	add_child(scene)
	await get_tree().process_frame
	await get_tree().physics_frame
	_expect(scene.get_node_or_null("Elena_EscapeMission") != null, "Elena player exists")
	_expect(scene.get_node_or_null("ESC_SHELF") != null and scene.get_node_or_null("ESC_CABINET") != null, "shelf and cabinet interaction props exist")
	_expect(scene.get_node_or_null("ESC_HUMAN_ALARM_BUTTON") != null and scene.get_node_or_null("ESC_SECURITY_GATE") != null, "human alarm control and security gate exist")
	_expect(scene.get_node_or_null("T1") != null and scene.get_node_or_null("T2") != null and scene.get_node_or_null("T3") != null, "three workers are instantiated")
	_expect(scene.get_node_or_null("G1") != null and scene.get_node_or_null("G2") != null, "two distinct guards are instantiated")
	_expect(scene.get_node_or_null("ESC_FOREST_HIDEOUT_TRIGGER") != null, "forest completion trigger exists")
	await get_tree().create_timer(0.2).timeout
	var player: Node3D = scene.get("player")
	_expect(player != null and absf(float(player.get("stamina")) - 100.0) < 0.01, "adrenaline prototype restores stamina to 100")
	_expect(str(player.get("camera_mode")) == "explore", "escape player uses the configured exploration camera mode")

	var trigger := scene.get_node("ESC_FOREST_HIDEOUT_TRIGGER") as Area3D
	player.global_position = trigger.global_position
	for frame in 8:
		await get_tree().physics_frame
	_expect(not bool(scene.get("complete")), "forest trigger cannot complete the mission before the escape sequence")
	_expect(bool(player.get("input_enabled")), "premature forest entry does not disable player input")

	var mission_state = scene.get("mission_state")
	_expect(not bool(mission_state.get("alarm_active")), "alarm begins inactive")
	scene.call("_on_encounter_entered", player)
	var interactables: Dictionary = scene.get("interactables")
	player.global_position = interactables["shelf"]["at"]
	scene.call("_update_interaction_prompt")
	_expect(str(scene.get("current_interaction")) == "shelf", "nearby shelf interaction is selected")
	scene.call("_try_interact")
	_expect(bool(mission_state.get("shelf_fallen")), "interacting topples the shelf and advances worker recovery")
	await get_tree().create_timer(2.5).timeout
	_expect(
		mission_state.get("worker_state")["T1"] == MissionState.WorkerState.MOVING_TO_ALARM
		and not bool(mission_state.get("alarm_active")),
		"T1 starts a physical alarm route without activating the alarm early"
	)
	await get_tree().create_timer(5.0).timeout
	_expect(bool(mission_state.get("alarm_active")), "T1 activates the alarm only after reaching the physical button")

	player.global_position = interactables["cabinet"]["at"]
	scene.call("_update_interaction_prompt")
	_expect(str(scene.get("current_interaction")) == "cabinet", "cabinet interaction becomes available after the shelf event")
	scene.call("_try_interact")
	_expect(bool(mission_state.get("cabinet_fallen")), "interacting topples the cabinet after the shelf")
	scene.call("_on_actor_path_finished", "G1")
	scene.call("_on_actor_path_finished", "G2")
	_expect(
		mission_state.get("player_beat") == MissionState.PlayerBeat.EXTINGUISHER_INTERACTION,
		"the extinguisher encounter begins after both guards arrive"
	)
	player.global_position = interactables["extinguisher"]["at"]
	scene.call("_update_interaction_prompt")
	_expect(str(scene.get("current_interaction")) == "extinguisher", "nearby extinguisher interaction is selected")
	scene.call("_try_interact")
	_expect(
		bool(mission_state.get("extinguisher_picked_up")) and scene.get("carried_extinguisher") != null,
		"interacting picks up the extinguisher"
	)
	var actors: Dictionary = scene.get("actors")
	(actors["G1"] as Node3D).global_position = player.global_position + Vector3(1.0, 0.0, 0.0)
	scene.call("_try_strike")
	_expect(not bool(mission_state.get("guard_strikes")["G1"]), "strikes are rejected before the extinguisher is discharged")
	scene.call("_try_interact")
	_expect(bool(mission_state.get("extinguisher_discharged")), "interacting again discharges the extinguisher")
	(actors["G1"] as Node3D).global_position = player.global_position + Vector3(1.0, 0.0, 0.0)
	scene.call("_try_strike")
	_expect(
		mission_state.get("guard_state")["G1"] == MissionState.GuardState.NEUTRALIZED,
		"striking a nearby disoriented guard neutralizes that guard"
	)
	(actors["G2"] as Node3D).global_position = player.global_position + Vector3(1.0, 0.0, 0.0)
	scene.call("_try_strike")
	_expect(
		mission_state.get("player_beat") == MissionState.PlayerBeat.ESCAPE_RUN,
		"neutralizing both guards resumes the escape run"
	)
	player.global_position = trigger.global_position
	for frame in 8:
		if bool(scene.get("complete")):
			break
		await get_tree().physics_frame
	_expect(bool(scene.get("complete")), "forest entry completes the mission after required state transitions")
	_expect(not bool(player.get("input_enabled")), "player input stops after the forest ending")
	print("Escape conduit mission: %d passed, %d failed" % [passed, failed])
	scene.queue_free()
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(1 if failed > 0 else 0)
