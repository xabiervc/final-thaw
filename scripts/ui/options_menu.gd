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
	lbl.text = "Escala de texto: %.2f" % GameManager.font_scale
	vbox.add_child(lbl)
	var slider := HSlider.new()
	slider.min_value = 0.75
	slider.max_value = 2.0
	slider.step = 0.05
	slider.value = GameManager.font_scale
	slider.custom_minimum_size = Vector2(320, 24)
	slider.value_changed.connect(func(v):
		GameManager.font_scale = v
		lbl.text = "Escala de texto: %.2f" % v)
	vbox.add_child(slider)
	var back := Button.new()
	back.text = "Volver"
	back.pressed.connect(func():
		GameManager.save_game(0)
		GameManager.change_scene("res://scenes/ui/main_menu.tscn"))
	vbox.add_child(back)
	back.grab_focus()
