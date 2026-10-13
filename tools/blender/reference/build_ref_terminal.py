"""Terminal cientifica industrial de referencia (docs/art/LAB_REFERENCE_SCENE_SPEC.md).

    blender --background --factory-startup --python tools/blender/reference/build_ref_terminal.py -- \
        --repo D:/Projects/github/final-thaw --blend-dir D:/Projects/evidence/final-thaw/lab-ref-source

Gabinete atornillado con puerta de acceso y rejillas, teclado inclinado de 65 teclas, monitor con
bisel recesado y pantalla emisiva (malla `emit_screen` aparte para que el gameplay pueda recolorear).
Frente = +Z. Pivote: centro de la base en el suelo.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
import numpy as np  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402
from ref_common import (RefMesh, bake_atlas, common_args, export_glb, finalize_materials, proc_material,  # noqa: E402
	repo_paths, reset_scene, save_blend, save_rgb_png, smart_uv, triangle_count, world_bounds_godot,
	write_emissive_tres, write_pbr_tres)

ASSET = "ref_terminal"
SCREEN_TEXTURE = "ref_terminal_screen_emission.png"
TEXTURE_SIZE = 1024
MONITOR_TILT = -25.0
MONITOR_CENTER = Vector((0.0, 1.2, 0.14))
SCREEN_SIZE = (0.78, 0.44)
SLOPE_FRONT = (0.34, 0.86)  # (z, y) del borde delantero del teclado
SLOPE_BACK = (0.06, 1.0)


def make_materials():
	return {
		"cab": proc_material("cab", base="4E5F66", rough=0.55, rough_var=0.25, metal=0.12, edge_color="9AA0A2", edge_amount=0.7,
			edge_radius=0.01, edge_metal=0.5, dirt=0.7, ao_distance=0.1, stain=0.3, mottle=0.3, scale=7.0, bump=0.3,
			bump_scale=160.0, grime_height=0.6, grime=0.55, scratch=0.6, scratch_scale=10.0),
		"panel": proc_material("panel", base="66787F", rough=0.5, rough_var=0.25, metal=0.1, edge_color="A9AFB1", edge_amount=0.6,
			edge_radius=0.006, edge_metal=0.5, dirt=0.7, ao_distance=0.06, stain=0.35, mottle=0.3, scale=9.0, bump=0.3,
			bump_scale=170.0, grime_height=0.6, grime=0.5, scratch=0.6, scratch_scale=14.0),
		"trim": proc_material("trim", base="2C3236", rough=0.5, rough_var=0.2, metal=0.3, edge_color="8C9396", edge_amount=0.7,
			edge_radius=0.004, edge_metal=0.6, dirt=0.65, ao_distance=0.05, mottle=0.3, scale=12.0, bump=0.3, bump_scale=190.0,
			scratch=0.4, scratch_scale=16.0),
		"steel": proc_material("steel", base="747B7F", rough=0.4, rough_var=0.25, metal=0.85, edge_color="C0C5C7", edge_amount=0.5,
			edge_radius=0.003, edge_metal=0.1, dirt=0.6, ao_distance=0.03, stain=0.3, mottle=0.3, scale=22.0, bump=0.2,
			bump_scale=220.0, scratch=0.4, scratch_scale=24.0),
		"rubber": proc_material("rubber", base="17191B", rough=0.8, rough_var=0.12, dirt=0.3, mottle=0.2, scale=22.0, bump=0.2),
		"keys": proc_material("keys", base="23272A", rough=0.45, rough_var=0.2, edge_color="5E6568", edge_amount=0.6, edge_radius=0.004,
			dirt=0.5, ao_distance=0.02, mottle=0.35, scale=40.0, bump=0.2, bump_scale=200.0),
		"cable": proc_material("cable", base="141619", rough=0.6, rough_var=0.1, dirt=0.3, mottle=0.2, scale=30.0, bump=0.2),
		"screen": proc_material("screen", base="000000"),
		"led": proc_material("led", base="000000"),
	}


def tilted(local):
	"""Posicion y rotacion de un elemento en el sistema inclinado del monitor."""
	rot = Matrix.Rotation(math.radians(MONITOR_TILT), 3, "X")
	return MONITOR_CENTER + rot @ Vector(local), (MONITOR_TILT, 0.0, 0.0)


def screen_texture(path):
	"""Interfaz ambar sintetica (sin texto legible): marcos, listas, onda, barras y escaneo."""
	w, h = 512, 288
	rng = np.random.default_rng(7)
	img = np.zeros((h, w, 3), dtype=np.float32)
	img[:, :] = (0.012, 0.009, 0.004)
	amber = np.array((1.0, 0.72, 0.25), dtype=np.float32)

	def rect(x0, y0, x1, y1, k=1.0):
		img[y0:y1, x0:x1] = np.maximum(img[y0:y1, x0:x1], amber * k)

	rect(0, 0, w, 3)
	rect(0, h - 3, w, h)
	rect(0, 0, 3, h)
	rect(w - 3, 0, w, h)
	rect(10, 10, w - 10, 30, 0.55)
	for row in range(9): # lista a la izquierda
		width = int(rng.integers(40, 120))
		rect(14, 46 + row * 22, 14 + width, 54 + row * 22, 0.85)
		rect(14 + width + 6, 46 + row * 22, 14 + width + 14, 54 + row * 22, 0.35)
	for gx in range(150, 356, 25): # rejilla
		rect(gx, 60, gx + 1, 200, 0.18)
	for gy in range(60, 200, 28):
		rect(150, gy, 356, gy + 1, 0.18)
	rect(148, 58, 358, 60, 0.7)
	rect(148, 200, 358, 202, 0.7)
	for x in range(150, 356): # onda central
		y = int(130 + 40 * math.sin(x * 0.07) + 18 * math.sin(x * 0.19 + 1.0))
		rect(x, y - 1, x + 1, y + 2, 1.0)
	for i in range(10): # barras de la derecha
		height = int(rng.integers(20, 130))
		rect(378 + i * 12, 200 - height, 386 + i * 12, 200, 0.9 if i % 4 else 0.5)
	rect(378, 206, 500, 208, 0.6)
	for i in range(18): # linea de estado
		if rng.random() > 0.35:
			rect(16 + i * 26, 250, 34 + i * 26, 262, 0.7)
	img[::2] *= 0.86 # lineas de escaneo
	save_rgb_png(img, path)


def build(mats):
	m = RefMesh("terminal")
	# --- gabinete inferior
	m.box((1.04, 0.08, 0.74), (0.0, 0.04, 0.0), "rubber", bevel=0.008, segments=2)
	m.box((1.0, 0.7, 0.7), (0.0, 0.43, 0.0), "cab", bevel=0.016, segments=3)
	door_c = (0.0, 0.45, 0.352)
	m.box((0.84, 0.54, 0.008), (door_c[0], door_c[1], 0.349), "trim") # junta oscura alrededor
	m.box((0.8, 0.5, 0.012), door_c, "panel", bevel=0.004, segments=2) # puerta de acceso
	for sx in (-1, 1):
		for sy in (-1, 1):
			m.cyl((0.026, 0.012, 0.026), (sx * 0.36, door_c[1] + sy * 0.22, 0.362), "steel", segs=6, rot=(90.0, 0.0, 0.0), bevel=0.002, segments=1)
	m.box((0.14, 0.05, 0.03), (0.28, door_c[1], 0.366), "trim", bevel=0.005, segments=2) # cierre
	m.box((0.06, 0.02, 0.016), (0.28, door_c[1], 0.384), "steel", bevel=0.003, segments=1)
	for i in range(3): # rejilla inferior delantera
		m.box((0.7, 0.014, 0.02), (0.0, 0.12 + i * 0.03, 0.352), "trim", rot=(-20.0, 0.0, 0.0), bevel=0.002, segments=1)
	for side in (-1.0, 1.0): # rejillas laterales y asas
		for i in range(6):
			m.box((0.014, 0.02, 0.36), (side * 0.5, 0.2 + i * 0.07, 0.0), "trim", bevel=0.002, segments=1)
		m.box((0.03, 0.04, 0.22), (side * 0.53, 0.6, 0.0), "steel", bevel=0.006, segments=2)
		for hz in (-0.1, 0.1):
			m.box((0.045, 0.03, 0.03), (side * 0.515, 0.6, hz), "steel", bevel=0.004, segments=1)
	# panel de conexiones lateral derecho + cable al suelo
	m.box((0.012, 0.16, 0.26), (0.505, 0.3, 0.12), "trim", bevel=0.003, segments=1)
	for i in range(3):
		m.box((0.02, 0.04, 0.05), (0.512, 0.3, 0.04 + i * 0.075), "rubber", bevel=0.004, segments=1)
	m.box((0.04, 0.04, 0.06), (0.55, 0.3, 0.115), "trim", bevel=0.005, segments=1) # conector
	m.tube([(0.57, 0.3, 0.115), (0.64, 0.3, 0.115), (0.74, 0.22, 0.13), (0.82, 0.07, 0.18), (0.95, 0.02, 0.32), (1.2, 0.02, 0.55)],
		0.016, "cable", segs=8, ref=(0.0, 1.0, 0.0))
	# --- cubierta del teclado: cuna inclinada
	m.prism([(0.35, 0.78), (SLOPE_FRONT[0], SLOPE_FRONT[1]), (SLOPE_BACK[0], SLOPE_BACK[1]), (0.06, 0.78)], -0.5, 0.5, "cab", bevel=0.01, segments=2)
	slope_angle = math.degrees(math.atan2(SLOPE_BACK[1] - SLOPE_FRONT[1], SLOPE_FRONT[0] - SLOPE_BACK[0]))
	rows, cols = 5, 13
	for r in range(rows):
		u = 0.08 + (0.34 + r * 0.14) * 0.8
		pz = SLOPE_FRONT[0] + (SLOPE_BACK[0] - SLOPE_FRONT[0]) * u
		py = SLOPE_FRONT[1] + (SLOPE_BACK[1] - SLOPE_FRONT[1]) * u
		for c in range(cols):
			if r == 0 and 3 <= c <= 9: # barra espaciadora en la fila delantera
				if c == 6:
					m.box((0.3, 0.014, 0.034), (0.0, py + 0.009, pz), "keys", rot=(slope_angle, 0.0, 0.0), bevel=0.003, segments=1)
				continue
			height = 0.012 + 0.002 * ((c * 7 + r * 3) % 3)
			m.box((0.04, height, 0.034), ((c - 6) * 0.0605, py + height * 0.5 + 0.003, pz), "keys", rot=(slope_angle, 0.0, 0.0), bevel=0.003, segments=1)
	# --- monitor: marco recesado y carcasa trasera
	for local, size in (((0.0, 0.255, 0.0), (0.94, 0.07, 0.1)), ((0.0, -0.255, 0.0), (0.94, 0.07, 0.1)),
			((-0.435, 0.0, 0.0), (0.07, 0.44, 0.1)), ((0.435, 0.0, 0.0), (0.07, 0.44, 0.1))):
		center, rot = tilted(local)
		m.box(size, center, "cab", rot=rot, bevel=0.012, segments=3)
	center, rot = tilted((0.0, 0.0, -0.035))
	m.box((0.86, 0.46, 0.03), center, "trim", rot=rot) # fondo del hueco, bajo el cristal
	center, rot = tilted((0.0, 0.0, -0.16))
	m.box((0.8, 0.5, 0.24), center, "cab", rot=rot, bevel=0.02, segments=3) # carcasa trasera
	for i in range(7): # ventilacion trasera superior
		center, rot = tilted((-0.27 + i * 0.09, 0.255, -0.2))
		m.box((0.04, 0.012, 0.16), center + Vector((0.0, 0.04, 0.0)), "trim", rot=rot, bevel=0.002, segments=1)
	for sx in (-1.0, 1.0): # soportes del monitor
		center, rot = tilted((sx * 0.43, -0.2, -0.04))
		m.box((0.05, 0.06, 0.09), center, "steel", rot=rot, bevel=0.005, segments=1)
	obj = m.finish(mats)

	# --- pantalla (malla separada con UV propios) y LEDs
	scr = RefMesh("emit_screen")
	hw, hh = SCREEN_SIZE[0] * 0.5, SCREEN_SIZE[1] * 0.5
	corners = []
	for lx, ly in ((-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)):
		center, _ = tilted((lx, ly, 0.0))
		corners.append(center)
	scr.quad(corners, "screen", [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)])
	screen = scr.finish(mats, uv=False, cull_down=False, sharp=False)
	leds = RefMesh("emit_leds")
	for i in range(4):
		center, rot = tilted((-0.36 + i * 0.05, -0.255, 0.052))
		leds.box((0.014, 0.014, 0.01), center, "led", rot=rot)
	led_obj = leds.finish(mats, uv=False, cull_down=False)
	return obj, screen, led_obj


def main():
	options = common_args()
	paths = repo_paths(options)
	samples = int(options["samples"])
	reset_scene()
	mats = make_materials()
	body, screen, leds = build(mats)
	body.name = ASSET
	bpy.context.view_layer.update()
	smart_uv(body, 0.002)
	print("[ref_terminal] tris=%d (+pantalla/leds %d)" % (triangle_count([body]), triangle_count([screen, leds])))
	bake_atlas([body], ASSET, TEXTURE_SIZE, paths["tex"], samples=samples)
	finalize_materials([body], ASSET)
	screen.data.materials.clear()
	screen.data.materials.append(bpy.data.materials.new("ref_terminal_screen"))
	leds.data.materials.clear()
	leds.data.materials.append(bpy.data.materials.new("ref_terminal_led"))
	screen_texture(os.path.join(paths["tex"], SCREEN_TEXTURE))
	write_pbr_tres(os.path.join(paths["mat"], ASSET + ".tres"), ASSET, paths["tex_res"])
	write_emissive_tres(os.path.join(paths["mat"], "ref_terminal_screen.tres"), "ref_terminal_screen", "0A0804", "FFFFFF", 0.7,
		paths["tex_res"] + "/" + SCREEN_TEXTURE)
	write_emissive_tres(os.path.join(paths["mat"], "ref_terminal_led.tres"), "ref_terminal_led", "2A1A05", "F2B340", 3.0)
	low, high = world_bounds_godot([body, screen, leds])
	size = high - low
	print("[ref_terminal] size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (size.x, size.y, size.z, low.x, low.y, low.z))
	print("[ref_terminal] -> " + export_glb([body, screen, leds], os.path.join(paths["glb"], ASSET + ".glb")))
	save_blend(options, "ref_terminal.blend")


main()
