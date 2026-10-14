extends Node2D

const Rules = preload("res://scripts/vertical_slice/shelter_rules.gd")
const PlayerScript = preload("res://scripts/entities/player.gd")

const BG := Color("182b39")
const WATER := Color("245975")
const LOCKED := Color("70505a")
const ACTIVE := Color("48ad99")
const HIGHLIGHT := Color("8ef7e4")
const TEXT := Color("eff4ee")
const OXYGEN_NORMAL := Color("eff4ee")
const OXYGEN_WARNING := Color("f2c14e")
const OXYGEN_CRITICAL := Color("f26d5b")
const HC_BG := Color("000000")
const HC_WATER := Color("003b5c")
const HC_LOCKED := Color("5a5a5a")
const HC_ACTIVE := Color("00e5a0")
const HC_HIGHLIGHT := Color("ffffff")
const HC_TEXT := Color("ffffff")
const HC_OXYGEN_NORMAL := Color("ffffff")
const HC_OXYGEN_WARNING := Color("ffd400")
const HC_OXYGEN_CRITICAL := Color("ff5252")
const MENU_PATH := "res://scenes/ui/main_menu.tscn"
const PLAYER_START := Vector2(125, 390)
const WORLD_MIN := Vector2(80, 130)
const WORLD_MAX := Vector2(2020, 640)
const INTERACT_RANGE := 110.0
const NARRATIVE_GRACE_SECONDS := 0.35

var rules = Rules.new()
var player: CharacterBody2D
var hud: Label
var hint: Label
var result: Label
var objects: Array[Area2D] = []
var interactables: Dictionary = {}
var highlighted_kind: String = ""
var ended: bool = false
var narrative_grace_left: float = 0.0

func _ready() -> void:
	add_to_group("vertical_slice")
	_restore_persistent_shelter_state()

	var floor_rect := ColorRect.new()
	floor_rect.color = BG
	floor_rect.size = Vector2(2100, 800)
	add_child(floor_rect)

	for n in 3:
		var room := ColorRect.new()
		room.color = WATER if n > 0 else Color("30465a")
		room.position = Vector2(70 + n * 650, 110)
		room.size = Vector2(600, 550)
		add_child(room)

	_create_interactable("POWER", Vector2(280, 390))
	_create_interactable("VALVES", Vector2(930, 390))
	_create_interactable("CIVILIAN", Vector2(1510, 390))
	_create_interactable("EXIT", Vector2(1840, 390))

	player = PlayerScript.new()
	player.position = PLAYER_START
	add_child(player)

	var camera := Camera2D.new()
	player.add_child(camera)
	camera.make_current()

	var ui := CanvasLayer.new()
	add_child(ui)
	hud = _label(ui, Vector2(24, 20), "")
	hint = _label(ui, Vector2(24, 56), "")
	result = _label(ui, Vector2(230, 245), "")
	result.visible = false

	rules.power_activated.connect(_on_rules_changed)
	rules.valves_opened.connect(_on_rules_changed)
	rules.civilian_rescued.connect(_on_rules_changed)
	rules.oxygen_depleted.connect(_on_oxygen_empty)
	rules.state_reset.connect(_on_rules_changed)

	var narrative_panel := get_tree().get_first_node_in_group("narrative_panel")
	if narrative_panel != null and narrative_panel.has_signal("narrative_dismissed"):
		narrative_panel.narrative_dismissed.connect(_on_narrative_dismissed)

	GameManager.stats_changed.connect(_on_accessibility_changed)
	_update_interactable_visuals()
	_update_ui(NarrativeTextManager.get_shelter_intro())

func _restore_persistent_shelter_state() -> void:
	var power := GameStateManager.get_flag("shelter_power_restored")
	var valves := GameStateManager.get_flag("shelter_valves_opened")
	var rescued := GameStateManager.get_flag("shelter_civilian_rescued")
	rules.restore(power, valves, rescued)

func _create_interactable(kind: String, location: Vector2) -> void:
	var area := Area2D.new()
	area.position = location
	area.set_meta("kind", kind)
	area.add_to_group("shelter_interactable")
	area.add_to_group("interactable")
	area.monitorable = true

	var shape_node := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(90, 90)
	shape_node.shape = shape
	area.add_child(shape_node)

	var graphic := ColorRect.new()
	graphic.color = LOCKED
	graphic.position = Vector2(-45, -45)
	graphic.size = Vector2(90, 90)
	area.add_child(graphic)

	var label := Label.new()
	label.text = kind
	label.position = Vector2(-44, -82)
	label.add_theme_color_override("font_color", TEXT)
	area.add_child(label)

	add_child(area)
	objects.append(area)
	interactables[kind] = {"area": area, "graphic": graphic, "label": label}

func _label(parent: Node, pos: Vector2, value: String) -> Label:
	var label := Label.new()
	label.position = pos
	label.text = value
	label.add_theme_color_override("font_color", TEXT)
	label.add_theme_font_size_override("font_size", int(20.0 * AccessibilityManager.ui_scale()))
	parent.add_child(label)
	return label

func _process(delta: float) -> void:
	if ended:
		return

	player.position = player.position.clamp(WORLD_MIN, WORLD_MAX)
	if narrative_grace_left > 0.0:
		narrative_grace_left = maxf(0.0, narrative_grace_left - delta)
	_update_highlight()

	if rules.valves_open:
		if rules.drain_oxygen(delta):
			return
		_update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().change_scene_to_file(MENU_PATH)
		return

	if ended:
		if event.is_action_pressed("interact"):
			get_tree().change_scene_to_file(MENU_PATH)
		return

	if event.is_action_pressed("scan"):
		_update_ui(NarrativeTextManager.get_shelter_scan())
	elif event.is_action_pressed("interact"):
		if narrative_grace_left > 0.0:
			return
		var target := _closest_object()
		if target != null:
			_interact_with(str(target.get_meta("kind")))

