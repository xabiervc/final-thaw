"""Shared hair-card helpers (Blender, live session): skull sampling, ribbon strips, object creation."""
import bpy
import bmesh
from mathutils import Vector


class Skull:
	"""Samples the head surface radially from a centre point."""

	def __init__(self, body, center):
		self.body = body
		self.center = center
		self.depsgraph = bpy.context.evaluated_depsgraph_get()

	def point(self, direction, lift):
		d = direction.normalized()
		ok, loc, normal, _ = self.body.ray_cast(self.center + d * 0.4, -d, depsgraph=self.depsgraph)
		if not ok:
			return self.center + d * 0.1, d
		return loc + normal * lift, normal

	def sweep(self, root_dir, target_dir, lift, samples=7, ease=0.9, lift_gain=0.004):
		"""Strand path from root_dir to target_dir (both directions from the centre), lifted off the surface."""
		pts, nrm = [], []
		for i in range(samples):
			t = i / (samples - 1)
			p, n = self.point(root_dir.lerp(target_dir, t ** ease), lift + lift_gain * t)
			pts.append(p)
			nrm.append(n)
		return pts, nrm


def ribbon(bm, pts, nrm, widths, u0, u1):
	"""Quad strip along pts; width direction = tangent x normal; V runs root (0) -> tip (1), U from u0 to u1."""
	rows = []
	n = len(pts)
	for i, (p, nv, w) in enumerate(zip(pts, nrm, widths)):
		tangent = (pts[min(i + 1, n - 1)] - pts[max(i - 1, 0)]).normalized()
		side = tangent.cross(nv).normalized()
		rows.append((bm.verts.new(p - side * w * 0.5), bm.verts.new(p + side * w * 0.5), i / (n - 1)))
	uv_layer = bm.loops.layers.uv.verify()
	for (a0, b0, v0), (a1, b1, v1) in zip(rows, rows[1:]):
		face = bm.faces.new((a0, b0, b1, a1))
		for loop, (u, v) in zip(face.loops, ((u0, v0), (u1, v0), (u1, v1), (u0, v1))):
			loop[uv_layer].uv = (u, v)
		face.smooth = True


def finish(bm, name, rig, group='head'):
	"""Turn the bmesh into an object skinned fully to one bone group."""
	if name in bpy.data.objects:
		bpy.data.objects.remove(bpy.data.objects[name])
	mesh = bpy.data.meshes.new(name)
	bm.to_mesh(mesh)
	bm.free()
	obj = bpy.data.objects.new(name, mesh)
	bpy.context.scene.collection.objects.link(obj)
	vg = obj.vertex_groups.new(name=group)
	vg.add(list(range(len(mesh.vertices))), 1.0, 'REPLACE')
	obj.parent = rig
	mod = obj.modifiers.new('Armature', 'ARMATURE')
	mod.object = rig
	print(name, 'tris', len(mesh.polygons) * 2)
	return obj
