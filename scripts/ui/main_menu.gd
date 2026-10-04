extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	var title := Label.new()
	title.text = "FINAL THAW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	vbox.add_child(title)
	var start := _btn(vbox, "Start", _on_start)
	var cont := _btn(vbox, "Continue", _on_continue)
	cont.disabled = not GameManager.has_save(0)
	_btn(vbox, "Options", func(): GameManager.change_scene("res://scenes/ui/options_menu.tscn"))
	_btn(vbox, "Credits", func(): GameManager.change_scene("res://scenes/ui/credits.tscn"))
	_btn(vbox, "Quit", func(): get_tree().quit())
	start.grab_focus()

func _btn(parent: Node, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 48)
	b.add_to_group("menu_button")
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

func _on_start() -> void:
	GameManager.new_game()
	GameManager.change_scene("res://scenes/levels/test_room.tscn")

func _on_continue() -> void:
	if GameManager.load_game(0):
		GameManager.change_scene("res://scenes/levels/test_room.tscn")
