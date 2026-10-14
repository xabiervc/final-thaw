class_name InputRemapManager
extends RefCounted

## Runtime keyboard remapping for core gameplay actions.
## Bindings are persisted through GameStateManager.

const REMAPPABLE_ACTIONS: Array[String] = ["interact", "jump", "scan"]

static func current_keycode(action: String) -> int:
	if not InputMap.has_action(action):
		return KEY_NONE
	for event in InputMap.action_get_events(action):
		var key_event := event as InputEventKey
		if key_event != null:
			return key_event.physical_keycode
	return KEY_NONE

static func rebind(action: String, keycode: int, save_binding: bool = true) -> bool:
	if not REMAPPABLE_ACTIONS.has(action) or keycode == KEY_NONE:
		return false
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)

	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action, key_event)

	if save_binding:
		GameStateManager.set_nested(["input_rebinds", action], keycode)
	return true

static func restore_all() -> void:
	for action in REMAPPABLE_ACTIONS:
		var keycode: Variant = GameStateManager.get_nested(["input_rebinds", action], KEY_NONE)
		if typeof(keycode) == TYPE_INT and keycode != KEY_NONE:
			rebind(action, int(keycode), false)

static func reset_all() -> void:
	for action in REMAPPABLE_ACTIONS:
		GameStateManager.set_nested(["input_rebinds", action], KEY_NONE)
