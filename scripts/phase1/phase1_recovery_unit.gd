extends CharacterBody3D
## Facility recovery unit for Containment (Phase 2). A hunter bound by its senses and by the building:
##
##  - Senses: a forward cone (55-degree half-angle) with real line of sight; range set by difficulty (9 m standard),
##    shorter if Elena is crouched (x0.55) or standing in darkness (x0.6 .. x1.0 by light exposure); a 1.6 m
##    proximity sense; hearing that depends on how Elena moves (still 1.5 m, crouched 2.5, walking 6, running 10;
##    x difficulty). It only perceives on its own level. Guard rails and mesh fences do not block sight.
##  - Readable states: sweep (protocol search, "·"), suspicious (sweep with rising awareness: slows, turns towards
##    the stimulus, "?" fading in), investigate ("?"), alert ("!", a short pause so Elena can break line of sight),
##    chase ("!!"), search ("?", sweeping its cone). Eye colour follows the state too (never colour alone).
##  - Memory, never omniscience: it chases the LAST position it perceived. When it gets there without contact it
##    checks a few metres along the direction Elena was last seen moving (a trail it could see), then searches,
##    then resumes the protocol sweep from where it is. Telemetry (lift used, R1 released) and noise devices only
##    report a PLACE, which it investigates.
##  - Movement: it walks the route graph (stairs included) and rides the same service lift as Elena; it cannot pass
##    closed doors, rails, fences or gaps, and it never teleports or spawns in front of her.
## Contact catches Elena (the scene restores the last checkpoint).

signal state_changed(state: String)
signal caught_player
signal reacquired  # first switch to chase after the quiet section
signal lost_contact  # chase -> searching (Elena broke contact)

const Graph := preload("res://scripts/phase1/phase1_route_graph.gd")
const Synth := preload("res://scripts/audio/game_synth.gd")
## Modelled unit (tools/blender/build_recovery_unit.py); the primitive build below is the fallback.
const MODEL_PATH := "res://assets/models/characters/recovery_unit.glb"

const URGENT_SWEEP_FACTOR := 1.45
const INVESTIGATE_SPEED := 3.4
## Pace when answering a telemetry order or a noise: urgent, not omniscient.
const RESPOND_SPEED := 4.8
const TURN_RATE := 7.0
const GRAVITY := 22.0
const VISION_HALF_ANGLE := 55.0
const CROUCH_VISION_FACTOR := 0.55
const DARK_VISION_FACTOR := 0.6
const NEAR_SENSE := 1.6
const SAME_LEVEL := 1.6
const AWARENESS_DECAY := 0.5
const SUSPICIOUS_AT := 0.22
const ARRIVE := 0.45
const CATCH_DISTANCE := 1.15
const STUCK_TIME := 1.6
const TRAIL_PROBE := 5.0
const NOISE := {"still": 1.5, "crouch": 2.5, "walk": 6.0, "run": 10.0}

var graph = Graph.new()
var lift = null           # service_lift.gd instance
var player: CharacterBody3D = null
## Optional Callable(Vector3) -> float 0..1: how lit Elena is (1 = in a light pool). Default: always lit.
var exposure: Callable = Callable()
var state: String = "dormant"
var awareness: float = 0.0
var last_known: Vector3 = Vector3.ZERO
var has_reacquired: bool = false
var times_spotted: int = 0
var times_lost: int = 0
## Tuning (GameSettings.DIFFICULTY), refreshed on activate/reset and whenever options change.
var vision_range_base: float = 9.0
var detect_time: float = 0.8
var alert_time: float = 0.55
var chase_speed: float = 5.3
var search_time: float = 3.5
var hearing: float = 1.0
var sweep_speed_base: float = 3.0
var halted: bool = false

