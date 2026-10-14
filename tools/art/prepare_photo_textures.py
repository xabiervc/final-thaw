"""Copy the photographic textures used by the lab dressing from D:/Projects/external_assets (Poly Haven, CC0) into the repo at 1K.

    python tools/art/prepare_photo_textures.py

Outputs assets/textures/lab_photo/<name>_{diff,nor,arm}.{jpg,png}. Sources are listed in docs/art/PROVENANCE.md.
"""
import os

from PIL import Image

SRC = "D:/Projects/external_assets/polyhaven"
DST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "textures", "lab_photo")
SIZE = 1024
USED = ["concrete_floor_worn_001", "painted_plaster_wall", "concrete_panels", "metal_plate_02"]

os.makedirs(DST, exist_ok=True)
for name in USED:
	for src_suffix, out_suffix, ext in (("Diffuse_2k.jpg", "diff", "jpg"), ("nor_gl_2k.png", "nor", "png"), ("arm_2k.jpg", "arm", "jpg")):
		path = os.path.join(SRC, name, "%s_%s" % (name, src_suffix))
		img = Image.open(path).convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)
		out = os.path.join(DST, "%s_%s.%s" % (name, out_suffix, ext))
		if ext == "jpg":
			img.save(out, quality=88)
		else:
			img.save(out, optimize=True)
		print(os.path.basename(out), os.path.getsize(out) // 1024, "KB")
