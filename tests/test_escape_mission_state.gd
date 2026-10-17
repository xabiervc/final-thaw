extends Node

const MissionState := preload("res://scripts/phase1/escape_mission_state.gd")
const ROUTE_PATH := "res://docs/design/assets/escape_conduit/geometria_ruta.json"

var passed := 0
var failed := 0


func _ready() -> void:
	_run()


func _expect(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)


func _run() -> void:
	_check_authoritative_route()
	_check_causal_mission_events()
	print("Escape mission state: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _check_authoritative_route() -> void:
	var raw := FileAccess.get_file_as_string(ROUTE_PATH)
	var route_data = JSON.parse_string(raw)
	_expect(route_data is Dictionary, "approved route geometry JSON parses")
	if not route_data is Dictionary:
		return
	var route: Array = route_data["route_S_to_A2"]
	var start: Array = route[0]
	var n1: Array = route[1]
	var first_after_n1: Array = route[2]
	_expect(is_equal_approx(float(start[0]), 80.0) and is_equal_approx(float(start[1]), 100.0)
		and is_equal_approx(float(n1[0]), 80.0) and is_equal_approx(float(n1[1]), 87.0), "route starts at S and reaches N1 at its recorded coordinates")
	_expect(float(first_after_n1[0]) < float(n1[0]) and is_equal_approx(float(first_after_n1[1]), float(n1[1])), "the only route from N1 turns west, not north")
	var n1_to_a2 := 0.0
	for i in range(1, route.size() - 1):
		var a: Array = route[i]
		var b: Array = route[i + 1]
		n1_to_a2 += Vector2(float(b[0]) - float(a[0]), float(b[1]) - float(a[1])).length()
	_expect(is_equal_approx(n1_to_a2, float(route_data["main_N1_to_A2_m"])), "N1-to-A2 route segments match the documented 199 m traverse")
	var a2_route: Array = route_data["route_A2_plan"]
	var horizontal := 0.0
	for i in range(a2_route.size() - 1):
		var a: Array = a2_route[i]
		var b: Array = a2_route[i + 1]
		horizontal += Vector2(float(b[0]) - float(a[0]), float(b[1]) - float(a[1])).length()
	var surface := sqrt(horizontal * horizontal + pow(float(route_data["A2_rise_m"]), 2.0))
	_expect(is_equal_approx(horizontal, float(route_data["A2_horizontal_m"])), "A2 horizontal projection matches the route polyline")
	_expect(is_equal_approx(surface, float(route_data["A2_surface_m"])), "A2 surface length is consistent with its 10 m rise")
	_expect(is_equal_approx(float(route_data["A2_slope_degrees"]), 10.0), "A2 keeps the approved +10 degree slope")


func _check_causal_mission_events() -> void:
	var state = MissionState.new()
	_expect(state.perform_shelving_interaction(), "shelving interaction begins from N1 encounter")
	_expect(state.shelf_fallen and not state.alarm_active, "shelving fall does not activate the alarm")
	_expect(state.worker_state["T1"] == MissionState.WorkerState.KNOCKED_DOWN, "T1 is downed by the shelf event")
	_expect(state.worker_state["T2"] == MissionState.WorkerState.JUMPING_SHELF and state.worker_state["T3"] == MissionState.WorkerState.JUMPING_SHELF, "T2 and T3 jump the shelf independently")
	_expect(not state.perform_shelving_interaction(), "shelving activation is idempotent")
	_expect(state.finish_shelving_choreography(), "shelf choreography releases T2 and T3 to pursue")
	_expect(state.recover_t1_and_start_alarm_route(), "T1 recovers and starts a physical route to the alarm button")
	_expect(not state.alarm_active, "alarm remains off while T1 travels")
	_expect(state.retry_t1_alarm_route(), "blocked T1 route requests a retry instead of silently firing the alarm")
	_expect(not state.guards_reach_intercept() and state.guard_state["G1"] == MissionState.GuardState.DORMANT, "guards cannot intercept before the alarm is activated")
	_expect(state.t1_reach_alarm_button(), "T1 reaches the physical alarm button")
	_expect(state.t1_press_alarm_button(), "T1's button press activates the alarm")
	_expect(state.alarm_active and state.alarm_press_count == 1, "alarm activation is recorded exactly once")
	_expect(not state.t1_press_alarm_button() and state.alarm_press_count == 1, "repeated button events cannot retrigger the alarm")
	_expect(state.guard_state["G1"] == MissionState.GuardState.RESPONDING and state.guard_state["G2"] == MissionState.GuardState.RESPONDING, "alarm dispatches both guards into a response state")
	_expect(state.topple_cabinet(), "cabinet interaction is available after the shelf event")
	_expect(state.worker_state["T2"] == MissionState.WorkerState.BLOCKED_BY_CABINET and state.worker_state["T3"] == MissionState.WorkerState.BLOCKED_BY_CABINET, "cabinet physically blocks both remaining workers")
	_expect(not state.topple_cabinet(), "cabinet interaction is idempotent")
	_expect(state.retry_guard_route("G1"), "blocked security navigation can request a route retry")
	_expect(state.guards_reach_intercept(), "responding guards reach the interception point")
	_expect(state.pick_up_extinguisher(), "extinguisher can be picked up at the guard encounter")
	_expect(state.discharge_extinguisher(), "extinguisher cloud begins after pickup")
	_expect(state.guard_state["G1"] == MissionState.GuardState.DISORIENTED and state.guard_state["G2"] == MissionState.GuardState.DISORIENTED, "cloud impairs both guards before strikes")
	_expect(state.strike_guard("G1") and not state.all_guards_neutralized(), "first guard reacts to a strike without ending the encounter early")
	_expect(state.strike_guard("G2") and state.all_guards_neutralized(), "second guard reaches a non-pursuing state")
	_expect(not state.strike_guard("G1"), "guard strike cannot be applied twice")
	_expect(state.begin_escape_run(), "player resumes the route after both pursuit groups are blocked")
	_expect(not state.complete_escape_at_forest(false), "mission cannot complete before the player enters the forest destination")
	_expect(state.complete_escape_at_forest(true), "mission completes when the player enters the forest destination")
	_expect(not state.complete_escape_at_forest(true), "forest completion is idempotent")
	_expect(state.event_log.find(&"shelf_fell") < state.event_log.find(&"alarm_activated_by_t1"), "event trace preserves shelf-before-alarm causality")
