"""Helix Station B environment kit: hero and structural pieces the level code places and batches.

    blender -b --factory-startup --python tools/blender/build_station_kit.py -- --repo D:/Projects/github/final-thaw

Writes assets/models/env/station_kit.glb: one object per piece, named kit_<piece>, pivot at its logical mounting point,
modelled in metres (Blender Z up -> glTF/Godot Y up). Material names are keys of the facility palette
(scripts/levels/test_room_art/facility_materials.gd), so the game swaps in its world-space station materials and
every piece matches the walls and floors around it; no UVs or textures are needed in the kit itself.

Art direction: docs/art/ASSET_PRODUCTION_BIBLE.md, "Helix Station B" (1920s riveted steel and cast iron for the station,
off-white panels, copper and violet-white light for the Aster insert). Budgets: hero pieces <= 10k triangles, others <= 2k.
Pieces:
- kit_truss: riveted lattice roof truss, 10.2 m span along +Y (Godot +Z), eaves at the pivot height, 1.6 m rise.
- kit_window_arch: tall arched iron window, 1.7 x 3.8 m, glass faces -Y (Godot +Z), pivot at the sill centre.
- kit_aster_base, kit_aster_ring, kit_aster_crown: the Aster calibration column's apparatus around a 0.58 m core.
- kit_pump: vertical wet-well pump with motor, 2.6 m tall, pivot at the floor centre.
- kit_valve: flanged gate valve with handwheel for a 0.3 m pipe along X, pivot at the pipe axis.
- kit_console: Helix operator console 2.4 m wide, front faces -Y (Godot +Z), pivot floor centre.
- kit_rack: Helix instrument rack 0.6 x 0.8 x 2.0 m.
- kit_cable_tray: 3 m ladder cable tray with cable bundle along X, pivot at its centre.
- kit_lamp_highbay: high-bay pendant lamp (shade + emissive lens), pivot at the ceiling hook.
- kit_bulkhead: caged bulkhead lamp for walls, back on the -Y face... front +(-Y), pivot on the wall.
"""
import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from lab_blender_common import parse_args  # noqa: E402

MATS = {}


def mat(name):
	if name not in MATS:
		MATS[name] = bpy.data.materials.new(name)
	return MATS[name]


