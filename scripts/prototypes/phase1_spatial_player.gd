extends "res://scripts/characters/elena_controller.gd"
## Spatial-test adapter only. Uses the shared model but never writes campaign state.
var orbit_yaw: float = -0.21
var orbit_pitch: float = -0.35
@export var mouse_sensitivity: float = 0.002
var pivot: Node3D
var arm: SpringArm3D
var view: Camera3D

func _ready() -> void:
	super._ready()
	pivot = Node3D.new()
	pivot.position.y = 1.25
	add_child(pivot)
	arm = SpringArm3D.new()
	arm.spring_length = 5.0
	arm.margin = 0.2
	arm.collision_mask = 1
	arm.add_excluded_object(get_rid())
	pivot.add_child(arm)
	view = Camera3D.new()
	view.current = true
	view.fov = 65.0
	arm.add_child(view)
	floor_snap_length = 0.35

func _process(_delta: float) -> void:
	# Do not squash or breathe-scale the visual. Existing pose child remains visual-only.
	pivot.rotation = Vector3(orbit_pitch, orbit_yaw, 0.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		orbit_yaw -= event.relative.x * mouse_sensitivity
		orbit_pitch = clampf(orbit_pitch - event.relative.y * mouse_sensitivity, -1.0, 0.1)

func _physics_process(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var wish := Basis(Vector3.UP, orbit_yaw) * Vector3(input_vec.x, 0.0, input_vec.y)
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(wish * 4.2, 18.0 * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y = -0.5 if is_on_floor() else velocity.y - 22.0 * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = 5.0
	if wish.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(wish.x, wish.z), minf(1.0, delta * 12.0))
	move_and_slide()
