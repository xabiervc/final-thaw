extends Node
## Crea las acciones de entrada por codigo (remapeables en runtime).
## Keyboard and gamepad defaults live here; InputRemapManager restores the player's own bindings over them.
## The 16 Phase 0 action names are a contract (tests/test_phase_0.gd) and stay, including the legacy combat ones
## used by older scenes; the Phase 1/2 game only uses the actions listed in InputRemapManager.REMAPPABLE_ACTIONS.

const ACTIONS = {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE],
	"attack_primary": [KEY_J, KEY_K],
	"attack_secondary": [KEY_L],
	"dodge": [KEY_SPACE, KEY_SHIFT],
	"interact": [KEY_E, KEY_F],
	"scan": [KEY_TAB, KEY_Q],
	"pause": [KEY_ESCAPE, KEY_P],
	"quick_save": [KEY_F2],
	"quick_load": [KEY_F3],
	"toggle_captions": [KEY_V],
	"increase_font": [KEY_EQUAL, KEY_PLUS],
	"decrease_font": [KEY_MINUS],
	"toggle_colorblind_mode": [KEY_B],
	"run": [KEY_SHIFT],
	"crouch": [KEY_CTRL, KEY_C],
	"hint": [KEY_H],
	"look_left": [],
	"look_right": [],
	"look_up": [],
	"look_down": [],
}

## Gamepad buttons per action (Xbox naming; Godot maps other pads to the same indices).
const PAD_BUTTONS = {
	"jump": [JOY_BUTTON_A],
	"crouch": [JOY_BUTTON_B],
	"interact": [JOY_BUTTON_X],
	"scan": [JOY_BUTTON_Y],
	"run": [JOY_BUTTON_LEFT_SHOULDER],
	"hint": [JOY_BUTTON_BACK],
	"pause": [JOY_BUTTON_START],
	"toggle_captions": [],
}

## Gamepad axes per action: [axis, direction]. Sticks move and look; the right trigger also runs.
const PAD_AXES = {
	"move_left": [JOY_AXIS_LEFT_X, -1.0],
	"move_right": [JOY_AXIS_LEFT_X, 1.0],
	"move_up": [JOY_AXIS_LEFT_Y, -1.0],
	"move_down": [JOY_AXIS_LEFT_Y, 1.0],
	"look_left": [JOY_AXIS_RIGHT_X, -1.0],
	"look_right": [JOY_AXIS_RIGHT_X, 1.0],
	"look_up": [JOY_AXIS_RIGHT_Y, -1.0],
	"look_down": [JOY_AXIS_RIGHT_Y, 1.0],
	"run": [JOY_AXIS_TRIGGER_RIGHT, 1.0],
}

const STICK_DEADZONE := 0.22

func _ready() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in ACTIONS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
	for action in PAD_BUTTONS:
		for button in PAD_BUTTONS[action]:
			var jb := InputEventJoypadButton.new()
			jb.button_index = button
			InputMap.action_add_event(action, jb)
	for action in PAD_AXES:
		var spec: Array = PAD_AXES[action]
		var jm := InputEventJoypadMotion.new()
		jm.axis = spec[0]
		jm.axis_value = spec[1]
		InputMap.action_add_event(action, jm)
		InputMap.action_set_deadzone(action, STICK_DEADZONE)
	_add_mouse("attack_primary", MOUSE_BUTTON_LEFT)
	_add_mouse("attack_secondary", MOUSE_BUTTON_RIGHT)
	InputRemapManager.restore_all()

func _add_mouse(action: String, button: int) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)
