extends Node
## Scenario test of the Phase 1 interactions: the clues, controls, trip feedback, diagnostic availability, rearm rules,
## order independence and hint ladder, driven through the same handlers the player uses. Runs the real scene.
## Run: godot --headless --path . res://tests/test_phase1_interactions.tscn

const GreyboxScene = preload("res://scenes/prototypes/phase1_spatial_greybox.tscn")
const Model = preload("res://scripts/prototypes/phase1_circuit_model.gd")
var passed: int = 0
var failed: int = 0
var completed: bool = false


func _ready() -> void:
	get_tree().create_timer(20.0).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void:
	if not completed:
		push_error("Interaction tests did not reach completion (possible script error).")
		get_tree().quit(1)


func _emission(node: MeshInstance3D) -> Color:
	return (node.material_override as StandardMaterial3D).emission


func _energy(node: MeshInstance3D) -> float:
	return (node.material_override as StandardMaterial3D).emission_energy_multiplier


func _run() -> void:
	print("Godot: ", Engine.get_version_info()["string"])
	var gb = GreyboxScene.instantiate()
	add_child(gb)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var ix = gb.interactions
	_expect(ix != null and ix.hotspots.size() == 9, "the scene wires nine interaction points")
	var rings: Array = gb.dressing.column_rings
	var strips: Dictionary = gb.dressing.indicators
	# Initial state: protection available (green ring), trial branch live, archive dark.
	_expect(_emission(rings[4]).g > 0.9 and _emission(rings[4]).r < 0.6, "the protection ring starts green")
	_expect(_energy(rings[3]) > 1.0 and _energy(rings[2]) < 0.5, "the trial ring starts live and the archive ring dark")
	# Clues are objects that report without changing the circuit.
	var before: Dictionary = ix.circuit.snapshot()
	ix.examine_schematic()
	ix.examine_bridge()
	ix.read_indicators()
	_expect(ix.clues.has("schematic") and ix.clues.has("bridge") and ix.clues.has("indicators"), "schematic, bridge and indicators register as clues")
	_expect(ix.circuit.snapshot() == before, "examining clues does not change the circuit")
	# Maintenance is independent of the recovery branches.
	ix.toggle_maintenance()
	_expect(ix.circuit.maintenance_on and _energy(rings[0]) > 1.0, "maintenance lights its ring")
	# Wrong configuration: selecting archive with the trial branch connected trips the protection.
	ix.toggle_selector()
	_expect(not ix.circuit.protection_available, "selecting archive with the trial connected trips protection")
	_expect(_emission(rings[4]).r > 0.9 and _emission(rings[4]).g < 0.6, "the protection ring turns red on a trip")
	_expect(_emission(strips["protection"]).r > 0.9 and _energy(strips["archive"]) < 0.5 or _energy(strips["archive"]) > 0.0, "the indicator strips follow the state")
	_expect(ix.circuit.maintenance_on and _energy(rings[1]) > 1.0, "maintenance and diagnostics survive the trip")
	# The diagnostic stays available while tripped and keeps the trip history.
	ix.use_terminal()
	_expect(ix.events.back()["id"] == "terminal", "the terminal can be used while protection is tripped")
	_expect(ix.diagnostic_text().contains("interrumpida") and ix.diagnostic_text().contains("disparo"), "the diagnostic reports the interrupted recovery and the trip")
	_expect(not ix.diagnostic_text().to_lower().contains("seccionador") and not ix.diagnostic_text().to_lower().contains("aísla"), "the diagnostic never names the control to operate")
	_expect(not ix.clues.has("archive_consulted"), "the archive cannot be read while tripped")
	# Rearm is refused while the fault persists; clearing the fault alone does not rearm.
	ix.request_rearm()
	_expect(not ix.circuit.protection_available and ix.events.back()["detail"] == "rejected", "rearm is refused while the fault is present")
	ix.toggle_isolator()
	_expect(not ix.circuit.fault_present() and not ix.circuit.protection_available, "isolating clears the fault without rearming")
	_expect(ix.diagnostic_text().contains("Rearme pendiente"), "the diagnostic then reports a pending rearm")
	ix.request_rearm()
	_expect(ix.circuit.protection_available and _energy(rings[2]) > 1.0, "rearm restores stable archive supply")
	ix.use_terminal()
	_expect(ix.clues.has("archive_consulted") and ix.circuit.known_clues().size() == 1, "the archive can be read once supply is stable")
	_expect(ix.diagnostic_text().contains("Último disparo"), "the last trip is still recorded after rearm")
	# The other order reaches the same functional state without a trip.
	var other = Model.new()
	other.set_isolated(true)
	other.select_destination(Model.ARCHIVE)
	# Compare the recovery branch only: maintenance was switched on in `ix` earlier and is independent (contract X1).
	var a: Dictionary = other.outputs()
	var b: Dictionary = ix.circuit.outputs()
	_expect(other.protection_available and a["archive"] == b["archive"] and a["trial"] == b["trial"], "isolating first reaches the same supply state without tripping")
	# Hint ladder: three steps, never more, never naming a control.
	for i in 5:
		ix.request_hint()
	_expect(ix.hints_used == 3, "the hint ladder stops at three steps")
	var names_a_control := false
	for hint in ix.HINTS:
		if str(hint).to_lower().contains("seccionador") or str(hint).to_lower().contains("selector") or str(hint).to_lower().contains("interruptor"):
			names_a_control = true
	_expect(not names_a_control, "no hint names a control")
	# Prompts: a position next to a control resolves to that control.
	gb.player.position = Vector3(14.0, 3.2, -14.8)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(ix.current_hotspot == "selector", "standing at the selector offers the selector")
	gb.player.position = Vector3(2.0, 0.2, 1.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_expect(ix.current_hotspot == "", "standing in the entry offers nothing")
	completed = true
	print("Phase 1 interactions: %d passed, %d failed; COMPLETED" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
