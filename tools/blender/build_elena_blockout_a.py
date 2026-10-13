"""Elena de bloqueo estilizada (docs/art/ELENA_BLOCKOUT_SPEC.md).

Ejecucion (Blender en segundo plano; argumentos tras "--"):
    blender --background --factory-startup --python tools/blender/build_elena_blockout_a.py -- \
        --glb-dir assets/models/characters --blend-dir D:/Projects/evidence/final-thaw/elena-blockout-source

Sin rig, sin pesos, sin cara y sin texturas: piezas rigidas con pivotes en las articulaciones.
Frente = +Z (como elena_controller.gd); mochila en -Z. "R" es la derecha anatomica de Elena:
mirando a +Z queda en -X (en ella esta el Aster). Geometria definida en pose A (reposo).
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402
from lab_blender_common import (AssetBuilder, LAB_MATERIALS, export_glb, godot_to_blender,  # noqa: E402
	make_materials, parse_args, reset_scene, triangle_count, world_bounds_godot)

# nombre: (hex sRGB, roughness, emision). Colores = referencia de lab_palette_test.gd.
ELENA_MATERIALS = {
	"elena_blk_coat": ("2C474C", 0.85, 0.0),
	"elena_blk_piping": ("8DB0B0", 0.6, 0.0),
	"elena_blk_turtleneck": ("26292C", 0.9, 0.0),
	"elena_blk_trousers": ("33373A", 0.9, 0.0),
	"elena_blk_boots": ("1F3436", 0.7, 0.0),
	"elena_blk_backpack": ("26403F", 0.85, 0.0),
	"elena_blk_skin": ("D9B49A", 0.8, 0.0),
	"elena_blk_hair": ("2A211E", 0.9, 0.0),
	"elena_blk_aster": ("7FF0E6", 0.4, 2.0),
	# La baliza ambar de la mochila va apagada (ambar reservado a interactuables; decision D2).
	"lab_mat_painted_metal": LAB_MATERIALS["lab_mat_painted_metal"],
}

SHOULDER_X = 0.235
SHOULDER_Y = 1.38
ARM_LENGTH = 0.60
HAND_REST_ANGLE_Z = 6.0
FORWARD_ARM_ANGLE_X = -35.0 # el antebrazo derecho avanza hacia +Z


def arm_direction(rot_x_deg: float, rot_z_deg: float) -> Vector:
	"""Direccion (ejes de Godot) del brazo colgando tras rotar (X, luego Z) en orden YXZ."""
	rx = Matrix.Rotation(math.radians(rot_x_deg), 3, "X")
	rz = Matrix.Rotation(math.radians(rot_z_deg), 3, "Z")
	return (rx @ rz) @ Vector((0.0, -1.0, 0.0))


def build_hips(materials):
	b = AssetBuilder("Hips", materials, pivot=(0.0, 0.92, 0.0))
	b.box((0.30, 0.20, 0.20), (0.0, 0.90, 0.0), "elena_blk_trousers", bevel=0.01)
	return b.finish()


def build_leg(materials, name: str, side: float):
	x = side * 0.10
	b = AssetBuilder(name, materials, pivot=(x, 0.92, 0.0))
	b.cone((0.15, 0.52, 0.15), (x, 0.69, 0.0), "elena_blk_trousers", top_ratio=1.3)
	b.cone((0.15, 0.45, 0.15), (x, 0.225, 0.0), "elena_blk_boots", top_ratio=1.15)
	b.box((0.14, 0.08, 0.27), (x, 0.04, 0.05), "elena_blk_boots", bevel=0.012)
	b.box((0.03, 0.14, 0.11), (x + side * 0.085, 0.62, 0.0), "elena_blk_trousers") # bolsillo cargo
	return b.finish()


def build_torso(materials):
	b = AssetBuilder("Torso", materials, pivot=(0.0, 1.0, 0.0))
	b.cone((0.58, 0.60, 0.40), (0.0, 1.10, 0.0), "elena_blk_coat", top_ratio=0.62, segments=14) # abrigo largo
	b.box((0.13, 0.44, 0.02), (0.0, 1.17, 0.152), "elena_blk_turtleneck") # jersey de cuello alto
	for side in (-1.0, 1.0):
		b.box((0.02, 0.46, 0.015), (side * 0.075, 1.17, 0.152), "elena_blk_piping") # vivos delanteros
		b.box((0.13, 0.15, 0.03), (side * 0.14, 0.97, 0.155), "elena_blk_coat") # solapa de bolsillo
	b.box((0.46, 0.06, 0.28), (0.0, 1.40, 0.0), "elena_blk_piping") # canesu gris-cian
	b.cone((0.28, 0.10, 0.26), (0.0, 1.47, 0.0), "elena_blk_coat", top_ratio=1.05) # cuello alto
	b.cone((0.15, 0.12, 0.15), (0.0, 1.44, 0.0), "elena_blk_turtleneck")
	return b.finish()


def build_head(materials):
	b = AssetBuilder("Head", materials, pivot=(0.0, 1.46, 0.0))
	b.sphere((0.20, 0.24, 0.22), (0.0, 1.56, 0.005), "elena_blk_skin")
	b.sphere((0.22, 0.25, 0.24), (0.0, 1.575, -0.035), "elena_blk_hair")
	b.cone((0.07, 0.20, 0.07), (0.0, 1.47, -0.14), "elena_blk_hair", top_ratio=1.4, segments=8, rot_deg=(15.0, 0.0, 0.0)) # coleta
	return b.finish()


def build_arm(materials, name: str, side: float, forward: bool):
	pivot = Vector((side * SHOULDER_X, SHOULDER_Y, 0.0))
	rot_x = FORWARD_ARM_ANGLE_X if forward else 0.0
	rot_z = side * (5.0 if forward else HAND_REST_ANGLE_Z)
	direction = arm_direction(rot_x, rot_z)
	b = AssetBuilder(name, materials, pivot=pivot)
	sleeve = pivot + direction * (ARM_LENGTH * 0.47)
	b.cone((0.105, ARM_LENGTH * 0.94, 0.105), sleeve, "elena_blk_coat", top_ratio=1.2, rot_deg=(rot_x, 0.0, rot_z))
	b.cone((0.115, 0.03, 0.115), pivot + direction * (ARM_LENGTH * 0.88), "elena_blk_piping", rot_deg=(rot_x, 0.0, rot_z)) # puno
	hand = pivot + direction * ARM_LENGTH
	b.sphere((0.09, 0.10, 0.09), hand, "elena_blk_skin", u_segments=10, v_segments=6)
	return b.finish(), hand


def build_aster(materials, hand: Vector):
	"""Dispositivo de mano con pantalla cian (el Aster). Pivote en la mano; pantalla hacia arriba y atras."""
	tilt = -125.0
	b = AssetBuilder("Aster", materials, pivot=hand)
	center = hand + Vector((0.0, 0.06, 0.02))
	b.box((0.075, 0.14, 0.016), center, "elena_blk_trousers", rot_deg=(tilt, 0.0, 0.0))
	screen_offset = Matrix.Rotation(math.radians(tilt), 3, "X") @ Vector((0.0, 0.0, 0.0095))
	b.box((0.06, 0.115, 0.004), center + screen_offset, "elena_blk_aster", rot_deg=(tilt, 0.0, 0.0))
	return b.finish()


def build_backpack(materials):
	b = AssetBuilder("Backpack", materials, pivot=(0.0, 1.16, -0.27))
	b.box((0.34, 0.46, 0.20), (0.0, 1.16, -0.27), "elena_blk_backpack", bevel=0.012)
	b.box((0.36, 0.06, 0.22), (0.0, 1.41, -0.27), "elena_blk_backpack", bevel=0.008) # tapa
	for side in (-1.0, 1.0):
		b.box((0.02, 0.20, 0.02), (side * 0.19, 1.12, -0.30), "elena_blk_trousers") # herramientas en bucles
	b.box((0.05, 0.04, 0.05), (0.09, 1.45, -0.27), "lab_mat_painted_metal") # baliza apagada
	return b.finish()


def parent_to(child, parent, child_pivot, parent_pivot) -> None:
	child.parent = parent
	child.location = godot_to_blender(Vector(child_pivot) - Vector(parent_pivot))


def main() -> None:
	options = parse_args({"glb-dir": None, "blend-dir": None})
	if not options["glb-dir"]:
		raise SystemExit("falta --glb-dir")
	glb_dir = os.path.abspath(options["glb-dir"])
	reset_scene()
	materials = make_materials({**ELENA_MATERIALS})

	root = bpy.data.objects.new("Root", None)
	bpy.context.scene.collection.objects.link(root)

	hips = build_hips(materials)
	torso = build_torso(materials)
	head = build_head(materials)
	arm_left, _ = build_arm(materials, "ArmL", 1.0, False)
	arm_right, hand = build_arm(materials, "ArmR", -1.0, True) # derecha anatomica = -X
	aster = build_aster(materials, hand)
	backpack = build_backpack(materials)
	leg_left = build_leg(materials, "LegL", 1.0)
	leg_right = build_leg(materials, "LegR", -1.0)

	hips_pivot = (0.0, 0.92, 0.0)
	torso_pivot = (0.0, 1.0, 0.0)
	parent_to(hips, root, hips_pivot, (0.0, 0.0, 0.0))
	parent_to(torso, hips, torso_pivot, hips_pivot)
	parent_to(head, torso, (0.0, 1.46, 0.0), torso_pivot)
	parent_to(arm_left, torso, (SHOULDER_X, SHOULDER_Y, 0.0), torso_pivot)
	parent_to(arm_right, torso, (-SHOULDER_X, SHOULDER_Y, 0.0), torso_pivot)
	parent_to(aster, arm_right, hand, (-SHOULDER_X, SHOULDER_Y, 0.0))
	parent_to(backpack, torso, (0.0, 1.16, -0.27), torso_pivot)
	parent_to(leg_left, hips, (0.10, 0.92, 0.0), hips_pivot)
	parent_to(leg_right, hips, (-0.10, 0.92, 0.0), hips_pivot)

	parts = [hips, torso, head, arm_left, arm_right, aster, backpack, leg_left, leg_right]
	bpy.context.view_layer.update()
	low, high = world_bounds_godot(parts)
	size = high - low
	used = sorted({m.name for part in parts for m in part.data.materials})
	print("[elena] tris=%d meshes=%d materiales=%d size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (
		triangle_count(parts), len(parts), len(used), size.x, size.y, size.z, low.x, low.y, low.z))
	print("[elena] materiales: " + ",".join(used))
	print("[elena] -> " + export_glb([root] + parts, os.path.join(glb_dir, "elena_blockout_a.glb")))

	if options["blend-dir"]:
		blend_dir = os.path.abspath(options["blend-dir"])
		os.makedirs(blend_dir, exist_ok=True)
		path = os.path.join(blend_dir, "elena_blockout_a.blend")
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


main()
