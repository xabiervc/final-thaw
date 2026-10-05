extends Node
class_name GameStateManager

## Persistent state dictionary for the current session.
## Example keys:
##   "shelter_power_restored": bool
##   "shelter_valves_opened": bool
##   "shelter_civilian_rescued": bool
##   "flags": { "demo_seen_intro": true }
var state: Dictionary = {}

func _ready() -> void:
	# In the future, load from disk / cloud here.
	state = {}

func set_flag(key: String, value: bool) -> void:
	state[key] = value

func get_flag(key: String, default: bool = false) -> bool:
	return state.get(key, default)

func set_nested(keys: Array, value: Variant) -> void:
	var current = state
	for i in range(keys.size() - 1):
		var k = keys[i]
		if not current.has(k):
			current[k] = {}
		current = current[k]
	current[keys[-1]] = value

func get_nested(keys: Array, default: Variant = null) -> Variant:
	var current = state
	for k in keys:
		if not current is Dictionary or not current.has(k):
			return default
		current = current[k]
	return current

func merge_from(other: Dictionary) -> void:
	for k in other:
		state[k] = other[k]

func clear() -> void:
	state = {}

# Future: save_to_file(path: String) / load_from_file(path: String)
