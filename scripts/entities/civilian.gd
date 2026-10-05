extends Node2D
class_name Civilian

enum State { TRAPPED, RESCUED, DEAD }

@export var start_state: State = State.TRAPPED
@export var rescue_dialogue: String = "Gracias... pensé que no saldría de aquí."

var state: State = State.TRAPPED
var is_alive: bool = true

signal state_changed(new_state: State)
signal civilian_rescued

func _ready() -> void:
	state = start_state
	update_visuals()

func trap() -> void:
	if not is_alive:
		return
	state = State.TRAPPED
	state_changed.emit(state)
	update_visuals()

func rescue() -> void:
	if not is_alive or state != State.TRAPPED:
		return
	state = State.RESCUED
	state_changed.emit(state)
	civilian_rescued.emit()
	update_visuals()

func kill() -> void:
	if not is_alive:
		return
	is_alive = false
	state = State.DEAD
	state_changed.emit(state)
	update_visuals()

func update_visuals() -> void:
	# Placeholder: en el slice real esto cambiará sprites, animaciones, etc.
	match state:
		State.TRAPPED:
			modulate = Color(0.7, 0.7, 0.9)
		State.RESCUED:
			modulate = Color(0.9, 0.9, 0.7)
		State.DEAD:
			modulate = Color(0.4, 0.4, 0.4)
