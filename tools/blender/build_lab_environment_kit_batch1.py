"""Lote 1 del kit de entorno del laboratorio (docs/art/LAB_BATCH1_SPEC.md).

Ejecucion (Blender en segundo plano; argumentos tras "--"):
    blender --background --factory-startup --python tools/blender/build_lab_environment_kit_batch1.py -- \
        --glb-dir assets/models/lab --blend-dir D:/Projects/evidence/final-thaw/lab-kit-batch1-source

Genera: lab_wall_low_2m_a, lab_wall_2m_b, lab_floor_2x2_b, lab_floor_edge_2m_a,
lab_divider_wall_2m_a y lab_door_frame_a. Sin texturas: el desgaste es geometrico.
El .blend se guarda fuera del repositorio.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
from lab_blender_common import (AssetBuilder, LAB_MATERIALS, export_glb, make_materials,  # noqa: E402
	parse_args, reset_scene, triangle_count, world_bounds_godot)

SEAM_HALF_WIDTH = 0.0075


def wall_trims(b: AssetBuilder, width: float, top: float, both_faces: bool, depth: float) -> None:
	"""Zocalo (0,3 m), barandilla (y=1,0 m si cabe) y medias juntas en cada borde."""
	faces = (1.0, -1.0) if both_faces else (1.0,)
	half = depth * 0.5
	for face in faces:
		z = face * (half + 0.015) if both_faces else 0.015
		b.box((width, 0.3, 0.03), (0.0, 0.15, z), "lab_mat_trim_metal")
		if top > 1.06:
			b.box((width, 0.06, 0.03), (0.0, 1.0, z), "lab_mat_trim_metal")
		seam_height = top - 0.3
		for side in (-1.0, 1.0):
			seam_z = face * (half + 0.005) if both_faces else 0.005
			b.box((SEAM_HALF_WIDTH, seam_height, 0.01), (side * (width * 0.5 - SEAM_HALF_WIDTH * 0.5), 0.3 + seam_height * 0.5, seam_z), "lab_mat_trim_metal")


def build_wall_low(materials):
	# Muro del lado de la camara: 0,9 m de alto, cuerpo de 0,5 m hacia -Z. Pivote: base, centro, cara interior.
	b = AssetBuilder("lab_wall_low_2m_a", materials)
	b.box((2.0, 0.86, 0.5), (0.0, 0.43, -0.25), "lab_mat_wall_panel")
	b.box((2.0, 0.04, 0.5), (0.0, 0.88, -0.25), "lab_mat_trim_metal") # remate superior
	b.box((2.0, 0.3, 0.03), (0.0, 0.15, 0.015), "lab_mat_trim_metal")
	for side in (-1.0, 1.0):
		b.box((SEAM_HALF_WIDTH, 0.56, 0.01), (side * (1.0 - SEAM_HALF_WIDTH * 0.5), 0.58, 0.005), "lab_mat_trim_metal")
	return b.finish()


def build_wall_b(materials):
	# Variante de lab_wall_2m_a con rejilla de ventilacion y conducto de cables.
	b = AssetBuilder("lab_wall_2m_b", materials)
	b.box((2.0, 3.2, 0.5), (0.0, 1.6, -0.25), "lab_mat_wall_panel")
	wall_trims(b, 2.0, 3.2, False, 0.5)
	b.box((0.7, 0.45, 0.02), (-0.4, 2.3, 0.01), "lab_mat_trim_metal") # marco de la rejilla
	for slat in range(5):
		b.box((0.62, 0.03, 0.015), (-0.4, 2.14 + slat * 0.08, 0.0275), "lab_mat_rubber")
	b.cone((0.06, 2.7, 0.06), (0.55, 1.65, 0.03), "lab_mat_rubber", segments=8) # conducto vertical
	for clamp_y in (0.7, 1.7, 2.7):
		b.box((0.14, 0.05, 0.03), (0.55, clamp_y, 0.03), "lab_mat_trim_metal")
	return b.finish()


def build_floor_b(materials):
	# Variante de lab_floor_2x2_a con marcas de desgaste geometricas (sin textura).
	b = AssetBuilder("lab_floor_2x2_b", materials)
	b.box((2.0, 0.08, 2.0), (0.0, -0.06, 0.0), "lab_mat_floor_joint")
	b.box((1.96, 0.1, 1.96), (0.0, -0.05, 0.0), "lab_mat_floor_epoxy", bevel=0.006)
	for center, length, yaw in (((-0.4, 0.0015, 0.3), 0.9, 20.0), ((0.5, 0.0015, -0.5), 0.6, -35.0), ((0.2, 0.0015, 0.7), 0.4, 80.0)):
		b.box((length, 0.003, 0.05), center, "lab_mat_floor_joint", rot_deg=(0.0, yaw, 0.0)) # rozaduras
	return b.finish()


def build_floor_edge(materials):
	# Labio de borde de foso o saliente. Pivote: centro, apoyado en y=0 (cara superior del suelo).
	b = AssetBuilder("lab_floor_edge_2m_a", materials)
	b.box((2.0, 0.06, 0.15), (0.0, 0.03, 0.0), "lab_mat_trim_metal")
	for side in (-1.0, 1.0):
		b.box((0.04, 0.01, 0.04), (side * 0.9, 0.065, 0.0), "lab_mat_trim_metal") # tornillos
	return b.finish()


def build_divider(materials):
	# Muro divisor de 0,6 m visible por ambas caras. Pivote: centro, a nivel de suelo.
	b = AssetBuilder("lab_divider_wall_2m_a", materials)
	b.box((2.0, 3.2, 0.6), (0.0, 1.6, 0.0), "lab_mat_wall_panel")
	wall_trims(b, 2.0, 3.2, True, 0.6)
	return b.finish()


def build_door_frame(materials):
	# Marco de 4,0 m con hueco de 2,8 x 3,0 m; jambas de 0,6 m y dintel de 0,2 m. Pivote: centro, suelo.
	# Molduras solo sobre las caras +-Z (nunca en el hueco ni en planos coplanares: sin z-fighting).
	b = AssetBuilder("lab_door_frame_a", materials)
	for side in (-1.0, 1.0):
		b.box((0.6, 3.2, 0.6), (side * 1.7, 1.6, 0.0), "lab_mat_wall_panel") # jambas
		for face in (-1.0, 1.0):
			b.box((0.06, 2.7, 0.03), (side * 1.43, 1.65, face * 0.315), "lab_mat_trim_metal") # moldura vertical del hueco
			b.box((0.54, 0.3, 0.03), (side * 1.73, 0.15, face * 0.315), "lab_mat_trim_metal") # zocalo
			b.box((0.54, 0.06, 0.03), (side * 1.73, 1.0, face * 0.315), "lab_mat_trim_metal") # barandilla
	b.box((2.8, 0.2, 0.6), (0.0, 3.1, 0.0), "lab_mat_wall_panel") # dintel
	for face in (-1.0, 1.0):
		b.box((2.92, 0.06, 0.03), (0.0, 3.03, face * 0.315), "lab_mat_trim_metal") # moldura del dintel
	return b.finish()


BUILDERS = [build_wall_low, build_wall_b, build_floor_b, build_floor_edge, build_divider, build_door_frame]


def main() -> None:
	options = parse_args({"glb-dir": None, "blend-dir": None})
	if not options["glb-dir"]:
		raise SystemExit("falta --glb-dir")
	glb_dir = os.path.abspath(options["glb-dir"])
	reset_scene()
	materials = make_materials(LAB_MATERIALS)
	objects = [builder(materials) for builder in BUILDERS]
	for obj in objects:
		low, high = world_bounds_godot([obj])
		size = high - low
		print("[asset] %s tris=%d materiales=%s size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (
			obj.name, triangle_count([obj]), ",".join(m.name for m in obj.data.materials),
			size.x, size.y, size.z, low.x, low.y, low.z))
		print("[asset] %s -> %s" % (obj.name, export_glb([obj], os.path.join(glb_dir, obj.name + ".glb"))))
	if options["blend-dir"]:
		blend_dir = os.path.abspath(options["blend-dir"])
		os.makedirs(blend_dir, exist_ok=True)
		for index, obj in enumerate(objects):
			obj.location.x = index * 5.0
		path = os.path.join(blend_dir, "lab_kit_batch1.blend")
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


main()
