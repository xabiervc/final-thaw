extends Node

## Physics layers that block line of sight to an interactable (layer 1 = world geometry).
## 0 disables the check (pure distance targeting, the original behaviour).
@export_flags_3d_physics var occlusion_mask: int = 1
## Ray endpoints: from the actor's chest to the interactable's working height.
const EYE_HEIGHT := 1.0
const TARGET_HEIGHT := 0.8

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
		if d <= float(node.get("interaction_range")) and d < best_d and has_line_of_sight(node):
			best = node
			best_d = d
	current_target = best

func _flat_distance(node: Node3D) -> float:
	var a := actor.global_position
	var b := node.global_position
	return Vector2(a.x - b.x, a.z - b.z).length()

## True when no world geometry stands between the actor and the interactable. Colliders that belong to the
## interactable itself (a door slab, a terminal body) and to the actor never block.
func has_line_of_sight(node: Node3D) -> bool:
	if occlusion_mask == 0 or not actor.is_inside_tree():
		return true
	var world := actor.get_world_3d()
	if world == null or world.direct_space_state == null:
		return true
	var from := actor.global_position + Vector3.UP * EYE_HEIGHT
	var to := node.global_position + Vector3.UP * TARGET_HEIGHT
	var exclude: Array[RID] = []
	if actor is CollisionObject3D:
		exclude.append((actor as CollisionObject3D).get_rid())
	var query := PhysicsRayQueryParameters3D.create(from, to, occlusion_mask, exclude)
	var hit := world.direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	# The first thing hit must be part of the target; anything else (a wall, another crate) obstructs it.
	var collider := hit.get("collider") as Node
	return collider == null or collider == node or node.is_ancestor_of(collider)

func _unhandled_input(event: InputEvent) -> void:
	if not active or actor == null:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		if current_target != null and is_instance_valid(current_target):
			current_target.call("interact", actor)
			get_viewport().set_input_as_handled()
