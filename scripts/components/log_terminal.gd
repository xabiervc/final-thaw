extends "res://scripts/components/terminal.gd"
## Terminal de registro: muestra un registro fechado y avisa a las reglas del puzle.
## No decide nada: solo traduce la interaccion en rules.read_log() y en un mensaje.
## Configurar antes de anadirlo al arbol: display_name, prompt_text, log_id y textos.
## Los textos los inyecta la escena (desde NarrativeTextManager); el componente no
## conoce la localizacion.

signal log_read(log_id: String, first_time: bool)

@export var log_id: String = ""
@export var title_text: String = ""
@export var body_text: String = ""
@export var show_seconds: float = 14.0

## Instancia de ControlRoomRules compartida por toda la sala.
var rules = null


func _on_interact(_actor: Node3D) -> void:
	_set_accessed(true)
	var first_time := false
	if rules != null:
		first_time = rules.read_log(log_id)
	show_message(_compose(), show_seconds)
	log_read.emit(log_id, first_time)


func _compose() -> String:
	if title_text.is_empty():
		return body_text
	return title_text + "\n" + body_text
