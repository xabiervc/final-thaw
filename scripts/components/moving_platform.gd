extends AnimatableBody3D

const B = preload("res://scripts/components/build_util.gd")

@export var save_id: String = ""
@export var end_a: Vector3 = Vector3.ZERO
@export var end_b: Vector3 = Vector3.ZERO
@export var plat_size: Vector3 = Vector3(3.0, 0.4, 5.0)
@export var travel_time: float = 3.0
@export var wait_time: float = 2.0
@export var auto_cycle: bool = false
@export var powered: bool = true
@export var initial_idx: int = 0

var idx: int = 0
var moving: bool = false
var paused: bool = false
var _target: int = 0
var _progress: float = 0.0
var _wait_left: float = 0.0
var _label: Label3D = null

func _ready() -> void:
	add_to_group("saveables")
	collision_layer = 1
	collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = plat_size
	cs.shape = shape
	add_child(cs)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = plat_size
	mi.mesh = mesh
	mi.material_override = B.mat(Color(0.34, 0.37, 0.41), 0.6)
	add_child(mi)
	B.box(self, Vector3(plat_size.x, 0.03, 0.2), Vector3(0.0, plat_size.y * 0.5, plat_size.z * 0.5 - 0.15), Color(0.95, 0.7, 0.1), 1.5)
	B.box(self, Vector3(plat_size.x, 0.03, 0.2), Vector3(0.0, plat_size.y * 0.5, -plat_size.z * 0.5 + 0.15), Color(0.95, 0.7, 0.1), 1.5)
	_label = B.label3d(self, "", Vector3(0.0, 1.8, 0.0), 36, Color(1.0, 0.8, 0.4))
	idx = clampi(initial_idx, 0, 1)
	position = _end(idx)
	_wait_left = wait_time
	_refresh_label()

func _end(i: int) -> Vector3:
	if i == 0:
		return end_a
	return end_b

func _physics_process(delta: float) -> void:
	if not powered or paused:
		return
	if moving:
		_progress = minf(1.0, _progress + delta / travel_time)
		position = _end(idx).lerp(_end(_target), smoothstep(0.0, 1.0, _progress))
		if _progress >= 1.0:
			idx = _target
			moving = false
			_wait_left = wait_time
			_refresh_label()
	elif auto_cycle:
		_wait_left -= delta
		if _wait_left <= 0.0:
			request_move(1 - idx)

func request_move(target: int) -> void:
	if moving or paused or not powered:
		return
	if target == idx:
		return
	_target = target
	_progress = 0.0
	moving = true

func toggle_pause() -> void:
	paused = not paused
	_refresh_label()

func set_powered(value: bool) -> void:
	powered = value
	_refresh_label()

func _refresh_label() -> void:
	var text := ""
	if not powered:
		text = "SIN ENERGÍA"
	elif paused:
		text = "DETENIDA"
	_label.text = text
	_label.visible = text != ""

func get_state() -> Dictionary:
	var current := idx
	if moving:
		current = _target
	return {"idx": current, "paused": paused}

func apply_state(state: Dictionary) -> void:
	idx = clampi(int(state.get("idx", idx)), 0, 1)
	moving = false
	_progress = 0.0
	paused = bool(state.get("paused", false))
	_wait_left = wait_time
	position = _end(idx)
	_refresh_label()
