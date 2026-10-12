extends "res://scripts/components/interactable.gd"

@export var index: int = 1

var connected: bool = false
var _orb: MeshInstance3D = null
var _ring: MeshInstance3D = null
var _label: Label3D = null

func _ready() -> void:
	super()
	if prompt_text == "Interactuar":
		prompt_text = "Conectar"
	B.box(self, Vector3(0.7, 0.5, 0.7), Vector3(0.0, 0.25, 0.0), Color(0.14, 0.16, 0.2))
	var sphere := SphereMesh.new()
	sphere.radius = 0.28
	sphere.height = 0.56
	_orb = MeshInstance3D.new()
	_orb.mesh = sphere
	_orb.material_override = B.mat(Color(0.95, 0.7, 0.25), 0.4, 2.0)
	_orb.position = Vector3(0.0, 0.85, 0.0)
	add_child(_orb)
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.5
	ring_mesh.bottom_radius = 0.5
	ring_mesh.height = 0.05
	_ring = MeshInstance3D.new()
	_ring.mesh = ring_mesh
	_ring.material_override = B.mat(Color(0.2, 0.9, 0.5), 0.4, 2.0)
	_ring.position = Vector3(0.0, 0.55, 0.0)
	add_child(_ring)
	_label = B.label3d(self, "", Vector3(0.0, 1.7, 0.0), 34, Color.WHITE)
	_refresh()

func set_connected(value: bool) -> void:
	connected = value
	_refresh()

func flash_error() -> void:
	B.set_glow(_orb, Color(1.0, 0.15, 0.15), 3.0)
	_label.text = "NODO %d [ERROR]" % index
	get_tree().create_timer(0.5).timeout.connect(_refresh)

func _refresh() -> void:
	if connected:
		B.set_glow(_orb, Color(0.2, 0.9, 0.5), 2.5)
		_label.text = "NODO %d [CONECTADO]" % index
	else:
		B.set_glow(_orb, Color(0.95, 0.7, 0.25), 1.0)
		_label.text = "NODO %d [SIN ENERGÍA]" % index
	_ring.visible = connected

func get_state() -> Dictionary:
	return {"connected": connected}

func apply_state(state: Dictionary) -> void:
	set_connected(bool(state.get("connected", false)))
