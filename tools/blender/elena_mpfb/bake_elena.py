"""UV layout, procedural-to-texture bake and GLB export of the MPFB Elena.

    blender --background --factory-startup --python tools/blender/elena_mpfb/bake_elena.py -- \
        --repo D:/Projects/github/final-thaw --blend D:/Projects/evidence/final-thaw/elena_mpfb/elena_mpfb_outfit_v04.blend \
        --blend-dir D:/Projects/evidence/final-thaw/elena_mpfb [--samples 12]

The input .blend is the finalized scene (build_base -> build_finalize). Everything except the backpack and the Aster is baked into one
2048 x 2048 albedo/normal/ORM atlas; the backpack and the Aster keep their existing `ref_elena` / `ref_elena_aster` materials.
"""

import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "reference"))
sys.path.insert(0, os.path.join(HERE, ".."))

import bmesh  # noqa: E402
import bpy  # noqa: E402
import numpy as np  # noqa: E402

from lab_blender_common import parse_args  # noqa: E402
from ref_common import bake_atlas, finalize_materials, hex_lin, proc_material, select_only, smart_uv, write_pbr_tres  # noqa: E402

ASSET = "elena_mpfb"
ATLAS = 2048
# atlas rectangles (u0, v0, u1, v1), origin bottom-left; shared rectangles overlap on purpose (mirrored parts share texels)
RECTS = {
	"Elena_Base": (0.00, 0.50, 0.50, 1.00),
	"Elena_Coat": (0.50, 0.50, 1.00, 1.00),
	"Elena_Knit": (0.00, 0.25, 0.25, 0.50),
	"Elena_Trousers": (0.25, 0.25, 0.50, 0.50),
	"Elena_Boots": (0.50, 0.25, 0.75, 0.50),
	"Elena_Hair": (0.75, 0.375, 1.00, 0.50),
	"Elena_Ponytail": (0.75, 0.3125, 0.875, 0.375),
	"Elena_Brow_L": (0.875, 0.3125, 1.00, 0.375),
	"Elena_Brow_R": (0.875, 0.3125, 1.00, 0.375),
	"Elena_Strap_L": (0.75, 0.25, 1.00, 0.3125),
	"Elena_Strap_R": (0.75, 0.25, 1.00, 0.3125),
	"Elena_Eye_L": (0.00, 0.125, 0.125, 0.25),
	"Elena_Eye_R": (0.00, 0.125, 0.125, 0.25),
	"Elena_Eye_L_LashUp": (0.875, 0.3125, 1.00, 0.375),
	"Elena_Eye_L_LashLo": (0.875, 0.3125, 1.00, 0.375),
	"Elena_Eye_R_LashUp": (0.875, 0.3125, 1.00, 0.375),
	"Elena_Eye_R_LashLo": (0.875, 0.3125, 1.00, 0.375),
}
FRONT_BIN = 0.03   # height bin (m) used to estimate the front edge position
FRONT_BAND = 0.024  # width (m) of the front piping band, measured inward from the open edge
CUFF_BAND = 0.018
HEM_Z = 0.93


def cloth(name, base, **kw):
	args = dict(rough=0.86, rough_var=0.12, dirt=0.55, ao_distance=0.05, stain=0.25, mottle=0.28, scale=9.0, bump=0.5,
		bump_scale=110.0, weave=0.55, grime_height=0.9, grime=0.45, scratch=0.0)
	args.update(kw)
	return proc_material(name, base=base, **args)


def eye_material():
	"""Sclera, brown iris and pupil from the angle to the eye's front axis (+Z of the sphere, object origin = eye centre)."""
	mat = bpy.data.materials.new("eye")
	mat.use_nodes = True
	nodes, links = mat.node_tree.nodes, mat.node_tree.links
	nodes.clear()
	coord = nodes.new("ShaderNodeTexCoord")
	norm = nodes.new("ShaderNodeVectorMath")
	norm.operation = "NORMALIZE"
	links.new(coord.outputs["Object"], norm.inputs[0])
	sep = nodes.new("ShaderNodeSeparateXYZ")
	links.new(norm.outputs["Vector"], sep.inputs[0])
	ramp = nodes.new("ShaderNodeValToRGB")
	stops = [(0.0, "D9D3C8"), (0.80, "D9D3C8"), (0.84, "6A4A33"), (0.93, "3F2A1C"), (0.955, "0A0807"), (1.0, "0A0807")]
	while len(ramp.color_ramp.elements) < len(stops):
		ramp.color_ramp.elements.new(0.5)
	for element, (position, color) in zip(ramp.color_ramp.elements, stops):
		element.position = position
		element.color = hex_lin(color)
	links.new(sep.outputs["Z"], ramp.inputs["Fac"])
	bsdf = nodes.new("ShaderNodeBsdfPrincipled")
	bsdf.inputs["Roughness"].default_value = 0.12
	links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
	metal = nodes.new("ShaderNodeValue")  # the atlas bake reads the metal channel from a node of this name
	metal.name = "metal_val"
	metal.outputs[0].default_value = 0.0
	out = nodes.new("ShaderNodeOutputMaterial")
	links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
	return mat


