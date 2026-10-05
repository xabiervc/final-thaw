extends RefCounted

var power_on: bool = false
var valves_open: bool = false
var rescued: bool = false
var oxygen: float = 30.0
var oxygen_max: float = 30.0

func reset() -> void:
	power_on = false
	valves_open = false
	rescued = false
	oxygen = oxygen_max

func activate_power() -> bool:
	if power_on:
		return false
	power_on = true
	return true

func open_valves() -> bool:
	if not power_on or valves_open:
		return false
	valves_open = true
	return true

func drain_oxygen(delta: float) -> bool:
	if not valves_open:
		return false
	oxygen = maxf(0.0, oxygen - maxf(0.0, delta))
	return oxygen <= 0.0

func rescue() -> bool:
	if not valves_open or rescued or oxygen <= 0.0:
		return false
	rescued = true
	return true

func can_exit() -> bool:
	return valves_open and oxygen > 0.0
