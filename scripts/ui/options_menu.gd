extends Control

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"

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

	var scale_label := Label.new()
	scale_label.text = _scale_text()
	vbox.add_child(scale_label)

	var slider := HSlider.new()
	slider.min_value = 0.75
	slider.max_value = 2.0
	slider.step = 0.05
	slider.value = GameManager.font_scale
	slider.custom_minimum_size = Vector2(320, 24)
	slider.value_changed.connect(func(v):
		GameManager.font_scale = v
		scale_label.text = _scale_text())
	vbox.add_child(slider)

	var contrast_check := CheckButton.new()
	contrast_check.text = _contrast_text()
	contrast_check.button_pressed = GameManager.get_flag("accessibility_high_contrast")
	contrast_check.toggled.connect(func(pressed: bool):
		GameManager.set_flag("accessibility_high_contrast", pressed)
		GameManager.stats_changed.emit())
	vbox.add_child(contrast_check)

	var motion_check := CheckButton.new()
	motion_check.text = _motion_text()
	motion_check.button_pressed = GameManager.get_flag("accessibility_reduced_motion")
	motion_check.toggled.connect(func(pressed: bool):
		GameManager.set_flag("accessibility_reduced_motion", pressed)
		GameManager.stats_changed.emit())
	vbox.add_child(motion_check)

	var subtitle_label := Label.new()
	subtitle_label.text = _subtitle_text()
	vbox.add_child(subtitle_label)

	var subtitle_option := OptionButton.new()
	subtitle_option.add_item(_subtitle_none_text(), 0)
	subtitle_option.add_item(_subtitle_dim_text(), 1)
	subtitle_option.add_item(_subtitle_solid_text(), 2)
	subtitle_option.selected = clampi(GameManager.subtitle_size, 0, 2)
	subtitle_option.item_selected.connect(func(index: int):
		GameManager.subtitle_size = index
		GameManager.stats_changed.emit())
	vbox.add_child(subtitle_option)

	var colorblind_label := Label.new()
	colorblind_label.text = _colorblind_text()
	vbox.add_child(colorblind_label)

	var colorblind_option := OptionButton.new()
	colorblind_option.add_item(_colorblind_none_text(), 0)
	colorblind_option.add_item(_colorblind_deuteranopia_text(), 1)
	colorblind_option.add_item(_colorblind_protanopia_text(), 2)
	colorblind_option.add_item(_colorblind_tritanopia_text(), 3)
	colorblind_option.selected = AccessibilityManager.colorblind_mode()
	colorblind_option.item_selected.connect(func(index: int):
		GameManager.colorblind_mode = index
		GameManager.stats_changed.emit())
	vbox.add_child(colorblind_option)

	var back := Button.new()
	back.text = _back_text()
	back.add_theme_font_size_override("font_size", int(18.0 * AccessibilityManager.ui_scale()))
	back.pressed.connect(_on_back_pressed)
	vbox.add_child(back)
	back.grab_focus()

func _scale_text() -> String:
	var template: String = NarrativeTextManager.get_options_text_scale()
	if template.is_empty():
		template = "Text scale: %.2f"
	return template % GameManager.font_scale

func _contrast_text() -> String:
	var text: String = NarrativeTextManager.get_options_high_contrast()
	return text if not text.is_empty() else ("Alto contraste" if NarrativeTextManager.current_locale == "es" else "High contrast")

func _motion_text() -> String:
	var text: String = NarrativeTextManager.get_options_reduced_motion()
	return text if not text.is_empty() else ("Reducir movimiento" if NarrativeTextManager.current_locale == "es" else "Reduce motion")

func _subtitle_text() -> String:
	var text: String = NarrativeTextManager.get_options_subtitle_background()
	return text if not text.is_empty() else ("Fondo de subtítulos" if NarrativeTextManager.current_locale == "es" else "Subtitle background")

func _subtitle_none_text() -> String:
	var text: String = NarrativeTextManager.get_options_subtitle_none()
	return text if not text.is_empty() else ("Ninguno" if NarrativeTextManager.current_locale == "es" else "None")

func _subtitle_dim_text() -> String:
	var text: String = NarrativeTextManager.get_options_subtitle_dim()
	return text if not text.is_empty() else ("Tenue" if NarrativeTextManager.current_locale == "es" else "Dim")

func _subtitle_solid_text() -> String:
	var text: String = NarrativeTextManager.get_options_subtitle_solid()
	return text if not text.is_empty() else ("Sólido" if NarrativeTextManager.current_locale == "es" else "Solid")

func _colorblind_text() -> String:
	var text: String = NarrativeTextManager.get_options_colorblind_mode()
	return text if not text.is_empty() else ("Modo daltónico" if NarrativeTextManager.current_locale == "es" else "Colorblind mode")

func _colorblind_none_text() -> String:
	var text: String = NarrativeTextManager.get_options_colorblind_none()
	return text if not text.is_empty() else ("Ninguno" if NarrativeTextManager.current_locale == "es" else "None")

func _colorblind_deuteranopia_text() -> String:
	var text: String = NarrativeTextManager.get_options_colorblind_deuteranopia()
	return text if not text.is_empty() else "Deuteranopia"

func _colorblind_protanopia_text() -> String:
	var text: String = NarrativeTextManager.get_options_colorblind_protanopia()
	return text if not text.is_empty() else "Protanopia"

func _colorblind_tritanopia_text() -> String:
	var text: String = NarrativeTextManager.get_options_colorblind_tritanopia()
	return text if not text.is_empty() else "Tritanopia"

func _back_text() -> String:
	var text: String = NarrativeTextManager.get_options_back_button()
	return text if not text.is_empty() else ("Volver" if NarrativeTextManager.current_locale == "es" else "Back")

func _on_back_pressed() -> void:
	GameManager.save_game(0)
	GameManager.change_scene(MAIN_MENU_PATH)
