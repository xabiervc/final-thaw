extends "res://scripts/components/interactable.gd"

signal opened

@export var locked: bool = true
@export var door_size: Vector3 = Vector3(0.4, 3.0, 2.8)
@export var locked_message: String = "La puerta está bloqueada. No hay energía en el circuito."

var is_open: bool = false
var _slab: StaticBody3D = null
var _strip: MeshInstance3D = null

func _ready() -> void:
	super()
	_slab = B.solid_box(self, door_size, Vector3(0.0, door_size.y * 0.5, 0.0), Color(0.34, 0.37, 0.41))
	_strip = B.box(self, Vector3(door_size.x + 0.2, 0.25, door_size.z + 0.3), Vector3(0.0, door_size.y + 0.12, 0.0), Color(0.85, 0.2, 0.2), 2.0)
	_refresh_strip()

func get_prompt() -> String:
	if is_open or not enabled:
		return ""
	if locked:
		return "Puerta bloqueada"
	return "Abrir puerta"

func set_locked(value: bool) -> void:
	locked = value
	_refresh_strip()

func _refresh_strip() -> void:
	if _strip == null:
		return
	var color := Color(0.85, 0.2, 0.2)
	if is_open or not locked:
		color = Color(0.2, 0.85, 0.5)
	B.set_glow(_strip, color, 2.0)

func _on_interact(_actor: Node3D) -> void:
	if is_open:
		return
	if locked:
		show_message(locked_message)
		return
	open_door(true)

func open_door(animate: bool = false) -> void:
	is_open = true
	enabled = false
	_slab.collision_layer = 0
	if animate:
		create_tween().tween_property(_slab, "position:z", door_size.z, 0.8)
	else:
		_slab.position.z = door_size.z
	_refresh_strip()
	opened.emit()

func _close_immediately() -> void:
	is_open = false
	enabled = true
	_slab.collision_layer = 1
	_slab.position.z = 0.0
	_refresh_strip()

func get_state() -> Dictionary:
	return {"open": is_open}

func apply_state(state: Dictionary) -> void:
	if bool(state.get("open", false)):
		open_door(false)
	else:
		_close_immediately()
