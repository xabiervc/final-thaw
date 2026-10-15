"""Elena v2 animation set: CMU motion capture retargeted onto her rig (mocap_cmu.py) plus the v1 procedural gestures, exported
into assets/models/characters/elena/elena.glb with a clip table (elena_clips.json: loop flag and natural ground speed).

    blender -b --python tools/blender/elena_mpfb/animate_elena_v2.py -- --repo D:/Projects/github/final-thaw \
        --src D:/Projects/evidence/final-thaw/elena_v2/elena_v2_baked.blend --mocap D:/Projects/external_assets/cmu_mocap/amc \
        --proc D:/Projects/evidence/final-thaw/elena_mpfb/elena_mpfb_animated.blend --out D:/Projects/evidence/final-thaw/elena_v2

Why: the v1 locomotion was keyed procedurally (sine swings) and read stiff at gameplay distance (2026-10-15 baseline). Clip choices
(CMU trial, AMC frame range at 120 fps) were made from the speed/height profiles of each trial; loops are cut where the pose repeats
best (find_cycle) and closed with a short blend. Gestures without a suitable capture (scan, interact, alert, caught, climb, jump,
fall, land, crouch_idle) keep their v1 procedural keys until replaced.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, ".."))

import bpy  # noqa: E402

import mocap_cmu as M  # noqa: E402
from lab_blender_common import parse_args  # noqa: E402

# name: (trial, (first, last) AMC frames, loop (min, max) frames or None, mode, note[, options: crouch layer, pin feet])
# Elena's crouch is deep (she passes 1.1 m openings, capsule 1.05 m); the CMU sneaks are shallow or sideways (143_41 faces ~80
# degrees off its travel), so the crouched clips layer a crouch on captured gaits (mocap_cmu.crouch_layer, leg IK keeps the feet).
CROUCH = {"drop": 0.3, "lean": 24.0, "head": 18.0, "elbow": 22.0}
CLIPS = {
	"idle": ("77_02", (0, 930), (360, 760), "grounded", "subject 77 'careful actions': standing, alert weight shifts", {"pin": True}),
	"walk": ("35_01", (0, 357), (110, 160), "grounded", "subject 35 walk, steady 1.3 m/s"),
	"run": ("35_22", (0, 166), (70, 104), "air", "subject 35 run/jog, steady 3.5 m/s"),
	"sprint": ("143_01", (0, 99), (56, 84), "air", "subject 143 run, 6 m/s"),
	"crouch_walk": ("35_01", (0, 357), (110, 160), "grounded", "subject 35 walk with a layered crouch (pelvis -30 cm, IK legs)", {"crouch": CROUCH}),
	"crouch_idle": ("77_02", (0, 930), (360, 760), "grounded", "subject 77 standing with a layered crouch", {"crouch": CROUCH, "pin": True}),
	# running jump: take-off ~84, apex ~100, touch-down ~128, absorption to ~176 (root/feet height profile of 127_21)
	"jump": ("127_21", (68, 106), None, "airborne", "subject 127 run-jump-stop: push-off to just past the apex (0.32 s, the rise lasts ~0.2 s)"),
	"fall": ("127_21", (100, 124), None, "airborne", "subject 127 run-jump-stop: apex to touch-down, ping-pong loop", {"pingpong": True}),
	"land": ("127_21", (126, 178), None, "grounded", "subject 127 run-jump-stop: impact and knee absorption", {"hips": True}),
	# start and stop transitions (in place: the controller moves the body); subject 143 'start to run' / 'run to stop'
	"start": ("143_03", (112, 176), None, "grounded", "subject 143 start to run: the push-off steps"),
	"stop": ("143_02", (80, 150), None, "grounded", "subject 143 run to stop: last braking step and settle", {"hips": True}),
	# pivots: subject 69 'turn in place', 90 degrees, the hips' yaw removed (the game turns the body)
	"turn_left": ("69_16", (450, 600), None, "grounded", "subject 69 turn in place, 90 degrees left", {"cancel_yaw": True}),
	"turn_right": ("69_18", (330, 460), None, "grounded", "subject 69 turn in place, 90 degrees right", {"cancel_yaw": True}),
	# startled duck (a sudden threat): subject 77 'duck to avoid flying object', from standing to the duck
	"alert": ("77_09", (214, 268), None, "grounded", "subject 77 duck to avoid a flying object (startle)", {"pin": True, "hips": True}),
}
PROCEDURAL = ("climb", "scan", "interact", "caught")


def set_import_loops(import_path, table):
	"""Loop flags in Godot's import settings for the GLB (so the loop is part of the imported asset, not only of the game code)."""
	if not os.path.exists(import_path):
		print("[anim] no %s yet: import the project once, then rerun to write loop modes" % import_path)
		return
	text = open(import_path, encoding="utf-8").read()
	nl = chr(10)
	entries = ("," + nl).join('"%s": {%s"settings/loop_mode": %d%s}' % (n, nl, 1 if v["loop"] else 0, nl) for n, v in sorted(table.items()))
	block = "_subresources={" + nl + '"animations": {' + nl + entries + nl + "}" + nl + "}"
	start = text.index("_subresources=")
	end = text.index(nl + "gltf/", start) if (nl + "gltf/") in text[start:] else len(text)
	text = text[:start] + block + text[end:]
	with open(import_path, "w", encoding="utf-8", newline=nl) as handle:
		handle.write(text)
	print("[anim] loop modes written to " + import_path)


