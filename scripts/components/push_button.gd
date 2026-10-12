extends "res://scripts/components/interactable.gd"

signal pressed

@export var button_color: Color = Color(0.2, 0.7, 0.9)

var _top: MeshInstance3D = null

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Pulsar"
	B.box(self, Vector3(0.5, 0.7, 0.5), Vector3(0.0, 0.35, 0.0), Color(0.16, 0.18, 0.22))
	_top = B.box(self, Vector3(0.36, 0.1, 0.36), Vector3(0.0, 0.75, 0.0), button_color, 2.0)

func _on_interact(_actor: Node3D) -> void:
	pressed.emit()
	B.set_glow(_top, Color(1.0, 1.0, 1.0), 4.0)
	get_tree().create_timer(0.2).timeout.connect(_restore)

func _restore() -> void:
	B.set_glow(_top, button_color, 2.0)
