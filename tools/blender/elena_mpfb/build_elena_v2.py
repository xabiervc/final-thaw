"""Elena v2 assembly: MakeHuman CC0 eyes, eyebrows, eyelashes and hair fitted to the v08 outfit, MakeHuman skin UVs kept.

    blender -b --python tools/blender/elena_mpfb/build_elena_v2.py -- --src <elena_mpfb_outfit_v08.blend>
        --mh D:/Projects/external_assets/makehuman/system --out <dir>/elena_v2_assembled.blend [--hair ponytail01]

Why: the v1 head used procedural face paint, sphere eyes, box brows and hand-built hair cards; at the gameplay camera the face read as
a mannequin and the hair as a dome (2026-10-15 baseline captures). MakeHuman's system assets are CC0 (makehumancommunity.org asset
packs, "MakeHuman system assets", 2026-10-15) and are authored for exactly this base mesh, so they fit and skin correctly.

How: the shipped body was stripped to head, neck and hands (build_finalize.py), so MakeHuman proxies cannot be fitted to it (their
reference vertices include the hair helper). A full MPFB human is rebuilt with the same macro and face targets as build_base.py (read
from that file, so the two never drift), the assets are fitted and rigged on it, then moved to the shipped rig (same 53-bone
`game_engine` skeleton, same bone names) and the temporary human is deleted. The fit is checked against the v1 eye centres.
"""
import ast
import math
import os
import sys

import bpy
from mathutils import Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
from lab_blender_common import parse_args  # noqa: E402

OLD_HEAD_PARTS = ("Elena_Eye_L", "Elena_Eye_R", "Elena_Eye_L_LashUp", "Elena_Eye_L_LashLo", "Elena_Eye_R_LashUp",
	"Elena_Eye_R_LashLo", "Elena_Brow_L", "Elena_Brow_R", "Elena_Hair", "Elena_HairCards", "Elena_Ponytail")
# Face refinements toward elena_vast_concept.png, on top of build_base.FACE (2026-10-15 review of the v1 head against the concept:
# the mouth read small with thin lips, the lower face round and short). Only head-region targets: the neck and collar fit is unchanged.
FACE_V2 = {
	"mouth/mouth-scale-horiz-incr": 0.2, "mouth/mouth-upperlip-volume-incr": 0.35, "mouth/mouth-lowerlip-volume-incr": 0.25,
	"mouth/mouth-cupidsbow-incr": 0.3, "head/head-scale-vert-incr": 0.1, "chin/chin-height-incr": 0.2,
	"nose/nose-scale-vert-incr": 0.12, "nose/nose-hump-decr": 0.15, "cheek/l-cheek-inner-decr": 0.2, "cheek/r-cheek-inner-decr": 0.2,
	"eyebrows/eyebrows-trans-down": 0.1,
}
# ponytail01 hangs to the shoulder blades and would cut through the backpack and collar; the concept wears it low and short.
PONYTAIL_TIE_Z = 1.53
PONYTAIL_KEEP = 0.6
ASSETS = (  # (asset folder, file stem, MPFB asset type, object name in the export)
	("eyes/low-poly", "low-poly", "Eyes", "Elena_Eyes"),
	("eyebrows/eyebrow001", "eyebrow001", "Eyebrows", "Elena_Eyebrows"),
	("eyelashes/eyelashes02", "eyelashes02", "Eyelashes", "Elena_Eyelashes"),
)


def build_base_params():
	"""MACRO and FACE exactly as build_base.py defines them (literal dicts in that file)."""
	tree = ast.parse(open(os.path.join(HERE, "build_base.py"), encoding="utf-8").read())
	found = {}
	for node in tree.body:
		if isinstance(node, ast.Assign) and isinstance(node.targets[0], ast.Name) and node.targets[0].id in ("MACRO", "FACE", "TARGET_HEIGHT"):
			found[node.targets[0].id] = ast.literal_eval(node.value)
	return found


