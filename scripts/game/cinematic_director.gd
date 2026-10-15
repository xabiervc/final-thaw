extends CanvasLayer
## Plays a short in-engine cinematic: camera moves between authored transforms over the real level, letterbox,
## timed text captions (no voice acting: well-timed text), title cards on black and fades. Skippable at any time by
## HOLDING interact / jump / menu (or the gamepad equivalents) for SKIP_HOLD seconds; a hint shows how.
##
## Safety contract: whether it ends or is skipped, `finished(skipped)` is emitted exactly once and every node this
## director created is removed; the host restores gameplay (camera, input, HUD) in ONE handler, so a skip can never
## leave the game paused, without a camera or without input.
##
## Shot dictionary: duration (s); from / to (Transform3D, camera; omitted on black cards); fov; black (bool);
## lines: Array of [start_seconds, text]; title / subtitle (centred card text); on_start (Callable);
## fade_in / fade_out (s).

signal finished(skipped: bool)

const T := preload("res://scripts/game/game_text.gd")
const SKIP_HOLD := 0.8
const SKIP_ACTIONS := ["interact", "jump", "pause"]

var active: bool = false
var shot_index: int = -1
var camera: Camera3D = null

var _shots: Array = []
var _t: float = 0.0
var _hold: float = 0.0
var _root: Control
var _bar_top: ColorRect
var _bar_bottom: ColorRect
var _fade: ColorRect
var _caption: Label
var _title: Label
var _subtitle: Label
var _skip_hint: Label
var _skip_bar: ProgressBar
var _world: Node3D = null
var _line_shown: int = -1


func _ready() -> void:
	layer = 40


func play(shots: Array, world: Node3D) -> void:
	if active:
		return
	_shots = shots
	_world = world
	active = true
	_build_overlay()
	camera = Camera3D.new()
	camera.name = "CinematicCamera"
	_world.add_child(camera)
	camera.make_current()
	_start_shot(0)


func _build_overlay() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_bar_top = ColorRect.new()
	_bar_top.color = Color.BLACK
	_bar_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_bar_top.offset_bottom = 78.0
	_root.add_child(_bar_top)
	_bar_bottom = ColorRect.new()
	_bar_bottom.color = Color.BLACK
	_bar_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bar_bottom.offset_top = -118.0
	_root.add_child(_bar_bottom)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 1)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_fade)
	_caption = _label(20, Color(0.94, 0.96, 0.95))
	_caption.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_caption.offset_top = -112.0
	_caption.offset_bottom = -20.0
	_caption.offset_left = 120.0
	_caption.offset_right = -120.0
	_title = _label(54, Color(0.92, 0.95, 0.95))
	_title.set_anchors_preset(Control.PRESET_CENTER)
	_title.offset_left = -560.0
	_title.offset_right = 560.0
	_title.offset_top = -120.0
	_title.offset_bottom = 0.0
	_subtitle = _label(22, UiKit.CYAN)
	_subtitle.set_anchors_preset(Control.PRESET_CENTER)
	_subtitle.offset_left = -560.0
	_subtitle.offset_right = 560.0
	_subtitle.offset_top = 6.0
	_subtitle.offset_bottom = 160.0
	_skip_hint = _label(14, Color(0.7, 0.76, 0.8))
	_skip_hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_skip_hint.offset_left = -360.0
	_skip_hint.offset_right = -24.0
	_skip_hint.offset_top = -40.0
	_skip_hint.offset_bottom = -16.0
	_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_skip_hint.text = T.t("cine_skip", {"key": _skip_key()})
	_skip_bar = ProgressBar.new()
	_skip_bar.show_percentage = false
	_skip_bar.max_value = 1.0
	_skip_bar.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_skip_bar.offset_left = -200.0
	_skip_bar.offset_right = -24.0
	_skip_bar.offset_top = -12.0
	_skip_bar.offset_bottom = -8.0
	_skip_bar.modulate.a = 0.0
	_root.add_child(_skip_bar)


