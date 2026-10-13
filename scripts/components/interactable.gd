extends Node3D

const B = preload("res://scripts/components/build_util.gd")

signal interacted(actor: Node3D)

@export var display_name: String = ""
@export var prompt_text: String = "Interactuar"
@export var enabled: bool = true
@export var interaction_range: float = 2.4
@export var save_id: String = ""

var _overlay: StandardMaterial3D = null
var _scan_label: Label3D = null

func _ready() -> void:
	add_to_group("interactables")

func make_solid(size: Vector3, offset: Vector3 = Vector3.ZERO) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = Vector3(offset.x, size.y * 0.5 + offset.y, offset.z)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)

func interact(actor: Node3D) -> void:
	if not enabled:
		return
	_on_interact(actor)
	interacted.emit(actor)

func _on_interact(_actor: Node3D) -> void:
	pass

func get_prompt() -> String:
	return prompt_text if enabled else ""

func get_prompt_line() -> String:
	var prompt := get_prompt()
	if prompt.is_empty():
		return ""
	if display_name.is_empty():
		return "[E] " + prompt
	return "[E] %s - %s" % [prompt, display_name]

func get_state() -> Dictionary:
	return {}

func apply_state(_state: Dictionary) -> void:
	pass

func show_message(text: String, duration: float = 8.0) -> void:
	var panel := get_tree().get_first_node_in_group("narrative_panel")
	if panel != null:
		panel.call("show_message", text, duration)

func set_scanned(on: bool) -> void:
	if _overlay == null:
		_overlay = StandardMaterial3D.new()
		_overlay.albedo_color = Color(0.0, 1.0, 1.0, 0.28)
		_overlay.emission_enabled = true
		_overlay.emission = Color(0.0, 1.0, 1.0)
		_overlay.emission_energy_multiplier = 0.6
		_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var meshes: Array = []
	_collect_meshes(self, meshes)
	for m in meshes:
		m.material_overlay = _overlay if on else null
	if on and _scan_label == null:
		_scan_label = B.label3d(self, "[ESCANEADO]", Vector3(0.0, 2.4, 0.0), 40, Color(0.2, 1.0, 1.0))
	if _scan_label != null:
		_scan_label.visible = on

func _collect_meshes(node: Node, out: Array) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			out.append(c)
		_collect_meshes(c, out)
