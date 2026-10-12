extends AnimatableBody3D

const B = preload("res://scripts/components/build_util.gd")

signal settled(index: int)

@export var save_id: String = "arm"
@export var rotate_seconds: float = 2.0

var index: int = 0
var is_moving: bool = false
var _label: Label3D = null

func _ready() -> void:
	add_to_group("saveables")
	collision_layer = 1
	collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.7, 2.2, 4.8)
	cs.shape = shape
	cs.position = Vector3(0.0, 1.1, 0.8)
	add_child(cs)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.7, 2.2, 4.8)
	mi.mesh = mesh
	mi.material_override = B.mat(Color(0.9, 0.5, 0.12), 0.6)
	mi.position = Vector3(0.0, 1.1, 0.8)
	add_child(mi)
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.6
	base_mesh.bottom_radius = 0.6
	base_mesh.height = 0.3
	var base := MeshInstance3D.new()
	base.mesh = base_mesh
	base.material_override = B.mat(Color(0.2, 0.22, 0.26), 0.5)
	base.position = Vector3(0.0, 0.15, 0.0)
	add_child(base)
	_label = B.label3d(self, "", Vector3(0.0, 3.0, 0.0), 40, Color(1.0, 0.8, 0.4))
	_refresh_label()

func rotate_next() -> void:
	if is_moving:
		return
	is_moving = true
	_refresh_label()
	var tw := create_tween()
	tw.tween_property(self, "rotation_degrees:y", rotation_degrees.y + 90.0, rotate_seconds)
	tw.tween_callback(_on_rotation_done)

func _on_rotation_done() -> void:
	index = (index + 1) % 4
	is_moving = false
	_refresh_label()
	settled.emit(index)

func set_index(value: int) -> void:
	index = clampi(value, 0, 3)
	is_moving = false
	rotation_degrees.y = float(index) * 90.0
	_refresh_label()

func _refresh_label() -> void:
	if is_moving:
		_label.text = "BRAZO - EN MOVIMIENTO"
		return
	var free := index == 1 or index == 3
	_label.text = "BRAZO %d° - %s" % [index * 90, "LIBRE" if free else "BLOQUEA EL PASO"]

func get_state() -> Dictionary:
	return {"index": index}

func apply_state(state: Dictionary) -> void:
	set_index(int(state.get("index", 0)))
