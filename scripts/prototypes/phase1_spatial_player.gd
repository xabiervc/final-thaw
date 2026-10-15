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
## Right-stick look speed at full deflection (rad/s), before the player's sensitivity option.
const STICK_YAW_SPEED := 2.6
const STICK_PITCH_SPEED := 1.7
## Camera framings. "explore": wide, high, reads the space and the routes. "pursuit": closer over the shoulder,
## a little wider field of view, for the chase (it never hides what is ahead: the shoulder offset keeps Elena to
## the side and the arm stays long enough to show the next obstacle).
const CAMERA_MODES := {
	"explore": {"length": 5.0, "fov": 65.0, "offset": 0.45, "height": 1.25},
	"pursuit": {"length": 3.4, "fov": 71.0, "offset": 0.6, "height": 1.38},
}
const CAMERA_BLEND := 2.2
var camera_mode: String = "explore"
## True while a cinematic owns the camera: look input is ignored.
var look_locked: bool = false
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

func set_camera_mode(mode: String, instant: bool = false) -> void:
	if not CAMERA_MODES.has(mode):
		return
	camera_mode = mode
	if instant:
		var m: Dictionary = CAMERA_MODES[mode]
		arm.spring_length = float(m["length"])
		view.fov = float(m["fov"])
		arm.position.x = float(m["offset"])


func _process(delta: float) -> void:
	# The shared controller's breathing scale is skipped on purpose: it would squash the animated model.
	if not look_locked and input_enabled:
		var look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
		if look != Vector2.ZERO:
			var sens := GameSettings.look_sensitivity()
			orbit_yaw -= look.x * STICK_YAW_SPEED * sens * delta
			var dy := look.y * STICK_PITCH_SPEED * sens * delta
			orbit_pitch = clampf(orbit_pitch - (dy if not GameSettings.invert_y() else -dy), -1.2, 0.1)
	# Framing blend (no field-of-view change with reduced motion).
	var m: Dictionary = CAMERA_MODES[camera_mode]
	var k := clampf(CAMERA_BLEND * delta, 0.0, 1.0)
	arm.spring_length = lerpf(arm.spring_length, float(m["length"]), k)
	arm.position.x = lerpf(arm.position.x, float(m["offset"]), k)
	var fov_target: float = 65.0 if AccessibilityManager.is_reduced_motion() else float(m["fov"])
	view.fov = lerpf(view.fov, fov_target, k)
	pivot.rotation = Vector3(orbit_pitch, orbit_yaw, 0.0)
	if visual != null and arm != null:
		var close := arm.get_hit_length() < HIDE_BODY_BELOW
		if visual.visible == close:
			visual.visible = not close

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and input_enabled and not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not look_locked:
		var sens := mouse_sensitivity * GameSettings.look_sensitivity()
		orbit_yaw -= event.relative.x * sens
		var dy: float = event.relative.y * sens
		orbit_pitch = clampf(orbit_pitch - (dy if not GameSettings.invert_y() else -dy), -1.2, 0.1)

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
	var stand_h := float((CAMERA_MODES[camera_mode] as Dictionary)["height"])
	pivot.position.y = lerpf(pivot.position.y, 0.85 if is_crouching else stand_h, clampf(delta * 8.0, 0.0, 1.0))
