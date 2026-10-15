extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	var lbl := Label.new()
	lbl.text = _title_text()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", int(28.0 * clampf(GameManager.font_scale, 0.75, 2.0)))
	vbox.add_child(lbl)
	var body := Label.new()
	body.text = GameText.t("credits_body")
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(760, 0)
	body.add_theme_font_size_override("font_size", int(15.0 * clampf(GameManager.font_scale, 0.75, 2.0)))
	vbox.add_child(body)
	var back := Button.new()
	back.text = _back_text()
	back.add_theme_font_size_override("font_size", int(18.0 * clampf(GameManager.font_scale, 0.75, 2.0)))
	back.pressed.connect(func(): GameManager.change_scene("res://scenes/ui/main_menu.tscn"))
	vbox.add_child(back)
	back.grab_focus()

func _title_text() -> String:
	return GameText.t("credits_title")

func _back_text() -> String:
	var text: String = NarrativeTextManager.get_options_back_button()
	return text if not text.is_empty() else ("Volver" if NarrativeTextManager.current_locale == "es" else "Back")
