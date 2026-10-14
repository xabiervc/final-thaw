extends Node
## Comprobaciones del prototipo de movimiento y persecucion (hito A).
## Ejecutar: godot --headless --path . res://tests/test_motion_chase_prototype.tscn

const ProtoScene = preload("res://scenes/prototypes/motion_chase_prototype.tscn")

var failed := 0
var passed := 0


func _ready() -> void:
	var proto = ProtoScene.instantiate()
	add_child(proto)
	_expect(proto.player != null, "el prototipo crea a Elena")
	_expect(proto.enemy != null, "el prototipo crea la unidad de recuperacion")
	_expect(proto.player_camera != null, "el prototipo crea una camara en tercera persona")
	_expect(proto.climb_points.size() == 1, "hay un punto de trepa definido")
	_expect(proto.scan_markers.size() == 4, "el escaner tiene una ruta revelable")
	_expect(proto.enemy_state == "patrol", "la unidad empieza patrullando")
	_expect(InputMap.has_action("crouch"), "la accion de agacharse existe")
	var shape: CollisionShape3D = null
	for child in proto.player.get_children():
		if child is CollisionShape3D:
			shape = child
	_expect(shape != null and shape.shape is CapsuleShape3D, "Elena tiene una capsula de colision")
	var markers_visible := false
	for marker in proto.scan_markers:
		if marker.visible:
			markers_visible = true
	_expect(not markers_visible, "los marcadores del escaner empiezan ocultos")
	proto.queue_free()
	print("Motion chase prototype: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
