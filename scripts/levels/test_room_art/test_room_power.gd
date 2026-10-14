extends Node3D
## Light rig and power-state presentation for the Helix test bay (visual-only, decision D1).
##
## Before the generator lever is pulled the bay runs on its emergency circuit: a few cold fixtures in B-1/B-2, one
## failing fixture, the warming station heater and a pulsing red beacon on the generator that spills over the alcove
## wall. Pulling the lever (lever.toggled) brings the generator circuit up fixture by fixture: B-3 and B-4 lights,
## generator vents, status strips turning from red to green and the exit chevrons. Turning it off reverses it.
## Gameplay is unaffected: the room script still owns the lever -> exit-door rule.
##
## Flicker is a fixed, deterministic pattern (cosmetic). With reduced motion enabled there is no flicker or pulsing:
## lights fade smoothly instead.

signal power_changed(on: bool)

const COLD := Color(0.78, 0.88, 1.0)
const WARM := Color(1.0, 0.6, 0.32)
const RED := Color(1.0, 0.18, 0.1)
const GREEN := Color(0.25, 1.0, 0.55)

const LAMP_ENERGY := 3.0
const VENT_ENERGY := 2.2
const STATUS_ENERGY := 2.5
const CHEVRON_ENERGY := 1.6
const BEACON_LIGHT := 2.2
const BEACON_PERIOD := 1.6  # seconds per pulse (well below photosensitivity limits)
const POWER_STEP := 0.32  # delay between fixtures coming online
## Failing fixture pattern: alternating on/off durations in seconds (deterministic, never faster than 4 Hz).
const FLICKER_PATTERN := [2.6, 0.12, 0.3, 0.15, 3.4, 0.25, 1.1, 0.12, 0.18, 0.4]

var mats = null  # FacilityMaterials, set by the dressing
var room: Node3D = null
var powered: bool = false

var _emergency: Array[OmniLight3D] = []
var _circuit: Array[Dictionary] = []  # {light, energy}
var _flicker_light: OmniLight3D = null
var _flicker_on: bool = true
var _flicker_index: int = 0
var _flicker_left: float = 0.0
var _beacon: OmniLight3D = null
var _t: float = 0.0
var _tweens: Array = []
var _door_lamps: Array = []  # {door, mat}: compact lock-state lamps on both faces of each door lintel


func _ready() -> void:
	name = "PowerRig"
	# Emergency circuit (always on).
	_emergency.append(_light("EmergencyAccess", Vector3(-10.0, 2.3, -6.4), COLD, 1.9, 8.0))
	_emergency.append(_light("EmergencyHallWest", Vector3(-5.35, 2.3, -6.4), COLD, 1.7, 8.0))
	_emergency.append(_light("EmergencyHallEast", Vector3(2.75, 2.3, -6.4), COLD, 1.5, 7.5))
	_emergency.append(_light("Heater", Vector3(-0.4, 1.7, 0.0), WARM, 2.2, 3.6))
	_emergency.append(_light("AccessFill", Vector3(-9.5, 3.4, 3.5), COLD, 0.35, 8.0))
	_emergency.append(_light("HallFill", Vector3(-2.5, 3.6, 4.5), COLD, 0.3, 9.0))
	_flicker_light = _light("FailingFixture", Vector3(-3.45, 2.3, -6.4), COLD, 1.1, 6.0)
	_beacon = _light("GeneratorBeacon", Vector3(5.55, 2.9, -7.0), RED, BEACON_LIGHT, 6.5)
	_light("GeneratorBaySpill", Vector3(6.2, 2.6, 1.5), RED, 0.35, 7.0)
	# Generator circuit, in the order it comes online.
	_circuit.append({"light": _light("PowerGenerator", Vector3(7.6, 2.3, -6.4), COLD, 0.0, 7.0), "energy": 1.4})
	_circuit.append({"light": _light("PowerBayFront", Vector3(5.9, 2.5, -3.6), COLD, 0.0, 7.0), "energy": 1.25})
	_circuit.append({"light": _light("PowerAirlock", Vector3(10.3, 2.3, -6.4), COLD, 0.0, 7.0), "energy": 1.3})
	_circuit.append({"light": _light("PowerGate", Vector3(11.0, 2.4, 0.0), GREEN, 0.0, 4.0), "energy": 0.9})
	_apply_materials(0.0)
	for key in ["door_a", "door"]:
		var d = room.get(key) if room != null else null
		if d != null:
			_door_lamps.append({"door": d, "mat": _door_lamp(d as Node3D)})
	var lever = room.get("lever") if room != null else null
	if lever != null:
		lever.toggled.connect(_on_lever_toggled)
		if bool(lever.get("is_on")):
			set_powered(true, false)


func _light(light_name: String, pos: Vector3, color: Color, energy: float, light_range: float) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.name = light_name
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = light_range
	l.omni_attenuation = 1.4
	l.shadow_enabled = false
	l.light_specular = 0.6
	add_child(l)
	return l


## Lock-state lamps on both lintel faces of a bulkhead door (red = locked, green = unlocked or open).
## Shape also changes (short bar when locked, full-width bar when unlocked) so state is not conveyed by colour alone.
func _door_lamp(door: Node3D) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.emission_enabled = true
	m.albedo_color = Color(0.1, 0.02, 0.02)
	m.emission = RED
	m.emission_energy_multiplier = 2.2
	for side in [-1.0, 1.0]:
		var lamp := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.03, 0.08, 1.0)
		lamp.mesh = mesh
		lamp.material_override = m
		lamp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		lamp.position = door.position + Vector3(side * 0.44, 2.9, 0.0)
		lamp.name = "DoorLamp"
		add_child(lamp)
	return m


