"""Genera los assets del rincon de laboratorio (lote 1) segun docs/art/LAB_STYLE_SPEC.md.

Ejecucion (Blender en segundo plano; los argumentos van tras "--"):
    blender --background --factory-startup --python tools/blender/build_lab_corner_assets.py -- \
        --glb-dir assets/models/lab --blend-dir D:/Projects/evidence/final-thaw/lab-corner-art-source

- Las medidas, posiciones y colores salen de scripts/levels/art_tests/lab_palette_test.gd.
- Toda la geometria se define en coordenadas de Godot (X derecha, Y arriba, +Z hacia
  la camara) y se convierte a Blender (X, -Z, Y); el exportador glTF (+Y arriba)
  deshace la conversion, de modo que el GLB llega a Godot sin rotaciones extra.
- Unidades: 1 unidad = 1 m. Sin texturas: materiales PBR planos con los nombres lab_mat_*.
- El .blend se guarda FUERA del repositorio (--blend-dir). No se versionan .blend.
"""

import math
import os
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector

# --- Paleta (sRGB hex, identica a lab_palette_test.gd) ------------------------
# nombre: (hex, roughness, emision)
MATERIALS = {
	"lab_mat_floor_epoxy": ("6B7377", 0.65, 0.0),
	"lab_mat_floor_joint": ("4A5155", 0.9, 0.0),
	"lab_mat_wall_panel": ("9AA2A5", 0.8, 0.0),
	"lab_mat_trim_metal": ("3B4347", 0.5, 0.0),
	"lab_mat_painted_metal": ("56656C", 0.7, 0.0),
	"lab_mat_rubber": ("1E2124", 0.9, 0.0),
	"lab_mat_screen_emissive": ("F2B340", 0.4, 2.0),
	"lab_mat_light_emissive": ("DDE8F0", 0.4, 2.5),
}

BEVEL_SEGMENTS = 1


def srgb_to_linear(channel: float) -> float:
	if channel <= 0.04045:
		return channel / 12.92
	return ((channel + 0.055) / 1.055) ** 2.4


def hex_to_linear_rgba(hex_value: str) -> tuple:
	r, g, b = (int(hex_value[i:i + 2], 16) / 255.0 for i in (0, 2, 4))
	return (srgb_to_linear(r), srgb_to_linear(g), srgb_to_linear(b), 1.0)


def make_material(name: str) -> bpy.types.Material:
	hex_value, roughness, emission = MATERIALS[name]
	material = bpy.data.materials.new(name)
	try:
		material.use_nodes = True # obsoleto en 5.x pero aun valido
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


def godot_to_blender(v) -> Vector:
	return Vector((v[0], -v[2], v[1]))


class AssetBuilder:
	"""Acumula cajas (en coordenadas de Godot) en una sola malla con varios materiales."""

	def __init__(self, name: str, materials: dict):
		self.name = name
		self.materials = materials
		self.bm = bmesh.new()
		self.used: list = []

	def _slot(self, material_name: str) -> int:
		if material_name not in self.used:
			self.used.append(material_name)
		return self.used.index(material_name)

	def box(self, size, center, material_name: str, rot_x_deg: float = 0.0, bevel: float = 0.0) -> None:
		size_b = Vector((size[0], size[2], size[1])) # (X, Y, Z) de Blender
		scale = Matrix.Diagonal(Vector((size_b.x, size_b.y, size_b.z, 1.0)))
		rotation = Matrix.Rotation(math.radians(rot_x_deg), 4, "X")
		translation = Matrix.Translation(godot_to_blender(center))
		result = bmesh.ops.create_cube(self.bm, size=1.0, matrix=translation @ rotation @ scale)
		verts = result["verts"]
		slot = self._slot(material_name)
		faces = {face for vert in verts for face in vert.link_faces}
		for face in faces:
			face.material_index = slot
		if bevel > 0.0:
			edges = {edge for vert in verts for edge in vert.link_edges}
			bmesh.ops.bevel(self.bm, geom=list(edges), offset=bevel, segments=BEVEL_SEGMENTS,
				profile=0.5, affect="EDGES")

	def finish(self) -> bpy.types.Object:
		bmesh.ops.recalc_face_normals(self.bm, faces=self.bm.faces[:])
		mesh = bpy.data.meshes.new(self.name)
		self.bm.to_mesh(mesh)
		self.bm.free()
		for material_name in self.used:
			mesh.materials.append(self.materials[material_name])
		obj = bpy.data.objects.new(self.name, mesh)
		bpy.context.scene.collection.objects.link(obj)
		return obj


