extends RefCounted
## Shared material palette for the Helix test bay (Elena test room art direction).
##
## Functional categories, one shared material per category so the whole room stays at a handful of draw calls:
## painted wall, bulkhead concrete, dark steel, worn light steel, wall caps, hazard paint, rubber/cable, pipes,
## and the few emissive accents. Emissive colour rules follow docs/art/LAB_STYLE_SPEC.md: amber = interactables,
## cyan = Elena / scanning / Aster tech, red = locked or danger, green = unlocked / safe, cold white = facility light.

const PHOTO_DIR := "res://assets/textures/lab_photo/"
const WALL_SHADER := preload("res://assets/shaders/facility_wall.gdshader")
## Variant with the dither cutaway (uses discard): only for walls that fade out of the camera's way.
const WALL_CUTAWAY_SHADER := preload("res://assets/shaders/facility_wall_cutaway.gdshader")
const FLOOR_SHADER := preload("res://assets/shaders/facility_floor.gdshader")
const HAZARD_SHADER := preload("res://assets/shaders/hazard_paint.gdshader")
const PhotoMaterial := preload("res://scripts/levels/lab_photo_material.gd")
const NOISE_SEED := 4127  # fixed: puddles, stains and frost are identical on every run

const COLD_WHITE := Color(0.78, 0.88, 1.0)
const WARNING_RED := Color(1.0, 0.16, 0.08)
const SAFE_GREEN := Color(0.35, 1.0, 0.3)
const ASTER_CYAN := Color(0.35, 0.95, 0.9)
const HEATER_WARM := Color(1.0, 0.55, 0.25)

var _cache: Dictionary = {}
var _noise: NoiseTexture2D = null


func noise() -> NoiseTexture2D:
	if _noise == null:
		var fast := FastNoiseLite.new()
		fast.seed = NOISE_SEED
		fast.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		fast.frequency = 0.012
		fast.fractal_octaves = 4
		_noise = NoiseTexture2D.new()
		_noise.width = 256
		_noise.height = 256
		_noise.seamless = true
		_noise.generate_mipmaps = true
		_noise.noise = fast
	return _noise


## A 64 px diamond wire pattern (deterministic), for the chain-link fence material.
func _chain_link_texture() -> ImageTexture:
	var img := Image.create(64, 64, true, Image.FORMAT_RGBA8)
	for y in 64:
		for x in 64:
			var a := absf(fmod(float(x + y), 32.0) - 16.0) < 1.6 or absf(fmod(float(x - y + 64), 32.0) - 16.0) < 1.6
			img.set_pixel(x, y, Color(1, 1, 1, 1.0 if a else 0.0))
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func get_material(key: String) -> Material:
	if not _cache.has(key):
		_cache[key] = _build(key)
	return _cache[key]


func _wall(texture_name: String, tint: Color, tile_m: float) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = WALL_SHADER
	m.set_shader_parameter("albedo_tex", load(PHOTO_DIR + texture_name + "_diff.jpg"))
	m.set_shader_parameter("arm_tex", load(PHOTO_DIR + texture_name + "_arm.jpg"))
	m.set_shader_parameter("noise_tex", noise())
	m.set_shader_parameter("tint", tint)
	m.set_shader_parameter("tile_m", tile_m)
	return m


func _flat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m


func _emissive(color: Color, energy: float, base: Color = Color(0.05, 0.05, 0.05)) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = base
	m.roughness = 0.4
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	return m


