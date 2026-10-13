extends "res://scripts/components/interactable.gd"

signal activated(actor: Node3D)

@export var powered: bool = true
@export var unpowered_message: String = "El terminal no tiene energía."
@export var message: String = ""

var is_active: bool = false
var _screen: MeshInstance3D = null
var _light: OmniLight3D = null

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Usar terminal"
	make_solid(Vector3(1.0, 1.3, 0.8))
	B.box(self, Vector3(1.0, 1.0, 0.7), Vector3(0.0, 0.5, 0.0), Color(0.12, 0.15, 0.18))
	var tilt := B.box(self, Vector3(0.9, 0.55, 0.08), Vector3(0.0, 1.2, 0.2), Color(0.1, 0.12, 0.15))
	tilt.rotation_degrees.x = -25.0
	_screen = B.box(self, Vector3(0.78, 0.4, 0.02), Vector3(0.0, 1.22, 0.25), Color(0.95, 0.7, 0.25), 2.0)
	_screen.rotation_degrees.x = -25.0
	_light = OmniLight3D.new()
	_light.omni_range = 3.0
	_light.position = Vector3(0.0, 1.3, 0.8)
	add_child(_light)
	_refresh()

func set_powered(value: bool) -> void:
	powered = value
	_refresh()

func _refresh() -> void:
	var color := Color(0.95, 0.7, 0.25)
	if not powered:
		color = Color(0.25, 0.27, 0.3)
	elif is_active:
		color = Color(0.25, 0.9, 1.0)
	B.set_glow(_screen, color, 2.0 if powered else 0.3)
	_light.light_color = color
	_light.light_energy = 0.6 if powered else 0.0

func _on_interact(actor: Node3D) -> void:
	if not powered:
		show_message(unpowered_message)
		return
	is_active = true
	_refresh()
	if not message.is_empty():
		show_message(message)
	activated.emit(actor)

func get_state() -> Dictionary:
	return {"active": is_active}

func apply_state(state: Dictionary) -> void:
	is_active = bool(state.get("active", false))
	_refresh()
