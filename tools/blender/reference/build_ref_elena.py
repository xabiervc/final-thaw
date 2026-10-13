"""Elena de referencia (docs/art/LAB_REFERENCE_SCENE_SPEC.md), basada en elena_vast_concept.png.

    blender --background --factory-startup --python tools/blender/reference/build_ref_elena.py -- \
        --repo D:/Projects/github/final-thaw --blend-dir D:/Projects/evidence/final-thaw/lab-ref-source [--nobake 1]

Modelado por script (no esculpido): abrigo largo de doble capa con frente abierto y pliegues,
jersey de cuello alto, mangas con puños de vivos, brazo derecho doblado con el Aster, pantalon cargo,
botas de goma de caña alta, cabeza con rasgos simples, pelo con coleta y mochila con correas,
herramientas y baliza apagada (decision D2). Frente = +Z. Pose estatica en A. Piezas rigidas con
pivotes en las articulaciones, sin esqueleto. "R" es la derecha anatomica de Elena (-X).
Un atlas de 2048 x 2048 (albedo, normal, ORM) horneado en Cycles desde materiales procedurales.
"""

import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402
import numpy as np  # noqa: E402
from mathutils import Matrix, Vector  # noqa: E402
from ref_common import (RefMesh, bake_atlas, common_args, export_glb, finalize_materials, godot_to_blender,  # noqa: E402
	proc_material, repo_paths, reset_scene, save_blend, save_rgb_png, select_only, smart_uv, triangle_count,
	world_bounds_godot, write_emissive_tres, write_pbr_tres)

ASSET = "ref_elena"
ATLAS = 2048
AT = math.pi * 2.0
V = Vector

# rectangulos del atlas (u0, v0, u1, v1), origen abajo-izquierda
RECTS = {
	"Torso": (0.0, 0.0, 0.5, 0.5),
	"ArmL": (0.5, 0.0, 0.75, 0.25), "ArmR": (0.75, 0.0, 1.0, 0.25),
	"LegL": (0.5, 0.25, 0.75, 0.5), "LegR": (0.75, 0.25, 1.0, 0.5),
	"Head": (0.0, 0.5, 0.5, 0.75), "Backpack": (0.5, 0.5, 1.0, 0.75),
	"Hips": (0.0, 0.75, 0.25, 1.0), "Aster": (0.25, 0.75, 0.5, 1.0),
}
PIVOTS = {
	"Hips": (0.0, 0.92, 0.0), "Torso": (0.0, 1.0, 0.0), "Head": (0.0, 1.46, 0.0),
	"ArmL": (0.205, 1.36, 0.0), "ArmR": (-0.205, 1.36, 0.0), "Aster": (-0.16, 1.03, 0.37),
	"Backpack": (0.0, 1.13, -0.27), "LegL": (0.10, 0.92, 0.0), "LegR": (-0.10, 0.92, 0.0),
}
PARENTS = {"Torso": "Hips", "Head": "Torso", "ArmL": "Torso", "ArmR": "Torso", "Aster": "ArmR", "Backpack": "Torso", "LegL": "Hips", "LegR": "Hips"}


