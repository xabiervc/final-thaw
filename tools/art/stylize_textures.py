"""Illustrated treatment for albedo textures (docs/art/ASSET_PRODUCTION_BIBLE.md, "Illustrated style").

    D:/Projects/tools/venv_art/Scripts/python.exe tools/art/stylize_textures.py [--only brick,tile]

Needs OpenCV (opencv-contrib-python-headless, Apache-2.0) in an isolated venv (see docs/art/PROVENANCE.md, "Tools").
For each source albedo it writes <name>_paint.<ext> next to it:
- fills: an oil-paint filter (cv2.xphoto.oilPainting) flattens photographic noise into painted patches;
- ink: cv2.stylization's dark edges, extracted as the luminance it removes, become lines tinted with the local colour
  (a dark warm/cool version of the surface, never pure black), with per-material strength;
- value and saturation are shaped toward the reference's disciplined palette.
The source textures stay untouched; materials choose the _paint version.
"""
import os
import sys

import cv2
import numpy as np

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
FACILITY = os.path.join(ROOT, "assets", "textures", "facility")
ELENA = os.path.join(ROOT, "assets", "textures", "characters", "elena")
# file: (oil size, ink strength, saturation, value gamma, ink tint (B, G, R multipliers of the local colour))
JOBS = {
	os.path.join(FACILITY, "brick_diff.jpg"): (4, 0.55, 1.05, 1.0, (0.35, 0.3, 0.32)),
	os.path.join(FACILITY, "tile_diff.jpg"): (3, 0.25, 0.9, 0.95, (0.45, 0.42, 0.4)),
	os.path.join(FACILITY, "green_steel_diff.jpg"): (5, 0.35, 1.0, 1.0, (0.4, 0.38, 0.32)),
	os.path.join(FACILITY, "tread_plate_diff.jpg"): (3, 0.5, 0.9, 1.0, (0.35, 0.32, 0.3)),
	os.path.join(FACILITY, "floor_painted_diff.jpg"): (6, 0.3, 0.9, 1.0, (0.4, 0.38, 0.35)),
	os.path.join(FACILITY, "floor_damaged_diff.jpg"): (6, 0.35, 0.95, 1.0, (0.4, 0.38, 0.35)),
	os.path.join(FACILITY, "concrete_raw_diff.jpg"): (6, 0.35, 0.9, 1.0, (0.42, 0.4, 0.38)),
	os.path.join(FACILITY, "roof_sheet_diff.jpg"): (4, 0.4, 0.9, 1.0, (0.4, 0.38, 0.36)),
	os.path.join(FACILITY, "rubble_diff.jpg"): (4, 0.45, 0.95, 1.0, (0.38, 0.36, 0.34)),
	os.path.join(FACILITY, "rust_diff.jpg"): (5, 0.35, 1.0, 1.0, (0.35, 0.33, 0.3)),
	os.path.join(FACILITY, "dirty_concrete_diff.jpg"): (6, 0.3, 0.9, 1.0, (0.42, 0.4, 0.38)),
	os.path.join(FACILITY, "plaster_peeling_diff.jpg"): (5, 0.45, 1.0, 1.0, (0.4, 0.38, 0.36)),
	# Elena: painted skin (no ink), outfit with seam ink
	os.path.join(ELENA, "elena_skin_albedo.jpg"): (5, 0.0, 1.06, 1.0, (0.5, 0.45, 0.45)),
	os.path.join(ELENA, "elena_outfit_albedo.png"): (3, 0.4, 1.05, 1.0, (0.45, 0.42, 0.4)),
}


def stylize(img, oil, ink, saturation, gamma, tint):
	fills = cv2.xphoto.oilPainting(img, oil, 1) if oil > 1 else img.copy()
	out = fills.astype(np.float32)
	if ink > 0.0:
		sty = cv2.stylization(img, sigma_s=40, sigma_r=0.35).astype(np.float32)
		lum_f = out.mean(axis=2)
		lum_s = sty.mean(axis=2)
		line = np.clip((lum_f - lum_s) / 90.0, 0.0, 1.0)
		line = cv2.GaussianBlur(line, (0, 0), 0.6)
		ink_col = out * np.array(tint, dtype=np.float32)[None, None, :]
		k = (line * ink)[:, :, None]
		out = out * (1.0 - k) + ink_col * k
	hsv = cv2.cvtColor(np.clip(out, 0, 255).astype(np.uint8), cv2.COLOR_BGR2HSV).astype(np.float32)
	hsv[:, :, 1] = np.clip(hsv[:, :, 1] * saturation, 0, 255)
	hsv[:, :, 2] = np.clip(255.0 * (hsv[:, :, 2] / 255.0) ** gamma, 0, 255)
	return cv2.cvtColor(hsv.astype(np.uint8), cv2.COLOR_HSV2BGR)


def main():
	only = []
	if "--only" in sys.argv:
		only = sys.argv[sys.argv.index("--only") + 1].split(",")
	for path, params in JOBS.items():
		name = os.path.basename(path)
		if only and not any(name.startswith(o) for o in only):
			continue
		img = cv2.imread(path, cv2.IMREAD_UNCHANGED)
		alpha = None
		if img.ndim == 3 and img.shape[2] == 4:
			alpha = img[:, :, 3]
			img = img[:, :, :3]
		out = stylize(img, *params)
		if alpha is not None:
			out = np.dstack([out, alpha])
		root, ext = os.path.splitext(path)
		dst = root.replace("_diff", "_paint").replace("_albedo", "_albedo_paint") + ext
		params_out = [cv2.IMWRITE_JPEG_QUALITY, 90] if ext == ".jpg" else [cv2.IMWRITE_PNG_COMPRESSION, 9]
		cv2.imwrite(dst, out, params_out)
		print(os.path.relpath(dst, ROOT), out.shape)


if __name__ == "__main__":
	main()
