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
## Natural ground speed (m/s) of each locomotion clip at playback 1.0. The retarget measures it from the capture scaled to Elena
## (tools/blender/elena_mpfb/animate_elena_v2.py writes elena_clips.json next to the model); these are the fallbacks.
## Playback = ground speed / clip speed, so the feet do not skate.
const CLIP_TABLE := "res://assets/models/characters/elena/elena_clips.json"
var clip_speed: Dictionary = {"walk": 1.34, "run": 3.73, "sprint": 7.51, "crouch_walk": 1.34}
## Gait switches, with hysteresis so analog speeds near a boundary do not flicker. The default pace (4.2 m/s) runs; the sprint
## (6.8 m/s) uses the sprint clip.
const RUN_CLIP_ABOVE := 2.8
const WALK_CLIP_BELOW := 2.4
const SPRINT_CLIP_ABOVE := 5.6
const RUN_CLIP_BELOW_SPRINT := 5.0
## Body lean (degrees) into acceleration and turns; smoothed, and reduced to a third with reduced motion.
const LEAN_FORWARD_MAX := 7.0
const LEAN_SIDE_MAX := 8.0
## Clips that cycle (the rest play once); set here so the model's import settings do not matter.
const LOOPING_CLIPS := ["idle", "walk", "run", "sprint", "crouch_idle", "crouch_walk", "fall"]
## Transitions (captured, in place): "start" when setting off, a pivot ("turn_left"/"turn_right") when setting off in a direction
## far from where she faces, "stop" after a run ends in a standstill. Each plays for a short window, then locomotion blends in.
## Any change of state (air, crouch, a new start) cuts a transition short, so they never delay control.
const START_TIME := 0.26
const START_PLAYBACK := 1.25
const PIVOT_ANGLE := 1.9  # radians between facing and the new direction that makes a standing start a pivot
const PIVOT_TIME := 0.3
const PIVOT_PLAYBACK := 1.8
const STOP_FROM_SPEED := 2.5
const STOP_TIME := 0.5
var _gait: String = "walk"
var _transition: String = ""
var _transition_left: float = 0.0
var _prev_speed: float = 0.0
var _prev_velocity: Vector3 = Vector3.ZERO
var _lean: Vector2 = Vector2.ZERO
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
	_load_clip_table()
	for clip in LOOPING_CLIPS:
		if anim.has_animation(clip):
			anim.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	if pose != null:
		pose.process_mode = Node.PROCESS_MODE_DISABLED
	anim.play("idle")

func _load_clip_table() -> void:
	if not FileAccess.file_exists(CLIP_TABLE):
		return
	var table = JSON.parse_string(FileAccess.get_file_as_string(CLIP_TABLE))
	if not table is Dictionary:
		return
	for clip in clip_speed.keys():
		if table.has(clip) and float(table[clip].get("speed", 0.0)) > 0.2:
			clip_speed[clip] = float(table[clip]["speed"])


## Starts, pivots and stops on the ground (see START_TIME and the constants above).
func _update_transition(delta: float, speed: float) -> void:
	_transition_left -= delta
	if _transition_left <= 0.0:
		_transition = ""
	var moving_off := _prev_speed < 0.3 and speed >= 0.3
	if moving_off:
		var heading := atan2(velocity.x, velocity.z)
		var error := absf(wrapf(heading - visual.rotation.y, -PI, PI)) if visual != null else 0.0
		if error > PIVOT_ANGLE and anim.has_animation("turn_left"):
			var left := wrapf(heading - visual.rotation.y, -PI, PI) > 0.0
			_set_transition("turn_left" if left else "turn_right", PIVOT_TIME)
		elif anim.has_animation("start"):
			_set_transition("start", START_TIME)
	elif _transition == "stop" and speed > 0.3:
		_transition = ""  # moving again: back to locomotion at once
	elif _prev_speed > STOP_FROM_SPEED and speed < 0.3 and anim.has_animation("stop"):
		_set_transition("stop", STOP_TIME)
	elif _transition == "start" and speed < 0.3:
		_transition = ""


func _set_transition(clip: String, seconds: float) -> void:
	_transition = clip
	_transition_left = seconds
	if anim.current_animation == clip:
		anim.seek(0.0, true)


## Walk / run / sprint from the ground speed, with hysteresis.
func _update_gait(speed: float) -> void:
	match _gait:
		"walk":
			if speed > RUN_CLIP_ABOVE or (is_running and speed > 2.0):
				_gait = "run"
		"run":
			if speed < WALK_CLIP_BELOW and not is_running:
				_gait = "walk"
			elif speed > SPRINT_CLIP_ABOVE and anim.has_animation("sprint"):
				_gait = "sprint"
		_:
			if speed < RUN_CLIP_BELOW_SPRINT:
				_gait = "run"


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


## Leans the body into what the controller is doing: forward when accelerating, back when braking, sideways into
## turns (centripetal). Visual only; collision and camera are unaffected.
func _update_lean(delta: float, on_floor: bool) -> void:
	if visual == null or delta <= 0.0:
		return
	var v := Vector3(velocity.x, 0.0, velocity.z)
	var accel := (v - _prev_velocity) / delta
	_prev_velocity = v
	var target := Vector2.ZERO
	if on_floor and not is_climbing:
		var facing := Vector3(sin(visual.rotation.y), 0.0, cos(visual.rotation.y))
		var side := facing.cross(Vector3.UP)
		target.x = clampf(accel.dot(facing) / 30.0, -1.0, 1.0) * LEAN_FORWARD_MAX
		target.y = clampf(-accel.dot(side) / 30.0, -1.0, 1.0) * LEAN_SIDE_MAX
		if AccessibilityManager.is_reduced_motion():
			target /= 3.0
	_lean = _lean.lerp(target, clampf(delta * 6.0, 0.0, 1.0))
	visual.rotation.x = deg_to_rad(_lean.x)
	visual.rotation.z = deg_to_rad(_lean.y)


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
		playback = clampf(speed / float(clip_speed["crouch_walk"]), 0.6, 2.0) if speed > 0.25 else 1.0
	else:
		_update_transition(delta, speed)
		if not _transition.is_empty():
			wanted = _transition
			playback = START_PLAYBACK if _transition == "start" else (PIVOT_PLAYBACK if _transition.begins_with("turn") else 1.0)
		elif speed > 0.3:
			_update_gait(speed)
			wanted = _gait
			# Playback follows ground speed so the feet do not skate.
			playback = clampf(speed / float(clip_speed.get(_gait, 1.0)), 0.55, 1.75)
		elif _gesture_left > 0.0:
			wanted = _gesture
	if not on_floor or is_crouching or is_climbing:
		_transition = ""
		_transition_left = 0.0
	_prev_speed = speed
	anim.speed_scale = playback
	if anim.current_animation != wanted:
		# Locomotion changes blend softly; airborne and landing states cut in quickly to stay responsive.
		var blend := 0.08 if wanted in ["jump", "fall", "land", "climb"] else (0.1 if wanted in ["start", "stop", "turn_left", "turn_right"] else 0.2)
		anim.play(wanted, blend)
	_update_lean(delta, on_floor)
	# The orbit pivot follows the body: lower while crouched so the camera reads low passages.
	var stand_h := float((CAMERA_MODES[camera_mode] as Dictionary)["height"])
	pivot.position.y = lerpf(pivot.position.y, 0.85 if is_crouching else stand_h, clampf(delta * 8.0, 0.0, 1.0))
