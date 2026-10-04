#!/usr/bin/env python3
"""FINAL THAW - Fase 0: genera todo el proyecto base de Godot 4.x de una vez.
Uso (con Godot CERRADO, desde la carpeta que contiene project.godot):
    python setup_phase0.py
"""
import os, sys, shutil

FILES = {}

FILES["scripts/managers/input_setup.gd"] = r"""extends Node
## Crea las 16 acciones de entrada por codigo (remapeables en runtime).

const ACTIONS = {
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"attack_primary": [KEY_J, KEY_K],
	"attack_secondary": [KEY_L],
	"dodge": [KEY_SPACE, KEY_SHIFT],
	"interact": [KEY_E, KEY_F],
	"scan": [KEY_TAB, KEY_Q],
	"pause": [KEY_ESCAPE, KEY_P],
	"quick_save": [KEY_F5],
	"quick_load": [KEY_F9],
	"toggle_captions": [KEY_C],
	"increase_font": [KEY_EQUAL, KEY_PLUS],
	"decrease_font": [KEY_MINUS],
	"toggle_colorblind_mode": [KEY_B],
}

func _ready() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for k in ACTIONS[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = k
			InputMap.action_add_event(action, ev)
	_add_mouse("attack_primary", MOUSE_BUTTON_LEFT)
	_add_mouse("attack_secondary", MOUSE_BUTTON_RIGHT)

func _add_mouse(action: String, button: int) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)
"""

FILES["scripts/managers/game_manager.gd"] = r"""extends Node
## Autoload. Estado global + guardado con CRC32.

signal stats_changed

var civilian_aid: int = 0
var prototype_integrity: int = 3
var elena_safety: int = 3
var evidence_choice: String = "preserve"
var memory_fragments_collected: Array = []
var current_phase: int = 0
var playtime_seconds: float = 0.0

var font_scale: float = 1.0
var colorblind_mode: int = 0
var subtitle_size: int = 2
var input_profile: String = "default"

func _ready() -> void:
	load_game(0)

func save_path(slot: int) -> String:
	return "user://save_%d.json" % slot

func new_game() -> void:
	civilian_aid = 0
	prototype_integrity = 3
	elena_safety = 3
	evidence_choice = "preserve"
	memory_fragments_collected = []
	current_phase = 0
	playtime_seconds = 0.0
	stats_changed.emit()

func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(save_path(slot))

func crc32(bytes: PackedByteArray) -> int:
	var crc: int = 0xFFFFFFFF
	for b in bytes:
		crc ^= b
		for _i in 8:
			if crc & 1:
				crc = (crc >> 1) ^ 0xEDB88320
			else:
				crc = crc >> 1
	return crc ^ 0xFFFFFFFF

func _collect() -> Dictionary:
	return {
		"version": 1,
		"phase": current_phase,
		"playtime": playtime_seconds,
		"civilian_aid": civilian_aid,
		"prototype_integrity": prototype_integrity,
		"elena_safety": elena_safety,
		"evidence_choice": evidence_choice,
		"memory_fragments": memory_fragments_collected,
		"font_scale": font_scale,
		"colorblind_mode": colorblind_mode,
		"subtitle_size": subtitle_size,
		"input_profile": input_profile,
	}

func _apply(d: Dictionary) -> void:
	current_phase = int(d.get("phase", 0))
	playtime_seconds = float(d.get("playtime", 0.0))
	civilian_aid = int(d.get("civilian_aid", 0))
	prototype_integrity = int(d.get("prototype_integrity", 3))
	elena_safety = int(d.get("elena_safety", 3))
	evidence_choice = str(d.get("evidence_choice", "preserve"))
	memory_fragments_collected = d.get("memory_fragments", [])
	font_scale = float(d.get("font_scale", 1.0))
	colorblind_mode = int(d.get("colorblind_mode", 0))
	subtitle_size = int(d.get("subtitle_size", 2))
	input_profile = str(d.get("input_profile", "default"))
	stats_changed.emit()

func save_game(slot: int = 0) -> bool:
	# El payload se guarda como TEXTO para que el CRC sea estable al releer.
	var payload: String = JSON.stringify(_collect())
	var container := {"payload": payload, "crc32": crc32(payload.to_utf8_buffer())}
	var f := FileAccess.open(save_path(slot), FileAccess.WRITE)
	if f == null:
		push_error("No se pudo abrir el guardado: %s" % error_string(FileAccess.get_open_error()))
		return false
	f.store_string(JSON.stringify(container))
	f.close()
	return true

func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false
	var f := FileAccess.open(save_path(slot), FileAccess.READ)
	if f == null:
		return false
	var text: String = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("payload") or not parsed.has("crc32"):
		push_warning("Guardado corrupto (estructura).")
		return false
	var payload: String = str(parsed["payload"])
	if int(parsed["crc32"]) != crc32(payload.to_utf8_buffer()):
		push_warning("Guardado corrupto (CRC32 no coincide).")
		return false
	var data = JSON.parse_string(payload)
	if typeof(data) != TYPE_DICTIONARY:
		return false
	_apply(data)
	return true

func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)
"""

