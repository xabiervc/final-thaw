class_name EscapeMissionState
extends RefCounted
## Event-driven mission state for the conduit escape. Actor motion and player proximity live in the scene;
## this object owns only causal progression and rejects duplicate/out-of-order events.

signal event_recorded(event_name: StringName, payload: Dictionary)

enum PlayerBeat {
	INITIAL_ENCOUNTER,
	WORKER_RECOVERY,
	CABINET_INTERACTION,
	EXTINGUISHER_INTERACTION,
	ESCAPE_RUN,
	SECURITY_DISABLED,
	ESCAPE_COMPLETE,
}

enum WorkerState {
	BLOCKING,
	KNOCKED_DOWN,
	MOVING_TO_ALARM,
	AT_ALARM_BUTTON,
	ALARM_PRESSED,
	PURSUING,
	JUMPING_SHELF,
	BLOCKED_BY_CABINET,
}

enum GuardState {
	DORMANT,
	RESPONDING,
	INTERCEPTING,
	DISORIENTED,
	NEUTRALIZED,
}

var player_beat: PlayerBeat = PlayerBeat.INITIAL_ENCOUNTER
var worker_state: Dictionary = {
	"T1": WorkerState.BLOCKING,
	"T2": WorkerState.BLOCKING,
	"T3": WorkerState.BLOCKING,
}
var guard_state: Dictionary = {"G1": GuardState.DORMANT, "G2": GuardState.DORMANT}
var alarm_active := false
var alarm_press_count := 0
var shelf_fallen := false
var shelf_choreography_complete := false
var cabinet_fallen := false
var extinguisher_picked_up := false
var extinguisher_discharged := false
var guard_strikes: Dictionary = {"G1": false, "G2": false}
var t1_route_retries := 0
var guard_route_retries: Dictionary = {"G1": 0, "G2": 0}
var event_log: Array[StringName] = []


func perform_shelving_interaction() -> bool:
	if player_beat != PlayerBeat.INITIAL_ENCOUNTER or shelf_fallen:
		return false
	shelf_fallen = true
	player_beat = PlayerBeat.WORKER_RECOVERY
	worker_state["T1"] = WorkerState.KNOCKED_DOWN
	worker_state["T2"] = WorkerState.JUMPING_SHELF
	worker_state["T3"] = WorkerState.JUMPING_SHELF
	_record(&"shelf_fell")
	return true


func finish_shelving_choreography() -> bool:
	if not shelf_fallen or shelf_choreography_complete:
		return false
	shelf_choreography_complete = true
	worker_state["T2"] = WorkerState.PURSUING
	worker_state["T3"] = WorkerState.PURSUING
	_record(&"workers_resume_pursuit")
	return true


func recover_t1_and_start_alarm_route() -> bool:
	if worker_state["T1"] != WorkerState.KNOCKED_DOWN:
		return false
	worker_state["T1"] = WorkerState.MOVING_TO_ALARM
	_record(&"t1_recovered_and_routed_to_alarm")
	return true


func retry_t1_alarm_route() -> bool:
	if worker_state["T1"] != WorkerState.MOVING_TO_ALARM:
		return false
	t1_route_retries += 1
	_record(&"t1_alarm_route_retry", {"attempt": t1_route_retries})
	return true


func t1_reach_alarm_button() -> bool:
	if worker_state["T1"] != WorkerState.MOVING_TO_ALARM:
		return false
	worker_state["T1"] = WorkerState.AT_ALARM_BUTTON
	_record(&"t1_reached_physical_alarm_button")
	return true


func t1_press_alarm_button() -> bool:
	if alarm_active or worker_state["T1"] != WorkerState.AT_ALARM_BUTTON:
		return false
	alarm_active = true
	alarm_press_count += 1
	worker_state["T1"] = WorkerState.ALARM_PRESSED
	guard_state["G1"] = GuardState.RESPONDING
	guard_state["G2"] = GuardState.RESPONDING
	_record(&"alarm_activated_by_t1")
	return true


func topple_cabinet() -> bool:
	if not shelf_fallen or cabinet_fallen or player_beat == PlayerBeat.ESCAPE_COMPLETE:
		return false
	cabinet_fallen = true
	worker_state["T2"] = WorkerState.BLOCKED_BY_CABINET
	worker_state["T3"] = WorkerState.BLOCKED_BY_CABINET
	player_beat = PlayerBeat.CABINET_INTERACTION
	_record(&"cabinet_blocks_t2_t3")
	return true


func retry_guard_route(guard_id: String) -> bool:
	if not guard_state.has(guard_id) or guard_state[guard_id] not in [GuardState.RESPONDING, GuardState.INTERCEPTING]:
		return false
	guard_route_retries[guard_id] += 1
	_record(&"guard_route_retry", {"guard": guard_id, "attempt": guard_route_retries[guard_id]})
	return true


func guards_reach_intercept() -> bool:
	if not alarm_active or guard_state["G1"] != GuardState.RESPONDING or guard_state["G2"] != GuardState.RESPONDING:
		return false
	guard_state["G1"] = GuardState.INTERCEPTING
	guard_state["G2"] = GuardState.INTERCEPTING
	player_beat = PlayerBeat.EXTINGUISHER_INTERACTION
	_record(&"guards_reached_intercept")
	return true


func pick_up_extinguisher() -> bool:
	if not alarm_active or extinguisher_picked_up or player_beat != PlayerBeat.EXTINGUISHER_INTERACTION:
		return false
	extinguisher_picked_up = true
	_record(&"extinguisher_picked_up")
	return true


func discharge_extinguisher() -> bool:
	if not extinguisher_picked_up or extinguisher_discharged:
		return false
	extinguisher_discharged = true
	guard_state["G1"] = GuardState.DISORIENTED
	guard_state["G2"] = GuardState.DISORIENTED
	_record(&"extinguisher_cloud_impairs_guards")
	return true


func strike_guard(guard_id: String) -> bool:
	if not guard_state.has(guard_id) or not extinguisher_discharged:
		return false
	if guard_state[guard_id] != GuardState.DISORIENTED or bool(guard_strikes[guard_id]):
		return false
	guard_strikes[guard_id] = true
	guard_state[guard_id] = GuardState.NEUTRALIZED
	_record(&"guard_neutralized", {"guard": guard_id})
	if all_guards_neutralized():
		player_beat = PlayerBeat.SECURITY_DISABLED
		_record(&"security_disabled")
	return true


func all_guards_neutralized() -> bool:
	return guard_state["G1"] == GuardState.NEUTRALIZED and guard_state["G2"] == GuardState.NEUTRALIZED


func begin_escape_run() -> bool:
	if not cabinet_fallen or not all_guards_neutralized() or player_beat == PlayerBeat.ESCAPE_COMPLETE:
		return false
	player_beat = PlayerBeat.ESCAPE_RUN
	_record(&"escape_run_resumed")
	return true


func complete_escape_at_forest(player_is_inside_hideout: bool) -> bool:
	if not player_is_inside_hideout or player_beat != PlayerBeat.ESCAPE_RUN or not cabinet_fallen or not all_guards_neutralized():
		return false
	player_beat = PlayerBeat.ESCAPE_COMPLETE
	_record(&"forest_hideout_reached")
	return true


func _record(event_name: StringName, payload: Dictionary = {}) -> void:
	event_log.append(event_name)
	event_recorded.emit(event_name, payload)
