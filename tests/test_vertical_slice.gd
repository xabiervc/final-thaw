extends Node

const Rules = preload("res://scripts/vertical_slice/shelter_rules.gd")
var failed: int = 0

func _ready() -> void:
	_check_rules()
	_check_rescue_persistence()
	print("Vertical slice rules: %s" % ("PASS" if failed == 0 else "FAIL (%d)" % failed))
	get_tree().quit(1 if failed > 0 else 0)

func _expect(condition: bool, label: String) -> void:
	if not condition:
		failed += 1
		push_error("FAIL: " + label)
	else:
		print("PASS: ", label)

func _check_rules() -> void:
	var rules = Rules.new()
	_expect(not rules.open_valves(), "No valves before power")
	_expect(not rules.rescue(), "No rescue before access")
	_expect(not rules.can_exit(), "Exit blocked before valves")
	_expect(rules.activate_power(), "Power switches on")
	_expect(not rules.activate_power(), "Power is idempotent")
	_expect(rules.open_valves(), "Valves open after power")
	_expect(rules.can_exit(), "Exit available after valves")
	_expect(rules.rescue(), "Rescue works once")
	_expect(not rules.rescue(), "Rescue cannot be repeated")
	rules.drain_oxygen(30.0)
	_expect(rules.oxygen == 0.0 and not rules.can_exit(), "Oxygen expires and blocks exit")
	rules.reset()
	_expect(rules.oxygen == rules.oxygen_max and not rules.power_on and not rules.rescued, "Retry resets room")

func _check_rescue_persistence() -> void:
	var previous: int = GameManager.civilian_aid
	GameManager.civilian_aid = 2
	var saved: bool = GameManager.save_game(99)
	GameManager.civilian_aid = 0
	var loaded: bool = GameManager.load_game(99)
	_expect(saved and loaded and GameManager.civilian_aid == 2, "Civilian aid survives save/load")
	GameManager.civilian_aid = previous
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.save_path(99)))