FILES["scripts/managers/debug_manager.gd"] = r"""extends Node
## F1 = god mode, F2 = contador FPS, F3 = salto de nivel (pendiente).

var god_mode: bool = false
var show_fps: bool = true

func toggle_god_mode() -> void:
	god_mode = not god_mode
	print("God mode: ", god_mode)

func toggle_fps() -> void:
	show_fps = not show_fps

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F1: toggle_god_mode()
			KEY_F2: toggle_fps()
			KEY_F3: print("Level skip: pendiente (Fase 1+)")
"""

FILES["scripts/entities/player.gd"] = r"""extends CharacterBody2D

@export var speed: float = 320.0
@export var acceleration: float = 2400.0
@export var friction: float = 3000.0

var nearby: Array = []

func _ready() -> void:
	add_to_group("player")
	var cs := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 20.0
	shape.height = 80.0
	cs.shape = shape
	add_child(cs)
	var body := ColorRect.new()
	body.color = Color("00c853")
	body.size = Vector2(40, 80)
	body.position = Vector2(-20, -40)
	add_child(body)
	var sensor := Area2D.new()
	var sc := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 60.0
	sc.shape = circle
	sensor.add_child(sc)
	add_child(sensor)
	sensor.area_entered.connect(func(a): if not nearby.has(a): nearby.append(a))
	sensor.area_exited.connect(func(a): nearby.erase(a))

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()

func try_interact() -> bool:
	if nearby.is_empty():
		return false
	nearby[0].call("interact")
	return true
"""

FILES["scripts/entities/interactable.gd"] = r"""extends Area2D

@export var interact_text: String = "Interactuable"
var interact_count: int = 0

func _ready() -> void:
	add_to_group("interactable")
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(100, 100)
	cs.shape = shape
	add_child(cs)
	var vis := ColorRect.new()
	vis.color = Color("ffd600")
	vis.size = Vector2(100, 100)
	vis.position = Vector2(-50, -50)
	add_child(vis)
	var lbl := Label.new()
	lbl.text = interact_text
	lbl.position = Vector2(-50, -80)
	add_child(lbl)

func interact() -> void:
	interact_count += 1
	print("Interactuando con: ", interact_text, " (", interact_count, ")")
"""

FILES["scripts/ui/hud.gd"] = r"""extends CanvasLayer

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
"""

FILES["scripts/ui/main_menu.gd"] = r"""extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	var title := Label.new()
	title.text = "FINAL THAW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	vbox.add_child(title)
	var start := _btn(vbox, "Start", _on_start)
	var cont := _btn(vbox, "Continue", _on_continue)
	cont.disabled = not GameManager.has_save(0)
	_btn(vbox, "Options", func(): GameManager.change_scene("res://scenes/ui/options_menu.tscn"))
	_btn(vbox, "Credits", func(): GameManager.change_scene("res://scenes/ui/credits.tscn"))
	_btn(vbox, "Quit", func(): get_tree().quit())
	start.grab_focus()

func _btn(parent: Node, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 48)
	b.add_to_group("menu_button")
	b.pressed.connect(cb)
	parent.add_child(b)
	return b

func _on_start() -> void:
	GameManager.new_game()
	GameManager.change_scene("res://scenes/levels/test_room.tscn")

func _on_continue() -> void:
	if GameManager.load_game(0):
		GameManager.change_scene("res://scenes/levels/test_room.tscn")
"""

FILES["scripts/ui/options_menu.gd"] = r"""extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	var lbl := Label.new()
	lbl.text = "Escala de texto: %.2f" % GameManager.font_scale
	vbox.add_child(lbl)
	var slider := HSlider.new()
	slider.min_value = 0.75
	slider.max_value = 2.0
	slider.step = 0.05
	slider.value = GameManager.font_scale
	slider.custom_minimum_size = Vector2(320, 24)
	slider.value_changed.connect(func(v):
		GameManager.font_scale = v
		lbl.text = "Escala de texto: %.2f" % v)
	vbox.add_child(slider)
	var back := Button.new()
	back.text = "Volver"
	back.pressed.connect(func():
		GameManager.save_game(0)
		GameManager.change_scene("res://scenes/ui/main_menu.tscn"))
	vbox.add_child(back)
	back.grab_focus()
"""

