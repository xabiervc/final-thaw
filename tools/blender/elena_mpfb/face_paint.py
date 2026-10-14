"""Procedural face painting shared by Elena and Marcus (used inside the headless bake).

Adds, on top of an existing skin material, soft elliptical masks in head object space (z measured down from the head top):
under-eye shadow, cheek blush, brow shadow, chin tint, plus optional freckles; and a detailed eye material
(limbal ring, radial iris fibres, pupil). Everything is deterministic node maths, baked into the albedo atlas.
"""
import bpy


def _n(nodes, kind, **kw):
	node = nodes.new(kind)
	for key, value in kw.items():
		setattr(node, key, value)
	return node


def _math(nodes, links, op, a, b=None, clamp=False):
	node = _n(nodes, "ShaderNodeMath", operation=op, use_clamp=clamp)
	for i, v in enumerate((a, b)):
		if v is None:
			continue
		if isinstance(v, (int, float)):
			node.inputs[i].default_value = v
		else:
			links.new(v, node.inputs[i])
	return node.outputs[0]


def _map(nodes, links, value, lo, hi):
	node = _n(nodes, "ShaderNodeMapRange", clamp=True)
	node.inputs["From Min"].default_value = lo
	node.inputs["From Max"].default_value = hi
	links.new(value, node.inputs["Value"])
	return node.outputs["Result"]


def _ellipse(nodes, links, ax, z, front, cx, cz, rx, rz, soft=0.5):
	"""1 inside the ellipse (centre cx, cz; radii rx, rz in metres), fading to 0 over `soft` of the radius; limited to the face front."""
	dx = _math(nodes, links, "DIVIDE", _math(nodes, links, "SUBTRACT", ax, cx), rx)
	dz = _math(nodes, links, "DIVIDE", _math(nodes, links, "SUBTRACT", z, cz), rz)
	dist = _math(nodes, links, "SQRT", _math(nodes, links, "ADD", _math(nodes, links, "MULTIPLY", dx, dx), _math(nodes, links, "MULTIPLY", dz, dz)))
	inside = _map(nodes, links, dist, 1.0, 1.0 - soft)
	return _math(nodes, links, "MULTIPLY", inside, front)


def _tint(nodes, links, color_socket, mask, rgb, strength):
	mix = _n(nodes, "ShaderNodeMixRGB")
	mix.inputs["Color2"].default_value = (*rgb, 1.0)
	links.new(_math(nodes, links, "MULTIPLY", mask, strength), mix.inputs["Fac"])
	links.new(color_socket, mix.inputs["Color1"])
	return mix.outputs["Color"]


def paint_face(skin, top, freckles=0.0, brow_shadow=0.25, blush=0.18, eye_bags=0.38):
	nodes, links = skin.node_tree.nodes, skin.node_tree.links
	bsdf = next(n for n in nodes if n.type == "BSDF_PRINCIPLED")
	socket = bsdf.inputs["Base Color"]
	color = socket.links[0].from_socket
	coord = _n(nodes, "ShaderNodeTexCoord")
	sep = _n(nodes, "ShaderNodeSeparateXYZ")
	links.new(coord.outputs["Object"], sep.inputs[0])
	ax = _math(nodes, links, "ABSOLUTE", sep.outputs["X"])
	z = sep.outputs["Z"]
	front = _map(nodes, links, sep.outputs["Y"], 0.03, 0.0)  # 1 on the face, 0 behind the ears
	eye_z = top - 0.120
	bags = _ellipse(nodes, links, ax, z, front, 0.031, eye_z - 0.014, 0.024, 0.011, 0.7)
	color = _tint(nodes, links, color, bags, (0.30, 0.17, 0.20), eye_bags)
	cheek = _ellipse(nodes, links, ax, z, front, 0.052, top - 0.168, 0.030, 0.026, 0.8)
	color = _tint(nodes, links, color, cheek, (0.72, 0.30, 0.28), blush)
	brow = _ellipse(nodes, links, ax, z, front, 0.034, eye_z + 0.016, 0.034, 0.010, 0.8)
	color = _tint(nodes, links, color, brow, (0.26, 0.15, 0.13), brow_shadow)
	chin = _ellipse(nodes, links, ax, z, front, 0.0, top - 0.232, 0.030, 0.016, 0.8)
	color = _tint(nodes, links, color, chin, (0.60, 0.32, 0.28), 0.10)
	if freckles > 0.0:
		noise = _n(nodes, "ShaderNodeTexNoise")
		noise.inputs["Scale"].default_value = 700.0
		noise.inputs["Detail"].default_value = 0.0
		links.new(coord.outputs["Object"], noise.inputs["Vector"])
		dots = _map(nodes, links, noise.outputs["Fac"], 0.60, 0.68)
		zone = _ellipse(nodes, links, ax, z, front, 0.022, top - 0.140, 0.052, 0.020, 0.5)
		color = _tint(nodes, links, color, _math(nodes, links, "MULTIPLY", dots, zone), (0.42, 0.24, 0.17), freckles)
	links.new(color, socket)


