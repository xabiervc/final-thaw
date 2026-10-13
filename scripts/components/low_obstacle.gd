extends StaticBody3D

const B = preload("res://scripts/components/build_util.gd")

@export var obstacle_size: Vector3 = Vector3(2.4, 0.45, 0.8)
@export var color: Color = Color(0.55, 0.42, 0.22)

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = obstacle_size
	cs.shape = shape
	cs.position = Vector3(0.0, obstacle_size.y * 0.5, 0.0)
	add_child(cs)
	B.box(self, obstacle_size, Vector3(0.0, obstacle_size.y * 0.5, 0.0), color)
