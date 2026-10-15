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


## Helix Station B surfaces (docs/art/ASSET_PRODUCTION_BIBLE.md, "Helix Station B"): world-space PBR sets from
## assets/textures/facility (Poly Haven CC0, tools/art/prepare_facility_textures.py) on station_surface.gdshader.
const STATION_DIR := "res://assets/textures/facility/"
const STATION_SHADER := preload("res://assets/shaders/station_surface.gdshader")


func _station(set_a: String, tint: Color, tile_m: float, options: Dictionary = {}) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = STATION_SHADER
	m.set_shader_parameter("albedo_a", _painted(set_a))
	m.set_shader_parameter("normal_a", load(STATION_DIR + set_a + "_nor.png"))
	m.set_shader_parameter("arm_a", load(STATION_DIR + set_a + "_arm.jpg"))
	m.set_shader_parameter("tint_a", tint)
	m.set_shader_parameter("tile_a", tile_m)
	m.set_shader_parameter("noise_tex", noise())
	if options.has("dado"):
		var b: String = options["dado"]
		m.set_shader_parameter("albedo_b", _painted(b))
		m.set_shader_parameter("normal_b", load(STATION_DIR + b + "_nor.png"))
		m.set_shader_parameter("arm_b", load(STATION_DIR + b + "_arm.jpg"))
	for key in options:
		if key != "dado":
			m.set_shader_parameter(key, options[key])
	return m


## The illustrated (painted) albedo of a station set if tools/art/stylize_textures.py made one, else the photo one.
func _painted(set_name: String) -> Texture2D:
	var painted := STATION_DIR + set_name + "_paint.jpg"
	return load(painted) if ResourceLoader.exists(painted) else load(STATION_DIR + set_name + "_diff.jpg")


## Illustrated shading for standard environment materials: Godot's toon diffuse (soft terminator), no specular.
static func illustrate(m: BaseMaterial3D) -> BaseMaterial3D:
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	# Environment materials are diffuse-only, like the shaders (illustrated_light.gdshaderinc: painted highlights,
	# and 2-3 ms saved at 720p on the reference GPU).
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m


func _flat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	illustrate(m)
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m


