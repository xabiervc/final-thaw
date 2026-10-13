"""Flat PBR placeholders from the Elena palette (docs/art, elena_vast_concept.png). Textured materials replace these in the bake step."""
import bpy

PALETTE = {  # object: (sRGB hex, roughness)
	'Elena_Coat': ('2A4A50', 0.8), 'Elena_Knit': ('232628', 0.9), 'Elena_Trousers': ('30353A', 0.85), 'Elena_Boots': ('1D3234', 0.35),
	'Elena_Hair': ('241A17', 0.6), 'Elena_Ponytail': ('241A17', 0.6), 'Elena_Brow_L': ('1A120E', 0.7), 'Elena_Brow_R': ('1A120E', 0.7),
	'Elena_Eye_L': ('D8D2C8', 0.2), 'Elena_Eye_R': ('D8D2C8', 0.2), 'Elena_Base': ('D2A68E', 0.55),
	'Elena_Strap_L': ('1B1E20', 0.85), 'Elena_Strap_R': ('1B1E20', 0.85),
}


def srgb_to_linear(hex_color):
	chan = [int(hex_color[i:i + 2], 16) / 255 for i in (0, 2, 4)]
	return tuple((c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4) for c in chan) + (1,)


for name, (hex_color, rough) in PALETTE.items():
	obj = bpy.data.objects.get(name)
	if obj is None:
		continue
	mat = bpy.data.materials.get(name + '_mat') or bpy.data.materials.new(name + '_mat')
	mat.use_nodes = True
	bsdf = mat.node_tree.nodes['Principled BSDF']
	bsdf.inputs['Base Color'].default_value = srgb_to_linear(hex_color)
	bsdf.inputs['Roughness'].default_value = rough
	obj.data.materials.clear()
	obj.data.materials.append(mat)
