"""Utilidades compartidas por los scripts de Blender del laboratorio (lote 1 en adelante).

Se importa desde los scripts hermanos de tools/blender/. No se ejecuta solo.

Convenciones (docs/art/LAB_STYLE_SPEC.md):
- Toda la geometria se define en coordenadas de Godot (X derecha, Y arriba, +Z frente) y se
  convierte a Blender con C: (x, y, z) -> (x, -z, y). El exportador glTF (+Y arriba) deshace C.
- 1 unidad = 1 m. Materiales PBR planos con nombre estable; color hex sRGB -> lineal.
"""

import math
import os

import bmesh
import bpy
from mathutils import Matrix, Vector

# Godot -> Blender (rotacion propia, det = +1).
C = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
C_INV = C.inverted()

# nombre: (hex sRGB, roughness, emision)
LAB_MATERIALS = {
	"lab_mat_floor_epoxy": ("6B7377", 0.65, 0.0),
	"lab_mat_floor_joint": ("4A5155", 0.9, 0.0),
	"lab_mat_wall_panel": ("9AA2A5", 0.8, 0.0),
	"lab_mat_trim_metal": ("3B4347", 0.5, 0.0),
	"lab_mat_painted_metal": ("56656C", 0.7, 0.0),
	"lab_mat_rubber": ("1E2124", 0.9, 0.0),
	"lab_mat_screen_emissive": ("F2B340", 0.4, 2.0),
	"lab_mat_light_emissive": ("DDE8F0", 0.4, 2.5),
}


def srgb_to_linear(channel: float) -> float:
	if channel <= 0.04045:
		return channel / 12.92
	return ((channel + 0.055) / 1.055) ** 2.4


