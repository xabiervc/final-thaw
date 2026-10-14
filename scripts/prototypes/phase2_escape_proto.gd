extends Node3D

## Minimal Phase 2 escape prototype.
## Reuses Elena's existing 3D controller and follow camera from Phase 1.
## It builds a small test arena with two routes, cover and a ThreatAgent.
## It does not modify Phase 1 scenes, contracts, save format or input actions.

const B = preload("res://scripts/components/build_util.gd")
const ElenaController = preload("res://scripts/characters/elena_controller.gd")
const FollowCamera = preload("res://scripts/components/follow_camera.gd")
const ThreatAgentScene = preload("res://scenes/entities/threat/threat_agent.tscn")

const ELENA_START := Vector3(-10.0, 0.1, 0.0)
const THREAT_START := Vector3(10.0, 0.1, 0.0)

var elena = null
var threat = null
var camera = null

func _ready() -> void:
	_build_environment()
	_build_arena()
	_build_actors()

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.04, 0.06, 0.08)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.35, 0.42, 0.5)
	environment.ambient_light_energy = 0.6

	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -35.0, 0.0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	add_child(sun)

func _build_arena() -> void:
	B.solid_box(self, Vector3(34.0, 0.5, 22.0), Vector3(0.0, -0.25, 0.0), Color(0.13, 0.16, 0.18))
	B.solid_box(self, Vector3(34.0, 3.0, 0.5), Vector3(0.0, 1.5, -11.0), Color(0.22, 0.26, 0.3))
	B.solid_box(self, Vector3(34.0, 3.0, 0.5), Vector3(0.0, 1.5, 11.0), Color(0.22, 0.26, 0.3))
	B.solid_box(self, Vector3(0.5, 3.0, 22.0), Vector3(-17.0, 1.5, 0.0), Color(0.22, 0.26, 0.3))
	B.solid_box(self, Vector3(0.5, 3.0, 22.0), Vector3(17.0, 1.5, 0.0), Color(0.22, 0.26, 0.3))

	B.solid_box(self, Vector3(0.8, 2.2, 12.0), Vector3(0.0, 1.1, 0.0), Color(0.24, 0.29, 0.34))
	B.solid_box(self, Vector3(6.0, 1.4, 0.8), Vector3(-5.0, 0.7, -5.0), Color(0.24, 0.29, 0.34))
	B.solid_box(self, Vector3(6.0, 1.4, 0.8), Vector3(-5.0, 0.7, 5.0), Color(0.24, 0.29, 0.34))

func _build_actors() -> void:
	elena = ElenaController.new()
	elena.position = ELENA_START
	add_child(elena)

	camera = FollowCamera.new()
	camera.target = elena
	add_child(camera)

	threat = ThreatAgentScene.instantiate()
	threat.position = THREAT_START
	add_child(threat)
	threat.set_target(elena)
	threat.set_patrol_points(PackedVector3Array([
		Vector3(10.0, 0.1, -6.0),
		Vector3(10.0, 0.1, 6.0),
	]))

	threat.target_caught.connect(_on_target_caught)

func _on_target_caught(_target: Node3D) -> void:
	elena.global_position = ELENA_START
	elena.velocity = Vector3.ZERO
	threat.reset()
