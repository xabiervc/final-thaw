extends CharacterBody3D
## STAFF-M1: the pump-room operator (FASE1_FUNCTIONAL_SPEC.md 5.1). Not an enemy: never fights, never blocks the
## corridor, never knows where Elena is unless he sees her.
##
## Routine (deterministic, learnable): works at panel A, walks to panel B, works, walks back; at each panel he
## faces the wall, and every second stop he turns to check the pump lamps (facing south) for a short while.
## Before Containment he ignores Elena (an authorised visitor). After it, his senses count:
##   vision 8 m, 100-degree cone, real line of sight (the pump bank C1 and the O2 rack block it; rails do not).
##   0.8 s of sight -> SUSPICIOUS ("?"), 1.2 s continuous -> ALERTED ("!"): one call, the unit receives the LAST
##   KNOWN position, then he WITHDRAWS to the shift office and leaves. Sight lost: suspicion decays in 2 s and he
##   briefly INVESTIGATES the last spot he saw her before resuming work.

signal alerted(last_known: Vector3)
signal state_changed(state: String)

const WALK_SPEED := 1.4
const WITHDRAW_SPEED := 2.6
const VISION_RANGE := 8.0
const VISION_HALF_ANGLE := 50.0
const SUSPICION_TIME := 0.8
const ALERT_TIME := 1.2
const DECAY_TIME := 2.0
const WORK_TIME := 3.2
const LOOK_TIME := 2.0
const PANEL_A := Vector3(16.5, 3.0, -9.1)
const PANEL_B := Vector3(21.5, 3.0, -9.1)
const REFUGE := Vector3(28.6, 3.0, -9.3)

var player: CharacterBody3D = null
var state: String = "WORKING"
var containment: bool = false
var suspicion: float = 0.0

var _target: Vector3 = PANEL_A
var _next_panel: Vector3 = PANEL_B
var _work_left: float = WORK_TIME
var _look_left: float = 0.0
var _stops: int = 0
var _investigate_at: Vector3 = Vector3.ZERO
var _investigate_left: float = 0.0
var _visual: Node3D
var _icon: Label3D
var _cone: MeshInstance3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 16
	var shape := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.75
	shape.shape = cap
	shape.position.y = 0.875
	add_child(shape)
	_build_visual()
	global_position = PANEL_A
	_visual.rotation.y = PI  # facing the panel (north)


func set_containment(on: bool) -> void:
	containment = on


func eye() -> Vector3:
	return global_position + Vector3(0.0, 1.6, 0.0)


func facing() -> Vector3:
	var f := _visual.global_transform.basis.z
	f.y = 0.0
	return f.normalized()