func _closest_object() -> Area2D:
	var sensor_target := player.get_nearest_interactable()
	if sensor_target != null:
		return sensor_target

	# Compatibility fallback for headless tests and dynamically built scenes.
	var best: Area2D = null
	var distance := INTERACT_RANGE
	for item in objects:
		var candidate: float = player.global_position.distance_to(item.global_position)
		if candidate < distance:
			distance = candidate
			best = item
	return best

func _update_highlight() -> void:
	var target := _closest_object()
	var next_kind := "" if target == null else str(target.get_meta("kind"))

	if next_kind == highlighted_kind:
		return

	highlighted_kind = next_kind
	_update_interactable_visuals()
	_update_ui()

func _interact_with(kind: String) -> void:
	match kind:
		"POWER":
			if rules.activate_power():
				GameStateManager.set_flag("shelter_power_restored", true)
				_update_ui(NarrativeTextManager.get_shelter_power_restored())
			else:
				_update_ui(NarrativeTextManager.get_shelter_power_already_on())
		"VALVES":
			if rules.open_valves():
				GameStateManager.set_flag("shelter_valves_opened", true)
				_update_ui(NarrativeTextManager.get_shelter_valves_opened())
			else:
				_update_ui(NarrativeTextManager.get_shelter_valves_need_power())
		"CIVILIAN":
			if rules.rescue():
				GameStateManager.set_flag("shelter_civilian_rescued", true)
				GameManager.civilian_aid = mini(10, GameManager.civilian_aid + 1)
				GameManager.stats_changed.emit()
				GameManager.save_game(0)
				_update_ui(NarrativeTextManager.get_shelter_civilian_rescued())
			else:
				_update_ui(NarrativeTextManager.get_shelter_civilian_blocked())
		"EXIT":
			if rules.can_exit():
				_finish(NarrativeTextManager.get_shelter_exit_title(rules.rescued, GameManager.civilian_aid))
			else:
				_update_ui(NarrativeTextManager.get_shelter_exit_blocked())

func _on_rules_changed() -> void:
	_update_interactable_visuals()
	_update_ui()

func _on_oxygen_empty() -> void:
	player.position = PLAYER_START
	rules.reset()
	GameStateManager.set_flag("shelter_power_restored", false)
	GameStateManager.set_flag("shelter_valves_opened", false)
	_update_interactable_visuals()
	_update_ui(NarrativeTextManager.get_shelter_oxygen_empty())

func _on_narrative_dismissed() -> void:
	narrative_grace_left = NARRATIVE_GRACE_SECONDS
	_update_interactable_visuals()

func _on_accessibility_changed() -> void:
	_update_interactable_visuals()
	_update_ui()

func _update_interactable_visuals() -> void:
	var high_contrast := AccessibilityManager.is_high_contrast()
	var locked := HC_LOCKED if high_contrast else LOCKED
	var active := HC_ACTIVE if high_contrast else ACTIVE
	var highlight := HC_HIGHLIGHT if high_contrast else HIGHLIGHT
	var text := HC_TEXT if high_contrast else TEXT

	for kind in interactables:
		var data: Dictionary = interactables[kind]
		var graphic: ColorRect = data["graphic"]
		var label: Label = data["label"]
		var is_active := _is_interactable_active(kind)
		graphic.color = active if is_active else locked
		graphic.self_modulate = highlight if kind == highlighted_kind else Color.WHITE
		label.add_theme_color_override("font_color", text)
		label.text = _interactable_prompt(kind)

func _is_interactable_active(kind: String) -> bool:
	match kind:
		"POWER":
			return rules.power_on
		"VALVES":
			return rules.valves_open
		"CIVILIAN":
			return rules.rescued
		"EXIT":
			return rules.can_exit()
	return false

func _interactable_prompt(kind: String) -> String:
	match kind:
		"POWER":
			return NarrativeTextManager.get_interact_power_console(rules.power_on)
		"VALVES":
			return NarrativeTextManager.get_interact_valve(rules.valves_open)
		"CIVILIAN":
			return NarrativeTextManager.get_interact_civilian(not rules.rescued)
		"EXIT":
			return NarrativeTextManager.get_shelter_exit_prompt(rules.can_exit())
	return kind

func _update_ui(message: String = "") -> void:
	var high_contrast := AccessibilityManager.is_high_contrast()
	hud.text = NarrativeTextManager.get_shelter_hud(
		rules.power_on,
		rules.valves_open,
		rules.oxygen,
		GameManager.civilian_aid
	)

	var oxygen_state := rules.oxygen_state()
	var oxygen_color := OXYGEN_NORMAL
	if oxygen_state == "warning":
		oxygen_color = OXYGEN_WARNING
	elif oxygen_state == "critical":
		oxygen_color = OXYGEN_CRITICAL

	if high_contrast:
		if oxygen_state == "warning":
			oxygen_color = HC_OXYGEN_WARNING
		elif oxygen_state == "critical":
			oxygen_color = HC_OXYGEN_CRITICAL
		else:
			oxygen_color = HC_OXYGEN_NORMAL

	hud.add_theme_color_override("font_color", oxygen_color)

	if not message.is_empty():
		hint.text = message
