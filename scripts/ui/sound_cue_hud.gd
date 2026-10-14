extends CanvasLayer
class_name SoundCueHUD

## Visual equivalent for important audio cues.
## This supports deaf and hard-of-hearing players and noisy play environments.

var _cue_label: Label = null
var _tween: Tween = null
var _hide_timer: Timer = null

func _ready() -> void:
	layer = 30
	add_to_group("sound_cue_hud")

	_cue_label = Label.new()
	_cue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cue_label.add_theme_font_size_override("font_size", int(20.0 * AccessibilityManager.ui_scale()))
	_cue_label.add_theme_color_override("font_color", Color(0.9, 0.98, 1.0))
	_cue_label.add_theme_stylebox_override("normal", _panel_style())
	_cue_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_cue_label.offset_top = 90.0
	_cue_label.offset_bottom = 130.0
	_cue_label.offset_left = -220.0
	_cue_label.offset_right = 220.0
	_cue_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_cue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cue_label.modulate.a = 0.0
	add_child(_cue_label)

	_hide_timer = Timer.new()
	_hide_timer.one_shot = true
	_hide_timer.timeout.connect(_hide_cue)
	add_child(_hide_timer)

	GameManager.stats_changed.connect(_apply_accessibility)
	_apply_accessibility()

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.95 if AccessibilityManager.is_high_contrast() else 0.78)
	style.border_color = Color(1.0, 1.0, 1.0, 1.0) if AccessibilityManager.is_high_contrast() else Color(0.3, 0.85, 0.95, 0.9)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style

func _apply_accessibility() -> void:
	if _cue_label == null:
		return
	_cue_label.add_theme_font_size_override("font_size", int(20.0 * AccessibilityManager.ui_scale()))
	_cue_label.add_theme_stylebox_override("normal", _panel_style())

func show_cue(cue_key: String, duration: float = 1.6) -> void:
	if _cue_label == null:
		return

	var text: String = NarrativeTextManager.get_sound_cue(cue_key)
	if text.is_empty():
		return

	_cue_label.text = text
	_cue_label.modulate.a = 1.0
	_hide_timer.start(duration)

func _hide_cue() -> void:
	if _cue_label == null:
		return

	var duration := AccessibilityManager.animation_duration(0.25)
	if duration <= 0.0:
		_cue_label.modulate.a = 0.0
		return

	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_cue_label, "modulate:a", 0.0, duration)
