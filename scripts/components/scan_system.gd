extends Node

@export var scan_radius: float = 6.0
@export var highlight_seconds: float = 2.0
@export var visuals_enabled: bool = true

## Grupos que el escaner resalta. Los nodos de "scannables" son solo visuales: deben
## implementar set_scanned(active: bool) y no pueden ser objetivo de interaccion.
const SCAN_GROUPS: Array[String] = ["interactables", "scannables"]

var actor: Node3D = null
var _serial: int = 0
var _lit: Array = []

func _unhandled_input(event: InputEvent) -> void:
	if actor == null:
		return
	if event.is_action_pressed("scan") and not event.is_echo():
		scan()

func scan() -> void:
	_clear()
	_serial += 1
	var my_serial := _serial
	if visuals_enabled:
		_spawn_ring()
	for group_name in SCAN_GROUPS:
		for n in get_tree().get_nodes_in_group(group_name):
			var node := n as Node3D
			if node == null or _lit.has(node):
				continue
			var a := actor.global_position
			var b := node.global_position
			if Vector2(a.x - b.x, a.z - b.z).length() <= scan_radius:
				node.call("set_scanned", true)
				_lit.append(node)
	await get_tree().create_timer(highlight_seconds).timeout
	if my_serial == _serial:
		_clear()

func _clear() -> void:
	for n in _lit:
		if is_instance_valid(n):
			n.call("set_scanned", false)
	_lit.clear()

func _spawn_ring() -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.94
	torus.outer_radius = 1.0
	ring.mesh = torus
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.0, 1.0, 1.0, 0.8)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = m
	actor.get_parent().add_child(ring)
	ring.global_position = actor.global_position + Vector3(0.0, 0.08, 0.0)
	var tw := ring.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector3(scan_radius, 1.0, scan_radius), 0.6)
	tw.tween_property(m, "albedo_color:a", 0.0, 0.6)
	tw.chain().tween_callback(ring.queue_free)
