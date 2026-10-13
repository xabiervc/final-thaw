"""Modulo de suelo de referencia 2 x 2 m (docs/art/LAB_REFERENCE_SCENE_SPEC.md).

    blender --background --factory-startup --python tools/blender/reference/build_ref_floor.py -- \
        --repo D:/Projects/github/final-thaw --blend-dir D:/Projects/evidence/final-thaw/lab-ref-source \
        [--variant drain|plain]

Cuatro losetas de epoxi biseladas con junta en cruz, placa de acero atornillada en el cruce, linea
de seguridad pintada y desgaste horneado. La variante `drain` (ref_floor) tiene ademas un sumidero
con rejilla (corte booleano real); `plain` (ref_floor_plain) no, para romper la repeticion.
Pivote: centro del modulo, cara superior de las losetas en y=0.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
from ref_common import (RefMesh, bake_atlas, common_args, export_glb, finalize_materials, proc_material,  # noqa: E402
	repo_paths, reset_scene, save_blend, select_only, smart_uv, triangle_count, world_bounds_godot, write_pbr_tres)

TILE = 0.96
TILE_CENTER = 0.5
TILE_THICK = 0.1
DRAIN_CENTER = (-0.5, 0.5)
DRAIN_SIZE = 0.5
TEXTURE_SIZE = 1024


def make_materials():
	return {
		"epoxy": proc_material("epoxy", base="5E696D", rough=0.58, rough_var=0.2, edge_color="9AA0A2", edge_amount=0.45,
			edge_radius=0.012, dirt=0.75, ao_distance=0.10, stain=0.16, mottle=0.12, scale=9.0, bump=0.4,
			bump_scale=150.0, wet=0.18, wet_height=0.05, scratch=0.45, scratch_scale=12.0),
		"joint": proc_material("joint", base="1F2326", rough=0.85, rough_var=0.1, dirt=0.5, mottle=0.25, scale=14.0, bump=0.2),
		"steel": proc_material("steel", base="737A7E", rough=0.42, rough_var=0.25, metal=0.85, edge_color="B8BDBF", edge_amount=0.5,
			edge_radius=0.006, edge_metal=0.1, dirt=0.6, ao_distance=0.05, stain=0.35, mottle=0.3, scale=18.0, bump=0.12),
		"rubber": proc_material("rubber", base="17191B", rough=0.8, rough_var=0.12, dirt=0.3, mottle=0.2, scale=22.0, bump=0.1),
		"paint": proc_material("paint", base="A9ADA8", rough=0.55, rough_var=0.3, edge_color="6F7473", edge_amount=0.9,
			edge_radius=0.004, dirt=0.65, ao_distance=0.04, stain=0.7, mottle=0.45, scale=26.0, bump=0.15),
	}


def build(mats, drain: bool, asset: str):
	parts = []
	for ix, iz in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
		if drain and (ix * TILE_CENTER, iz * TILE_CENTER) == DRAIN_CENTER:
			continue
		m = RefMesh("tile_%d_%d" % (ix, iz))
		m.box((TILE, TILE_THICK, TILE), (ix * TILE_CENTER, -TILE_THICK * 0.5, iz * TILE_CENTER), "epoxy", bevel=0.012, segments=3)
		parts.append(m.finish(mats, uv=False))
	sub = RefMesh("substrate")
	sub.box((2.0, 0.08, 2.0), (0.0, -0.06, 0.0), "joint")
	sub_obj = sub.finish(mats, uv=False)
	if drain: # loseta del sumidero y sustrato con corte booleano
		tile = RefMesh("tile_drain")
		tile.box((TILE, TILE_THICK, TILE), (DRAIN_CENTER[0], -TILE_THICK * 0.5, DRAIN_CENTER[1]), "epoxy", bevel=0.012, segments=3)
		tile_obj = tile.finish(mats, uv=False)
		cutter = RefMesh("cutter")
		cutter.box((DRAIN_SIZE, 0.2, DRAIN_SIZE), (DRAIN_CENTER[0], -0.03, DRAIN_CENTER[1]), "joint")
		cutter_obj = cutter.finish(mats, uv=False)
		for target in (tile_obj, sub_obj):
			modifier = target.modifiers.new("cut", "BOOLEAN")
			modifier.operation = "DIFFERENCE"
			modifier.object = cutter_obj
			modifier.solver = "EXACT"
			select_only(target)
			bpy.ops.object.modifier_apply(modifier="cut")
		bpy.data.objects.remove(cutter_obj, do_unlink=True)
		parts.append(tile_obj)
	parts.append(sub_obj)

	detail = RefMesh("detail")
	cx, cz = DRAIN_CENTER
	if drain:
		detail.box((DRAIN_SIZE, 0.012, DRAIN_SIZE), (cx, -0.095, cz), "rubber") # fondo del sumidero
		half = DRAIN_SIZE * 0.5 + 0.03
		for sign in (-1, 1): # marco de la rejilla
			detail.box((half * 2.0, 0.026, 0.05), (cx, 0.002, cz + sign * (half - 0.025)), "steel", bevel=0.004)
			detail.box((0.05, 0.026, half * 2.0 - 0.1), (cx + sign * (half - 0.025), 0.002, cz), "steel", bevel=0.004)
		for slat in range(9): # lamas
			detail.box((0.026, 0.022, DRAIN_SIZE), (cx + (slat - 4) * 0.05, -0.018, cz), "steel", bevel=0.003)
		detail.box((DRAIN_SIZE, 0.018, 0.03), (cx, -0.03, cz), "steel") # travesano
	detail.box((2.0, 0.016, 0.04), (0.0, -0.014, 0.0), "rubber") # relleno de goma de la junta en cruz
	detail.box((0.04, 0.016, 2.0), (0.0, -0.014, 0.0), "rubber")
	detail.box((0.2, 0.01, 0.2), (0.0, 0.002, 0.0), "steel", bevel=0.003) # placa del cruce
	for bx in (-0.07, 0.07):
		for bz in (-0.07, 0.07):
			detail.cyl((0.036, 0.012, 0.036), (bx, 0.01, bz), "steel", segs=6, bevel=0.002)
	detail.box((0.07, 0.003, 1.9), (0.82, 0.0015, 0.0), "paint", bevel=0.001) # linea de seguridad
	parts.append(detail.finish(mats, uv=False))

	select_only(parts[0])
	for obj in parts:
		obj.select_set(True)
	bpy.context.view_layer.objects.active = parts[0]
	bpy.ops.object.join()
	floor = bpy.context.view_layer.objects.active
	floor.name = asset
	smart_uv(floor, 0.002)
	return floor


def main():
	options = common_args({"variant": "drain"})
	drain = options["variant"] != "plain"
	asset = "ref_floor" if drain else "ref_floor_plain"
	paths = repo_paths(options)
	reset_scene()
	mats = make_materials()
	floor = build(mats, drain, asset)
	bpy.context.view_layer.update()
	print("[%s] tris=%d" % (asset, triangle_count([floor])))
	bake_atlas([floor], asset, TEXTURE_SIZE, paths["tex"], samples=int(options["samples"]))
	finalize_materials([floor], asset)
	write_pbr_tres(os.path.join(paths["mat"], asset + ".tres"), asset, paths["tex_res"])
	low, high = world_bounds_godot([floor])
	size = high - low
	print("[%s] size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (asset, size.x, size.y, size.z, low.x, low.y, low.z))
	print("[%s] -> %s" % (asset, export_glb([floor], os.path.join(paths["glb"], asset + ".glb"))))
	save_blend(options, asset + ".blend")


main()