def make_materials():
	def cloth(name, base, **kw):
		args = dict(rough=0.86, rough_var=0.12, dirt=0.55, ao_distance=0.05, stain=0.25, mottle=0.28, scale=9.0, bump=0.5,
			bump_scale=110.0, weave=0.55, grime_height=0.9, grime=0.45, scratch=0.0)
		args.update(kw)
		return proc_material(name, base=base, **args)

	return {
		"coat": cloth("coat", "2A4A50", edge_color="4F7076", edge_amount=0.45, edge_radius=0.012, grime_height=1.15, grime=0.5),
		"lining": cloth("lining", "162427", edge_color="2C3F43", edge_amount=0.3, grime=0.2),
		"piping": proc_material("piping", base="8EB1B1", rough=0.42, rough_var=0.15, edge_color="C4D8D6", edge_amount=0.35, edge_radius=0.004,
			dirt=0.5, ao_distance=0.03, stain=0.3, mottle=0.25, scale=20.0, bump=0.3, bump_scale=160.0),
		"knit": cloth("knit", "232628", rough=0.92, weave=0.85, bump=0.7, bump_scale=190.0, grime=0.1),
		"trousers": cloth("trousers", "30353A", rough=0.9, weave=0.4, bump_scale=130.0, grime_height=0.9, grime=0.65, stain=0.35),
		"boot": proc_material("boot", base="1D3234", rough=0.32, rough_var=0.22, edge_color="5C7572", edge_amount=0.5, edge_radius=0.006,
			dirt=0.65, ao_distance=0.04, stain=0.45, mottle=0.3, scale=14.0, bump=0.35, bump_scale=120.0, grime_height=0.35, grime=0.8,
			scratch=0.5, scratch_scale=16.0),
		"sole": proc_material("sole", base="121415", rough=0.85, rough_var=0.1, dirt=0.4, mottle=0.3, scale=25.0, bump=0.5, bump_scale=140.0,
			grime_height=0.1, grime=0.7),
		"skin": proc_material("skin", base="D2A68E", rough=0.55, rough_var=0.18, dirt=0.35, dirt_color="5A2F2A", ao_distance=0.025,
			mottle=0.2, scale=26.0, bump=0.18, bump_scale=240.0),
		"lips": proc_material("lips", base="A5675F", rough=0.45, rough_var=0.1, dirt=0.2, mottle=0.1, scale=30.0, bump=0.1),
		"eye": proc_material("eye", base="171210", rough=0.2, rough_var=0.05),
		"hair": proc_material("hair", base="241A17", rough=0.66, rough_var=0.15, edge_color="4A3A30", edge_amount=0.4, edge_radius=0.01,
			dirt=0.4, ao_distance=0.04, mottle=0.45, scale=36.0, bump=0.45, bump_scale=420.0),
		"canvas": cloth("canvas", "2C4745", rough=0.88, weave=0.5, bump_scale=90.0, edge_color="5A7471", edge_amount=0.5, grime_height=1.0, grime=0.6),
		"strap": cloth("strap", "1B1E20", rough=0.85, weave=0.7, bump_scale=210.0, grime=0.3),
		"steel": proc_material("steel", base="777E82", rough=0.4, rough_var=0.25, metal=0.85, edge_color="C3C8CA", edge_amount=0.5,
			edge_radius=0.003, edge_metal=0.1, dirt=0.6, ao_distance=0.02, stain=0.3, mottle=0.3, scale=24.0, bump=0.2, bump_scale=230.0,
			scratch=0.4, scratch_scale=26.0),
		"beacon": proc_material("beacon", base="4C3416", rough=0.3, rough_var=0.1, dirt=0.4, mottle=0.2, scale=30.0, bump=0.1),
		"device": proc_material("device", base="1E2326", rough=0.4, rough_var=0.2, edge_color="5C6468", edge_amount=0.6, edge_radius=0.004,
			dirt=0.5, ao_distance=0.02, mottle=0.3, scale=30.0, bump=0.2, bump_scale=200.0),
		"aster": proc_material("aster", base="000000"),
	}


def arc(y, rx, rz, cz, n, a0=0.0, a1=AT, closed=True, fx=0.0, amp=0.0, m=6.0, ph=0.0):
	"""Anillo (elipse) en el plano XZ. theta=0 mira a +Z; crece hacia +X. amp/m: pliegues radiales."""
	pts = []
	for k in range(n):
		th = a0 + (a1 - a0) * k / (n if closed else n - 1)
		f = 1.0 + amp * math.sin(m * th + ph)
		pts.append(V((fx + rx * f * math.sin(th), y, cz + rz * f * math.cos(th))))
	return pts


