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
	lbl.text = "FINAL THAW\nPrototipo Fase 0"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)
	var back := Button.new()
	back.text = "Volver"
	back.pressed.connect(func(): GameManager.change_scene("res://scenes/ui/main_menu.tscn"))
	vbox.add_child(back)
	back.grab_focus()