FILES["scripts/ui/credits.gd"] = r"""extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color("1a1a2e")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)
	var lbl := Label.new()
	lbl.text = "FINAL THAW\nPrototipo Fase 0"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)
	var back := Button.new()
	back.text = "Volver"
	back.pressed.connect(func(): GameManager.change_scene("res://scenes/ui/main_menu.tscn"))
	vbox.add_child(back)
	back.grab_focus()
"""

FILES["scripts/levels/test_room.gd"] = r"""extends Node2D

const PlayerScript = preload("res://scripts/entities/player.gd")
const InteractableScript = preload("res://scripts/entities/interactable.gd")
const HudScript = preload("res://scripts/ui/hud.gd")

var player: CharacterBody2D
var hud: CanvasLayer
var interactables: Array = []

func _ready() -> void:
	var floor_rect := ColorRect.new()
	floor_rect.color = Color("2d2d44")
	floor_rect.size = Vector2(2000, 2000)
	add_child(floor_rect)

	for i in 3:
		var it: Area2D = InteractableScript.new()
		it.set("interact_text", "Objeto %d" % (i + 1))
		it.position = Vector2(1200 + i * 200, 1000)
		add_child(it)
		interactables.append(it)

	player = PlayerScript.new()
	player.position = Vector2(1000, 1000)
	add_child(player)
	var cam := Camera2D.new()
	player.add_child(cam)
	cam.make_current()

	hud = HudScript.new()
	add_child(hud)
	hud.set_character("Elena")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		GameManager.change_scene("res://scenes/ui/main_menu.tscn")
	elif event.is_action_pressed("quick_save"):
		print("Quick save: ", GameManager.save_game(0))
	elif event.is_action_pressed("quick_load"):
		print("Quick load: ", GameManager.load_game(0))
"""

FILES["tests/test_phase_0.gd"] = r"""extends Node
## Ejecutar: godot --headless --path . res://tests/test_phase_0.tscn

var passed := 0
var failed := 0

func check(name: String, cond: bool) -> void:
	if cond:
		passed += 1
		print("PASS  ", name)
	else:
		failed += 1
		print("FAIL  ", name)

func _ready() -> void:
	await get_tree().process_frame
	await _run()
	print("=== %d passed, %d failed ===" % [passed, failed])
	get_tree().quit(1 if failed > 0 else 0)

func _new_room() -> Node:
	var room = load("res://scenes/levels/test_room.tscn").instantiate()
	add_child(room)
	return room

func _run() -> void:
	check("01 GameManager autoload existe", get_node_or_null("/root/GameManager") != null)

	var actions := ["move_up","move_down","move_left","move_right","attack_primary","attack_secondary",
		"dodge","interact","scan","pause","quick_save","quick_load","toggle_captions",
		"increase_font","decrease_font","toggle_colorblind_mode"]
	var missing := actions.filter(func(a): return not InputMap.has_action(a))
	check("02 Input Map tiene las 16 acciones", missing.is_empty())

	var room = _new_room()
	await get_tree().process_frame
	var p = room.player
	var x0: float = p.position.x
	Input.action_press("move_right")
	for i in 20:
		await get_tree().physics_frame
	Input.action_release("move_right")
	check("03 El jugador se mueve con move_right", p.position.x > x0 + 10.0)

	p.position = room.interactables[0].position
	for i in 4:
		await get_tree().physics_frame
	var did: bool = p.try_interact()
	check("04 Interaccion con objeto cercano", did and room.interactables[0].interact_count == 1)

	var old_aid: int = GameManager.civilian_aid
	GameManager.civilian_aid = 4
	room.hud.refresh()
	check("05 HUD refleja civilian_aid", room.hud.aid_label.text.contains("4/10"))
	GameManager.civilian_aid = old_aid

	check("10 Test room tiene 3 interactuables", room.interactables.size() == 3)
	room.queue_free()
	await get_tree().process_frame

	GameManager.civilian_aid = 7
	GameManager.font_scale = 1.5
	var saved: bool = GameManager.save_game(99)
	GameManager.civilian_aid = 0
	GameManager.font_scale = 1.0
	var loaded: bool = GameManager.load_game(99)
	check("06 Guardar y cargar conserva datos", saved and loaded and GameManager.civilian_aid == 7)
	check("08 Escala de fuente persiste", is_equal_approx(GameManager.font_scale, 1.5))

	var f := FileAccess.open(GameManager.save_path(99), FileAccess.READ)
	var container = JSON.parse_string(f.get_as_text())
	f.close()
	container["payload"] = str(container["payload"]).replace("civilian_aid", "civilian_aidX")
	var w := FileAccess.open(GameManager.save_path(99), FileAccess.WRITE)
	w.store_string(JSON.stringify(container))
	w.close()
	check("07 CRC32 detecta corrupcion", GameManager.load_game(99) == false)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GameManager.save_path(99)))

	var menu = load("res://scenes/ui/main_menu.tscn").instantiate()
	add_child(menu)
	await get_tree().process_frame
	check("09 MainMenu tiene 5 botones", get_tree().get_nodes_in_group("menu_button").size() == 5)
	menu.queue_free()
	await get_tree().process_frame

	var before: bool = DebugManager.god_mode
	DebugManager.toggle_god_mode()
	var toggled: bool = DebugManager.god_mode != before
	DebugManager.toggle_god_mode()
	check("11 DebugManager alterna god mode", toggled and DebugManager.god_mode == before)
"""

