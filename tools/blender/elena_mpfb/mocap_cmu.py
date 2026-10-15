"""CMU motion capture (ASF/AMC) -> Elena's 53-bone `game_engine` rig. Runs inside Blender (bpy, mathutils, numpy).

Source data: CMU Graphics Lab Motion Capture Database (mocap.cs.cmu.edu; "may be copied, modified, or redistributed without
permission"), kept outside the repository in D:/Projects/external_assets/cmu_mocap (see SOURCE.txt there).

Method (world-space delta transfer):
- ASF/AMC forward kinematics give every source bone a world rotation G(t) relative to the ASF rest pose (where all G = I).
- The source basis (Y up, facing taken from the rest feet) is mapped to Blender's (Z up, Elena faces -Y) by P, and a per-clip yaw
  turns the travel direction (or the hips' facing, for clips that do not travel) onto -Y.
- Each mapped target bone gets the swing that aligns its rest direction with the source rest direction (this absorbs the A-pose /
  T-pose difference), then the source delta: W(t) = Yaw * P G(t) P^T * Align * R_rest.
- Pose-bone rotations are solved down the hierarchy; unmapped bones (fingers) keep their rest relation plus a relaxed curl.
- The pelvis keeps the source's vertical motion scaled by leg length; horizontal travel is removed (the controller moves the body)
  and, for grounded clips, the lowest foot is pinned to the floor so stance feet never float or sink.
Outputs per clip: the solved frames (30 fps) and the natural ground speed in Elena's scale (m/s), used by the game to match
playback rate to ground speed so the feet do not skate.
"""
import math
import os

import numpy as np
from mathutils import Euler, Matrix, Quaternion, Vector

FPS_OUT = 30
CMU_UNIT_TO_M = 0.0254 / 0.45  # ASF lengths are in 1/0.45 inch

# target bone <- source bone
MAP = {
	"pelvis": "root", "spine_01": "lowerback", "spine_02": "upperback", "spine_03": "thorax",
	"neck_01": "lowerneck", "head": "head",
	"clavicle_l": "lclavicle", "upperarm_l": "lhumerus", "lowerarm_l": "lradius", "hand_l": "lhand",
	"clavicle_r": "rclavicle", "upperarm_r": "rhumerus", "lowerarm_r": "rradius", "hand_r": "rhand",
	"thigh_l": "lfemur", "calf_l": "ltibia", "foot_l": "lfoot", "ball_l": "ltoes",
	"thigh_r": "rfemur", "calf_r": "rtibia", "foot_r": "rfoot", "ball_r": "rtoes",
}
# relaxed hand: degrees of flexion per finger joint (about each bone's local X)
FINGER_CURL = {"index": (12.0, 18.0, 10.0), "middle": (14.0, 20.0, 12.0), "ring": (16.0, 22.0, 12.0), "pinky": (18.0, 24.0, 14.0),
	"thumb": (4.0, 8.0, 6.0)}


# --- ASF / AMC --------------------------------------------------------------------------------------------------------

class Bone:
	def __init__(self):
		self.name = ""
		self.direction = Vector((0.0, 0.0, 0.0))
		self.length = 0.0
		self.axis = Matrix.Identity(3)
		self.dof = []
		self.parent = None
		self.children = []