var _path: Array = []          # node names still to visit
var _sweep_index: int = 0
var _alert_left: float = 0.0
var _search_left: float = 0.0
var _search_yaw: float = 0.0
var _stuck_left: float = STUCK_TIME
var _best_progress: float = INF
var _lift_requested: bool = false
var _investigate_speed: float = INVESTIGATE_SPEED
var _sweep_speed: float = 3.0
var _lift_from: String = ""
var _lift_to: String = ""
var _last_heading: Vector3 = Vector3.ZERO
var _trail_checked: bool = false
var _stuck_hit: bool = false
var _replans: int = 0
var _visual: Node3D
var _eye_mat: StandardMaterial3D
var _icon: Label3D
var _lamp: OmniLight3D
var _cone: MeshInstance3D
var _hum: AudioStreamPlayer3D
var _sting: AudioStreamPlayer3D
var _step_audio: AudioStreamPlayer3D
var _step_left: float = 0.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 16
	floor_snap_length = 0.4
	floor_max_angle = deg_to_rad(46.0)
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.42
	cap.height = 1.95
	shape.shape = cap
	shape.position.y = 0.975
	add_child(shape)
	_build_visual()
	_build_audio()
	apply_tuning()
	GameManager.stats_changed.connect(apply_tuning)
	_set_state("dormant")


## Reads the current difficulty. Called on activation, reset and whenever the options change (pause menu).
func apply_tuning() -> void:
	vision_range_base = GameSettings.tuning("vision_range")
	detect_time = GameSettings.tuning("detect_time")
	alert_time = GameSettings.tuning("alert_time")
	chase_speed = GameSettings.tuning("chase_speed")
	search_time = GameSettings.tuning("search_time")
	hearing = GameSettings.tuning("hearing")
	var urgent := _sweep_speed > sweep_speed_base + 0.01
	sweep_speed_base = GameSettings.tuning("sweep_speed")
	_sweep_speed = sweep_speed_base * (URGENT_SWEEP_FACTOR if urgent else 1.0)
	if _cone != null:
		(_cone.mesh as CylinderMesh).bottom_radius = vision_range_base * tan(deg_to_rad(VISION_HALF_ANGLE)) * 0.55
		(_cone.mesh as CylinderMesh).height = vision_range_base
		_cone.position.z = vision_range_base * 0.5


## Starts the Containment sweep from the given route-graph node.
func activate(start_node: String) -> void:
	apply_tuning()
	global_position = graph.pos(start_node)
	_sweep_index = maxi(0, Graph.SWEEP.find(start_node))
	_set_state("sweep")
	_plan_sweep()
	if _hum != null:
		_hum.play()


## Places the unit (after a catch) at a node well behind the player's checkpoint and resumes searching.
func reset_to(node: String) -> void:
	global_position = graph.pos(node)
	velocity = Vector3.ZERO
	awareness = 0.0
	halted = false
	_lift_from = ""
	_sweep_speed = sweep_speed_base  # after a catch the hunt restarts at its ordinary pace
	_trail_checked = false
	_sweep_index = maxi(0, Graph.SWEEP.find(node))
	_set_state("sweep")
	_plan_sweep()


## Containment telemetry: the facility reports WHERE a device was used (a lift landing, a manual release), never
## where Elena is. The unit goes there at an urgent pace and searches; it still needs to see her to chase.
func respond(position: Vector3) -> void:
	if state in ["dormant", "chase", "alert"] or halted:
		return
	last_known = position
	_investigate_speed = RESPOND_SPEED
	_sweep_speed = sweep_speed_base * URGENT_SWEEP_FACTOR
	_trail_checked = true
	_set_state("investigate")
	_plan_to(position)


## A noise in the world (a device Elena started). Heard if within `radius` on the same level; it investigates the
## PLACE of the noise unless it is already chasing Elena with her in sight.
func hear_noise(position: Vector3, radius: float) -> bool:
	if state in ["dormant", "alert"] or halted:
		return false
	if state == "chase" and sees_player():
		return false
	if absf(position.y - global_position.y) > SAME_LEVEL:
		return false
	if Vector2(position.x - global_position.x, position.z - global_position.z).length() > radius:
		return false
	last_known = position
	_investigate_speed = RESPOND_SPEED
	_trail_checked = true
	if state == "chase":
		times_lost += 1
		lost_contact.emit()
	_set_state("investigate")
	_plan_to(position)
	return true


## Stops the unit where it is (sector boundary reached / ending): it no longer moves or perceives.
func halt() -> void:
	halted = true
	velocity = Vector3.ZERO
	_path = []
	_set_state("search")
	_search_left = 999.0


# --- perception -----------------------------------------------------------------------------------------------

func _eye() -> Vector3:
	return global_position + Vector3(0.0, 1.7, 0.0)


func _forward() -> Vector3:
	var f := _visual.global_transform.basis.z
	f.y = 0.0
	return f.normalized()