class Piece:
	"""Accumulates primitives into one bmesh with per-face material slots."""

	def __init__(self, name):
		self.name = name
		self.bm = bmesh.new()
		self.slots = []

	def _slot(self, material):
		if material not in self.slots:
			self.slots.append(material)
		return self.slots.index(material)

	def _add(self, src, material, matrix, smooth=False):
		index = self._slot(material)
		src.transform(matrix)
		tmp = bpy.data.meshes.new("tmp")
		src.to_mesh(tmp)
		src.free()
		before = len(self.bm.faces)
		self.bm.from_mesh(tmp)
		bpy.data.meshes.remove(tmp)
		self.bm.faces.ensure_lookup_table()
		for f in self.bm.faces[before:]:
			f.material_index = index
			f.smooth = smooth

	def box(self, size, centre, material, rot=(0.0, 0.0, 0.0), bevel=0.0):
		bm = bmesh.new()
		bmesh.ops.create_cube(bm, size=1.0)
		bmesh.ops.scale(bm, vec=Vector(size), verts=bm.verts)
		if bevel > 0.0:
			bmesh.ops.bevel(bm, geom=list(bm.edges), offset=bevel, segments=1, affect="EDGES", clamp_overlap=True)
		m = Matrix.Translation(Vector(centre)) @ euler(rot)
		self._add(bm, material, m)

	def cyl(self, radius, depth, centre, material, rot=(0.0, 0.0, 0.0), segments=12, radius2=None, smooth=True, caps=True):
		bm = bmesh.new()
		bmesh.ops.create_cone(bm, cap_ends=caps, cap_tris=False, segments=segments, radius1=radius,
			radius2=radius if radius2 is None else radius2, depth=depth)
		m = Matrix.Translation(Vector(centre)) @ euler(rot)
		self._add(bm, material, m, smooth)

	def torus(self, major, minor, centre, material, rot=(0.0, 0.0, 0.0), seg=24, ring=8, arc=1.0):
		bm = bmesh.new()
		verts = []
		count = seg if arc >= 1.0 else seg + 1
		for i in range(count):
			a = 2.0 * math.pi * arc * i / seg
			row = []
			for j in range(ring):
				b = 2.0 * math.pi * j / ring
				r = major + minor * math.cos(b)
				row.append(bm.verts.new((r * math.cos(a), r * math.sin(a), minor * math.sin(b))))
			verts.append(row)
		for i in range(seg if arc >= 1.0 else seg):
			n = (i + 1) % count if arc >= 1.0 else i + 1
			for j in range(ring):
				k = (j + 1) % ring
				bm.faces.new((verts[i][j], verts[n][j], verts[n][k], verts[i][k]))
		m = Matrix.Translation(Vector(centre)) @ euler(rot)
		self._add(bm, material, m, True)

	def beam(self, a, b, w, h, material, up=(0.0, 0.0, 1.0)):
		"""Box from point a to point b with cross-section w x h."""
		a, b = Vector(a), Vector(b)
		d = b - a
		length = d.length
		x = d.normalized()
		u = Vector(up)
		if abs(x.dot(u)) > 0.95:
			u = Vector((1.0, 0.0, 0.0)) if abs(x.x) < 0.9 else Vector((0.0, 1.0, 0.0))
		y = u.cross(x).normalized()
		z = x.cross(y).normalized()
		rotm = Matrix((x, y, z)).transposed().to_4x4()
		bm = bmesh.new()
		bmesh.ops.create_cube(bm, size=1.0)
		bmesh.ops.scale(bm, vec=Vector((length, w, h)), verts=bm.verts)
		self._add(bm, material, Matrix.Translation((a + b) * 0.5) @ rotm)

	def finish(self):
		mesh = bpy.data.meshes.new(self.name)
		bmesh.ops.remove_doubles(self.bm, verts=self.bm.verts, dist=1e-5)
		self.bm.to_mesh(mesh)
		self.bm.free()
		for m in self.slots:
			mesh.materials.append(mat(m))
		obj = bpy.data.objects.new(self.name, mesh)
		bpy.context.scene.collection.objects.link(obj)
		mesh.calc_loop_triangles()
		print("[kit] %-20s %6d tris  %s" % (self.name, len(mesh.loop_triangles), self.slots))
		return obj


def euler(rot):
	from mathutils import Euler
	return Euler(rot, "XYZ").to_matrix().to_4x4()


# --- pieces --------------------------------------------------------------------------------------------------------

def truss():
	"""Riveted lattice truss in the X=0 plane, span along +Y from -5.1 to +5.1, eaves at Z=0, apex at Z=1.6."""
	p = Piece("kit_truss")
	span, rise = 10.2, 1.6
	half = span * 0.5
	steel = "st_green_steel"
	# bottom chord, two rafters
	p.beam((0, -half, 0.0), (0, half, 0.0), 0.16, 0.14, steel)
	p.beam((0, -half, 0.05), (0, 0, rise), 0.16, 0.16, steel)
	p.beam((0, half, 0.05), (0, 0, rise), 0.16, 0.16, steel)
	# lattice: verticals and diagonals every 1.275 m
	n = 8
	for i in range(1, n):
		y = -half + span * i / n
		top = rise * (1.0 - abs(y) / half)
		p.beam((0, y, 0.0), (0, y, top), 0.08, 0.07, steel)
		if i < n - 1:
			y2 = -half + span * (i + 1) / n
			top2 = rise * (1.0 - abs(y2) / half)
			if y < 0:
				p.beam((0, y, 0.0), (0, y2, top2), 0.07, 0.06, steel)
			else:
				p.beam((0, y2, 0.0), (0, y, top), 0.07, 0.06, steel)
	# gusset plates and rivet heads at the panel points of the bottom chord
	for i in range(0, n + 1):
		y = -half + span * i / n
		p.box((0.03, 0.34, 0.26), (0.0, y, 0.04), steel)
		for k in (-0.1, 0.0, 0.1):
			p.cyl(0.012, 0.05, (0.0, y + k, -0.02), steel, rot=(0.0, math.pi * 0.5, 0.0), segments=6)
	# purlins stubs (the roof purlins run along X between trusses; these are the cleats)
	for i in range(0, n + 1):
		y = -half + span * i / n
		top = rise * (1.0 - abs(y) / half)
		p.box((0.22, 0.06, 0.12), (0.0, y, top + 0.13), steel)
	return p.finish()


