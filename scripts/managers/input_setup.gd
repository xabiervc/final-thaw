extends Node
## Crea las 16 acciones de entrada por codigo (remapeables en runtime).

const ACTIONS = {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"attack_primary": [KEY_J, KEY_K],
	"attack_secondary": [KEY_L],
	"dodge": [KEY_SPACE, KEY_SHIFT],
	"interact": [KEY_E, KEY_F],
	"scan": [KEY_TAB, KEY_Q],
	"pause": [KEY_ESCAPE, KEY_P],
	"quick_save": [KEY_F5],
	"quick_load": [KEY_F9],
	"toggle_captions": [KEY_C],
	"increase_font": [KEY_EQUAL, KEY_PLUS],
	"decrease_font": [KEY_MINUS],
	"toggle_colorblind_mode": [KEY_B],
}

func _ready() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in ACTIONS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
	_add_mouse("attack_primary", MOUSE_BUTTON_LEFT)
	_add_mouse("attack_secondary", MOUSE_BUTTON_RIGHT)

func _add_mouse(action: String, button: int) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)