def parse_asf(path):
	bones = {}
	root = Bone()
	root.name = "root"
	root.dof = ["tx", "ty", "tz", "rx", "ry", "rz"]
	bones["root"] = root
	section = None
	current = None
	with open(path, encoding="latin-1") as handle:
		lines = handle.read().splitlines()
	for raw in lines:
		line = raw.strip()
		if not line or line.startswith("#"):
			continue
		if line.startswith(":"):
			section = line.split()[0]
			if section == ":root":
				pass
			continue
		parts = line.split()
		if section == ":root":
			if parts[0] == "axis":
				pass
			elif parts[0] == "orientation":
				root.axis = Euler([math.radians(float(v)) for v in parts[1:4]], "XYZ").to_matrix()
		elif section == ":bonedata":
			if parts[0] == "begin":
				current = Bone()
			elif parts[0] == "end":
				bones[current.name] = current
				current = None
			elif current is not None:
				if parts[0] == "name":
					current.name = parts[1]
				elif parts[0] == "direction":
					current.direction = Vector([float(v) for v in parts[1:4]])
				elif parts[0] == "length":
					current.length = float(parts[1])
				elif parts[0] == "axis":
					order = parts[4]
					angles = [math.radians(float(v)) for v in parts[1:4]]
					current.axis = Euler(angles, order).to_matrix() if order == "XYZ" else _euler_order(angles, order)
				elif parts[0] == "dof":
					current.dof = [p.lower() for p in parts[1:]]
		elif section == ":hierarchy":
			if parts[0] in ("begin", "end"):
				continue
			parent = bones[parts[0]]
			for child_name in parts[1:]:
				child = bones[child_name]
				child.parent = parent
				parent.children.append(child)
	return bones


def _euler_order(angles, order):
	m = Matrix.Identity(3)
	for axis, a in zip(order, angles):
		m = Matrix.Rotation(a, 3, axis) @ m
	return m


def parse_amc(path):
	frames = []
	current = None
	with open(path, encoding="latin-1") as handle:
		for raw in handle:
			line = raw.strip()
			if not line or line.startswith("#") or line.startswith(":"):
				continue
			parts = line.split()
			if len(parts) == 1 and parts[0].isdigit():
				current = {}
				frames.append(current)
				continue
			if current is not None:
				current[parts[0]] = [float(v) for v in parts[1:]]
	return frames


def _motion_matrix(bone, values):
	rx = ry = rz = 0.0
	for name, v in zip([d for d in bone.dof if d.startswith("r")], [v for d, v in zip(bone.dof, values) if d.startswith("r")]):
		if name == "rx":
			rx = v
		elif name == "ry":
			ry = v
		elif name == "rz":
			rz = v
	return Euler((math.radians(rx), math.radians(ry), math.radians(rz)), "XYZ").to_matrix()


def fk(bones, frame):
	"""World rotation (3x3) and end position (ASF units) of every source bone for one AMC frame."""
	rot, end = {}, {}
	root = bones["root"]
	values = frame.get("root", [0.0] * 6)
	pos = Vector(values[0:3])
	rot["root"] = root.axis @ _motion_matrix(root, [0, 0, 0] + values[3:6]) @ root.axis.inverted()
	end["root"] = pos

	def walk(bone):
		for child in bone.children:
			m = _motion_matrix(child, frame[child.name]) if child.name in frame and child.dof else Matrix.Identity(3)
			rot[child.name] = rot[bone.name] @ child.axis @ m @ child.axis.inverted()
			end[child.name] = end[bone.name] + rot[child.name] @ (child.direction * child.length)
			walk(child)
	walk(root)
	return rot, end


def rest_frame():
	return {}


# --- target rig ---------------------------------------------------------------------------------------------------------

