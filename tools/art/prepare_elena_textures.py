"""Elena v2 head textures from the MakeHuman CC0 asset packs (D:/Projects/external_assets/makehuman, see docs/art/PROVENANCE.md).

    python tools/art/prepare_elena_textures.py

Outputs assets/textures/characters/elena/:
- elena_skin_albedo.jpg: skins01 "onlytheghosts_middle_aged_eurasian_female" (2048), warmed slightly toward the concept's skin swatch.
- elena_skin_normal.png: fine pore/skin-relief normal derived from the albedo's high frequencies (1024; weak on purpose).
- elena_eyes_albedo.png: system "brown" eyes with the iris moved from red-brown to the concept's warm dark brown.
- elena_hair_albedo.png: system "ponytail01" strands recoloured to the concept's dark brown, alpha kept.
- elena_brows_albedo.png, elena_lashes_albedo.png: system eyebrow001 / eyelashes02, darkened, alpha kept.
The concept (assets/concept/characters/elena_vast_concept.png) is only read for its palette; none of its pixels are reused.
"""
import colorsys
import os

import numpy as np
from PIL import Image, ImageFilter

MH = "D:/Projects/external_assets/makehuman"
DST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "textures", "characters", "elena")
SKIN = MH + "/skins01/skins/onlytheghosts_middle_aged_eurasian_female/middleage_eurasian_female_diffuse.png"
EYES = MH + "/system/eyes/materials/brown_eye.png"
HAIR = MH + "/system/hair/ponytail01/ponytail01_diffuse.png"
BROWS = MH + "/system/eyebrows/eyebrow001/eyebrow001.png"
LASHES = MH + "/system/eyelashes/eyelashes02/eyelashes02.png"
# Concept palette (sampled by eye from the swatches and the head study): hair dark brown, iris warm brown.
HAIR_DARK = np.array([0.075, 0.055, 0.045])
HAIR_LIGHT = np.array([0.36, 0.27, 0.21])
IRIS_HUE = 0.075  # ~27 degrees: brown, not red


def save(img, name, **kw):
	path = os.path.join(DST, name)
	img.save(path, **kw)
	print(name, img.size, os.path.getsize(path) // 1024, "KB")


def skin():
	img = np.asarray(Image.open(SKIN).convert("RGB"), dtype=np.float32) / 255.0
	# a touch warmer and less grey than the source (the concept's skin swatch is a warm light tan)
	img = img * np.array([1.03, 0.995, 0.96])
	img = np.clip(img, 0.0, 1.0)
	save(Image.fromarray((img * 255.0 + 0.5).astype(np.uint8)), "elena_skin_albedo.jpg", quality=92)
	# normal from luminance high-pass: pores and fine creases only (the large forms are geometry)
	lum = Image.open(SKIN).convert("L").resize((1024, 1024), Image.LANCZOS)
	blur = lum.filter(ImageFilter.GaussianBlur(6))
	hp = (np.asarray(lum, dtype=np.float32) - np.asarray(blur, dtype=np.float32)) / 255.0
	strength = 2.2
	gy, gx = np.gradient(hp)
	nx, ny, nz = -gx * strength, gy * strength, np.ones_like(hp)
	length = np.sqrt(nx * nx + ny * ny + nz * nz)
	normal = np.stack([nx / length, ny / length, nz / length], axis=-1) * 0.5 + 0.5
	save(Image.fromarray((normal * 255.0 + 0.5).astype(np.uint8)), "elena_skin_normal.png", optimize=True)


def eyes():
	rgba = np.asarray(Image.open(EYES).convert("RGBA"), dtype=np.float32) / 255.0
	out = rgba.copy()
	h, w, _ = rgba.shape
	for y in range(h):
		row = rgba[y]
		for x in range(w):
			r, g, b, a = row[x]
			hh, ss, vv = colorsys.rgb_to_hsv(r, g, b)
			if ss > 0.25 and vv < 0.8:  # iris (the sclera and its veins are pale)
				ss = min(1.0, ss * 0.85)
				vv = vv * 0.85
				out[y, x, :3] = colorsys.hsv_to_rgb(IRIS_HUE, ss, vv)
			elif ss <= 0.25:  # sclera: lift a little toward off-white, never pure white
				out[y, x, :3] = np.clip(np.array([r, g, b]) * 1.08 + 0.02, 0.0, 0.9)
	save(Image.fromarray((out * 255.0 + 0.5).astype(np.uint8), "RGBA"), "elena_eyes_albedo.png", optimize=True)


def recolour_strands(src, name, dark, light, size=None, gamma=1.0):
	img = Image.open(src).convert("RGBA")
	if size:
		img = img.resize((size, size), Image.LANCZOS)
	arr = np.asarray(img, dtype=np.float32) / 255.0
	lum = (0.299 * arr[..., 0] + 0.587 * arr[..., 1] + 0.114 * arr[..., 2]) ** gamma
	col = dark[None, None, :] + (light - dark)[None, None, :] * lum[..., None]
	out = np.concatenate([col, arr[..., 3:4]], axis=-1)
	save(Image.fromarray((np.clip(out, 0, 1) * 255.0 + 0.5).astype(np.uint8), "RGBA"), name, optimize=True)


def main():
	os.makedirs(DST, exist_ok=True)
	skin()
	eyes()
	recolour_strands(HAIR, "elena_hair_albedo.png", HAIR_DARK, HAIR_LIGHT, size=2048, gamma=1.15)
	recolour_strands(BROWS, "elena_brows_albedo.png", np.array([0.05, 0.035, 0.03]), np.array([0.22, 0.16, 0.12]))
	recolour_strands(LASHES, "elena_lashes_albedo.png", np.array([0.02, 0.018, 0.016]), np.array([0.10, 0.08, 0.07]))


if __name__ == "__main__":
	main()
