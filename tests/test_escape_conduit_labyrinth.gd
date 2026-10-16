extends Node

const SCENE := "res://scenes/prototypes/escape_conduit_labyrinth.tscn"

var passed := 0
var failed := 0
var scene: Node3D

func _ready() -> void:
	_run.call_deferred()

func _expect(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)

func _run() -> void:
	var packed := load(SCENE) as PackedScene
	_expect(packed != null, "standalone escape scene loads")
	if packed == null:
		get_tree().quit(1)
		return
	scene = packed.instantiate() as Node3D
	add_child(scene)
	await get_tree().process_frame
	await get_tree().physics_frame
	_expect(scene.get_node_or_null("Elena_EscapePrototype") != null, "Elena player exists")
	_expect(scene.get_node_or_null("ESC_D01_EndCap") != null and scene.get_node_or_null("ESC_D02_EndCap") != null and scene.get_node_or_null("ESC_D03_EndCap") != null, "all optional dead ends have physical end caps")
	_expect(scene.get_node_or_null("ESC_FOREST_HIDEOUT_TRIGGER") != null, "forest completion trigger exists")
	_expect(scene.get_node_or_null("ESC_HATCH_FRAME_Post_L") != null and scene.get_node_or_null("ESC_HATCH_FRAME_Post_R") != null and scene.get_node_or_null("ESC_SECONDARY_ROAD") != null and scene.get_node_or_null("ESC_FOREST_GROUND") != null, "hatch, road and continuous forest ground exist")
	await get_tree().create_timer(0.2).timeout
	var player = scene.get("player")
	_expect(player != null and absf(float(player.get("stamina")) - 100.0) < 0.01, "adrenaline prototype restores stamina to 100")
	if player != null and player.get("arm") != null:
		_expect(float(player.arm.spring_length) < 0.1, "first-person camera remains close to eye point")
	scene.call("_on_forest_entered", player)
	_expect(bool(scene.get("complete")), "reaching the forest ends the escape")
	_expect(not bool(player.get("input_enabled")), "player input stops after the forest ending")
	print("Escape conduit greybox: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)