class TargetRig:
	def __init__(self, rig):
		self.rig = rig
		self.bones = [b for b in rig.data.bones]
		self.order = []  # parents first
		def add(b):
			self.order.append(b.name)
			for c in b.children:
				add(c)
		for b in rig.data.bones:
			if b.parent is None:
				add(b)
		self.rest = {b.name: b.matrix_local.to_3x3().normalized() for b in self.bones}
		self.head = {b.name: b.head_local.copy() for b in self.bones}
		self.tail = {b.name: b.tail_local.copy() for b in self.bones}
		self.parent = {b.name: (b.parent.name if b.parent else None) for b in self.bones}
		self.hip_height = (self.head["thigh_l"].z + self.head["thigh_r"].z) * 0.5
		# contact points per foot in rest (Blender world): heel under the ankle, toe tip ahead of the ball
		self.contacts = {}
		for side in ("l", "r"):
			ankle = self.head["foot_" + side]
			toe = self.tail["ball_" + side]
			self.contacts["foot_" + side] = Vector((ankle.x, ankle.y + 0.035, 0.012))
			self.contacts["ball_" + side] = Vector((toe.x, toe.y + 0.01, 0.012))

	def solve(self, world_rot, pelvis_offset):
		"""Desired world rotations for mapped bones -> pose-bone (basis) quaternions for every bone, plus the pelvis location."""
		W = {}
		basis = {}
		for name in self.order:
			parent = self.parent[name]
			rest_rel = (self.rest[parent].inverted() @ self.rest[name]) if parent else self.rest[name]
			if name in world_rot:
				W[name] = world_rot[name]
			elif parent is None:
				W[name] = self.rest[name]
			else:
				W[name] = W[parent] @ rest_rel
				curl = _finger_curl(name)
				if curl:
					W[name] = W[name] @ Matrix.Rotation(math.radians(curl), 3, "X")
			current_rel = (W[parent].inverted() @ W[name]) if parent else W[name]
			basis[name] = (rest_rel.inverted() @ current_rel).to_quaternion()
		loc = self.rest["pelvis"].inverted() @ pelvis_offset
		return basis, loc, W

	def positions(self, W, pelvis_offset):
		"""Joint head positions (Blender world) for solved world rotations (rigid bones, pelvis translated)."""
		pos = {}
		for name in self.order:
			parent = self.parent[name]
			if parent is None:
				pos[name] = self.head[name].copy()
				continue
			offset = self.head[name] - self.head[parent]
			pos[name] = pos[parent] + W[parent] @ (self.rest[parent].inverted() @ offset)
			if name == "pelvis":
				pos[name] = pos[name] + pelvis_offset
		return pos

	def contact_heights(self, W, pos):
		out = {}
		for bone, point in self.contacts.items():
			local = self.rest[bone].inverted() @ (point - self.head[bone])
			out[bone] = (pos[bone] + W[bone] @ local).z
		return out


def _finger_curl(name):
	for finger, angles in FINGER_CURL.items():
		if name.startswith(finger + "_"):
			index = int(name.split("_")[1]) - 1
			return angles[index] if 0 <= index < 3 else 0.0
	return 0.0


# --- retarget -------------------------------------------------------------------------------------------------------------

class Clip:
	def __init__(self, asf_path, amc_path):
		self.bones = parse_asf(asf_path)
		self.frames = parse_amc(amc_path)
		self.fps_in = 120
		# source basis: Y up; forward from the rest feet (toes direction)
		feet = self.bones["lfoot"].direction + self.bones["rfoot"].direction
		fwd = Vector((feet.x, 0.0, feet.z)).normalized()
		up = Vector((0.0, 1.0, 0.0))
		left = up.cross(fwd).normalized()  # right-handed: left = up x forward
		# Blender: forward -Y, up +Z, Elena's left +X
		src = Matrix((left, up, fwd)).transposed()     # columns: left, up, fwd in source coords
		dst = Matrix(((1.0, 0.0, 0.0), (0.0, 0.0, 1.0), (0.0, -1.0, 0.0))).transposed()  # columns: +X, +Z, -Y
		self.P = dst @ src.inverted()
		rest_rot, rest_end = fk(self.bones, {})
		self.rest_end = {k: self.P @ v * CMU_UNIT_TO_M for k, v in rest_end.items()}
		lowest = min(v.z for v in self.rest_end.values())
		self.hip_height = (self.rest_end["lhipjoint"].z + self.rest_end["rhipjoint"].z) * 0.5 - lowest
		self.root_standing = -lowest  # root height above the floor in the ASF rest pose
		self._ground = None
		self.rest_dir = {name: (self.P @ b.direction).normalized() for name, b in self.bones.items() if b.length > 0.0}

	def ground(self):
		"""The capture floor (m, Blender basis): 5th percentile of the lowest foot end over the clip."""
		if self._ground is None:
			lows = []
			for i in range(0, len(self.frames), 6):
				_, end = fk(self.bones, self.frames[i])
				lows.append(min((self.P @ end[b] * CMU_UNIT_TO_M).z for b in ("lfoot", "ltoes", "rfoot", "rtoes")))
			lows.sort()
			self._ground = lows[int(len(lows) * 0.05)]
		return self._ground

	def sample(self, start, end):
		"""Source frames resampled to 30 fps between AMC frame indices start..end (inclusive), as (rot, root_pos) in Blender basis."""
		step = self.fps_in / FPS_OUT
		out = []
		t = float(start)
		while t <= end + 1e-6:
			i = int(t)
			out.append(self._at(min(i, len(self.frames) - 1)))
			t += step
		return out

	def _at(self, index):
		rot, end = fk(self.bones, self.frames[index])
		Pt = self.P.transposed()
		return {k: self.P @ m @ Pt for k, m in rot.items()}, self.P @ end["root"] * CMU_UNIT_TO_M

	def speed_profile(self, window=0.5):
		"""Per-window horizontal root speed (m/s, source scale), root height and travel heading, for choosing frame ranges."""
		rows = []
		n = int(self.fps_in * window)
		for i in range(0, len(self.frames) - n, n):
			_, a = self._at(i)
			_, b = self._at(i + n)
			d = Vector((b.x - a.x, b.y - a.y, 0.0))
			rows.append((i, d.length / window, a.z, math.degrees(math.atan2(d.x, -d.y)) if d.length > 0.01 else float("nan")))
		return rows


