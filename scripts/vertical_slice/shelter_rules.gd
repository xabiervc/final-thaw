extends RefCounted

signal power_activated
signal valves_opened
signal civilian_rescued
signal oxygen_depleted
signal state_reset

var power_on: bool = false
var valves_open: bool = false
var rescued: bool = false
var oxygen: float = 30.0
var oxygen_max: float = 30.0

func restore(power: bool, valves: bool, civilian_rescued: bool) -> void:
	power_on = power
	valves_open = valves
	rescued = civilian_rescued

func reset() -> void:
	power_on = false
	valves_open = false
	rescued = false
	oxygen = oxygen_max
	state_reset.emit()

func activate_power() -> bool:
	if power_on:
		return false
	power_on = true
	power_activated.emit()
	return true

func open_valves() -> bool:
	if not power_on or valves_open:
		return false
	valves_open = true
	valves_opened.emit()
	return true

func drain_oxygen(delta: float) -> bool:
	if not valves_open:
		return false
	oxygen = maxf(0.0, oxygen - maxf(0.0, delta))
	if oxygen <= 0.0:
		oxygen_depleted.emit()
		return true
	return false

func rescue() -> bool:
	if not valves_open or rescued or oxygen <= 0.0:
		return false
	rescued = true
	civilian_rescued.emit()
	return true

func can_exit() -> bool:
	return valves_open and oxygen > 0.0

func oxygen_state() -> String:
	var ratio := oxygen / maxf(0.001, oxygen_max)
	if ratio <= 0.2:
		return "critical"
	if ratio <= 0.4:
		return "warning"
	return "normal"
