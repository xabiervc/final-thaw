class_name AccessibilityManager
extends RefCounted

## Central read-only access to persisted accessibility preferences.
## GameManager remains the source of truth and persistence layer.

static func is_high_contrast() -> bool:
	return GameManager.get_flag("accessibility_high_contrast")

static func is_reduced_motion() -> bool:
	return GameManager.get_flag("accessibility_reduced_motion")

static func subtitle_background() -> int:
	return clampi(GameManager.subtitle_size, 0, 2)

static func ui_scale() -> float:
	return clampf(GameManager.font_scale, 0.75, 2.0)

static func animation_duration(default_duration: float) -> float:
	if is_reduced_motion():
		return 0.0
	return default_duration

static func subtitle_panel_alpha() -> float:
	match subtitle_background():
		0:
			return 0.0
		1:
			return 0.55
		2:
			return 0.95
	return 0.55

static func apply_subtitle_background(panel: PanelContainer) -> void:
	if panel == null:
		return
	var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.07, 0.9)
	panel.add_theme_stylebox_override("panel", style)
	style.bg_color.a = subtitle_panel_alpha()
