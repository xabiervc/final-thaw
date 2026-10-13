extends Node2D

const PlayerScript = preload("res://scripts/entities/player.gd")
const InteractableScript = preload("res://scripts/entities/interactable.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const EnvironmentModifierScript = preload("res://scripts/components/environment_modifier.gd")
const StaminaStationScript = preload("res://scripts/components/stamina_station.gd")
const LowObstacleScript = preload("res://scripts/components/low_obstacle.gd")

var player: CharacterBody2D
var hud: CanvasLayer
var interactables: Array = []

func _ready() -> void:
	var floor_rect := ColorRect.new()
	floor_rect.color = Color("2d2d44")
	floor_rect.size = Vector2(2000, 2000)
	add_child(floor_rect)

	for i in 3:
		var it: Area2D = InteractableScript.new()
		it.set("interact_text", "Objeto %d" % (i + 1))
		it.position = Vector2(1200 + i * 200, 1000)
		add_child(it)
		interactables.append(it)

	_add_condition_test_area()
	_add_recovery_station()
	_add_low_obstacles()
	_add_prototype_charger()

	player = PlayerScript.new()
	player.position = Vector2(1000, 1000)
	add_child(player)
	var cam := Camera2D.new()
	player.add_child(cam)
	cam.make_current()

	hud = HudScript.new()
	add_child(hud)
	hud.set_character("Elena")

func _add_condition_test_area() -> void:
	var zone: Area2D = EnvironmentModifierScript.new()
	zone.position = Vector2(600, 600)
	add_child(zone)

func _add_recovery_station() -> void:
	var station: Area2D = StaminaStationScript.new()
	station.position = Vector2(1500, 500)
	add_child(station)

func _add_low_obstacles() -> void:
	for offset in [0.0, 260.0]:
		var obstacle: StaticBody2D = LowObstacleScript.new()
		obstacle.position = Vector2(800.0 + offset, 1400.0)
		add_child(obstacle)

func _add_prototype_charger() -> void:
	var charger: Area2D = InteractableScript.new()
	charger.set("interact_text", "Recargar Aster")
	charger.position = Vector2(1700, 1500)
	charger.interact = func():
		GameManager.prototype_integrity = 3
		GameManager.stats_changed.emit()
	add_child(charger)
	interactables.append(charger)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.change_scene("res://scenes/ui/main_menu.tscn")
	elif event.is_action_pressed("quick_save"):
		print("Quick save: ", GameManager.save_game(0))
	elif event.is_action_pressed("quick_load"):
		print("Quick load: ", GameManager.load_game(0))
