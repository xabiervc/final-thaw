extends Node
## State-machine tests of the service lift, stepped by hand (no physics): travel time, gates, calls, dwell, queued calls
## and every power-loss rule. Run: godot --headless --path . res://tests/test_service_lift.tscn

const ServiceLift = preload("res://scripts/prototypes/service_lift.gd")
const DT := 0.05
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(15.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Lift tests did not reach completion (possible script error).")
		get_tree().quit(1)


func _new_lift():
	var lift = ServiceLift.new()
	add_child(lift)
	lift.set_physics_process(false)
	return lift


## Steps until the lift docks; returns the elapsed seconds (or -1 if it never docks).
func _run_to_dock(lift, limit: float = 20.0) -> float:
	var t: float = 0.0
	while lift.moving and t < limit:
		lift.step(DT)
		t += DT
	return t if not lift.moving else -1.0


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var lift = _new_lift()
	_expect(lift.state_key() == "docked_lower" and is_equal_approx(lift.platform_y, 0.0), "starts docked at the lower landing, flush with it")
	_expect(lift.gates_open() == {"south": true, "north": false}, "at the lower landing only the south end is open")
	# Normal trip.
	_expect(lift.call_to("upper"), "a call to the other landing is accepted")
	_expect(lift.state_key() == "moving_up" and lift.gates_open() == {"south": false, "north": false}, "while moving both ends are closed")
	var time: float = _run_to_dock(lift)
	_expect(time > 2.4 and time < 2.7, "a 3 m trip at 1.2 m/s takes about 2.5 s (%.2f s)" % time)
	_expect(lift.state_key() == "docked_upper" and is_equal_approx(lift.platform_y, 3.0), "it docks flush with the upper landing")
	_expect(lift.gates_open() == {"south": false, "north": true}, "at the upper landing only the north end is open, so nobody can step into the shaft")
	# Same-level call, dwell and queued calls.
	_expect(lift.call_to("upper") and lift.state_key() == "docked_upper", "calling the landing it is at changes nothing")
	_expect(lift.call_to("lower") and lift.state_key() == "docked_upper", "a call during the dwell is queued, not obeyed at once")
	for i in 58:
		lift.step(DT)
	_expect(lift.state_key() == "docked_upper", "it waits out the dwell time so a rider can get off")
	for i in 6:
		lift.step(DT)
	_expect(lift.state_key() == "moving_down", "it then leaves for the queued call")
	_run_to_dock(lift)
	_expect(lift.state_key() == "docked_lower", "and docks at the lower landing")
	# A call during a trip is queued and honoured after docking and the dwell.
	for i in 70:
		lift.step(DT)
	_expect(lift.call_to("upper") and lift.state_key() == "moving_up", "a call after the dwell departs immediately")
	_expect(lift.call_to("lower") and lift.pending == "lower", "a reverse call during the trip is queued")
	_run_to_dock(lift)
	_expect(lift.state_key() == "docked_upper" and lift.pending == "lower", "the trip is not interrupted: it docks first")
	for i in 70:
		lift.step(DT)
	_expect(lift.state_key() == "moving_down", "then the queued call is served")
	_run_to_dock(lift)
	for i in 70:
		lift.step(DT)
	# Power lost while docked: stays, gate open, calls refused.
	lift.set_powered(false)
	_expect(not lift.call_to("upper") and lift.state_key() == "docked_lower", "without power a docked lift refuses calls and stays put")
	_expect(lift.gates_open()["south"], "and keeps its open end open, so nobody is trapped")
	lift.set_powered(true)
	_expect(lift.call_to("upper"), "power back: calls work again")
	_run_to_dock(lift)
	for i in 70:
		lift.step(DT)
	# Power lost in the first half of the trip: it returns to the origin at crawl speed.
	_expect(lift.call_to("lower"), "a descent starts")
	for i in 10:
		lift.step(DT)
	lift.set_powered(false)
	_expect(lift.crawling and lift.target == "upper", "power lost in the first half heads for the nearest landing (the origin)")
	time = _run_to_dock(lift)
	_expect(time > 0.0 and lift.state_key() == "docked_upper" and is_equal_approx(lift.platform_y, 3.0), "it docks at the origin, never between floors (%.2f s)" % time)
	_expect(lift.gates_open()["north"] and not lift.call_to("lower"), "it then locks with its end open and refuses calls")
	lift.set_powered(true)
	for i in 70:
		lift.step(DT)
	# Power lost in the second half: it finishes the trip to the destination at crawl speed.
	_expect(lift.call_to("lower"), "another descent starts")
	for i in 36:
		lift.step(DT)
	lift.set_powered(false)
	_expect(lift.crawling and lift.target == "lower", "power lost in the second half heads for the nearest landing (the destination)")
	time = _run_to_dock(lift)
	_expect(time > 0.0 and time <= 3.0 / (1.2 * 0.3) + 0.2 and lift.state_key() == "docked_lower", "it docks within the worst-case emergency time (%.2f s)" % time)
	_expect(lift.gates_open()["south"], "and opens the end facing that landing")
	# Exact midpoint is a deterministic tie: the implementation chooses the upper landing.
	var midpoint = _new_lift()
	_expect(midpoint.call_to("upper"), "midpoint test starts a normal upward trip")
	for i in 25:
		midpoint.step(DT)
	_expect(is_equal_approx(midpoint.platform_y, 1.5), "midpoint case is exactly halfway between landings")
	midpoint.set_powered(false)
	_expect(midpoint.crawling and midpoint.target == "upper", "exact midpoint resolves to the upper landing")
	_run_to_dock(midpoint)
	_expect(midpoint.state_key() == "docked_upper", "midpoint emergency stop completes at the upper landing")
	# Invalid input.
	lift.set_powered(true)
	_expect(not lift.call_to("basement"), "an unknown landing is refused")
	completed = true
	print("Service lift: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