def window_arch():
	"""Arched iron window, sill centre at origin, 1.7 m wide, 3.8 m to the crown, glass toward -Y."""
	p = Piece("kit_window_arch")
	w, h_spring = 1.7, 2.95
	r = w * 0.5
	frame, glass = "graphite", "window_moon"
	# glass (flat) with an arched top: rectangle + half disc
	p.box((w, 0.02, h_spring), (0, 0.0, h_spring * 0.5), glass)
	bm = bmesh.new()
	bmesh.ops.create_circle(bm, cap_ends=True, cap_tris=False, segments=24, radius=r)
	bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.y < -1e-4], context="VERTS")
	p._add(bm, glass, Matrix.Translation((0, -0.011, h_spring)) @ euler((math.pi * 0.5, 0, 0)))
	# frame: jambs, sill, arch ring, glazing bars
	p.box((0.09, 0.14, h_spring), (-r, -0.03, h_spring * 0.5), frame)
	p.box((0.09, 0.14, h_spring), (r, -0.03, h_spring * 0.5), frame)
	p.box((w + 0.3, 0.32, 0.1), (0, -0.1, -0.05), "st_concrete")  # stone sill
	p.torus(r, 0.05, (0, -0.03, h_spring), frame, rot=(math.pi * 0.5, 0, 0), seg=16, ring=6, arc=0.5)
	for x in (-r / 3.0, r / 3.0):
		p.box((0.035, 0.05, h_spring + r * 0.9), (x, -0.04, (h_spring + r * 0.9) * 0.5), frame)
	for z in (0.75, 1.5, 2.25, h_spring):
		p.box((w, 0.05, 0.035), (0, -0.04, z), frame)
	# brick voussoir arch around it (a slightly proud ring in brick)
	p.torus(r + 0.16, 0.12, (0, 0.04, h_spring), "st_brick", rot=(math.pi * 0.5, 0, 0), seg=16, ring=4, arc=0.5)
	return p.finish()


def aster_base():
	"""Octagonal plinth around the 0.58 m column core: Helix cladding, copper bus bars, ceramic insulators, cable glands."""
	p = Piece("kit_aster_base")
	p.cyl(1.05, 0.5, (0, 0, 0.25), "helix_panel", segments=8, smooth=False)
	p.cyl(0.95, 0.08, (0, 0, 0.54), "graphite", segments=8, smooth=False)
	p.cyl(0.62, 1.2, (0, 0, 1.18), "helix_panel", segments=16, smooth=True)
	p.torus(0.66, 0.05, (0, 0, 1.78), "copper", seg=24, ring=6)
	for i in range(4):
		a = math.pi * 0.25 + i * math.pi * 0.5
		x, y = math.cos(a), math.sin(a)
		# copper bus bar from the plinth up into the core
		p.beam((x * 0.98, y * 0.98, 0.5), (x * 0.66, y * 0.66, 1.65), 0.06, 0.02, "copper")
		# insulator stack
		for k in range(5):
			p.cyl(0.07 - (k % 2) * 0.02, 0.04, (x * 0.85, y * 0.85, 0.62 + k * 0.045), "st_tile", segments=10)
		# cable gland and a cable down to the floor
		p.cyl(0.05, 0.12, (x * 1.08, y * 1.08, 0.2), "graphite", rot=(0, math.pi * 0.5, a), segments=8)
		p.beam((x * 1.12, y * 1.12, 0.2), (x * 1.6, y * 1.6, 0.03), 0.07, 0.07, "cable")
	# stencilled star plate on the plinth (geometry plate; the mark itself is a decal in the level)
	p.box((0.5, 0.02, 0.32), (0, -0.96, 0.28), "graphite")
	return p.finish()


def aster_ring():
	"""Calibration ring module clamped to the core: copper coil, clamp ribs, a violet-white indicator band."""
	p = Piece("kit_aster_ring")
	p.torus(0.42, 0.06, (0, 0, 0.0), "copper", seg=28, ring=8)
	p.torus(0.42, 0.06, (0, 0, 0.14), "copper", seg=28, ring=8)
	p.cyl(0.47, 0.06, (0, 0, 0.07), "aster_violet", segments=28)
	for i in range(6):
		a = i * math.pi / 3.0
		p.box((0.1, 0.06, 0.32), (math.cos(a) * 0.36, math.sin(a) * 0.36, 0.07), "graphite", rot=(0, 0, a))
	return p.finish()


