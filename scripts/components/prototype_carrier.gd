extends Node3D

const PROTOTYPE_LOAD := 0.4

var _orb: MeshInstance3D = null
var _light: OmniLight3D = null
var _t: float = 0.0
var _load_applied: bool = false

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
	_sync_load(visible)
	if not visible:
		return
	_t += delta
	var s := 1.0 + 0.08 * sin(_t * TAU)
	_orb.scale = Vector3(s, s, s)

func _sync_load(carrying: bool) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var c = parent.get("condition")
	if c == null:
		return
	if carrying:
		c.load_factor = PROTOTYPE_LOAD
		_load_applied = true
	elif _load_applied:
		c.load_factor = 0.0
		_load_applied = false