def join(objects, name):
	select_only(objects[0])
	for o in objects:
		o.select_set(True)
	bpy.context.view_layer.objects.active = objects[0]
	if len(objects) > 1:
		bpy.ops.object.join()
	result = bpy.context.view_layer.objects.active
	result.name = name
	return result


def finish_part(name, soft, hard, mats, subsurf=0):
	"""soft: RefMesh con subdivision; hard: RefMesh o None sin subdivision. Devuelve objeto con UV en su rectangulo."""
	objs = [soft.finish(mats, subsurf=subsurf, uv=False, cull_down=False, recalc=False)] if soft is not None else []
	if hard is not None:
		objs.append(hard.finish(mats, subsurf=0, uv=False, cull_down=False))
	obj = join(objs, name)
	smart_uv(obj, 0.003)
	rect = RECTS[name]
	uv = obj.data.uv_layers.active.data
	xs = [d.uv.x for d in uv]
	ys = [d.uv.y for d in uv]
	margin = 0.004
	sx = (rect[2] - rect[0] - 2 * margin) / max(max(xs) - min(xs), 1e-6)
	sy = (rect[3] - rect[1] - 2 * margin) / max(max(ys) - min(ys), 1e-6)
	scale = min(sx, sy)
	for d in uv:
		d.uv.x = rect[0] + margin + (d.uv.x - min(xs)) * scale
		d.uv.y = rect[1] + margin + (d.uv.y - min(ys)) * scale
	return obj


# --------------------------------------------------------------------------------------------
# Piezas
# --------------------------------------------------------------------------------------------


def build_torso(mats):
	soft = RefMesh("torso_soft")
	hard = RefMesh("torso_hard")
	rows = [  # y, rx, rz, cz, hueco frontal (rad)
		(0.78, 0.285, 0.200, -0.010, 0.42), (0.86, 0.262, 0.190, -0.008, 0.38), (0.95, 0.240, 0.180, -0.005, 0.33),
		(1.04, 0.222, 0.168, 0.000, 0.30), (1.13, 0.226, 0.172, 0.005, 0.28), (1.22, 0.232, 0.178, 0.010, 0.27),
		(1.31, 0.226, 0.172, 0.008, 0.26), (1.38, 0.205, 0.156, 0.004, 0.25), (1.42, 0.160, 0.128, 0.000, 0.24),
	]
	thickness = 0.012
	outer, inner = [], []
	for y, rx, rz, cz, gap in rows:
		amp = 0.05 * max(0.0, (1.06 - y) / 0.28) ** 1.4
		outer.append(arc(y, rx, rz, cz, 21, gap, AT - gap, closed=False, amp=amp, m=6.0, ph=1.7 * y))
		inner.append(arc(y, rx - thickness, rz - thickness, cz, 21, gap, AT - gap, closed=False, amp=amp, m=6.0, ph=1.7 * y))
	soft.loft(outer, "coat", closed=False)
	soft.loft(inner, "lining", closed=False, flip=True)
	# cuello alto (doble capa, abierto al frente)
	c_out, c_in = [], []
	for y, rx, rz in ((1.39, 0.140, 0.115), (1.44, 0.124, 0.106), (1.49, 0.118, 0.104), (1.535, 0.120, 0.106)):
		c_out.append(arc(y, rx, rz, 0.0, 17, 0.55, AT - 0.55, closed=False))
		c_in.append(arc(y, rx - 0.010, rz - 0.010, 0.0, 17, 0.55, AT - 0.55, closed=False))
	soft.loft(c_out, "coat", closed=False)
	soft.loft(c_in, "lining", closed=False, flip=True)
	# jersey de cuello alto bajo el abrigo
	knit = []
	for y, rx, rz, cz in ((0.84, 0.195, 0.145, 0.0), (0.98, 0.188, 0.140, 0.0), (1.12, 0.198, 0.148, 0.005), (1.26, 0.200, 0.150, 0.01),
			(1.36, 0.186, 0.138, 0.005), (1.42, 0.105, 0.088, 0.0), (1.48, 0.060, 0.058, 0.008)):
		knit.append(arc(y, rx, rz, cz, 20))
	soft.loft(knit, "knit", cap_start=True, cap_end=False)
	# vivos delanteros (a lo largo del canto del abrigo) y vivos del cuello
	for side in (-1, 1):
		edge = []
		for (y, rx, rz, cz, gap), o, i in zip(rows, outer, inner):
			p = o[0] if side < 0 else o[-1]
			q = i[0] if side < 0 else i[-1]
			edge.append((p + q) * 0.5)
		hard.tube(edge, 0.0105, "piping", segs=6, ref=(1.0, 0.0, 0.0))
		neck_edge = [(c_out[k][0] if side < 0 else c_out[k][-1]) * 0.5 + (c_in[k][0] if side < 0 else c_in[k][-1]) * 0.5 for k in range(len(c_out))]
		hard.tube(neck_edge, 0.008, "piping", segs=6, ref=(1.0, 0.0, 0.0))
	# canesu de los hombros (parche gris-cian) y solapas de bolsillo
	for side in (-1.0, 1.0):
		hard.sphere((0.12, 0.04, 0.20), (side * 0.140, 1.384, 0.0), "piping", u=12, v=8, rot=(0.0, 0.0, side * -12.0))
		hard.box((0.13, 0.15, 0.03), (side * 0.145, 0.945, 0.168), "coat", rot=(-4.0, side * -8.0, 0.0), bevel=0.007, segments=2)
		hard.box((0.13, 0.014, 0.034), (side * 0.145, 1.018, 0.176), "piping", rot=(-4.0, side * -8.0, 0.0), bevel=0.003, segments=1)
		hard.cyl((0.024, 0.01, 0.024), (side * 0.145, 0.9, 0.186), "steel", segs=8, rot=(86.0, 0.0, 0.0), bevel=0.002, segments=1)
	return finish_part("Torso", soft, hard, mats, subsurf=1)


