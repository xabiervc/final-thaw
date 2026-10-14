extends RefCounted
## Shared geometry for the lift gate: a lower landing to the south, an upper landing to the north, a shaft between them.
## Used by the manual scene and by the transport test so both exercise exactly the same space.
## Plan: the deck is 3 x 3 m centred on the origin. Lower landing at y = 0 for z 1.5..8, upper landing at y = 3 for
## z -8..-1.5 on a solid support, and a pit under the deck for the lower stop.

const ServiceLift = preload("res://scripts/prototypes/service_lift.gd")
const FLOOR_COLOR := Color(0.22, 0.25, 0.28)


static func _box(parent: Node3D, label: String, size: Vector3, center: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = FLOOR_COLOR
	material.roughness = 0.85
	mesh.material_override = material
	body.add_child(mesh)
	parent.add_child(body)


static func build(parent: Node3D) -> Node3D:
	_box(parent, "LowerLanding", Vector3(8.0, 0.25, 6.5), Vector3(0.0, -0.125, 4.75))
	_box(parent, "Pit", Vector3(3.0, 0.25, 3.0), Vector3(0.0, -0.625, 0.0))
	_box(parent, "UpperLanding", Vector3(8.0, 0.25, 6.5), Vector3(0.0, 2.875, -4.75))
	_box(parent, "UpperSupport", Vector3(8.0, 2.75, 6.5), Vector3(0.0, 1.375, -4.75))
	_box(parent, "ShaftEast", Vector3(0.2, 3.6, 3.0), Vector3(1.75, 1.8, 0.0))
	_box(parent, "ShaftWest", Vector3(0.2, 3.6, 3.0), Vector3(-1.75, 1.8, 0.0))
	var lift := ServiceLift.new()
	lift.name = "ServiceLift"
	parent.add_child(lift)
	return lift
