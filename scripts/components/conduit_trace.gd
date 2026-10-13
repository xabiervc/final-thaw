extends Node3D
## Traza de cableado: elemento visual que se ilumina al escanear.
## No es un interactuable: no tiene aviso ni estado de interaccion, y el gestor de
## interaccion nunca lo selecciona (solo recorre el grupo "interactables").
## Vive en el grupo "scannables" y el escaner llama a set_scanned(active).
##
## El escaner mide la distancia desde el ORIGEN de este nodo, no desde su geometria:
## colocalo a menos de scan_radius del sitio donde el jugador va a escanear.
## La ruta es plana: se usan x y z de cada punto (coordenadas locales).

const B = preload("res://scripts/components/build_util.gd")

signal scanned(trace_id: String)

@export var trace_id: String = ""
@export var label_text: String = ""
@export var route: PackedVector3Array = PackedVector3Array()
@export var base_color: Color = Color(0.16, 0.2, 0.22)
@export var glow_color: Color = Color(0.2, 1.0, 0.9)
@export var glow_energy: float = 3.0

var _segments: Array[MeshInstance3D] = []
var _label: Label3D = null
var _is_scanned: bool = false


func _ready() -> void:
	add_to_group("scannables")
	_build_segments()
	if label_text != "" and route.size() > 0:
		_label = B.label3d(self, label_text, route[route.size() - 1] + Vector3(0.0, 0.6, 0.0), 36, glow_color)
		_label.visible = false


func set_scanned(active: bool) -> void:
	_is_scanned = active
	for mi in _segments:
		if active:
			B.set_glow(mi, glow_color, glow_energy)
		else:
			B.set_glow(mi, base_color, 0.0)
	if _label != null:
		_label.visible = active
	if active:
		scanned.emit(trace_id)


func is_scanned() -> bool:
	return _is_scanned


func get_scan_label() -> String:
	return label_text


func segment_count() -> int:
	return _segments.size()


func _build_segments() -> void:
	for i in range(route.size() - 1):
		var a: Vector3 = route[i]
		var b: Vector3 = route[i + 1]
		var delta := b - a
		var length := Vector2(delta.x, delta.z).length()
		if length < 0.01:
			continue
		var mi := B.box(self, Vector3(length, 0.05, 0.12), (a + b) * 0.5 + Vector3(0.0, 0.03, 0.0), base_color)
		mi.rotation.y = atan2(-delta.z, delta.x)
		_segments.append(mi)