def sleeve(side, forward):
	if not forward:
		path = [(0.200, 1.37, 0.0), (0.232, 1.24, 0.005), (0.248, 1.10, 0.015), (0.250, 0.98, 0.030), (0.248, 0.86, 0.050), (0.243, 0.77, 0.060)]
		radii = [0.062, 0.057, 0.052, 0.050, 0.047, 0.044]
	else:
		path = [(-0.200, 1.37, 0.0), (-0.230, 1.24, 0.0), (-0.242, 1.12, 0.02), (-0.242, 1.03, 0.07), (-0.228, 1.00, 0.17), (-0.205, 1.005, 0.265)]
		radii = [0.062, 0.057, 0.052, 0.050, 0.047, 0.044]
	return path, radii


def build_arm(name, side, mats):
	forward = side < 0
	path, radii = sleeve(side, forward)
	soft = RefMesh(name + "_soft")
	hard = RefMesh(name + "_hard")
	ref = (1.0, 0.0, 0.0)
	soft.tube(path, radii, "coat", segs=12, ref=ref, smooth=2)
	# puño de vivos
	cuff_start = V(path[-1]) + (V(path[-1]) - V(path[-2])).normalized() * -0.045
	hard.tube([cuff_start, V(path[-1]) + (V(path[-1]) - V(path[-2])).normalized() * 0.004], radii[-1] + 0.006, "piping", segs=10, ref=ref)
	direction = (V(path[-1]) - V(path[-2])).normalized()
	wrist = V(path[-1]) + direction * 0.005
	if not forward: # mano colgando: mitten con pulgar
		hand = [wrist, wrist + V((-0.004, -0.045, 0.012)), wrist + V((-0.006, -0.095, 0.022)), wrist + V((-0.004, -0.135, 0.028))]
		soft.tube(hand, [(0.026, 0.040), (0.030, 0.042), (0.026, 0.036), (0.014, 0.020)], "skin", segs=8, ref=(1.0, 0.0, 0.0))
		soft.tube([wrist + V((-0.018, -0.045, 0.045)), wrist + V((-0.040, -0.085, 0.060)), wrist + V((-0.046, -0.110, 0.066))],
			[0.016, 0.014, 0.010], "skin", segs=6, ref=(0.0, 0.0, 1.0))
	else: # mano sosteniendo el Aster
		hand = [wrist, wrist + V((0.028, -0.004, 0.045)), wrist + V((0.050, -0.006, 0.095)), wrist + V((0.060, -0.004, 0.130))]
		soft.tube(hand, [(0.030, 0.034), (0.034, 0.036), (0.030, 0.032), (0.016, 0.018)], "skin", segs=8, ref=(0.0, 1.0, 0.0))
		soft.tube([wrist + V((0.035, 0.025, 0.040)), wrist + V((0.075, 0.032, 0.070)), wrist + V((0.095, 0.030, 0.098))],
			[0.014, 0.012, 0.009], "skin", segs=6, ref=(0.0, 1.0, 0.0))
	return finish_part(name, soft, hard, mats)


