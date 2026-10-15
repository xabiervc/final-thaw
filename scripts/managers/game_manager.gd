extends Node
## Autoload. Estado global + guardado con CRC32.

signal stats_changed
signal character_switched(character_id: String)

var civilian_aid: int = 0
var prototype_integrity: int = 3
var elena_safety: int = 3
var evidence_choice: String = "preserve"
var memory_fragments_collected: Array = []
var current_phase: int = 0
var playtime_seconds: float = 0.0

var active_character_id: String = "elena"
var current_checkpoint_id: String = ""
var has_prototype: bool = false
var elena_condition: Dictionary = {}
var world_state: Dictionary = {}

var font_scale: float = 1.0
var colorblind_mode: int = 0
var subtitle_size: int = 2
var input_profile: String = "default"
## Persisted boolean preferences (e.g. accessibility_high_contrast); kept across new games like the other options.
var flags: Dictionary = {}
## Persisted player options (difficulty, camera, audio, subtitles, game speed, input bindings). Read and written
## through GameSettings / InputRemapManager; kept across new games. Older saves without it load with defaults.
var settings: Dictionary = {}
## Slot the options menus write to. Tests point it elsewhere so they never overwrite the player's options.
var settings_slot: int = 0

func _ready() -> void:
	load_game(0)
	# Autoload order runs InputSetup before this load: re-apply the persisted bindings and options now.
	InputRemapManager.restore_all()
	GameSettings.apply()

## Saves the options (and the rest of the session state, as the options menu always has) to settings_slot.
func save_settings() -> bool:
	return save_game(settings_slot)

func save_path(slot: int) -> String:
	return "user://save_%d.json" % slot

func set_flag(key: String, value: bool) -> void:
	flags[key] = value

func get_flag(key: String, default: bool = false) -> bool:
	return bool(flags.get(key, default))

func set_active_character(character_id: String) -> void:
	if character_id == active_character_id:
		return
	active_character_id = character_id
	character_switched.emit(character_id)

func get_active_character() -> String:
	return active_character_id

func new_game() -> void:
	civilian_aid = 0
	prototype_integrity = 3
	elena_safety = 3
	evidence_choice = "preserve"
	memory_fragments_collected = []
	current_phase = 0
	playtime_seconds = 0.0
	active_character_id = "elena"
	current_checkpoint_id = ""
	has_prototype = false
	elena_condition = {}
	world_state = {}
	stats_changed.emit()

func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(save_path(slot))

func crc32(bytes: PackedByteArray) -> int:
	var crc: int = 0xFFFFFFFF
	for b in bytes:
		crc ^= b
		for _i in 8:
			if crc & 1:
				crc = (crc >> 1) ^ 0xEDB88320
			else:
				crc = crc >> 1
	return crc ^ 0xFFFFFFFF

func _collect() -> Dictionary:
	return {
		"version": 1,
		"phase": current_phase,
		"playtime": playtime_seconds,
		"civilian_aid": civilian_aid,
		"prototype_integrity": prototype_integrity,
		"elena_safety": elena_safety,
		"evidence_choice": evidence_choice,
		"memory_fragments": memory_fragments_collected,
		"font_scale": font_scale,
		"colorblind_mode": colorblind_mode,
		"subtitle_size": subtitle_size,
		"input_profile": input_profile,
		"flags": flags,
		"settings": settings,
		"active_character_id": active_character_id,
		"current_checkpoint_id": current_checkpoint_id,
		"has_prototype": has_prototype,
		"elena_condition": elena_condition,
		"world_state": world_state,
	}

func _apply(d: Dictionary) -> void:
	current_phase = int(d.get("phase", 0))
	playtime_seconds = float(d.get("playtime", 0.0))
	civilian_aid = int(d.get("civilian_aid", 0))
	prototype_integrity = clampi(int(d.get("prototype_integrity", 3)), 0, 3)
	elena_safety = int(d.get("elena_safety", 3))
	evidence_choice = str(d.get("evidence_choice", "preserve"))
	memory_fragments_collected = d.get("memory_fragments", [])
	font_scale = float(d.get("font_scale", 1.0))
	colorblind_mode = int(d.get("colorblind_mode", 0))
	subtitle_size = int(d.get("subtitle_size", 2))
	input_profile = str(d.get("input_profile", "default"))
	var saved_flags = d.get("flags", {})
	flags = saved_flags if typeof(saved_flags) == TYPE_DICTIONARY else {}
	var saved_settings = d.get("settings", {})
	settings = saved_settings if typeof(saved_settings) == TYPE_DICTIONARY else {}
	active_character_id = str(d.get("active_character_id", "elena"))
	current_checkpoint_id = str(d.get("current_checkpoint_id", ""))
	has_prototype = bool(d.get("has_prototype", false))
	var ec = d.get("elena_condition", {})
	if typeof(ec) == TYPE_DICTIONARY:
		elena_condition = ec
	else:
		elena_condition = {}
	var ws = d.get("world_state", {})
	if typeof(ws) == TYPE_DICTIONARY:
		world_state = ws
	else:
		world_state = {}
	stats_changed.emit()

func save_game(slot: int = 0) -> bool:
	# El payload se guarda como TEXTO para que el CRC sea estable al releer.
	var payload: String = JSON.stringify(_collect())
	var container := {"payload": payload, "crc32": crc32(payload.to_utf8_buffer())}
	var f := FileAccess.open(save_path(slot), FileAccess.WRITE)
	if f == null:
		push_error("No se pudo abrir el guardado: %s" % error_string(FileAccess.get_open_error()))
		return false
	f.store_string(JSON.stringify(container))
	f.close()
	return true

func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false
	var f := FileAccess.open(save_path(slot), FileAccess.READ)
	if f == null:
		return false
	var text: String = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("payload") or not parsed.has("crc32"):
		push_warning("Guardado corrupto (estructura).")
		return false
	var payload: String = str(parsed["payload"])
	if int(parsed["crc32"]) != crc32(payload.to_utf8_buffer()):
		push_warning("Guardado corrupto (CRC32 no coincide).")
		return false
	var data = JSON.parse_string(payload)
	if typeof(data) != TYPE_DICTIONARY:
		return false
	_apply(data)
	return true

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
