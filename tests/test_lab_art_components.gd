extends Node
## Visual art for the interactive components (scripts/levels/lab_art_components.gd): every known component gets its art,
## the greybox meshes are hidden, glow/state is mirrored, and the level's colliders and scripts are unchanged.
## Ejecutar: godot --headless --path . res://tests/test_lab_art_components.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const WrapperScene := preload("res://scenes/levels/abandoned_lab_art.tscn")
const LevelScene := preload("res://scenes/levels/abandoned_lab.tscn")
const PhaseOneScene := preload("res://scenes/levels/elena_test_room_art.tscn")
const KNOWN := ["connection_node.gd", "junction_box.gd", "powered_terminal.gd", "terminal.gd", "push_button.gd", "memory_fragment.gd",
	"checkpoint.gd", "lever.gd", "door.gd", "robotic_arm.gd"]

var failed := 0
var passed := 0


func _ready() -> void:
	var plain := LevelScene.instantiate()
	add_child(plain)
	await get_tree().process_frame
	var plain_colliders: int = plain.find_children("*", "CollisionShape3D", true, false).size()
	var plain_bodies: int = plain.find_children("*", "CollisionObject3D", true, false).size()
	plain.queue_free()
	await get_tree().process_frame

	var wrapper := WrapperScene.instantiate()
	add_child(wrapper)
	await get_tree().process_frame
	await get_tree().process_frame
	var level: Node = wrapper.get_child(0)

	var components: Array = []
	for n in level.find_children("*", "Node3D", true, false):
		var script := n.get_script() as Script
		if script != null and KNOWN.has(script.resource_path.get_file()) and n.get_node_or_null("ArtProp") != null:
			components.append(n)
	var expected := 0
	for n in level.find_children("*", "Node3D", true, false):
		var script2 := n.get_script() as Script
		if script2 != null and KNOWN.has(script2.resource_path.get_file()):
			expected += 1
	_expect(expected > 20, "the lab has many known components (%d)" % expected)
	_expect(components.size() == expected, "every known component got its art (%d of %d)" % [components.size(), expected])

	var all_hidden := true
	for c in components:
		for m in c.find_children("*", "MeshInstance3D", true, false):
			if c.get_node("ArtProp").is_ancestor_of(m):
				continue
			if (m as MeshInstance3D).layers != 0:
				all_hidden = false
	_expect(all_hidden, "greybox meshes of dressed components are hidden")

	_expect(level.find_children("*", "CollisionShape3D", true, false).size() == plain_colliders, "collision shapes unchanged")
	_expect(level.find_children("*", "CollisionObject3D", true, false).size() == plain_bodies, "collision bodies unchanged")

	# state mirroring
	var node = _first(level, "connection_node.gd", func(n): return not n.connected)
	if node != null:
		node.set_connected(true)
		await get_tree().process_frame
		await get_tree().process_frame
		var orb: MeshInstance3D = node.get_node("ArtProp").find_child("emit_orb", true, false)
		var ring: MeshInstance3D = node.get_node("ArtProp").find_child("emit_ring", true, false)
		var src_orb := (node._orb as MeshInstance3D).material_override as StandardMaterial3D
		_expect((orb.material_override as StandardMaterial3D).emission.is_equal_approx(src_orb.emission), "node orb mirrors the greybox glow when connected")
		_expect(ring.visible, "node ring becomes visible when connected")
		node.set_connected(false)
		await get_tree().process_frame
		await get_tree().process_frame
		_expect(not ring.visible, "node ring hides again when disconnected")
	else:
		_expect(false, "found a disconnected node")

	var door = _first(level, "door.gd", func(n): return not n.is_open)
	if door != null:
		door.open_door(false)
		await get_tree().process_frame
		await get_tree().process_frame
		var slab: Node3D = door.get_node("ArtProp").find_child("DoorSlab", true, false)
		_expect(is_equal_approx(slab.position.z, door._slab.position.z) and slab.position.z > 1.0, "door slab slides with the greybox slab")
	else:
		_expect(false, "found a closed door")

	var frag = _first(level, "memory_fragment.gd", func(n): return not n.collected)
	if frag != null:
		var gem: Node3D = frag.get_node("ArtProp").find_child("emit_gem", true, false)
		_expect(gem.visible, "fragment gem is visible before pickup")
		frag._collect()
		await get_tree().process_frame
		await get_tree().process_frame
		_expect(not gem.visible, "fragment gem hides after pickup")

	# the lever lives in the phase 1 room
	wrapper.queue_free()
	await get_tree().process_frame
	var room_wrapper := PhaseOneScene.instantiate()
	add_child(room_wrapper)
	await get_tree().process_frame
	await get_tree().process_frame
	var lever = _first(room_wrapper.get_child(0), "lever.gd", func(_n): return true)
	if lever != null and lever.get_node_or_null("ArtProp") != null:
		lever.set_on(true, false)
		await get_tree().process_frame
		await get_tree().process_frame
		var arm: Node3D = lever.get_node("ArtProp").find_child("LeverArm", true, false)
		_expect(is_equal_approx(arm.rotation_degrees.z, lever._pivot.rotation_degrees.z), "lever arm follows the greybox pivot")
	else:
		_expect(false, "the phase 1 lever got its art")

	print("Lab art components: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _first(level: Node, script_name: String, pred: Callable) -> Node:
	for n in level.find_children("*", "Node3D", true, false):
		var s := n.get_script() as Script
		if s != null and s.resource_path.get_file() == script_name and pred.call(n):
			return n
	return null


func _expect(cond: bool, message: String) -> void:
	if cond:
		passed += 1
		print("PASS: ", message)
	else:
		failed += 1
		push_error("FAIL: " + message)
