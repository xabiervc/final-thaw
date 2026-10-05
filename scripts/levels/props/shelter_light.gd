extends Node2D
class_name ShelterLight

@export var is_on: bool = false

var light: PointLight2D
var sprite: Sprite2D

func _ready() -> void:
	light = $PointLight2D if has_node("PointLight2D") else null
	sprite = $Sprite2D if has_node("Sprite2D") else null
	update_state()

func set_power(on: bool) -> void:
	is_on = on
	update_state()

func update_state() -> void:
	if light:
		light.enabled = is_on
	if sprite:
		sprite.visible = is_on
		if is_on:
			sprite.modulate = Color(1.0, 0.9, 0.6)
		else:
			sprite.modulate = Color(0.3, 0.3, 0.35)
