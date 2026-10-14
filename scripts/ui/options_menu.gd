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
	var lbl := Label.new()
	lbl.text = _scale_text()
	vbox.add_child(lbl)
	var slider := HSlider.new()
	slider.min_value = 0.75
	slider.max_value = 2.0
	slider.step = 0.05
	slider.value = GameManager.font_scale
	slider.custom_minimum_size = Vector2(320, 24)
	slider.value_changed.connect(func(v):
		GameManager.font_scale = v
		lbl.text = _scale_text())
	vbox.add_child(slider)
	var back := Button.new()
	back.text = _back_text()
	back.add_theme_font_size_override("font_size", int(18.0 * clampf(GameManager.font_scale, 0.75, 2.0)))
	back.pressed.connect(func():
		GameManager.save_game(0)
		GameManager.change_scene("res://scenes/ui/main_menu.tscn"))
	vbox.add_child(back)
	back.grab_focus()

func _scale_text() -> String:
	var template: String = NarrativeTextManager.get_options_text_scale()
	if template.is_empty():
		template = "Text scale: %.2f"
	return template % GameManager.font_scale

func _back_text() -> String:
	var text: String = NarrativeTextManager.get_options_back_button()
	return text if not text.is_empty() else ("Volver" if NarrativeTextManager.current_locale == "es" else "Back")