def make_materials():
	return {
		"coat": cloth("coat", "2A4A50", edge_color="4F7076", edge_amount=0.45, edge_radius=0.012, grime_height=1.15, grime=0.5),
		"piping": proc_material("piping", base="8EB1B1", rough=0.42, rough_var=0.15, edge_color="C4D8D6", edge_amount=0.35, edge_radius=0.004,
			dirt=0.5, ao_distance=0.03, stain=0.3, mottle=0.25, scale=20.0, bump=0.3, bump_scale=160.0),
		"knit": cloth("knit", "232628", rough=0.92, weave=0.85, bump=0.7, bump_scale=190.0, grime=0.1),
		"trousers": cloth("trousers", "30353A", rough=0.9, weave=0.4, bump_scale=130.0, grime_height=0.9, grime=0.65, stain=0.35),
		"boot": proc_material("boot", base="1D3234", rough=0.32, rough_var=0.22, edge_color="5C7572", edge_amount=0.5, edge_radius=0.006,
			dirt=0.65, ao_distance=0.04, stain=0.45, mottle=0.3, scale=14.0, bump=0.35, bump_scale=120.0, grime_height=0.35, grime=0.8,
			scratch=0.5, scratch_scale=16.0),
		"skin": proc_material("skin", base="D2A68E", rough=0.55, rough_var=0.18, dirt=0.35, dirt_color="5A2F2A", ao_distance=0.025,
			mottle=0.2, scale=26.0, bump=0.05, bump_scale=140.0),
		"lips": proc_material("lips", base="A5675F", rough=0.45, rough_var=0.1, dirt=0.2, mottle=0.1, scale=30.0, bump=0.1),
		"hair": proc_material("hair", base="241A17", rough=0.66, rough_var=0.15, edge_color="4A3A30", edge_amount=0.4, edge_radius=0.01,
			dirt=0.4, ao_distance=0.04, mottle=0.45, scale=36.0, bump=0.45, bump_scale=420.0),
		"strap": cloth("strap", "1B1E20", rough=0.85, weave=0.7, bump_scale=210.0, grime=0.3),
		"eye": eye_material(),
	}


def set_materials(obj, mats):
	obj.data.materials.clear()
	for mat in mats:
		obj.data.materials.append(mat)


def assign_coat_piping(coat):
	"""Piping as a clean band along the open front edge (edge x per height, median-filtered) plus the cuffs."""
	bm = bmesh.new()
	bm.from_mesh(coat.data)
	bm.verts.ensure_lookup_table()
	boundary = [v.co.copy() for v in bm.verts if any(e.is_boundary for e in v.link_edges)]
	front = [p for p in boundary if p.y < 0.02 and abs(p.x) < 0.14 and 0.55 < p.z < 1.47]
	bins = {}
	for p in front:
		bins.setdefault(round(p.z / FRONT_BIN), []).append(abs(p.x))
	edge_x = {k: float(np.median(v)) for k, v in bins.items()}
	keys = sorted(edge_x)
	cuffs = np.array([p[:] for p in boundary if abs(p.x) > 0.25], dtype=np.float32)
	count = 0
	for face in bm.faces:
		c = face.calc_center_median()
		near = False
		if c.y < 0.02 and 0.55 < c.z < 1.47 and keys:
			key = min(keys, key=lambda k: abs(k - c.z / FRONT_BIN))
			near = 0.0 <= abs(c.x) - edge_x[key] < FRONT_BAND
		if not near and len(cuffs):
			near = float(np.min(np.linalg.norm(cuffs - np.array(c[:], dtype=np.float32), axis=1))) < CUFF_BAND
		face.material_index = 1 if near else 0
		count += 1 if near else 0
	bm.to_mesh(coat.data)
	bm.free()
	print("[bake] coat piping faces: %d of %d" % (count, len(coat.data.polygons)))


