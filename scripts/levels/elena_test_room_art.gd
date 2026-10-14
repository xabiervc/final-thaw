extends Node3D
## Wrapper that runs the unmodified Phase 1 room (elena_test_room) and overlays the visual-only art dressing (decision D1).
## Switch back to the plain greybox by pointing main_menu.gd LEVEL_PATH at elena_test_room.tscn again.

const LEVEL_SCENE := "res://scenes/levels/elena_test_room.tscn"
const DressingScript := preload("res://scripts/levels/lab_art_dressing.gd")


func _ready() -> void:
	name = "ElenaTestRoomArt"
	var level := (load(LEVEL_SCENE) as PackedScene).instantiate()
	add_child(level)
	var dressing := DressingScript.new()
	dressing.profile = "phase1"
	add_child(dressing)