def build_legs(mats):
	out = {}
	for name, side in (("LegL", 1.0), ("LegR", -1.0)):
		x = side * 0.10
		soft = RefMesh(name + "_soft")
		hard = RefMesh(name + "_hard")
		trouser = [(x, 0.95, 0.0), (x * 1.06, 0.79, 0.005), (x * 1.06, 0.63, 0.015), (x * 1.0, 0.52, 0.02), (x, 0.46, 0.012)]
		soft.tube(trouser, [(0.095, 0.092), (0.086, 0.085), (0.078, 0.077), (0.073, 0.073), (0.088, 0.088)], "trousers", segs=14, ref=(0.0, 0.0, 1.0), smooth=2)
		shaft = [(x, 0.47, 0.012), (x, 0.40, 0.014), (x, 0.30, 0.016), (x, 0.20, 0.012), (x, 0.12, 0.004)]
		soft.tube(shaft, [(0.086, 0.087), (0.080, 0.081), (0.072, 0.073), (0.066, 0.068), (0.062, 0.066)], "boot", segs=14, ref=(0.0, 0.0, 1.0), cap_start=False, smooth=2)
		foot = [(x, 0.075, -0.075), (x, 0.062, 0.0), (x, 0.052, 0.085), (x, 0.040, 0.165), (x, 0.034, 0.215)]
		soft.tube(foot, [(0.060, 0.058), (0.063, 0.052), (0.059, 0.045), (0.050, 0.034), (0.030, 0.020)], "boot", segs=14, ref=(1.0, 0.0, 0.0), smooth=2)
		hard.box((0.112, 0.034, 0.30), (x, 0.017, 0.03), "sole", bevel=0.01, segments=2)
		hard.box((0.112, 0.046, 0.075), (x, 0.040, -0.085), "sole", bevel=0.008, segments=2) # tacon
		for i in range(5): # tacos de la suela
			hard.box((0.12, 0.012, 0.022), (x, 0.003, -0.07 + i * 0.07), "sole", bevel=0.003, segments=1)
		hard.box((0.03, 0.15, 0.11), (x + side * 0.085, 0.64, 0.01), "trousers", rot=(0.0, 0.0, side * -6.0), bevel=0.006, segments=2) # bolsillo cargo
		hard.box((0.032, 0.014, 0.115), (x + side * 0.087, 0.71, 0.01), "piping", rot=(0.0, 0.0, side * -6.0), bevel=0.003, segments=1)
		out[name] = finish_part(name, soft, hard, mats)
	return out