def aster_crown():
	"""Top of the column: cable fan-out into a tray that runs to the control room."""
	p = Piece("kit_aster_crown")
	p.cyl(0.5, 0.35, (0, 0, 0.0), "helix_panel", segments=16)
	p.cyl(0.4, 0.06, (0, 0, 0.2), "graphite", segments=16)
	for i in range(8):
		a = i * math.pi / 4.0
		end = Vector((math.cos(a) * 0.9, math.sin(a) * 0.9, 0.7))
		p.beam((math.cos(a) * 0.35, math.sin(a) * 0.35, 0.2), end, 0.05, 0.05, "cable")
	p.box((1.2, 1.2, 0.05), (0, 0, 0.78), "graphite")
	return p.finish()


def pump():
	"""Vertical wet-well pump: volute on a base frame, flanged discharge toward +Y, motor stool and ribbed motor."""
	p = Piece("kit_pump")
	g = "st_green_steel"
	p.box((1.1, 1.1, 0.12), (0, 0, 0.06), "graphite")
	p.cyl(0.42, 0.5, (0, 0, 0.4), g, segments=20)
	p.torus(0.42, 0.1, (0, 0, 0.42), g, seg=20, ring=8)
	p.cyl(0.14, 0.55, (0, 0.62, 0.45), g, rot=(math.pi * 0.5, 0, 0), segments=14)
	p.cyl(0.24, 0.05, (0, 0.88, 0.45), g, rot=(math.pi * 0.5, 0, 0), segments=14)
	p.cyl(0.18, 0.7, (0, 0, 1.0), g, segments=14)
	for k in range(4):
		a = k * math.pi * 0.5 + math.pi * 0.25
		p.box((0.06, 0.06, 0.7), (math.cos(a) * 0.22, math.sin(a) * 0.22, 1.0), "graphite")
	p.cyl(0.36, 0.95, (0, 0, 1.85), g, segments=20)
	for k in range(16):  # cooling ribs
		a = k * math.pi / 8.0
		p.box((0.06, 0.02, 0.8), (math.cos(a) * 0.37, math.sin(a) * 0.37, 1.85), g, rot=(0, 0, a))
	p.cyl(0.3, 0.12, (0, 0, 2.38), g, segments=20)
	p.box((0.16, 0.12, 0.2), (0.38, 0, 2.05), "graphite")  # terminal box
	p.cyl(0.05, 0.2, (0, 0, 2.52), "graphite", segments=8)  # lifting eye post
	p.torus(0.07, 0.015, (0, 0, 2.66), "graphite", rot=(math.pi * 0.5, 0, 0), seg=10, ring=4)
	return p.finish()


def valve():
	"""Gate valve on a 0.3 m pipe along X: flanged body, bonnet, yoke and a red handwheel on top."""
	p = Piece("kit_valve")
	g = "st_green_steel"
	p.cyl(0.24, 0.42, (0, 0, 0), g, rot=(0, math.pi * 0.5, 0), segments=16)
	for x in (-0.23, 0.23):
		p.cyl(0.27, 0.05, (x, 0, 0), g, rot=(0, math.pi * 0.5, 0), segments=16)
		for k in range(8):
			a = k * math.pi / 4.0
			p.cyl(0.02, 0.07, (x, math.cos(a) * 0.23, math.sin(a) * 0.23), "graphite", rot=(0, math.pi * 0.5, 0), segments=6)
	p.box((0.3, 0.2, 0.45), (0, 0, 0.32), g, bevel=0.03)
	p.box((0.05, 0.05, 0.5), (0.1, 0, 0.75), "graphite")
	p.box((0.05, 0.05, 0.5), (-0.1, 0, 0.75), "graphite")
	p.cyl(0.02, 0.4, (0, 0, 0.95), "graphite", segments=8)
	p.torus(0.22, 0.025, (0, 0, 1.08), "pipe_fire", seg=20, ring=6)
	for k in range(4):
		a = k * math.pi * 0.5
		p.beam((0, 0, 1.08), (math.cos(a) * 0.22, math.sin(a) * 0.22, 1.08), 0.03, 0.03, "pipe_fire")
	return p.finish()


