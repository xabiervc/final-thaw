extends "res://scripts/components/interactable.gd"

const LABELS = ["Entrada A -> Salida 1", "Entrada A -> Salida 2", "Entrada B -> Salida 1"]

@export var correct_pairing: int = 1

var pairing: int = 0
var _lamp: MeshInstance3D = null
var _label: Label3D = null

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Cambiar emparejamiento"
	make_solid(Vector3(1.1, 1.0, 0.6))
	B.box(self, Vector3(1.1, 1.0, 0.6), Vector3(0.0, 0.5, 0.0), Color(0.16, 0.18, 0.22))
	_lamp = B.box(self, Vector3(0.3, 0.1, 0.05), Vector3(0.0, 0.85, 0.33), Color(0.95, 0.7, 0.25), 2.0)
	_label = B.label3d(self, "", Vector3(0.0, 1.6, 0.0), 32, Color.WHITE)
	_refresh()

func _on_interact(_actor: Node3D) -> void:
	pairing = (pairing + 1) % LABELS.size()
	_refresh()
	show_message("Unión: %s" % LABELS[pairing], 4.0)

func spark_reset() -> void:
	B.set_glow(_lamp, Color(1.0, 0.15, 0.1), 4.0)
	_label.text = "CHISPAS - REINICIANDO"
	await get_tree().create_timer(0.6).timeout
	pairing = 0
	_refresh()

func _refresh() -> void:
	_label.text = "UNIÓN: " + LABELS[pairing]
	B.set_glow(_lamp, Color(0.95, 0.7, 0.25), 2.0)

func get_state() -> Dictionary:
	return {"pairing": pairing}

func apply_state(state: Dictionary) -> void:
	pairing = clampi(int(state.get("pairing", 0)), 0, LABELS.size() - 1)
	_refresh()