def hex_to_linear_rgba(hex_value: str) -> tuple:
	r, g, b = (int(hex_value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
	return (srgb_to_linear(r), srgb_to_linear(g), srgb_to_linear(b), 1.0)


def make_material(name: str, spec: tuple) -> bpy.types.Material:
	hex_value, roughness, emission = spec
	material = bpy.data.materials.new(name)
	try:
		material.use_nodes = True # obsoleto en 5.x, aun valido
	except Exception:
		pass
	bsdf = material.node_tree.nodes["Principled BSDF"]
	color = hex_to_linear_rgba(hex_value)
	bsdf.inputs["Base Color"].default_value = color
	bsdf.inputs["Roughness"].default_value = roughness
	bsdf.inputs["Metallic"].default_value = 0.0
	if emission > 0.0:
		bsdf.inputs["Emission Color"].default_value = color
		bsdf.inputs["Emission Strength"].default_value = emission
	return material


def make_materials(specs: dict) -> dict:
	return {name: make_material(name, spec) for name, spec in specs.items()}


def godot_to_blender(v) -> Vector:
	return Vector((v[0], -v[2], v[1]))


def prim_matrix(center, size, rot_deg=(0.0, 0.0, 0.0)) -> Matrix:
	"""Matriz de Blender para una primitiva definida en ejes de Godot.

	center/size en Godot; rot_deg = (x, y, z) en grados con orden YXZ como Godot.
	Los ejes locales de bmesh (X, Y, Z) coinciden con (X, Z, Y) de Godot, por eso la
	escala se conjuga con C y la caja/cilindro/esfera salen con (ancho, alto, fondo) de Godot.
	"""
	scale = Matrix.Diagonal(Vector((size[0], size[1], size[2], 1.0)))
	rx = Matrix.Rotation(math.radians(rot_deg[0]), 4, "X")
	ry = Matrix.Rotation(math.radians(rot_deg[1]), 4, "Y")
	rz = Matrix.Rotation(math.radians(rot_deg[2]), 4, "Z")
	godot_matrix = Matrix.Translation(Vector(center)) @ ry @ rx @ rz @ scale
	return C @ godot_matrix @ C_INV


class AssetBuilder:
	"""Acumula primitivas (coordenadas absolutas de Godot) en una malla con varios materiales.

	pivot: origen de la malla en Godot. Las primitivas se guardan relativas a el, de modo que
	al colocar el objeto en `pivot` la geometria queda donde se definio.
	"""

	def __init__(self, name: str, materials: dict, pivot=(0.0, 0.0, 0.0)):
		self.name = name
		self.materials = materials
		self.pivot = Vector(pivot)
		self.bm = bmesh.new()
		self.used: list = []

	def _slot(self, material_name: str) -> int:
		if material_name not in self.used:
			self.used.append(material_name)
		return self.used.index(material_name)

	def _finish_primitive(self, verts, material_name: str, bevel: float) -> None:
		slot = self._slot(material_name)
		for face in {face for vert in verts for face in vert.link_faces}:
			face.material_index = slot
		if bevel > 0.0:
			edges = {edge for vert in verts for edge in vert.link_edges}
			bmesh.ops.bevel(self.bm, geom=list(edges), offset=bevel, segments=1, profile=0.5, affect="EDGES")

	def box(self, size, center, material_name: str, rot_deg=(0.0, 0.0, 0.0), bevel: float = 0.0) -> None:
		matrix = prim_matrix(Vector(center) - self.pivot, size, rot_deg)
		verts = bmesh.ops.create_cube(self.bm, size=1.0, matrix=matrix)["verts"]
		self._finish_primitive(verts, material_name, bevel)

	def cone(self, size, center, material_name: str, top_ratio: float = 1.0, segments: int = 12,
			rot_deg=(0.0, 0.0, 0.0)) -> None:
		"""Cilindro o tronco de cono con el eje en Y de Godot. size = (ancho, alto, fondo)."""
		matrix = prim_matrix(Vector(center) - self.pivot, size, rot_deg)
		verts = bmesh.ops.create_cone(self.bm, cap_ends=True, cap_tris=False, segments=segments,
			radius1=0.5, radius2=0.5 * top_ratio, depth=1.0, matrix=matrix)["verts"]
		self._finish_primitive(verts, material_name, 0.0)

	def sphere(self, size, center, material_name: str, u_segments: int = 14, v_segments: int = 9,
			rot_deg=(0.0, 0.0, 0.0)) -> None:
		matrix = prim_matrix(Vector(center) - self.pivot, size, rot_deg)
		verts = bmesh.ops.create_uvsphere(self.bm, u_segments=u_segments, v_segments=v_segments,
			radius=0.5, matrix=matrix)["verts"]
		self._finish_primitive(verts, material_name, 0.0)

	def finish(self) -> bpy.types.Object:
		bmesh.ops.recalc_face_normals(self.bm, faces=self.bm.faces[:])
		mesh = bpy.data.meshes.new(self.name)
		self.bm.to_mesh(mesh)
		self.bm.free()
		for material_name in self.used:
			mesh.materials.append(self.materials[material_name])
		obj = bpy.data.objects.new(self.name, mesh)
		obj.location = godot_to_blender(self.pivot)
		bpy.context.scene.collection.objects.link(obj)
		return obj


def parse_args(options: dict) -> dict:
	import sys
	argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for index, arg in enumerate(argv):
		if arg.startswith("--") and arg[2:] in options and index + 1 < len(argv):
			options[arg[2:]] = argv[index + 1]
	return options


def world_bounds_godot(objects) -> tuple:
	"""AABB combinado (min, max) en coordenadas de Godot de varios objetos."""
	low = Vector((1e9, 1e9, 1e9))
	high = Vector((-1e9, -1e9, -1e9))
	for obj in objects:
		if obj.type != "MESH":
			continue
		for corner in obj.bound_box:
			world = obj.matrix_world @ Vector(corner)
			godot = Vector((world.x, world.z, -world.y))
			low = Vector((min(low.x, godot.x), min(low.y, godot.y), min(low.z, godot.z)))
			high = Vector((max(high.x, godot.x), max(high.y, godot.y), max(high.z, godot.z)))
	return low, high


def triangle_count(objects) -> int:
	total = 0
	for obj in objects:
		if obj.type == "MESH":
			obj.data.calc_loop_triangles()
			total += len(obj.data.loop_triangles)
	return total


def export_glb(objects, path: str) -> str:
	os.makedirs(os.path.dirname(path), exist_ok=True)
	bpy.ops.object.select_all(action="DESELECT")
	for obj in objects:
		obj.select_set(True)
	bpy.context.view_layer.objects.active = objects[0]
	bpy.ops.export_scene.gltf(
		filepath=path,
		export_format="GLB",
		use_selection=True,
		export_apply=True,
		export_yup=True,
		export_materials="EXPORT",
		export_cameras=False,
		export_lights=False,
	)
	return path


def reset_scene() -> None:
	bpy.ops.wm.read_factory_settings(use_empty=True)
	scene = bpy.context.scene
	scene.unit_settings.system = "METRIC"
	scene.unit_settings.scale_length = 1.0
