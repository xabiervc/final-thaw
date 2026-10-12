extends Node

const RulesScript = preload("res://scripts/vertical_slice/first_room_rules.gd")
var failed := 0

func _ready() -> void:
	var rules = RulesScript.new()
	_expect(not rules.can_open_exit(), "Exit starts locked")
	_expect(rules.activate_power(), "Console restores power once")
	_expect(rules.can_open_exit(), "Restored power unlocks exit")
	_expect(not rules.activate_power(), "Repeated activation is safe")
	rules.reset()
	_expect(not rules.power_restored and not rules.can_open_exit(), "Room reset relocks exit")
	print("First room rules: %s" % ("PASS" if failed == 0 else "FAIL (%d)" % failed))
	get_tree().quit(1 if failed > 0 else 0)

func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