func _update_door_lamps() -> void:
	for entry in _door_lamps:
		var d = entry["door"]
		if not is_instance_valid(d):
			continue
		var open_or_free: bool = bool(d.get("is_open")) or not bool(d.get("locked"))
		var m := entry["mat"] as StandardMaterial3D
		m.emission = GREEN if open_or_free else RED
		m.albedo_color = Color(0.02, 0.1, 0.04) if open_or_free else Color(0.1, 0.02, 0.02)
		for lamp in get_children():
			if lamp is MeshInstance3D and lamp.material_override == m:
				(lamp.mesh as BoxMesh).size.z = 2.4 if open_or_free else 0.7


func _on_lever_toggled(on: bool) -> void:
	set_powered(on, true)


func set_powered(on: bool, animate: bool) -> void:
	if on == powered and animate:
		return
	powered = on
	for t in _tweens:
		(t as Tween).kill()
	_tweens.clear()
	var reduced := AccessibilityManager.is_reduced_motion()
	if not animate:
		for entry in _circuit:
			(entry["light"] as OmniLight3D).light_energy = float(entry["energy"]) if on else 0.0
		_apply_materials(1.0 if on else 0.0)
		power_changed.emit(on)
		return
	var main := create_tween()
	_tweens.append(main)
	if on:
		main.tween_method(_apply_materials, 0.0, 1.0, 1.4).set_delay(0.15)
		for i in _circuit.size():
			var entry: Dictionary = _circuit[i]
			var l := entry["light"] as OmniLight3D
			var full := float(entry["energy"])
			var seq := create_tween()
			_tweens.append(seq)
			seq.tween_interval(0.25 + POWER_STEP * i)
			if reduced:
				seq.tween_property(l, "light_energy", full, 0.5)
			else:
				# Fluorescent strike: two short blinks, then steady.
				seq.tween_property(l, "light_energy", full, 0.04)
				seq.tween_property(l, "light_energy", 0.0, 0.07)
				seq.tween_interval(0.09)
				seq.tween_property(l, "light_energy", full * 0.6, 0.04)
				seq.tween_property(l, "light_energy", 0.0, 0.06)
				seq.tween_interval(0.05)
				seq.tween_property(l, "light_energy", full, 0.12)
	else:
		main.tween_method(_apply_materials, 1.0, 0.0, 0.6)
		for entry in _circuit:
			main.parallel().tween_property(entry["light"], "light_energy", 0.0, 0.45)
	power_changed.emit(on)


## k = 0 (emergency only) .. 1 (generator circuit fully online).
func _apply_materials(k: float) -> void:
	if mats == null:
		return
	(mats.get_material("lamp_power") as StandardMaterial3D).emission_energy_multiplier = LAMP_ENERGY * k
	(mats.get_material("lamp_power") as StandardMaterial3D).albedo_color = Color(0.12, 0.13, 0.14).lerp(Color(0.6, 0.65, 0.7), k)
	(mats.get_material("gen_vent") as StandardMaterial3D).emission_energy_multiplier = VENT_ENERGY * k
	(mats.get_material("chevron") as StandardMaterial3D).emission_energy_multiplier = CHEVRON_ENERGY * k
	var status := mats.get_material("status_power") as StandardMaterial3D
	status.emission = RED.lerp(GREEN, k)
	status.albedo_color = Color(0.1, 0.02, 0.02).lerp(Color(0.02, 0.1, 0.04), k)


func _process(delta: float) -> void:
	_t += delta
	var reduced := AccessibilityManager.is_reduced_motion()
	# Beacon pulses only while the bay is unpowered.
	var beacon_mat := mats.get_material("beacon_red") as StandardMaterial3D if mats != null else null
	if powered:
		_beacon.light_energy = move_toward(_beacon.light_energy, 0.0, delta * 3.0)
		if beacon_mat != null:
			beacon_mat.emission_energy_multiplier = move_toward(beacon_mat.emission_energy_multiplier, 0.4, delta * 6.0)
	else:
		var pulse := 0.75 if reduced else 0.5 + 0.5 * sin(_t * TAU / BEACON_PERIOD)
		_beacon.light_energy = BEACON_LIGHT * (0.25 + 0.75 * pulse)
		if beacon_mat != null:
			beacon_mat.emission_energy_multiplier = 1.0 + 4.0 * pulse
	_update_flicker(delta, reduced)
	_update_door_lamps()


func _update_flicker(delta: float, reduced: bool) -> void:
	var flicker_mat := mats.get_material("lamp_flicker") as StandardMaterial3D if mats != null else null
	if reduced:
		_flicker_light.light_energy = 0.8
		if flicker_mat != null:
			flicker_mat.emission_energy_multiplier = 2.0
		return
	_flicker_left -= delta
	if _flicker_left <= 0.0:
		_flicker_on = not _flicker_on
		_flicker_index = (_flicker_index + 1) % FLICKER_PATTERN.size()
		_flicker_left = float(FLICKER_PATTERN[_flicker_index])
	_flicker_light.light_energy = 1.1 if _flicker_on else 0.08
	if flicker_mat != null:
		flicker_mat.emission_energy_multiplier = 3.0 if _flicker_on else 0.15
