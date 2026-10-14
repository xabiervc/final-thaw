extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0.0, 8.5, 6.5)
@export var smoothing: float = 6.0
@export var limit_min: Vector2 = Vector2(-1000.0, -1000.0)
@export var limit_max: Vector2 = Vector2(1000.0, 1000.0)
## Seconds of the target's horizontal velocity the camera leads by (0 = no lead, the original behaviour).
@export var look_ahead: float = 0.0
## Maximum lead distance in metres.
@export var look_ahead_max: float = 1.6

var _lead: Vector3 = Vector3.ZERO

func _ready() -> void:
	fov = 40.0
	rotation = Vector3(-atan2(offset.y, offset.z), 0.0, 0.0)
	current = true
	if target != null:
		global_position = _desired()

## Places the camera on its target immediately (after changing offset or limits).
func snap() -> void:
	_lead = Vector3.ZERO
	if target != null:
		global_position = _desired()

func _desired() -> Vector3:
	var p := target.global_position + _lead
	p.x = clampf(p.x, limit_min.x, limit_max.x)
	p.z = clampf(p.z, limit_min.y, limit_max.y)
	return p + offset

func _process(delta: float) -> void:
	if target == null:
		return
	if look_ahead > 0.0 and target is CharacterBody3D:
		var v := (target as CharacterBody3D).velocity
		var wanted := Vector3(v.x, 0.0, v.z) * look_ahead
		wanted = wanted.limit_length(look_ahead_max)
		_lead = _lead.lerp(wanted, 1.0 - exp(-2.5 * delta))
	global_position = global_position.lerp(_desired(), 1.0 - exp(-smoothing * delta))
