extends "res://scripts/components/interactable.gd"

@export var message: String = ""
@export var variant: int = 0

var seen: bool = false

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Examinar"
	match variant:
		1:
			make_solid(Vector3(0.7, 1.0, 0.5))
			B.box(self, Vector3(0.7, 1.0, 0.5), Vector3(0.0, 0.5, 0.0), Color(0.18, 0.2, 0.24))
			B.box(self, Vector3(0.5, 0.3, 0.04), Vector3(0.0, 0.75, 0.27), Color(0.3, 0.8, 0.9), 1.2)
		2:
			make_solid(Vector3(0.7, 0.9, 0.7))
			var barrel := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.35
			cyl.bottom_radius = 0.35
			cyl.height = 0.9
			barrel.mesh = cyl
			barrel.material_override = B.mat(Color(0.25, 0.3, 0.28), 0.6)
			barrel.position = Vector3(0.0, 0.45, 0.0)
			add_child(barrel)
		_:
			make_solid(Vector3(0.9, 0.7, 0.9))
			B.box(self, Vector3(0.9, 0.7, 0.9), Vector3(0.0, 0.35, 0.0), Color(0.34, 0.3, 0.25))
			B.box(self, Vector3(0.92, 0.08, 0.92), Vector3(0.0, 0.5, 0.0), Color(0.5, 0.42, 0.3))

func _on_interact(_actor: Node3D) -> void:
	seen = true
	if not message.is_empty():
		show_message(message)

func get_state() -> Dictionary:
	return {"seen": seen}

func apply_state(state: Dictionary) -> void:
	seen = bool(state.get("seen", false))
