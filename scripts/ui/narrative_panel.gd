extends CanvasLayer

signal narrative_dismissed

var _panel: PanelContainer = null
var _label: Label = null
var _timer: Timer = null
var _shown_msec: int = 0

func _ready() -> void:
	layer = 20
	add_to_group("narrative_panel")
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 140.0
	_panel.offset_right = -140.0
	_panel.offset_top = -190.0
	_panel.offset_bottom = -60.0
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.07, 0.9)
	style.border_color = Color(0.25, 0.7, 0.8, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_hide_panel)
	add_child(_timer)
	GameManager.stats_changed.connect(_apply_accessibility)
	_apply_accessibility()

func _apply_accessibility() -> void:
	var scale := clampf(GameManager.font_scale, 0.75, 2.0)
	_label.add_theme_font_size_override("font_size", int(22.0 * scale))

	var high_contrast: bool = GameManager.get_flag("accessibility_high_contrast")
	var style: StyleBoxFlat = _panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style != null:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.98) if high_contrast else Color(0.03, 0.05, 0.07, 0.9)
		style.border_color = Color(1.0, 1.0, 1.0, 1.0) if high_contrast else Color(0.25, 0.7, 0.8, 0.9)
	_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color(0.94, 0.96, 0.95))

func show_message(text: String, duration: float = 8.0) -> void:
	_label.text = text
	_panel.visible = true
	_shown_msec = Time.get_ticks_msec()
	_timer.start(duration)

func is_visible() -> bool:
	return _panel != null and _panel.visible

func _hide_panel() -> void:
	if _panel == null or not _panel.visible:
		return
	_panel.visible = false
	narrative_dismissed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if _panel.visible and event.is_action_pressed("interact") and not event.is_echo():
		if Time.get_ticks_msec() - _shown_msec > 350:
			_hide_panel()
