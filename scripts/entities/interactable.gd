extends Area2D
class_name Interactable

@export var interact_text: String = "Interactuable"
var interact_count: int = 0
var can_interact_func: Callable
var on_interact_func: Callable

signal interacted(interactor: Node2D)

func _ready() -> void:
	add_to_group("interactable")
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(100, 100)
	cs.shape = shape
	add_child(cs)
	var vis := ColorRect.new()
	vis.color = Color("ffd600")
	vis.size = Vector2(100, 100)
	vis.position = Vector2(-50, -50)
	vis.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vis)
	var lbl := Label.new()
	lbl.text = interact_text
	lbl.position = Vector2(-50, -80)
	add_child(lbl)

func can_interact(_interactor: Node2D) -> bool:
	if can_interact_func.is_valid():
		return can_interact_func.call(_interactor)
	return true

func try_interact(interactor: Node2D) -> bool:
	if not can_interact(interactor):
		return false
	if on_interact_func.is_valid():
		on_interact_func.call(interactor)
	interact_count += 1
	interacted.emit(interactor)
	return true

func interact(interactor: Node2D = null) -> bool:
	return try_interact(interactor)
