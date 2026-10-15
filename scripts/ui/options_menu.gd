extends Control
## Main-menu options screen: hosts the shared OptionsPanel (also used by the in-game pause menu) on a backdrop and
## returns to the main menu when the panel closes (the panel saves the options itself).

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("0b1116")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var panel := OptionsPanel.new()
	add_child(panel)
	panel.closed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	GameManager.change_scene(MAIN_MENU_PATH)
