extends CanvasLayer
## Gameplay HUD shared by the 3D rooms. Hierarchy, most to least prominent:
##   1. Banner (centre top)       - state changes that matter: power restored, room cleared. Transient.
##   2. Interaction prompt        - bottom centre, amber key cap (the live binding of `interact`) + verb + object.
##   3. Objective card (top left) - directive header, objective, contextual tutorial hint.
##   4. Condition (top right)     - stamina bar and state; the state is spelled out, never colour alone.
##   5. Control legend (bottom left) - built from the current input map, so remapped keys are shown correctly.
## Public API kept for every level: set_objective, set_hint, set_status, set_prompt. Added: show_banner.

const CARD_BG := Color(0.02, 0.032, 0.042, 0.86)
const CYAN := Color(0.4, 0.86, 0.88)
const AMBER := Color(0.98, 0.74, 0.32)
const TEXT := Color(0.93, 0.95, 0.94)
const TEXT_DIM := Color(0.66, 0.74, 0.78)
const HINT := Color(0.96, 0.86, 0.58)
const GREEN := Color(0.45, 0.95, 0.65)
const CARD_WIDTH := 400.0
const MARGIN := 22.0
## Actions listed in the control legend, with the text key and fallback for their label.
const LEGEND := [
	["move", "hud_ctrl_move", "mover"],
	["interact", "hud_ctrl_interact", "interactuar"],
	["scan", "hud_ctrl_scan", "escanear"],
	["jump", "hud_ctrl_jump", "saltar"],
	["quick_save", "hud_ctrl_save", "guardar"],
	["quick_load", "hud_ctrl_load", "cargar"],
	["pause", "hud_ctrl_menu", "menú"],
]

var _card: PanelContainer = null
var _section_label: Label = null
var _objective: Label = null
var _hint: Label = null
var _instructions: Label = null
var _prompt_box: PanelContainer = null
var _prompt_key: Label = null
var _prompt_verb: Label = null
var _prompt_name: Label = null
var _prompt: Label = null  # kept for compatibility: holds the raw prompt line
var _status: Label = null
var _condition_card: PanelContainer = null
var _condition: Label = null
var _cond_bar: ProgressBar = null
var _banner: PanelContainer = null
var _banner_title: Label = null
var _banner_body: Label = null
var _last_prompt: String = ""
var _tween: Tween = null
var _card_tween: Tween = null
var _banner_tween: Tween = null
var _completed: bool = false
var _visibility: Label = null
var _note_toast: PanelContainer = null
var _note_label: Label = null
var _note_tween: Tween = null
## True while the last input came from a gamepad: prompts and the legend then show pad buttons.
static var using_pad: bool = false


func _ready() -> void:
	layer = 10
	_build_objective_card()
	_build_condition()
	_build_prompt()
	_build_banner()
	_build_legend()
	GameManager.stats_changed.connect(_apply_accessibility)
	NarrativeTextManager.language_changed.connect(func(_l): _refresh_texts())
	_apply_accessibility()


# --- construction ---------------------------------------------------------------------------------------------------