def build_hips(mats):
	soft = RefMesh("hips_soft")
	rings = [arc(0.99, 0.172, 0.118, 0.0, 20), arc(0.94, 0.178, 0.122, 0.0, 20), arc(0.88, 0.165, 0.115, 0.0, 20), arc(0.83, 0.130, 0.100, 0.0, 20)]
	soft.loft(rings, "trousers")
	return finish_part("Hips", soft, None, mats)


def build_head(mats):
	soft = RefMesh("head_soft")
	hard = RefMesh("head_hard")
	head = [(y, rx * 1.12, rz * 1.08, cz) for y, rx, rz, cz in ((1.485, 0.040, 0.050, 0.045), (1.510, 0.068, 0.075, 0.035), (1.540, 0.082, 0.092, 0.020), (1.570, 0.090, 0.102, 0.008),
		(1.600, 0.094, 0.108, 0.002), (1.640, 0.095, 0.108, -0.004), (1.670, 0.084, 0.097, -0.010), (1.692, 0.056, 0.066, -0.014),
		(1.703, 0.022, 0.028, -0.016))]
	soft.loft([arc(y, rx, rz, cz, 20) for y, rx, rz, cz in head], "skin")
	soft.tube([(0.0, 1.40, 0.004), (0.0, 1.45, 0.008), (0.0, 1.50, 0.016)], 0.047, "skin", segs=12, ref=(1.0, 0.0, 0.0))
	# pelo: casquete abierto por la cara + coleta
	hair_rows = [(1.50, 2.35), (1.54, 1.95), (1.58, 1.20), (1.62, 0.98), (1.66, 0.70), (1.69, 0.30)]
	cap = []
	for y, gap in hair_rows:
		src = min(head, key=lambda h: abs(h[0] - y))
		cap.append(arc(y, src[1] + 0.012, src[2] + 0.012, src[3] - 0.012, 20, gap, AT - gap, closed=False))
	soft.loft(cap, "hair", closed=False)
	soft.tube([(0.0, 1.575, -0.118), (0.0, 1.535, -0.150), (0.0, 1.45, -0.168), (0.0, 1.37, -0.160), (0.0, 1.31, -0.146), (0.0, 1.27, -0.135)],
		[0.036, 0.040, 0.036, 0.028, 0.017, 0.006], "hair", segs=10, ref=(1.0, 0.0, 0.0), smooth=2)
	hard.cyl((0.08, 0.025, 0.08), (0.0, 1.545, -0.138), "strap", segs=10, rot=(78.0, 0.0, 0.0), bevel=0.003, segments=1) # goma del pelo
	hard.sphere((0.026, 0.042, 0.032), (0.0, 1.572, 0.112), "skin", u=12, v=8) # nariz
	hard.sphere((0.018, 0.045, 0.026), (0.0, 1.600, 0.106), "skin", u=8, v=6, rot=(-18.0, 0.0, 0.0)) # puente
	hard.sphere((0.044, 0.010, 0.018), (0.0, 1.527, 0.092), "lips", u=12, v=6) # labios
	for side in (-1.0, 1.0):
		hard.sphere((0.022, 0.011, 0.012), (side * 0.037, 1.607, 0.106), "eye", u=10, v=6) # ojos
		hard.box((0.044, 0.006, 0.010), (side * 0.039, 1.630, 0.104), "hair", rot=(0.0, side * -14.0, side * -8.0), bevel=0.002, segments=1) # cejas
		hard.sphere((0.014, 0.04, 0.026), (side * 0.104, 1.585, 0.0), "skin", u=8, v=6) # orejas
	return finish_part("Head", soft, hard, mats, subsurf=1)


