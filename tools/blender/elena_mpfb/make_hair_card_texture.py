"""Procedural strand texture (RGBA) for hair cards + the Godot material that uses it.

    python -I tools/blender/elena_mpfb/make_hair_card_texture.py --repo D:/Projects/github/final-thaw [--name elena_hair_cards]

Strands run along V (root at the bottom of the image, tips at the top), several clumps wide so each card can sample a different U window.
Deterministic (fixed seed). Requires Pillow.
"""
import argparse
import math
import os
import random

from PIL import Image, ImageDraw

W, H = 1024, 512
SS = 2  # supersampling factor
PALETTES = {
	"elena_hair_cards": [(0x22, 0x18, 0x14), (0x2E, 0x20, 0x19), (0x3A, 0x28, 0x1F), (0x4B, 0x35, 0x28)],
	"marcus_hair_cards": [(0x12, 0x0E, 0x0C), (0x1A, 0x14, 0x11), (0x24, 0x1B, 0x16), (0x31, 0x25, 0x1D)],
}


def draw_strands(palette, seed=7, count=230):
	rng = random.Random(seed)
	img = Image.new("RGBA", (W * SS, H * SS), (*palette[1], 0))
	draw = ImageDraw.Draw(img)
	for _ in range(count):
		x0 = rng.uniform(-10, W + 10)
		length = rng.uniform(0.55, 1.0) * H
		width_root = rng.uniform(2.2, 5.0)
		sway = rng.uniform(2.0, 9.0)
		freq = rng.uniform(0.6, 1.6)
		phase = rng.uniform(0, math.tau)
		base = rng.choice(palette)
		shade = rng.uniform(0.8, 1.15)
		root_y = H - rng.uniform(0.0, 0.14) * H  # staggered roots: ragged hairline instead of a hard edge
		steps = 40
		left, right = [], []
		for i in range(steps + 1):
			t = i / steps
			y = root_y - t * length
			x = x0 + math.sin(phase + t * math.pi * freq) * sway * t
			w = width_root * (1.0 - 0.85 * t ** 1.4)
			left.append(((x - w) * SS, y * SS))
			right.append(((x + w) * SS, y * SS))
		poly = left + right[::-1]
		color = tuple(min(255, int(c * shade * (0.75 + 0.25 * (1 - 0.0)))) for c in base) + (255,)
		draw.polygon(poly, fill=color)
		# a lighter thin highlight line on some strands
		if rng.random() < 0.3:
			hl = tuple(min(255, int(c * 1.7)) for c in base) + (255,)
			draw.line([((x0 + (left[i][0] / SS - x0) * 0.2) * SS, left[i][1]) for i in range(0, steps, 1)], fill=hl, width=SS)
	return img.resize((W, H), Image.LANCZOS)


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--repo", required=True)
	parser.add_argument("--name", default="elena_hair_cards")
	args = parser.parse_args()
	img = draw_strands(PALETTES[args.name])
	# fill fully transparent texels with the mean colour so mip filtering does not leave dark fringes
	px = img.load()
	mean = PALETTES[args.name][1]
	for y in range(H):
		for x in range(W):
			r, g, b, a = px[x, y]
			if a == 0:
				px[x, y] = (*mean, 0)
	tex_dir = os.path.join(args.repo, "assets", "textures", "lab_ref")
	mat_dir = os.path.join(args.repo, "assets", "materials", "lab_ref")
	os.makedirs(tex_dir, exist_ok=True)
	os.makedirs(mat_dir, exist_ok=True)
	img.save(os.path.join(tex_dir, args.name + ".png"))
	tres = (
		'[gd_resource type="StandardMaterial3D" load_steps=2 format=3]\n\n'
		'[ext_resource type="Texture2D" path="res://assets/textures/lab_ref/%(n)s.png" id="1"]\n\n'
		'[resource]\n'
		'resource_name = "%(n)s"\n'
		'transparency = 2\n'
		'alpha_scissor_threshold = 0.45\n'
		'cull_mode = 2\n'
		'albedo_texture = ExtResource("1")\n'
		'roughness = 0.55\n'
		'metallic_specular = 0.6\n'
	) % {"n": args.name}
	with open(os.path.join(mat_dir, args.name + ".tres"), "w", encoding="utf-8", newline="\n") as handle:
		handle.write(tres)
	print("wrote", args.name)


main()
