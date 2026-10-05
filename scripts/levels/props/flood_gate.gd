extends Node2D
class_name FloodGate

@export var is_open: bool = false

var collision: CollisionShape2D

func _ready() -> void:
	collision = $CollisionShape2D if has_node("CollisionShape2D") else null
	update_state()

func open_gate() -> void:
	if is_open:
		return
	is_open = true
	update_state()

func close_gate() -> void:
	if not is_open:
		return
	is_open = false
	update_state()

func update_state() -> void:
	if collision:
		collision.disabled = is_open
	# Aquí iría la animación de abrir/cerrar
