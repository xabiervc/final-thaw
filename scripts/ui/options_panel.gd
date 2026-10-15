class_name OptionsPanel
extends Control
## The game's options, usable from the main menu (options_menu.tscn) and from the pause menu. Every control
## writes through GameManager / GameSettings / InputRemapManager and has an observable effect:
##   Accessibility: text size, high contrast, reduced motion, subtitles, subtitle background, colour-blind palette,
##                  game speed.
##   Gameplay:      difficulty, camera sensitivity, invert vertical look.
##   Audio:         master, music, effects volume.
##   Controls:      keyboard and gamepad remapping with conflict swap, restore defaults.
## Closing saves the options to GameManager.settings_slot and emits `closed`.

signal closed

const T := preload("res://scripts/game/game_text.gd")

var _tabs: TabContainer
var _remap_rows: Dictionary = {}  # action -> {"key": Button, "pad": Button}
var _capture_action: String = ""
var _capture_pad: bool = false
var _remap_note: Label
var _difficulty_note: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()


func _build() -> void:
	for c in get_children():
		c.queue_free()
	var parts := UiKit.modal(self, UiKit.CYAN, 760.0)
	var box: VBoxContainer = parts[1]
	box.add_child(UiKit.heading(T.t("opt_title"), 26))
	_tabs = TabContainer.new()
	_tabs.custom_minimum_size = Vector2(0.0, 430.0 * clampf(UiKit.scale(), 1.0, 1.3))
	_tabs.add_theme_font_size_override("font_size", UiKit.font(16))
	box.add_child(_tabs)
	_tabs.add_child(_accessibility_tab())
	_tabs.add_child(_gameplay_tab())
	_tabs.add_child(_audio_tab())
	_tabs.add_child(_controls_tab())
	var back := UiKit.button(T.t("opt_back"))
	back.name = "BackButton"
	back.pressed.connect(close)
	box.add_child(back)
	back.grab_focus.call_deferred()


func _page(title: String) -> Array:
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 10)
	scroll.add_child(v)
	return [scroll, v]


func _row(parent: Node, text: String, control: Control) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	var l := UiKit.label(text, 16)
	l.custom_minimum_size = Vector2(270.0 * clampf(UiKit.scale(), 1.0, 1.3), 0.0)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(l)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	parent.add_child(row)


func _slider(min_v: float, max_v: float, step: float, value: float, on_change: Callable) -> HSlider:
	var s := HSlider.new()
	s.min_value = min_v
	s.max_value = max_v
	s.step = step
	s.value = value
	s.custom_minimum_size = Vector2(240.0, 28.0)
	s.value_changed.connect(on_change)
	return s


func _check(value: bool, on_change: Callable) -> CheckButton:
	var c := CheckButton.new()
	c.button_pressed = value
	c.add_theme_font_size_override("font_size", UiKit.font(15))
	c.toggled.connect(on_change)
	return c


func _choice(items: Array, selected: int, on_change: Callable) -> OptionButton:
	var o := OptionButton.new()
	o.add_theme_font_size_override("font_size", UiKit.font(15))
	for i in items.size():
		o.add_item(str(items[i]), i)
	o.selected = selected
	o.item_selected.connect(on_change)
	return o


# --- tabs -------------------------------------------------------------------------------------------------------