def fresh_human(params):
	from bl_ext.blender_org.mpfb.services.humanservice import HumanService
	from bl_ext.blender_org.mpfb.services.targetservice import TargetService
	root = bpy.utils.user_resource("EXTENSIONS") + "/blender_org/mpfb/data/targets"
	macro = TargetService.get_default_macro_info_dict()
	macro.update(params["MACRO"])
	body = HumanService.create_human(mask_helpers=False, detailed_helpers=False, extra_vertex_groups=True, feet_on_ground=True,
		scale=0.1, macro_detail_dict=macro)
	body.name = "Fit_Base"
	bpy.context.view_layer.objects.active = body
	for key, weight in params["FACE"].items():
		folder, name = key.split("/")
		TargetService.load_target(body, f"{root}/{folder}/{name}.target.gz", weight=weight)
	rig = HumanService.add_builtin_rig(body, "game_engine", import_weights=True)
	rig.name = "Fit_Rig"
	# same correction as build_base._snap_rig_to_body: MPFB fits the rig before the feet-on-ground lift
	bpy.context.view_layer.update()
	depsgraph = bpy.context.evaluated_depsgraph_get()
	top = max(v.co.z for v in body.evaluated_get(depsgraph).data.vertices)
	dz = top - (rig.matrix_world @ rig.data.bones["head"].tail_local).z
	bpy.ops.object.select_all(action="DESELECT")
	bpy.context.view_layer.objects.active = rig
	rig.select_set(True)
	bpy.ops.object.mode_set(mode="EDIT")
	for bone in rig.data.edit_bones:
		bone.head.z += dz
		bone.tail.z += dz
	bpy.ops.object.mode_set(mode="OBJECT")
	apply_shape(body)
	return body, rig


def apply_shape(body):
	bpy.ops.object.select_all(action="DESELECT")
	bpy.context.view_layer.objects.active = body
	body.select_set(True)
	if body.data.shape_keys:
		bpy.ops.object.shape_key_remove(all=True, apply_mix=True)


def refine_face(fit_body, shipped_body, extra):
	"""Map every shipped head/neck/hand vertex to the fit body (same build, so distances are ~0), apply the extra targets to the
	fit body and copy the new positions back. The fit body is then the base the head assets are fitted to."""
	from bl_ext.blender_org.mpfb.services.targetservice import TargetService
	from mathutils.kdtree import KDTree
	root = bpy.utils.user_resource("EXTENSIONS") + "/blender_org/mpfb/data/targets"
	fit_world = [fit_body.matrix_world @ v.co for v in fit_body.data.vertices]
	tree = KDTree(len(fit_world))
	for i, co in enumerate(fit_world):
		tree.insert(co, i)
	tree.balance()
	mapping, worst = [], 0.0
	for v in shipped_body.data.vertices:
		co, index, dist = tree.find(shipped_body.matrix_world @ v.co)
		mapping.append(index)
		worst = max(worst, dist)
	print("[v2] shipped -> fit body mapping: %d verts, worst distance %.6f m" % (len(mapping), worst))
	if worst > 0.002:
		raise RuntimeError("the shipped body does not match a fresh build_base human; refusing to transfer the face")
	bpy.context.view_layer.objects.active = fit_body
	for key, weight in extra.items():
		folder, name = key.split("/")
		TargetService.load_target(fit_body, f"{root}/{folder}/{name}.target.gz", weight=weight)
	apply_shape(fit_body)
	inverse = shipped_body.matrix_world.inverted()
	for v, index in zip(shipped_body.data.vertices, mapping):
		v.co = inverse @ (fit_body.matrix_world @ fit_body.data.vertices[index].co)
	shipped_body.data.update()


def shorten_ponytail(hair):
	"""Pull the tail toward its tie: keep PONYTAIL_KEEP of its length below PONYTAIL_TIE_Z (vertices behind the skull only)."""
	inverse = hair.matrix_world.inverted()
	moved = 0
	for v in hair.data.vertices:
		co = hair.matrix_world @ v.co
		if co.z < PONYTAIL_TIE_Z and co.y > 0.04:
			co.z = PONYTAIL_TIE_Z + (co.z - PONYTAIL_TIE_Z) * PONYTAIL_KEEP
			co.y = co.y - (co.y - 0.06) * 0.25 * (PONYTAIL_TIE_Z - co.z) / 0.12
			v.co = inverse @ co
			moved += 1
	hair.data.update()
	print("[v2] ponytail shortened: %d verts" % moved)


def fit_asset(body, mh_root, folder, stem, asset_type):
	from bl_ext.blender_org.mpfb.services.humanservice import HumanService
	path = os.path.join(mh_root, folder, stem + ".mhclo")
	before = set(bpy.data.objects.keys())
	obj = HumanService.add_mhclo_asset(path, body, asset_type=asset_type, subdiv_levels=0, material_type="MAKESKIN")
	if obj is None:
		new = [bpy.data.objects[n] for n in bpy.data.objects.keys() if n not in before]
		obj = new[0]
	return obj


