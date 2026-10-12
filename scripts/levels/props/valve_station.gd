extends Node2D
class_name ValveStation

@export var is_open: bool = false

const INTERACTABLE_SCRIPT = preload("res://scripts/entities/interactable.gd")
var interactable: Area2D

signal valve_opened

func _ready() -> void:
	interactable = INTERACTABLE_SCRIPT.new() as Area2D
	interactable.set("interact_text", "Abrir válvula")
	interactable.set("can_interact_func", Callable(self, "_can_interact"))
	interactable.set("on_interact_func", Callable(self, "_on_interact"))
	add_child(interactable)

func _can_interact(_interactor: Node2D) -> bool:
	return not is_open

func _on_interact(_interactor: Node2D) -> void:
	if is_open:
		return
	is_open = true
	valve_opened.emit()