func _accessibility_tab() -> Control:
	var p := _page(T.t("opt_tab_access"))
	var v: VBoxContainer = p[1]
	var scale_value := UiKit.label("%.2f×" % GameManager.font_scale, 15, UiKit.TEXT_DIM)
	var s := _slider(0.75, 2.0, 0.05, GameManager.font_scale, func(x: float):
		GameManager.font_scale = x
		scale_value.text = "%.2f×" % x
		GameManager.stats_changed.emit())
	# Rebuilding the panel on release re-lays it out at the new size.
	s.drag_ended.connect(func(_changed: bool): _rebuild_keep_tab())
	var srow := HBoxContainer.new()
	srow.add_child(s)
	srow.add_child(scale_value)
	_row(v, T.t("opt_text_size"), srow)
	_row(v, T.t("opt_high_contrast"), _check(GameManager.get_flag("accessibility_high_contrast"), func(on: bool):
		GameManager.set_flag("accessibility_high_contrast", on)
		GameManager.stats_changed.emit()
		_rebuild_keep_tab()))
	_row(v, T.t("opt_reduced_motion"), _check(GameManager.get_flag("accessibility_reduced_motion"), func(on: bool):
		GameManager.set_flag("accessibility_reduced_motion", on)
		GameManager.stats_changed.emit()))
	_row(v, T.t("opt_subtitles"), _check(GameSettings.subtitles_enabled(), func(on: bool): GameSettings.set_value("subtitles", on)))
	_row(v, T.t("opt_subtitle_bg"), _choice([T.t("opt_bg_none"), T.t("opt_bg_dim"), T.t("opt_bg_solid")], clampi(GameManager.subtitle_size, 0, 2), func(i: int):
		GameManager.subtitle_size = i
		GameManager.stats_changed.emit()))
	_row(v, T.t("opt_colorblind"), _choice([T.t("opt_cb_none"), T.t("opt_cb_deut"), T.t("opt_cb_prot"), T.t("opt_cb_trit")], AccessibilityManager.colorblind_mode(), func(i: int):
		GameManager.colorblind_mode = i
		GameManager.stats_changed.emit()))
	var speeds: Array = GameSettings.GAME_SPEEDS
	_row(v, T.t("opt_game_speed"), _choice(speeds.map(func(x): return "%d %%" % int(x * 100.0)), speeds.find(GameSettings.get_value("game_speed")), func(i: int):
		GameSettings.set_value("game_speed", speeds[i])))
	var note := UiKit.label(T.t("opt_game_speed_note"), 13, UiKit.TEXT_DIM)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(note)
	return p[0]


func _gameplay_tab() -> Control:
	var p := _page(T.t("opt_tab_game"))
	var v: VBoxContainer = p[1]
	var levels: Array = GameSettings.DIFFICULTIES
	_difficulty_note = UiKit.label(T.t("opt_diff_" + GameSettings.difficulty() + "_desc"), 14, UiKit.TEXT_DIM)
	_difficulty_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_row(v, T.t("opt_difficulty"), _choice(levels.map(func(d): return T.t("opt_diff_" + str(d))), levels.find(GameSettings.difficulty()), func(i: int):
		GameSettings.set_value("difficulty", levels[i])
		_difficulty_note.text = T.t("opt_diff_" + str(levels[i]) + "_desc")))
	v.add_child(_difficulty_note)
	var sens_value := UiKit.label("%.1f×" % GameSettings.look_sensitivity(), 15, UiKit.TEXT_DIM)
	var sens := _slider(0.4, 2.0, 0.1, GameSettings.look_sensitivity(), func(x: float):
		GameSettings.set_value("camera_sensitivity", x)
		sens_value.text = "%.1f×" % x)
	var srow := HBoxContainer.new()
	srow.add_child(sens)
	srow.add_child(sens_value)
	_row(v, T.t("opt_camera_sens"), srow)
	_row(v, T.t("opt_invert_y"), _check(GameSettings.invert_y(), func(on: bool): GameSettings.set_value("invert_y", on)))
	return p[0]


func _audio_tab() -> Control:
	var p := _page(T.t("opt_tab_audio"))
	var v: VBoxContainer = p[1]
	for key in ["master_volume", "music_volume", "sfx_volume"]:
		var k: String = key
		_row(v, T.t("opt_" + k), _slider(0.0, 1.0, 0.05, float(GameSettings.get_value(k)), func(x: float): GameSettings.set_value(k, x)))
	return p[0]