def eye_material(name="eye", iris=("7A5A3A", "4A3322"), sclera="E6E0D6"):
	"""Eye sphere whose local +Z faces forward: sclera, limbal ring, radial fibres, pupil."""
	from ref_common import hex_lin
	mat = bpy.data.materials.new(name)
	mat.use_nodes = True
	nodes, links = mat.node_tree.nodes, mat.node_tree.links
	nodes.clear()
	coord = _n(nodes, "ShaderNodeTexCoord")
	norm = _n(nodes, "ShaderNodeVectorMath", operation="NORMALIZE")
	links.new(coord.outputs["Object"], norm.inputs[0])
	sep = _n(nodes, "ShaderNodeSeparateXYZ")
	links.new(norm.outputs["Vector"], sep.inputs[0])
	fwd = sep.outputs["Z"]
	ang = _n(nodes, "ShaderNodeMath", operation="ARCTAN2")
	links.new(sep.outputs["Y"], ang.inputs[0])
	links.new(sep.outputs["X"], ang.inputs[1])
	fibre = _n(nodes, "ShaderNodeTexNoise")
	fibre.inputs["Scale"].default_value = 18.0
	fibre.inputs["Detail"].default_value = 3.0
	comb = _n(nodes, "ShaderNodeCombineXYZ")
	links.new(ang.outputs[0], comb.inputs["X"])
	links.new(_math(nodes, links, "MULTIPLY", _math(nodes, links, "SUBTRACT", 1.0, fwd), 40.0), comb.inputs["Y"])
	links.new(comb.outputs["Vector"], fibre.inputs["Vector"])
	ramp = _n(nodes, "ShaderNodeValToRGB")
	stops = [(0.0, sclera), (0.78, sclera), (0.805, "20150F"), (0.83, iris[1]), (0.90, iris[0]), (0.955, iris[1]), (0.962, "050403"), (1.0, "050403")]
	while len(ramp.color_ramp.elements) < len(stops):
		ramp.color_ramp.elements.new(0.5)
	for el, (pos, col) in zip(ramp.color_ramp.elements, stops):
		el.position = pos
		el.color = hex_lin(col)
	shifted = _math(nodes, links, "ADD", fwd, _math(nodes, links, "MULTIPLY", _math(nodes, links, "SUBTRACT", fibre.outputs["Fac"], 0.5), 0.04))
	links.new(shifted, ramp.inputs["Fac"])
	bsdf = _n(nodes, "ShaderNodeBsdfPrincipled")
	bsdf.inputs["Roughness"].default_value = 0.08
	links.new(ramp.outputs["Color"], bsdf.inputs["Base Color"])
	metal = _n(nodes, "ShaderNodeValue")
	metal.name = "metal_val"
	metal.outputs[0].default_value = 0.0
	out = _n(nodes, "ShaderNodeOutputMaterial")
	links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
	return mat
