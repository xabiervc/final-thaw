extends Node3D
## Wrapper that runs the Phase 1 room (elena_test_room) and overlays its visual-only art direction (decision D1):
## the Helix test-bay dressing and light rig (test_room_art/), plus the shared art for interactive components.
## Switch back to the plain greybox by pointing main_menu.gd LEVEL_PATH at elena_test_room.tscn again.

const LEVEL_SCENE := "res://scenes/levels/elena_test_room.tscn"
const DressingScript := preload("res://scripts/levels/test_room_art/test_room_dressing.gd")
const ComponentsScript := preload("res://scripts/levels/lab_art_components.gd")
## The bay is darker than the lab, so component status lights are toned down to stay readable instead of blooming.
const COMPONENT_EMISSION_SCALE := 0.45


func _ready() -> void:
	name = "ElenaTestRoomArt"
	var level := (load(LEVEL_SCENE) as PackedScene).instantiate()
	add_child(level)
	add_child(DressingScript.new())
	var components := ComponentsScript.new()
	components.emission_scale = COMPONENT_EMISSION_SCALE
	add_child(components)
