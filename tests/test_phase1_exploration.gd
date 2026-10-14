extends Node
## Smoke and surface checks only, not a walk-through or camera validation.
const Scene = preload("res://scenes/prototypes/phase1_exploration_greybox.tscn")
var failed: int = 0
var passed: int = 0
var completed: bool = false

func _ready() -> void:
	get_tree().create_timer(20.0).timeout.connect(func():
		if not completed:
			push_error("Exploration tests did not complete")
			get_tree().quit(1))
	call_deferred("_run")

func _run() -> void:
	print("Godot: ",Engine.get_version_info()["string"])
	var scene = Scene.instantiate()
	add_child(scene)
	scene.set_physics_process(false)
	scene.player.set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(scene.EXTRA_ROOMS.size()+scene.Layout.ROOMS.size()==10,"Ten space identities")
	_expect(scene.interactions!=null and scene.interactions.hotspots.size()==9,"Baseline circuit interactions preserved")
	_expect(scene.has_node("GalleryWindow") and scene.has_node("HallObservationWindow"),"Observation apertures built")
	var probes: Array = [
		Vector3(-20,0,1),Vector3(-3,0,1),Vector3(20,1.5,18),
		Vector3(20,-2,18),Vector3(30,-2,20.5),Vector3(46,-2,20),
		Vector3(23,0.75,11),Vector3(43,-0.25,11)]
	for point: Vector3 in probes:
		var query := PhysicsRayQueryParameters3D.create(point+Vector3(0,0.5,0),point-Vector3(0,0.5,0),1)
		query.exclude = [scene.player.get_rid()]
		var hit: Dictionary = scene.get_world_3d().direct_space_state.intersect_ray(query)
		_expect(not hit.is_empty() and absf(float(hit.get("position",Vector3(0,999,0)).y)-point.y)<0.05,"Expected surface at %s" % point)
	_expect(not scene.unlock_allowed(Vector3(2,2.5,-9)),"Shortcut cannot unlock from lower approach")
	_expect(scene.unlock_allowed(Vector3(2,3.2,-11)),"Shortcut still unlockable from cabin")
	completed = true
	print("Phase 1 exploration: %d passed, %d failed; COMPLETED" % [passed,failed])
	get_tree().quit(1 if failed>0 else 0)

func _expect(ok: bool, label: String) -> void:
	if ok:
		passed += 1
		print("PASS: ",label)
	else:
		failed += 1
		push_error("FAIL: "+label)