# --- Definicion de assets (medidas de lab_palette_test.gd) --------------------
def build_floor(materials) -> bpy.types.Object:
	# Modulo 2x2 m: loseta de 1,96 m (2 cm de junta por lado) sobre placa de junta.
	# Pivote: centro del modulo, cara superior de la loseta en y=0.
	b = AssetBuilder("lab_floor_2x2_a", materials)
	b.box((2.0, 0.08, 2.0), (0.0, -0.06, 0.0), "lab_mat_floor_joint")
	b.box((1.96, 0.1, 1.96), (0.0, -0.05, 0.0), "lab_mat_floor_epoxy", bevel=0.006)
	return b.finish()


def build_wall(materials) -> bpy.types.Object:
	# Modulo de 2 m: cara interior en z=0 (normal +Z), cuerpo hacia -Z (0,5 m de grosor).
	# Pivote: base, centro del ancho, sobre la cara interior.
	b = AssetBuilder("lab_wall_2m_a", materials)
	b.box((2.0, 3.2, 0.5), (0.0, 1.6, -0.25), "lab_mat_wall_panel")
	b.box((2.0, 0.3, 0.03), (0.0, 0.15, 0.015), "lab_mat_trim_metal") # zocalo
	b.box((2.0, 0.06, 0.03), (0.0, 1.0, 0.015), "lab_mat_trim_metal") # barandilla
	seam_height = 3.2 - 0.3
	for side in (-1.0, 1.0): # media junta en cada borde: dos modulos juntos suman 1,5 cm
		b.box((0.0075, seam_height, 0.01), (side * (1.0 - 0.00375), 0.3 + seam_height * 0.5, 0.005), "lab_mat_trim_metal")
	return b.finish()


def build_corner(materials) -> bpy.types.Object:
	# Esquina interior: poste de 0,5 x 0,5 m detras del vertice interior.
	# Pivote: vertice interior de la esquina, en el suelo; el cuerpo va hacia -X y -Z.
	b = AssetBuilder("lab_wall_corner_a", materials)
	b.box((0.5, 3.2, 0.5), (-0.25, 1.6, -0.25), "lab_mat_wall_panel")
	b.box((0.06, 2.9, 0.06), (0.03, 1.75, 0.03), "lab_mat_trim_metal") # guardaesquinas
	b.box((0.06, 0.3, 0.06), (0.03, 0.15, 0.03), "lab_mat_trim_metal") # retorno de zocalo
	return b.finish()


def build_terminal(materials) -> bpy.types.Object:
	# Terminal de 1,0 x 1,0 x 0,7 m con pantalla inclinada -25 grados. Frente = +Z.
	# Pivote: centro de la base, en el suelo.
	b = AssetBuilder("lab_terminal_a", materials)
	b.box((1.0, 1.0, 0.7), (0.0, 0.5, 0.0), "lab_mat_painted_metal", bevel=0.01)
	b.box((1.04, 0.06, 0.74), (0.0, 0.03, 0.0), "lab_mat_rubber") # zocalo de goma
	for slot_y in (0.25, 0.32, 0.39): # rejilla de ventilacion frontal
		b.box((0.6, 0.025, 0.01), (0.0, slot_y, 0.355), "lab_mat_trim_metal")
	b.box((0.9, 0.55, 0.08), (0.0, 1.2, 0.2), "lab_mat_painted_metal", rot_x_deg=-25.0, bevel=0.008)
	b.box((0.78, 0.4, 0.02), (0.0, 1.22, 0.25), "lab_mat_screen_emissive", rot_x_deg=-25.0)
	return b.finish()


