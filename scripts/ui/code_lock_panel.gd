extends CanvasLayer
## Four-digit code lock (the dispatch drawer). It opens over the world without pausing it; while it is open the player
## is frozen by its owner (the transfer controller) and every input it uses is a remappable action: move_left /
## move_right choose the digit, move_up / move_down change it, interact tries the code, pause cancels.
## It only collects a code: whether the code is right is decided by phase1_transfer_state.gd.
## The selected digit is shown with brackets as well as colour, and every instruction is text (never colour alone).

signal submitted(code: String)
signal cancelled

const T := preload("res://scripts/game/game_text.gd")
const HudScript := preload("res://scripts/ui/prompt_hud.gd")
const DIGITS := 4

var is_open: bool = false
## Physics frame in which the lock closed: the scene polls `interact` once per physics frame, so the press that submitted
## the right code must not also be read as "use the drawer" in the frame after the lock closes.
var closed_physics_frame: int = -100
var digits: Array[int] = [0, 0, 0, 0]
var index: int = 0
var _root: Control = null
var _cells: Array[Label] = []
var _status: Label = null
var _help: Label = null
var _title: Label = null


func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(false)


func code() -> String:
	var out := ""
	for d in digits:
		out += str(d)
	return out


func open() -> void:
	if is_open:
		return
	if _root == null:
		_build()
	for i in DIGITS:
		digits[i] = 0
	index = 0
	_status.text = ""
	_root.visible = true
	is_open = true
	set_process_input(true)
	_refresh()


func recently_closed() -> bool:
	return Engine.get_physics_frames() - closed_physics_frame <= 1


func close() -> void:
	if not is_open:
		return
	is_open = false
	closed_physics_frame = Engine.get_physics_frames()
	set_process_input(false)
	if _root != null:
		_root.visible = false


## Feedback line under the digits ("wrong code", "open").
func show_status(text: String) -> void:
	if _status != null:
		_status.text = text


func _build() -> void:
	var made: Array = UiKit.modal(self, UiKit.AMBER, 520.0)
	_root = made[0]
	var box: VBoxContainer = made[1]
	_title = UiKit.heading(T.t("code_title"), 22)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_title)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	box.add_child(row)
	for i in DIGITS:
		var cell := UiKit.label("0", 44, UiKit.TEXT)
		cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.custom_minimum_size = Vector2(UiKit.font(70), UiKit.font(64))
		row.add_child(cell)
		_cells.append(cell)
	_status = UiKit.label("", 18, UiKit.AMBER)
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_status)
	_help = UiKit.label("", 15, UiKit.TEXT_DIM)
	_help.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_help)


func _refresh() -> void:
	if _root == null:
		return
	_title.text = T.t("code_title")
	for i in DIGITS:
		var selected := i == index
		_cells[i].text = ("[%d]" % digits[i]) if selected else (" %d " % digits[i])
		_cells[i].add_theme_color_override("font_color", UiKit.AMBER if selected else UiKit.TEXT)
	_help.text = T.t("code_help", {
		"left": HudScript.action_label("move_left"), "right": HudScript.action_label("move_right"),
		"up": HudScript.action_label("move_up"), "down": HudScript.action_label("move_down"),
		"interact": HudScript.action_label("interact"), "pause": HudScript.action_label("pause")})


func _input(event: InputEvent) -> void:
	if not is_open:
		return
	var handled := true
	if event.is_action_pressed("move_left"):
		index = (index + DIGITS - 1) % DIGITS
	elif event.is_action_pressed("move_right"):
		index = (index + 1) % DIGITS
	elif event.is_action_pressed("move_up"):
		digits[index] = (digits[index] + 1) % 10
	elif event.is_action_pressed("move_down"):
		digits[index] = (digits[index] + 9) % 10
	elif event.is_action_pressed("interact"):
		_status.text = ""
		submitted.emit(code())
	elif event.is_action_pressed("pause"):
		close()
		cancelled.emit()
	else:
		handled = false
	if handled:
		get_viewport().set_input_as_handled()
		_refresh()
