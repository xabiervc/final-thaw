"""Helix Station B surface textures from the Poly Haven CC0 library (D:/Projects/external_assets/polyhaven, official API downloads,
see docs/art/PROVENANCE.md) into assets/textures/facility at 1K.

    python tools/art/prepare_facility_textures.py

Per material: <name>_diff.jpg (sRGB), <name>_nor.png (OpenGL normal), <name>_arm.jpg (AO, roughness, metallic). The facility shaders
project them in world space (no UVs needed), so one tiling set serves every wall, floor and kit piece of the same kind.
"""
import os

from PIL import Image

SRC = "D:/Projects/external_assets/polyhaven"
DST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "assets", "textures", "facility")
SIZE = 1024
# repo name: Poly Haven asset (art direction: docs/art/ASSET_PRODUCTION_BIBLE.md, "Helix Station B")
MATERIALS = {
	"brick": "brick_wall_02",              # aged pump-hall brick
	"tile": "long_white_tiles",            # glazed tile dado
	"green_steel": "green_metal_rust",     # painted riveted steel, machinery
	"tread_plate": "metal_grate_rusty",    # catwalks, landings, stair treads
	"floor_painted": "painted_concrete",   # pump-hall floor (green paint, worn)
	"floor_damaged": "concrete_floor_damaged_01",  # pit, culvert, service floors
	"concrete_raw": "concrete_wall_006",   # retaining walls, culvert, bulkheads
	"roof_sheet": "corrugated_iron_02",    # roof underside and outside
	"rubble": "concrete_debris",           # collapse debris
	"rust": "rust_coarse_01",              # rust runs and old iron
	"dirty_concrete": "dirty_concrete",    # yard concrete, exterior ground
	"plaster_peeling": "peeling_painted_wall",  # old service corridor walls
}


def find(folder, key):
	for name in os.listdir(folder):
		if key in name:
			return os.path.join(folder, name)
	return None


def main():
	os.makedirs(DST, exist_ok=True)
	for repo_name, ph in MATERIALS.items():
		folder = os.path.join(SRC, ph)
		diff, nor, arm = find(folder, "Diffuse") or find(folder, "diff"), find(folder, "nor_gl"), find(folder, "arm")
		Image.open(diff).convert("RGB").resize((SIZE, SIZE), Image.LANCZOS).save(os.path.join(DST, repo_name + "_diff.jpg"), quality=88)
		Image.open(nor).convert("RGB").resize((SIZE, SIZE), Image.LANCZOS).save(os.path.join(DST, repo_name + "_nor.png"), optimize=True)
		if arm:
			Image.open(arm).convert("RGB").resize((SIZE, SIZE), Image.LANCZOS).save(os.path.join(DST, repo_name + "_arm.jpg"), quality=88)
		else:  # no ARM in the source: AO 1, roughness 0.85, metallic 0
			Image.new("RGB", (SIZE, SIZE), (255, 217, 0)).save(os.path.join(DST, repo_name + "_arm.jpg"), quality=88)
		print(repo_name, "<-", ph)


if __name__ == "__main__":
	main()
