extends Node3D

var _orb: MeshInstance3D = null
var _light: OmniLight3D = null
var _t: float = 0.0

func _ready() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.36
	sphere.height = 0.72
	_orb = MeshInstance3D.new()
	_orb.mesh = sphere
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.29, 0.56, 0.89, 0.22)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.emission_enabled = true
	m.emission = Color(0.29, 0.56, 0.89)
	m.emission_energy_multiplier = 1.5
	_orb.material_override = m
	_orb.position = Vector3(0.0, 1.1, 0.0)
	add_child(_orb)
	_light = OmniLight3D.new()
	_light.light_color = Color(0.29, 0.56, 0.89)
	_light.light_energy = 0.8
	_light.omni_range = 4.0
	_light.position = Vector3(0.0, 1.2, 0.0)
	add_child(_light)
	visible = false

func _process(delta: float) -> void:
	visible = GameManager.has_prototype
	if not visible:
		return
	_t += delta
	var s := 1.0 + 0.08 * sin(_t * TAU)
	_orb.scale = Vector3(s, s, s)
