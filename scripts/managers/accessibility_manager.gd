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

static func colorblind_mode() -> int:
	return clampi(GameManager.colorblind_mode, 0, 3)

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

## Returns a gameplay-safe palette for the Flooded Shelter.
## Modes: 0 default, 1 deuteranopia, 2 protanopia, 3 tritanopia.
static func shelter_palette() -> Dictionary:
	var high_contrast := is_high_contrast()
	var mode := colorblind_mode()

	var palette := {
		"locked": Color("70505a"),
		"active": Color("48ad99"),
		"highlight": Color("8ef7e4"),
		"text": Color("eff4ee"),
		"oxygen_normal": Color("eff4ee"),
		"oxygen_warning": Color("f2c14e"),
		"oxygen_critical": Color("f26d5b"),
	}

	if high_contrast:
		palette = {
			"locked": Color("5a5a5a"),
			"active": Color("00e5a0"),
			"highlight": Color("ffffff"),
			"text": Color("ffffff"),
			"oxygen_normal": Color("ffffff"),
			"oxygen_warning": Color("ffd400"),
			"oxygen_critical": Color("ff5252"),
		}

	match mode:
		1: # Deuteranopia: avoid red/green distinction; use blue and amber.
			palette["active"] = Color(0.0, 0.72, 1.0)
			palette["highlight"] = Color(0.85, 0.95, 1.0)
			palette["oxygen_warning"] = Color(1.0, 0.78, 0.0)
			palette["oxygen_critical"] = Color(1.0, 0.42, 0.1)
		2: # Protanopia: blue and amber remain distinguishable.
			palette["active"] = Color(0.0, 0.65, 1.0)
			palette["highlight"] = Color(0.85, 0.95, 1.0)
			palette["oxygen_warning"] = Color(1.0, 0.72, 0.0)
			palette["oxygen_critical"] = Color(1.0, 0.35, 0.15)
		3: # Tritanopia: use cyan and magenta separation.
			palette["active"] = Color(0.0, 0.85, 0.85)
			palette["highlight"] = Color(1.0, 0.75, 1.0)
			palette["oxygen_warning"] = Color(1.0, 0.55, 0.85)
			palette["oxygen_critical"] = Color(0.85, 0.2, 0.55)

	return palette