def build_backpack(mats):
	soft = RefMesh("pack_soft")
	hard = RefMesh("pack_hard")
	soft.box((0.34, 0.44, 0.20), (0.0, 1.13, -0.27), "canvas", bevel=0.045, segments=3)
	soft.box((0.36, 0.13, 0.22), (0.0, 1.325, -0.27), "canvas", bevel=0.05, segments=3)
	soft.box((0.28, 0.20, 0.07), (0.0, 1.03, -0.385), "canvas", bevel=0.03, segments=3)
	for side in (-1.0, 1.0):
		soft.box((0.08, 0.20, 0.12), (side * 0.205, 1.02, -0.27), "canvas", bevel=0.03, segments=3)
	for side in (-1.0, 1.0): # correas de los hombros
		path = [(side * 0.11, 1.28, -0.20), (side * 0.115, 1.40, -0.15), (side * 0.118, 1.437, -0.04), (side * 0.118, 1.43, 0.06),
			(side * 0.118, 1.34, 0.152), (side * 0.118, 1.20, 0.188), (side * 0.12, 1.08, 0.18)]
		hard.tube(path, [(0.006, 0.023)] * len(path), "strap", segs=6, ref=(1.0, 0.0, 0.0))
		hard.box((0.046, 0.034, 0.014), (side * 0.12, 1.16, 0.19), "steel", bevel=0.003, segments=1) # hebilla
	hard.box((0.28, 0.012, 0.012), (0.0, 1.265, -0.375), "strap") # cinchas
	hard.box((0.012, 0.13, 0.012), (0.0, 1.325, -0.385), "strap")
	# herramientas en el costado (llave inglesa y alicates)
	for side in (1.0,):
		x = side * 0.249
		hard.box((0.012, 0.19, 0.014), (x, 1.04, -0.30), "steel", bevel=0.002, segments=1)
		hard.box((0.014, 0.045, 0.034), (x, 1.15, -0.30), "steel", bevel=0.003, segments=1)
		hard.box((0.012, 0.17, 0.012), (x, 1.03, -0.24), "steel", rot=(0.0, 0.0, 4.0), bevel=0.002, segments=1)
		hard.box((0.012, 0.17, 0.012), (x + 0.003, 1.03, -0.236), "steel", rot=(0.0, 0.0, -5.0), bevel=0.002, segments=1)
		for ly in (0.99, 1.07):
			hard.box((0.018, 0.016, 0.1), (x - 0.003, ly, -0.27), "strap", bevel=0.002, segments=1)
	hard.cyl((0.05, 0.05, 0.05), (0.09, 1.415, -0.27), "beacon", segs=10, bevel=0.005, segments=1) # baliza apagada (D2)
	return finish_part("Backpack", soft, hard, mats)


def build_aster(mats):
	hard = RefMesh("aster_hard")
	center = V((-0.165, 1.05, 0.375))
	hard.box((0.078, 0.014, 0.142), center, "device", rot=(-32.0, 0.0, 0.0), bevel=0.005, segments=2)
	body = finish_part("Aster", None, hard, mats)
	scr = RefMesh("emit_aster")
	rot = Matrix.Rotation(math.radians(-32.0), 3, "X")
	corners = []
	for lx, lz in ((-0.032, -0.056), (0.032, -0.056), (0.032, 0.056), (-0.032, 0.056)):
		corners.append(center + rot @ V((lx, 0.0078, lz)))
	scr.quad(corners, "aster", [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)])
	screen = scr.finish(mats, uv=False, cull_down=False, sharp=False, recalc=False)
	return body, screen


