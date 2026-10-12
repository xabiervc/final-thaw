extends RefCounted
class_name FirstRoomRules

var power_restored: bool = false

func activate_power() -> bool:
	if power_restored:
		return false
	power_restored = true
	return true

func can_open_exit() -> bool:
	return power_restored

func reset() -> void:
	power_restored = false
