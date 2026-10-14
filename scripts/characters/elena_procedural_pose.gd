extends Node
## Procedural pose layer for Elena's MPFB rig, which ships without animations (bind pose = arms-out A-pose).
##
## Every frame it poses a handful of bones from the controller's state:
##   - rest stance: arms lowered to the sides with a slight elbow bend, a breathing sway in the spine;
##   - walk: legs and arms swing in opposition, knees bend on the forward swing, the torso leans into the motion,
##     the hips bob; amplitude and cadence follow the real horizontal speed (no foot sliding at low speed);
##   - airborne: knees tucked and arms raised for balance;
##   - landing: a short knee dip.
## Axes are derived from the rig itself (hip and head positions), so the code does not depend on bone roll.
## Purely visual: no gameplay state, collision or timing depends on it.

const ARM_DOWN := 0.97      # arm direction at rest: mostly down...
const ARM_OUT := 0.2        # ...slightly away from the body...
const ARM_FORWARD := 0.06   # ...and a touch forward
const ELBOW_BEND := deg_to_rad(14.0)
const STRIDE := 1.45                 # metres per full walk cycle (two steps)
const MAX_SPEED := 4.5
const THIGH_SWING := deg_to_rad(30.0)
const KNEE_BEND := deg_to_rad(48.0)
const ARM_SWING := deg_to_rad(17.0)
const FORWARD_LEAN := deg_to_rad(7.0)
const HIP_BOB := 0.035
const AIR_TUCK_THIGH := deg_to_rad(28.0)
const AIR_TUCK_KNEE := deg_to_rad(55.0)
const AIR_ARMS_OUT := deg_to_rad(28.0)
const LAND_DIP := 0.06
const BREATH_PERIOD := 3.6

var body: CharacterBody3D = null
var skeleton: Skeleton3D = null
var model: Node3D = null

var _ids: Dictionary = {}
var _rest_global: Dictionary = {}  # bone -> Basis (skeleton space)
var _rest_dir: Dictionary = {}     # bone -> Vector3 (direction to its child joint)
var _up := Vector3.UP
var _left := Vector3.RIGHT
var _forward := Vector3.BACK
var _phase: float = 0.0
var _walk: float = 0.0
var _air: float = 0.0
var _dip: float = 0.0
var _t: float = 0.0
var _was_on_floor: bool = true
var _model_rest_y: float = 0.0
var ready_ok: bool = false


func setup(character: CharacterBody3D, model_root: Node3D) -> void:
	body = character
	model = model_root
	var found := model_root.find_children("*", "Skeleton3D", true, false)
	if found.is_empty():
		return
	skeleton = found[0] as Skeleton3D
	_model_rest_y = model.position.y
	for bone_name in ["pelvis", "spine_01", "spine_02", "spine_03", "neck_01", "clavicle_l", "clavicle_r",
			"upperarm_l", "lowerarm_l", "hand_l", "upperarm_r", "lowerarm_r", "hand_r",
			"thigh_l", "calf_l", "foot_l", "ball_l", "thigh_r", "calf_r", "foot_r", "ball_r", "head"]:
		var idx := skeleton.find_bone(bone_name)
		if idx < 0:
			return
		_ids[bone_name] = idx
		_rest_global[bone_name] = skeleton.get_bone_global_rest(idx).basis
	var pos := func(n: String) -> Vector3: return skeleton.get_bone_global_rest(_ids[n]).origin
	_up = (pos.call("head") - pos.call("pelvis")).normalized()
	_left = (pos.call("thigh_l") - pos.call("thigh_r"))
	_left = (_left - _up * _left.dot(_up)).normalized()
	_forward = _left.cross(_up).normalized()
	var toe: Vector3 = pos.call("ball_l") - pos.call("foot_l")
	if toe.dot(_forward) < 0.0:
		_forward = -_forward
		_left = -_left
	for pair in [["upperarm_l", "lowerarm_l"], ["lowerarm_l", "hand_l"], ["upperarm_r", "lowerarm_r"],
			["lowerarm_r", "hand_r"], ["thigh_l", "calf_l"], ["calf_l", "foot_l"], ["thigh_r", "calf_r"], ["calf_r", "foot_r"]]:
		_rest_dir[pair[0]] = (pos.call(pair[1]) - pos.call(pair[0])).normalized()
	ready_ok = true


## Rotation that pitches a hanging limb forward by `angle` (negative = backward), about the character's left axis.
func _pitch(angle: float) -> Basis:
	return Basis(_left, -angle)


func _arc(from_dir: Vector3, to_dir: Vector3) -> Basis:
	return Basis(Quaternion(from_dir.normalized(), to_dir.normalized()))