def aster_texture(path):
	w, h = 128, 224
	img = np.zeros((h, w, 3), dtype=np.float32)
	img[:, :] = (0.01, 0.04, 0.045)
	cyan = np.array((0.30, 0.95, 0.90), dtype=np.float32)

	def rect(x0, y0, x1, y1, k=1.0):
		img[y0:y1, x0:x1] = np.maximum(img[y0:y1, x0:x1], cyan * k)

	rect(0, 0, w, 3)
	rect(0, h - 3, w, h)
	rect(0, 0, 3, h)
	rect(w - 3, 0, w, h)
	rect(10, 10, w - 10, 22, 0.6)
	cx, cy = 64, 88
	yy, xx = np.ogrid[:h, :w]
	ring = (np.abs(np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) - 34) < 2.5)
	img[ring] = cyan
	for a in range(0, 360, 30): # marcas de la mira de escaneo
		x = int(cx + 44 * math.cos(math.radians(a)))
		y = int(cy + 44 * math.sin(math.radians(a)))
		rect(x - 2, y - 2, x + 3, y + 3, 0.8)
	rect(cx - 18, cy - 1, cx + 19, cy + 2, 0.7)
	rect(cx - 1, cy - 18, cx + 2, cy + 19, 0.7)
	for i in range(6):
		rect(14, 146 + i * 12, 14 + (40 + (i * 29) % 70), 152 + i * 12, 0.75)
	img[::2] *= 0.88
	save_rgb_png(img, path)


def main():
	options = common_args({"nobake": "0"})
	paths = repo_paths(options)
	samples = int(options["samples"])
	reset_scene()
	mats = make_materials()
	parts = {}
	parts["Torso"] = build_torso(mats)
	parts["ArmL"] = build_arm("ArmL", 1.0, mats)
	parts["ArmR"] = build_arm("ArmR", -1.0, mats)
	parts.update(build_legs(mats))
	parts["Hips"] = build_hips(mats)
	parts["Head"] = build_head(mats)
	parts["Backpack"] = build_backpack(mats)
	parts["Aster"], aster_screen = build_aster(mats)
	bpy.context.view_layer.update()
	objects = list(parts.values())
	print("[ref_elena] tris=%d partes=%d" % (triangle_count(objects), len(objects)))
	if options["nobake"] == "0":
		bake_atlas(objects, ASSET, ATLAS, paths["tex"], samples=samples, margin=10)
	finalize_materials(objects, ASSET)
	aster_screen.data.materials.clear()
	aster_screen.data.materials.append(bpy.data.materials.new("ref_elena_aster"))
	aster_texture(os.path.join(paths["tex"], "ref_elena_aster_emission.png"))
	write_pbr_tres(os.path.join(paths["mat"], ASSET + ".tres"), ASSET, paths["tex_res"])
	write_emissive_tres(os.path.join(paths["mat"], "ref_elena_aster.tres"), "ref_elena_aster", "031412", "FFFFFF", 2.2,
		paths["tex_res"] + "/ref_elena_aster_emission.png")
	# pivotes en las articulaciones y jerarquia
	def set_pivot(obj, pivot):
		pivot_b = godot_to_blender(V(pivot))
		obj.data.transform(Matrix.Translation(-pivot_b))
		obj.location = pivot_b
	for name, obj in parts.items():
		set_pivot(obj, PIVOTS[name])
	set_pivot(aster_screen, PIVOTS["Aster"])
	bpy.context.view_layer.update()
	for name, parent in PARENTS.items():
		child = parts[name]
		child.parent = parts[parent]
		child.location = godot_to_blender(V(PIVOTS[name]) - V(PIVOTS[parent]))
	aster_screen.parent = parts["Aster"]
	aster_screen.location = (0.0, 0.0, 0.0)
	bpy.context.view_layer.update()
	root = bpy.data.objects.new("Root", None)
	bpy.context.scene.collection.objects.link(root)
	parts["Hips"].parent = root
	export_objects = [root] + objects + [aster_screen]
	low, high = world_bounds_godot(objects + [aster_screen])
	size = high - low
	print("[ref_elena] size=(%.3f, %.3f, %.3f) min=(%.3f, %.3f, %.3f)" % (size.x, size.y, size.z, low.x, low.y, low.z))
	print("[ref_elena] -> " + export_glb(export_objects, os.path.join(paths["glb"], ASSET + ".glb")))
	save_blend(options, "ref_elena.blend")


main()
