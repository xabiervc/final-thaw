extends Node2D
class_name ValveStation

@export var is_open: bool = false

var interactable: Interactable

signal valve_opened

func _ready() -> void:
	interactable = Interactable.new()
	interactable.interaction_text = "Abrir válvula"
	interactable.can_interact_func = _can_interact
	interactable.on_interact_func = _on_interact
	add_child(interactable)

func _can_interact(interactor: Node2D) -> bool:
	return not is_open

func _on_interact(interactor: Node2D) -> void:
	if is_open:
		return
	is_open = true
	valve_opened.emit()
