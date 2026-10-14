"""Procedural animations for Elena's MPFB rig, exported into ref_elena_mpfb.glb.

    blender --background --factory-startup --python tools/blender/elena_mpfb/animate_elena.py -- \
        --repo D:/Projects/github/final-thaw --blend D:/Projects/evidence/final-thaw/elena_mpfb/elena_mpfb_baked.blend \
        --blend-dir D:/Projects/evidence/final-thaw/elena_mpfb

The input .blend is the output of bake_elena.py (finalized materials, 53-bone `game_engine` rig, A-pose rest). Thirteen actions are keyed
at 30 fps and exported as glTF animations named exactly: idle, walk, run, crouch_idle, crouch_walk, jump, fall, land, climb, scan,
interact, alert, caught. Nothing translates the character: only the pelvis height changes (so the feet stay on the floor) and only in
the animations where the feet are planted. Looping animations are closed (last key == first key); set loop mode in Godot.

Conventions (Blender world axes): +X = Elena's left, +Y = back, -Y = front (glTF +Z), +Z = up. A rotation of +angle about +X leans the
upper body forward and swings a downward-pointing limb backward, so forward swings of arms/legs are negative.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))

import bpy  # noqa: E402
from mathutils import Quaternion, Vector  # noqa: E402

from lab_blender_common import parse_args  # noqa: E402

FPS = 30
TAU = math.tau
ARM_HANG = 32.0  # degrees the upper arms are lowered from the A-pose (not fully, so the long coat does not clip)
AXES = {"x": Vector((1, 0, 0)), "y": Vector((0, 1, 0)), "z": Vector((0, 0, 1))}

rig = None
bone_rest = {}  # bone name -> 3x3 rest rotation in armature space
ground_rest_z = 0.0
FOOT_BONES = ("foot_l", "foot_r", "ball_l", "ball_r")
LOOPS = ("idle", "walk", "run", "crouch_idle", "crouch_walk", "fall")


class Pose:
	"""Accumulates world-axis rotations per bone for one frame."""

	def __init__(self):
		self.rot = {}
		self.pelvis_dz = 0.0  # extra world-space vertical offset applied after grounding

	def r(self, bone, axis, degrees):
		q = Quaternion(AXES[axis], math.radians(degrees))
		self.rot[bone] = q @ self.rot.get(bone, Quaternion())
		return self

	def arm_hang(self):
		self.r("upperarm_l", "y", ARM_HANG).r("upperarm_r", "y", -ARM_HANG)
		return self


def setup():
	global rig, ground_rest_z
	rig = bpy.data.objects["Elena_Base.rig"]
	bpy.context.view_layer.objects.active = rig
	for b in rig.data.bones:
		bone_rest[b.name] = b.matrix_local.to_3x3()
	for pb in rig.pose.bones:
		pb.rotation_mode = "QUATERNION"
	ground_rest_z = lowest_foot_z()


def lowest_foot_z():
	bpy.context.view_layer.update()
	zs = []
	for name in FOOT_BONES:
		pb = rig.pose.bones[name]
		zs.append((rig.matrix_world @ pb.head).z)
		zs.append((rig.matrix_world @ pb.tail).z)
	return min(zs)


def apply(pose, ground):
	for pb in rig.pose.bones:
		pb.rotation_quaternion = Quaternion()
		pb.location = Vector((0, 0, 0))
	for name, qw in pose.rot.items():
		rb = bone_rest[name]
		local = (rb.inverted() @ qw.to_matrix() @ rb).to_quaternion()
		rig.pose.bones[name].rotation_quaternion = local
	pelvis = rig.pose.bones["pelvis"]
	dz = pose.pelvis_dz
	if ground:
		dz += ground_rest_z - lowest_foot_z()
	if abs(dz) > 1e-6:
		pelvis.location = bone_rest["pelvis"].inverted() @ Vector((0, 0, dz))
	bpy.context.view_layer.update()
	if ground:
		# second pass: the pelvis shift above moves the feet too, so re-measure once
		residual = ground_rest_z - lowest_foot_z()
		if abs(residual) > 1e-4:
			pelvis.location = bone_rest["pelvis"].inverted() @ Vector((0, 0, dz + residual))
			bpy.context.view_layer.update()


def leg_lengths():
	b = rig.data.bones
	return (b["calf_l"].head_local - b["thigh_l"].head_local).length, (b["foot_l"].head_local - b["calf_l"].head_local).length


def crouch_legs(p, alpha):
	"""Both legs flexed `alpha` degrees at the hip with the ankle kept under the hip; the foot stays flat."""
	l1, l2 = leg_lengths()
	a = math.radians(alpha)
	g = math.asin(min(1.0, l1 * math.sin(a) / l2))
	for s in ("l", "r"):
		p.r("thigh_" + s, "x", -alpha).r("calf_" + s, "x", math.degrees(g) + alpha).r("foot_" + s, "x", -math.degrees(g))
	return p


def swing_leg(p, side, phase, amp, knee, toe=18.0, base_flex=4.0):
	"""One leg of a walk/run cycle. phase 0..tau; forward = sin(phase) > 0."""
	s = math.sin(phase)
	c = max(0.0, math.cos(phase))
	thigh = -amp * s
	calf = base_flex + knee * c
	foot = -0.55 * (thigh + calf) + toe * max(0.0, -s)
	p.r("thigh_" + side, "x", thigh).r("calf_" + side, "x", calf).r("foot_" + side, "x", foot)


def swing_arm(p, side, phase, amp, elbow, hang=True):
	"""Arm counter-swinging against the same-side leg (phase of that leg)."""
	p.r("upperarm_" + side, "x", amp * math.sin(phase))
	p.r("lowerarm_" + side, "x", -(elbow + 0.35 * elbow * max(0.0, -math.sin(phase))))
	if hang:
		p.r("upperarm_" + side, "y", ARM_HANG if side == "l" else -ARM_HANG)


# ---------------------------------------------------------------- animations: each returns (frame_count, function(frame_index) -> (Pose, grounded))
def anim_idle():
	n = 90

	def f(i):
		t = i / n * TAU
		p = Pose().arm_hang()
		p.r("spine_02", "x", 1.0 * math.sin(t)).r("spine_03", "x", 1.4 * math.sin(t)).r("head", "x", -1.0 * math.sin(t + 0.6))
		p.r("clavicle_l", "z", 1.2 * math.sin(t)).r("clavicle_r", "z", -1.2 * math.sin(t))
		p.r("upperarm_l", "x", 0.8 * math.sin(t + 1.0)).r("upperarm_r", "x", -0.8 * math.sin(t + 1.0))
		p.r("lowerarm_l", "x", -6).r("lowerarm_r", "x", -6)
		p.r("pelvis", "y", 0.8 * math.sin(t * 0.5))
		return p, True
	return n, f


def anim_walk():
	n = 30

	def f(i):
		t = i / n * TAU
		p = Pose()
		swing_leg(p, "l", t, 26, 38)
		swing_leg(p, "r", t + math.pi, 26, 38)
		swing_arm(p, "l", t, 17, 12)
		swing_arm(p, "r", t + math.pi, 17, 12)
		p.r("pelvis", "z", 4.0 * math.sin(t)).r("spine_02", "z", -3.0 * math.sin(t)).r("spine_03", "z", -3.0 * math.sin(t))
		p.r("pelvis", "y", 2.0 * math.sin(t)).r("spine_03", "x", 3).r("head", "z", 1.5 * math.sin(t))
		return p, True
	return n, f


def anim_run():
	n = 20

	def f(i):
		t = i / n * TAU
		p = Pose()
		swing_leg(p, "l", t, 46, 105, toe=28.0, base_flex=10.0)
		swing_leg(p, "r", t + math.pi, 46, 105, toe=28.0, base_flex=10.0)
		swing_arm(p, "l", t, 42, 80)
		swing_arm(p, "r", t + math.pi, 42, 80)
		p.r("pelvis", "x", 8).r("spine_02", "x", 4).r("spine_03", "x", 4).r("head", "x", -9)
		p.r("pelvis", "z", 6.0 * math.sin(t)).r("spine_03", "z", -7.0 * math.sin(t)).r("pelvis", "y", 3.0 * math.sin(t))
		return p, True
	return n, f


def anim_crouch_idle():
	n = 90

	def f(i):
		t = i / n * TAU
		p = crouch_legs(Pose(), 46)
		p.r("pelvis", "x", 18).r("spine_02", "x", 8).r("spine_03", "x", 6).r("head", "x", -26)
		p.arm_hang().r("upperarm_l", "x", -22).r("upperarm_r", "x", -22).r("lowerarm_l", "x", -35).r("lowerarm_r", "x", -35)
		p.r("spine_03", "x", 1.2 * math.sin(t)).r("head", "x", -0.8 * math.sin(t + 0.5))
		return p, True
	return n, f


def anim_crouch_walk():
	n = 36

	def f(i):
		t = i / n * TAU
		p = Pose()
		swing_leg(p, "l", t, 16, 30, toe=10.0, base_flex=0.0)
		swing_leg(p, "r", t + math.pi, 16, 30, toe=10.0, base_flex=0.0)
		for s in ("l", "r"):  # on top of the swing, the crouch posture
			p.r("thigh_" + s, "x", -36).r("calf_" + s, "x", 33 + 36).r("foot_" + s, "x", -33)
		swing_arm(p, "l", t, 10, 30)
		swing_arm(p, "r", t + math.pi, 10, 30)
		p.r("pelvis", "x", 16).r("spine_02", "x", 6).r("spine_03", "x", 6).r("head", "x", -20)
		p.r("pelvis", "z", 3.0 * math.sin(t)).r("spine_03", "z", -3.0 * math.sin(t))
		return p, True
	return n, f


def _lerp(a, b, t):
	return a + (b - a) * t


def _ease(t):
	t = max(0.0, min(1.0, t))
	return t * t * (3.0 - 2.0 * t)


def anim_jump():
	n = 24

	def f(i):
		p = Pose()
		if i <= 6:  # anticipation: crouch and swing the arms back
			k = _ease(i / 6.0)
			crouch_legs(p, 62 * k)
			p.r("pelvis", "x", 18 * k).r("spine_03", "x", 6 * k).r("head", "x", -14 * k)
			p.arm_hang().r("upperarm_l", "x", 30 * k).r("upperarm_r", "x", 30 * k)
			return p, True
		if i <= 10:  # push off: legs extend, arms swing up, feet leave the floor
			k = _ease((i - 6) / 4.0)
			crouch_legs(p, _lerp(62, 5, k))
			p.r("pelvis", "x", _lerp(18, -2, k)).r("head", "x", _lerp(-14, 4, k))
			p.arm_hang().r("upperarm_l", "x", _lerp(30, -150, k)).r("upperarm_r", "x", _lerp(30, -150, k))
			p.r("foot_l", "x", 35 * k).r("foot_r", "x", 35 * k)
			return p, i < 9
		k = _ease((i - 10) / 14.0)  # rise and tuck the knees
		p.r("thigh_l", "x", -_lerp(10, 50, k)).r("calf_l", "x", _lerp(15, 80, k)).r("foot_l", "x", _lerp(20, -10, k))
		p.r("thigh_r", "x", -_lerp(5, 38, k)).r("calf_r", "x", _lerp(10, 70, k)).r("foot_r", "x", _lerp(20, -10, k))
		p.arm_hang().r("upperarm_l", "x", _lerp(-150, -60, k)).r("upperarm_r", "x", _lerp(-150, -60, k)).r("lowerarm_l", "x", -25 * k).r("lowerarm_r", "x", -25 * k)
		p.r("pelvis", "x", _lerp(-2, 6, k)).r("head", "x", _lerp(4, -4, k))
		return p, False
	return n, f


def anim_fall():
	n = 30

	def f(i):
		t = i / n * TAU
		p = Pose()
		p.r("thigh_l", "x", -18 - 4 * math.sin(t)).r("calf_l", "x", 38 + 6 * math.sin(t)).r("foot_l", "x", 28)
		p.r("thigh_r", "x", -8 + 4 * math.sin(t)).r("calf_r", "x", 30 - 6 * math.sin(t)).r("foot_r", "x", 28)
		p.arm_hang().r("upperarm_l", "x", -50 + 8 * math.sin(t)).r("upperarm_r", "x", -50 - 8 * math.sin(t))
		p.r("upperarm_l", "y", 25).r("upperarm_r", "y", -25).r("lowerarm_l", "x", -25).r("lowerarm_r", "x", -25)
		p.r("pelvis", "x", -4).r("spine_03", "x", -3).r("head", "x", 5 + 1.5 * math.sin(t))
		return p, False
	return n, f


def anim_land():
	n = 12

	def f(i):
		k = 1.0 - _ease(i / (n - 1.0))  # deep absorb -> upright
		p = crouch_legs(Pose(), 52 * k)
		p.r("pelvis", "x", 20 * k).r("spine_03", "x", 6 * k).r("head", "x", -18 * k)
		p.arm_hang().r("upperarm_l", "x", -10 * k).r("upperarm_r", "x", -10 * k)
		return p, True
	return n, f


def anim_climb():
	n = 45

	def f(i):
		k = i / (n - 1.0)
		p = Pose()
		if k < 0.25:  # reach for the ledge with both hands
			u = _ease(k / 0.25)
			p.r("upperarm_l", "x", -165 * u).r("upperarm_r", "x", -165 * u).r("lowerarm_l", "x", -10 * u).r("lowerarm_r", "x", -10 * u)
			p.r("pelvis", "x", 6 * u).r("head", "x", -12 * u)
			p.r("thigh_l", "x", -6 * u).r("calf_l", "x", 10 * u)
			return p, False
		if k < 0.6:  # pull up: elbows bend, one knee comes up
			u = _ease((k - 0.25) / 0.35)
			p.r("upperarm_l", "x", _lerp(-165, -120, u)).r("upperarm_r", "x", _lerp(-165, -120, u))
			p.r("lowerarm_l", "x", _lerp(-10, -125, u)).r("lowerarm_r", "x", _lerp(-10, -125, u))
			p.r("pelvis", "x", _lerp(6, 14, u)).r("spine_03", "x", 8 * u).r("head", "x", _lerp(-12, -20, u))
			p.r("thigh_l", "x", _lerp(-6, -95, u)).r("calf_l", "x", _lerp(10, 105, u)).r("foot_l", "x", -10 * u)
			p.r("thigh_r", "x", -8 * u).r("calf_r", "x", 14 * u)
			return p, False
		u = _ease((k - 0.6) / 0.4)  # push up to stand
		p.r("upperarm_l", "x", _lerp(-120, 0, u)).r("upperarm_r", "x", _lerp(-120, 0, u))
		p.r("lowerarm_l", "x", _lerp(-125, -8, u)).r("lowerarm_r", "x", _lerp(-125, -8, u))
		p.r("pelvis", "x", _lerp(14, 0, u)).r("spine_03", "x", _lerp(8, 0, u)).r("head", "x", _lerp(-20, 0, u))
		p.r("thigh_l", "x", _lerp(-95, -8, u)).r("calf_l", "x", _lerp(105, 12, u)).r("foot_l", "x", _lerp(-10, 0, u))
		p.r("thigh_r", "x", _lerp(-8, 0, u)).r("calf_r", "x", _lerp(14, 4, u))
		p.arm_hang()
		return p, u > 0.7
	return n, f


def anim_scan():
	n = 45

	def f(i):
		k = i / (n - 1.0)
		up = _ease(k / 0.3) if k < 0.7 else 1.0 - _ease((k - 0.7) / 0.3)  # raise, hold, lower the right arm (the Aster hand)
		p = Pose().arm_hang()
		p.r("upperarm_r", "x", -75 * up).r("upperarm_r", "y", 28 * up).r("lowerarm_r", "x", -50 * up).r("hand_r", "x", -15 * up)
		p.r("upperarm_l", "x", -8 * up).r("lowerarm_l", "x", -14 * up)
		sweep = math.sin(k * math.pi * 2.0) * 14.0 * up  # slow head and torso sweep while scanning
		p.r("head", "z", sweep).r("spine_03", "z", sweep * 0.5).r("head", "x", -6 * up).r("pelvis", "x", 3 * up)
		return p, True
	return n, f


def anim_interact():
	n = 36

	def f(i):
		k = i / (n - 1.0)
		reach = _ease(k / 0.35) if k < 0.5 else 1.0 - _ease((k - 0.5) / 0.5)  # reach, press, return
		press = math.sin(min(1.0, max(0.0, (k - 0.3) / 0.25)) * math.pi)
		p = Pose().arm_hang()
		p.r("upperarm_r", "x", -62 * reach).r("lowerarm_r", "x", -35 * reach - 18 * press).r("hand_r", "x", -8 * reach)
		p.r("upperarm_r", "y", 20 * reach)
		p.r("pelvis", "x", 10 * reach).r("spine_03", "x", 6 * reach).r("head", "x", -8 * reach)
		p.r("thigh_l", "x", -6 * reach).r("calf_l", "x", 8 * reach)
		return p, True
	return n, f


def anim_alert():
	n = 18

	def f(i):
		k = i / (n - 1.0)
		hit = math.sin(min(1.0, k / 0.55) * math.pi * 0.5) if k < 0.55 else 1.0 - 0.45 * _ease((k - 0.55) / 0.45)
		p = Pose().arm_hang()
		p.r("pelvis", "x", -4 * hit).r("spine_03", "x", -5 * hit).r("head", "x", -2 * hit).r("clavicle_l", "z", 3 * hit).r("clavicle_r", "z", -3 * hit)
		p.r("upperarm_l", "x", -14 * hit).r("upperarm_r", "x", -14 * hit).r("lowerarm_l", "x", -30 * hit).r("lowerarm_r", "x", -30 * hit)
		p.r("thigh_l", "x", -10 * hit).r("calf_l", "x", 18 * hit).r("thigh_r", "x", 4 * hit).r("calf_r", "x", 6 * hit)
		p.r("head", "z", 8 * hit)
		return p, True
	return n, f


def anim_caught():
	n = 36

	def f(i):
		k = i / (n - 1.0)
		u = _ease(k / 0.6)  # stagger back, knees buckle, end kneeling-slumped (held to the last frame)
		p = Pose().arm_hang()
		crouch_legs(p, 70 * u)
		p.r("pelvis", "x", _lerp(-8, 24, u)).r("spine_03", "x", _lerp(-6, 14, u)).r("head", "x", _lerp(-12, 30, u))
		p.r("upperarm_l", "x", _lerp(-70, 10, u)).r("upperarm_r", "x", _lerp(-70, 10, u))
		p.r("upperarm_l", "y", -25 * (1 - u)).r("upperarm_r", "y", 25 * (1 - u))
		p.r("lowerarm_l", "x", _lerp(-30, -50, u)).r("lowerarm_r", "x", _lerp(-30, -50, u))
		return p, True
	return n, f


ANIMATIONS = [("idle", anim_idle), ("walk", anim_walk), ("run", anim_run), ("crouch_idle", anim_crouch_idle), ("crouch_walk", anim_crouch_walk),
	("jump", anim_jump), ("fall", anim_fall), ("land", anim_land), ("climb", anim_climb), ("scan", anim_scan), ("interact", anim_interact),
	("alert", anim_alert), ("caught", anim_caught)]


def key_animation(name, builder):
	count, fn = builder()
	loop = name in LOOPS
	frames = list(range(count + 1)) if loop else list(range(count))
	poses = []
	for i in frames:
		pose, grounded = fn(i % count if loop else i)
		poses.append((pose, grounded))
	touched = {"pelvis"}
	for pose, _ in poses:
		touched.update(pose.rot.keys())
	ad = rig.animation_data_create()
	ad.action = None
	# phase 1: solve every pose with no action assigned (an assigned action would be re-evaluated and overwrite the pose)
	solved = []
	for pose, grounded in poses:
		apply(pose, grounded)
		solved.append(({b: rig.pose.bones[b].rotation_quaternion.copy() for b in touched}, rig.pose.bones["pelvis"].location.copy()))
	# phase 2: write the stored values and key them, without any depsgraph update in between
	action = bpy.data.actions.new(name)
	ad.action = action
	for i, (rotations, pelvis_loc) in list(zip(frames, solved)) * 2:  # twice: the first insertion into a new action records the evaluated value, the second overwrites it
		for bone, q in rotations.items():
			pb = rig.pose.bones[bone]
			pb.rotation_quaternion = q
			pb.keyframe_insert("rotation_quaternion", frame=i + 1)
		rig.pose.bones["pelvis"].location = pelvis_loc
		rig.pose.bones["pelvis"].keyframe_insert("location", frame=i + 1)
	ad.action = None
	action.use_fake_user = True
	print("[anim] %s: %d frames, %d bones" % (name, len(frames), len(touched)))
	return action


def main():
	options = {"repo": None, "blend": None, "blend-dir": None}
	parse_args(options)
	repo = os.path.abspath(options["repo"])
	glb = os.path.join(repo, "assets", "models", "lab_ref", "ref_elena_mpfb.glb")
	bpy.ops.wm.open_mainfile(filepath=options["blend"])
	bpy.context.scene.render.fps = FPS
	setup()
	actions = [key_animation(name, builder) for name, builder in ANIMATIONS]
	# NLA tracks only after every pose is solved: existing strips would be re-evaluated and overwrite the pose being solved
	ad = rig.animation_data
	for action in actions:
		track = ad.nla_tracks.new()
		track.name = action.name
		track.strips.new(action.name, 1, action).name = action.name
	apply(Pose(), False)  # leave the file in the rest pose
	meshes = [o for o in bpy.data.objects if o.type == "MESH"]
	bpy.ops.object.select_all(action="DESELECT")
	for obj in meshes + [rig]:
		obj.select_set(True)
	bpy.ops.export_scene.gltf(filepath=glb, export_format="GLB", use_selection=True, export_yup=True, export_skins=True, export_apply=False,
		export_materials="EXPORT", export_image_format="NONE", export_animations=True, export_animation_mode="ACTIONS",
		export_force_sampling=True, export_optimize_animation_size=False)
	print("[anim] -> " + glb)
	if options.get("blend-dir"):
		path = os.path.join(os.path.abspath(options["blend-dir"]), "elena_mpfb_animated.blend")
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


if __name__ == "__main__":
	main()