func sees_player() -> bool:
	if player == null or not containment or state == "WITHDRAWING" or state == "GONE":
		return false
	var p := player.global_position
	if absf(p.y - global_position.y) > 1.6:
		return false
	var to := Vector3(p.x - global_position.x, 0.0, p.z - global_position.z)
	if to.length() > VISION_RANGE:
		return false
	if to.length() > 0.8 and rad_to_deg(facing().angle_to(to.normalized())) > VISION_HALF_ANGLE:
		return false
	var chest := 0.6 if bool(player.get("is_crouching")) else 1.1
	var q := PhysicsRayQueryParameters3D.create(eye(), p + Vector3(0.0, chest, 0.0), 1, [get_rid(), player.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(q).is_empty()


func _physics_process(delta: float) -> void:
	if state == "GONE":
		return
	var sees := sees_player()
	if state != "WITHDRAWING":
		if sees:
			suspicion += delta
		else:
			suspicion = maxf(0.0, suspicion - delta * (ALERT_TIME / DECAY_TIME))
		if suspicion >= ALERT_TIME:
			_alert()
		elif sees and suspicion >= SUSPICION_TIME and state != "SUSPICIOUS":
			_set_state("SUSPICIOUS")
		elif not sees and state == "SUSPICIOUS":
			_investigate_at = player.global_position if player != null else global_position
			_investigate_left = 3.0
			_set_state("INVESTIGATING")
	match state:
		"WORKING":
			_routine(delta)
		"SUSPICIOUS":
			_halt(delta)
			if player != null:
				_face(player.global_position, delta, 4.0)
		"INVESTIGATING":
			_investigate_left -= delta
			if _move_to(_flat_clamped(_investigate_at), WALK_SPEED, delta) or _investigate_left <= 0.0:
				_set_state("WORKING")
		"WITHDRAWING":
			if _move_to(REFUGE, WITHDRAW_SPEED, delta):
				_set_state("GONE")
				visible = false
				collision_mask = 0
	_update_icon()


## Investigation never leaves the pump-room lanes (he does not chase anyone).
func _flat_clamped(p: Vector3) -> Vector3:
	return Vector3(clampf(p.x, 14.0, 23.0), global_position.y, clampf(p.z, -9.2, -7.9))


func _routine(delta: float) -> void:
	if _look_left > 0.0:
		_look_left -= delta
		_halt(delta)
		_turn_to_yaw(0.0, delta)  # facing south, towards the pump lamps
		return
	if _work_left > 0.0:
		_work_left -= delta
		_halt(delta)
		_turn_to_yaw(PI, delta)  # facing the panel
		if _work_left <= 0.0:
			_stops += 1
			if _stops % 2 == 0:
				_look_left = LOOK_TIME * (1.4 if containment else 1.0)
		return
	if _move_to(_next_panel, WALK_SPEED, delta):
		var reached := _next_panel
		_next_panel = PANEL_A if reached == PANEL_B else PANEL_B
		_work_left = WORK_TIME * (0.75 if containment else 1.0)


func _alert() -> void:
	suspicion = 0.0
	_set_state("ALERTED")
	var seen := player.global_position if player != null else global_position
	alerted.emit(seen)
	_set_state("WITHDRAWING")


func _move_to(target: Vector3, speed: float, delta: float) -> bool:
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	if to.length() < 0.25:
		_halt(delta)
		return true
	var dir := to.normalized()
	velocity = Vector3(dir.x * speed, -0.5, dir.z * speed)
	_face(target, delta, 8.0)
	move_and_slide()
	return false


func _halt(_delta: float) -> void:
	velocity = Vector3(0.0, -0.5, 0.0)
	move_and_slide()


func _face(target: Vector3, delta: float, rate: float) -> void:
	var to := Vector3(target.x - global_position.x, 0.0, target.z - global_position.z)
	if to.length() > 0.05:
		_visual.rotation.y = lerp_angle(_visual.rotation.y, atan2(to.x, to.z), clampf(rate * delta, 0.0, 1.0))


func _turn_to_yaw(yaw: float, delta: float) -> void:
	_visual.rotation.y = lerp_angle(_visual.rotation.y, yaw, clampf(5.0 * delta, 0.0, 1.0))


func _set_state(s: String) -> void:
	if s == state:
		return
	state = s
	state_changed.emit(s)


func _build_visual() -> void:
	_visual = Node3D.new()
	_visual.name = "StaffVisual"
	add_child(_visual)
	var coverall := StandardMaterial3D.new()
	coverall.albedo_color = Color(0.22, 0.3, 0.36)
	coverall.roughness = 0.85
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.72, 0.56, 0.46)
	var helmet := StandardMaterial3D.new()
	helmet.albedo_color = Color(0.85, 0.82, 0.78)
	var reflective := StandardMaterial3D.new()
	reflective.albedo_color = Color(0.75, 0.75, 0.7)
	reflective.roughness = 0.3
	for side in [-1.0, 1.0]:
		_piece(CapsuleMesh.new(), Vector3(0.11 * side, 0.45, 0.0), coverall, Vector3(0.22, 0.9, 0.22))
	_piece(CapsuleMesh.new(), Vector3(0.0, 1.15, 0.0), coverall, Vector3(0.5, 0.75, 0.32))
	_piece(BoxMesh.new(), Vector3(0.0, 1.2, 0.0), reflective, Vector3(0.52, 0.05, 0.34))
	_piece(SphereMesh.new(), Vector3(0.0, 1.62, 0.02), skin, Vector3(0.24, 0.27, 0.24))
	_piece(SphereMesh.new(), Vector3(0.0, 1.72, 0.0), helmet, Vector3(0.3, 0.16, 0.32))
	_piece(BoxMesh.new(), Vector3(0.0, 1.25, 0.22), helmet, Vector3(0.18, 0.24, 0.04))  # clipboard
	_icon = Label3D.new()
	_icon.position = Vector3(0.0, 2.25, 0.0)
	_icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_icon.no_depth_test = true
	_icon.font_size = 80
	_icon.pixel_size = 0.005
	_icon.outline_size = 12
	add_child(_icon)
	# Sight cone on the floor (shown by the scanner and while he is suspicious).
	_cone = MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.0
	cm.bottom_radius = VISION_RANGE * tan(deg_to_rad(VISION_HALF_ANGLE)) * 0.55
	cm.height = VISION_RANGE
	cm.radial_segments = 3
	_cone.mesh = cm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(1.0, 0.85, 0.3, 0.16)
	mat.no_depth_test = true
	_cone.material_override = mat
	_cone.rotation = Vector3(PI * 0.5, 0.0, 0.0)
	_cone.position = Vector3(0.0, 0.08, VISION_RANGE * 0.5)
	_cone.scale = Vector3(1.0, 1.0, 0.08)
	_cone.visible = false
	_visual.add_child(_cone)


func _piece(mesh: PrimitiveMesh, pos: Vector3, material: Material, size: Vector3) -> void:
	var m := MeshInstance3D.new()
	if mesh is CapsuleMesh:
		(mesh as CapsuleMesh).radius = size.x * 0.5
		(mesh as CapsuleMesh).height = size.y
	elif mesh is SphereMesh:
		(mesh as SphereMesh).radius = size.x * 0.5
		(mesh as SphereMesh).height = size.y
	elif mesh is BoxMesh:
		(mesh as BoxMesh).size = size
	m.mesh = mesh
	m.position = pos
	m.material_override = material
	_visual.add_child(m)


var revealed: bool = false


func set_revealed(on: bool) -> void:
	revealed = on


func _update_icon() -> void:
	var icon := ""
	var color := Color(1.0, 0.85, 0.3)
	match state:
		"SUSPICIOUS", "INVESTIGATING":
			icon = "?"
		"ALERTED", "WITHDRAWING":
			icon = "!"
			color = Color(1.0, 0.4, 0.2)
	_icon.text = icon
	_icon.modulate = color
	_cone.visible = containment and state != "WITHDRAWING" and state != "GONE" and (revealed or state == "SUSPICIOUS")