func _emissive(color: Color, energy: float, base: Color = Color(0.05, 0.05, 0.05)) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	illustrate(m)
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
			# Red-oxide handrail paint (the illustrated reference's red-brown steelwork; reads against brick and teal).
			return _flat(Color(0.5, 0.17, 0.11), 0.7)
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
		# --- Helix Station B (historic station, Helix insert, neglect) ---
		"st_wall":
			# Pump-hall wall: aged brick over a glazed tile dado with a dark green bullnose band.
			return _station("brick", Color(0.92, 0.88, 0.86), 2.4, {"dado": "tile", "tile_b": 1.3, "dado_height": 1.4,
				"saturation_a": 0.8, "tint_b": Color(0.86, 0.85, 0.8), "saturation_b": 0.7, "cap_color": Color(0.11, 0.19, 0.15),
				"normal_strength": 1.2, "rotate_b": true})
		"st_brick":
			return _station("brick", Color(0.92, 0.88, 0.86), 2.4, {"saturation_a": 0.8, "normal_strength": 1.2, "grime_strength": 0.25})
		"st_brick_outside":
			# Exterior brick: no interior flood marks, weather streaks instead.
			return _station("brick", Color(0.85, 0.8, 0.78), 2.4, {"saturation_a": 0.75, "tide_strength": 0.0, "streak_strength": 0.4,
				"grime_strength": 0.3, "grime_height": 0.8})
		"st_tile":
			return _station("tile", Color(0.86, 0.85, 0.8), 1.3, {"saturation_a": 0.7})  # vertical tile panels (A set is not rotated)
		"st_concrete":
			return _station("concrete_raw", Color(0.78, 0.78, 0.76), 4.0, {"saturation_a": 0.5, "tide_strength": 0.7})
		"st_concrete_outside":
			return _station("concrete_raw", Color(0.7, 0.71, 0.7), 4.0, {"saturation_a": 0.5, "tide_strength": 0.0, "streak_strength": 0.4})
		"st_floor_painted":
			# Hall floor: old green deck paint worn to grey-green; low contrast so it never reads as water.
			return _station("floor_painted", Color(0.5, 0.56, 0.54), 5.0, {"saturation_a": 0.14, "is_floor": true, "normal_strength": 0.5})
		"st_floor_damaged":
			return _station("floor_damaged", Color(0.8, 0.8, 0.8), 3.0, {"saturation_a": 0.45, "is_floor": true})
		"st_tread":
			# Tread plate: catwalks, mezzanine decks, stair landings (rust toned down).
			return _station("tread_plate", Color(0.62, 0.6, 0.58), 0.9, {"saturation_a": 0.35, "is_floor": true, "metallic_amount": 0.7,
				"normal_strength": 1.4})
		"st_green_steel":
			# Station green: painted riveted steel, pumps, old machinery (triplanar for curved kit pieces).
			return _station("green_steel", Color(0.82, 0.9, 0.86), 1.6, {"saturation_a": 0.7, "triplanar": true, "metallic_amount": 0.5,
				"grime_strength": 0.25, "tide_strength": 0.4})
		"st_green_steel_flat":
			return _station("green_steel", Color(0.82, 0.9, 0.86), 1.6, {"saturation_a": 0.7, "metallic_amount": 0.5, "grime_strength": 0.25})
		"st_roof":
			return _station("roof_sheet", Color(0.62, 0.63, 0.64), 2.0, {"saturation_a": 0.5, "metallic_amount": 0.6, "tide_strength": 0.0,
				"grime_strength": 0.0})
		"st_rubble":
			return _station("rubble", Color(0.8, 0.79, 0.77), 1.4, {"triplanar": true, "saturation_a": 0.5, "tide_strength": 0.0})
		"st_rust":
			return _station("rust", Color(0.8, 0.72, 0.66), 1.2, {"triplanar": true, "saturation_a": 0.6, "metallic_amount": 0.3})
		"st_plaster":
			# Old service corridor plaster, peeling (the source's pink pushed to a faded station cream).
			return _station("plaster_peeling", Color(0.92, 0.95, 0.88), 2.2, {"saturation_a": 0.12, "dado": "tile", "tile_b": 1.3,
				"dado_height": 1.2, "tint_b": Color(0.86, 0.85, 0.8), "saturation_b": 0.7, "rotate_b": true})
		"st_yard_concrete":
			return _station("dirty_concrete", Color(0.66, 0.67, 0.68), 4.0, {"saturation_a": 0.4, "is_floor": true})
		"helix_panel":
			# Helix insert: off-white composite panels with 1.2 m seams, recent and maintained (no flood marks).
			var hp := _wall("painted_plaster_wall", Color(0.62, 0.63, 0.61), 2.5)
			hp.set_shader_parameter("seam_spacing", 1.2)
			hp.set_shader_parameter("seam_height_a", 0.12)
			hp.set_shader_parameter("seam_height_b", 2.4)
			hp.set_shader_parameter("seam_darkness", 0.4)
			hp.set_shader_parameter("tide_height", -1.0)
			hp.set_shader_parameter("grime_strength", 0.15)
			hp.set_shader_parameter("roughness_bias", -0.25)
			return hp
		"helix_floor":
			# Helix raised access floor: 60 cm grey tiles, dry.
			var hf := ShaderMaterial.new()
			hf.shader = FLOOR_SHADER
			hf.set_shader_parameter("albedo_tex", load(PHOTO_DIR + "concrete_floor_worn_001_diff.jpg"))
			hf.set_shader_parameter("arm_tex", load(PHOTO_DIR + "concrete_floor_worn_001_arm.jpg"))
			hf.set_shader_parameter("normal_tex", load(PHOTO_DIR + "concrete_floor_worn_001_nor.png"))
			hf.set_shader_parameter("noise_tex", noise())
			hf.set_shader_parameter("tint", Color(0.6, 0.62, 0.62))
			hf.set_shader_parameter("tile_m", 2.0)
			hf.set_shader_parameter("joint_spacing", 0.6)
			hf.set_shader_parameter("wetness", 0.0)
			hf.set_shader_parameter("room_bounds", Vector4(0.0, -10.0, 24.0, -4.5))
			return hf
		"water_still":
			# Standing water: near-black, glossy, a little green from the silt.
			return _flat(Color(0.035, 0.045, 0.04), 0.04, 0.0)
		"copper":
			return _flat(Color(0.72, 0.42, 0.25), 0.35, 0.9)
		"graphite":
			return _flat(Color(0.12, 0.13, 0.14), 0.55, 0.4)
		"pipe_water":
			return _flat(Color(0.2, 0.32, 0.25), 0.55, 0.25)
		"pipe_drain":
			return _flat(Color(0.13, 0.135, 0.14), 0.6, 0.3)
		"pipe_fire":
			return _flat(Color(0.36, 0.09, 0.06), 0.55, 0.2)
		"pipe_air":
			return _flat(Color(0.33, 0.43, 0.5), 0.5, 0.3)
		"conduit":
			return _flat(Color(0.45, 0.4, 0.27), 0.6, 0.3)
		"cable":
			return _flat(Color(0.07, 0.075, 0.08), 0.7)
		"glass_dark":
			return _flat(Color(0.03, 0.035, 0.04), 0.08, 0.0)
		"window_moon":
			# Night sky seen through grimy wired glass: faint cold glow, brighter at the top, dirt streaks.
			var wg := ShaderMaterial.new()
			wg.shader = preload("res://assets/shaders/window_glass.gdshader")
			wg.set_shader_parameter("noise_tex", noise())
			return wg
		"lamp_fluor":
			return _emissive(Color(0.85, 0.9, 0.94), 2.6, Color(0.7, 0.72, 0.74))
		"lamp_sodium":
			return _emissive(Color(1.0, 0.68, 0.36), 3.0, Color(0.5, 0.35, 0.2))
		"lamp_bulkhead":
			return _emissive(Color(1.0, 0.82, 0.58), 2.2, Color(0.5, 0.42, 0.3))
		"aster_violet":
			return _emissive(Color(0.79, 0.76, 1.0), 2.2, Color(0.2, 0.19, 0.26))
		"exit_green":
			return _emissive(Color(0.35, 0.78, 0.48), 1.8, Color(0.05, 0.12, 0.07))
	push_warning("FacilityMaterials: unknown material %s" % key)
	return _flat(Color.MAGENTA, 1.0)
