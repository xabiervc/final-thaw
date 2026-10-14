class_name ThreatAgent
extends CharacterBody3D

## Definitive Phase 2 threat agent.
## It composes perception, state machine, navigation and capture components.
## It does not decide narrative consequences after capturing a target.

signal target_caught(target: Node3D)
signal state_changed(previous_state: ThreatStateMachine.State, new_state: ThreatStateMachine.State)

@export var target_path: NodePath
@export var patrol_points: Array[Vector3] = []
@export var gravity: float = 18.0

@onready var perception: ThreatPerceptionComponent = $ThreatPerception
@onready var state_machine: ThreatStateMachine = $ThreatStateMachine
@onready var navigation: ThreatNavigationComponent = $ThreatNavigation
@onready var capture: ThreatCaptureComponent = $ThreatCapture

func _ready() -> void:
	if not target_path.is_empty():
		set_target(get_node_or_null(target_path))

	state_machine.patrol_points = patrol_points
	state_machine.state_changed.connect(
		func(previous_state: ThreatStateMachine.State, new_state: ThreatStateMachine.State) -> void:
			state_changed.emit(previous_state, new_state)
	)

	capture.target_caught.connect(
		func(captured_target: Node3D) -> void:
			target_caught.emit(captured_target)
	)

func set_target(new_target: Node3D) -> void:
	perception.set_target(new_target)
	capture.set_target(new_target)

func set_patrol_points(points: Array[Vector3]) -> void:
	patrol_points = points
	state_machine.patrol_points = points

func report_noise(position: Vector3, loudness: float) -> void:
	perception.report_noise(position, loudness)

func reset() -> void:
	perception.reset()
	state_machine.reset()
	capture.reset()

func get_current_state() -> ThreatStateMachine.State:
	return state_machine.current_state

func get_current_state_name() -> String:
	return state_machine.get_state_name()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