func _process(delta: float) -> void:
	if not ready_ok or not is_instance_valid(skeleton) or body == null:
		return
	_t += delta
	var v := Vector2(body.velocity.x, body.velocity.z)
	var speed := v.length()
	var on_floor := body.is_on_floor()
	var moving := clampf(speed / MAX_SPEED, 0.0, 1.0) if on_floor else 0.0
	_walk = move_toward(_walk, moving, delta * 6.0)
	_air = move_toward(_air, 0.0 if on_floor else 1.0, delta * (10.0 if on_floor else 5.0))
	if on_floor and not _was_on_floor:
		_dip = 1.0
	_was_on_floor = on_floor
	_dip = move_toward(_dip, 0.0, delta * 5.0)
	if on_floor and speed > 0.05:
		_phase = fmod(_phase + speed * delta / STRIDE * TAU, TAU)
	elif _walk < 0.05:
		_phase = lerp_angle(_phase, 0.0, clampf(delta * 4.0, 0.0, 1.0))
	_apply()


func _apply() -> void:
	var s := sin(_phase)
	var c := cos(_phase)
	var breath := sin(_t * TAU / BREATH_PERIOD)
	var posed := {}  # bone -> global basis

	# Torso: lean into the walk, breathe at rest.
	var lean := FORWARD_LEAN * _walk + deg_to_rad(0.8) * breath * (1.0 - _walk) + deg_to_rad(6.0) * _dip
	_set_global("spine_01", _pitch(lean * 0.5) * _rest_global["spine_01"], posed)
	_set_global("spine_02", _pitch(lean) * _rest_global["spine_02"], posed)
	_set_global("spine_03", _pitch(lean) * Basis(_up, deg_to_rad(5.0) * s * _walk) * _rest_global["spine_03"], posed)

	# Legs.
	for side in ["l", "r"]:
		var sign := 1.0 if side == "l" else -1.0
		var swing := THIGH_SWING * _walk * s * sign + AIR_TUCK_THIGH * _air + deg_to_rad(12.0) * _dip
		var lift := maxf(0.0, c * sign)  # knee bends while this leg swings forward
		var knee := KNEE_BEND * _walk * lift + deg_to_rad(6.0) * _walk + AIR_TUCK_KNEE * _air + deg_to_rad(22.0) * _dip
		var thigh := _pitch(swing)
		_set_global("thigh_" + side, thigh * _rest_global["thigh_" + side], posed)
		var calf := _pitch(swing - knee)
		_set_global("calf_" + side, calf * _rest_global["calf_" + side], posed)
		# Keep the foot roughly level: undo most of the leg's pitch.
		_set_global("foot_" + side, _pitch((swing - knee) * 0.15) * _rest_global["foot_" + side], posed)

	# Arms: lower from the A-pose, swing opposite to the legs, raise slightly in the air.
	for side in ["l", "r"]:
		var sign := 1.0 if side == "l" else -1.0
		var outward := _left * sign
		var target := (-_up * ARM_DOWN + outward * ARM_OUT + _forward * ARM_FORWARD).normalized()
		var lowered := _arc(_rest_dir["upperarm_" + side], target)
		var spread := Basis(_forward, -sign * AIR_ARMS_OUT * _air)
		var swing := _pitch(-ARM_SWING * _walk * s * sign)
		var upper := spread * swing * lowered
		_set_global("upperarm_" + side, upper * _rest_global["upperarm_" + side], posed)
		var elbow := _pitch(ELBOW_BEND + deg_to_rad(12.0) * _walk + deg_to_rad(25.0) * _air)
		_set_global("lowerarm_" + side, elbow * upper * _rest_global["lowerarm_" + side], posed)
		_set_global("hand_" + side, elbow * upper * _rest_global["hand_" + side], posed)

	# Hip bob (two dips per cycle) and landing dip, on the model root.
	if model != null:
		model.position.y = _model_rest_y - HIP_BOB * _walk * absf(s) * 0.8 - LAND_DIP * _dip


## Sets a bone so its skeleton-space orientation equals `global_basis`, given the already posed parents.
func _set_global(bone: String, global_basis: Basis, posed: Dictionary) -> void:
	var idx: int = _ids[bone]
	var parent := skeleton.get_bone_parent(idx)
	var parent_basis := Basis.IDENTITY
	if parent >= 0:
		var parent_name := skeleton.get_bone_name(parent)
		if posed.has(parent_name):
			parent_basis = posed[parent_name]
		else:
			parent_basis = skeleton.get_bone_global_pose(parent).basis
	posed[bone] = global_basis
	var local := (parent_basis.inverse() * global_basis).orthonormalized()
	skeleton.set_bone_pose_rotation(idx, local.get_rotation_quaternion())
