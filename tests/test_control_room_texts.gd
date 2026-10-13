extends Node
## Entrega B, paso 1: textos del puzle de registros y cableado.
## Ejecutar: godot --headless --path . res://tests/test_control_room_texts.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const ManagerScript = preload("res://scripts/managers/narrative_text_manager.gd")
const ES_PATH := "res://data/narrative_text.tres"
const EN_PATH := "res://data/narrative_text_en.tres"

var failed := 0
var passed := 0


func _ready() -> void:
	var es: Resource = load(ES_PATH)
	var en: Resource = load(EN_PATH)
	_expect(es != null, "B5: ES resource loads")
	_expect(en != null, "B5: EN resource loads")
	_expect(not ManagerScript.CONTROL_ROOM_KEYS.is_empty(), "B5: key list is not empty")
	_expect(_has_no_duplicates(ManagerScript.CONTROL_ROOM_KEYS), "B5: key list has no duplicates")
	if es != null and en != null:
		for key in ManagerScript.CONTROL_ROOM_KEYS:
			_check_key(es, en, key)
		_check_getters(es, en)
	print("Control room texts: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _check_key(es: Resource, en: Resource, key: String) -> void:
	var es_value: Variant = es.get(key)
	var en_value: Variant = en.get(key)
	_expect(es_value is String and not str(es_value).strip_edges().is_empty(), "B5: ES has a non-empty value for %s" % key)
	_expect(en_value is String and not str(en_value).strip_edges().is_empty(), "B5: EN has a non-empty value for %s" % key)
	_expect(str(es_value) != str(en_value), "B5: EN is translated (differs from ES) for %s" % key)


func _check_getters(es: Resource, en: Resource) -> void:
	ManagerScript.set_locale("es")
	for key in ManagerScript.CONTROL_ROOM_KEYS:
		_expect(ManagerScript.get_control_room_text(key) == str(es.get(key)), "B5: ES getter returns the ES value for %s" % key)
	ManagerScript.set_locale("en")
	for key in ManagerScript.CONTROL_ROOM_KEYS:
		_expect(ManagerScript.get_control_room_text(key) == str(en.get(key)), "B5: EN getter returns the EN value for %s" % key)
	ManagerScript.set_locale("es")
	_expect(ManagerScript.get_control_room_text("not_a_key") == "", "B5: unknown key returns an empty string")


func _has_no_duplicates(items: Array) -> bool:
	var seen := {}
	for item in items:
		if seen.has(item):
			return false
		seen[item] = true
	return true


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
