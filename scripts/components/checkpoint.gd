extends Node3D

const B = preload("res://scripts/components/build_util.gd")

signal reached(checkpoint: Node3D)

@export var checkpoint_id: String = ""
@export var save_id: String = ""
@export var trigger_radius: float = 1.8

var triggered: bool = false
var _parts: Array = []

func _ready() -> void:
	add_to_group("saveables")
	_parts.append(B.box(self, Vector3(0.2, 2.6, 0.2), Vector3(0.0, 1.3, -1.2), Color(0.2, 0.7, 0.9), 2.0))
	_parts.append(B.box(self, Vector3(0.2, 2.6, 0.2), Vector3(0.0, 1.3, 1.2), Color(0.2, 0.7, 0.9), 2.0))
	_parts.append(B.box(self, Vector3(0.2, 0.2, 2.6), Vector3(0.0, 2.6, 0.0), Color(0.2, 0.7, 0.9), 2.0))
	for pz in [-1.2, 1.2]:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = Vector3(0.0, 1.3, pz)
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.3, 2.6, 0.3)
		cs.shape = shape
		body.add_child(cs)
		add_child(body)
	B.label3d(self, "PUNTO DE CONTROL", Vector3(0.0, 3.3, 0.0), 36, Color(0.6, 0.95, 1.0))
	_refresh()

func _process(_delta: float) -> void:
	if triggered:
		return
	var p := get_tree().get_first_node_in_group("player") as Node3D
	if p == null:
		return
	var d := Vector2(p.global_position.x - global_position.x, p.global_position.z - global_position.z).length()
	if d <= trigger_radius:
		triggered = true
		_refresh()
		reached.emit(self)

func _refresh() -> void:
	var color := Color(0.2, 0.9, 0.55) if triggered else Color(0.2, 0.7, 0.9)
	for part in _parts:
		B.set_glow(part, color, 2.0)

func get_state() -> Dictionary:
	return {"triggered": triggered}

func apply_state(state: Dictionary) -> void:
	triggered = bool(state.get("triggered", false))
	_refresh()
