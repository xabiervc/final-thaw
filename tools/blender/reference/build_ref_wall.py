"""Seccion de pared de referencia de 2 m, columna de esquina y lampara de pared.

    blender --background --factory-startup --python tools/blender/reference/build_ref_wall.py -- \
        --repo D:/Projects/github/final-thaw --blend-dir D:/Projects/evidence/final-thaw/lab-ref-source

Pared: nucleo de hormigon con 6 paneles pintados en relieve (escotilla, rejilla, placa), pilares
de acero en los bordes, zocalo atornillado, baranda, tuberia con bridas y valvula, bandeja con
cables y conducto vertical. Pivote: base, centro del ancho, sobre la cara interior (z=0, cuerpo
hacia -Z, normal +Z). Esquina: pivote en el vertice interior. Lampara: pivote en el centro de la
carcasa, cara trasera en z=-0.125.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
from mathutils import Vector  # noqa: E402
from ref_common import (RefMesh, bake_atlas, common_args, export_glb, finalize_materials, proc_material,  # noqa: E402
	repo_paths, reset_scene, save_blend, select_only, smart_uv, triangle_count, world_bounds_godot,
	write_emissive_tres, write_pbr_tres)

PANEL_ROWS = (0.77, 1.71, 2.65)
PANEL_COLS = (-0.5, 0.5)
PANEL_W = 0.88
PANEL_H = 0.9
PANEL_D = 0.06


def make_materials():
	return {
		"concrete": proc_material("concrete", base="3B4043", rough=0.92, rough_var=0.1, dirt=0.6, mottle=0.4, scale=4.0,
			stain=0.3, bump=0.6, bump_scale=110.0),
		"panel": proc_material("panel", base="7F898D", rough=0.62, rough_var=0.22, edge_color="545B5F", edge_amount=0.8,
			edge_radius=0.012, edge_metal=0.5, dirt=0.7, ao_distance=0.1, stain=0.25, mottle=0.2, scale=6.0,
			bump=0.3, bump_scale=150.0, grime_height=0.85, grime=0.55, scratch=0.22, scratch_scale=8.0),
		"pillar": proc_material("pillar", base="4C5D63", rough=0.5, rough_var=0.22, edge_color="9AA1A4", edge_amount=0.8,
			edge_radius=0.006, edge_metal=0.6, dirt=0.65, ao_distance=0.08, stain=0.3, mottle=0.3, scale=8.0, bump=0.3,
			bump_scale=160.0, grime_height=0.8, grime=0.5, scratch=0.6, scratch_scale=12.0),
		"trim": proc_material("trim", base="333A3E", rough=0.5, rough_var=0.2, metal=0.3, edge_color="9EA4A6", edge_amount=0.8,
			edge_radius=0.005, edge_metal=0.6, dirt=0.6, ao_distance=0.06, stain=0.3, mottle=0.3, scale=10.0, bump=0.3,
			bump_scale=180.0, grime_height=0.5, grime=0.5, scratch=0.5, scratch_scale=14.0),
		"steel": proc_material("steel", base="747B7F", rough=0.4, rough_var=0.25, metal=0.85, edge_color="BFC4C6", edge_amount=0.5,
			edge_radius=0.004, edge_metal=0.1, dirt=0.65, ao_distance=0.04, stain=0.35, mottle=0.3, scale=20.0, bump=0.2,
			bump_scale=200.0, scratch=0.4, scratch_scale=22.0),
		"rubber": proc_material("rubber", base="16181A", rough=0.8, rough_var=0.12, dirt=0.3, mottle=0.2, scale=22.0, bump=0.2),
		"pipe": proc_material("pipe", base="4D6762", rough=0.42, rough_var=0.22, metal=0.35, edge_color="A9B0AE", edge_amount=0.7,
			edge_radius=0.006, edge_metal=0.5, dirt=0.6, ao_distance=0.06, stain=0.55, mottle=0.3, scale=10.0, bump=0.25,
			bump_scale=170.0, grime_height=0.9, grime=0.35, scratch=0.5, scratch_scale=14.0),
		"cable_a": proc_material("cable_a", base="141619", rough=0.65, rough_var=0.1, dirt=0.3, mottle=0.2, scale=30.0, bump=0.2),
		"cable_b": proc_material("cable_b", base="5C2A27", rough=0.6, rough_var=0.1, dirt=0.4, mottle=0.25, scale=30.0, bump=0.2),
		"cable_c": proc_material("cable_c", base="26394C", rough=0.6, rough_var=0.1, dirt=0.4, mottle=0.25, scale=30.0, bump=0.2),
	}


def bolts_row(m, pts, mat="steel", radius=0.014, height=0.014, axis="z"):
	for p in pts:
		m.cyl((radius * 2.0, height, radius * 2.0), p, mat, segs=6, rot=(90.0, 0.0, 0.0), bevel=0.002, segments=1)


def build_wall(mats):
	m = RefMesh("wall")
	m.box((2.0, 3.2, 0.3), (0.0, 1.6, -0.21), "concrete") # nucleo; la cara frontal queda en z=-0.06
	for row, y in enumerate(PANEL_ROWS):
		for col, x in enumerate(PANEL_COLS):
			m.box((PANEL_W, PANEL_H, PANEL_D), (x, y, -PANEL_D * 0.5), "panel", bevel=0.014, segments=3)
			m.box((PANEL_W - 0.2, PANEL_H - 0.2, 0.012), (x, y, 0.004), "panel", bevel=0.004, segments=2) # relieve central
			bolts_row(m, [(x + sx * (PANEL_W * 0.5 - 0.04), y + sy * (PANEL_H * 0.5 - 0.04), 0.004) for sx in (-1, 1) for sy in (-1, 1)])
	# escotilla de acceso (col 0, fila 1)
	hx, hy = PANEL_COLS[0], PANEL_ROWS[1]
	m.box((0.52, 0.62, 0.025), (hx, hy, 0.018), "trim", bevel=0.006, segments=2)
	m.box((0.44, 0.54, 0.016), (hx, hy, 0.034), "panel", bevel=0.005, segments=2)
	m.cyl((0.03, 0.05, 0.03), (hx + 0.17, hy, 0.062), "steel", segs=8, rot=(90.0, 0.0, 0.0), bevel=0.003) # tirador
	m.box((0.22, 0.03, 0.03), (hx + 0.1, hy, 0.075), "steel", bevel=0.004)
	for hy_off in (-0.22, 0.22):
		m.cyl((0.03, 0.06, 0.03), (hx - 0.24, hy + hy_off, 0.04), "steel", segs=8, bevel=0.003) # bisagras
	# rejilla de ventilacion (col 1, fila 0)
	vx, vy = PANEL_COLS[1], PANEL_ROWS[0]
	m.box((0.62, 0.5, 0.02), (vx, vy, 0.016), "trim", bevel=0.005, segments=2)
	m.box((0.54, 0.42, 0.01), (vx, vy, 0.026), "rubber")
	for slat in range(7):
		m.box((0.54, 0.03, 0.02), (vx, vy - 0.18 + slat * 0.06, 0.04), "trim", rot=(-28.0, 0.0, 0.0), bevel=0.002, segments=1)
	# placa de datos (col 0, fila 2)
	px, py = PANEL_COLS[0], PANEL_ROWS[2]
	m.box((0.34, 0.12, 0.008), (px, py - 0.18, 0.024), "steel", bevel=0.002, segments=1)
	bolts_row(m, [(px + sx * 0.15, py - 0.18 + sy * 0.04, 0.03) for sx in (-1, 1) for sy in (-1, 1)], radius=0.008, height=0.01)
	# pilares de borde (medio pilar por lado)
	for side in (-1.0, 1.0):
		m.box((0.06, 3.2, 0.07), (side * 0.97, 1.6, 0.035), "pillar", bevel=0.005, segments=2)
		bolts_row(m, [(side * 0.97, 0.45 + 0.4 * i, 0.07) for i in range(7)], radius=0.011, height=0.012)
	# zocalo atornillado y barandilla
	m.box((1.88, 0.28, 0.05), (0.0, 0.14, 0.025), "trim", bevel=0.005, segments=2)
	m.box((1.88, 0.025, 0.075), (0.0, 0.2925, 0.0375), "trim", bevel=0.004, segments=2)
	bolts_row(m, [(-0.85 + 0.34 * i, 0.14, 0.05) for i in range(6)], radius=0.012, height=0.012)
	m.box((1.88, 0.06, 0.05), (0.0, 1.0, 0.025), "trim", bevel=0.006, segments=2)
	for bx in (-0.7, 0.0, 0.7):
		m.box((0.04, 0.1, 0.045), (bx, 0.96, 0.0225), "steel", bevel=0.004, segments=1)
	# tuberia con bridas, abrazaderas y valvula
	m.cyl((0.11, 1.88, 0.11), (0.0, 2.88, 0.15), "pipe", segs=16, rot=(0.0, 0.0, 90.0), bevel=0.003, segments=1)
	for fx in (-0.62, 0.62):
		m.cyl((0.17, 0.035, 0.17), (fx, 2.88, 0.15), "pipe", segs=16, rot=(0.0, 0.0, 90.0), bevel=0.004, segments=1)
		bolts_row(m, [(fx + 0.02, 2.88 + 0.06 * dy, 0.15 + 0.06 * dz) for dy, dz in ((1, 0), (-1, 0), (0, 1), (0, -1))], radius=0.01, height=0.012)
	for cx in (-0.85, -0.2, 0.3, 0.85):
		m.box((0.04, 0.04, 0.12), (cx, 2.88, 0.075), "trim", bevel=0.003, segments=1)
		m.box((0.04, 0.16, 0.025), (cx, 2.88, 0.2), "trim", bevel=0.003, segments=1)
	m.box((0.12, 0.1, 0.12), (0.2, 2.97, 0.15), "pipe", bevel=0.01, segments=2) # cuerpo de la valvula
	m.cyl((0.03, 0.14, 0.03), (0.2, 3.07, 0.15), "steel", segs=8)
	m.cyl((0.16, 0.022, 0.16), (0.2, 3.15, 0.15), "steel", segs=16, bevel=0.004, segments=1)
	for spoke in range(2):
		m.box((0.16, 0.016, 0.016), (0.2, 3.15, 0.15), "steel", rot=(0.0, 90.0 * spoke, 0.0))
	# bandeja de cables con cables
	m.box((1.88, 0.012, 0.18), (0.0, 2.3, 0.1), "steel", bevel=0.002, segments=1)
	for z in (0.012, 0.188):
		m.box((1.88, 0.06, 0.012), (0.0, 2.33, z), "steel", bevel=0.002, segments=1)
	for bx in (-0.8, 0.0, 0.8):
		m.box((0.03, 0.03, 0.1), (bx, 2.285, 0.04), "steel", bevel=0.003, segments=1)
	for i, (z, mat) in enumerate(((0.05, "cable_a"), (0.1, "cable_b"), (0.15, "cable_c"), (0.075, "cable_a"))):
		pts = [(-0.94 + 0.235 * k, 2.325 + (0.012 if i == 3 else 0.0) + 0.006 * ((k + i) % 2), z) for k in range(9)]
		m.tube(pts, 0.017, mat, segs=8, ref=(0.0, 1.0, 0.0))
	# conducto vertical
	m.cyl((0.045, 2.0, 0.045), (0.82, 1.3, 0.06), "rubber", segs=10, bevel=0.003, segments=1)
	for cy in (0.5, 1.2, 1.9):
		m.box((0.075, 0.035, 0.05), (0.82, cy, 0.04), "steel", bevel=0.004, segments=1)
	# remate superior
	m.box((2.0, 0.08, 0.1), (0.0, 3.16, 0.04), "trim", bevel=0.006, segments=2)
	return m.finish(mats)


def build_corner(mats):
	m = RefMesh("corner")
	m.box((0.5, 3.2, 0.5), (-0.25, 1.6, -0.25), "concrete")
	m.box((0.54, 0.06, 0.54), (-0.25, 3.17, -0.25), "trim", bevel=0.006, segments=2) # tapa superior
	# angular de proteccion del vertice interior
	m.box((0.08, 3.0, 0.03), (0.04, 1.68, 0.015), "pillar", bevel=0.004, segments=2)
	m.box((0.03, 3.0, 0.08), (0.015, 1.68, 0.04), "pillar", bevel=0.004, segments=2)
	bolts_row(m, [(0.05, 0.4 + 0.4 * i, 0.03) for i in range(7)], radius=0.011, height=0.012)
	m.box((0.09, 0.28, 0.09), (0.045, 0.14, 0.045), "trim", bevel=0.005, segments=2)
	m.box((0.5, 0.28, 0.05), (-0.25, 0.14, 0.025), "trim", bevel=0.005, segments=2)
	m.box((0.05, 0.28, 0.5), (0.025, 0.14, -0.25), "trim", bevel=0.005, segments=2)
	return m.finish(mats)


def build_light(mats):
	m = RefMesh("light")
	m.box((0.92, 0.24, 0.03), (0.0, 0.0, -0.11), "trim", bevel=0.005, segments=2)
	m.box((0.86, 0.17, 0.12), (0.0, 0.0, -0.035), "trim", bevel=0.01, segments=2)
	for side in (-1.0, 1.0): # tapas y soportes
		m.box((0.04, 0.2, 0.14), (side * 0.43, 0.0, -0.03), "steel", bevel=0.004, segments=1)
		m.box((0.03, 0.03, 0.08), (side * 0.38, 0.0, 0.03), "steel", bevel=0.003, segments=1)
	for i in range(9): # jaula de proteccion
		m.box((0.012, 0.16, 0.012), (-0.36 + i * 0.09, 0.0, 0.092), "steel")
	for dy in (-0.075, 0.075):
		m.box((0.76, 0.012, 0.012), (0.0, dy, 0.092), "steel")
	bolts_row(m, [(sx * 0.4, sy * 0.09, -0.092) for sx in (-1, 1) for sy in (-1, 1)], radius=0.01, height=0.012)
	return m.finish(mats)


def build_light_glow(mats):
	m = RefMesh("light_glow")
	m.cyl((0.1, 0.74, 0.1), (0.0, 0.0, 0.045), "steel", segs=14, rot=(0.0, 0.0, 90.0))
	obj = m.finish(mats, uv=False)
	return obj


def bake_asset(name, obj, size, paths, samples, extra=(), home_x=0.0):
	"""Hornea, finaliza y exporta un asset. Mientras se hornea esta en `home_x` (lejos de los demas)."""
	bpy.context.view_layer.update()
	objs = [obj] + list(extra)
	print("[%s] tris=%d" % (name, triangle_count(objs)))
	bake_atlas([obj], name, size, paths["tex"], samples=samples)
	finalize_materials([obj], name)
	write_pbr_tres(os.path.join(paths["mat"], name + ".tres"), name, paths["tex_res"])
	for o in objs:
		o.location.x -= home_x
	bpy.context.view_layer.update()
	low, high = world_bounds_godot(objs)
	s = high - low
	print("[%s] size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (name, s.x, s.y, s.z, low.x, low.y, low.z))
	print("[%s] -> %s" % (name, export_glb(objs, os.path.join(paths["glb"], name + ".glb"))))
	for o in objs:
		o.location.x += home_x


def main():
	options = common_args()
	paths = repo_paths(options)
	samples = int(options["samples"])
	reset_scene()
	mats = make_materials()
	wall = build_wall(mats)
	wall.name = "ref_wall"
	corner = build_corner(mats)
	corner.name = "ref_wall_corner"
	light = build_light(mats)
	light.name = "ref_wall_light"
	glow = build_light_glow(mats)
	glow.name = "emit_tube"
	for obj, x in ((corner, 6.0), (light, 12.0), (glow, 12.0)):
		obj.location.x += x
	bake_asset("ref_wall", wall, 2048, paths, samples)
	bake_asset("ref_wall_corner", corner, 1024, paths, samples, home_x=6.0)
	glow.data.materials.clear()
	glow.data.materials.append(bpy.data.materials.new("ref_wall_light_glow"))
	bake_asset("ref_wall_light", light, 512, paths, samples, extra=[glow], home_x=12.0)
	write_emissive_tres(os.path.join(paths["mat"], "ref_wall_light_glow.tres"), "ref_wall_light_glow", "DDE8F0", "DDE8F0", 2.5)
	save_blend(options, "ref_wall.blend")


main()
