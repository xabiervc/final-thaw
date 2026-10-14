extends CanvasLayer

signal narrative_dismissed

var _panel: PanelContainer = null
var _label: Label = null
var _timer: Timer = null
var _shown_msec: int = 0

const SUBTITLE_WIDTH := 760.0
const BOTTOM_MARGIN := 60.0  # keeps the subtitle clear of the HUD control legend

func _ready() -> void:
	layer = 20
	add_to_group("narrative_panel")
	# Subtitle bar: bottom centre, at most SUBTITLE_WIDTH wide, grows upwards with the text.
	_panel = PanelContainer.new()
	_panel.visible = false
	_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_panel.offset_left = -SUBTITLE_WIDTH * 0.5
	_panel.offset_right = SUBTITLE_WIDTH * 0.5
	_panel.offset_top = -BOTTOM_MARGIN
	_panel.offset_bottom = -BOTTOM_MARGIN
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.03, 0.04, 0.82)
	style.border_color = Color(0.4, 0.86, 0.88, 0.9)
	style.border_width_left = 3
	style.set_corner_radius_all(4)
	style.content_margin_left = 22.0
	style.content_margin_right = 22.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.custom_minimum_size = Vector2(SUBTITLE_WIDTH - 44.0, 0.0)
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("outline_size", 5)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_label)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_hide_panel)
	add_child(_timer)
	GameManager.stats_changed.connect(_apply_accessibility)
	_apply_accessibility()

func _apply_accessibility() -> void:
	_label.add_theme_font_size_override("font_size", int(19.0 * AccessibilityManager.ui_scale()))

	var high_contrast := AccessibilityManager.is_high_contrast()
	var style: StyleBoxFlat = _panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style != null:
		style.bg_color = Color(0.0, 0.0, 0.0, 0.98) if high_contrast else Color(0.02, 0.03, 0.04, 0.82)
		style.border_color = Color(1.0, 1.0, 1.0, 1.0) if high_contrast else Color(0.4, 0.86, 0.88, 0.9)
	_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color(0.94, 0.96, 0.95))
	AccessibilityManager.apply_subtitle_background(_panel)

func show_message(text: String, duration: float = 8.0) -> void:
	_label.text = text
	_panel.visible = true
	_panel.reset_size()
	_pin_to_bottom.call_deferred()
	_shown_msec = Time.get_ticks_msec()
	_timer.start(duration)

## Keeps the bar's bottom edge at BOTTOM_MARGIN whatever its height (multi-line messages grow upwards).
func _pin_to_bottom() -> void:
	if _panel == null:
		return
	_panel.offset_top = -BOTTOM_MARGIN - _panel.get_combined_minimum_size().y
	_panel.offset_bottom = -BOTTOM_MARGIN

func is_message_visible() -> bool:
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