def console():
	"""Helix operator console: sloped desk with three screens, keyboard shelf, cable plinth."""
	p = Piece("kit_console")
	panel = "helix_panel"
	p.box((2.4, 0.7, 0.75), (0, 0, 0.375), panel, bevel=0.01)
	p.box((2.4, 0.5, 0.06), (0, -0.05, 0.78), "graphite", rot=(-0.2, 0, 0))
	for k, x in enumerate((-0.78, 0.0, 0.78)):
		p.box((0.7, 0.06, 0.45), (x, 0.18, 1.12), "graphite", rot=(0.12, 0, 0), bevel=0.01)
		p.box((0.64, 0.01, 0.38), (x, 0.145, 1.13), "screen_dark", rot=(0.12, 0, 0))
		p.box((0.08, 0.08, 0.3), (x, 0.26, 0.92), "graphite")
	p.box((2.3, 0.05, 0.05), (0, -0.36, 0.73), "graphite")
	return p.finish()


def rack():
	p = Piece("kit_rack")
	p.box((0.6, 0.8, 2.0), (0, 0, 1.0), "graphite", bevel=0.01)
	for k in range(9):
		z = 0.25 + k * 0.19
		p.box((0.5, 0.02, 0.16), (0, -0.405, z), "helix_panel" if k % 3 else "graphite")
		p.box((0.03, 0.01, 0.02), (0.18, -0.418, z + 0.04), "exit_green" if k % 4 else "lamp_sodium")
	return p.finish()


def cable_tray():
	p = Piece("kit_cable_tray")
	for y in (-0.22, 0.22):
		p.box((3.0, 0.03, 0.09), (0, y, 0), "graphite")
	for k in range(11):
		p.box((0.025, 0.44, 0.02), (-1.5 + k * 0.3, 0, -0.035), "graphite")
	for y in (-0.12, -0.04, 0.05, 0.13):
		p.cyl(0.03, 3.0, (0, y, 0.0), "cable", rot=(0, math.pi * 0.5, 0), segments=6)
	return p.finish()


def lamp_highbay():
	p = Piece("kit_lamp_highbay")
	p.cyl(0.012, 1.2, (0, 0, -0.6), "graphite", segments=6)
	p.cyl(0.08, 0.18, (0, 0, -1.25), "graphite", segments=10)
	p.cyl(0.12, 0.32, (0, 0, -1.45), "st_green_steel", radius2=0.42, segments=18)
	p.cyl(0.4, 0.02, (0, 0, -1.62), "lamp_sodium", segments=18)
	return p.finish()


def bulkhead():
	p = Piece("kit_bulkhead")
	p.box((0.3, 0.06, 0.2), (0, -0.03, 0), "graphite", bevel=0.01)
	p.cyl(0.1, 0.08, (0, -0.1, 0), "lamp_bulkhead", rot=(math.pi * 0.5, 0, 0), segments=14)
	for k in range(3):
		p.box((0.012, 0.1, 0.2), (-0.06 + k * 0.06, -0.12, 0), "graphite")
	return p.finish()


def main():
	options = {"repo": None}
	parse_args(options)
	for o in list(bpy.data.objects):
		bpy.data.objects.remove(o)
	pieces = [truss(), window_arch(), aster_base(), aster_ring(), aster_crown(), pump(), valve(), console(), rack(),
		cable_tray(), lamp_highbay(), bulkhead()]
	for i, obj in enumerate(pieces):
		obj.location = (i * 12.0, 0.0, 0.0)  # spread out for inspection; Godot reads each node's mesh, not its position
	out = os.path.join(os.path.abspath(options["repo"]), "assets", "models", "env", "station_kit.glb")
	os.makedirs(os.path.dirname(out), exist_ok=True)
	bpy.ops.object.select_all(action="SELECT")
	bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=True, export_yup=True, export_apply=True,
		export_materials="EXPORT", export_image_format="NONE", export_animations=False)
	print("[kit] -> " + out)


if __name__ == "__main__":
	main()
