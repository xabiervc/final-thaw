extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0.0, 8.5, 6.5)
@export var smoothing: float = 6.0
@export var limit_min: Vector2 = Vector2(-1000.0, -1000.0)
@export var limit_max: Vector2 = Vector2(1000.0, 1000.0)

func _ready() -> void:
	fov = 40.0
	rotation = Vector3(-atan2(offset.y, offset.z), 0.0, 0.0)
	current = true
	if target != null:
		global_position = _desired()

func _desired() -> Vector3:
	var p := target.global_position
	p.x = clampf(p.x, limit_min.x, limit_max.x)
	p.z = clampf(p.z, limit_min.y, limit_max.y)
	return p + offset

func _process(delta: float) -> void:
	if target == null:
		return
	global_position = global_position.lerp(_desired(), 1.0 - exp(-smoothing * delta))
