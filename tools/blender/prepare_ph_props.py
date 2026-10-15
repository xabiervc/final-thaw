"""Poly Haven CC0 props (D:/Projects/external_assets/polyhaven/models_1k, official API) -> game-ready GLBs in assets/models/props/ph.

    blender -b --factory-startup --python tools/blender/prepare_ph_props.py -- --repo D:/Projects/github/final-thaw [--only a,b]

Per prop: all meshes joined into one object (materials kept), transforms applied, pivot at the bottom centre, decimated to its
triangle budget (docs/art/ASSET_PRODUCTION_BIBLE.md: standard props <= 2k, hero props <= 10k), textures downscaled and
embedded as JPEG/PNG. Provenance (author, licence) is copied into the GLB's extras and recorded in docs/art/PROVENANCE.md.
"""
import json
import os
import sys

import bpy
from mathutils import Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lab_blender_common import parse_args  # noqa: E402

SRC = "D:/Projects/external_assets/polyhaven/models_1k"
# asset: (triangle budget, texture size)
PROPS = {
	"hanging_industrial_lamp": (3000, 512),
	"caged_hanging_light": (3000, 512),
	"mounted_fluorescent_lights": (1500, 512),
	"industrial_wall_lamp": (1500, 512),
	"power_box_01": (2500, 512),
	"worn_metal_rack": (2500, 512),
	"metal_office_desk": (2500, 1024),
	"metal_tool_chest": (2500, 512),
	"tool_cart": (3000, 512),
	"industrial_storage_cart": (3000, 512),
	"Barrel_02": (1500, 512),
	"plastic_crate_02": (1500, 512),
	"wooden_crate_01": (1500, 512),
	"cardboard_box_01": (800, 512),
	"industrial_microscope": (2500, 512),
	"retro_multimeter": (1500, 512),
	"clipboard": (500, 512),
	"classic_laptop": (2500, 512),
	"portable_generator": (3500, 512),
	"ladder_sectioned_01": (2500, 512),
	"hand_truck": (2500, 512),
	"cement_bag": (800, 512),
	"overhead_crane": (10000, 1024),
	"utility_box_02": (2500, 512),
	"security_camera_01": (2000, 512),
	"exterior_aircon_unit": (3000, 512),
	"water_manhole_cover": (1500, 512),
	"metal_stool_02": (1500, 512),
	"SchoolChair_01": (1500, 512),
	"concrete_road_barrier": (2500, 512),
	"office_notepads": (700, 512),
}


def prepare(asset, budget, tex_size, out_dir, manifest):
	for obj in list(bpy.data.objects):
		bpy.data.objects.remove(obj)
	for img in list(bpy.data.images):
		bpy.data.images.remove(img)
	folder = os.path.join(SRC, asset)
	gltf = [f for f in os.listdir(folder) if f.endswith(".gltf")][0]
	bpy.ops.import_scene.gltf(filepath=os.path.join(folder, gltf))
	meshes = [o for o in bpy.data.objects if o.type == "MESH"]
	for o in bpy.data.objects:
		if o.type != "MESH":
			o.select_set(False)
	bpy.ops.object.select_all(action="DESELECT")
	for o in meshes:
		o.select_set(True)
	bpy.context.view_layer.objects.active = meshes[0]
	# keep world transforms when unparenting from the glTF root
	for o in meshes:
		world = o.matrix_world.copy()
		o.parent = None
		o.matrix_world = world
	bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
	if len(meshes) > 1:
		bpy.ops.object.join()
	obj = bpy.context.view_layer.objects.active
	obj.name = asset
	for o in list(bpy.data.objects):
		if o != obj:
			bpy.data.objects.remove(o)
	tris = sum(len(p.vertices) - 2 for p in obj.data.polygons)
	if tris > budget:
		mod = obj.modifiers.new("decimate", "DECIMATE")
		mod.ratio = budget / tris
		mod.use_collapse_triangulate = True
		bpy.ops.object.modifier_apply(modifier="decimate")
	after = sum(len(p.vertices) - 2 for p in obj.data.polygons)
	# pivot at the bottom centre
	lo = Vector((min(v.co.x for v in obj.data.vertices), min(v.co.y for v in obj.data.vertices), min(v.co.z for v in obj.data.vertices)))
	hi = Vector((max(v.co.x for v in obj.data.vertices), max(v.co.y for v in obj.data.vertices), max(v.co.z for v in obj.data.vertices)))
	pivot = Vector(((lo.x + hi.x) * 0.5, (lo.y + hi.y) * 0.5, lo.z))
	for v in obj.data.vertices:
		v.co -= pivot
	for img in bpy.data.images:
		if img.size[0] > tex_size:
			img.scale(tex_size, tex_size)
	meta = manifest.get(asset, {})
	obj["source"] = "https://polyhaven.com/a/" + asset
	obj["license"] = "CC0 1.0"
	obj["authors"] = ", ".join((meta.get("authors") or {}).keys())
	path = os.path.join(out_dir, asset.lower() + ".glb")
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_yup=True, export_apply=True,
		export_materials="EXPORT", export_image_format="AUTO", export_extras=True, export_animations=False)
	size = hi - lo
	print("[ph] %-26s %6d -> %5d tris  %.2f x %.2f x %.2f m  %d KB" % (asset, tris, after, size.x, size.y, size.z, os.path.getsize(path) // 1024))
	return {"tris": after, "size": [round(size.x, 3), round(size.z, 3), round(size.y, 3)]}


def main():
	options = {"repo": None, "only": ""}
	parse_args(options)
	out_dir = os.path.join(os.path.abspath(options["repo"]), "assets", "models", "props", "ph")
	os.makedirs(out_dir, exist_ok=True)
	manifest = json.load(open(os.path.join(SRC, "manifest.json"), encoding="utf-8"))
	only = [a for a in options["only"].split(",") if a]
	table = {}
	table_path = os.path.join(out_dir, "props.json")
	if os.path.exists(table_path):
		table = json.load(open(table_path, encoding="utf-8"))
	for asset, (budget, tex) in PROPS.items():
		if only and asset not in only:
			continue
		info = prepare(asset, budget, tex, out_dir, manifest)
		meta = manifest.get(asset, {})
		info.update({"source": "https://polyhaven.com/a/" + asset, "license": "CC0 1.0",
			"authors": list((meta.get("authors") or {}).keys())})
		table[asset.lower()] = info
	with open(table_path, "w", encoding="utf-8", newline="\n") as handle:
		json.dump(table, handle, indent=1, sort_keys=True)
		handle.write("\n")


if __name__ == "__main__":
	main()
