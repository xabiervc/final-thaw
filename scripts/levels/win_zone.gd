extends Area2D
class_name WinZone

var shelter: FloodedShelterController

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	shelter = get_tree().get_first_node_in_group("flooded_shelter")

func _on_body_entered(body: Node2D) -> void:
	if body is Elena and shelter:
		shelter.complete_level(true)
