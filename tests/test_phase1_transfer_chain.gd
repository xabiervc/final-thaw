extends Node
## Scene-level acceptance of the expanded Phase 1 (the real canonical scene, the real handlers, no walking): hotspot gating,
## the feedback for every missing prerequisite in both languages, order independence in the scene, the Aster boundary,
## the lift rule, persistence of the chain, the threshold to the second building and the text contracts.
## Walking (physics, collision, the code lock's real input) is tests/test_phase1_playthrough.gd and
## tests/test_phase1_transfer_route.gd; the pure rules are tests/test_phase1_transfer_state.gd.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_transfer_chain.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const State := preload("res://scripts/phase1/phase1_transfer_state.gd")
const Expansion := preload("res://scripts/phase1/phase1_expansion.gd")
const CircuitModel := preload("res://scripts/prototypes/phase1_circuit_model.gd")

var passed := 0
var failed := 0
var completed := false


func _ready() -> void:
	get_tree().create_timer(300.0).timeout.connect(func():
		if not completed:
			push_error("transfer chain test did not complete (possible script error)")
			get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _new_scene() -> Node3D:
	var scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("play_intro", false)
	scene.set("spawn_unit_enabled", false)
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame
	return scene


func _banner_title(scene) -> String:
	return str((scene.hud.get("_banner_title") as Label).text)


func _banner_body(scene) -> String:
	return str((scene.hud.get("_banner_body") as Label).text)


## Archive supply stable through the circuit model, then the real consult handler: RESTRICTED_RECORD_READ.
func _read_record(scene) -> void:
	scene.circuit.set_isolated(true)
	scene.circuit.select_destination(CircuitModel.ARCHIVE)
	scene.call("_consult_archive")


func _do(scene, event: String) -> void:
	var t = scene.transfer
	match event:
		"seam":
			t.interact("wall_seam")
		"note":
			t.interact("maintenance_note")
		"cabinet":
			t.interact("dry_cabinet")
		"record":
			_read_record(scene)
		"power":
			t.call("_on_code", State.solution())
			t.interact("drawer")
			t.interact("substation_door")
			t.interact("terminal")
			t.interact("disconnector")


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	await _gating_and_feedback()
	await _aster_boundary()
	await _orders()
	await _persistence()
	await _threshold()
	await _texts()
	completed = true
	print("Phase 1 transfer chain: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


# --- gating, anchors and the feedback for every missing prerequisite ------------------------------------------------------------

func _gating_and_feedback() -> void:
	var scene = await _new_scene()
	var t = scene.transfer
	_expect(t.state.to_dict() == State.new().to_dict(), "the mission starts with every chain flag clear")
	_expect(not scene.lift.powered and not t.state.power_restored, "the lift and the auxiliary supply start dead")
	var ids: Array = []
	var unique := true
	for h in t.hotspots():
		if str(h["id"]) in ids:
			unique = false
		ids.append(str(h["id"]))
	_expect(unique and ids.size() == 14, "the controller offers 14 uniquely identified hotspots (%d)" % ids.size())
	# Every anchor stands on a floor, in free space for the capsule, and is a place a body can reach.
	var space: PhysicsDirectSpaceState3D = scene.get_world_3d().direct_space_state
	var bad: Array = []
	for h in t.hotspots():
		var at: Vector3 = h["at"]
		var down := PhysicsRayQueryParameters3D.create(at + Vector3(0, 0.6, 0), at + Vector3(0, -0.5, 0), 1)
		var floor_hit := space.intersect_ray(down)
		var capsule := CapsuleShape3D.new()
		capsule.radius = 0.4
		capsule.height = 1.8
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = capsule
		q.transform = Transform3D(Basis.IDENTITY, at + Vector3(0, 0.95, 0))
		q.collision_mask = 1 | 16
		if floor_hit.is_empty() or not space.intersect_shape(q, 1).is_empty():
			bad.append(str(h["id"]))
	_expect(bad.is_empty(), "every hotspot anchor has floor under it and free space for Elena %s" % [bad])
	# Availability follows the state (nothing is offered that cannot be done).
	_expect(t.available("wall_seam") and not t.available("transfer_door") and not t.available("bay_window"), "before discovery only the anomaly is offered, not the door")
	_expect(t.available("substation_door") and not t.available("terminal") and not t.available("disconnector"), "the substation's inside is not offered while its door is shut")
	# Feedback for each missing prerequisite, in order of discovery.
	scene.set("_hotspot_id", "")
	t.interact("wall_seam")
	_expect(t.state.hidden_door_discovered and not t.available("wall_seam") and t.available("transfer_door"), "inspecting the anomaly discovers the door and swaps the hotspots")
	_expect(not t.state.transfer_door_open and not (t.fx.transfer_door.get_child(0) as CollisionShape3D).disabled, "the discovered door is still a solid leaf")
	t.interact("transfer_door")
	var locked_body := _banner_body(scene)
	_expect(_banner_title(scene) == GameText.t("ban_door_locked_title") and locked_body.count(GameText.t("door_state_missing")) == 3, "the closed door lists all three missing prerequisites as words (%s)" % locked_body.replace("\n", " | "))
	_expect(not t.state.transfer_door_open, "an attempt with nothing in hand does not open it")
	t.interact("dry_cabinet")
	t.interact("transfer_door")
	_expect(_banner_body(scene).count(GameText.t("door_state_missing")) == 2 and t.state.has_item(State.TRANSFER_KEY), "with the key, two prerequisites are still reported")
	_expect(t.fx.reader_text.text.contains("LLAVE: OK") and t.fx.reader_text.text.contains("TENSIÓN: --"), "the door's reader mirrors the state")
	_read_record(scene)
	t.interact("transfer_door")
	_expect(_banner_body(scene).count(GameText.t("door_state_missing")) == 1 and not t.state.transfer_door_open, "key and record: only the power is missing and the door stays shut")
	_expect(not scene.lift.powered, "the lift is still dead")
	# The lift: maintenance alone is refused with its own message.
	scene.call("_toggle_maintenance")
	scene.call("_call_lift", "lower")
	_expect(_banner_title(scene) == GameText.t("ban_lift_nopower_title") and not scene.lift.powered, "maintenance without the auxiliary supply: the lift refuses and says why")
	_do(scene, "power")
	_expect(t.state.power_restored and scene.lift.powered, "the auxiliary supply restored with maintenance ON powers the lift")
	scene.call("_toggle_maintenance")
	_expect(not scene.lift.powered and t.state.power_restored, "maintenance OFF cuts the lift again; the auxiliary supply stays restored")
	scene.call("_toggle_maintenance")
	_expect(scene.lift.powered, "and switching maintenance back ON restores it")
	t.interact("transfer_door")
	await get_tree().physics_frame
	_expect(t.state.transfer_door_open and (t.fx.transfer_door.get_child(0) as CollisionShape3D).disabled, "with every prerequisite the door opens and its collision goes")
	_expect(t.available("bay_window") and not t.available("transfer_door"), "once open the door is no longer offered and the window is")
	t.interact("transfer_door")
	_expect(t.state.transfer_door_open, "using an open door again changes nothing")
	# The deduced code is never written anywhere the player can read it.
	_expect(not scene.notes.entries().any(func(e): return str(e["body"]).contains(State.solution())), "no field note contains the code")
	scene.queue_free()
	await get_tree().process_frame


# --- the Aster boundary -----------------------------------------------------------------------------------------------------------

func _aster_boundary() -> void:
	var scene = await _new_scene()
	var t = scene.transfer
	var circuit_before: Variant = scene.circuit.snapshot() if scene.circuit.has_method("snapshot") else [scene.circuit.inspect(), scene.circuit.outputs()]
	var mission_before: Dictionary = scene.mission.to_dict()
	var aster_notes := ["schematic", "bridge", "hypothesis", "trip", "test_result", "archive_stable", "record", "conclusion", "maintenance_risk", "scan_bridge"]
	_do(scene, "power")
	_do(scene, "seam")
	_do(scene, "cabinet")
	_do(scene, "note")
	var circuit_after: Variant = scene.circuit.snapshot() if scene.circuit.has_method("snapshot") else [scene.circuit.inspect(), scene.circuit.outputs()]
	_expect(circuit_after == circuit_before, "the whole auxiliary and transfer chain leaves the Aster circuit model untouched (protection, destination, isolator, history)")
	_expect(scene.mission.to_dict() == mission_before, "and leaves the mission contract (SERVICE_OVERRIDE, RESTRICTED_RECORD_READ, AUDIT, CONTAINMENT) untouched")
	var leaked := []
	for id in aster_notes:
		if scene.notes.has(id):
			leaked.append(id)
	_expect(leaked.is_empty(), "no Aster field note is derived or granted by the new chains %s" % [leaked])
	# The reverse: the Aster investigation changes nothing in the chain.
	var chain_before: Dictionary = t.state.to_dict()
	scene.call("_toggle_maintenance")
	_read_record(scene)
	_expect(t.state.to_dict() == chain_before, "maintenance, the circuit and the record never alter the chain's flags")
	_expect(scene.mission.restricted_record_read and scene.mission.service_override_queued and not scene.mission.containment_active, "the record is read and nothing starts Containment")
	scene.queue_free()
	await get_tree().process_frame


# --- exploration order in the scene -----------------------------------------------------------------------------------------------

func _orders() -> void:
	var orders := [
		["seam", "note", "cabinet", "power", "record"],
		["record", "power", "cabinet", "note", "seam"],
		["cabinet", "seam", "record", "power", "note"],
		["power", "record", "seam", "cabinet"],  # the note is never read
	]
	for order in orders:
		var scene = await _new_scene()
		var t = scene.transfer
		var done: Array = []
		var early := false
		for event in order:
			_do(scene, event)
			done.append(event)
			var complete: bool = done.has("seam") and done.has("cabinet") and done.has("power") and done.has("record")
			if t.available("transfer_door"):
				t.interact("transfer_door")
			if t.state.transfer_door_open != complete:
				early = true
		_expect(not early and t.state.transfer_door_open, "order %s: the door opens exactly when the last prerequisite arrives" % [order])
		_expect(t.state.items.size() == 3 and t.state.items.count(State.TRANSFER_KEY) == 1, "order %s: three items, none duplicated" % [order])
		scene.queue_free()
		await get_tree().process_frame


# --- persistence --------------------------------------------------------------------------------------------------------------------

func _persistence() -> void:
	var save_before := {}
	for slot in 3:
		var p: String = GameManager.save_path(slot)
		save_before[slot] = FileAccess.get_md5(p) if FileAccess.file_exists(p) else ""
	var scene = await _new_scene()
	var t = scene.transfer
	for event in ["seam", "note", "cabinet", "power", "record"]:
		_do(scene, event)
	t.interact("transfer_door")
	var snapshot: Dictionary = t.state.to_dict()
	scene.queue_free()
	await get_tree().process_frame
	# A new mission loaded from the dictionary: no duplicate items, every fixture matches the state.
	var scene2 = await _new_scene()
	var t2 = scene2.transfer
	scene2.circuit.set_maintenance(true)
	t2.apply_state_for_test(snapshot)
	await get_tree().physics_frame
	_expect(t2.state.to_dict() == snapshot and t2.state.items.size() == 3, "the chain restores from its dictionary without duplicating anything")
	_expect(scene2.lift.powered, "the restored supply and the maintenance switch power the lift")
	_expect((t2.fx.transfer_door.get_child(0) as CollisionShape3D).disabled and (t2.fx.substation_door.get_child(0) as CollisionShape3D).disabled and (t2.fx.hidden_panel.get_child(0) as CollisionShape3D).disabled, "restored doors and panel are open (no collision left behind)")
	_expect(not t2.available("wall_seam") and not t2.available("substation_door") and t2.available("bay_window"), "restored hotspots match the restored state")
	var save_after_ok := true
	for slot in 3:
		var p: String = GameManager.save_path(slot)
		var now: String = FileAccess.get_md5(p) if FileAccess.file_exists(p) else ""
		if now != str(save_before[slot]):
			save_after_ok = false
	_expect(save_after_ok, "playing the chain writes nothing to the save file (session-only by contract)")
	scene2.queue_free()
	await get_tree().process_frame


# --- the threshold: crossing, observing, being noticed ------------------------------------------------------------------------------------

func _threshold() -> void:
	var scene = await _new_scene()
	var t = scene.transfer
	for event in ["seam", "cabinet", "power", "record"]:
		_do(scene, event)
	_expect(not t.crossed and scene.phase == "investigation", "before the door opens Elena has not crossed")
	t.interact("transfer_door")
	# Leaving the dead workshop's door side is not crossing; the vestibule is.
	scene.player.global_position = Vector3(28.0, -4.0, 17.0)
	scene.player.velocity = Vector3.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(not t.crossed, "standing in the dead workshop beside the open door is not the threshold")
	scene.player.global_position = Vector3(34.7, -4.0, 17.4)
	scene.player.velocity = Vector3.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(t.crossed and scene.notes.has("second_building") and scene.phase == "investigation" and not t.detected, "entering the vestibule crosses into the second building and the field notes record it")
	# Outside the vestibule the staff cannot notice her: the clock only runs inside.
	t.in_vestibule_time = 0.0
	scene.player.global_position = Vector3(27.0, -4.0, 16.0)
	await get_tree().physics_frame
	for i in 30:
		await get_tree().physics_frame
	_expect(t.in_vestibule_time == 0.0 and not t.detected, "the staff cannot notice her while she is outside their vestibule")
	# Inside, away from the bay door, the window can be examined before anyone notices.
	scene.player.global_position = Vector3(34.7, -4.0, 17.4)
	await get_tree().physics_frame
	await get_tree().physics_frame
	t.interact("bay_window")
	_expect(scene.notes.has("second_building") and not t.detected, "the window gives the evidence before the staff notice her")
	# Near the bay door she is noticed at once: Containment from the bay, checkpoint B2, the bay door open.
	scene.player.global_position = Vector3(31.2, -4.0, 18.6)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(t.detected and scene.phase == "containment" and scene.mission.containment_active, "approaching the bay door gets her noticed: Containment starts")
	_expect(scene.checkpoint_index == scene.CP_B2 and str(scene.CHECKPOINTS[scene.CP_B2]["id"]) == "B2", "the escape's first checkpoint is B2")
	_expect((t.fx.bay_door.get_child(0) as CollisionShape3D).disabled, "the bay door is open")
	_expect(scene.notes.has("transfer_breach"), "the breach is recorded in the notes")
	# The G airlock can no longer start a second Containment.
	scene.call("_open_g_outer")
	_expect(scene.mission.on_open_g() == "already", "G cannot start a second Containment")
	scene.queue_free()
	await get_tree().process_frame


# --- text contracts -----------------------------------------------------------------------------------------------------------------------

func _texts() -> void:
	var missing: Array = []
	for id in ["shift_order", "pressure_values", "drawer_open", "aux_power", "hidden_door", "maintenance_note", "transfer_key", "second_building", "transfer_breach"]:
		for suffix in ["_title", "_body"]:
			if not GameText.has("note_" + id + suffix):
				missing.append("note_" + id + suffix)
		if not (id in preload("res://scripts/game/field_notes.gd").ORDER):
			missing.append("ORDER:" + id)
	_expect(missing.is_empty(), "every new field note has its texts and a place in the reading order %s" % [missing])
	var both_languages := true
	for key in GameText.keys():
		var e: Dictionary = GameText.entry(str(key))
		if str(e.get("es", "")).is_empty() or str(e.get("en", "")).is_empty():
			both_languages = false
	_expect(both_languages, "every text key has Spanish and English")
	# The English game shows English everywhere the chain speaks.
	var before := GameText.locale()
	NarrativeTextManager.set_locale("en")
	var scene = await _new_scene()
	var t = scene.transfer
	t.interact("wall_seam")
	t.interact("transfer_door")
	var english: bool = _banner_title(scene).begins_with("Transfer door") and _banner_body(scene).contains("MISSING") and not _banner_body(scene).contains("FALTA")
	_expect(english, "the locked door's feedback is English in the English game (%s)" % _banner_title(scene))
	scene.queue_free()
	await get_tree().process_frame
	NarrativeTextManager.set_locale(before)
	# The hint ladders never name the answer.
	var leaks: Array = []
	for stage in ["aux", "transfer"]:
		for key in preload("res://scripts/prototypes/phase1_canonical_greybox.gd").HINTS[stage]:
			for lang in ["es", "en"]:
				var text := str(GameText.entry(str(key)).get(lang, ""))
				if text.contains("0437") or text.contains("B, D, A, C") or text.to_lower().contains("seccionador"):
					leaks.append(key)
	_expect(leaks.is_empty(), "the new hint ladders (ES and EN) never contain the code or name the control %s" % [leaks])
