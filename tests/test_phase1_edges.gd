extends Node
## "Zero accidental falls": Elena is placed on a walkable floor and walks (real input, running) straight at every
## guarded edge, shaft and closed door of the building. Each probe must end BLOCKED, never FELL or past the edge.
## Run: godot --headless --fixed-fps 60 --path . res://tests/test_phase1_edges.tscn

const SCENE := "res://scenes/prototypes/phase1_canonical_greybox.tscn"
const RouteBot := preload("res://tests/support/route_bot.gd")

var passed := 0
var failed := 0
var scene: Node3D
var bot

## [label, start, target beyond the edge, floor y of the start]
const PROBES := [
	["pit rail west (P0 -> D1)", Vector3(8.5, 0, 4.5), Vector3(13.0, 0, 4.5), 0.0],
	["pit rail north (nave -> pit)", Vector3(15.0, 0, -0.5), Vector3(15.0, 0, 4.0), 0.0],
	["pit rail south (south band -> pit)", Vector3(15.0, 0, 9.8), Vector3(15.0, 0, 5.0), 0.0],
	["pit rail east (east return -> pit)", Vector3(29.0, 0, 2.0), Vector3(25.0, 0, 2.0), 0.0],
	["bridge rail (deck -> pit)", Vector3(29.0, 0.35, 6.0), Vector3(25.0, 0.35, 6.0), 0.35],
	["S1 well, west side", Vector3(22.8, 0, 9.5), Vector3(25.5, 0, 9.5), 0.0],
	["S1 well, east side", Vector3(27.3, 0, 9.5), Vector3(24.5, 0, 9.5), 0.0],
	["lift shaft at P0 (deck away at M)", Vector3(26.0, 0, -0.4), Vector3(26.0, 0, -3.5), 0.0],
	["lift shaft side at P0", Vector3(23.2, 0, -3.0), Vector3(26.5, 0, -3.0), 0.0],
	["M west edge", Vector3(9.0, 3, -7.0), Vector3(5.0, 3, -7.0), 3.0],
	["M atrium edge", Vector3(18.5, 3, -5.2), Vector3(18.5, 3, -2.0), 3.0],
	["M S2 landing south", Vector3(8.2, 3, -2.3), Vector3(8.2, 3, 0.5), 3.0],
	["M east of shaft", Vector3(28.6, 3, -5.2), Vector3(28.6, 3, -2.0), 3.0],
	["S2 open side (stair -> atrium)", Vector3(11.0, 4.35, -2.6), Vector3(11.0, 4.35, 0.5), 4.3],
	["P2 control edge over S2", Vector3(11.0, 6, -5.6), Vector3(11.0, 6, -3.0), 6.0],
	["P2 control east edge", Vector3(22.5, 6, -6.4), Vector3(26.5, 6, -6.4), 6.0],
	["P2 walkway south edge", Vector3(19.0, 6, -3.0), Vector3(19.0, 6, 0.5), 6.0],
	["P2 walkway over the shaft", Vector3(23.6, 6, -3.0), Vector3(27.0, 6, -3.0), 6.0],
	["gantry north rail", Vector3(-5.0, 6, -7.5), Vector3(-5.0, 6, -10.5), 6.0],
	["gantry south rail", Vector3(-5.0, 6, -7.5), Vector3(-5.0, 6, -4.5), 6.0],
	["G outer leaf (closed)", Vector3(1.4, 6, -7.5), Vector3(-2.0, 6, -7.5), 6.0],
	["entry tunnel gate", Vector3(-2.0, 0, 6.0), Vector3(-5.0, 0, 6.0), 0.0],
	["broken stair rubble", Vector3(3.0, 0, 4.5), Vector3(3.0, 0, -2.0), 0.0],
]


func _ready() -> void:
	get_tree().create_timer(600.0).timeout.connect(func(): push_error("edges watchdog"); get_tree().quit(1))
	_run.call_deferred()


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _run() -> void:
	scene = (load(SCENE) as PackedScene).instantiate()
	scene.set("spawn_unit_enabled", false)
	add_child(scene)
	await get_tree().physics_frame
	bot = RouteBot.new()
	add_child(bot)
	bot.player = scene.player
	bot.before_step = func(): scene.player.set("orbit_yaw", 0.0)
	# The deck waits at M so both P0 and M shaft probes meet a gate without the deck behind it.
	scene.lift.set_powered(true)
	for probe in PROBES:
		if str(probe[0]).begins_with("lift shaft at P0"):
			scene.lift.call_to("upper")
			await bot.wait(3.5)
		await _probe(probe)
	print("Phase 1 edges: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _probe(probe: Array) -> void:
	var start: Vector3 = probe[1]
	var floor_y: float = probe[3]
	scene.player.global_position = start + Vector3(0.0, 0.05, 0.0)
	scene.player.velocity = Vector3.ZERO
	await bot.wait(0.25)
	var result: Dictionary = await bot.walk(probe[0], [probe[2]], {"min_y": floor_y - 0.6, "run": true, "timeout": 6.0})
	var blocked: bool = not bool(result["ok"]) and str(result.get("kind", "")) in ["STUCK", "TIMEOUT"]
	_expect(blocked and scene.player.global_position.y > floor_y - 0.6, "%s is guarded (%s at %s)" % [probe[0], result.get("kind", "PASSED THROUGH"), scene.player.global_position])
