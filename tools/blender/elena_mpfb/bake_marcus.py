"""UV layout, procedural-to-texture bake and GLB export of Marcus (spec: docs/art/MARCUS_MPFB_SPEC.md).

    blender --background --factory-startup --python tools/blender/elena_mpfb/bake_marcus.py -- \
        --repo D:/Projects/github/final-thaw --blend D:/Projects/evidence/final-thaw/marcus/marcus_outfit_v01.blend \
        --blend-dir D:/Projects/evidence/final-thaw/marcus [--samples 8]
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "..", "reference"))
sys.path.insert(0, os.path.join(HERE, ".."))

import bmesh  # noqa: E402
import bpy  # noqa: E402
import numpy as np  # noqa: E402

import garments  # noqa: E402
import face_paint  # noqa: E402
from bake_elena import cloth, limit_influences, set_materials, unwrap  # noqa: E402
from lab_blender_common import parse_args  # noqa: E402
from ref_common import bake_atlas, finalize_materials, proc_material, write_emissive_tres, write_pbr_tres  # noqa: E402

ASSET = "marcus_mpfb"
ATLAS = 2048
RECTS = {
	"Marcus_Base": (0.00, 0.50, 0.50, 1.00),
	"Marcus_Jacket": (0.50, 0.50, 1.00, 1.00),
	"Marcus_Knit": (0.00, 0.25, 0.25, 0.50),
	"Marcus_Trousers": (0.25, 0.25, 0.50, 0.50),
	"Marcus_Boots": (0.50, 0.25, 0.75, 0.50),
	"Marcus_Hair": (0.75, 0.375, 1.00, 0.50),
	"Marcus_Brow_L": (0.875, 0.3125, 1.00, 0.375),
	"Marcus_Brow_R": (0.875, 0.3125, 1.00, 0.375),
	"Marcus_Eye_L": (0.00, 0.125, 0.125, 0.25),
	"Marcus_Eye_R": (0.00, 0.125, 0.125, 0.25),
	"Marcus_Belt": (0.25, 0.125, 0.50, 0.25),
	"Marcus_Buckle": (0.50, 0.125, 0.625, 0.25),
	"Marcus_Pouch_0": (0.625, 0.125, 0.75, 0.25),
	"Marcus_Pouch_1": (0.625, 0.125, 0.75, 0.25),
	"Marcus_Radio": (0.25, 0.00, 0.375, 0.125),
	"Marcus_Antenna": (0.375, 0.00, 0.50, 0.125),
	"Marcus_Collar": (0.75, 0.125, 1.00, 0.25),
	"Marcus_Eye_L_LashUp": (0.875, 0.3125, 1.00, 0.375),
	"Marcus_Eye_L_LashLo": (0.875, 0.3125, 1.00, 0.375),
	"Marcus_Eye_R_LashUp": (0.875, 0.3125, 1.00, 0.375),
	"Marcus_Eye_R_LashLo": (0.875, 0.3125, 1.00, 0.375),
}
SCREEN = "Marcus_RadioScreen"  # own emissive material, not in the atlas
HAND_BONES = ("hand_", "index_", "middle_", "pinky_", "ring_", "thumb_")


def make_materials():
	return {
		"orange": cloth("jacket_orange", "B5622B", rough=0.55, rough_var=0.18, weave=0.15, bump=0.35, bump_scale=90.0, dirt=0.6,
			edge_color="D9935C", edge_amount=0.4, edge_radius=0.01, grime_height=1.0, grime=0.5, stain=0.3),
		"red": cloth("jacket_red", "8A3A32", rough=0.55, rough_var=0.18, weave=0.15, bump=0.35, bump_scale=90.0, dirt=0.6,
			edge_color="B25C50", edge_amount=0.4, edge_radius=0.01, grime_height=1.0, grime=0.5, stain=0.3),
		"lining": cloth("jacket_lining", "3E4236", rough=0.9, weave=0.8, bump=0.6, bump_scale=170.0, grime=0.2),
		"knit": cloth("knit", "202325", rough=0.92, weave=0.85, bump=0.7, bump_scale=190.0, grime=0.1),
		"trousers": cloth("trousers", "32362F", rough=0.88, weave=0.5, bump_scale=120.0, grime_height=0.9, grime=0.7, stain=0.4),
		"boot": proc_material("boot", base="4A3B2B", rough=0.5, rough_var=0.25, edge_color="7A6448", edge_amount=0.5, edge_radius=0.006,
			dirt=0.75, dirt_color="1E1A14", ao_distance=0.04, stain=0.5, mottle=0.35, scale=14.0, bump=0.4, bump_scale=110.0,
			grime_height=0.35, grime=0.9, scratch=0.6, scratch_scale=16.0),
		"glove": proc_material("glove", base="5A4630", rough=0.6, rough_var=0.2, edge_color="86704D", edge_amount=0.4, edge_radius=0.004,
			dirt=0.6, dirt_color="1E1A14", ao_distance=0.02, stain=0.4, mottle=0.35, scale=22.0, bump=0.3, bump_scale=140.0, scratch=0.4),
		"skin": proc_material("skin", base="C79A7E", rough=0.55, rough_var=0.18, dirt=0.4, dirt_color="4E2B24", ao_distance=0.025,
			mottle=0.25, scale=26.0, bump=0.05, bump_scale=140.0),
		"lips": proc_material("lips", base="9A6258", rough=0.45, rough_var=0.1, dirt=0.2, mottle=0.1, scale=30.0, bump=0.1),
		"hair": proc_material("hair", base="15110F", rough=0.66, rough_var=0.15, edge_color="3A2E27", edge_amount=0.4, edge_radius=0.01,
			dirt=0.4, ao_distance=0.04, mottle=0.45, scale=36.0, bump=0.45, bump_scale=420.0),
		"webbing": cloth("webbing", "4A4B3F", rough=0.85, weave=0.7, bump_scale=200.0, grime=0.5, edge_color="6C6D5C", edge_amount=0.3),
		"pouch": cloth("pouch", "5A5A48", rough=0.85, weave=0.6, bump_scale=150.0, grime=0.6, edge_color="7C7C66", edge_amount=0.35),
		"device": proc_material("device", base="15181A", rough=0.4, rough_var=0.2, edge_color="4A5256", edge_amount=0.6, edge_radius=0.003,
			dirt=0.5, ao_distance=0.02, mottle=0.3, scale=30.0, bump=0.2, bump_scale=200.0),
		"steel": proc_material("steel", base="777E82", rough=0.4, rough_var=0.25, metal=0.85, edge_color="C3C8CA", edge_amount=0.5,
			edge_radius=0.003, edge_metal=0.1, dirt=0.6, ao_distance=0.02, stain=0.3, mottle=0.3, scale=24.0, bump=0.2, bump_scale=230.0,
			scratch=0.4, scratch_scale=26.0),
		"eye": face_paint.eye_material(iris=("6A4B2E", "3A281A")),
	}


def add_stubble(skin, top):
	"""Dark speckled beard shadow on the lower face, mixed into the skin base colour by object-space height."""
	nodes, links = skin.node_tree.nodes, skin.node_tree.links
	bsdf = next(n for n in nodes if n.type == "BSDF_PRINCIPLED")
	socket = bsdf.inputs["Base Color"]
	source = socket.links[0].from_socket
	coord = nodes.new("ShaderNodeTexCoord")
	sep = nodes.new("ShaderNodeSeparateXYZ")
	links.new(coord.outputs["Object"], sep.inputs[0])

	def ramp(inp, lo, hi):
		node = nodes.new("ShaderNodeMapRange")
		node.clamp = True
		node.inputs["From Min"].default_value = lo
		node.inputs["From Max"].default_value = hi
		links.new(inp, node.inputs["Value"])
		return node.outputs["Result"]

	def mul(a, b):
		node = nodes.new("ShaderNodeMath")
		node.operation = "MULTIPLY"
		links.new(a, node.inputs[0])
		links.new(b, node.inputs[1])
		return node.outputs[0]

	up = ramp(sep.outputs["Z"], top - 0.262, top - 0.235)
	down = ramp(sep.outputs["Z"], top - 0.160, top - 0.172)  # 1 below the nose, 0 above
	front = ramp(sep.outputs["Y"], 0.04, 0.01)  # 1 on the face, 0 behind the ears
	region = mul(mul(up, down), front)
	noise = nodes.new("ShaderNodeTexNoise")
	noise.inputs["Scale"].default_value = 900.0
	noise.inputs["Detail"].default_value = 2.0
	links.new(coord.outputs["Object"], noise.inputs["Vector"])
	speckle = ramp(noise.outputs["Fac"], 0.42, 0.62)
	factor = mul(region, speckle)
	strong = nodes.new("ShaderNodeMath")
	strong.operation = "MULTIPLY"
	strong.inputs[1].default_value = 0.75
	links.new(factor, strong.inputs[0])
	mix = nodes.new("ShaderNodeMixRGB")
	mix.inputs["Color2"].default_value = (0.045, 0.032, 0.028, 1.0)
	links.new(strong.outputs[0], mix.inputs["Fac"])
	links.new(source, mix.inputs["Color1"])
	links.new(mix.outputs["Color"], socket)


def assign_jacket(jacket, rig):
	"""0 orange body, 1 dark-red yoke / upper arms / elbow patches, 2 olive collar lining."""
	shoulder = (rig.matrix_world @ rig.data.bones["upperarm_l"].head_local)
	elbow = (rig.matrix_world @ rig.data.bones["lowerarm_l"].head_local)
	head = (rig.matrix_world @ rig.data.bones["head"].head_local)
	collar_top = head.z + 0.035
	chest_line = shoulder.z - 0.02
	count = [0, 0, 0]
	for poly in jacket.data.polygons:
		c = poly.center
		ax = abs(c.x)
		sh = np.linalg.norm(np.array([ax - abs(shoulder.x), c.y - shoulder.y, c.z - shoulder.z]))
		el = np.linalg.norm(np.array([ax - abs(elbow.x), c.y - elbow.y, c.z - elbow.z]))
		if c.z > collar_top - 0.02:
			index = 2
		elif (c.z > chest_line and ax < 0.20) or sh < 0.11 or (el < 0.085 and c.y > elbow.y - 0.015):
			index = 1
		else:
			index = 0
		poly.material_index = index
		count[index] += 1
	print("[bake] jacket faces orange/red/lining:", count)


def assign_gloves(body):
	dom = garments.dominant_bones(body)
	lips = body.vertex_groups.get("lips")
	lip_v = {v.index for v in body.data.vertices if lips and any(g.group == lips.index and g.weight > 0.5 for g in v.groups)}
	for poly in body.data.polygons:
		verts = poly.vertices
		if sum(1 for i in verts if (dom[i] or "").startswith(HAND_BONES)) >= 3:
			poly.material_index = 2
		elif sum(1 for i in verts if i in lip_v) >= 3:
			poly.material_index = 1
		else:
			poly.material_index = 0


def main():
	options = {"repo": None, "blend": None, "blend-dir": None, "samples": "8"}
	parse_args(options)
	repo = os.path.abspath(options["repo"])
	tex_dir = os.path.join(repo, "assets", "textures", "lab_ref")
	mat_dir = os.path.join(repo, "assets", "materials", "lab_ref")
	glb_path = os.path.join(repo, "assets", "models", "lab_ref", "ref_marcus_mpfb.glb")
	bpy.ops.wm.open_mainfile(filepath=options["blend"])
	objs = {name: bpy.data.objects[name] for name in RECTS}
	rig = bpy.data.objects["Marcus_Base.rig"]
	mats = make_materials()

	set_materials(objs["Marcus_Jacket"], [mats["orange"], mats["red"], mats["lining"]])
	assign_jacket(objs["Marcus_Jacket"], rig)
	top_z = max(v.co.z for v in objs["Marcus_Base"].data.vertices)
	add_stubble(mats["skin"], top_z)
	face_paint.paint_face(mats["skin"], top_z, blush=0.10, brow_shadow=0.35, eye_bags=0.45)
	set_materials(objs["Marcus_Base"], [mats["skin"], mats["lips"], mats["glove"]])
	assign_gloves(objs["Marcus_Base"])
	for name, mat in (("Knit", "knit"), ("Trousers", "trousers"), ("Boots", "boot"), ("Hair", "hair"), ("Brow_L", "hair"), ("Brow_R", "hair"),
			("Eye_L", "eye"), ("Eye_R", "eye"), ("Belt", "webbing"), ("Buckle", "steel"), ("Pouch_0", "pouch"), ("Pouch_1", "pouch"),
			("Radio", "device"), ("Antenna", "device"), ("Collar", "orange"), ("Eye_L_LashUp", "hair"),
			("Eye_L_LashLo", "hair"), ("Eye_R_LashUp", "hair"), ("Eye_R_LashLo", "hair")):
		set_materials(objs["Marcus_" + name], [mats[mat]])
	for name, rect in RECTS.items():
		unwrap(objs[name], rect, keep_default=name in ("Marcus_Eye_L", "Marcus_Eye_R"))
	bpy.context.view_layer.update()

	bake_list = list(objs.values())
	bake_atlas(bake_list, ASSET, ATLAS, tex_dir, samples=int(options["samples"]), margin=10)
	finalize_materials(bake_list, ASSET)
	cards = bpy.data.objects.get("Marcus_HairCards")
	if cards:
		cards.data.materials.clear()
		cards.data.materials.append(bpy.data.materials.new("marcus_hair_cards"))
	screen = bpy.data.objects[SCREEN]
	screen.data.materials.clear()
	screen.data.materials.append(bpy.data.materials.new("marcus_radio_screen"))
	write_pbr_tres(os.path.join(mat_dir, ASSET + ".tres"), ASSET, "res://assets/textures/lab_ref")
	write_emissive_tres(os.path.join(mat_dir, "marcus_radio_screen.tres"), "marcus_radio_screen", "2A1A06", "E8932A", 1.8)

	meshes = [o for o in bpy.data.objects if o.type == "MESH"]
	limit_influences(meshes)
	bpy.ops.object.select_all(action="DESELECT")
	for obj in meshes + [rig]:
		obj.select_set(True)
	os.makedirs(os.path.dirname(glb_path), exist_ok=True)
	bpy.ops.export_scene.gltf(filepath=glb_path, export_format="GLB", use_selection=True, export_yup=True, export_skins=True,
		export_apply=False, export_materials="EXPORT", export_image_format="NONE")
	print("[bake] -> " + glb_path)
	if options.get("blend-dir"):
		path = os.path.join(os.path.abspath(options["blend-dir"]), "marcus_baked.blend")
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


if __name__ == "__main__":
	main()
