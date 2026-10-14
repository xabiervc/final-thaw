extends "res://scripts/prototypes/phase1_spatial_greybox.gd"
## Alternative exploration build. Keeps shared art, animations and circuit interactions.
## No changes to baseline files; no final record, extraction, containment or pursuit.
const EXTRA_ROOMS := {
	"approach": {"name": "Acceso de servicio", "x0": -24.0, "x1": -6.0, "z0": -2.0, "z1": 4.0, "y": 0.0, "spawn": Vector3(-22,0.2,1)},
	"gallery": {"name": "Galería de observación", "x0": 18.0, "x1": 26.0, "z0": 14.0, "z1": 24.0, "y": 1.5, "spawn": Vector3(23,1.7,16)},
	"passage": {"name": "Pasaje inferior", "x0": 26.0, "x1": 42.0, "z0": 18.0, "z1": 22.0, "y": -2.0, "spawn": Vector3(28,-1.8,20.5)},
	"workshop": {"name": "Taller de mantenimiento", "x0": 42.0, "x1": 52.0, "z0": 16.0, "z1": 28.0, "y": -2.0, "spawn": Vector3(46,-1.8,20)},
}
const EXTRA_GAPS := {
	"approach": {"east": [[0.0,2.0]]},
	"gallery": {"north": [[18.0,24.0]]},
	"passage": {"west": [[18.0,22.0]], "east": [[18.0,22.0]]},
	"workshop": {"west": [[18.0,22.0]], "north": [[42.0,44.0]]},
}
const EXTRA_STAIRS := [
	{"id": "Gallery", "axis": "z", "c0": 22.0, "c1": 24.0, "a0": 8.0, "a1": 14.0, "y0": 0.0, "y1": 1.5},
	{"id": "Workshop", "axis": "z", "c0": 42.0, "c1": 44.0, "a0": 6.0, "a1": 16.0, "y0": 1.5, "y1": -2.0},
]

func _ready() -> void:
	super._ready()
	for id: String in EXTRA_ROOMS:
		_build_extra_room(id)
	for stair: Dictionary in EXTRA_STAIRS:
		_build_stairs(stair)
	_body("ApproachConnectorFloor", Vector3(6,0.25,2), Vector3(-3,-0.125,1), materials.get_material("floor"))
	_body("ApproachConnectorNorth", Vector3(6,3,0.2), Vector3(-3,1.5,-0.1), materials.get_material("bulkhead"))
	_body("ApproachConnectorSouth", Vector3(6,3,0.2), Vector3(-3,1.5,2.1), materials.get_material("bulkhead"))
	# A shallow partition makes the lower passage turn, with 2 m clear to its south.
	_body("PassageTurn", Vector3(0.25,2.6,2), Vector3(34,-0.7,19), materials.get_material("steel"))
	_window("GalleryWindow", Vector3(4,2.2,0.15), Vector3(20,2.2,14))
	_window("HallObservationWindow", Vector3(4,2.2,0.15), Vector3(20,2.2,8))
	_window_frame(14.0)
	_window_frame(8.0)
	player.position = EXTRA_ROOMS["approach"]["spawn"]
	safe_point = player.position
	current_room = ""
	overview_camera.position = Vector3(14,80,5)
	overview_camera.look_at(Vector3(14,0,5), Vector3(0,0,-1))
	hud.call("set_hint", "Explora la instalación · H ayuda opcional · F4/F5 vistas de revisión")

func _build_markers() -> void:
	# Hide debug position labels in this variant; actual objects and HUD prompts remain.
	pass

func _build_room(id: String) -> void:
	super._build_room(id)
	if id == "entry":
		_replace_side(id, "west", [[0.0,2.0]])
	elif id == "test_hall":
		_replace_side(id, "south", [[18.0,24.0]])
	elif id == "pit":
		# Lower boundary walls must stop below the new gallery floor (underside at 1.25 m).
		_replace_side(id, "north", [], 3.2)
		_replace_side(id, "south", [], 3.2)
		_replace_side(id, "east", [[18.0,22.0]], 3.2)
	elif id == "pump":
		_replace_side(id, "south", [[42.0,44.0]])

