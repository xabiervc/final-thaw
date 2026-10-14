extends Node3D
## Spatial review only: no circuit integration, archive extraction or containment.
const Player = preload("res://scripts/prototypes/phase1_spatial_player.gd")
const FLOOR := Color(0.24, 0.28, 0.31)
const RAIL := Color(0.6, 0.44, 0.15)
var player: CharacterBody3D
var shortcut_shape: CollisionShape3D
var shortcut_mesh: MeshInstance3D
var shortcut_open: bool = false
var safe_point := Vector3(3.0, 0.1, 7.0)
var hud: Label

func _ready() -> void:
	_build()
	player = Player.new()
	player.position = safe_point
	add_child(player)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(16.0, 16.0)
	hud.add_theme_constant_override("outline_size", 6)
	layer.add_child(hud)

func _physics_process(_delta: float) -> void:
	if player.is_on_floor() and player.position.y > 2.8:
		safe_point = Vector3(26.0, 3.1, -6.5)
	if player.position.y < -5.0:
		player.position = safe_point
		player.velocity = Vector3.ZERO
	var near := player.position.distance_to(Vector3(2.0, 3.0, -7.5)) < 2.5
	hud.text = "SPATIAL TEST / NOT A MISSION\nWASD: move | Mouse: camera (click) | Space: jump | Esc: release mouse/menu\nTemporary ramp replaces the lift; no lift validation."
	if near and not shortcut_open:
		hud.text += "\nE: unlock shortcut from cabin side"
		if Input.is_action_just_pressed("interact"):
			unlock_shortcut(player.position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func unlock_shortcut(from: Vector3) -> bool:
	if from.x <= 2.0 or from.distance_to(Vector3(2.0, 3.0, -7.5)) > 2.5:
		return false
	shortcut_open = true
	shortcut_shape.set_deferred("disabled", true)
	shortcut_mesh.visible = false
	return true

func _box(id: String, size: Vector3, pos: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = id
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var resource := BoxShape3D.new()
	resource.size = size
	shape.shape = resource
	body.add_child(shape)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	body.add_child(mesh)
	add_child(body)
	return body

func _floor(id: String, x0: float, x1: float, z0: float, z1: float, y: float) -> void:
	_box(id, Vector3(x1-x0, 0.25, z1-z0), Vector3((x0+x1)*0.5, y-0.125, (z0+z1)*0.5), FLOOR)

func _ramp(id: String, x0: float, x1: float, z0: float, z1: float, y0: float, y1: float) -> void:
	var angle := -atan2(y1-y0, z1-z0)
	var basis := Basis(Vector3.RIGHT, angle)
	var center := Vector3((x0+x1)*0.5, (y0+y1)*0.5, (z0+z1)*0.5) - basis.y * 0.125
	var body := _box(id, Vector3(x1-x0, 0.25, Vector2(z1-z0,y1-y0).length()), center, FLOOR)
	body.rotation.x = angle

func _sign(text: String, at: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = at
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 42
	label.pixel_size = 0.008
	add_child(label)

func _build() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08,0.1,0.13)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7,0.8,0.9)
	env.ambient_light_energy = 0.7
	environment.environment = env
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50,-30,0)
	sun.light_energy = 0.8
	add_child(sun)
	# Split main floor: no collider covering pit or descending stairs.
	_floor("WestFloorWithInfill",0,20,-10,12,0)
	_floor("NorthFloor",20,30,-10,1,0)
	_floor("EastFloor",28,30,1,12,0)
	_floor("ApronWest",20,24,8,12,0)
	_floor("ApronEast",26,28,8,12,0)
	_floor("StairTopApron",24,26,11,12,0)
	_floor("Pit",20,28,1,8,-2)
	_ramp("PitStairsCollision",24,26,8,11,-2,0)
	_box("Machine",Vector3(7,2,5),Vector3(14.5,1,0.5),Color(0.15,0.2,0.22))
	_floor("Cabin",2,9,-9,-5,3)
	_floor("PublicWalkway",9,26,-8,-6,3)
	_floor("UpperLanding",24,28,-7,-4.5,3)
	_floor("LiftLowerConnector",24.5,27.5,-1.5,-1,0)
	_ramp("BrokenApproach",2,4,-3,3,3,0)
	_floor("BrokenLanding",2,4,-4,-3,3)
	_box("BrokenBarrier",Vector3(2,2.4,0.15),Vector3(3,4.2,-4),RAIL)
	# Shortcut has no overlap with public walkway.
	_floor("ShortcutVestibule",0,2,-9,-6,3)
	_ramp("ShortcutStairsCollision",0,2,-6,0,3,0)
	_floor("ShortcutFoot",0,2,0,2,0)
	_box("WestPartitionNorth",Vector3(0.15,2.4,0.5),Vector3(2.075,4.2,-8.75),FLOOR)
	_box("WestPartitionSouth",Vector3(0.15,2.4,1.5),Vector3(2.075,4.2,-5.75),FLOOR)
	_box("WestLintel",Vector3(0.15,0.2,2),Vector3(2.075,5.3,-7.5),FLOOR)
	var door := _box("ShortcutDoor",Vector3(0.15,2.2,2),Vector3(2.075,4.1,-7.5),RAIL)
	shortcut_shape = door.get_child(0) as CollisionShape3D
	shortcut_mesh = door.get_child(1) as MeshInstance3D
	_box("VestibuleNorth",Vector3(2,2.4,0.15),Vector3(1,4.2,-9.075),FLOOR)
	_box("VestibuleWest",Vector3(0.15,2.4,3),Vector3(-0.075,4.2,-7.5),FLOOR)
	_box("VestibuleRoof",Vector3(2,0.2,3),Vector3(1,5.5,-7.5),FLOOR)
	_box("StairSeparation",Vector3(0.15,5.4,6),Vector3(2,2.7,-3),FLOOR)
	# Temporary alternative, not a functioning lift.
	_floor("TemporaryGroundJoin",28,31,8,10,0)
	_floor("TemporaryLowerLanding",31,33,8,10,0)
	_ramp("TemporaryRamp",31,33,-6,8,3,0)
	_floor("TemporaryUpperLanding",31,33,-8,-6,3)
	_floor("TemporaryReturn",28,31,-8,-6,3)
	_floor("TemporaryUpperJoin",26,28,-8,-6,3)
	# Pit protection, with the stair mouth left open.
	_box("PitWestRail",Vector3(0.2,1.2,7),Vector3(19.9,0.6,4.5),RAIL)
	_box("PitSouthRailA",Vector3(4,1.2,0.2),Vector3(22,0.6,7.9),RAIL)
	_box("PitSouthRailB",Vector3(2,1.2,0.2),Vector3(27,0.6,7.9),RAIL)
	_box("PitEastRail",Vector3(0.15,1.2,7),Vector3(28.075,0.6,4.5),RAIL)
	_box("PitNorthRail",Vector3(8,1.2,0.15),Vector3(24,0.6,0.925),RAIL)
	_box("LiftNotInstalledBarrier",Vector3(4,1.2,0.15),Vector3(26,3.6,-4.425),RAIL)
	_sign("ARCHIVE / UPPER CABIN",Vector3(5,4.5,-7))
	_sign("MAINTENANCE / PIT",Vector3(26,-0.6,2))
	_sign("SCHEMATIC (clue position)",Vector3(27,-0.5,6))
	_sign("TAMPERED BRIDGE (clue position)",Vector3(22,-0.5,4))
	_sign("ISOLATOR (control position)",Vector3(19,4.2,-7))
	_sign("SELECTOR (control position)",Vector3(12,4.2,-7))
	_sign("PROVISIONAL RAMP / NOT LIFT VALIDATION",Vector3(32,1.8,9))
	_sign("LIFT NOT INSTALLED",Vector3(26,4.5,-4.5))
