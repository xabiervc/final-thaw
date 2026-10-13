extends Node
## Entrega B, paso 3: los componentes solo traducen interacciones a ControlRoomRules y a
## mensajes; no deciden la solucion.
## Ejecutar: godot --headless --path . res://tests/test_control_room_components.tscn
## Codigo de salida: 0 si todo pasa, 1 si algo falla.

const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")
const LogScript = preload("res://scripts/components/log_terminal.gd")
const BreakerScript = preload("res://scripts/components/breaker_panel.gd")


class PanelStub extends Node:
	var last_text := ""
	var last_duration := 0.0
	var messages: Array = []

	func _ready() -> void:
		add_to_group("narrative_panel")

	func show_message(text: String, duration: float = 8.0) -> void:
		last_text = text
		last_duration = duration
		messages.append(text)


var failed := 0
var passed := 0
## Interactable.show_message usa el PRIMER nodo del grupo narrative_panel, asi que
## todos los tests comparten un unico panel falso.
var panel_stub: PanelStub = null


func _ready() -> void:
	panel_stub = PanelStub.new()
	add_child(panel_stub)
	_test_breakers()
	_test_breaker_without_rules()
	_test_log_terminals()
	print("Control room components: %d passed, %d failed" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)


func _make_breaker(id: String, rules, clock_state: Dictionary):
	var panel = BreakerScript.new()
	panel.breaker_id = id
	panel.display_name = "Panel " + id
	panel.prompt_text = "Operate panel"
	panel.text_lamp = "TEXT_LAMP"
	panel.text_burned = "TEXT_BURNED"
	panel.text_pressure = "TEXT_PRESSURE"
	panel.text_cooldown = "TEXT_COOLDOWN"
	panel.rules = rules
	panel.clock = func() -> float: return clock_state["t"]
	add_child(panel)
	return panel


func _make_log(id: String, title: String, body: String, rules):
	var terminal = LogScript.new()
	terminal.log_id = id
	terminal.title_text = title
	terminal.body_text = body
	terminal.display_name = "Log " + id
	terminal.prompt_text = "Read log"
	terminal.rules = rules
	add_child(terminal)
	return terminal


func _test_breakers() -> void:
	var stub := panel_stub
	var rules = RulesScript.new()
	var clock := {"t": 0.0}
	var a = _make_breaker("A", rules, clock)
	var b = _make_breaker("B", rules, clock)
	var c = _make_breaker("C", rules, clock)
	var seen: Array = []
	for panel in [a, b, c]:
		panel.used.connect(func(id: String, result: Dictionary) -> void: seen.append([id, result["result"]]))

	_expect(a.get_prompt_line() == "[E] Operate panel - Panel A", "B3: the prompt names the breaker")

	a.interact(null)
	_expect(stub.last_text == "TEXT_LAMP", "B3: A shows its specific response")
	_expect(rules.lamp_lit and not rules.can_open_gate(), "B3: A lights the lamp and does not power the gate")
	_expect(a.lamp_is_on(), "B3: A turns its status lamp on")
	_expect(seen.back() == ["A", "lamp"], "B3: A reports its result")
	_expect(is_equal_approx(stub.last_duration, a.message_seconds), "B3: the response uses the configured duration")

	b.interact(null)
	_expect(stub.last_text == "TEXT_BURNED", "B3: B shows the burned-fuse response")
	_expect(seen.back() == ["B", "burned"] and not b.lamp_is_on(), "B3: B reports burned and keeps its lamp off")
	b.interact(null)
	_expect(stub.last_text == "TEXT_COOLDOWN", "B3: B shows the cooldown response while it is hot")
	_expect(seen.back() == ["B", "cooldown"] and rules.attempts_for("B") == 1, "B3: a blocked B is not counted as an attempt")
	clock["t"] = 4.0
	b.interact(null)
	_expect(stub.last_text == "TEXT_BURNED" and rules.attempts_for("B") == 2, "B3: B works again after 4 seconds")

	c.interact(null)
	_expect(stub.last_text == "TEXT_PRESSURE", "B3: C shows the pressure response")
	_expect(rules.can_open_gate() and c.lamp_is_on(), "B3: C powers the gate and lights its lamp")
	_expect(seen.back() == ["C", "pressure"], "B3: C reports its result")

	rules.reset()
	a.refresh_from_rules()
	c.refresh_from_rules()
	_expect(not a.lamp_is_on() and not c.lamp_is_on(), "B3: refresh_from_rules turns lamps off after a reset")
	rules.use_breaker("A", 0.0)
	rules.use_breaker("C", 0.0)
	a.refresh_from_rules()
	c.refresh_from_rules()
	_expect(a.lamp_is_on() and c.lamp_is_on(), "B3: refresh_from_rules restores lamps from the rules state")


func _test_breaker_without_rules() -> void:
	var stub := panel_stub
	var messages_before := stub.messages.size()
	var orphan = BreakerScript.new()
	orphan.breaker_id = "A"
	orphan.text_lamp = "SHOULD_NOT_APPEAR"
	add_child(orphan)
	var emitted := []
	orphan.used.connect(func(id: String, result: Dictionary) -> void: emitted.append(id))
	orphan.interact(null)
	_expect(emitted.is_empty() and stub.messages.size() == messages_before, "B3: a breaker without rules does nothing and does not fail")


func _test_log_terminals() -> void:
	var stub := panel_stub
	var rules = RulesScript.new()
	var first = _make_log(RulesScript.LOG_BEFORE, "Title 1", "Body 1", rules)
	var second = _make_log(RulesScript.LOG_AFTER, "Title 2", "Body 2", rules)
	var seen: Array = []
	for terminal in [first, second]:
		terminal.log_read.connect(func(id: String, first_time: bool) -> void: seen.append([id, first_time]))

	_expect(first.get_prompt_line() == "[E] Read log - Log " + RulesScript.LOG_BEFORE, "B3: the log prompt names the terminal")
	first.interact(null)
	_expect(stub.last_text == "Title 1\nBody 1", "B3: a log shows its title and body")
	_expect(is_equal_approx(stub.last_duration, first.show_seconds), "B3: a log uses the configured duration")
	_expect(rules.has_read_log(RulesScript.LOG_BEFORE) and first.accessed, "B3: reading a log registers it and marks the terminal")
	_expect(seen.back() == [RulesScript.LOG_BEFORE, true], "B3: the first read is reported as first")
	first.interact(null)
	_expect(seen.back() == [RulesScript.LOG_BEFORE, false] and stub.last_text == "Title 1\nBody 1", "B3: rereading shows the log again and is not counted twice")
	_expect(not rules.has_read_both_logs(), "B3: one log is not both")
	second.interact(null)
	_expect(rules.has_read_both_logs(), "B3: both logs read")
	_expect(not rules.can_open_gate() and rules.total_attempts() == 0, "B3: reading logs never changes solvability or attempts")

	var plain = _make_log("x", "", "Only body", rules)
	plain.interact(null)
	_expect(stub.last_text == "Only body", "B3: a log without title shows only its body")
	var detached = _make_log(RulesScript.LOG_BEFORE, "T", "B", null)
	detached.interact(null)
	_expect(stub.last_text == "T\nB", "B3: a log without rules still shows its text")


func _expect(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", label)
	else:
		failed += 1
		push_error("FAIL: " + label)
