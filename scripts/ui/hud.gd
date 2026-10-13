extends CanvasLayer

var aid_label: Label
var integrity_label: Label
var safety_label: Label
var character_label: Label
var fps_label: Label

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
	GameManager.stats_changed.connect(refresh)
	refresh()

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