func _build(key: String) -> Material:
	match key:
		"wall":
			# Painted cold blue-grey panels with seams; carries the meltwater tide line.
			var m := _wall("painted_plaster_wall", Color(0.36, 0.42, 0.47), 2.5)
			m.set_shader_parameter("seam_spacing", 2.0)
			return m
		"wall_alcove":
			# Own instance of the wall material, with the cutaway variant, so only this wall pays for discard.
			var m := _wall("painted_plaster_wall", Color(0.36, 0.42, 0.47), 2.5)
			m.shader = WALL_CUTAWAY_SHADER
			m.set_shader_parameter("seam_spacing", 2.0)
			return m
		"wall_frost":
			var m := _wall("painted_plaster_wall", Color(0.36, 0.42, 0.47), 2.5)
			m.set_shader_parameter("frost_amount", 1.0)
			m.set_shader_parameter("frost_start", 1.9)
			return m
		"bulkhead":
			# Poured bulkhead walls between bays: heavier, darker, no panel seams.
			var m := _wall("concrete_panels", Color(0.33, 0.36, 0.38), 6.0)
			m.set_shader_parameter("seam_spacing", 0.0)
			m.set_shader_parameter("seam_height_a", -10.0)
			m.set_shader_parameter("seam_height_b", -10.0)
			return m
		"steel":
			# Dark structural steel: pilasters, frames, posts.
			var m := _wall("metal_plate_02", Color(0.2, 0.23, 0.26), 1.5)
			m.set_shader_parameter("metallic_amount", 0.6)
			m.set_shader_parameter("seam_spacing", 0.0)
			m.set_shader_parameter("seam_height_a", -10.0)
			m.set_shader_parameter("seam_height_b", -10.0)
			m.set_shader_parameter("grime_strength", 0.3)
			return m
		"steel_light":
			# Worn brushed steel: barrier planks, housings, rails.
			var m := _wall("metal_plate_02", Color(0.42, 0.45, 0.47), 1.2)
			m.set_shader_parameter("metallic_amount", 0.8)
			m.set_shader_parameter("seam_spacing", 0.0)
			m.set_shader_parameter("seam_height_a", -10.0)
			m.set_shader_parameter("seam_height_b", -10.0)
			m.set_shader_parameter("roughness_bias", -0.1)
			return m
		"machine":
			# Painted machinery housing (generator, pump): muted Helix green-grey.
			var m := _wall("metal_plate_02", Color(0.25, 0.3, 0.28), 1.6)
			m.set_shader_parameter("metallic_amount", 0.3)
			m.set_shader_parameter("seam_spacing", 0.0)
			m.set_shader_parameter("seam_height_a", -10.0)
			m.set_shader_parameter("seam_height_b", -10.0)
			return m
		"floor":
			var m := ShaderMaterial.new()
			m.shader = FLOOR_SHADER
			m.set_shader_parameter("albedo_tex", load(PHOTO_DIR + "concrete_floor_worn_001_diff.jpg"))
			m.set_shader_parameter("arm_tex", load(PHOTO_DIR + "concrete_floor_worn_001_arm.jpg"))
			m.set_shader_parameter("normal_tex", load(PHOTO_DIR + "concrete_floor_worn_001_nor.png"))
			m.set_shader_parameter("noise_tex", noise())
			return m
		"asphalt":
			# Phase 2 service yard: wet asphalt (ambientCG Asphalt033, CC0), no slab joints, puddles under the lights.
			var m := ShaderMaterial.new()
			m.shader = FLOOR_SHADER
			m.set_shader_parameter("albedo_tex", load(PHOTO_DIR + "asphalt_033_diff.jpg"))
			m.set_shader_parameter("arm_tex", load(PHOTO_DIR + "asphalt_033_arm.jpg"))
			m.set_shader_parameter("normal_tex", load(PHOTO_DIR + "asphalt_033_nor.png"))
			m.set_shader_parameter("noise_tex", noise())
			m.set_shader_parameter("tint", Color(0.42, 0.44, 0.46))
			m.set_shader_parameter("tile_m", 4.0)
			m.set_shader_parameter("joint_spacing", 1000.0)
			m.set_shader_parameter("wetness", 0.04)
			m.set_shader_parameter("room_bounds", Vector4(34.0, -15.5, 76.0, 14.0))
			return m
		"fence":
			# Chain-link mesh: see-through (alpha scissor), so fences block movement but never sight.
			var m := StandardMaterial3D.new()
			m.albedo_texture = _chain_link_texture()
			m.albedo_color = Color(0.55, 0.58, 0.6)
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			m.alpha_scissor_threshold = 0.5
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
			m.metallic = 0.6
			m.roughness = 0.5
			m.uv1_triplanar = true
			m.uv1_scale = Vector3(1.6, 1.6, 1.6)
			return m
		"paint_line":
			return _flat(Color(0.82, 0.78, 0.55), 0.85)
		"grate":
			return PhotoMaterial.make("metal_plate_02", Color(0.3, 0.32, 0.33), 0.5, 0.8)
		"grate_warm":
			# Heated grating of the warming station: lighter steel so the heater's warm pool reads on it.
			return PhotoMaterial.make("metal_plate_02", Color(0.62, 0.55, 0.5), 0.5, 0.8)
		"cap":
			return _flat(Color(0.035, 0.04, 0.048), 0.85)
		"cap_edge":
			return _flat(Color(0.3, 0.33, 0.36), 0.5, 0.6)
		"hazard":
			var m := ShaderMaterial.new()
			m.shader = HAZARD_SHADER
			m.set_shader_parameter("noise_tex", noise())
			return m
		"rubber":
			return _flat(Color(0.05, 0.055, 0.06), 0.75)
		"pipe":
			return _flat(Color(0.22, 0.27, 0.3), 0.45, 0.5)
		"pipe_red":
			# Fire main: the one saturated pipe in the room, oxide red.
			return _flat(Color(0.38, 0.08, 0.06), 0.55, 0.2)
		"locker":
			return _flat(Color(0.2, 0.26, 0.3), 0.6, 0.35)
		"safety_paint":
			return _flat(Color(0.62, 0.45, 0.09), 0.8)
		"blanket":
			# Foil thermal blanket: crumpled metallic gold, dull from dirt.
			return _flat(Color(0.42, 0.36, 0.2), 0.45, 0.7)
		"stencil":
			return _flat(Color(0.75, 0.72, 0.62), 0.9)
		"screen_dark":
			return _flat(Color(0.02, 0.025, 0.03), 0.15, 0.0)
		"lamp_cold":
			return _emissive(COLD_WHITE, 3.0, Color(0.6, 0.65, 0.7))
		"lamp_dead":
			return _flat(Color(0.12, 0.13, 0.14), 0.3)
		"lamp_flicker":
			return _emissive(COLD_WHITE, 3.0, Color(0.6, 0.65, 0.7))
		"lamp_power":
			# Fixtures on the generator circuit: dark until power is restored (animated by the power controller).
			return _emissive(COLD_WHITE, 0.0, Color(0.12, 0.13, 0.14))
		"beacon_red":
			return _emissive(WARNING_RED, 4.0, Color(0.3, 0.02, 0.02))
		"status_power":
			# Red before power, green after (animated by the power controller).
			return _emissive(WARNING_RED, 2.5, Color(0.1, 0.02, 0.02))
		"heater":
			return _emissive(HEATER_WARM, 3.0, Color(0.3, 0.12, 0.05))
		"aster_screen":
			return _emissive(ASTER_CYAN, 1.6, Color(0.02, 0.05, 0.05))
		"gen_vent":
			# Generator cooling vents: dead before power, cold glow after (animated).
			return _emissive(Color(0.55, 0.8, 1.0), 0.0, Color(0.05, 0.06, 0.07))
		"chevron":
			# Exit floor chevrons: unlit paint before power, green after (animated).
			return _emissive(SAFE_GREEN, 0.0, Color(0.16, 0.2, 0.17))
	push_warning("FacilityMaterials: unknown material %s" % key)
	return _flat(Color.MAGENTA, 1.0)