func _replace_side(id: String, side: String, extra: Array, height: float = -1.0) -> void:
	var prefix: String = "Wall_%s_%s" % [id, side]
	for child: Node in get_children():
		if child is StaticBody3D and str(child.name).begins_with(prefix):
			body_group.erase(child)
			child.free()
	var r: Dictionary = Layout.ROOMS[id]
	var gaps: Array = Layout.openings(id)[side].duplicate()
	gaps.append_array(extra)
	_side(r, id, side, gaps, height if height > 0.0 else Layout.WALL_HEIGHT)

func _side(r: Dictionary, id: String, side: String, gaps: Array, height: float) -> void:
	var horizontal: bool = side == "north" or side == "south"
	var lo: float = float(r["x0"]) if horizontal else float(r["z0"])
	var hi: float = float(r["x1"]) if horizontal else float(r["z1"])
	var fixed: float = float(r["x1"])
	if side == "north":
		fixed = float(r["z0"])
	elif side == "south":
		fixed = float(r["z1"])
	elif side == "west":
		fixed = float(r["x0"])
	var group: int = _new_fade_group("bulkhead")
	for segment: Array in _segments(lo,hi,gaps):
		var a: float = float(segment[0])
		var b: float = float(segment[1])
		var size: Vector3 = Vector3(b-a,height,0.2) if horizontal else Vector3(0.2,height,b-a)
		var center: Vector3 = Vector3((a+b)*0.5,float(r["y"])+height*0.5,fixed) if horizontal else Vector3(fixed,float(r["y"])+height*0.5,(a+b)*0.5)
		var wall: StaticBody3D = _body("ExtendedWall_%s_%s" % [id,side],size,center,fade_groups[group]["material"])
		body_group[wall] = group

func _build_extra_room(id: String) -> void:
	var r: Dictionary = EXTRA_ROOMS[id]
	var x0: float = float(r["x0"])
	var x1: float = float(r["x1"])
	var z0: float = float(r["z0"])
	var z1: float = float(r["z1"])
	var y: float = float(r["y"])
	_body("ExtensionFloor_"+id,Vector3(x1-x0,0.25,z1-z0),Vector3((x0+x1)*0.5,y-0.125,(z0+z1)*0.5),materials.get_material("floor"))
	var gaps: Dictionary = EXTRA_GAPS[id]
	for side: String in ["north","south","west","east"]:
		_side(r,id,side,gaps.get(side,[]),3.0)
	var light := OmniLight3D.new()
	light.position = Vector3((x0+x1)*0.5,y+2.7,(z0+z1)*0.5)
	light.light_energy = 0.4
	light.omni_range = 8.0
	add_child(light)
	room_lights.append(light)
	var label := Label3D.new()
	label.text = str(r["name"])
	label.position = Vector3((x0+x1)*0.5,y+2.5,z1-0.2)
	label.rotation.y = PI
	label.font_size = 32
	label.pixel_size = 0.005
	add_child(label)

func _window(id: String, size: Vector3, center: Vector3) -> void:
	var glass := StandardMaterial3D.new()
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color = Color(0.4,0.7,0.8,0.16)
	_body(id,size,center,glass)

func _window_frame(z: float) -> void:
	_body("WindowSill",Vector3(4,1.1,0.2),Vector3(20,0.55,z),materials.get_material("bulkhead"))
	_body("WindowHeader",Vector3(4,1.2,0.2),Vector3(20,3.9,z),materials.get_material("bulkhead"))

func _update_room() -> void:
	for id: String in EXTRA_ROOMS:
		var r: Dictionary = EXTRA_ROOMS[id]
		var p: Vector3 = player.position
		if p.x >= float(r["x0"]) and p.x <= float(r["x1"]) and p.z >= float(r["z0"]) and p.z <= float(r["z1"]) and absf(p.y-float(r["y"])) < 1.0:
			if id != current_room:
				current_room = id
				if player.is_on_floor():
					safe_point = r["spawn"]
				hud.call("set_status","Zona: "+str(r["name"]))
			return
	super._update_room()
