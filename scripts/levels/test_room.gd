extends Node2D

const PlayerScript = preload("res://scripts/entities/player.gd")
const InteractableScript = preload("res://scripts/entities/interactable.gd")
const HudScript = preload("res://scripts/ui/hud.gd")

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

	player = PlayerScript.new()
	player.position = Vector2(1000, 1000)
	add_child(player)
	var cam := Camera2D.new()
	player.add_child(cam)
	cam.make_current()

	hud = HudScript.new()
	add_child(hud)
	hud.set_character("Elena")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.change_scene("res://scenes/ui/main_menu.tscn")
	elif event.is_action_pressed("quick_save"):
		print("Quick save: ", GameManager.save_game(0))
	elif event.is_action_pressed("quick_load"):
		print("Quick load: ", GameManager.load_game(0))
