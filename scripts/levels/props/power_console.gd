extends Node2D
class_name PowerConsole

@export var is_on: bool = false

const INTERACTABLE_SCRIPT = preload("res://scripts/entities/interactable.gd")
var interactable: Interactable

signal power_activated

func _ready() -> void:
	interactable = INTERACTABLE_SCRIPT.new()
	interactable.interact_text = NarrativeTextManager.get_interact_power_console(is_on)
	interactable.can_interact_func = Callable(self, "_can_interact")
	interactable.on_interact_func = Callable(self, "_on_interact")
	add_child(interactable)

	NarrativeTextManager.language_changed.connect(_on_language_changed)

func _exit_tree() -> void:
	if NarrativeTextManager.language_changed.is_connected(_on_language_changed):
		NarrativeTextManager.language_changed.disconnect(_on_language_changed)

func _can_interact(_interactor: Node2D) -> bool:
	return not is_on

func _on_interact(_interactor: Node2D) -> void:
	if is_on:
		return
	is_on = true
	update_prompt()
	power_activated.emit()

func update_prompt() -> void:
	if interactable:
		interactable.interact_text = NarrativeTextManager.get_interact_power_console(is_on)
		interactable.update_label()

func _on_language_changed(_locale: String) -> void:
	update_prompt()

func restore_state(power_on: bool) -> void:
	is_on = power_on
	update_prompt()
