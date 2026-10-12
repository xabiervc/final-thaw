extends "res://scripts/components/interactable.gd"

@export var message: String = "Terminal: sistemas en espera. La palanca del ala este alimenta la puerta de salida."

var accessed: bool = false
var _screen: MeshInstance3D = null
var _light: OmniLight3D = null

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Acceder"
	B.box(self, Vector3(1.0, 1.0, 0.7), Vector3(0.0, 0.5, 0.0), Color(0.12, 0.15, 0.18))
	var tilt := B.box(self, Vector3(0.9, 0.55, 0.08), Vector3(0.0, 1.2, 0.2), Color(0.1, 0.12, 0.15))
	tilt.rotation_degrees.x = -25.0
	_screen = B.box(self, Vector3(0.78, 0.4, 0.02), Vector3(0.0, 1.22, 0.25), Color(0.95, 0.7, 0.25), 2.0)
	_screen.rotation_degrees.x = -25.0
	_light = OmniLight3D.new()
	_light.light_color = Color(0.95, 0.7, 0.25)
	_light.light_energy = 0.6
	_light.omni_range = 3.0
	_light.position = Vector3(0.0, 1.3, 0.8)
	add_child(_light)

func _on_interact(_actor: Node3D) -> void:
	_set_accessed(true)
	show_message(message)

func _set_accessed(value: bool) -> void:
	accessed = value
	var color := Color(0.25, 0.9, 1.0) if accessed else Color(0.95, 0.7, 0.25)
	B.set_glow(_screen, color, 2.0)
	_light.light_color = color

func get_state() -> Dictionary:
	return {"accessed": accessed}

func apply_state(state: Dictionary) -> void:
	_set_accessed(bool(state.get("accessed", false)))