def yaw_matrix(degrees):
	return Matrix.Rotation(math.radians(degrees), 3, "Z")


def heading_of_travel(samples):
	a, b = samples[0][1], samples[-1][1]
	d = Vector((b.x - a.x, b.y - a.y))
	return math.degrees(math.atan2(d.x, -d.y)) if d.length > 0.05 else None


def heading_of_hips(samples):
	"""Average facing from the root rotation: the rest facing is -Y in Blender basis."""
	acc = Vector((0.0, 0.0))
	for rot, _ in samples:
		f = rot["root"] @ Vector((0.0, -1.0, 0.0))
		acc += Vector((f.x, f.y))
	return math.degrees(math.atan2(acc.x, -acc.y))


def retarget(clip, target, samples, mode="grounded", yaw=None, speed_scale=None, keep_travel=False, crouch=None, pin=False, cancel_yaw=False,
		layer=None):
	"""Solve every sample onto the target rig. Returns (frames, natural_speed). frames: list of (basis quats, pelvis loc).
	mode: "grounded" pins the lowest foot to the floor every frame; "air" keeps the scaled source height (only prevents sinking)."""
	if yaw is None:
		travel = heading_of_travel(samples)
		yaw = travel if travel is not None else heading_of_hips(samples)
	Y = yaw_matrix(-yaw)  # turn the clip's heading onto -Y
	k = target.hip_height / clip.hip_height
	align = {}
	for tname, sname in MAP.items():
		d_t = (target.tail[tname] - target.head[tname]).normalized()
		if sname == "root":
			align[tname] = Matrix.Identity(3)
			continue
		d_s = clip.rest_dir[sname]
		align[tname] = d_t.rotation_difference(d_s).to_matrix()
	root0 = samples[0][1]
	n = len(samples)
	travel = (samples[-1][1] - root0)
	frames = []
	raw_offsets = []
	for i, (rot, root) in enumerate(samples):
		# turning clips used as in-place pivots: the game rotates the body, so the hips' own yaw is removed frame by frame
		Yi = yaw_matrix(-heading_of_hips([(rot, root)])) if cancel_yaw else Y
		world = {}
		for tname, sname in MAP.items():
			world[tname] = Yi @ rot[sname] @ align[tname] @ target.rest[tname]
		p = Yi @ (root - root0)
		if not keep_travel:
			lin = Y @ (travel * (i / max(1, n - 1)))
			p = p - Vector((lin.x, lin.y, 0.0))
		# vertical: the source root's height above the capture floor, relative to its standing height, scaled by leg length
		z = (root.z - clip.ground() - clip.root_standing) * k
		if mode == "airborne":  # physics moves the body in the air: keep only the shape (tuck, reach), not the arc
			z = 0.0
		offset = Vector((p.x * k * 0.35, p.y * k * 0.35, z)) if not keep_travel else Vector((p.x * k, p.y * k, z))
		if crouch:
			world, offset = crouch_layer(target, world, offset, crouch["drop"], crouch["lean"], crouch.get("head"), crouch.get("elbow", 0.0))
		raw_offsets.append((world, offset))
	if layer is not None:  # authored pose layer on top of the capture (gestures), per frame
		raw_offsets = [layer(target, w, o, i, len(raw_offsets)) for i, (w, o) in enumerate(raw_offsets)]
	if pin:
		raw_offsets = pin_feet(target, raw_offsets)
	# grounding pass
	for world, offset in raw_offsets:
		basis, loc, W = target.solve(world, offset)
		pos = target.positions(W, offset)
		low = min(target.contact_heights(W, pos).values())
		if mode == "grounded":
			offset = offset + Vector((0.0, 0.0, -low))
		elif mode == "air" and low < 0.0:
			offset = offset + Vector((0.0, 0.0, -low))
		basis, loc, W = target.solve(world, offset)
		frames.append((basis, loc))
	natural = None
	if n > 1:
		horizontal = Vector((travel.x, travel.y)).length
		natural = horizontal * k / ((n - 1) / FPS_OUT)
	return frames, natural, yaw


