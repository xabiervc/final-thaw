extends Node3D
## Wrapper that runs the unmodified Abandoned Lab level and overlays the visual-only art dressing (decision D1).
## Switch back to the plain greybox by pointing elena_test_room.gd NEXT_PATH at abandoned_lab.tscn again.

const LEVEL_SCENE := "res://scenes/levels/abandoned_lab.tscn"
const DressingScript := preload("res://scripts/levels/lab_art_dressing.gd")
const ComponentsScript := preload("res://scripts/levels/lab_art_components.gd")


func _ready() -> void:
	name = "AbandonedLabArt"
	var level := (load(LEVEL_SCENE) as PackedScene).instantiate()
	add_child(level)
	var dressing := DressingScript.new()
	dressing.profile = "lab"
	add_child(dressing)
	add_child(ComponentsScript.new())
