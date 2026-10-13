extends CanvasLayer

var aid_label: Label
var integrity_label: Label
var safety_label: Label
var character_label: Label
var fps_label: Label
var stamina_fill: ColorRect

func _ready() -> void:
	layer = 10
	add_to_group("hud")
	var box := HBoxContainer.new()
	box.position = Vector2(20, 20)
	box.add_theme_constant_override("separation", 24)
	add_child(box)
	aid_label = _label(box)
	integrity_label = _label(box)
	safety_label = _label(box)
	character_label = _label(self)
	character_label.position = Vector2(1100, 20)
	fps_label = _label(self)
	fps_label.position = Vector2(20, 680)
	_build_stamina_bar()
	GameManager.stats_changed.connect(refresh)
	refresh()
	_call_deferred("_connect_player")

func _build_stamina_bar() -> void:
	var background := ColorRect.new()
	background.color = Color(0, 0, 0, 0.55)
	background.position = Vector2(20, 70)
	background.size = Vector2(260, 18)
	add_child(background)
	stamina_fill = ColorRect.new()
	stamina_fill.color = Color(0.25, 0.85, 1.0)
	stamina_fill.position = Vector2(2, 2)
	stamina_fill.size = Vector2(256, 14)
	background.add_child(stamina_fill)

func _connect_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player: Node = players[0]
		if not player.stamina_changed.is_connected(_on_stamina_changed):
			player.stamina_changed.connect(_on_stamina_changed)
		_on_stamina_changed(player.stamina, player.max_stamina)

func _on_stamina_changed(value: float, maximum: float) -> void:
	var ratio := 0.0 if maximum <= 0.0 else clampf(value / maximum, 0.0, 1.0)
	stamina_fill.size.x = 256.0 * ratio
	stamina_fill.color = Color(0.25, 0.85, 1.0) if ratio > 0.25 else Color(1.0, 0.35, 0.25)

func _label(parent: Node) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", int(20 * GameManager.font_scale))
	parent.add_child(l)
	return l

func refresh() -> void:
	aid_label.text = "Ayuda civil %d/10" % GameManager.civilian_aid
	integrity_label.text = "Prototipo %d/3" % GameManager.prototype_integrity
	safety_label.text = "Elena %d/3" % GameManager.elena_safety

func set_character(character_name: String) -> void:
	character_label.text = character_name.to_upper()

func _process(_delta: float) -> void:
	fps_label.visible = DebugManager.show_fps
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
