extends StaticBody2D
## Obstáculo bajo: bloquea el avance normal, pero puede cruzarse con el impulso.

@export var size: Vector2 = Vector2(160, 48)
@export var color: Color = Color(0.75, 0.55, 0.25)

const LOW_OBSTACLE_LAYER := 4

func _ready() -> void:
	collision_layer = 1 << (LOW_OBSTACLE_LAYER - 1)
	collision_mask = 0
	var visual := ColorRect.new()
	visual.color = color
	visual.size = size
	visual.position = -size / 2.0
	add_child(visual)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = size
	shape.shape = rectangle
	add_child(shape)