def scene(root_type, name, script):
    return ('[gd_scene load_steps=2 format=3]\n\n'
            '[ext_resource type="Script" path="%s" id="1_s"]\n\n'
            '[node name="%s" type="%s"]\nscript = ExtResource("1_s")\n') % (script, name, root_type)

FILES["scenes/ui/main_menu.tscn"] = scene("Control", "MainMenu", "res://scripts/ui/main_menu.gd")
FILES["scenes/ui/options_menu.tscn"] = scene("Control", "OptionsMenu", "res://scripts/ui/options_menu.gd")
FILES["scenes/ui/credits.tscn"] = scene("Control", "Credits", "res://scripts/ui/credits.gd")
FILES["scenes/levels/test_room.tscn"] = scene("Node2D", "TestRoom", "res://scripts/levels/test_room.gd")
FILES["tests/test_phase_0.tscn"] = scene("Node", "TestPhase0", "res://tests/test_phase_0.gd")

DIRS = ["scenes/ui","scenes/levels","scenes/entities","scripts/managers","scripts/ui",
        "scripts/entities","scripts/levels","assets/fonts","assets/textures","assets/audio","tests","config"]

def set_ini(lines, section, key, value):
    header = "[%s]" % section
    if header not in [l.strip() for l in lines]:
        if lines and lines[-1].strip() != "":
            lines.append("")
        lines.extend([header, "%s=%s" % (key, value), ""])
        return
    i = [l.strip() for l in lines].index(header)
    j = i + 1
    while j < len(lines) and not lines[j].startswith("["):
        if lines[j].startswith(key + "="):
            lines[j] = "%s=%s" % (key, value)
            return
        j += 1
    k = j
    while k - 1 > i and lines[k - 1].strip() == "":
        k -= 1
    lines.insert(k, "%s=%s" % (key, value))

def main():
    if not os.path.exists("project.godot"):
        sys.exit("ERROR: no encuentro project.godot. Ejecuta el script dentro de la carpeta del proyecto.")
    for d in DIRS:
        os.makedirs(d, exist_ok=True)
    for path, content in FILES.items():
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)
        print("escrito", path)

    shutil.copy("project.godot", "project.godot.bak")
    with open("project.godot", encoding="utf-8") as f:
        lines = f.read().split("\n")
    set_ini(lines, "application", "run/main_scene", '"res://scenes/ui/main_menu.tscn"')
    set_ini(lines, "autoload", "InputSetup", '"*res://scripts/managers/input_setup.gd"')
    set_ini(lines, "autoload", "GameManager", '"*res://scripts/managers/game_manager.gd"')
    set_ini(lines, "autoload", "DebugManager", '"*res://scripts/managers/debug_manager.gd"')
    set_ini(lines, "display", "window/size/viewport_width", "1280")
    set_ini(lines, "display", "window/size/viewport_height", "720")
    set_ini(lines, "display", "window/stretch/mode", '"canvas_items"')
    set_ini(lines, "display", "window/stretch/aspect", '"keep"')
    set_ini(lines, "physics", "common/physics_ticks_per_second", "60")
    with open("project.godot", "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))
    print("\nproject.godot actualizado (copia en project.godot.bak)")
    print("Siguiente: abre el proyecto en Godot y pulsa F5.")
    print("Tests:  godot --headless --path . res://tests/test_phase_0.tscn")

if __name__ == "__main__":
    main()
