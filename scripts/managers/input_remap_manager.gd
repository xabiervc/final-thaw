class_name InputRemapManager
extends RefCounted

## Runtime remapping of the gameplay actions, keyboard and gamepad.
##
## Each action has a PRIMARY keyboard key and a PRIMARY gamepad button (the first event of that kind in the input
## map). Rebinding replaces only the primary, so secondary defaults (arrow keys, the F key, the right trigger for
## running) keep working. Binding a key or button that is another gameplay action's primary SWAPS the two
## bindings; taking another action's secondary key just moves it (that action keeps its primary). Either way no
## action is left without a control and no control does two things.
## Escape and Start stay on `pause` (system controls: they also cancel menus and capture).
## Bindings are stored in GameManager.settings["bindings"] and persisted by GameManager.save_settings().

const InputSetupScript := preload("res://scripts/managers/input_setup.gd")

const REMAPPABLE_ACTIONS: Array[String] = ["move_up", "move_down", "move_left", "move_right", "run", "crouch", "jump",
	"interact", "scan", "hint"]
const RESERVED_KEYS := [KEY_ESCAPE]
const RESERVED_PAD := [JOY_BUTTON_START]


# --- queries --------------------------------------------------------------------------------------------------------

static func current_keycode(action: String) -> int:
	var e := _primary_key_event(action)
	return e.physical_keycode if e != null else KEY_NONE


static func current_pad_button(action: String) -> int:
	var e := _primary_pad_event(action)
	return e.button_index if e != null else JOY_BUTTON_INVALID


## The gameplay action (other than `action`) that already uses this key, or "".
static func conflict_for_key(action: String, keycode: int) -> String:
	for other in REMAPPABLE_ACTIONS:
		if other == action or not InputMap.has_action(other):
			continue
		for e in InputMap.action_get_events(other):
			if e is InputEventKey and (e as InputEventKey).physical_keycode == keycode:
				return other
	return ""


static func conflict_for_pad(action: String, button: int) -> String:
	for other in REMAPPABLE_ACTIONS:
		if other == action or not InputMap.has_action(other):
			continue
		for e in InputMap.action_get_events(other):
			if e is InputEventJoypadButton and (e as InputEventJoypadButton).button_index == button:
				return other
	return ""


# --- changes --------------------------------------------------------------------------------------------------------

## Binds `keycode` as the primary key of `action`. If another gameplay action used it, that action receives the old
## primary key of `action` instead (swap). Returns false for unknown actions or reserved keys.
static func rebind(action: String, keycode: int, save_binding: bool = true) -> bool:
	if not REMAPPABLE_ACTIONS.has(action) or keycode == KEY_NONE or RESERVED_KEYS.has(keycode):
		return false
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var old := current_keycode(action)
	if old == keycode:
		return true
	var other := conflict_for_key(action, keycode)
	if other != "":
		_replace_key(other, keycode, old)
		if save_binding:
			_store(other)
	_set_primary_key(action, keycode)
	if save_binding:
		_store(action)
	return true


## Gamepad counterpart of rebind() (buttons only; sticks stay on the analog axes).
static func rebind_pad(action: String, button: int, save_binding: bool = true) -> bool:
	if not REMAPPABLE_ACTIONS.has(action) or button < 0 or RESERVED_PAD.has(button):
		return false
	var old := current_pad_button(action)
	if old == button:
		return true
	var other := conflict_for_pad(action, button)
	if other != "":
		_replace_pad(other, button, old)
		if save_binding:
			_store(other)
	_set_primary_pad(action, button)
	if save_binding:
		_store(action)
	return true


## Re-applies the persisted bindings over the defaults (called at start-up once the save is loaded).
static func restore_all() -> void:
	var saved = GameManager.settings.get("bindings", {}) if GameManager != null else {}
	if typeof(saved) != TYPE_DICTIONARY:
		return
	for action in saved:
		if not REMAPPABLE_ACTIONS.has(action) or typeof(saved[action]) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = saved[action]
		var key := int(entry.get("key", KEY_NONE))
		if key != KEY_NONE and not RESERVED_KEYS.has(key):
			_set_primary_key(action, key)
		var pad := int(entry.get("pad", JOY_BUTTON_INVALID))
		if pad >= 0 and not RESERVED_PAD.has(pad):
			_set_primary_pad(action, pad)


