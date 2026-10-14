"""Marcus's short hair as cards: strips radiating from the crown along the skull to the hairline (ragged tips from the strand texture).

Run in the live session after build_marcus.py:  exec(open(path).read())   (uses hair_cards_lib.py)
"""
import importlib
import math
import random
import sys

import bmesh
import bpy
from mathutils import Vector

sys.path.insert(0, 'D:/Projects/github/final-thaw/tools/blender/elena_mpfb')
import hair_cards_lib as hc

importlib.reload(hc)

body = bpy.data.objects['Marcus_Base']
rig = body.parent
top = max(v.co.z for v in body.data.vertices)
rng = random.Random(23)
skull = hc.Skull(body, Vector((0.0, 0.01, top - 0.09)))
bm = bmesh.new()
bm.loops.layers.uv.new('UVMap')

STRIPS = 26
for layer, lift in ((0, 0.016), (1, 0.021)):
	for k in range(STRIPS):
		phi = math.tau * (k + 0.5 * layer) / STRIPS
		sx, cy = math.sin(phi), math.cos(phi)  # phi = 0 faces the front (-Y)
		hairline_drop = 0.050 + 0.040 * abs(sx) + (0.040 * -cy if cy < 0 else 0.0)  # front high, sides lower, nape lowest
		root = Vector((0.020 * sx, -0.020 * cy, 0.105))
		target = Vector((0.100 * sx, -0.120 * cy, (top - 0.09) - 0.0 - (hairline_drop - 0.09) * -1.0 - 0.09 + 0.0))
		# target height above the centre: hairline z - centre z = (top - drop) - (top - 0.09)
		target.z = 0.09 - hairline_drop
		jitter = Vector((rng.uniform(-0.004, 0.004), rng.uniform(-0.004, 0.004), 0.0))
		pts, nrm = skull.sweep(root + jitter, target + jitter, lift, samples=6, ease=1.0)
		count = len(pts)
		widths = [0.034 * (1.0 - 0.30 * (i / (count - 1))) for i in range(count)]
		u0 = rng.uniform(0.0, 0.7)
		hc.ribbon(bm, pts, nrm, widths, u0, u0 + 0.28)
hc.finish(bm, 'Marcus_HairCards', rig)
