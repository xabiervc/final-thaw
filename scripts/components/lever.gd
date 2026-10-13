extends "res://scripts/components/interactable.gd"

signal toggled(on: bool)

var is_on: bool = false
var _pivot: Node3D = null
var _lamp: MeshInstance3D = null

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Accionar palanca"
	make_solid(Vector3(0.9, 1.0, 0.6))
	B.box(self, Vector3(0.9, 0.5, 0.6), Vector3(0.0, 0.25, 0.0), Color(0.16, 0.18, 0.21))
	_lamp = B.box(self, Vector3(0.18, 0.08, 0.05), Vector3(0.0, 0.35, 0.31), Color(0.85, 0.2, 0.2), 2.0)
	_pivot = Node3D.new()
	_pivot.position = Vector3(0.0, 0.55, 0.0)
	add_child(_pivot)
	B.box(_pivot, Vector3(0.1, 0.9, 0.1), Vector3(0.0, 0.45, 0.0), Color(0.55, 0.58, 0.62))
	B.box(_pivot, Vector3(0.2, 0.2, 0.2), Vector3(0.0, 0.95, 0.0), Color(0.9, 0.7, 0.2), 1.0)
	_pivot.rotation_degrees.z = -35.0

func _on_interact(_actor: Node3D) -> void:
	set_on(not is_on, true)
	if is_on:
		show_message("Palanca activada. Se oye un zumbido en la puerta de salida.")
	else:
		show_message("Palanca desactivada. La puerta de salida se queda sin energía.")

func set_on(value: bool, animate: bool = false) -> void:
	is_on = value
	var target_deg := 35.0 if is_on else -35.0
	if animate:
		create_tween().tween_property(_pivot, "rotation_degrees:z", target_deg, 0.25)
	else:
		_pivot.rotation_degrees.z = target_deg
	var lamp_color := Color(0.2, 0.9, 0.5) if is_on else Color(0.85, 0.2, 0.2)
	B.set_glow(_lamp, lamp_color, 2.0)
	toggled.emit(is_on)

func get_state() -> Dictionary:
	return {"on": is_on}

func apply_state(state: Dictionary) -> void:
	set_on(bool(state.get("on", false)), false)