def world_centre(obj):
	depsgraph = bpy.context.evaluated_depsgraph_get()
	mesh = obj.evaluated_get(depsgraph).to_mesh()
	total = Vector()
	for v in mesh.vertices:
		total += obj.matrix_world @ v.co
	centre = total / max(1, len(mesh.vertices))
	obj.evaluated_get(depsgraph).to_mesh_clear()
	return centre


def move_to_rig(obj, rig, name):
	world = obj.matrix_world.copy()
	obj.parent = rig
	obj.parent_type = "OBJECT"
	obj.matrix_world = world
	for mod in obj.modifiers:
		if mod.type == "ARMATURE":
			mod.object = rig
	obj.name = name
	obj.data.name = name


def main():
	options = {"src": None, "mh": "D:/Projects/external_assets/makehuman/system", "out": None, "hair": "ponytail01"}
	parse_args(options)
	bpy.ops.wm.open_mainfile(filepath=options["src"])
	bpy.ops.preferences.addon_enable(module="bl_ext.blender_org.mpfb")
	rig = bpy.data.objects["Elena_Base.rig"]
	old_eye = world_centre(bpy.data.objects["Elena_Eye_L"]) if "Elena_Eye_L" in bpy.data.objects else None

	fit_body, fit_rig = fresh_human(build_base_params())
	refine_face(fit_body, bpy.data.objects["Elena_Base"], FACE_V2)
	fitted = []
	for folder, stem, asset_type, name in ASSETS + ((f"hair/{options['hair']}", options["hair"], "Hair", "Elena_HairMH"),):
		obj = fit_asset(fit_body, options["mh"], folder, stem, asset_type)
		fitted.append((obj, name))
		print("[v2] fitted %s -> %s (%d verts, groups %d)" % (stem, obj.name, len(obj.data.vertices), len(obj.vertex_groups)))

	# The shipped body and the fit body come from the same parameters: their eyes must coincide.
	eyes = fitted[0][0]
	new_eye = world_centre(eyes)
	if old_eye is not None:
		# MakeHuman eyes are one object (both eyes): compare the left half against the v1 left eye
		depsgraph = bpy.context.evaluated_depsgraph_get()
		mesh = eyes.evaluated_get(depsgraph).to_mesh()
		left = [eyes.matrix_world @ v.co for v in mesh.vertices if (eyes.matrix_world @ v.co).x > 0.0]
		left_centre = sum(left, Vector()) / max(1, len(left))
		eyes.evaluated_get(depsgraph).to_mesh_clear()
		print("[v2] eye centre v1 %s  v2-left %s  delta %.4f m" % (tuple(round(c, 4) for c in old_eye), tuple(round(c, 4) for c in left_centre),
			(left_centre - old_eye).length))
	for obj, name in fitted:
		move_to_rig(obj, rig, name)
	hair = bpy.data.objects["Elena_HairMH"]
	hair["mh_texture"] = os.path.join(options["mh"], "hair", options["hair"], options["hair"] + "_diffuse.png")
	hair["mh_asset"] = options["hair"]
	if options["hair"] == "ponytail01":
		shorten_ponytail(hair)
	for name in OLD_HEAD_PARTS:
		if name in bpy.data.objects:
			bpy.data.objects.remove(bpy.data.objects[name])
	for obj in list(bpy.data.objects):
		if obj.name.startswith("Fit_") or (obj.parent is not None and obj.parent.name == "Fit_Rig"):
			bpy.data.objects.remove(obj)
	if "Fit_Rig" in bpy.data.objects:
		bpy.data.objects.remove(bpy.data.objects["Fit_Rig"])
	for obj in bpy.data.objects:
		if obj.type == "MESH":
			print("[v2] %-22s verts %6d  parent %s" % (obj.name, len(obj.data.vertices), obj.parent.name if obj.parent else "-"))
	os.makedirs(os.path.dirname(os.path.abspath(options["out"])), exist_ok=True)
	bpy.ops.wm.save_as_mainfile(filepath=os.path.abspath(options["out"]))
	print("[v2] saved " + options["out"])


if __name__ == "__main__":
	main()
