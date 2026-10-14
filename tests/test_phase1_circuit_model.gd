extends Node
## Run this scene with F6 or godot --headless --path . res://tests/test_phase1_circuit_model.tscn.
## Pure model tests, not mission integration or playtest evidence.

const Model = preload("res://scripts/prototypes/phase1_circuit_model.gd")
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(10.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Circuit tests did not reach completion (possible script error).")
		get_tree().quit(1)


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var s = Model.new()
	_expect(not s.maintenance_on and s.destination == Model.TRIAL and not s.trial_isolated and s.protection_available and s.last_trip == "", "T1 initial state")
	_expect(s.outputs() == {"diagnostic": true, "maintenance": false, "archive": false, "trial": true, "machine_running": false}, "T1 initial outputs")
	_expect(s.inspect()["current"] == "ARCHIVE_UNPOWERED" and s.inspect()["destination"] == Model.TRIAL, "T1 archive off is a state, not a malfunction")
	# T2: all observable trip effects in the same test, with maintenance enabled.
	s.set_maintenance(true)
	s.select_destination(Model.ARCHIVE)
	var out: Dictionary = s.outputs()
	_expect(not s.protection_available and not out["archive"] and not out["trial"] and out["diagnostic"] and out["maintenance"] and not out["machine_running"] and s.last_trip == Model.TRIP_CAUSE, "T2 atomic trip effects: recovery off; maintenance/diagnostics intact; cause recorded; start interlocked")
	_expect(s.inspect()["current"] == "RECOVERY_TRIPPED_FAULT_PRESENT", "T2 current fault diagnostic")
	s.set_isolated(true)
	_expect(not s.fault_present() and not s.protection_available and not s.outputs()["archive"], "T3 clearing fault does not rearm")
	_expect(s.inspect()["current"] == "RECOVERY_TRIPPED_REARM_PENDING" and s.inspect()["last_trip"] == Model.TRIP_CAUSE, "T3 current state and trip cause separate")
	_expect(s.rearm() and s.outputs()["archive"], "T4 explicit rearm restores stable archive")
	_expect(s.inspect()["current"] == "ARCHIVE_STABLE" and s.inspect()["last_trip"] == Model.TRIP_CAUSE, "T4 stable diagnostic retains last trip")
	var t = Model.new()
	t.select_destination(Model.ARCHIVE)
	var before: Dictionary = t.snapshot()
	_expect(not t.rearm() and t.snapshot() == before, "T5 invalid rearm preserves positions and history")
	var u = Model.new()
	u.set_isolated(true)
	u.select_destination(Model.ARCHIVE)
	_expect(u.protection_available and u.outputs()["archive"] and u.last_trip == "", "T6 isolate-first order does not trip")
	u.select_destination(Model.TRIAL)
	_expect(not u.outputs()["archive"] and not u.outputs()["machine_running"], "T7 selecting trial cuts archive without starting machinery")
	u.set_isolated(false)
	_expect(u.outputs()["trial"] and not u.outputs()["machine_running"], "T7 trial supply is not machine start")
	s.set_maintenance(false)
	_expect(not s.outputs()["maintenance"] and s.outputs()["archive"] and s.outputs()["diagnostic"], "T8 maintenance independent")
	before = s.snapshot()
	for i in 10:
		s.set_isolated(true)
		s.select_destination(Model.ARCHIVE)
		s.set_maintenance(false)
		_expect(s.rearm() and s.snapshot() == before, "T9 repeated valid actions %d" % i)
	var v = Model.new()
	v.set_isolated(true)
	v.select_destination(Model.ARCHIVE)
	_expect(s.outputs() == v.outputs() and s.destination == v.destination and s.trial_isolated == v.trial_isolated and s.protection_available == v.protection_available, "X1 both orders have same functional endpoint")
	_expect(s.last_trip != v.last_trip, "X1 histories intentionally differ")
	for tripped in [false, true]:
		var w = Model.new()
		if tripped:
			w.select_destination(Model.ARCHIVE)
		before = w.snapshot()
		for i in 10:
			w.set_maintenance(false)
			w.set_isolated(false)
			w.select_destination(w.destination)
			_expect(w.rearm() == (not tripped) and w.snapshot() == before, "X2 idempotence tripped=%s iteration=%d" % [tripped, i])
	for isolated in [false, true]:
		var w = Model.new()
		w.destination = Model.ARCHIVE
		w.trial_isolated = isolated
		_expect(not w.outputs()["trial"], "Explicit selector dependence, including synthetic state")
	v.set_isolated(false)
	_expect(not v.protection_available and v.last_trip == Model.TRIP_CAUSE, "Reconnecting trial while archive selected trips")
	_expect(s.consult(), "Stable archive permits consultation")
	var known: Array = s.known_clues()
	s.select_destination(Model.TRIAL)
	_expect(not s.consult() and s.known_clues() == known, "Interrupted consultation preserves acquired knowledge")
	_expect(s.inspect()["last_trip"] == Model.TRIP_CAUSE, "Current diagnostic never hides trip history")
	s.select_destination(Model.ARCHIVE)
	_expect(s.consult() and s.known_clues() == known, "Resumed consultation does not duplicate clues")
	before = s.snapshot()
	_expect(not s.select_destination("INVALID") and s.snapshot() == before, "Invalid destination rejected without mutation")
	completed = true
	print("Phase 1 circuit: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
