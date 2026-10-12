extends Node2D
class_name PowerConsole

@export var is_on: bool = false

const INTERACTABLE_SCRIPT = preload("res://scripts/entities/interactable.gd")
var interactable: Area2D

signal power_activated

func _ready() -> void:
	interactable = INTERACTABLE_SCRIPT.new() as Area2D
	interactable.set("interact_text", "Activar generador")
	interactable.add_user_signal("interacted")
	interactable.connect("interacted", _on_interact)
	add_child(interactable)

func _on_interact() -> void:
	if is_on:
		return
	is_on = true
	power_activated.emit()