func _style(bg: Color, accent: Color = Color(0, 0, 0, 0), left: int = 0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = accent
	s.border_width_left = left
	s.set_corner_radius_all(4)
	s.content_margin_left = 14.0
	s.content_margin_right = 14.0
	s.content_margin_top = 9.0
	s.content_margin_bottom = 10.0
	return s


func _make_label(parent: Node, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _build_objective_card() -> void:
	_card = PanelContainer.new()
	_card.position = Vector2(MARGIN, MARGIN)
	_card.add_theme_stylebox_override("panel", _style(CARD_BG, CYAN, 3))
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	_card.add_child(box)
	_section_label = _make_label(box, 12, CYAN)
	_objective = _make_label(box, 19, TEXT)
	_objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective.custom_minimum_size = Vector2(CARD_WIDTH, 0.0)
	_hint = _make_label(box, 15, HINT)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size = Vector2(CARD_WIDTH, 0.0)
	_hint.visible = false
	_section_label.text = _directive_header()


func _build_condition() -> void:
	_condition_card = PanelContainer.new()
	_condition_card.add_theme_stylebox_override("panel", _style(CARD_BG))
	_condition_card.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_condition_card.offset_left = -270.0 - MARGIN
	_condition_card.offset_right = -MARGIN
	_condition_card.offset_top = MARGIN
	_condition_card.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_condition_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_condition_card.visible = false
	add_child(_condition_card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_condition_card.add_child(box)
	_condition = _make_label(box, 14, TEXT)
	_cond_bar = ProgressBar.new()
	_cond_bar.min_value = 0.0
	_cond_bar.max_value = 100.0
	_cond_bar.show_percentage = false
	_cond_bar.custom_minimum_size = Vector2(240.0, 8.0)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.1, 0.13, 0.15, 0.9)
	bg.set_corner_radius_all(2)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color.WHITE
	fill.set_corner_radius_all(2)
	_cond_bar.add_theme_stylebox_override("background", bg)
	_cond_bar.add_theme_stylebox_override("fill", fill)
	_cond_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_cond_bar)
	_status = _make_label(box, 14, Color(0.6, 0.92, 0.95))
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(240.0, 0.0)
	_status.visible = false
	_visibility = _make_label(box, 14, TEXT)
	_visibility.visible = false
	# Field-notes toast, under the condition card.
	_note_toast = PanelContainer.new()
	_note_toast.add_theme_stylebox_override("panel", _style(CARD_BG, AMBER, 3))
	_note_toast.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_note_toast.offset_left = -330.0 - MARGIN
	_note_toast.offset_right = -MARGIN
	_note_toast.offset_top = MARGIN + 92.0
	_note_toast.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_note_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_note_toast.modulate.a = 0.0
	add_child(_note_toast)
	_note_label = _make_label(_note_toast, 14, AMBER)
	_note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note_label.custom_minimum_size = Vector2(300.0, 0.0)


func _build_prompt() -> void:
	_prompt_box = PanelContainer.new()
	_prompt_box.add_theme_stylebox_override("panel", _style(Color(0.02, 0.03, 0.04, 0.88), AMBER, 3))
	_prompt_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt_box.offset_top = -196.0
	_prompt_box.offset_bottom = -152.0
	_prompt_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt_box.modulate.a = 0.0
	add_child(_prompt_box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_prompt_box.add_child(row)
	_prompt_key = _make_label(row, 16, Color(0.05, 0.05, 0.05))
	var cap := StyleBoxFlat.new()
	cap.bg_color = AMBER
	cap.set_corner_radius_all(3)
	cap.content_margin_left = 8.0
	cap.content_margin_right = 8.0
	cap.content_margin_top = 1.0
	cap.content_margin_bottom = 1.0
	_prompt_key.add_theme_stylebox_override("normal", cap)
	_prompt_key.add_theme_constant_override("outline_size", 0)
	_prompt_key.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_prompt_verb = _make_label(row, 18, Color(1.0, 0.93, 0.8))
	_prompt_name = _make_label(row, 16, TEXT_DIM)
	_prompt = Label.new()
	_prompt.visible = false
	add_child(_prompt)


func _build_banner() -> void:
	_banner = PanelContainer.new()
	_banner.add_theme_stylebox_override("panel", _style(Color(0.015, 0.025, 0.03, 0.9), GREEN, 0))
	_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_banner.offset_top = 92.0
	_banner.offset_bottom = 160.0
	_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.modulate.a = 0.0
	add_child(_banner)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	_banner.add_child(box)
	_banner_title = _make_label(box, 26, GREEN)
	_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_body = _make_label(box, 15, TEXT)
	_banner_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _build_legend() -> void:
	_instructions = Label.new()
	_instructions.add_theme_font_size_override("font_size", 13)
	_instructions.add_theme_color_override("font_color", TEXT_DIM)
	_instructions.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_instructions.add_theme_constant_override("outline_size", 4)
	_instructions.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_instructions.offset_left = MARGIN
	_instructions.offset_top = -MARGIN - 20.0
	_instructions.offset_bottom = -MARGIN
	_instructions.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_instructions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_instructions)
	_instructions.text = control_legend()


# --- texts --------------------------------------------------------------------------------------------------------

func _directive_header() -> String:
	return NarrativeTextManager.get_option("hud_directive_header", "DIRECTIVA  ·  ASTER")


## Human-readable name of the first keyboard binding of an action ("" if unbound).
static func key_name(action: String) -> String:
	if not InputMap.has_action(action):
		return ""
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			var k := e as InputEventKey
			var code := k.physical_keycode if k.physical_keycode != KEY_NONE else k.keycode
			return _key_label(code)
	return ""


## Up to `limit` distinct keyboard bindings of an action, in input-map order.
static func key_names(action: String, limit: int) -> Array[String]:
	var out: Array[String] = []
	if not InputMap.has_action(action):
		return out
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and out.size() < limit:
			var k := e as InputEventKey
			var code := k.physical_keycode if k.physical_keycode != KEY_NONE else k.keycode
			var label := _key_label(code)
			if not out.has(label):
				out.append(label)
	return out


static func _key_label(code: Key) -> String:
	match code:
		KEY_SPACE:
			return NarrativeTextManager.get_option("hud_key_space", "Espacio")
		KEY_ESCAPE:
			return "Esc"
	return OS.get_keycode_string(code)


## Control legend from the live input map ("WASD mover · E interactuar · ...").
## Every action the legend knows how to label. A scene lists only the ones it really supports (set_legend_actions).
const LEGEND_LABELS := {
	"move": ["hud_ctrl_move", "mover"], "run": ["hud_ctrl_run", "correr"], "crouch": ["hud_ctrl_crouch", "agacharse"],
	"jump": ["hud_ctrl_jump", "saltar"], "interact": ["hud_ctrl_interact", "interactuar"], "scan": ["hud_ctrl_scan", "escanear (mantener)"],
	"hint": ["hud_ctrl_hint", "pista"], "quick_save": ["hud_ctrl_save", "guardar"], "quick_load": ["hud_ctrl_load", "cargar"],
	"pause": ["hud_ctrl_menu", "menú"],
}

## Actions shown by this HUD; empty = the historical default (LEGEND).
var legend_actions: Array = []


## A scene declares the controls it really supports, so the legend never promises an action that does nothing.
func set_legend_actions(actions: Array) -> void:
	legend_actions = actions
	_instructions.text = control_legend(actions)


## The control the player should press for an action, on the device they are using now.
static func action_label(action: String) -> String:
	if using_pad:
		return InputRemapManager.pad_label(InputRemapManager.current_pad_button(action))
	return key_name(action)


static func control_legend(actions: Array = []) -> String:
	var entries: Array = LEGEND
	if not actions.is_empty():
		entries = []
		for a in actions:
			if LEGEND_LABELS.has(a):
				entries.append([a, LEGEND_LABELS[a][0], LEGEND_LABELS[a][1]])
	var parts: Array[String] = []
	for entry in entries:
		var keys := ""
		if entry[0] == "move":
			if using_pad:
				keys = NarrativeTextManager.get_option("hud_pad_left_stick", "L-stick")
			else:
				for a in ["move_up", "move_left", "move_down", "move_right"]:
					keys += key_name(a)
		elif using_pad:
			keys = InputRemapManager.pad_label(InputRemapManager.current_pad_button(entry[0])) if entry[0] != "pause" else "Menu"
			if entry[0] == "run":
				keys += " / RT"
		else:
			keys = "/".join(key_names(entry[0], 2))
		if keys.is_empty():
			continue
		parts.append("%s %s" % [keys, NarrativeTextManager.get_option(entry[1], entry[2])])
	return "   ·   ".join(parts)


func _refresh_texts() -> void:
	if not _completed:
		_section_label.text = _directive_header()
	_instructions.text = control_legend(legend_actions)


func _input(event: InputEvent) -> void:
	var pad := using_pad
	if event is InputEventJoypadButton or (event is InputEventJoypadMotion and absf((event as InputEventJoypadMotion).axis_value) > 0.5):
		pad = true
	elif event is InputEventKey or event is InputEventMouseButton:
		pad = false
	if pad != using_pad:
		using_pad = pad
		_refresh_texts()
		if not _last_prompt.is_empty():
			var p := _last_prompt
			_last_prompt = ""
			set_prompt(p)


# --- accessibility --------------------------------------------------------------------------------------------------

func _apply_accessibility() -> void:
	var scale := AccessibilityManager.ui_scale()
	var high_contrast := AccessibilityManager.is_high_contrast()
	_section_label.add_theme_font_size_override("font_size", maxi(12, int(12 * scale)))
	_objective.add_theme_font_size_override("font_size", int(19 * scale))
	_hint.add_theme_font_size_override("font_size", int(15 * scale))
	_objective.custom_minimum_size.x = CARD_WIDTH * clampf(scale, 1.0, 1.4)
	_hint.custom_minimum_size.x = _objective.custom_minimum_size.x
	_instructions.add_theme_font_size_override("font_size", int(13 * scale))
	_status.add_theme_font_size_override("font_size", int(14 * scale))
	_condition.add_theme_font_size_override("font_size", int(14 * scale))
	_prompt_key.add_theme_font_size_override("font_size", int(16 * scale))
	_prompt_verb.add_theme_font_size_override("font_size", int(18 * scale))
	_prompt_name.add_theme_font_size_override("font_size", int(16 * scale))
	_banner_title.add_theme_font_size_override("font_size", int(26 * scale))
	_banner_body.add_theme_font_size_override("font_size", int(15 * scale))
	_visibility.add_theme_font_size_override("font_size", int(14 * scale))
	_note_label.add_theme_font_size_override("font_size", int(14 * scale))
	_note_label.custom_minimum_size.x = 300.0 * clampf(scale, 1.0, 1.4)

	var bg_alpha := 0.97 if high_contrast else 0.86
	for card in [_card, _condition_card, _prompt_box, _banner, _note_toast]:
		var s := (card as PanelContainer).get_theme_stylebox("panel") as StyleBoxFlat
		s.bg_color.a = bg_alpha
		if high_contrast:
			s.bg_color = Color(0, 0, 0, bg_alpha)
	_section_label.add_theme_color_override("font_color", Color.WHITE if high_contrast else CYAN)
	_objective.add_theme_color_override("font_color", Color.WHITE if high_contrast else TEXT)
	_hint.add_theme_color_override("font_color", Color(1.0, 0.95, 0.65) if high_contrast else HINT)
	_instructions.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0) if high_contrast else TEXT_DIM)
	_prompt_name.add_theme_color_override("font_color", Color.WHITE if high_contrast else TEXT_DIM)
	_prompt_verb.add_theme_color_override("font_color", Color.WHITE if high_contrast else Color(1.0, 0.93, 0.8))


