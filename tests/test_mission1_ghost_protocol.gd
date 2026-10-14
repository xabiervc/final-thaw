extends Node
## Comprobaciones del prototipo de la Fase 1: El protocolo fantasma.
## Ejecutar: godot --headless --path . res://tests/test_mission1_ghost_protocol.tscn

const Mission = preload("res://scripts/prototypes/mission1_ghost_protocol.gd")
const MissionScene = preload("res://scenes/prototypes/mission1_ghost_protocol.tscn")

var failed := 0
var passed := 0


func _ready() -> void:
	var mission = MissionScene.instantiate()
	add_child(mission)
	await get_tree().physics_frame
	_expect(mission.elena != null, "el prototipo crea a Elena")
	_expect(mission.b_diverted, "el circuito B empieza desviado")
	_expect(not mission.power_on, "la energia empieza apagada")
	_expect(not mission.door_open(), "la puerta empieza bloqueada")
	var hidden := true
	for marker in mission.scan_markers:
		if marker.visible:
			hidden = false
	_expect(hidden, "los marcadores del escaner empiezan ocultos")
	mission._use_lever()
	_expect(mission.power_on and not mission.door_open(), "restaurar energia con B desviado no abre la puerta")
	mission._use_junction()
	_expect(not mission.b_diverted, "reconectar B cambia el estado del circuito")
	_expect(mission.door_open(), "con B reconectado y energia activada, la puerta se abre")
	mission._use_terminal()
	_expect(mission.evidence_found, "el terminal revela la evidencia tras restaurar el circuito")
	mission.trigger_scan_reveal()
	var shown := true
	for marker in mission.scan_markers:
		if not marker.visible:
			shown = false
	_expect(shown, "el escaner revela panel, cable y terminal")
	mission.queue_free()
	print("Mission 1 prototype: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
