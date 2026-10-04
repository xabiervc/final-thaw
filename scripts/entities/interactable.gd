extends Area2D

@export var interact_text: String = "Interactuable"
var interact_count: int = 0

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
	add_child(vis)
	var lbl := Label.new()
	lbl.text = interact_text
	lbl.position = Vector2(-50, -80)
	add_child(lbl)

func interact() -> void:
	interact_count += 1
	print("Interactuando con: ", interact_text, " (", interact_count, ")")
