extends Node

var actor: Node3D = null
var current_target: Node3D = null
var active: bool = true

func _process(_delta: float) -> void:
	if actor == null or not active:
		current_target = null
		return
	var best: Node3D = null
	var best_d: float = INF
	for n in get_tree().get_nodes_in_group("interactables"):
		var node := n as Node3D
		if node == null or not is_instance_valid(node):
			continue
		if node.get("enabled") == false:
			continue
		var d := _flat_distance(node)
		if d <= float(node.get("interaction_range")) and d < best_d:
			best = node
			best_d = d
	current_target = best

func _flat_distance(node: Node3D) -> float:
	var a := actor.global_position
	var b := node.global_position
	return Vector2(a.x - b.x, a.z - b.z).length()

func _unhandled_input(event: InputEvent) -> void:
	if not active or actor == null:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		if current_target != null and is_instance_valid(current_target):
			current_target.call("interact", actor)
			get_viewport().set_input_as_handled()
