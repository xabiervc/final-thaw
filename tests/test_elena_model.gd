extends Node
## Integracion del modelo MPFB en el controlador de Elena.
## Comprueba el modelo si se puede importar y, si no, que el controlador cae al cuerpo de
## primitivas sin fallar. Las medidas se toman antes del primer fotograma para no incluir el
## escalado de respiracion de _process.
## Ejecutar: godot --headless --path . res://tests/test_elena_model.tscn
## (hace falta haber importado el proyecto al menos una vez para que el .glb sea cargable)
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const ElenaScript = preload("res://scripts/characters/elena_controller.gd")

const EXPECTED_MESHES := 21  # 16 body/outfit pieces + 4 eyelash lines + the hair cards
const TRIANGLE_BUDGET := 30000
const ELENA_HEIGHT := 1.7
const HEIGHT_TOLERANCE := 0.06

var failed := 0
var passed := 0


func _ready() -> void:
	_test_primitive_fallback_when_disabled()
	_test_model_or_graceful_fallback()
	print("Elena model: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _loadable() -> bool:
	return ResourceLoader.exists(ElenaScript.MPFB_MODEL_PATH) and load(ElenaScript.MPFB_MODEL_PATH) is PackedScene


func _test_primitive_fallback_when_disabled() -> void:
	var elena = ElenaScript.new()
	elena.use_mpfb_model = false
	add_child(elena)
	_expect(not elena.uses_mpfb_model, "use_mpfb_model = false keeps the primitive body")
	_expect(elena.visual != null and elena.visual.get_child_count() >= 8, "the primitive body is built (legs, torso, head, hair, pack, Aster, glow)")
	_expect(elena.visual.find_child("ElenaModel", true, false) == null, "no MPFB model is instanced when disabled")
	elena.queue_free()


func _test_model_or_graceful_fallback() -> void:
	var elena = ElenaScript.new()
	add_child(elena)
	_expect(elena.visual != null and elena.visual.get_child_count() > 0, "Elena always has a visual, with or without the model")
	var shape: CollisionShape3D = null
	for child in elena.get_children():
		if child is CollisionShape3D:
			shape = child
	_expect(shape != null and shape.shape is CapsuleShape3D and is_equal_approx((shape.shape as CapsuleShape3D).radius, 0.32) and is_equal_approx((shape.shape as CapsuleShape3D).height, 1.7), "the collision capsule is unchanged (0.32 m x 1.7 m)")
	if not _loadable():
		_expect(not elena.uses_mpfb_model, "without an importable GLB the controller falls back to primitives")
		print("NOTE: ref_elena_mpfb.glb is not importable here (run godot --headless --path . --import first); model checks skipped")
		elena.queue_free()
		return
	_expect(elena.uses_mpfb_model, "the MPFB model is used when it can be loaded")
	var model: Node = elena.visual.find_child("ElenaModel", true, false)
	_expect(model != null, "the model is instanced under the visual node")
	if model == null:
		elena.queue_free()
		return
	var meshes: Array = model.find_children("*", "MeshInstance3D", true, false)
	_expect(meshes.size() == EXPECTED_MESHES, "the model has %d mesh instances (found %d)" % [EXPECTED_MESHES, meshes.size()])
	_expect(model.find_children("*", "Skeleton3D", true, false).size() == 1, "the model has one skeleton")
	var triangles := 0
	var every_surface_has_material := true
	for mesh_instance in meshes:
		triangles += int(mesh_instance.mesh.get_faces().size() / 3)
		for surface in mesh_instance.mesh.get_surface_count():
			if mesh_instance.get_active_material(surface) == null:
				every_surface_has_material = false
	_expect(triangles <= TRIANGLE_BUDGET and triangles > 0, "the model stays within the triangle budget (%d of %d)" % [triangles, TRIANGLE_BUDGET])
	_expect(every_surface_has_material, "every surface has a material (imported or from the .tres)")
	var box := _local_aabb(elena, meshes)
	_expect(absf(box.size.y - ELENA_HEIGHT) <= HEIGHT_TOLERANCE, "the model is about 1.70 m tall (%.3f m)" % box.size.y)
	_expect(absf(box.position.y) <= 0.05, "the model stands on the floor (min y = %.3f)" % box.position.y)
	var lights: Array = elena.visual.find_children("*", "OmniLight3D", false, false)
	_expect(lights.size() == 1, "the model path adds exactly one Aster light")
	elena.queue_free()


func _local_aabb(root: Node3D, meshes: Array) -> AABB:
	var combined := AABB()
	var first := true
	var inverse := root.global_transform.affine_inverse()
	for mesh_instance in meshes:
		var box: AABB = (inverse * mesh_instance.global_transform) * mesh_instance.get_aabb()
		combined = box if first else combined.merge(box)
		first = false
	return combined


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
