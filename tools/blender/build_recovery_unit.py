"""Facility recovery unit (the Phase 2 pursuer) — reproducible model, exported to assets/models/characters/recovery_unit.glb.

    blender --background --factory-startup --python tools/blender/build_recovery_unit.py -- --repo D:/Projects/github/final-thaw

Specification (docs/art/MASTER_ASSET_LIST.md, "Phases 1-2 asset register"): no concept art exists for the enemy, so the spec follows the
established narrative intent — an autonomous facility recovery/security machine, never a person, no face.
  * Scale: 1.95 m tall, footprint 0.95 x 1.10 m (fits the 0.42 m-radius gameplay capsule and the 1.3 m O3 aperture).
  * Silhouette: low tracked base, narrow upright chassis, a mast, and a wide sensor head whose horizontal visor ("Eye")
    shows where it is looking; two folded manipulators on the chassis sides. Reads as a machine from any angle.
  * Materials: industrial grey painted steel (unit_shell), dark rubber/steel (unit_dark), amber hazard paint
    (unit_warn), visor glass (unit_eye; its emission colour is driven by the game state in Godot).
  * Detail: bevelled edges, track guards, hub caps, panel seams; ~3-5 k triangles, no textures (flat PBR materials).
  * Animation: none (the game turns the whole visual); collision is the gameplay capsule, not this mesh.
  * Godot integration: front = +Z (eye side), origin at the floor centre; node "Eye" gets the state material.
Blender convention used here: front = -Y (exported as glTF +Z), Z up.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import bpy  # noqa: E402
from mathutils import Vector  # noqa: E402

from lab_blender_common import parse_args  # noqa: E402


def material(name, color, metallic=0.0, roughness=0.6):
	m = bpy.data.materials.new(name)
	m.use_nodes = True
	bsdf = m.node_tree.nodes["Principled BSDF"]
	bsdf.inputs["Base Color"].default_value = (*color, 1.0)
	bsdf.inputs["Metallic"].default_value = metallic
	bsdf.inputs["Roughness"].default_value = roughness
	return m


def box(name, size, loc, mat, bevel=0.025, segments=2):
	bpy.ops.mesh.primitive_cube_add(size=1.0, location=loc)
	o = bpy.context.active_object
	o.name = name
	o.scale = size
	bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
	if bevel > 0.0:
		mod = o.modifiers.new("Bevel", "BEVEL")
		mod.width = bevel
		mod.segments = segments
		mod.limit_method = "ANGLE"
	o.data.materials.append(mat)
	bpy.ops.object.shade_smooth()
	o.data.shade_smooth()  # Blender 4.1+: smooth by angle via modifier below
	ws = o.modifiers.new("WeightedNormals", "WEIGHTED_NORMAL")
	ws.keep_sharp = True
	return o


def cylinder(name, radius, depth, loc, rot, mat, verts=20, bevel=0.01):
	bpy.ops.mesh.primitive_cylinder_add(vertices=verts, radius=radius, depth=depth, location=loc, rotation=rot)
	o = bpy.context.active_object
	o.name = name
	if bevel > 0.0:
		mod = o.modifiers.new("Bevel", "BEVEL")
		mod.width = bevel
		mod.segments = 1
		mod.limit_method = "ANGLE"
	o.data.materials.append(mat)
	bpy.ops.object.shade_smooth()
	return o


def build():
	shell = material("unit_shell", (0.30, 0.32, 0.31), metallic=0.65, roughness=0.42)
	dark = material("unit_dark", (0.05, 0.055, 0.06), metallic=0.2, roughness=0.8)
	warn = material("unit_warn", (0.72, 0.53, 0.10), metallic=0.1, roughness=0.65)
	eye = material("unit_eye", (0.02, 0.02, 0.02), metallic=0.0, roughness=0.15)
	parts = []
	# Tracked base: two track modules (rounded ends) with guards and hub caps, a low deck between them.
	for side in (-1.0, 1.0):
		x = 0.36 * side
		parts.append(box("TrackBelt_%s" % ("L" if side < 0 else "R"), (0.2, 0.86, 0.3), (x, 0.0, 0.17), dark, bevel=0.12, segments=4))
		parts.append(box("TrackGuard_%s" % ("L" if side < 0 else "R"), (0.24, 1.0, 0.07), (x, 0.0, 0.36), shell, bevel=0.02))
		for y in (-0.36, 0.0, 0.36):
			parts.append(cylinder("Hub_%s_%d" % ("L" if side < 0 else "R", int(y * 100)), 0.09, 0.03, (x + 0.11 * side, y, 0.17), (0.0, math.pi / 2, 0.0), shell))
	parts.append(box("Deck", (0.5, 0.9, 0.16), (0.0, 0.0, 0.32), dark, bevel=0.03))
	# Chassis: narrow upright body, tapered by a second slab, hazard band, a dark sensor-bay strip at the front.
	parts.append(box("ChassisLower", (0.58, 0.48, 0.42), (0.0, 0.02, 0.6), shell, bevel=0.04))
	parts.append(box("ChassisUpper", (0.52, 0.42, 0.36), (0.0, 0.03, 0.99), shell, bevel=0.04))
	parts.append(box("HazardBand", (0.6, 0.5, 0.07), (0.0, 0.02, 0.82), warn, bevel=0.015))
	parts.append(box("FrontBay", (0.34, 0.03, 0.18), (0.0, -0.215, 0.62), dark, bevel=0.01))
	parts.append(box("BackPack", (0.38, 0.12, 0.42), (0.0, 0.27, 0.86), dark, bevel=0.03))
	# Mast and the sensor head with its wide visor.
	parts.append(cylinder("Mast", 0.075, 0.42, (0.0, 0.03, 1.36), (0.0, 0.0, 0.0), dark, verts=16))
	parts.append(box("SensorHead", (0.62, 0.34, 0.25), (0.0, 0.0, 1.69), shell, bevel=0.05, segments=3))
	parts.append(box("HeadCrest", (0.5, 0.26, 0.05), (0.0, 0.03, 1.835), warn, bevel=0.015))
	parts.append(box("VisorFrame", (0.56, 0.04, 0.12), (0.0, -0.17, 1.69), dark, bevel=0.015))
	visor = box("Eye", (0.5, 0.03, 0.07), (0.0, -0.19, 1.69), eye, bevel=0.01)
	parts.append(visor)
	# Folded manipulators (upper arm, forearm, gripper) on the chassis sides.
	for side in (-1.0, 1.0):
		x = 0.36 * side
		s = "L" if side < 0 else "R"
		parts.append(cylinder("Shoulder_%s" % s, 0.07, 0.08, (x, 0.0, 1.08), (0.0, math.pi / 2, 0.0), dark))
		parts.append(box("UpperArm_%s" % s, (0.1, 0.12, 0.44), (x, 0.0, 0.86), shell, bevel=0.025))
		parts.append(box("Forearm_%s" % s, (0.09, 0.32, 0.1), (x, -0.16, 0.66), shell, bevel=0.025))
		parts.append(box("Gripper_%s" % s, (0.12, 0.08, 0.12), (x, -0.34, 0.66), dark, bevel=0.02))
	return parts, visor


def main():
	options = {"repo": None}
	parse_args(options)
	repo = os.path.abspath(options["repo"])
	bpy.ops.wm.read_factory_settings(use_empty=True)
	parts, visor = build()
	# Join everything except the visor into one mesh (one draw call per material in Godot); keep "Eye" separate.
	body = [p for p in parts if p is not visor]
	bpy.ops.object.select_all(action="DESELECT")
	for p in body:
		p.select_set(True)
		bpy.context.view_layer.objects.active = p
		for m in list(p.modifiers):
			bpy.ops.object.modifier_apply(modifier=m.name)
	bpy.context.view_layer.objects.active = body[0]
	bpy.ops.object.join()
	body[0].name = "UnitBody"
	bpy.ops.object.select_all(action="DESELECT")
	visor.select_set(True)
	bpy.context.view_layer.objects.active = visor
	for m in list(visor.modifiers):
		bpy.ops.object.modifier_apply(modifier=m.name)
	tris = sum(len(p.data.polygons) for p in [body[0], visor])
	out = os.path.join(repo, "assets", "models", "characters", "recovery_unit.glb")
	bpy.ops.object.select_all(action="SELECT")
	bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=True, export_yup=True, export_apply=True,
		export_materials="EXPORT")
	print("[unit] %d faces -> %s" % (tris, out))


if __name__ == "__main__":
	main()
