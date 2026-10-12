extends Node3D

const B = preload("res://scripts/components/build_util.gd")

signal damaged(hazard: Node3D)

@export var save_id: String = ""
@export var zone_size: Vector2 = Vector2(3.0, 3.0)
@export var fake: bool = false
@export var phase_offset: float = 0.0
@export var off_seconds: float = 3.0
@export var warn_seconds: float = 1.0
@export var on_seconds: float = 2.0

var already_hit: bool = false
var state: int = 0
var _plate: MeshInstance3D = null
var _column: MeshInstance3D = null
var _light: OmniLight3D = null
var _label: Label3D = null

func _ready() -> void:
	add_to_group("saveables")
	var base_color := Color(0.35, 0.2, 0.05)
	if fake:
		base_color = Color(0.2, 0.3, 0.4)
	_plate = B.box(self, Vector3(zone_size.x, 0.06, zone_size.y), Vector3(0.0, 0.03, 0.0), base_color, 0.6)
	if not fake:
		var n := maxi(2, int(zone_size.x / 0.9))
		var step := zone_size.x / float(n)
		for i in n:
			if i % 2 == 0:
				B.box(self, Vector3(step * 0.5, 0.07, zone_size.y * 0.96), Vector3(-zone_size.x * 0.5 + step * (float(i) + 0.5), 0.035, 0.0), Color(0.95, 0.75, 0.1), 0.8)
		_column = B.box(self, Vector3(zone_size.x, 2.2, zone_size.y), Vector3(0.0, 1.1, 0.0), Color(1.0, 0.2, 0.1, 0.25))
		var cm := _column.material_override as StandardMaterial3D
		cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_column.visible = false
		_light = OmniLight3D.new()
		_light.light_color = Color(1.0, 0.3, 0.15)
		_light.light_energy = 0.0
		_light.omni_range = 5.0
		_light.position = Vector3(0.0, 1.5, 0.0)
		add_child(_light)
		_label = B.label3d(self, "PELIGRO", Vector3(0.0, 2.8, 0.0), 44, Color(1.0, 0.6, 0.2))
	_refresh()

func _process(_delta: float) -> void:
	if fake:
		return
	var period := off_seconds + warn_seconds + on_seconds
	var t := fposmod(float(Time.get_ticks_msec()) / 1000.0 + phase_offset, period)
	var s := 0
	if t >= off_seconds + warn_seconds:
		s = 2
	elif t >= off_seconds:
		s = 1
	if s != state:
		state = s
		_refresh()
	if state == 1:
		var blink_on := int(t * 6.0) % 2 == 0
		B.set_glow(_plate, Color(1.0, 0.55, 0.1), 4.0 if blink_on else 0.8)
	elif state == 2 and not already_hit:
		var p := get_tree().get_first_node_in_group("player") as Node3D
		if p != null:
			var d := p.global_position - global_position
			if absf(d.x) <= zone_size.x * 0.5 and absf(d.z) <= zone_size.y * 0.5:
				already_hit = true
				damaged.emit(self)

func _refresh() -> void:
	if fake:
		B.set_glow(_plate, Color(0.2, 0.3, 0.4), 0.6)
		return
	match state:
		0:
			B.set_glow(_plate, Color(0.9, 0.55, 0.1), 0.6)
			_label.text = "PELIGRO"
			_column.visible = false
			_light.light_energy = 0.0
		1:
			_label.text = "¡ATENCIÓN!"
			_column.visible = false
			_light.light_energy = 0.0
		2:
			B.set_glow(_plate, Color(1.0, 0.15, 0.1), 3.0)
			_label.text = "¡ACTIVO!"
			_column.visible = true
			_light.light_energy = 1.2

func reset_hit() -> void:
	already_hit = false

func get_state() -> Dictionary:
	return {"hit": already_hit}

func apply_state(state_data: Dictionary) -> void:
	already_hit = bool(state_data.get("hit", false))
