extends Area3D

const B = preload("res://scripts/components/build_util.gd")

@export var zone_size: Vector3 = Vector3(3.0, 2.0, 3.0)
@export var recovery_bonus: float = 0.0
@export var tint: Color = Color(0.9, 0.5, 0.2)
@export var zone_label: String = ""

var _affected: Array = []

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	monitorable = false
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = zone_size
	cs.shape = box
	cs.position = Vector3(0.0, zone_size.y * 0.5, 0.0)
	add_child(cs)
	B.box(self, Vector3(zone_size.x, 0.04, zone_size.z), Vector3(0.0, 0.02, 0.0), tint, 1.2)
	if zone_label != "":
		B.label3d(self, zone_label, Vector3(0.0, zone_size.y, 0.0), 36, tint)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _condition_of(body: Node):
	if body == null or not body.is_in_group("player"):
		return null
	return body.get("condition")

func _on_body_entered(body: Node3D) -> void:
	var c = _condition_of(body)
	if c == null or _affected.has(body):
		return
	_affected.append(body)
	c.recovery_bonus += recovery_bonus

func _on_body_exited(body: Node3D) -> void:
	var idx := _affected.find(body)
	if idx < 0:
		return
	_affected.remove_at(idx)
	var c = _condition_of(body)
	if c != null:
		c.recovery_bonus -= recovery_bonus

func _exit_tree() -> void:
	for body in _affected:
		if is_instance_valid(body):
			var c = _condition_of(body)
			if c != null:
				c.recovery_bonus -= recovery_bonus
	_affected.clear()
