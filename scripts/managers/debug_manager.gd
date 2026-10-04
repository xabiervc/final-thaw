extends Node
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