def main():
	options = {"repo": None, "src": None, "mocap": "D:/Projects/external_assets/cmu_mocap/amc", "proc": "", "out": None, "only": ""}
	parse_args(options)
	repo = os.path.abspath(options["repo"])
	glb_path = os.path.join(repo, "assets", "models", "characters", "elena", "elena.glb")
	table_path = os.path.join(repo, "assets", "models", "characters", "elena", "elena_clips.json")
	bpy.ops.wm.open_mainfile(filepath=options["src"])
	bpy.context.scene.render.fps = M.FPS_OUT
	rig = bpy.data.objects["Elena_Base.rig"]
	for action in list(bpy.data.actions):
		bpy.data.actions.remove(action)
	if rig.animation_data:
		rig.animation_data.action = None
		for track in list(rig.animation_data.nla_tracks):
			rig.animation_data.nla_tracks.remove(track)
	for pb in rig.pose.bones:
		pb.rotation_mode = "QUATERNION"
		pb.rotation_quaternion = (1.0, 0.0, 0.0, 0.0)
		pb.location = (0.0, 0.0, 0.0)
	bpy.context.view_layer.update()

	target = M.TargetRig(rig)
	table = {}
	only = [c for c in options["only"].split(",") if c]
	for name, spec in CLIPS.items():
		trial, (first, last), loop, mode, note = spec[:5]
		extra = spec[5] if len(spec) > 5 else {}
		if only and name not in only:
			continue
		subject = trial.split("_")[0]
		clip = M.Clip(os.path.join(options["mocap"], subject + ".asf"), os.path.join(options["mocap"], trial + ".amc"))
		if loop:
			cost, a, length = M.find_cycle(clip, first, last, loop[0], loop[1])
			samples = clip.sample(a, a + length)
			frames, speed, yaw = M.retarget(clip, target, samples, mode=mode, crouch=extra.get("crouch"), pin=extra.get("pin", False))
			frames = M.close_loop(frames[:-1])
			print("[anim] %-12s %s cycle %d..%d (%.2fs, cost %.2f) yaw %.0f speed %.2f m/s" % (name, trial, a, a + length, length / 120.0,
				cost, yaw, speed or 0.0))
		else:
			samples = clip.sample(first, last)
			facing = M.heading_of_hips(samples) if extra.get("hips") else None  # clips that barely travel face where the hips face
			frames, speed, yaw = M.retarget(clip, target, samples, mode=mode, yaw=facing, crouch=extra.get("crouch"), pin=extra.get("pin", False),
				cancel_yaw=extra.get("cancel_yaw", False))
			if extra.get("pingpong"):
				frames = frames + frames[-2::-1]
			a, length = first, last - first
			print("[anim] %-12s %s %d..%d yaw %.0f" % (name, trial, first, last, yaw))
		M.write_action(rig, name, frames)
		table[name] = {"loop": bool(loop) or bool(extra.get("pingpong")), "speed": round(speed, 3) if (speed and loop) else 0.0, "frames": len(frames),
			"source": "CMU %s frames %d-%d" % (trial, a, a + length), "note": note}

	if options["proc"]:
		with bpy.data.libraries.load(options["proc"], link=False) as (src, dst):
			dst.actions = [n for n in src.actions if n in PROCEDURAL]
		for action in bpy.data.actions:
			action.use_fake_user = True
			if action.name in PROCEDURAL:
				table.setdefault(action.name, {"loop": action.name == "fall", "speed": 0.0,
					"source": "procedural (animate_elena.py v1)"})
	# NLA tracks so every action is exported (ACTIONS mode also does, the tracks make the .blend reviewable)
	ad = rig.animation_data_create()
	for action in bpy.data.actions:
		track = ad.nla_tracks.new()
		track.name = action.name
		track.strips.new(action.name, 1, action).name = action.name
	for pb in rig.pose.bones:
		pb.rotation_quaternion = (1.0, 0.0, 0.0, 0.0)
		pb.location = (0.0, 0.0, 0.0)
	meshes = [o for o in bpy.data.objects if o.type == "MESH"]
	bpy.ops.object.select_all(action="DESELECT")
	for obj in meshes + [rig]:
		obj.select_set(True)
	bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB", use_selection=True, export_yup=True, export_skins=True,
		export_apply=False, export_materials="EXPORT", export_image_format="NONE", export_animations=True,
		export_animation_mode="ACTIONS", export_force_sampling=True, export_optimize_animation_size=False)
	with open(table_path, "w", encoding="utf-8", newline="\n") as handle:
		json.dump(table, handle, indent=1, sort_keys=True)
		handle.write("\n")
	print("[anim] -> %s (%d actions)" % (glb_path, len(bpy.data.actions)))
	set_import_loops(glb_path + ".import", table)
	bpy.ops.wm.save_as_mainfile(filepath=os.path.join(os.path.abspath(options["out"]), "elena_v2_animated.blend"))


if __name__ == "__main__":
	main()
