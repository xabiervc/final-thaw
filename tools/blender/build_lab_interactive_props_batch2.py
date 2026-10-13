"""Lote 2: props interactivos de las salas 1 y 2 (docs/art/LAB_BATCH2_SPEC.md).

Ejecucion (Blender en segundo plano; argumentos tras "--"):
    blender --background --factory-startup --python tools/blender/build_lab_interactive_props_batch2.py -- \
        --glb-dir assets/models/lab --blend-dir D:/Projects/evidence/final-thaw/lab-props-batch2-source

Cada GLB contiene objetos de primer nivel con el origen donde el componente de gameplay
espera encontrarlo (origen del componente; palanca y gema con su propio pivote). Las
partes que el gameplay recolorea son mallas separadas llamadas emit_*, con material propio.
Sin colisiones, sin luces, sin texturas. El .blend se guarda fuera del repositorio.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
from lab_blender_common import (AssetBuilder, LAB_MATERIALS, export_glb, godot_to_blender,  # noqa: E402
	make_materials, parse_args, reset_scene, triangle_count, world_bounds_godot)
from mathutils import Vector  # noqa: E402

# Materiales nuevos: colores de estado por defecto de los componentes (mismos valores que en
# sus scripts). El gameplay los sustituye en tiempo de ejecucion; aqui solo fijan el estado inicial.
BATCH2_MATERIALS = {
	"lab_mat_arm_orange": ("E6801F", 0.6, 0.0), # color del brazo en robotic_arm.gd (0.9, 0.5, 0.12)
	"lab_mat_state_red": ("D93333", 0.4, 2.0), # (0.85, 0.2, 0.2)
	"lab_mat_state_green": ("33E680", 0.4, 2.0), # (0.2, 0.9, 0.5)
	"lab_mat_state_cyan": ("33B3E6", 0.4, 2.0), # (0.2, 0.7, 0.9)
	"lab_mat_state_gem": ("4DE6FF", 0.4, 3.0), # (0.3, 0.9, 1.0)
	"lab_mat_state_console": ("4DCCE6", 0.4, 1.2), # (0.3, 0.8, 0.9)
}
ALL_MATERIALS = {**LAB_MATERIALS, **BATCH2_MATERIALS}

METAL = "lab_mat_painted_metal"
TRIM = "lab_mat_trim_metal"
RUBBER = "lab_mat_rubber"
AMBER = "lab_mat_screen_emissive"


def parent_to(child, parent, child_pivot, parent_pivot) -> None:
	child.parent = parent
	child.location = godot_to_blender(Vector(child_pivot) - Vector(parent_pivot))


def emit(materials, name, builder_fn, pivot=(0.0, 0.0, 0.0)):
	b = AssetBuilder(name, materials, pivot=pivot)
	builder_fn(b)
	return b.finish()


def build_power_node(m):
	b = AssetBuilder("lab_power_node_a", m)
	b.box((0.7, 0.5, 0.7), (0.0, 0.25, 0.0), METAL, bevel=0.015)
	b.box((0.74, 0.05, 0.74), (0.0, 0.025, 0.0), RUBBER)
	b.cone((0.12, 0.3, 0.12), (0.0, 0.65, 0.0), TRIM, segments=8)
	b.cone((0.34, 0.05, 0.34), (0.0, 0.525, 0.0), TRIM, segments=12)
	return [b.finish(),
		emit(m, "emit_orb", lambda e: e.sphere((0.56, 0.56, 0.56), (0.0, 0.85, 0.0), AMBER)),
		emit(m, "emit_ring", lambda e: e.cone((1.0, 0.05, 1.0), (0.0, 0.55, 0.0), "lab_mat_state_green", segments=20))]


def build_junction_box(m):
	b = AssetBuilder("lab_junction_box_a", m)
	b.box((1.1, 1.0, 0.6), (0.0, 0.5, 0.0), METAL, bevel=0.015)
	b.box((1.0, 0.9, 0.02), (0.0, 0.5, 0.31), TRIM) # puerta del cuadro
	b.box((0.08, 0.25, 0.04), (0.4, 0.5, 0.33), RUBBER) # tirador
	for hinge_y in (0.2, 0.8):
		b.box((0.04, 0.12, 0.03), (-0.52, hinge_y, 0.325), TRIM)
	for slat in range(3):
		b.box((0.5, 0.03, 0.012), (-0.1, 0.3 + slat * 0.08, 0.326), RUBBER) # rejilla
	return [b.finish(), emit(m, "emit_lamp", lambda e: e.box((0.3, 0.1, 0.05), (0.0, 0.85, 0.33), AMBER))]


def build_terminal(m):
	# Misma geometria que lab_terminal_a, con la pantalla como malla separada (recoloreable).
	b = AssetBuilder("lab_terminal_power_a", m)
	b.box((1.0, 1.0, 0.7), (0.0, 0.5, 0.0), METAL, bevel=0.01)
	b.box((1.04, 0.06, 0.74), (0.0, 0.03, 0.0), RUBBER)
	for slot_y in (0.25, 0.32, 0.39):
		b.box((0.6, 0.025, 0.01), (0.0, slot_y, 0.355), TRIM)
	b.box((0.9, 0.55, 0.08), (0.0, 1.2, 0.2), METAL, rot_deg=(-25.0, 0.0, 0.0), bevel=0.008)
	b.cone((0.06, 0.4, 0.06), (0.4, 0.5, -0.36), TRIM, segments=8) # conducto de energia trasero
	return [b.finish(), emit(m, "emit_screen", lambda e: e.box((0.78, 0.4, 0.02), (0.0, 1.22, 0.25), AMBER, rot_deg=(-25.0, 0.0, 0.0)))]


def build_lever(m):
	pivot = (0.0, 0.55, 0.0)
	b = AssetBuilder("lab_lever_a", m)
	b.box((0.9, 0.5, 0.6), (0.0, 0.25, 0.0), METAL, bevel=0.015)
	b.box((0.3, 0.02, 0.2), (0.0, 0.51, 0.0), TRIM) # placa de la ranura
	b.cone((0.14, 0.12, 0.14), (0.0, 0.55, 0.0), TRIM, segments=10, rot_deg=(0.0, 0.0, 90.0)) # buje del pivote
	base = b.finish()
	arm = emit(m, "LeverArm", lambda e: e.cone((0.1, 0.9, 0.1), (0.0, 1.0, 0.0), METAL, segments=8), pivot=pivot)
	knob = emit(m, "emit_knob", lambda e: e.sphere((0.2, 0.2, 0.2), (0.0, 1.5, 0.0), AMBER, u_segments=10, v_segments=6), pivot=(0.0, 1.5, 0.0))
	parent_to(knob, arm, (0.0, 1.5, 0.0), pivot)
	lamp = emit(m, "emit_lamp", lambda e: e.box((0.18, 0.08, 0.05), (0.0, 0.35, 0.31), "lab_mat_state_red"))
	return [base, arm, knob, lamp]


def build_button(m):
	b = AssetBuilder("lab_button_pedestal_a", m)
	b.box((0.5, 0.7, 0.5), (0.0, 0.35, 0.0), METAL, bevel=0.012)
	b.box((0.44, 0.04, 0.44), (0.0, 0.68, 0.0), TRIM)
	b.box((0.54, 0.05, 0.54), (0.0, 0.025, 0.0), RUBBER)
	return [b.finish(), emit(m, "emit_cap", lambda e: e.box((0.36, 0.1, 0.36), (0.0, 0.75, 0.0), "lab_mat_state_cyan"))]


def build_door(m):
	# DoorSlab: origen en el centro de la losa (0, 1,5, 0), como el StaticBody de door.gd, porque
	# el script lo desplaza en z al abrir. emit_strip no se mueve: origen en el de la puerta.
	slab_pivot = (0.0, 1.5, 0.0)
	b = AssetBuilder("DoorSlab", m, pivot=slab_pivot)
	b.box((0.4, 3.0, 2.8), (0.0, 1.5, 0.0), METAL)
	for side in (-1.0, 1.0):
		x = side * 0.205
		b.box((0.01, 0.08, 2.4), (x, 0.2, 0.0), TRIM)
		b.box((0.01, 0.08, 2.4), (x, 2.8, 0.0), TRIM)
		for z in (-1.2, 1.2):
			b.box((0.01, 2.6, 0.08), (x, 1.5, z), TRIM)
		b.box((0.04, 0.5, 0.1), (side * 0.22, 1.2, 1.0), RUBBER) # tirador
	slab = b.finish()
	strip = emit(m, "emit_strip", lambda e: e.box((0.6, 0.25, 3.1), (0.0, 3.12, 0.0), "lab_mat_state_red"))
	return [slab, strip]


def build_arm(m):
	b = AssetBuilder("lab_robotic_arm_a", m)
	b.cone((1.2, 0.3, 1.2), (0.0, 0.15, 0.0), TRIM, segments=16) # plato giratorio
	b.box((0.56, 1.0, 0.56), (0.0, 0.8, 0.0), METAL, bevel=0.02) # columna
	b.cone((0.64, 0.7, 0.64), (0.0, 1.45, 0.0), TRIM, segments=14, rot_deg=(0.0, 0.0, 90.0)) # hombro
	b.box((0.6, 0.9, 3.0), (0.0, 1.55, 1.5), "lab_mat_arm_orange", bevel=0.025) # brazo principal
	b.box((0.4, 0.4, 1.0), (0.0, 1.5, -0.5), METAL) # brazo trasero
	b.box((0.6, 0.8, 0.8), (0.0, 1.5, -1.2), "lab_mat_arm_orange", bevel=0.025) # contrapeso
	for band_z in (0.6, 2.4):
		b.box((0.62, 0.92, 0.12), (0.0, 1.55, band_z), RUBBER) # bandas de proteccion
	b.cone((0.5, 0.6, 0.5), (0.0, 1.55, 2.95), TRIM, segments=12, rot_deg=(0.0, 0.0, 90.0)) # muneca
	for side in (-1.0, 1.0):
		b.box((0.1, 0.9, 0.18), (side * 0.18, 1.1, 3.05), TRIM, bevel=0.01) # pinzas
	return [b.finish()]


def build_checkpoint(m):
	b = AssetBuilder("lab_checkpoint_arch_a", m)
	for z in (-1.2, 1.2):
		b.box((0.2, 2.5, 0.2), (0.0, 1.25, z), METAL)
		b.box((0.26, 0.08, 0.28), (0.0, 0.04, z), TRIM)
	b.box((0.2, 0.2, 2.6), (0.0, 2.6, 0.0), METAL)
	def strips_post(z):
		def build(e):
			for side in (-1.0, 1.0): # caras +-X (paso del jugador) y +-Z (las que ve la camara)
				e.box((0.02, 2.1, 0.08), (side * 0.105, 1.3, z), "lab_mat_state_cyan")
				e.box((0.08, 2.1, 0.02), (0.0, 1.3, z + side * 0.105), "lab_mat_state_cyan")
		return build
	def strips_lintel(e):
		for side in (-1.0, 1.0):
			e.box((0.02, 0.08, 2.2), (side * 0.105, 2.6, 0.0), "lab_mat_state_cyan")
		e.box((0.1, 0.02, 2.2), (0.0, 2.71, 0.0), "lab_mat_state_cyan") # cara superior, visible desde la camara
	return [b.finish(),
		emit(m, "emit_arch_post_L", strips_post(-1.2)),
		emit(m, "emit_arch_post_R", strips_post(1.2)),
		emit(m, "emit_arch_lintel", strips_lintel)]


def build_memory_fragment(m):
	b = AssetBuilder("lab_memory_fragment_a", m)
	b.cone((0.4, 0.7, 0.4), (0.0, 0.35, 0.0), METAL, top_ratio=0.7, segments=12)
	b.cone((0.46, 0.04, 0.46), (0.0, 0.72, 0.0), TRIM, segments=12)
	for index in range(3): # garras del soporte
		angle = index * 120.0
		import math
		x, z = 0.13 * math.cos(math.radians(angle)), 0.13 * math.sin(math.radians(angle))
		b.box((0.03, 0.22, 0.03), (x, 0.85, z), TRIM)
	def gem(e):
		e.cone((0.3, 0.24, 0.3), (0.0, 1.12, 0.0), "lab_mat_state_gem", top_ratio=0.0, segments=6)
		e.cone((0.3, 0.24, 0.3), (0.0, 0.88, 0.0), "lab_mat_state_gem", top_ratio=0.0, segments=6, rot_deg=(180.0, 0.0, 0.0))
	return [b.finish(), emit(m, "emit_gem", gem, pivot=(0.0, 1.0, 0.0))]


def build_console(m):
	b = AssetBuilder("lab_console_a", m)
	b.box((0.7, 1.0, 0.5), (0.0, 0.5, 0.0), METAL, bevel=0.012)
	b.box((0.74, 0.06, 0.54), (0.0, 0.03, 0.0), RUBBER)
	b.box((0.56, 0.36, 0.03), (0.0, 0.75, 0.26), TRIM) # marco de la pantalla
	for slat in range(3):
		b.box((0.4, 0.025, 0.012), (0.0, 0.35 + slat * 0.07, 0.256), RUBBER)
	return [b.finish(), emit(m, "emit_screen", lambda e: e.box((0.5, 0.3, 0.04), (0.0, 0.75, 0.27), "lab_mat_state_console"))]


BUILDERS = [("lab_power_node_a", build_power_node), ("lab_junction_box_a", build_junction_box),
	("lab_terminal_power_a", build_terminal), ("lab_lever_a", build_lever), ("lab_button_pedestal_a", build_button),
	("lab_door_slab_a", build_door), ("lab_robotic_arm_a", build_arm), ("lab_checkpoint_arch_a", build_checkpoint),
	("lab_memory_fragment_a", build_memory_fragment), ("lab_console_a", build_console)]


def main() -> None:
	options = parse_args({"glb-dir": None, "blend-dir": None})
	if not options["glb-dir"]:
		raise SystemExit("falta --glb-dir")
	glb_dir = os.path.abspath(options["glb-dir"])
	reset_scene()
	materials = make_materials(ALL_MATERIALS)
	layout_objects = []
	for index, (asset, builder) in enumerate(BUILDERS):
		objects = builder(materials)
		bpy.context.view_layer.update()
		low, high = world_bounds_godot(objects)
		size = high - low
		print("[asset] %s tris=%d objetos=%s size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (
			asset, triangle_count(objects), ",".join(o.name for o in objects), size.x, size.y, size.z, low.x, low.y, low.z))
		print("[asset] %s -> %s" % (asset, export_glb(objects, os.path.join(glb_dir, asset + ".glb"))))
		for obj in objects: # nombres unicos en el .blend; el GLB ya esta exportado
			obj.name = "%s__%s" % (obj.name, asset)
			if obj.parent is None:
				obj.location.x += index * 6.0
		layout_objects.extend(objects)
	if options["blend-dir"]:
		blend_dir = os.path.abspath(options["blend-dir"])
		os.makedirs(blend_dir, exist_ok=True)
		path = os.path.join(blend_dir, "lab_props_batch2.blend")
		bpy.ops.wm.save_as_mainfile(filepath=path)
		print("[blend] " + path)


main()