def _swing(W, rest, d_rest_world, new_dir):
	"""Rotate world rotation W (bone with rest rotation `rest`) so the bone points along new_dir, keeping its twist."""
	current = (W @ rest.inverted() @ d_rest_world).normalized()
	return current.rotation_difference(new_dir.normalized()).to_matrix() @ W


def solve_leg(target, W, Wfull, hip, ankle, side):
	"""Two-bone IK in world space: thigh and calf of side reach nkle from hip with the knee forward; the foot and ball keep
	their captured world rotations (Wfull). Writes into W."""
	thigh, calf, foot = "thigh_" + side, "calf_" + side, "foot_" + side
	l1 = (target.head[calf] - target.head[thigh]).length
	l2 = (target.head[foot] - target.head[calf]).length
	to = ankle - hip
	d = max(1e-4, min(to.length, (l1 + l2) * 0.999))
	axis = to.normalized()
	a = (l1 * l1 - l2 * l2 + d * d) / (2.0 * d)
	h = math.sqrt(max(0.0, l1 * l1 - a * a))
	hint = Vector((0.0, -1.0, 0.15))  # knees forward (Elena faces -Y)
	hint = (hint - axis * hint.dot(axis)).normalized()
	knee = hip + axis * a + hint * h
	d_thigh = (target.head[calf] - target.head[thigh]).normalized()
	d_calf = (target.head[foot] - target.head[calf]).normalized()
	W[thigh] = _swing(Wfull[thigh], target.rest[thigh], d_thigh, knee - hip)
	W[calf] = _swing(Wfull[calf], target.rest[calf], d_calf, ankle - knee)
	W[foot] = Wfull[foot]
	W["ball_" + side] = Wfull["ball_" + side]


def pin_feet(target, frames_world):
	"""Keep both ankles at their average captured position (weight shifts move the hips, never the feet)."""
	positions = []
	for world, offset in frames_world:
		_, _, Wfull = target.solve(world, offset)
		positions.append(target.positions(Wfull, offset))
	pins = {}
	for side in ("l", "r"):
		pts = [p["foot_" + side] for p in positions]
		pins[side] = sum(pts, Vector()) / len(pts)
	out = []
	for (world, offset), pos in zip(frames_world, positions):
		W = dict(world)
		_, _, Wfull = target.solve(world, offset)
		for side in ("l", "r"):
			solve_leg(target, W, Wfull, pos["thigh_" + side], pins[side], side)
		out.append((W, offset))
	return out