## Restores every gameplay action to its default keys and buttons and forgets the stored bindings.
static func reset_all() -> void:
	for action in REMAPPABLE_ACTIONS:
		if not InputMap.has_action(action):
			continue
		for e in InputMap.action_get_events(action):
			if e is InputEventKey or e is InputEventJoypadButton:
				InputMap.action_erase_event(action, e)
		for k in InputSetupScript.ACTIONS.get(action, []):
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
		for button in InputSetupScript.PAD_BUTTONS.get(action, []):
			var jb := InputEventJoypadButton.new()
			jb.button_index = button
			InputMap.action_add_event(action, jb)
	GameManager.settings.erase("bindings")


# --- labels ---------------------------------------------------------------------------------------------------------

static func key_label(keycode: int) -> String:
	if keycode == KEY_NONE:
		return "—"
	return OS.get_keycode_string(keycode)


## Short, layout-neutral gamepad names (Xbox / PlayStation).
static func pad_label(button: int) -> String:
	match button:
		JOY_BUTTON_A: return "A / ✕"
		JOY_BUTTON_B: return "B / ○"
		JOY_BUTTON_X: return "X / □"
		JOY_BUTTON_Y: return "Y / △"
		JOY_BUTTON_LEFT_SHOULDER: return "LB / L1"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB / R1"
		JOY_BUTTON_LEFT_STICK: return "L3"
		JOY_BUTTON_RIGHT_STICK: return "R3"
		JOY_BUTTON_BACK: return "View / Share"
		JOY_BUTTON_START: return "Menu / Options"
		JOY_BUTTON_DPAD_UP: return "D-pad ↑"
		JOY_BUTTON_DPAD_DOWN: return "D-pad ↓"
		JOY_BUTTON_DPAD_LEFT: return "D-pad ←"
		JOY_BUTTON_DPAD_RIGHT: return "D-pad →"
		JOY_BUTTON_INVALID: return "—"
	return "Pad %d" % button


# --- internals ------------------------------------------------------------------------------------------------------

static func _primary_key_event(action: String) -> InputEventKey:
	if not InputMap.has_action(action):
		return null
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			return e as InputEventKey
	return null


static func _primary_pad_event(action: String) -> InputEventJoypadButton:
	if not InputMap.has_action(action):
		return null
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton:
			return e as InputEventJoypadButton
	return null


## Replaces the primary key, keeping it first in the event list so it stays the primary.
static func _set_primary_key(action: String, keycode: int) -> void:
	var events := InputMap.action_get_events(action)
	var kept: Array = []
	var replaced := false
	for e in events:
		if e is InputEventKey and not replaced:
			replaced = true
			continue
		if e is InputEventKey and (e as InputEventKey).physical_keycode == keycode:
			continue  # no duplicate of the new key as a secondary
		kept.append(e)
	InputMap.action_erase_events(action)
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action, ev)
	for e in kept:
		InputMap.action_add_event(action, e)


static func _set_primary_pad(action: String, button: int) -> void:
	var events := InputMap.action_get_events(action)
	var kept: Array = []
	var replaced := false
	for e in events:
		if e is InputEventJoypadButton and not replaced:
			replaced = true
			continue
		if e is InputEventJoypadButton and (e as InputEventJoypadButton).button_index == button:
			continue
		kept.append(e)
	InputMap.action_erase_events(action)
	var jb := InputEventJoypadButton.new()
	jb.button_index = button
	InputMap.action_add_event(action, jb)
	for e in kept:
		InputMap.action_add_event(action, e)


## In `action`, the event using `taken` becomes `given` (or is removed if `given` is none).
static func _replace_key(action: String, taken: int, given: int) -> void:
	var was_primary := current_keycode(action) == taken
	for e in InputMap.action_get_events(action):
		if e is InputEventKey and (e as InputEventKey).physical_keycode == taken:
			if was_primary:
				if given != KEY_NONE:
					_set_primary_key(action, given)  # replaces the primary in place
				else:
					InputMap.action_erase_event(action, e)
			else:
				InputMap.action_erase_event(action, e)  # a secondary key just moves; the primary keeps the action usable
			return


static func _replace_pad(action: String, taken: int, given: int) -> void:
	var was_primary := current_pad_button(action) == taken
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton and (e as InputEventJoypadButton).button_index == taken:
			if was_primary and given >= 0:
				_set_primary_pad(action, given)
			else:
				InputMap.action_erase_event(action, e)
			return


static func _store(action: String) -> void:
	var all = GameManager.settings.get("bindings", {})
	if typeof(all) != TYPE_DICTIONARY:
		all = {}
	all[action] = {"key": current_keycode(action), "pad": current_pad_button(action)}
	GameManager.settings["bindings"] = all
