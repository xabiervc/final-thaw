extends RefCounted

const MAX_VALUE := 100.0
const JUMP_COST := 12.0

var stamina: float = 100.0
var oxygen: float = 100.0
var temperature: float = 100.0
var load_factor: float = 0.0
var recovery_bonus: float = 0.0

func state_name() -> String:
	if stamina >= 70.0:
		return "estable"
	if stamina >= 35.0:
		return "fatiga"
	if stamina > 0.0:
		return "exhausta"
	return "critica"

func speed_multiplier() -> float:
	var m := 1.0
	match state_name():
		"fatiga":
			m = 0.9
		"exhausta":
			m = 0.75
		"critica":
			m = 0.6
	if oxygen < 30.0:
		m *= 0.85
	if temperature < 40.0:
		m *= 0.9
	m *= 1.0 - 0.10 * clampf(load_factor, 0.0, 1.0)
	return m

func jump_multiplier() -> float:
	var m := 1.0
	match state_name():
		"fatiga":
			m = 0.9
		"exhausta":
			m = 0.65
		"critica":
			m = 0.5
	if oxygen < 30.0:
		m *= 0.8
	if temperature < 40.0:
		m *= 0.9
	m *= 1.0 - 0.15 * clampf(load_factor, 0.0, 1.0)
	return m

func spend(amount: float) -> void:
	stamina = maxf(0.0, stamina - amount)

func tick(delta: float, moving: bool, on_floor: bool) -> void:
	if not on_floor:
		return
	var rate := 10.0
	if moving:
		rate = 5.0
	if temperature < 40.0:
		rate *= 0.5
	stamina = minf(MAX_VALUE, stamina + (rate + recovery_bonus) * delta)

func to_dict() -> Dictionary:
	return {
		"stamina": stamina,
		"oxygen": oxygen,
		"temperature": temperature,
	}

func from_dict(d: Dictionary) -> void:
	stamina = clampf(float(d.get("stamina", MAX_VALUE)), 0.0, MAX_VALUE)
	oxygen = clampf(float(d.get("oxygen", MAX_VALUE)), 0.0, MAX_VALUE)
	temperature = clampf(float(d.get("temperature", MAX_VALUE)), 0.0, MAX_VALUE)
