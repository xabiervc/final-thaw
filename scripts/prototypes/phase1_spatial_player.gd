extends "res://scripts/characters/elena_controller.gd"
## Spatial-test adapter: orbit camera plus Elena's embedded animations. Never writes campaign state.
## When the model carries its AnimationPlayer (idle/walk/jump/fall/land), the procedural pose layer is disabled
## so both do not fight over the same bones.
const LANDING_TIME := 0.2
const MOVE_SPEED := 4.2
## Default camera elevation: steeper than before (about 31 degrees) so low volumes hide less of the floor behind them.
var orbit_yaw: float = -0.21
var orbit_pitch: float = -0.55
@export var mouse_sensitivity: float = 0.002
var pivot: Node3D
var arm: SpringArm3D
var view: Camera3D
var anim: AnimationPlayer = null
var _landing_left: float = 0.0
var _was_on_floor: bool = true

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
	_setup_animation()

func _setup_animation() -> void:
	if visual == null:
		return
	var found := visual.find_children("*", "AnimationPlayer", true, false)
	if found.is_empty():
		return
	var candidate := found[0] as AnimationPlayer
	if candidate == null or not candidate.has_animation("idle"):
		return
	anim = candidate
	if pose != null:
		pose.process_mode = Node.PROCESS_MODE_DISABLED
	anim.play("idle")

func _process(_delta: float) -> void:
	# The shared controller's breathing scale is skipped on purpose: it would squash the animated model.
	pivot.rotation = Vector3(orbit_pitch, orbit_yaw, 0.0)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		orbit_yaw -= event.relative.x * mouse_sensitivity
		orbit_pitch = clampf(orbit_pitch - event.relative.y * mouse_sensitivity, -1.2, 0.1)

func _physics_process(delta: float) -> void:
	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var wish := Basis(Vector3.UP, orbit_yaw) * Vector3(input_vec.x, 0.0, input_vec.y)
	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	horizontal = horizontal.move_toward(wish * MOVE_SPEED, 18.0 * delta)
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	velocity.y = -0.5 if is_on_floor() else velocity.y - 22.0 * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = 5.0
	if wish.length_squared() > 0.01:
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(wish.x, wish.z), minf(1.0, delta * 12.0))
	move_and_slide()
	_update_animation(delta)

func _update_animation(delta: float) -> void:
	if anim == null:
		return
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_landing_left = LANDING_TIME
	_was_on_floor = on_floor
	var speed := Vector2(velocity.x, velocity.z).length()
	var wanted := "idle"
	if not on_floor:
		wanted = "jump" if velocity.y > 0.5 else "fall"
	elif _landing_left > 0.0:
		_landing_left -= delta
		wanted = "land"
	elif speed > 0.3:
		wanted = "walk"
	# Playback speed follows ground speed so feet do not skate; tune once the stride length is measured.
	anim.speed_scale = clampf(speed / 2.5, 0.7, 1.5) if wanted == "walk" else 1.0
	if anim.current_animation != wanted:
		anim.play(wanted, 0.12)
