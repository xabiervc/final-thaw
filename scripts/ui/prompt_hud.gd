extends CanvasLayer

var _section_label: Label = null
var _objective: Label = null
var _hint: Label = null
var _instructions: Label = null
var _prompt: Label = null
var _status: Label = null
var _condition: Label = null
var _cond_bar: ProgressBar = null
var _last_prompt: String = ""
var _tween: Tween = null

func _ready() -> void:
	layer = 10
	var top := PanelContainer.new()
	top.position = Vector2(20.0, 16.0)
	top.custom_minimum_size = Vector2(540.0, 0.0)
	top.add_theme_stylebox_override("panel", _objective_style())
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	top.add_child(box)
	_section_label = _make_label(box, 11, Color(0.35, 0.83, 0.85))
	_section_label.text = "DIRECTIVA DE MISIÓN  /  ASTER"
	_objective = _make_label(box, 20, Color(0.94, 0.96, 0.95))
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective.custom_minimum_size = Vector2(510.0, 0.0)
	_hint = _make_label(box, 15, Color(0.95, 0.88, 0.55))
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size = Vector2(510.0, 0.0)
	_hint.visible = false
	_instructions = _make_label(box, 13, Color(0.72, 0.8, 0.84))
	_instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_instructions.custom_minimum_size = Vector2(510.0, 0.0)
	_instructions.text = NarrativeTextManager.get_prompt_instructions()

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 15)
	_status.add_theme_color_override("font_color", Color(0.6, 0.92, 0.95))
	_status.add_theme_stylebox_override("normal", _style())
	_status.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_status.offset_left = -320.0
	_status.offset_right = -20.0
	_status.offset_top = 16.0
	_status.offset_bottom = 56.0
	_status.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_status.visible = false
	add_child(_status)

	_condition = Label.new()
	_condition.add_theme_font_size_override("font_size", 14)
	_condition.add_theme_color_override("font_color", Color(0.85, 0.95, 0.92))
	_condition.add_theme_stylebox_override("normal", _style())
	_condition.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_condition.offset_left = -320.0
	_condition.offset_right = -20.0
	_condition.offset_top = 62.0
	_condition.offset_bottom = 100.0
	_condition.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_condition.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_condition.visible = false
	add_child(_condition)

	_cond_bar = ProgressBar.new()
	_cond_bar.min_value = 0.0
	_cond_bar.max_value = 100.0
	_cond_bar.show_percentage = false
	_cond_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_cond_bar.offset_left = -320.0
	_cond_bar.offset_right = -20.0
	_cond_bar.offset_top = 104.0
	_cond_bar.offset_bottom = 114.0
	_cond_bar.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_cond_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cond_bar.visible = false
	add_child(_cond_bar)

	_prompt = Label.new()
	_prompt.add_theme_font_size_override("font_size", 20)
	_prompt.add_theme_color_override("font_color", Color(0.55, 0.9, 0.82))
	_prompt.add_theme_stylebox_override("normal", _style())
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.offset_top = -255.0
	_prompt.offset_bottom = -215.0
	_prompt.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.modulate.a = 0.0
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_prompt)

	GameManager.stats_changed.connect(_apply_accessibility)
	_apply_accessibility()

func _objective_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.025, 0.04, 0.055, 0.91)
	s.border_color = Color(0.18, 0.55, 0.61, 0.9)
	s.border_width_left = 3
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	s.set_corner_radius_all(5)
	s.content_margin_left = 14.0
	s.content_margin_right = 14.0
	s.content_margin_top = 10.0
	s.content_margin_bottom = 10.0
	return s

func _style() -> StyleBoxFlat:
	var alpha := 0.98 if AccessibilityManager.is_high_contrast() else 0.82
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.03, 0.05, 0.07, alpha)
	s.set_corner_radius_all(6)
	s.content_margin_left = 14.0
	s.content_margin_right = 14.0
	s.content_margin_top = 8.0
	s.content_margin_bottom = 8.0
	return s

func _make_label(parent: Node, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func _apply_accessibility() -> void:
	var scale := AccessibilityManager.ui_scale()
	_objective.add_theme_font_size_override("font_size", int(18 * scale))
	_hint.add_theme_font_size_override("font_size", int(15 * scale))
	_instructions.add_theme_font_size_override("font_size", int(13 * scale))
	_status.add_theme_font_size_override("font_size", int(15 * scale))
	_condition.add_theme_font_size_override("font_size", int(14 * scale))
	_prompt.add_theme_font_size_override("font_size", int(20 * scale))

	var high_contrast := AccessibilityManager.is_high_contrast()
	var text_color := Color.WHITE if high_contrast else Color(0.94, 0.96, 0.95)
	var hint_color := Color(1.0, 0.95, 0.65) if high_contrast else Color(0.95, 0.88, 0.55)
	var instructions_color := Color(0.9, 0.95, 1.0) if high_contrast else Color(0.72, 0.8, 0.84)
	var prompt_color := Color(0.75, 1.0, 0.95) if high_contrast else Color(0.55, 0.9, 0.82)

	_objective.add_theme_color_override("font_color", text_color)
	_hint.add_theme_color_override("font_color", hint_color)
	_instructions.add_theme_color_override("font_color", instructions_color)
	_prompt.add_theme_color_override("font_color", prompt_color)

func _process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	var c = null
	if p != null:
		c = p.get("condition")
	if c == null:
		_condition.visible = false
		_cond_bar.visible = false
		return
	_update_condition(c)

func _update_condition(c) -> void:
	var state := str(c.state_name())
	var text: String = NarrativeTextManager.get_prompt_condition(
		int(round(c.stamina)),
		state,
		c.load_factor > 0.0
	)
	_condition.text = text
	_cond_bar.value = c.stamina
	var tint := Color(0.4, 0.9, 0.8)
	match state:
		"fatiga":
			tint = Color(0.95, 0.85, 0.4)
		"exhausta":
			tint = Color(0.95, 0.6, 0.3)
		"critica":
			tint = Color(0.95, 0.35, 0.3)
	_cond_bar.modulate = tint
	_condition.visible = true
	_cond_bar.visible = true

func set_objective(text: String) -> void:
	var clean_text := text
	if clean_text.begins_with("OBJETIVO  /  "):
		clean_text = clean_text.trim_prefix("OBJETIVO  /  ")
		_section_label.text = "DIRECTIVA DE MISIÓN  /  ASTER"
	elif clean_text.begins_with("SALA SUPERADA  /  "):
		clean_text = clean_text.trim_prefix("SALA SUPERADA  /  ")
		_section_label.text = "OBJETIVO COMPLETADO"
	_objective.text = clean_text

func set_hint(text: String) -> void:
	if _hint.text != text:
		_hint.text = text
	_hint.visible = not text.is_empty()

func set_status(text: String) -> void:
	if _status.text != text:
		_status.text = text
	_status.visible = not text.is_empty()

func set_prompt(text: String) -> void:
	if text == _last_prompt:
		return
	_last_prompt = text
	if _tween != null:
		_tween.kill()

	var duration := AccessibilityManager.animation_duration(0.2)
	if duration <= 0.0:
		_prompt.text = text
		_prompt.modulate.a = 1.0 if not text.is_empty() else 0.0
		return

	_tween = create_tween()
	if text.is_empty():
		_tween.tween_property(_prompt, "modulate:a", 0.0, duration)
	else:
		_prompt.text = text
		_tween.tween_property(_prompt, "modulate:a", 1.0, duration)
