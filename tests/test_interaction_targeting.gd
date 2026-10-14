extends Node
## Interaction targeting and the Elena test room's investigation loop.
## Run: godot --headless --path . res://tests/test_interaction_targeting.tscn

const ManagerScript = preload("res://scripts/components/interaction_manager.gd")
const InteractableScript = preload("res://scripts/components/interactable.gd")
const DoorScript = preload("res://scripts/components/door.gd")
const ROOM_SCENE := "res://scenes/levels/elena_test_room.tscn"

var failed := 0
var passed := 0


func _ready() -> void:
	await _test_line_of_sight()
	await _test_own_collider_does_not_block()
	await _test_room_lever_not_through_wall()
	print("Interaction targeting: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _physics_settle() -> void:
	for i in 3:
		await get_tree().physics_frame


func _wall(size: Vector3, pos: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)
	body.global_position = pos
	return body


func _test_line_of_sight() -> void:
	var root := Node3D.new()
	add_child(root)
	var actor := Node3D.new()
	root.add_child(actor)
	var target = InteractableScript.new()
	root.add_child(target)
	target.global_position = Vector3(2.0, 0.0, 0.0)
	var manager = ManagerScript.new()
	manager.actor = actor
	add_child(manager)
	await _physics_settle()
	manager._process(0.0)
	_expect(manager.current_target == target, "A1: in range with clear line of sight -> targeted")

	var wall := _wall(Vector3(0.3, 3.0, 4.0), Vector3(1.0, 1.5, 0.0))
	await _physics_settle()
	manager._process(0.0)
	_expect(manager.current_target == null, "A2: a wall between actor and interactable blocks targeting")

	manager.occlusion_mask = 0
	manager._process(0.0)
	_expect(manager.current_target == target, "A3: occlusion_mask = 0 restores pure distance targeting")
	manager.occlusion_mask = 1

	wall.queue_free()
	await _physics_settle()
	manager._process(0.0)
	_expect(manager.current_target == target, "A4: removing the wall makes the interactable targetable again")

	target.global_position = Vector3(3.0, 0.0, 0.0)
	manager._process(0.0)
	_expect(manager.current_target == null, "A5: out of interaction range -> not targeted")
	for n in [root, manager]:
		n.queue_free()
	await get_tree().process_frame


func _test_own_collider_does_not_block() -> void:
	var root := Node3D.new()
	add_child(root)
	var actor := Node3D.new()
	root.add_child(actor)
	var door = DoorScript.new()
	door.locked = false
	root.add_child(door)
	door.global_position = Vector3(1.5, 0.0, 0.0)
	var manager = ManagerScript.new()
	manager.actor = actor
	add_child(manager)
	await _physics_settle()
	manager._process(0.0)
	_expect(manager.current_target == door, "A6: the door's own slab collider does not block targeting it")
	for n in [root, manager]:
		n.queue_free()
	await get_tree().process_frame


func _test_room_lever_not_through_wall() -> void:
	var room := (load(ROOM_SCENE) as PackedScene).instantiate()
	add_child(room)
	await get_tree().process_frame
	var elena = room.get("elena")
	var manager = room.get("manager")
	var lever = room.get("lever")
	# South of the alcove wall, within 2.4 m flat distance of the lever: used to work through the wall.
	elena.global_position = Vector3(5.2, 0.1, -4.03)
	elena.velocity = Vector3.ZERO
	await _physics_settle()
	elena.global_position = Vector3(5.2, 0.1, -4.03)
	manager._process(0.0)
	var flat := Vector2(elena.global_position.x - lever.global_position.x, elena.global_position.z - lever.global_position.z).length()
	_expect(flat <= float(lever.interaction_range), "R1: the probe position is inside the lever's flat interaction range")
	_expect(manager.current_target != lever, "R2: the lever cannot be targeted through the alcove wall")
	manager.occlusion_mask = 0
	manager._process(0.0)
	_expect(manager.current_target == lever, "R2b: control - without the line-of-sight check the same spot targets the lever")
	manager.occlusion_mask = 1

	elena.global_position = Vector3(5.0, 0.1, -5.4)
	await _physics_settle()
	elena.global_position = Vector3(5.0, 0.1, -5.4)
	manager._process(0.0)
	_expect(manager.current_target == lever, "R3: inside the alcove the lever is the interaction target")

	# Investigation: scanning from the bay entrance reveals the generator feed cable and explains it once.
	var trace = room.get("feed_trace")
	_expect(trace != null and trace.is_in_group("scannables"), "R4: the generator feed trace is a scannable")
	elena.global_position = Vector3(5.0, 0.1, -0.5)
	room.get("scanner").call("scan")
	await get_tree().process_frame
	_expect(trace.is_scanned(), "R5: a scan from the bay entrance reveals the feed trace")
	_expect(room.get("panel").call("is_message_visible"), "R6: revealing the feed shows the explanation message")

	var names_ok := true
	for n in get_tree().get_nodes_in_group("interactables"):
		if str(n.get("display_name")) in ["", "Objeto"]:
			names_ok = false
	_expect(names_ok, "R7: every interactable in the room has a specific name for its prompt")
	room.queue_free()
	await get_tree().process_frame