def assign_lips(body):
	group = body.vertex_groups.get("lips")
	if not group:
		return
	lip_vertices = {v.index for v in body.data.vertices if any(g.group == group.index and g.weight > 0.5 for g in v.groups)}
	for poly in body.data.polygons:
		poly.material_index = 1 if sum(1 for i in poly.vertices if i in lip_vertices) >= 3 else 0


def fit_uv_to_rect(obj, rect):
	uv = obj.data.uv_layers.active.data
	xs = np.array([d.uv.x for d in uv])
	ys = np.array([d.uv.y for d in uv])
	margin = 0.004
	u0, v0, u1, v1 = rect
	scale = min((u1 - u0 - 2 * margin) / max(xs.max() - xs.min(), 1e-6), (v1 - v0 - 2 * margin) / max(ys.max() - ys.min(), 1e-6))
	for d in uv:
		d.uv.x = u0 + margin + (d.uv.x - xs.min()) * scale
		d.uv.y = v0 + margin + (d.uv.y - ys.min()) * scale


def unwrap(obj, rect, keep_default=False):
	if not keep_default:
		while obj.data.uv_layers:
			obj.data.uv_layers.remove(obj.data.uv_layers[0])
		obj.data.uv_layers.new(name="UVMap")
		smart_uv(obj, margin=0.004, angle=66.0)
	fit_uv_to_rect(obj, rect)


def limit_influences(objects):
	for obj in objects:
		if obj.vertex_groups:
			select_only(obj)
			bpy.ops.object.vertex_group_limit_total(group_select_mode="ALL", limit=4)


def main():
	options = {"repo": None, "blend": None, "blend-dir": None, "samples": "12"}
	parse_args(options)
	repo = os.path.abspath(options["repo"])
	tex_dir = os.path.join(repo, "assets", "textures", "lab_ref")
	mat_dir = os.path.join(repo, "assets", "materials", "lab_ref")
	glb_path = os.path.join(repo, "assets", "models", "lab_ref", "ref_elena_mpfb.glb")
	bpy.ops.wm.open_mainfile(filepath=options["blend"])
	objs = {name: bpy.data.objects[name] for name in RECTS}
	mats = make_materials()

	set_materials(objs["Elena_Coat"], [mats["coat"], mats["piping"]])
	assign_coat_piping(objs["Elena_Coat"])
	set_materials(objs["Elena_Base"], [mats["skin"], mats["lips"]])
	assign_lips(objs["Elena_Base"])
	for name, mat in (("Elena_Knit", "knit"), ("Elena_Trousers", "trousers"), ("Elena_Boots", "boot"), ("Elena_Hair", "hair"),
			("Elena_Ponytail", "hair"), ("Elena_Brow_L", "hair"), ("Elena_Brow_R", "hair"), ("Elena_Strap_L", "strap"),
			("Elena_Strap_R", "strap"), ("Elena_Eye_L", "eye"), ("Elena_Eye_R", "eye"),
			("Elena_Eye_L_LashUp", "hair"), ("Elena_Eye_L_LashLo", "hair"), ("Elena_Eye_R_LashUp", "hair"), ("Elena_Eye_R_LashLo", "hair")):
		set_materials(objs[name], [mats[mat]])
	for name, rect in RECTS.items():
		unwrap(objs[name], rect, keep_default=name in ("Elena_Eye_L", "Elena_Eye_R"))
	bpy.context.view_layer.update()

	bake_list = list(objs.values())
	bake_atlas(bake_list, ASSET, ATLAS, tex_dir, samples=int(options["samples"]), margin=10)
	finalize_materials(bake_list, ASSET)

	# the backpack and the Aster keep their existing materials (resolved by name in Godot)
	# the Aster screen shares the Aster's pivot: re-seat it on the Aster with an identity local transform
	from mathutils import Matrix
	screen, aster = bpy.data.objects["emit_aster"], bpy.data.objects["Aster"]
	screen.parent = aster
	screen.matrix_parent_inverse = Matrix.Identity(4)
	screen.location = (0.0, 0.0, 0.0)
	screen.rotation_euler = (0.0, 0.0, 0.0)
	for name, mat in (("Backpack", "ref_elena"), ("Aster", "ref_elena"), ("emit_aster", "ref_elena_aster")):
		obj = bpy.data.objects[name]
		obj.data.materials.clear()
		obj.data.materials.append(bpy.data.materials.new(mat))
	write_pbr_tres(os.path.join(mat_dir, ASSET + ".tres"), ASSET, "res://assets/textures/lab_ref")

	rig = bpy.data.objects["Elena_Base.rig"]
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
		path = os.path.join(os.path.abspath(options["blend-dir"]), "elena_mpfb_baked.blend")
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


if __name__ == "__main__":
	main()