def crouch_layer(target, world, offset, drop, lean_deg, head_deg=None, elbow_deg=0.0):
	"""Layer a crouch on a solved standing frame: pelvis lowered by `drop` (m) and moved back a little, spine pitched forward by
	`lean_deg` (spread over the three spine bones), head counter-pitched to keep looking ahead, then both legs re-solved with
	two-bone IK so each ankle keeps its captured position and the foot its captured orientation (knees stay over the toes)."""
	W = dict(world)
	_, _, Wfull = target.solve(world, offset)
	pos0 = target.positions(Wfull, offset)
	new_offset = offset + Vector((0.0, drop * 0.18, -drop))
	pitch = Matrix.Rotation(math.radians(lean_deg / 3.0), 3, "X")  # +X pitch leans the upper body forward (toward -Y)
	for bone in ("spine_01", "spine_02", "spine_03"):
		W[bone] = pitch @ W[bone]
		pitch = Matrix.Rotation(math.radians(lean_deg / 3.0), 3, "X") @ pitch
	lean = Matrix.Rotation(math.radians(lean_deg), 3, "X")
	for bone in ("neck_01", "head", "clavicle_l", "clavicle_r", "upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r", "hand_l", "hand_r"):
		W[bone] = lean @ W[bone]
	back = Matrix.Rotation(math.radians(-(head_deg if head_deg is not None else lean_deg * 0.8)), 3, "X")
	W["head"] = back @ W["head"]
	W["neck_01"] = Matrix.Rotation(math.radians(-(head_deg if head_deg is not None else lean_deg * 0.8) * 0.4), 3, "X") @ W["neck_01"]
	if elbow_deg:
		for side in ("l", "r"):
			W["lowerarm_" + side] = W["lowerarm_" + side] @ Matrix.Rotation(math.radians(elbow_deg), 3, "X")
			W["hand_" + side] = W["hand_" + side] @ Matrix.Rotation(math.radians(elbow_deg), 3, "X")
	_, _, Wtmp = target.solve(W, new_offset)
	pos1 = target.positions(Wtmp, new_offset)
	for side in ("l", "r"):
		solve_leg(target, W, Wfull, pos1["thigh_" + side], pos0["foot_" + side], side)
	return W, new_offset


def _frame(primary, secondary):
	"""Orthonormal 3x3 whose columns are primary, the part of secondary perpendicular to it, and their cross product."""
	a = primary.normalized()
	b = (secondary - a * secondary.dot(a)).normalized()
	return Matrix((a, b, a.cross(b))).transposed()


def arm_to(target, W, Wfull, offset, side, wrist, pole, dorsal_up=None, weight=1.0):
	"""Two-bone IK for one arm: the wrist reaches `wrist` with the elbow toward `pole`. If `dorsal_up` is given, the
	forearm is rolled so its rest lateral (dorsal) side faces that world direction (e.g. a wrist display facing the eyes);
	the hand follows the forearm. `weight` blends from the captured pose (0) to the solved pose (1). Writes into W."""
	up_b, low_b, hand_b = "upperarm_" + side, "lowerarm_" + side, "hand_" + side
	pos = target.positions(Wfull, offset)
	shoulder = pos[up_b]
	l1 = (target.head[low_b] - target.head[up_b]).length
	l2 = (target.head[hand_b] - target.head[low_b]).length
	to = wrist - shoulder
	d = max(1e-4, min(to.length, (l1 + l2) * 0.999))
	axis = to.normalized()
	a = (l1 * l1 - l2 * l2 + d * d) / (2.0 * d)
	h = math.sqrt(max(0.0, l1 * l1 - a * a))
	hint = (pole - shoulder)
	hint = (hint - axis * hint.dot(axis)).normalized()
	elbow = shoulder + axis * a + hint * h
	d_up = (target.head[low_b] - target.head[up_b]).normalized()
	d_low = (target.head[hand_b] - target.head[low_b]).normalized()
	solved_up = _swing(Wfull[up_b], target.rest[up_b], d_up, elbow - shoulder)
	f = (wrist - elbow).normalized()
	if dorsal_up is not None:
		lateral = Vector((1.0, 0.0, 0.0)) if side == "l" else Vector((-1.0, 0.0, 0.0))
		rest_frame = _frame(d_low, lateral)
		goal_frame = _frame(f, dorsal_up)
		delta = goal_frame @ rest_frame.transposed()
		solved_low = delta @ target.rest[low_b]
		solved_hand = delta @ target.rest[hand_b]
	else:
		solved_low = _swing(Wfull[low_b], target.rest[low_b], d_low, wrist - elbow)
		solved_hand = solved_low @ (target.rest[low_b].inverted() @ target.rest[hand_b])
	for bone, solved in ((up_b, solved_up), (low_b, solved_low), (hand_b, solved_hand)):
		base = Wfull[bone].to_quaternion()
		W[bone] = base.slerp(solved.to_quaternion(), weight).to_matrix()


