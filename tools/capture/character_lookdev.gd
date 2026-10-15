extends Node3D
## Character look-development stage (QA tool, not shipped gameplay): Elena exactly as the game builds her (same controller,
## materials and animation player) on a neutral floor, under one of three lighting setups chosen by `lighting`:
##   "neutral"     grey studio: soft key, fill and rim, neutral ambient (judges albedo, roughness and form)
##   "directional" one hard sun at 45 degrees plus low ambient (judges silhouette, normal maps and self-shadowing)
##   "gameplay"    the Phase 1 environment and ambient values with a cool overhead practical (what the player sees)
## Used by tools/capture/shots/elena_lookdev.json through scene_capture.gd (`player` is the shot list's Elena).

const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")

@export var lighting: String = "neutral"
var player: CharacterBody3D


func _ready() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var ink := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2.0, 2.0)
	ink.mesh = quad
	var ink_mat := ShaderMaterial.new()
	ink_mat.shader = preload("res://assets/shaders/ink_outline.gdshader")
	ink.material_override = ink_mat
	ink.extra_cull_margin = 16384.0
	add_child(ink)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12.0, 12.0)
	floor_mesh.mesh = plane
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.32, 0.32, 0.31)
	floor_mat.roughness = 0.85
	floor_mesh.material_override = floor_mat
	add_child(floor_mesh)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(12.0, 0.2, 12.0)
	shape.shape = box
	shape.position.y = -0.1
	body.add_child(shape)
	add_child(body)
	match lighting:
		"directional":
			env.background_color = Color(0.16, 0.17, 0.18)
			env.ambient_light_color = Color(0.5, 0.52, 0.55)
			env.ambient_light_energy = 0.25
			var sun := DirectionalLight3D.new()
			sun.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
			sun.light_energy = 1.6
			sun.shadow_enabled = true
			add_child(sun)
		"gameplay":
			env.background_color = Color(0.03, 0.04, 0.06)
			env.ambient_light_color = Color(0.36, 0.43, 0.52)
			env.ambient_light_energy = 0.52
			var practical := OmniLight3D.new()
			practical.position = Vector3(1.2, 3.2, 1.0)
			practical.light_color = Color(0.72, 0.84, 0.95)
			practical.light_energy = 0.9
			practical.omni_range = 10.0
			practical.shadow_enabled = true
			add_child(practical)
		_:
			env.background_color = Color(0.36, 0.37, 0.38)
			env.ambient_light_color = Color(0.6, 0.6, 0.6)
			env.ambient_light_energy = 0.35
			for spec in [[Vector3(-35.0, -35.0, 0.0), 1.25, true], [Vector3(-15.0, 120.0, 0.0), 0.45, false], [Vector3(-25.0, 200.0, 0.0), 0.8, false]]:
				var l := DirectionalLight3D.new()
				l.rotation_degrees = spec[0]
				l.light_energy = spec[1]
				l.shadow_enabled = spec[2]
				add_child(l)
	player = Player.new()
	player.name = "Elena"
	add_child(player)
	player.set("input_enabled", false)
