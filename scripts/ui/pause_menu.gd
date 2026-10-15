class_name PauseMenu
extends CanvasLayer
## In-game pause menu. Pauses the scene tree and offers: resume, field notes (what Elena has observed and inferred),
## options (shared OptionsPanel), retry from the last safe point (only while a checkpoint exists) and quit to the
## main menu (with confirmation: Phase 1/2 progress is session-only).
##
## The host scene provides the content through an explicit interface:
##   pause_notes() -> Array of {"title": String, "body": String}
##   can_retry() -> bool          retry_from_checkpoint() -> void          quit_to_menu() -> void

signal opened
signal closed_menu

const T := preload("res://scripts/game/game_text.gd")

var host: Node = null
var is_open: bool = false
var _root: Control = null
var _sub: Control = null
var _mouse_before: int = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS


func open() -> void:
	if is_open:
		return
	is_open = true
	_mouse_before = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	_show_main()
	opened.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	_clear()
	get_tree().paused = false
	if _mouse_before == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	closed_menu.emit()


func _clear() -> void:
	if _sub != null and is_instance_valid(_sub):
		_sub.queue_free()
	_sub = null
	if _root != null and is_instance_valid(_root):
		_root.queue_free()
	_root = null


func _show_main() -> void:
	_clear()
	var parts := UiKit.modal(self, UiKit.CYAN, 420.0)
	_root = parts[0]
	var box: VBoxContainer = parts[1]
	box.add_child(UiKit.heading(T.t("pause_title"), 26))
	var resume := UiKit.button(T.t("pause_resume"))
	resume.name = "Resume"
	resume.pressed.connect(close)
	box.add_child(resume)
	var notes := UiKit.button(T.t("pause_notes"))
	notes.name = "Notes"
	notes.pressed.connect(_show_notes)
	box.add_child(notes)
	var options := UiKit.button(T.t("pause_options"))
	options.name = "Options"
	options.pressed.connect(_show_options)
	box.add_child(options)
	if host != null and host.has_method("can_retry") and bool(host.call("can_retry")):
		var retry := UiKit.button(T.t("pause_retry"))
		retry.name = "Retry"
		retry.pressed.connect(func():
			close()
			host.call("retry_from_checkpoint"))
		box.add_child(retry)
	var quit := UiKit.button(T.t("pause_quit"))
	quit.name = "Quit"
	quit.pressed.connect(_confirm_quit)
	box.add_child(quit)
	resume.grab_focus.call_deferred()


func _show_notes() -> void:
	_clear()
	var parts := UiKit.modal(self, UiKit.AMBER, 680.0)
	_root = parts[0]
	var box: VBoxContainer = parts[1]
	box.add_child(UiKit.heading(T.t("notes_title"), 24))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0.0, 380.0 * clampf(UiKit.scale(), 1.0, 1.3))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	var entries: Array = host.call("pause_notes") if host != null and host.has_method("pause_notes") else []
	if entries.is_empty():
		list.add_child(UiKit.label(T.t("notes_empty"), 15, UiKit.TEXT_DIM))
	for e in entries:
		var title := UiKit.label(str(e.get("title", "")), 17, UiKit.AMBER)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(title)
		var body := UiKit.label(str(e.get("body", "")), 15)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list.add_child(body)
	var back := UiKit.button(T.t("pause_back"))
	back.pressed.connect(_show_main)
	box.add_child(back)
	back.grab_focus.call_deferred()


func _show_options() -> void:
	_clear()
	_sub = OptionsPanel.new()
	add_child(_sub)
	(_sub as OptionsPanel).closed.connect(func():
		_sub = null
		if is_open:
			_show_main())


func _confirm_quit() -> void:
	_clear()
	var parts := UiKit.modal(self, UiKit.AMBER, 520.0)
	_root = parts[0]
	var box: VBoxContainer = parts[1]
	box.add_child(UiKit.heading(T.t("pause_quit_title"), 22))
	var warn := UiKit.label(T.t("pause_quit_body"), 15)
	warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(warn)
	var yes := UiKit.button(T.t("pause_quit_yes"))
	yes.pressed.connect(func():
		close()
		if host != null and host.has_method("quit_to_menu"):
			host.call("quit_to_menu"))
	box.add_child(yes)
	var no := UiKit.button(T.t("pause_quit_no"))
	no.pressed.connect(_show_main)
	box.add_child(no)
	no.grab_focus.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or _sub != null:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
