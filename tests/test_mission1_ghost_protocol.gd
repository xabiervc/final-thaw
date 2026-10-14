extends Node
## Comprobaciones de la mision 1: pistas, escaner, deduccion y consecuencias.
## Ejecutar: godot --headless --path . res://tests/test_mission1_ghost_protocol.tscn

const Mission = preload("res://scripts/prototypes/mission1_ghost_protocol.gd")
const MissionScene = preload("res://scenes/prototypes/mission1_ghost_protocol.tscn")

var failed := 0
var passed := 0


func _ready() -> void:
	var mission = MissionScene.instantiate()
	add_child(mission)
	await get_tree().physics_frame
	_expect(mission.player != null and mission.player_camera != null, "la mision crea a Elena y la camara")
	_expect(mission.cut_cable != null and mission.terminal != null and mission.junction != null and mission.lever != null and mission.exit_door != null, "la mision crea cable, terminal, union, palanca y puerta")
	_expect(mission.scan_highlights.size() == 4, "el escaner tiene cuatro objetivos revelables")
	_expect(not mission.b_connected and not mission.power_on, "el circuito empieza alterado y sin energia")
	var hidden := true
	for highlight in mission.scan_highlights:
		if highlight.visible:
			hidden = false
	_expect(hidden, "los objetivos del escaner empiezan ocultos")
	mission.trigger_scan()
	var shown := true
	for highlight in mission.scan_highlights:
		if not highlight.visible:
			shown = false
	_expect(shown, "el escaner revela panel, cable, terminal y palanca")
	mission.b_connected = false
	mission.power_on = false
	mission._interact(mission.junction)
	_expect(mission.b_connected, "reconectar la derivacion cambia el estado del circuito")
	mission._interact(mission.lever)
	_expect(mission.power_on, "la palanca restaura la energia")
	mission._interact(mission.exit_door)
	_expect(mission.finished, "con B reconectado y energia, la puerta completa la mision")
	mission.queue_free()
	print("Mission 1: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
