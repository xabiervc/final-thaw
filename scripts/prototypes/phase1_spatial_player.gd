extends "res://scripts/characters/elena_controller.gd"
## Spatial-test adapter: orbit camera plus Elena's embedded animations. Never writes campaign state.
## Movement is delegated to the shared controller so run, crouch, climb and stamina work here too.

const LANDING_TIME := 0.2
const SHOULDER_OFFSET := 0.45
## When walls push the camera this close, Elena's model is hidden so it never fills the screen (the capsule stays).
const HIDE_BODY_BELOW := 1.0
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
	arm.position = Vector3(SHOULDER_OFFSET, 0.0, 0.0)  # over the right shoulder: Elena never hides what is ahead
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
	if visual != null and arm != null:
		var close := arm.get_hit_length() < HIDE_BODY_BELOW
		if visual.visible == close:
			visual.visible = not close

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		orbit_yaw -= event.relative.x * mouse_sensitivity
		orbit_pitch = clampf(orbit_pitch - event.relative.y * mouse_sensitivity, -1.2, 0.1)

func _physics_process(delta: float) -> void:
	movement_basis = Basis(Vector3.UP, orbit_yaw)
	super._physics_process(delta)
	_update_animation(delta)

## One-shot gestures requested by the scene (scan, interact, caught); they play over idle and never block input.
var _gesture: String = ""
var _gesture_left: float = 0.0


func play_gesture(name_: String, seconds: float = 0.8) -> void:
	if anim == null or not anim.has_animation(name_):
		return
	_gesture = name_
	_gesture_left = seconds


func _update_animation(delta: float) -> void:
	if anim == null:
		return
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor:
		_landing_left = LANDING_TIME
	_was_on_floor = on_floor
	var speed := Vector2(velocity.x, velocity.z).length()
	_gesture_left = maxf(0.0, _gesture_left - delta)
	var wanted := "idle"
	var playback := 1.0
	if is_climbing:
		wanted = "climb"
	elif not on_floor:
		wanted = "jump" if velocity.y > 0.5 else "fall"
	elif _landing_left > 0.0:
		_landing_left -= delta
		wanted = "land"
	elif is_crouching:
		wanted = "crouch_walk" if speed > 0.25 else "crouch_idle"
		playback = clampf(speed / 1.5, 0.7, 1.4) if speed > 0.25 else 1.0
	elif speed > 0.3:
		wanted = "run" if is_running and anim.has_animation("run") else "walk"
		# Playback follows ground speed so the feet do not skate.
		playback = clampf(speed / (6.5 if wanted == "run" else 2.5), 0.7, 1.5)
	elif _gesture_left > 0.0:
		wanted = _gesture
	anim.speed_scale = playback
	if anim.current_animation != wanted:
		anim.play(wanted, 0.12)
	# The orbit pivot follows the body: lower while crouched so the camera reads low passages.
	pivot.position.y = lerpf(pivot.position.y, 0.85 if is_crouching else 1.25, clampf(delta * 8.0, 0.0, 1.0))