def build_container(materials) -> bpy.types.Object:
	# Contenedor de 1,2 x 1,0 x 0,8 m con tapa de 1,24 x 0,84 m. Frente = +Z.
	# Pivote: centro de la base, en el suelo.
	b = AssetBuilder("lab_container_a", materials)
	b.box((1.2, 1.0, 0.8), (0.0, 0.5, 0.0), "lab_mat_painted_metal", bevel=0.01)
	b.box((1.24, 0.06, 0.84), (0.0, 0.97, 0.0), "lab_mat_trim_metal")
	for corner_x in (-0.6, 0.6): # nervios de esquina
		for corner_z in (-0.4, 0.4):
			b.box((0.04, 0.94, 0.04), (corner_x, 0.47, corner_z), "lab_mat_trim_metal")
	for side in (-1.0, 1.0):
		b.box((0.3, 0.06, 0.06), (side * 0.35, 0.72, 0.43), "lab_mat_rubber") # asa
		b.box((0.08, 0.12, 0.02), (side * 0.35, 0.88, 0.41), "lab_mat_trim_metal") # cierre
	return b.finish()


def build_wall_light(materials) -> bpy.types.Object:
	# Aplique de 0,8 x 0,2 x 0,25 m con tira emisiva frontal. Frente = +Z.
	# Pivote: centro de la carcasa; la cara trasera (z=-0,125) apoya en la pared.
	b = AssetBuilder("lab_wall_light_a", materials)
	b.box((0.8, 0.2, 0.25), (0.0, 0.0, 0.0), "lab_mat_trim_metal", bevel=0.008)
	b.box((0.7, 0.08, 0.02), (0.0, 0.0, 0.125), "lab_mat_light_emissive")
	return b.finish()


BUILDERS = [build_floor, build_wall, build_corner, build_terminal, build_container, build_wall_light]


def parse_args() -> dict:
	argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	options = {"glb-dir": None, "blend-dir": None}
	for index, arg in enumerate(argv):
		if arg.startswith("--") and arg[2:] in options and index + 1 < len(argv):
			options[arg[2:]] = argv[index + 1]
	if not options["glb-dir"]:
		raise SystemExit("falta --glb-dir")
	return options


def export_glb(obj: bpy.types.Object, directory: str) -> str:
	bpy.ops.object.select_all(action="DESELECT")
	obj.select_set(True)
	bpy.context.view_layer.objects.active = obj
	path = os.path.join(directory, obj.name + ".glb")
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


def main() -> None:
	options = parse_args()
	glb_dir = os.path.abspath(options["glb-dir"])
	os.makedirs(glb_dir, exist_ok=True)
	bpy.ops.wm.read_factory_settings(use_empty=True)
	scene = bpy.context.scene
	scene.unit_settings.system = "METRIC"
	scene.unit_settings.scale_length = 1.0
	materials = {name: make_material(name) for name in MATERIALS}

	objects = [builder(materials) for builder in BUILDERS]
	for obj in objects:
		mesh = obj.data
		mesh.calc_loop_triangles()
		corners = [obj.matrix_world @ Vector(c) for c in obj.bound_box]
		low = Vector((min(c.x for c in corners), min(c.y for c in corners), min(c.z for c in corners)))
		high = Vector((max(c.x for c in corners), max(c.y for c in corners), max(c.z for c in corners)))
		# Aviso: Blender (X, Y, Z) = Godot (X, Z, Y) con Y invertida.
		print("[asset] %s tris=%d materiales=%s dims_godot(x,y,z)=(%.3f, %.3f, %.3f)" % (
			obj.name, len(mesh.loop_triangles), ",".join(m.name for m in mesh.materials),
			high.x - low.x, high.z - low.z, high.y - low.y))
		print("[asset] %s -> %s" % (obj.name, export_glb(obj, glb_dir)))

	if options["blend-dir"]:
		blend_dir = os.path.abspath(options["blend-dir"])
		os.makedirs(blend_dir, exist_ok=True)
		for index, obj in enumerate(objects): # separados solo para revisar el .blend
			obj.location.x = index * 4.0
		blend_path = os.path.join(blend_dir, "lab_corner_assets.blend")
		bpy.ops.wm.save_as_mainfile(filepath=blend_path)
		print("[blend] " + blend_path)


main()
