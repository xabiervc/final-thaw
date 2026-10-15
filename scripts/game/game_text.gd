class_name GameText
extends RefCounted
## Localized text for the Phase 1/2 game, its menus and cinematics: res://data/game_text.json maps every key to
## {"es": ..., "en": ...}. The language is the one chosen in the main menu (NarrativeTextManager.current_locale).
## Placeholders use String.format: "{key}" -> t("prompt", {"key": "E"}).
## tests/test_game_text.gd checks that every key has both languages and that every key used in code exists.

const PATH := "res://data/game_text.json"

static var _table: Dictionary = {}
static var _missing: Dictionary = {}


static func t(key: String, args: Dictionary = {}) -> String:
	_load()
	var entry = _table.get(key)
	if typeof(entry) != TYPE_DICTIONARY:
		if not _missing.has(key):
			_missing[key] = true
			push_warning("GameText: missing key '%s'" % key)
		return key
	var locale := str(NarrativeTextManager.current_locale)
	var text := str(entry.get(locale, entry.get("es", key)))
	return text.format(args) if not args.is_empty() else text


static func has(key: String) -> bool:
	_load()
	return _table.has(key)


static func keys() -> Array:
	_load()
	return _table.keys()


static func entry(key: String) -> Dictionary:
	_load()
	var e = _table.get(key, {})
	return e if typeof(e) == TYPE_DICTIONARY else {}


static func locale() -> String:
	return str(NarrativeTextManager.current_locale)


static func _load() -> void:
	if not _table.is_empty():
		return
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		push_error("GameText: cannot open %s" % PATH)
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("GameText: %s is not a JSON object" % PATH)
		return
	_table = parsed
