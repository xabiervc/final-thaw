extends Node
## Comprobaciones del prototipo de movimiento, infiltracion y persecucion (hitos A y B, v2).
## Incluye regresiones de los fallos de la v1: hueco imposible, trepa inoperante, cono de vision hacia atras.
## Ejecutar: godot --headless --path . res://tests/test_motion_chase_prototype.tscn

const Proto = preload("res://scripts/prototypes/motion_chase_prototype.gd")
const ProtoScene = preload("res://scenes/prototypes/motion_chase_prototype.tscn")
const JUMP_MARGIN := 0.3

var failed := 0
var passed := 0


func _ready() -> void:
	_test_geometry_constants()
	var proto = ProtoScene.instantiate()
	add_child(proto)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_test_structure(proto)
	_test_detection(proto)
	await _test_awareness_and_memory(proto)
	await _test_climb(proto)
	await _test_occluder_fade(proto)
	_test_scan(proto)
	proto.queue_free()
	print("Motion chase prototype v2: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _test_geometry_constants() -> void:
	var air_time: float = 2.0 * Proto.JUMP_VELOCITY / Proto.GRAVITY
	var walk_range: float = Proto.WALK_SPEED * air_time
	var run_range: float = Proto.RUN_SPEED * air_time
	var segments: Array = Proto.FLOOR_SEGMENTS
	_expect(segments.size() == 4, "el nivel tiene cuatro tramos de suelo y tres huecos")
	var gap_one: float = float(segments[1][0]) - float(segments[0][1])
	var gap_two: float = float(segments[2][0]) - float(segments[1][1])
	var gap_three: float = float(segments[3][0]) - float(segments[2][1])
	_expect(gap_one <= walk_range - JUMP_MARGIN, "el primer hueco (%.1f m) se salta caminando (alcance %.2f m)" % [gap_one, walk_range])
	_expect(gap_two > walk_range and gap_two <= run_range - JUMP_MARGIN, "el segundo hueco (%.1f m) exige correr (alcance %.2f m)" % [gap_two, run_range])
	_expect(gap_three <= walk_range - JUMP_MARGIN, "el tercer hueco (%.1f m) se salta caminando" % gap_three)
	_expect(Proto.CEILING_BOTTOM > Proto.CROUCH_HEIGHT and Proto.CEILING_BOTTOM < Proto.STAND_HEIGHT, "el techo bajo deja pasar agachada pero no de pie")
	_expect(Proto.ENEMY_HEIGHT > Proto.CEILING_BOTTOM, "la unidad no cabe bajo el techo bajo")
	var tunnel: Array = Proto.TUNNEL_X
	var overlaps := false
	for i in segments.size() - 1:
		var gap_start: float = float(segments[i][1])
		var gap_end: float = float(segments[i + 1][0])
		if float(tunnel[0]) < gap_end and float(tunnel[1]) > gap_start:
			overlaps = true
	_expect(not overlaps, "el techo bajo no cubre ningun hueco (en la v1 lo hacia y el salto era imposible)")
	_expect(Proto.CLIMB_HEIGHT > 0.9, "la trepa supera lo que se puede saltar")


func _test_structure(proto) -> void:
	_expect(proto.player != null and proto.enemy != null and proto.player_camera != null, "el prototipo crea a Elena, la unidad y la camara")
	_expect(proto.enemy_state == "patrol", "la unidad empieza patrullando")
	_expect(InputMap.has_action("crouch") and InputMap.has_action("run"), "existen las acciones de agacharse y correr")
	_expect(proto.climb_area != null and proto.climb_area.collision_mask == 2, "la zona de trepa detecta la capa del jugador")
	_expect(proto.uses_model or not ResourceLoader.exists(Proto.MODEL_PATH), "usa el modelo de Elena si esta disponible, y primitivas si no")
	var hidden := true
	for marker in proto.scan_markers:
		if marker.visible:
			hidden = false
	_expect(hidden, "los marcadores del escaner empiezan ocultos")


func _test_detection(proto) -> void:
	proto.set_physics_process(false)
	proto.enemy.global_position = Vector3(46.0, 0.0, 0.0)
	proto.enemy_visual.rotation.y = 0.0
	_expect(proto.enemy_cone_contains(Vector3(46.0, 0.0, 5.0)), "el cono de vision cubre lo que tiene delante (+Z)")
	_expect(not proto.enemy_cone_contains(Vector3(46.0, 0.0, -5.0)), "el cono de vision no cubre lo que tiene detras")
	_expect(not proto.enemy_cone_contains(Vector3(51.0, 0.0, 0.0)), "el cono de vision no cubre su costado")
	proto.player.global_position = Vector3(46.0, 0.1, 7.0)
	proto.crouching = false
	_expect(proto.can_enemy_see_player(), "ve a Elena de pie a 7 m dentro del cono")
	proto.crouching = true
	_expect(not proto.can_enemy_see_player(), "agachada a 7 m queda fuera de su alcance de vision")
	proto.crouching = false
	proto.enemy_visual.rotation.y = PI
	proto.player.global_position = Vector3(46.0, 0.1, -5.5)
	_expect(proto.enemy_cone_contains(proto.player.global_position), "el conducto queda dentro del cono cuando la unidad mira hacia el")
	_expect(not proto.can_enemy_see_player(), "aun asi no la ve a traves de la pared del conducto")
	proto.enemy_visual.rotation.y = 0.0


func _test_awareness_and_memory(proto) -> void:
	proto.set_physics_process(false)
	proto.crouching = false
	proto.enemy.global_position = Vector3(46.0, 0.0, 0.0)
	proto.enemy_visual.rotation.y = 0.0
	proto.enemy_state = "patrol"
	proto.awareness = 0.0
	proto.patrol_wait_left = 5.0
	var seen_at := Vector3(46.0, 0.1, 5.0)
	proto.player.global_position = seen_at
	var saw_alert := false
	for i in 80:
		proto.step_enemy(0.05)
		if proto.enemy_state == "alert":
			saw_alert = true
		if proto.enemy_state == "chase":
			break
	_expect(saw_alert, "la deteccion pasa por una alerta antes de la persecucion")
	_expect(proto.enemy_state == "chase", "tras la alerta la unidad persigue")
	proto.player.global_position = Vector3(46.0, 0.1, -5.5)
	proto.crouching = true
	var reached_search := false
	for i in 400:
		proto.step_enemy(0.05)
		if i == 0:
			_expect(proto.last_known.distance_to(seen_at) < 0.6, "tras perderla persigue la ultima posicion vista, no la real")
		if proto.enemy_state == "search":
			reached_search = true
			break
	_expect(reached_search, "al llegar a la ultima posicion empieza a buscar")
	var back_to_patrol := false
	for i in 900:
		proto.step_enemy(0.05)
		if proto.enemy_state == "patrol":
			back_to_patrol = true
			break
	_expect(back_to_patrol, "tras buscar vuelve a patrullar")
	proto.crouching = false


func _test_climb(proto) -> void:
	proto.set_physics_process(true)
	proto.enemy.global_position = Vector3(58.0, 0.0, -1.0)
	proto.enemy_state = "patrol"
	proto.player.global_position = Vector3(42.2, 0.1, 5.3)
	proto.player.velocity = Vector3.ZERO
	for i in 6:
		await get_tree().physics_frame
	_expect(proto.player_in_climb, "estar junto al borde activa la zona de trepa")
	_expect(proto.try_climb(), "se puede iniciar la trepa")
	for i in 80:
		await get_tree().physics_frame
	var position: Vector3 = proto.player.global_position
	_expect(position.y > Proto.CLIMB_HEIGHT - 0.3 and position.x > 43.0, "tras trepar Elena esta sobre la pasarela (%.2f, %.2f)" % [position.x, position.y])
	proto.set_physics_process(false)


func _test_occluder_fade(proto) -> void:
	proto.set_physics_process(false)
	proto.crouching = true
	proto.player.global_position = Vector3(22.5, 0.1, 0.0)
	await get_tree().physics_frame
	proto.cam_yaw = 0.0
	proto._update_camera(100.0)
	for i in 6:
		proto._update_occluders(0.1)
	var entry: Dictionary = proto.fade_bodies[proto.tunnel_ceiling]
	_expect(float(entry["alpha"]) < 0.5, "el techo que tapa a Elena se vuelve casi transparente (alpha %.2f)" % float(entry["alpha"]))
	proto.crouching = false
	proto.player.global_position = Vector3(10.0, 0.1, 0.0)
	await get_tree().physics_frame
	proto._update_camera(100.0)
	for i in 12:
		proto._update_occluders(0.1)
	entry = proto.fade_bodies[proto.tunnel_ceiling]
	_expect(float(entry["alpha"]) > 0.95, "cuando deja de taparla vuelve a ser opaco (alpha %.2f)" % float(entry["alpha"]))


func _test_scan(proto) -> void:
	proto.trigger_scan_reveal()
	var shown := true
	for marker in proto.scan_markers:
		if not marker.visible:
			shown = false
	_expect(shown, "el escaner revela la unidad, su cono, su ruta y las rutas alternativas")
	_expect(is_equal_approx(proto.scan_cooldown_left, Proto.SCAN_COOLDOWN), "el escaner entra en recarga")
	proto._update_scan(Proto.SCAN_REVEAL_TIME + 0.1)
	var hidden := true
	for marker in proto.scan_markers:
		if marker.visible:
			hidden = false
	_expect(hidden, "el escaner vuelve a ocultar la informacion")


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
