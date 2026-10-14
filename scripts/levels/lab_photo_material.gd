extends RefCounted
## Builds a photographic PBR material (Poly Haven CC0 textures in assets/textures/lab_photo) with world-space
## triplanar mapping, so kit meshes do not need usable UVs. tile_m = real-world metres per texture repeat.

const PHOTO_DIR := "res://assets/textures/lab_photo/"

static func make(texture_name: String, tint: Color, tile_m: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.resource_name = texture_name
	m.albedo_texture = load(PHOTO_DIR + texture_name + "_diff.jpg")
	m.albedo_color = tint
	m.normal_enabled = true
	m.normal_texture = load(PHOTO_DIR + texture_name + "_nor.png")
	var arm: Texture2D = load(PHOTO_DIR + texture_name + "_arm.jpg")
	m.ao_enabled = true
	m.ao_texture = arm
	m.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	m.roughness = 1.0
	m.roughness_texture = arm
	m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	m.metallic = 1.0
	m.metallic_texture = arm
	m.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE / tile_m
	return m
