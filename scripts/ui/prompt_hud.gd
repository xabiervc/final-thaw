extends CanvasLayer

var _objective: Label = null
var _instructions: Label = null
var _prompt: Label = null
var _last_prompt: String = ""
var _tween: Tween = null

func _ready() -> void:
	layer = 10
	var top := PanelContainer.new()
	top.position = Vector2(20.0, 16.0)
	top.add_theme_stylebox_override("panel", _style(0.88))
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	top.add_child(box)
	_objective = _make_label(box, 22, Color(0.94, 0.96, 0.95))
	_instructions = _make_label(box, 15, Color(0.72, 0.8, 0.84))
	_instructions.text = "WASD / flechas: mover   |   E: interactuar   |   Q / Tab: escanear   |   F5: guardar   F9: cargar   |   ESC: menú"
	_prompt = Label.new()
	_prompt.add_theme_font_size_override("font_size", 24)
	_prompt.add_theme_color_override("font_color", Color(0.55, 0.9, 0.82))
	_prompt.add_theme_stylebox_override("normal", _style(0.85))
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.offset_top = -255.0
	_prompt.offset_bottom = -215.0
	_prompt.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.modulate.a = 0.0
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_prompt)

func _style(alpha: float) -> StyleBoxFlat:
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

func set_objective(text: String) -> void:
	_objective.text = text

func set_prompt(text: String) -> void:
	if text == _last_prompt:
		return
	_last_prompt = text
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	if text.is_empty():
		_tween.tween_property(_prompt, "modulate:a", 0.0, 0.2)
	else:
		_prompt.text = text
		_tween.tween_property(_prompt, "modulate:a", 1.0, 0.2)