func _controls_tab() -> Control:
	var p := _page(T.t("opt_tab_controls"))
	var v: VBoxContainer = p[1]
	var head := HBoxContainer.new()
	var h1 := UiKit.label(T.t("opt_ctrl_action"), 14, UiKit.TEXT_DIM)
	h1.custom_minimum_size = Vector2(230.0 * clampf(UiKit.scale(), 1.0, 1.3), 0.0)
	head.add_child(h1)
	var h2 := UiKit.label(T.t("opt_ctrl_keyboard"), 14, UiKit.TEXT_DIM)
	h2.custom_minimum_size = Vector2(180.0, 0.0)
	head.add_child(h2)
	head.add_child(UiKit.label(T.t("opt_ctrl_gamepad"), 14, UiKit.TEXT_DIM))
	v.add_child(head)
	for action in InputRemapManager.REMAPPABLE_ACTIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var name_l := UiKit.label(T.t("action_" + action), 15)
		name_l.custom_minimum_size = Vector2(230.0 * clampf(UiKit.scale(), 1.0, 1.3), 0.0)
		row.add_child(name_l)
		var kb := UiKit.button("", 170.0)
		kb.pressed.connect(_begin_capture.bind(action, false))
		row.add_child(kb)
		var pb := UiKit.button("", 170.0)
		pb.pressed.connect(_begin_capture.bind(action, true))
		row.add_child(pb)
		v.add_child(row)
		_remap_rows[action] = {"key": kb, "pad": pb}
	_remap_note = UiKit.label(T.t("opt_ctrl_note"), 14, UiKit.AMBER)
	_remap_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(_remap_note)
	var fixed := UiKit.label(T.t("opt_ctrl_fixed"), 13, UiKit.TEXT_DIM)
	fixed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(fixed)
	var reset := UiKit.button(T.t("opt_ctrl_reset"))
	reset.pressed.connect(func():
		InputRemapManager.reset_all()
		_capture_action = ""
		_remap_note.text = T.t("opt_ctrl_reset_done")
		_refresh_remap())
	v.add_child(reset)
	_refresh_remap()
	return p[0]


# --- remapping ------------------------------------------------------------------------------------------------------

func _refresh_remap() -> void:
	for action in _remap_rows:
		var row: Dictionary = _remap_rows[action]
		var capturing: bool = action == _capture_action
		(row["key"] as Button).text = T.t("opt_ctrl_press") if capturing and not _capture_pad else InputRemapManager.key_label(InputRemapManager.current_keycode(action))
		(row["pad"] as Button).text = T.t("opt_ctrl_press") if capturing and _capture_pad else InputRemapManager.pad_label(InputRemapManager.current_pad_button(action))


func _begin_capture(action: String, pad: bool) -> void:
	_capture_action = action
	_capture_pad = pad
	_remap_note.text = T.t("opt_ctrl_capture_pad" if pad else "opt_ctrl_capture_key", {"action": T.t("action_" + action)})
	_refresh_remap()


func _input(event: InputEvent) -> void:
	if _capture_action.is_empty():
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
			get_viewport().set_input_as_handled()
			close()
		return
	var action := _capture_action
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		var code := (event as InputEventKey).physical_keycode
		if code == KEY_ESCAPE:
			_capture_action = ""
			_remap_note.text = T.t("opt_ctrl_cancelled")
		elif _capture_pad:
			return  # waiting for a gamepad button
		else:
			var other := InputRemapManager.conflict_for_key(action, code)
			var old := InputRemapManager.current_keycode(action)
			if InputRemapManager.rebind(action, code):
				_capture_action = ""
				_remap_note.text = _result_text(action, InputRemapManager.key_label(code), other, InputRemapManager.key_label(old))
		_refresh_remap()
	elif event is InputEventJoypadButton and event.pressed:
		get_viewport().set_input_as_handled()
		var button := (event as InputEventJoypadButton).button_index
		if button == JOY_BUTTON_START:
			_capture_action = ""
			_remap_note.text = T.t("opt_ctrl_cancelled")
		elif _capture_pad:
			var other := InputRemapManager.conflict_for_pad(action, button)
			var old := InputRemapManager.current_pad_button(action)
			if InputRemapManager.rebind_pad(action, button):
				_capture_action = ""
				_remap_note.text = _result_text(action, InputRemapManager.pad_label(button), other, InputRemapManager.pad_label(old))
		_refresh_remap()


func _result_text(action: String, new_label: String, other: String, old_label: String) -> String:
	if other.is_empty():
		return T.t("opt_ctrl_done", {"action": T.t("action_" + action), "key": new_label})
	return T.t("opt_ctrl_swapped", {"action": T.t("action_" + action), "key": new_label, "other": T.t("action_" + other), "old": old_label})


# --- lifecycle --------------------------------------------------------------------------------------------------------

func _rebuild_keep_tab() -> void:
	var tab := _tabs.current_tab if _tabs != null else 0
	_remap_rows.clear()
	_build.call_deferred()
	(func(): if _tabs != null: _tabs.current_tab = tab).call_deferred()


func close() -> void:
	GameManager.save_settings()
	closed.emit()
	queue_free()