func light_factor() -> float:
	if not exposure.is_valid() or player == null:
		return 1.0
	return lerpf(DARK_VISION_FACTOR, 1.0, clampf(float(exposure.call(player.global_position)), 0.0, 1.0))


func vision_range() -> float:
	return vision_range_base * (CROUCH_VISION_FACTOR if bool(player.get("is_crouching")) else 1.0) * light_factor()


func cone_contains(point: Vector3) -> bool:
	var to := point - global_position
	to.y = 0.0
	if to.length() < 0.001:
		return true
	return rad_to_deg(_forward().angle_to(to.normalized())) <= VISION_HALF_ANGLE


func line_clear(from: Vector3, to: Vector3) -> bool:
	var q := PhysicsRayQueryParameters3D.create(from, to, 1, [get_rid(), player.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func sees_player() -> bool:
	if player == null or halted:
		return false
	var p := player.global_position
	if absf(p.y - global_position.y) > SAME_LEVEL:
		return false
	var flat := Vector2(p.x - global_position.x, p.z - global_position.z).length()
	if flat > NEAR_SENSE and flat > vision_range():
		return false
	if flat > NEAR_SENSE and not cone_contains(p):
		return false
	var chest := 0.6 if bool(player.get("is_crouching")) else 1.1
	return line_clear(_eye(), p + Vector3(0.0, chest, 0.0))


func noise_radius() -> float:
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	var base: float = NOISE["walk"]
	if speed < 0.3:
		base = NOISE["still"]
	elif bool(player.get("is_crouching")):
		base = NOISE["crouch"]
	elif bool(player.get("is_running")):
		base = NOISE["run"]
	return base * hearing


func hears_player() -> bool:
	if halted:
		return false
	var p := player.global_position
	if absf(p.y - global_position.y) > SAME_LEVEL:
		return false
	return Vector2(p.x - global_position.x, p.z - global_position.z).length() < noise_radius()


# --- state machine ------------------------------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if state == "dormant" or player == null:
		return
	if halted:
		_halt(delta)
		_update_visual(delta)
		return
	var sees := sees_player()
	var hears := hears_player()
	match state:
		"sweep":
			_accumulate(delta, sees, hears)
			if state == "sweep":
				if awareness > SUSPICIOUS_AT:
					# Suspicious: slows and turns towards what it half-perceived (readable, gives time to back off).
					_face(last_known, delta)
					if _follow(delta, _sweep_speed * 0.45):
						_sweep_index += 1
						_plan_sweep()
				elif _follow(delta, _sweep_speed):
					_sweep_index += 1
					_plan_sweep()
		"investigate":
			_accumulate(delta, sees, hears)
			if state == "investigate" and _follow(delta, _investigate_speed):
				_begin_search()
		"alert":
			_face(player.global_position, delta)
			_halt(delta)
			if sees:
				_remember(player)
			_alert_left -= delta
			if _alert_left <= 0.0:
				_set_state("chase")
				_trail_checked = false
				if not has_reacquired:
					has_reacquired = true
					reacquired.emit()
				_plan_to(last_known)
		"chase":
			if sees:
				_remember(player)
				_trail_checked = false
				if _direct_clear(last_known):
					_path = []
				elif _path.is_empty():
					_plan_to(last_known)
			if _path.is_empty() and not sees and not _direct_clear(last_known):
				_plan_to(last_known)  # the straight line is blocked (a fallen tray, a corner): go round by the route
			var arrived := false
			if _path.is_empty():
				arrived = _steer(last_known, chase_speed, delta)
				_stuck_hit = false
			else:
				arrived = _follow(delta, chase_speed)
			if arrived and not sees:
				_lose_contact()
		"search":
			_halt(delta)
			_search_left -= delta
			_visual.rotation.y = _search_yaw + sin((search_time - _search_left) * 1.7) * 1.25
			_accumulate(delta, sees, hears)
			if state == "search" and _search_left <= 0.0:
				_resume_sweep()
	_check_catch()
	_update_visual(delta)
	_update_audio(delta)


func _remember(p: CharacterBody3D) -> void:
	last_known = p.global_position
	var v := Vector3(p.velocity.x, 0.0, p.velocity.z)
	if v.length() > 0.8:
		_last_heading = v.normalized()


## Arrived where it last perceived Elena and she is not there: first check along the trail she was seen taking
## (once per loss, only if that line is open), then search on the spot.
func _lose_contact() -> void:
	times_lost += 1
	lost_contact.emit()
	if not _trail_checked and _last_heading != Vector3.ZERO:
		_trail_checked = true
		var probe := last_known + _last_heading * TRAIL_PROBE
		var from := last_known + Vector3(0.0, 1.0, 0.0)
		if line_clear(from, probe + Vector3(0.0, 1.0, 0.0)):
			last_known = probe
			_investigate_speed = chase_speed * 0.8
			_set_state("investigate")
			_plan_to(probe)
			return
	_begin_search()


func _accumulate(delta: float, sees: bool, hears: bool) -> void:
	if sees:
		var flat := Vector2(player.global_position.x - global_position.x, player.global_position.z - global_position.z).length()
		awareness += delta * clampf(1.6 - flat / maxf(vision_range(), 0.1), 0.45, 1.6) / detect_time
		_remember(player)
	elif hears:
		awareness += delta * 0.6 / detect_time
		last_known = player.global_position
	else:
		awareness = maxf(0.0, awareness - AWARENESS_DECAY * delta)
	if awareness >= 1.0:
		if sees:
			awareness = 1.0
			times_spotted += 1
			_alert_left = alert_time
			_set_state("alert")
		elif state != "investigate":
			awareness = 0.6
			_investigate_speed = INVESTIGATE_SPEED
			_trail_checked = true
			_set_state("investigate")
			_plan_to(last_known)


func _begin_search() -> void:
	_search_left = search_time
	_search_yaw = _visual.rotation.y
	awareness = 0.0
	_set_state("search")


func _resume_sweep() -> void:
	# Continue the protocol from the sweep node nearest to where it lost her (never from her real position).
	var near: String = graph.nearest(global_position, _walkable_to)
	var idx: int = Graph.SWEEP.find(near)
	_sweep_index = idx if idx >= 0 else _sweep_index
	_set_state("sweep")
	_plan_sweep()


func _plan_sweep() -> void:
	if _sweep_index >= Graph.SWEEP.size():
		_sweep_index = Graph.SWEEP.find(Graph.SWEEP_LOOP_FROM)  # keep searching the lower levels and the yard
	_path = _route_from_here(Graph.SWEEP[_sweep_index])
	_drop_reached_head()


func _plan_to(target: Vector3) -> void:
	var goal: String = graph.nearest(target, func(q): return absf(q.y - target.y) < 1.3)
	_path = _route_from_here(goal)
	_drop_reached_head()
	_path.append("@target")


## A new plan never abandons a lift ride in progress: the route continues from the landing the deck is heading to.
## Otherwise it starts from the nearest route node it can actually walk to in a straight line (never a node on the
## other side of a wall, e.g. inside a stairwell it is standing beside).
func _route_from_here(goal: String) -> Array:
	if _lift_from != "":
		var rest: Array = graph.path(_lift_to, goal)
		if rest.is_empty():
			rest = [_lift_to]
		return [_lift_from] + rest
	return graph.path(graph.nearest(global_position, _walkable_to), goal)


## True if a body could walk straight from here to `q`: same level and no wall, rail or fence in between.
func _walkable_to(q: Vector3) -> bool:
	if absf(q.y - global_position.y) > 1.3:
		return false
	var a := global_position + Vector3(0.0, 0.6, 0.0)
	var b := Vector3(q.x, maxf(q.y, global_position.y) + 0.6, q.z)
	var ray := PhysicsRayQueryParameters3D.create(a, b, 1 | 16, [get_rid()] + ([player.get_rid()] if player != null else []))
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


## Got stuck on the way to a node: plan again from where it really is, towards the same final goal.
func _replan() -> void:
	_replans += 1
	var had_target: bool = not _path.is_empty() and str(_path[-1]) == "@target"
	var nodes: Array = _path.filter(func(n): return str(n) != "@target")
	if nodes.is_empty() or _replans > 3:
		_replans = 0
		if not _path.is_empty():
			_path.pop_front()  # repeated failure: drop the node and carry on
		return
	_path = _route_from_here(str(nodes[-1]))
	_drop_reached_head()
	if had_target:
		_path.append("@target")


func _drop_reached_head() -> void:
	while _path.size() > 1 and Vector2(graph.pos(_path[0]).x - global_position.x, graph.pos(_path[0]).z - global_position.z).length() < 1.2 and absf(graph.pos(_path[0]).y - global_position.y) < 1.0:
		_path.pop_front()


# --- movement -------------------------------------------------------------------------------------------------------

## Follows the planned node path; returns true when the path is finished.
func _follow(delta: float, speed: float) -> bool:
	if _lift_from != "":
		if _ride_lift(delta):
			_lift_from = ""
			_path.pop_front()  # the landing it came from
			_path.pop_front()  # the landing it reached (already standing there)
		return _path.is_empty()
	if _path.is_empty():
		_halt(delta)
		return true
	var head: String = _path[0]
	if head == "@target":
		if _steer(last_known, speed, delta):
			_path.pop_front()
		_stuck_hit = false
		return _path.is_empty()
	if _path.size() > 1 and graph.edge_kind(head, _path[1]) == "lift" and _near(graph.pos(head)):
		_lift_from = head
		_lift_to = _path[1]
		_lift_requested = false
		return false
	if _steer(graph.pos(head), speed, delta):
		if _stuck_hit:
			_stuck_hit = false
			_replan()
		else:
			_replans = 0
			_path.pop_front()
	return _path.is_empty()


func _near(p: Vector3) -> bool:
	return Vector2(p.x - global_position.x, p.z - global_position.z).length() < ARRIVE + 0.3 and absf(p.y - global_position.y) < 1.0


## Lift sequence: call the deck to this landing, step onto it, send it, ride, then step off at the other landing.
## Returns true once standing at the destination landing node. The lift's own gates keep everyone off the shaft.
func _ride_lift(delta: float) -> bool:
	if lift == null:
		return false
	var from_level: String = "upper" if graph.pos(_lift_from).y > 1.5 else "lower"
	var deck := Vector3(26.0, float(lift.platform_y), -3.0)
	var on_deck := Vector2(deck.x - global_position.x, deck.z - global_position.z).length() < 1.0 and absf(global_position.y - float(lift.platform_y)) < 0.6
	if on_deck and not lift.moving and lift.landing != from_level:
		# Arrived on the other level: walk off to its landing node.
		return false if not _steer(graph.pos(_lift_to), sweep_speed_base, delta) else true
	if not on_deck and not lift.moving and lift.landing != from_level and Vector2(graph.pos(_lift_to).x - global_position.x, graph.pos(_lift_to).z - global_position.z).length() < 2.5 and absf(global_position.y - graph.pos(_lift_to).y) < 1.0:
		# Already stepping off towards the destination landing.
		return _steer(graph.pos(_lift_to), sweep_speed_base, delta)
	if on_deck:
		_halt(delta)
		if not lift.moving and lift.landing == from_level and not _lift_requested:
			_lift_requested = lift.send()
		return false
	if not lift.moving and lift.landing == from_level:
		_steer(deck, sweep_speed_base, delta)
		return false
	_halt(delta)
	if not lift.moving:
		lift.call_to(from_level)
	return false


## Steers towards `target`; true when arrived. Gravity and floors come from move_and_slide.
func _steer(target: Vector3, speed: float, delta: float) -> bool:
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	var dist := to.length()
	if dist < ARRIVE:
		_halt(delta)
		_reset_stuck()
		return true
	var dir := to / dist
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	velocity.y = -0.5 if is_on_floor() else velocity.y - GRAVITY * delta
	_face(target, delta)
	move_and_slide()
	if dist < _best_progress - 0.1:
		_best_progress = dist
		_stuck_left = STUCK_TIME
	else:
		_stuck_left -= delta
		if _stuck_left <= 0.0:
			_reset_stuck()
			_stuck_hit = true
			return true  # give up on this point; the caller replans from where it really is
	return false


func _reset_stuck() -> void:
	_best_progress = INF
	_stuck_left = STUCK_TIME


func _halt(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = -0.5 if is_on_floor() else velocity.y - GRAVITY * delta
	move_and_slide()


func _face(target: Vector3, delta: float) -> void:
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	if to.length() < 0.05:
		return
	_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(to.x, to.z), clampf(TURN_RATE * delta, 0.0, 1.0))


## A direct run is only taken when three parallel rays (body width) are clear on the same level.
func _direct_clear(target: Vector3) -> bool:
	if absf(target.y - global_position.y) > 0.8:
		return false
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	if to.length() < 0.1:
		return true
	var side := to.normalized().cross(Vector3.UP) * 0.4
	for s in [Vector3.ZERO, side, -side]:
		var a: Vector3 = global_position + Vector3(0.0, 0.5, 0.0) + s
		var q := PhysicsRayQueryParameters3D.create(a, a + to, 1 | 16, [get_rid(), player.get_rid()])
		if not get_world_3d().direct_space_state.intersect_ray(q).is_empty():
			return false
	return true


## Contact catch. The manipulators also reach up to REACH_UP above its base: climbing onto a car or the crates beside
## the unit is not a safe spot (it reaches slightly further when she is up there, over the edge of the cover).
const REACH_UP := 1.9


func _check_catch() -> void:
	if state != "chase" and state != "alert":
		return
	var p := player.global_position
	var dy := p.y - global_position.y
	var flat := Vector2(p.x - global_position.x, p.z - global_position.z).length()
	if dy > -1.2 and dy < REACH_UP and flat < CATCH_DISTANCE + (0.45 if dy > 0.8 else 0.0):
		caught_player.emit()


# --- presentation ------------------------------------------------------------------------------------------------

func _set_state(s: String) -> void:
	if s == state:
		return
	var before := state
	state = s
	if s == "alert" and _sting != null and before != "chase":
		_sting.play()
	state_changed.emit(s)


## Display state for HUD, music and tests: the internal state plus "suspicious" (a sweep with rising awareness).
func display_state() -> String:
	if state == "sweep" and awareness > SUSPICIOUS_AT:
		return "suspicious"
	return state


func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "UnitVisual"
	add_child(_visual)
	var shell := StandardMaterial3D.new()
	shell.albedo_color = Color(0.3, 0.32, 0.31)
	shell.metallic = 0.65
	shell.roughness = 0.42
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.06, 0.065, 0.07)
	dark.roughness = 0.8
	var warn := StandardMaterial3D.new()
	warn.albedo_color = Color(0.72, 0.53, 0.1)
	warn.roughness = 0.7
	_eye_mat = StandardMaterial3D.new()
	_eye_mat.emission_enabled = true
	_eye_mat.albedo_color = Color(0.05, 0.05, 0.05)
	if not _build_model():
		_build_primitive(shell, dark, warn)
	_build_lamp_icon_cone()


## The modelled unit: its "Eye" visor node carries the state material.
func _build_model() -> bool:
	if not ResourceLoader.exists(MODEL_PATH):
		return false
	var scene := load(MODEL_PATH) as PackedScene
	if scene == null:
		return false
	var model := scene.instantiate() as Node3D
	model.name = "UnitModel"
	_visual.add_child(model)
	var eyes := model.find_children("Eye*", "MeshInstance3D", true, false)
	if eyes.is_empty():
		model.queue_free()
		return false
	(eyes[0] as MeshInstance3D).material_override = _eye_mat
	return true


func _build_primitive(shell: Material, dark: Material, warn: Material) -> void:
	# Silhouette: tracked base, narrow chassis, hazard band, tall sensor mast with a wide visor. Reads as a machine
	# (not a person) from any angle, and the visor shows where it is looking.
	_piece(Vector3(0.95, 0.32, 1.05), Vector3(0.0, 0.18, 0.0), dark)          # tracked base
	for side in [-1.0, 1.0]:
		_piece(Vector3(0.18, 0.4, 1.15), Vector3(0.46 * side, 0.2, 0.0), dark)  # track guards
	_piece(Vector3(0.62, 0.9, 0.5), Vector3(0.0, 0.85, -0.03), shell)       # chassis
	_piece(Vector3(0.64, 0.08, 0.52), Vector3(0.0, 1.05, -0.03), warn)      # hazard band
	_piece(Vector3(0.16, 0.42, 0.16), Vector3(0.0, 1.48, -0.02), dark)      # mast
	_piece(Vector3(0.62, 0.26, 0.34), Vector3(0.0, 1.72, 0.02), shell)      # sensor head
	_piece(Vector3(0.66, 0.05, 0.36), Vector3(0.0, 1.87, 0.02), warn)       # head crest
	for side in [-1.0, 1.0]:
		_piece(Vector3(0.12, 0.7, 0.14), Vector3(0.38 * side, 0.92, 0.1), dark)  # folded manipulators
		_piece(Vector3(0.1, 0.12, 0.3), Vector3(0.38 * side, 0.52, 0.2), shell)   # grippers
	var eye := _piece(Vector3(0.5, 0.07, 0.04), Vector3(0.0, 1.73, 0.2), _eye_mat)
	eye.name = "Eye"


func _build_lamp_icon_cone() -> void:
	_lamp = OmniLight3D.new()
	_lamp.position = Vector3(0.0, 1.75, 0.5)
	_lamp.omni_range = 3.5
	_lamp.light_energy = 0.8
	_visual.add_child(_lamp)
	_icon = Label3D.new()
	_icon.position = Vector3(0.0, 2.45, 0.0)
	_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon.no_depth_test = true
	_icon.font_size = 96
	_icon.pixel_size = 0.005
	_icon.outline_size = 12
	add_child(_icon)
	# Vision cone on the floor: hidden normally, shown by Elena's scanner.
	_cone = MeshInstance3D.new()
	var cone_mesh := CylinderMesh.new()
	cone_mesh.top_radius = 0.0
	cone_mesh.bottom_radius = 9.0 * tan(deg_to_rad(VISION_HALF_ANGLE)) * 0.55
	cone_mesh.height = 9.0
	cone_mesh.radial_segments = 3
	_cone.mesh = cone_mesh
	var cm := StandardMaterial3D.new()
	cm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cm.albedo_color = Color(1.0, 0.3, 0.2, 0.18)
	cm.no_depth_test = true
	_cone.material_override = cm
	_cone.rotation = Vector3(PI * 0.5, 0.0, 0.0)
	_cone.position = Vector3(0.0, 0.1, 4.5)
	_cone.scale = Vector3(1.0, 1.0, 0.08)
	_cone.visible = false
	_visual.add_child(_cone)


func _build_audio() -> void:
	_hum = AudioStreamPlayer3D.new()
	_hum.stream = Synth.servo_hum()
	_hum.bus = "SFX"
	_hum.unit_size = 4.0
	_hum.max_distance = 26.0
	_hum.volume_db = -6.0
	_hum.position.y = 1.0
	add_child(_hum)
	_sting = AudioStreamPlayer3D.new()
	_sting.stream = Synth.alert_sting()
	_sting.bus = "SFX"
	_sting.unit_size = 8.0
	_sting.max_distance = 40.0
	_sting.position.y = 1.7
	add_child(_sting)
	_step_audio = AudioStreamPlayer3D.new()
	_step_audio.stream = Synth.heavy_step()
	_step_audio.bus = "SFX"
	_step_audio.unit_size = 5.0
	_step_audio.max_distance = 28.0
	_step_audio.volume_db = -4.0
	add_child(_step_audio)


## Machine audio: the servo hum rises with speed and heavy track thumps mark its pace, so it can be located by ear.
func _update_audio(delta: float) -> void:
	var speed := Vector2(velocity.x, velocity.z).length()
	if _hum != null:
		_hum.pitch_scale = 0.8 + speed * 0.09
		_hum.volume_db = -14.0 + minf(speed, 5.0) * 1.6
	_step_left -= delta * maxf(speed, 0.0)
	if speed > 0.4 and _step_left <= 0.0 and _step_audio != null:
		_step_left = 1.4
		_step_audio.pitch_scale = 0.9 + randf_range(-0.04, 0.04)  # cosmetic variation only
		_step_audio.play()


func _piece(size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var m := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	m.mesh = bm
	m.position = pos
	m.material_override = material
	_visual.add_child(m)
	return m


func set_revealed(on: bool) -> void:
	_cone.visible = on


## Eye colour AND a symbol, never colour alone: sweep "·", suspicious "?" (fading in with awareness),
## investigate/search "?", alert "!", chase "!!".
func _update_visual(_delta: float) -> void:
	var shown := display_state()
	var role := "neutral"
	var icon := "·"
	var alpha := 1.0
	match shown:
		"suspicious":
			role = "warn"
			icon = "?"
			alpha = clampf(0.35 + awareness, 0.35, 1.0)
		"investigate", "search":
			role = "warn"
			icon = "?"
		"alert":
			role = "danger"
			icon = "!"
		"chase":
			role = "danger"
			icon = "!!"
	var color := GamePalette.unit_color(role)
	_eye_mat.emission = color
	_eye_mat.emission_energy_multiplier = 3.0
	_lamp.light_color = color
	_icon.text = icon
	_icon.modulate = Color(color.r, color.g, color.b, alpha)
