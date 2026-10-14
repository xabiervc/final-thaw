extends Node
## Transport test of the service lift with real physics: a character boards without jumping, rides up and down without
## slipping or leaving the deck, cannot step into the shaft from the closed end, and gets off without jumping.
## This is the independent validation gate for the lift; it does not use the provisional ramp.
## Run: godot --headless --path . res://tests/test_service_lift_transport.tscn

const Rig = preload("res://scripts/prototypes/lift_test_rig.gd")
const WALK := 2.0
var passed: int = 0
var failed: int = 0
var completed: bool = false
var world: Node3D
var lift = null
var body: CharacterBody3D
var walk: Vector2 = Vector2.ZERO


func _ready() -> void:
	Engine.time_scale = 4.0
	get_tree().create_timer(60.0, true, false, true).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		Engine.time_scale = 1.0
		push_error("Transport test did not reach completion (possible script error or a stuck lift).")
		get_tree().quit(1)


func _physics_process(delta: float) -> void:
	if body == null:
		return
	body.velocity.x = walk.x
	body.velocity.z = walk.y
	body.velocity.y = -0.5 if body.is_on_floor() else body.velocity.y - 22.0 * delta
	body.move_and_slide()


func _frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame


func _wait_for_dock(limit_frames: int) -> int:
	var frames: int = 0
	while (lift.moving or lift.dwell_left > 0.0 or lift.pending != "") and frames < limit_frames:
		await get_tree().physics_frame
		frames += 1
	return frames


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	world = Node3D.new()
	add_child(world)
	lift = Rig.build(world)
	body = CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	body.floor_snap_length = 0.35
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0.0, 0.85, 0.0)
	body.add_child(shape)
	body.position = Vector3(0.0, 0.1, 5.0)
	world.add_child(body)
	await _frames(20)
	_expect(body.is_on_floor() and absf(body.position.y) < 0.1, "stands on the lower landing")
	# Boarding: walk north onto the deck, which is flush with the landing.
	walk = Vector2(0.0, -WALK)
	await _frames(130)
	walk = Vector2.ZERO
	await _frames(10)
	_expect(body.position.z < 1.2 and absf(body.position.y - lift.platform_y) < 0.1, "boards the deck by walking, without a jump (z %.2f, y %.2f)" % [body.position.z, body.position.y])
	# Ride up.
	var start := Vector2(body.position.x, body.position.z)
	var max_gap: float = 0.0
	var max_drift: float = 0.0
	_expect(lift.send(), "the deck button sends the lift up")
	var frames: int = 0
	while lift.moving and frames < 600:
		await get_tree().physics_frame
		frames += 1
		max_gap = maxf(max_gap, absf(body.position.y - lift.platform_y))
		max_drift = maxf(max_drift, Vector2(body.position.x, body.position.z).distance_to(start))
	_expect(not lift.moving, "the trip ends")
	_expect(max_gap < 0.2, "the rider stays on the deck while it rises (max gap %.3f m)" % max_gap)
	_expect(max_drift < 0.1, "the rider does not slide while it rises (max drift %.3f m)" % max_drift)
	_expect(absf(body.position.y - 3.0) < 0.1, "arrives at the upper landing height (y %.2f)" % body.position.y)
	# The closed end: walking towards the shaft must not drop the rider.
	walk = Vector2(0.0, WALK)
	await _frames(60)
	walk = Vector2.ZERO
	await _frames(5)
	_expect(body.position.z < 1.5 and body.position.y > 2.8, "the closed south end stops the rider at the shaft (z %.2f, y %.2f)" % [body.position.z, body.position.y])
	# Disembark by walking north.
	walk = Vector2(0.0, -WALK)
	await _frames(130)
	walk = Vector2.ZERO
	await _frames(10)
	_expect(body.position.z < -2.0 and absf(body.position.y - 3.0) < 0.1, "gets off onto the upper landing without a jump (z %.2f, y %.2f)" % [body.position.z, body.position.y])
	# Call from the upper landing and come back down.
	await _wait_for_dock(600)
	walk = Vector2(0.0, WALK)
	await _frames(110)
	walk = Vector2.ZERO
	await _frames(10)
	_expect(body.position.z > -1.2 and body.position.z < 1.2 and absf(body.position.y - 3.0) < 0.1, "boards again at the upper landing (z %.2f, y %.2f)" % [body.position.z, body.position.y])
	_expect(lift.send(), "the deck button sends the lift down")
	frames = 0
	var upper_start := Vector2(body.position.x, body.position.z)
	max_drift = 0.0
	while (lift.moving or lift.pending != "") and frames < 900:
		await get_tree().physics_frame
		frames += 1
		if lift.moving:
			max_drift = maxf(max_drift, Vector2(body.position.x, body.position.z).distance_to(upper_start))
	_expect(not lift.moving and lift.landing == "lower", "the lift returns to the lower landing")
	_expect(max_drift < 0.1 and absf(body.position.y) < 0.1, "the rider rides down without slipping and arrives at floor height (drift %.3f, y %.2f)" % [max_drift, body.position.y])
	_expect(body.position.y > -0.3, "nobody fell during the whole sequence")
	Engine.time_scale = 1.0
	completed = true
	print("Service lift transport: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
