extends Node2D
class_name PowerConsole

@export var is_on: bool = false

var interactable: Interactable

signal power_activated

func _ready() -> void:
	interactable = Interactable.new()
	interactable.interaction_text = "Activar generador"
	interactable.can_interact_func = _can_interact
	interactable.on_interact_func = _on_interact
	add_child(interactable)

func _can_interact(interactor: Node2D) -> bool:
	return not is_on

func _on_interact(interactor: Node2D) -> void:
	if is_on:
		return
	is_on = true
	power_activated.emit()