# --- per-frame condition ------------------------------------------------------------------------------------------

func _process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player")
	var c = null
	if p != null:
		c = p.get("condition")
	if c == null:
		_condition_card.visible = _status.visible
		_condition.visible = false
		_cond_bar.visible = false
		return
	_update_condition(c)


func _update_condition(c) -> void:
	var state := str(c.state_name())
	_condition.text = NarrativeTextManager.get_prompt_condition(int(round(c.stamina)), state, c.load_factor > 0.0)
	_cond_bar.value = c.stamina
	var tint := Color(0.4, 0.9, 0.8)
	match state:
		"fatiga":
			tint = Color(0.95, 0.85, 0.4)
		"exhausta":
			tint = Color(0.95, 0.6, 0.3)
		"critica":
			tint = Color(0.95, 0.35, 0.3)
	(_cond_bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = tint
	_condition_card.visible = true
	_condition.visible = true
	_cond_bar.visible = true


# --- public API -----------------------------------------------------------------------------------------------------

func set_objective(text: String) -> void:
	var clean_text := text
	if clean_text.begins_with("OBJETIVO  /  "):
		clean_text = clean_text.trim_prefix("OBJETIVO  /  ")
		_completed = false
		_section_label.text = _directive_header()
	elif clean_text.begins_with("SALA SUPERADA  /  "):
		clean_text = clean_text.trim_prefix("SALA SUPERADA  /  ")
		_completed = true
		_section_label.text = NarrativeTextManager.get_option("hud_completed_header", "OBJETIVO COMPLETADO")
	if _objective.text == clean_text:
		return
	var changed := not _objective.text.is_empty()
	_objective.text = clean_text
	if changed:
		_flash_card()


## Brief accent pulse on the objective card when the objective changes (skipped with reduced motion).
func _flash_card() -> void:
	var duration := AccessibilityManager.animation_duration(0.6)
	if duration <= 0.0:
		return
	if _card_tween != null:
		_card_tween.kill()
	var s := _card.get_theme_stylebox("panel") as StyleBoxFlat
	_card_tween = create_tween()
	_card_tween.tween_property(s, "border_width_left", 9, duration * 0.25)
	_card_tween.tween_property(s, "border_width_left", 3, duration * 0.75)


func set_hint(text: String) -> void:
	if _hint.text != text:
		_hint.text = text
	_hint.visible = not text.is_empty()


func set_status(text: String) -> void:
	if _status.text != text:
		_status.text = text
	_status.visible = not text.is_empty()
	if _status.visible:
		_condition_card.visible = true


## Accepts the interactables' prompt line "[E] Verb - Name"; the key cap always shows the live `interact` binding.
func set_prompt(text: String) -> void:
	if text == _last_prompt:
		return
	_last_prompt = text
	_prompt.text = text
	if _tween != null:
		_tween.kill()
	if not text.is_empty():
		var body := text
		if body.begins_with("["):
			var close := body.find("]")
			if close > 0:
				body = body.substr(close + 1).strip_edges()
		var split := body.find(" - ")
		_prompt_verb.text = body if split < 0 else body.substr(0, split)
		_prompt_name.text = "" if split < 0 else body.substr(split + 3)
		_prompt_name.visible = not _prompt_name.text.is_empty()
		var key := key_name("interact")
		_prompt_key.text = key if not key.is_empty() else "E"
	var duration := AccessibilityManager.animation_duration(0.15)
	var target := 1.0 if not text.is_empty() else 0.0
	if duration <= 0.0:
		_prompt_box.modulate.a = target
		return
	_tween = create_tween()
	_tween.tween_property(_prompt_box, "modulate:a", target, duration)


## Transient centred banner for important state changes. accent: green success, cyan info, red warning.
func show_banner(title: String, body: String = "", accent: Color = GREEN, seconds: float = 3.5) -> void:
	_banner_title.text = title
	_banner_title.add_theme_color_override("font_color", Color.WHITE if AccessibilityManager.is_high_contrast() else accent)
	_banner_body.text = body
	_banner_body.visible = not body.is_empty()
	var s := _banner.get_theme_stylebox("panel") as StyleBoxFlat
	s.border_color = accent
	s.border_width_top = 2
	s.border_width_bottom = 2
	if _banner_tween != null:
		_banner_tween.kill()
	var fade := AccessibilityManager.animation_duration(0.35)
	_banner_tween = create_tween()
	if fade > 0.0:
		_banner_tween.tween_property(_banner, "modulate:a", 1.0, fade)
	else:
		_banner.modulate.a = 1.0
	_banner_tween.tween_interval(seconds)
	if fade > 0.0:
		_banner_tween.tween_property(_banner, "modulate:a", 0.0, fade * 2.0)
	else:
		_banner_tween.tween_callback(func(): _banner.modulate.a = 0.0)


## Stealth readout: -1 hides it; 0 in shadow, 1 partly lit, 2 exposed. Symbol + word, never colour alone.
func set_visibility(level: int) -> void:
	if level < 0:
		_visibility.visible = false
		return
	var keys := ["hud_vis_hidden", "hud_vis_partial", "hud_vis_exposed"]
	var symbols := ["○", "◐", "●"]
	var roles := ["ok", "warn", "danger"]
	_visibility.text = "%s  %s" % [symbols[level], GameText.t(keys[level])]
	_visibility.add_theme_color_override("font_color", Color.WHITE if AccessibilityManager.is_high_contrast() else GamePalette.color(roles[level]).lerp(TEXT, 0.35))
	_visibility.visible = true
	_condition_card.visible = true


## Small, non-blocking notice when Elena writes something in her field notes.
func show_note(text: String) -> void:
	_note_label.text = text
	if _note_tween != null:
		_note_tween.kill()
	var fade := AccessibilityManager.animation_duration(0.3)
	_note_tween = create_tween()
	if fade > 0.0:
		_note_tween.tween_property(_note_toast, "modulate:a", 1.0, fade)
	else:
		_note_toast.modulate.a = 1.0
	_note_tween.tween_interval(3.5)
	if fade > 0.0:
		_note_tween.tween_property(_note_toast, "modulate:a", 0.0, fade * 2.0)
	else:
		_note_tween.tween_callback(func(): _note_toast.modulate.a = 0.0)


## Cinematics hide the whole HUD; gameplay shows it again.
func set_hud_visible(on: bool) -> void:
	visible = on


func is_banner_visible() -> bool:
	return _banner.modulate.a > 0.01
