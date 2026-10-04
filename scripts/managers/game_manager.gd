extends Node
## Autoload. Estado global + guardado con CRC32.

signal stats_changed

var civilian_aid: int = 0
var prototype_integrity: int = 3
var elena_safety: int = 3
var evidence_choice: String = "preserve"
var memory_fragments_collected: Array = []
var current_phase: int = 0
var playtime_seconds: float = 0.0

var font_scale: float = 1.0
var colorblind_mode: int = 0
var subtitle_size: int = 2
var input_profile: String = "default"

func _ready() -> void:
	load_game(0)

func save_path(slot: int) -> String:
	return "user://save_%d.json" % slot

func new_game() -> void:
	civilian_aid = 0
	prototype_integrity = 3
	elena_safety = 3
	evidence_choice = "preserve"
	memory_fragments_collected = []
	current_phase = 0
	playtime_seconds = 0.0
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
	}

func _apply(d: Dictionary) -> void:
	current_phase = int(d.get("phase", 0))
	playtime_seconds = float(d.get("playtime", 0.0))
	civilian_aid = int(d.get("civilian_aid", 0))
	prototype_integrity = int(d.get("prototype_integrity", 3))
	elena_safety = int(d.get("elena_safety", 3))
	evidence_choice = str(d.get("evidence_choice", "preserve"))
	memory_fragments_collected = d.get("memory_fragments", [])
	font_scale = float(d.get("font_scale", 1.0))
	colorblind_mode = int(d.get("colorblind_mode", 0))
	subtitle_size = int(d.get("subtitle_size", 2))
	input_profile = str(d.get("input_profile", "default"))
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
