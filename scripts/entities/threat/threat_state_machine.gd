class_name ThreatStateMachine
extends Node

## Reusable finite-state machine for the Phase 2 threat agent.
## It consumes perception signals and exposes movement intents.
## It never receives the target's live position after losing sight.

signal state_changed(previous_state: ThreatStateMachine.State, new_state: ThreatStateMachine.State)
signal movement_intent_changed(destination: Vector3, move_speed: float)
signal target_caught

enum State {
	PATROL,
	INVESTIGATE,
	ALERT,
	CHASE,
	SEARCH,
	RETURN,
}

@export var patrol_points: Array[Vector3] = []
@export var patrol_speed: float = 2.0
@export var investigate_speed: float = 2.0
@export var chase_speed: float = 4.0
@export var search_duration: float = 4.0
@export var search_sweep_degrees: float = 70.0
@export var capture_distance: float = 0.9

var current_state: State = State.PATROL
var current_destination: Vector3
var current_move_speed: float = patrol_speed
var patrol_index: int = 0
var search_timer: float = 0.0
var search_direction: float = 1.0

var perception: ThreatPerceptionComponent

func _ready() -> void:
	perception = get_node_or_null("../ThreatPerception") as ThreatPerceptionComponent

	if perception == null:
		push_warning("ThreatStateMachine requires a sibling ThreatPerceptionComponent named ThreatPerception.")
		return

	perception.target_spotted.connect(_on_target_spotted)
	perception.target_lost.connect(_on_target_lost)
	perception.noise_heard.connect(_on_noise_heard)
	perception.detection_confirmed.connect(_on_detection_confirmed)

	_enter_state(State.PATROL)

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			_process_patrol()
		State.INVESTIGATE:
			_process_move_to_destination()
		State.ALERT:
			_process_alert(delta)
		State.CHASE:
			_process_chase()
		State.SEARCH:
			_process_search(delta)
		State.RETURN:
			_process_move_to_destination()

func get_state_name() -> String:
	return State.keys()[current_state]

func reset() -> void:
	patrol_index = 0
	search_timer = 0.0
	search_direction = 1.0
	_enter_state(State.PATROL)

func _enter_state(new_state: State) -> void:
	if new_state == current_state:
		return

	var previous_state := current_state
	current_state = new_state
	state_changed.emit(previous_state, new_state)

	match new_state:
		State.PATROL:
			_go_to_next_patrol_point()
		State.SEARCH:
			search_timer = search_duration
		State.RETURN:
			if patrol_points.size() > 0:
				_set_destination(patrol_points[patrol_index], patrol_speed)

func _go_to_next_patrol_point() -> void:
	if patrol_points.is_empty():
		return

	var destination := patrol_points[patrol_index]
	patrol_index = (patrol_index + 1) % patrol_points.size()
	_set_destination(destination, patrol_speed)

func _set_destination(destination: Vector3, speed: float) -> void:
	current_destination = destination
	current_move_speed = speed
	movement_intent_changed.emit(destination, speed)

func _process_patrol() -> void:
	if patrol_points.is_empty():
		return

	if global_position.distance_to(current_destination) <= capture_distance:
		_go_to_next_patrol_point()

func _process_move_to_destination() -> void:
	if global_position.distance_to(current_destination) <= capture_distance:
		if current_state == State.INVESTIGATE:
			_enter_state(State.SEARCH)
		elif current_state == State.RETURN:
			_enter_state(State.PATROL)

func _process_alert(delta: float) -> void:
	if not perception.is_alerted():
		_enter_state(State.CHASE)

func _process_chase() -> void:
	if perception.can_see_target():
		_set_destination(perception.get_last_known_position(), chase_speed)
		return

	if perception.has_known_position():
		_set_destination(perception.get_last_known_position(), chase_speed)

	if global_position.distance_to(current_destination) <= capture_distance:
		_enter_state(State.SEARCH)

func _process_search(delta: float) -> void:
	search_timer -= delta

	if perception.can_see_target():
		_enter_state(State.CHASE)
		return

	if search_timer <= 0.0:
		_enter_state(State.RETURN)

func _on_target_spotted() -> void:
	if current_state in [State.PATROL, State.INVESTIGATE, State.RETURN]:
		_enter_state(State.ALERT)

func _on_target_lost() -> void:
	pass

func _on_noise_heard(position: Vector3, _loudness: float) -> void:
	if current_state in [State.PATROL, State.RETURN]:
		_enter_state(State.INVESTIGATE)
		_set_destination(position, investigate_speed)

func _on_detection_confirmed() -> void:
	_enter_state(State.ALERT)