func _label(size: int, color: Color) -> Label:
	var l := Label.new()
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", UiKit.font(size))
	l.add_theme_color_override("font_color", Color.WHITE if AccessibilityManager.is_high_contrast() else color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(l)
	return l


func _skip_key() -> String:
	var k := InputRemapManager.current_keycode("interact")
	var pad := InputRemapManager.pad_label(InputRemapManager.current_pad_button("interact"))
	return "%s / %s" % [InputRemapManager.key_label(k), pad]


func _start_shot(i: int) -> void:
	shot_index = i
	_t = 0.0
	_line_shown = -1
	if i >= _shots.size():
		_finish(false)
		return
	var shot: Dictionary = _shots[i]
	var black := bool(shot.get("black", false))
	_bar_top.visible = not black
	_bar_bottom.visible = not black
	_caption.text = ""
	_title.text = str(shot.get("title", ""))
	_subtitle.text = str(shot.get("subtitle", ""))
	if shot.has("fov"):
		camera.fov = float(shot["fov"])
	if shot.has("from"):
		camera.global_transform = shot["from"]
	_fade.color.a = 1.0 if (black or float(shot.get("fade_in", 0.0)) > 0.0) else 0.0
	if black:
		_fade.color.a = 1.0
	var cb = shot.get("on_start")
	if cb is Callable and (cb as Callable).is_valid():
		(cb as Callable).call()


func _process(delta: float) -> void:
	if not active:
		return
	_update_skip(delta)
	if not active:
		return
	var shot: Dictionary = _shots[shot_index]
	var duration := float(shot.get("duration", 4.0))
	_t += delta
	var k := clampf(_t / duration, 0.0, 1.0)
	var eased := k * k * (3.0 - 2.0 * k)
	if shot.has("from") and shot.has("to"):
		var a: Transform3D = shot["from"]
		var b: Transform3D = shot["to"]
		camera.global_transform = a.interpolate_with(b, eased)
	# Fades (black cards stay black; the text sits on top).
	if not bool(shot.get("black", false)):
		var fi := float(shot.get("fade_in", 0.0))
		var fo := float(shot.get("fade_out", 0.0))
		var alpha := 0.0
		if fi > 0.0 and _t < fi:
			alpha = 1.0 - _t / fi
		if fo > 0.0 and _t > duration - fo:
			alpha = maxf(alpha, (_t - (duration - fo)) / fo)
		_fade.color.a = clampf(alpha, 0.0, 1.0)
	# Timed captions: the latest line whose start has passed.
	var lines: Array = shot.get("lines", [])
	for j in lines.size():
		if _t >= float(lines[j][0]) and j > _line_shown:
			_line_shown = j
			_caption.text = str(lines[j][1])
	if _t >= duration:
		_start_shot(shot_index + 1)


func _update_skip(delta: float) -> void:
	var held := false
	for a in SKIP_ACTIONS:
		if InputMap.has_action(a) and Input.is_action_pressed(a):
			held = true
	_hold = _hold + delta if held else 0.0
	_skip_bar.value = _hold / SKIP_HOLD
	_skip_bar.modulate.a = 1.0 if _hold > 0.0 else 0.0
	if _hold >= SKIP_HOLD:
		skip()


func skip() -> void:
	if active:
		_finish(true)


func _finish(skipped: bool) -> void:
	if not active:
		return
	active = false
	if camera != null and is_instance_valid(camera):
		camera.queue_free()
	camera = null
	if _root != null and is_instance_valid(_root):
		_root.queue_free()
	_root = null
	_shots = []
	finished.emit(skipped)


## Seconds of the whole sequence (for tests and the intro length budget).
static func total_duration(shots: Array) -> float:
	var t := 0.0
	for s in shots:
		t += float((s as Dictionary).get("duration", 4.0))
	return t
