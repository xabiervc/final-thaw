"""Copy the asphalt used by the Phase 2 service yard from D:/Projects/external_assets (ambientCG Asphalt033, CC0) into the repo at 1K.

    python tools/art/prepare_parking_textures.py

Outputs assets/textures/lab_photo/asphalt_033_{diff,nor,arm}.{jpg,png} in the same layout as prepare_photo_textures.py:
ARM = ambient occlusion (R), roughness (G), metallic (B = 0). Source listed in docs/art/PROVENANCE.md.
"""
import os

from PIL import Image

SRC = "D:/Projects/external_assets/ambientcg/Asphalt033/Asphalt033_2K-JPG_%s.jpg"
DST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "textures", "lab_photo")
SIZE = 1024

color = Image.open(SRC % "Color").convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)
color.save(os.path.join(DST, "asphalt_033_diff.jpg"), quality=88)
normal = Image.open(SRC % "NormalGL").convert("RGB").resize((SIZE, SIZE), Image.LANCZOS)
normal.save(os.path.join(DST, "asphalt_033_nor.png"), optimize=True)
ao = Image.open(SRC % "AmbientOcclusion").convert("L").resize((SIZE, SIZE), Image.LANCZOS)
rough = Image.open(SRC % "Roughness").convert("L").resize((SIZE, SIZE), Image.LANCZOS)
metal = Image.new("L", (SIZE, SIZE), 0)
Image.merge("RGB", (ao, rough, metal)).save(os.path.join(DST, "asphalt_033_arm.jpg"), quality=88)
for n in ("asphalt_033_diff.jpg", "asphalt_033_nor.png", "asphalt_033_arm.jpg"):
	print(n, os.path.getsize(os.path.join(DST, n)) // 1024, "KB")
