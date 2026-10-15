class_name UiKit
extends RefCounted
## Shared look for the game's menus (pause, options, field notes, cinematic captions): the same dark cards and
## cyan accent as the HUD, sizes scaled by the player's text-size option, high contrast respected.

const BG := Color(0.02, 0.032, 0.042, 0.94)
const BG_HC := Color(0.0, 0.0, 0.0, 0.98)
const CYAN := Color(0.4, 0.86, 0.88)
const AMBER := Color(0.98, 0.74, 0.32)
const TEXT := Color(0.93, 0.95, 0.94)
const TEXT_DIM := Color(0.66, 0.74, 0.78)


static func scale() -> float:
	return AccessibilityManager.ui_scale()


static func font(base: int) -> int:
	return int(round(base * scale()))


static func panel_style(accent: Color = CYAN, left: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = BG_HC if AccessibilityManager.is_high_contrast() else BG
	s.border_color = Color.WHITE if AccessibilityManager.is_high_contrast() else accent
	s.border_width_left = left
	s.set_corner_radius_all(5)
	s.content_margin_left = 22.0
	s.content_margin_right = 22.0
	s.content_margin_top = 18.0
	s.content_margin_bottom = 18.0
	return s


static func label(text: String, size: int = 16, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font(size))
	l.add_theme_color_override("font_color", Color.WHITE if AccessibilityManager.is_high_contrast() and color != TEXT_DIM else color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 3)
	return l


static func heading(text: String, size: int = 22) -> Label:
	return label(text, size, CYAN)


static func button(text: String, min_width: float = 260.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_width * clampf(scale(), 1.0, 1.5), 38.0 * clampf(scale(), 1.0, 1.6))
	b.add_theme_font_size_override("font_size", font(17))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.07, 0.1, 0.12, 0.95)
	normal.set_corner_radius_all(4)
	normal.content_margin_left = 14.0
	normal.content_margin_right = 14.0
	var focus := normal.duplicate() as StyleBoxFlat
	focus.bg_color = Color(0.1, 0.2, 0.22, 1.0)
	focus.border_color = Color.WHITE if AccessibilityManager.is_high_contrast() else CYAN
	focus.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", focus)
	b.add_theme_stylebox_override("focus", focus)
	b.add_theme_stylebox_override("pressed", focus)
	return b


## Full-screen dimmer with a centred card; returns [root, card content VBox].
static func modal(parent: Node, accent: Color = CYAN, width: float = 620.0) -> Array:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(root)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", panel_style(accent))
	card.custom_minimum_size = Vector2(width * clampf(scale(), 1.0, 1.35), 0.0)
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)
	return [root, box]
