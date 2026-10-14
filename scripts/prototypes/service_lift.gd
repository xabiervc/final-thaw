extends Node3D
## Service lift for the Phase 1 lift gate (docs/design/FASE1_LIFT_GATE.md). Independent component: it knows nothing about
## the mission or the circuit. It only needs `set_powered()` from whoever owns the power (maintenance, per the logic contract).
##
## Rules (all covered by tests/test_service_lift.tscn):
##  - Two landings, `lower` and `upper`. The deck is flush with the landing it is docked at.
##  - A gate closes each end of the deck. The end facing a landing opens only while docked at that landing, so nobody
##    can step into the shaft from the deck or onto the deck while it is away.
##  - Calls from either landing or from the deck. A call during a trip is queued; the lift stays docked for `dwell_time`
##    seconds before leaving again, so a rider can always get off.
##  - Power loss: while docked the lift stays docked with its gate open and ignores calls. While moving it finishes the
##    trip at `crawl_factor` of its speed towards the NEAREST landing (never left between floors) and then locks.
##  - The motion is a pure function of `step(delta)`, so it can be tested without physics.

signal docked(landing_name: String)
signal departed(origin: String, destination: String)
signal state_changed(description: String)

const LOWER := "lower"
const UPPER := "upper"

@export var lower_y: float = 0.0
@export var upper_y: float = 3.0
@export var speed: float = 1.2
@export var crawl_factor: float = 0.3
@export var dwell_time: float = 3.0
@export var deck_size: Vector3 = Vector3(3.0, 0.25, 3.0)
@export var rail_height: float = 1.1

var powered: bool = true
var moving: bool = false
var crawling: bool = false
var landing: String = LOWER
var target: String = LOWER
var pending: String = ""
var platform_y: float = 0.0
var dwell_left: float = 0.0
var platform: AnimatableBody3D = null
var _gate_parts: Dictionary = {}
## Optional occupancy sensor: while it returns true (a rider is on the deck and did not ask to move), calls from the
## landings wait instead of carrying the rider away. Unset by default: the component behaves as before.
var hold_departure: Callable = Callable()


func _ready() -> void:
	platform_y = _y_of(landing)
	_build()
	_apply_gates()
	_sync_platform()


func _physics_process(delta: float) -> void:
	step(delta)


func _y_of(level: String) -> float:
	return upper_y if level == UPPER else lower_y


## Which ends of the deck are open (state only, independent of the nodes).
func gates_open() -> Dictionary:
	return {"south": not moving and landing == LOWER, "north": not moving and landing == UPPER}


func state_key() -> String:
	if moving:
		return "moving_up" if target == UPPER else "moving_down"
	return "docked_upper" if landing == UPPER else "docked_lower"


func describe() -> String:
	if moving:
		return ("Emergencia: " if crawling else "") + ("subiendo" if target == UPPER else "bajando")
	return "Detenido en el nivel " + ("superior" if landing == UPPER else "inferior") + ("" if powered else " (sin energía)")


func set_powered(on: bool) -> void:
	if powered == on:
		return
	powered = on
	_log("power " + ("on" if on else "off"))
	if not on and moving:
		crawling = true
		pending = ""
		var middle: float = (lower_y + upper_y) * 0.5
		target = UPPER if platform_y >= middle else LOWER
		_log("emergency: finishing the trip towards " + target)
	state_changed.emit(describe())


## Returns true when the call is accepted (including "already here"). Unpowered calls are refused.
func call_to(destination: String) -> bool:
	if destination != LOWER and destination != UPPER:
		return false
	if not powered:
		return false
	if moving:
		pending = destination if destination != target else ""
		return true
	if destination == landing:
		return true
	if dwell_left > 0.0 or _held():
		pending = destination
		return true
	_depart(destination)
	return true


func _held() -> bool:
	return hold_departure.is_valid() and bool(hold_departure.call())


## Sends the lift to the other landing (the deck button).
func send() -> bool:
	return call_to(LOWER if (target if moving else landing) == UPPER else UPPER)


func _depart(destination: String) -> void:
	target = destination
	moving = true
	crawling = false
	_log("departing %s -> %s" % [landing, destination])
	departed.emit(landing, destination)
	_apply_gates()
	state_changed.emit(describe())


func step(delta: float) -> void:
	if moving:
		var goal: float = _y_of(target)
		var rate: float = speed * (crawl_factor if crawling else 1.0)
		platform_y = move_toward(platform_y, goal, rate * delta)
		if is_equal_approx(platform_y, goal):
			platform_y = goal
			landing = target
			moving = false
			crawling = false
			dwell_left = dwell_time
			_log("docked at " + landing)
			_apply_gates()
			docked.emit(landing)
			state_changed.emit(describe())
	else:
		dwell_left = maxf(0.0, dwell_left - delta)
		if dwell_left <= 0.0:
			if pending != "" and pending != landing and powered and not _held():
				var destination: String = pending
				pending = ""
				_depart(destination)
			elif pending == landing:
				pending = ""
	_sync_platform()


func _sync_platform() -> void:
	if platform != null:
		platform.position = Vector3(0.0, platform_y - deck_size.y * 0.5, 0.0)


func _apply_gates() -> void:
	if _gate_parts.is_empty():
		return
	var open: Dictionary = gates_open()
	for side: String in ["south", "north"]:
		var part: Dictionary = _gate_parts[side]
		(part["shape"] as CollisionShape3D).set_deferred("disabled", bool(open[side]))
		(part["mesh"] as MeshInstance3D).visible = not bool(open[side])


func _build() -> void:
	platform = AnimatableBody3D.new()
	platform.name = "Platform"
	platform.sync_to_physics = true
	platform.collision_layer = 1
	platform.collision_mask = 0
	add_child(platform)
	var half: Vector3 = deck_size * 0.5
	var rail_y: float = half.y + rail_height * 0.5
	var steel := Color(0.28, 0.3, 0.33)
	var amber := Color(0.6, 0.44, 0.15)
	_part("Deck", deck_size, Vector3.ZERO, steel)
	_part("RailEast", Vector3(0.1, rail_height, deck_size.z), Vector3(half.x - 0.05, rail_y, 0.0), amber)
	_part("RailWest", Vector3(0.1, rail_height, deck_size.z), Vector3(-half.x + 0.05, rail_y, 0.0), amber)
	_gate_parts["south"] = _part("GateSouth", Vector3(deck_size.x - 0.2, rail_height, 0.1), Vector3(0.0, rail_y, half.z - 0.05), amber)
	_gate_parts["north"] = _part("GateNorth", Vector3(deck_size.x - 0.2, rail_height, 0.1), Vector3(0.0, rail_y, -half.z + 0.05), amber)


func _part(label: String, size: Vector3, offset: Vector3, color: Color) -> Dictionary:
	var shape := CollisionShape3D.new()
	shape.name = label + "Shape"
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = offset
	platform.add_child(shape)
	var mesh := MeshInstance3D.new()
	mesh.name = label + "Mesh"
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.7
	mesh.material_override = material
	mesh.position = offset
	platform.add_child(mesh)
	return {"shape": shape, "mesh": mesh}


func _log(message: String) -> void:
	print("[lift %.1fs] %s" % [Time.get_ticks_msec() / 1000.0, message])