def look_layer(W, Wfull, pitch_deg, yaw_deg, weight=1.0):
	"""Head and neck turn (pitch forward/down, yaw to Elena's left): the neck takes 35 % and the head, whose world rotation
	must include the neck's, the whole turn."""
	for bone, share in (("neck_01", 0.35), ("head", 1.0)):
		r = Matrix.Rotation(math.radians(yaw_deg * share * weight), 3, "Z") @ Matrix.Rotation(math.radians(pitch_deg * share * weight), 3, "X")
		W[bone] = r @ W[bone]


def find_cycle(clip, start, end, min_len, max_len, bones=("lfemur", "rfemur", "ltibia", "rtibia", "lhumerus", "rhumerus")):
	"""Best loop [a, a+L) within [start, end] (AMC frames) minimising the pose difference between a and a+L."""
	cache = {}

	def pose(i):
		if i not in cache:
			rot, _ = fk(clip.bones, clip.frames[i])
			cache[i] = [rot[b].to_quaternion() for b in bones]
		return cache[i]

	best = (1e9, start, min_len)
	for a in range(start, end - min_len, 4):
		pa = pose(a)
		for length in range(min_len, max_len + 1, 2):
			b = a + length
			if b > end:
				break
			pb = pose(b)
			cost = sum(qa.rotation_difference(qb).angle for qa, qb in zip(pa, pb))
			if cost < best[0]:
				best = (cost, a, length)
	return best


def close_loop(frames, blend=6):
	"""Blend the last `blend` frames into the first ones so the loop has no pop, and append the first frame at the end."""
	n = len(frames)
	out = [(dict(b), loc.copy()) for b, loc in frames]
	for j in range(blend):
		w = (j + 1) / (blend + 1)
		i = n - blend + j
		src_b, src_l = out[i]
		dst_b, dst_l = frames[j]
		out[i] = ({k: src_b[k].slerp(dst_b[k], w * 0.5) for k in src_b}, src_l.lerp(dst_l, w * 0.5))
	out.append((dict(frames[0][0]), frames[0][1].copy()))
	return out


def write_action(rig, name, frames):
	"""Key the solved frames into a new action (rotation of every bone that moves, pelvis location)."""
	import bpy
	ad = rig.animation_data_create()
	action = bpy.data.actions.new(name)
	ad.action = action
	moving = set()
	for basis, _ in frames:
		for bone, q in basis.items():
			if q.angle > 1e-4:
				moving.add(bone)
	for pb in rig.pose.bones:
		pb.rotation_mode = "QUATERNION"
	for _pass in range(2):  # the first insertion into a new action records the evaluated value, the second overwrites it
		for i, (basis, loc) in enumerate(frames):
			for bone in moving:
				pb = rig.pose.bones[bone]
				pb.rotation_quaternion = basis[bone]
				pb.keyframe_insert("rotation_quaternion", frame=i + 1)
			pb = rig.pose.bones["pelvis"]
			pb.location = loc
			pb.keyframe_insert("location", frame=i + 1)
	ad.action = None
	action.use_fake_user = True
	return action
