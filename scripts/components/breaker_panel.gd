extends "res://scripts/components/interactable.gd"
## Cuadro electrico: traduce la interaccion en rules.use_breaker() y en un mensaje.
## No decide cual es la solucion: eso vive en ControlRoomRules.
## Configurar antes de anadirlo al arbol: breaker_id, display_name, prompt_text,
## colores y textos de respuesta (los inyecta la escena desde NarrativeTextManager).

const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")

signal used(breaker_id: String, result: Dictionary)

@export var breaker_id: String = ""
@export var band_color: Color = Color(0.5, 0.5, 0.5)
@export var lamp_off_color: Color = Color(0.1, 0.12, 0.14)
@export var lamp_on_color: Color = Color(0.3, 0.6, 1.0)
@export var text_lamp: String = ""
@export var text_burned: String = ""
@export var text_pressure: String = ""
@export var text_cooldown: String = ""
@export var message_seconds: float = 5.0

## Instancia de ControlRoomRules compartida por toda la sala.
var rules = null
## Devuelve los segundos actuales (float). Si no es valido se usa el reloj del motor.
var clock: Callable = Callable()

var _lamp: MeshInstance3D = null
var _lamp_on: bool = false


func _ready() -> void:
	super()
	make_solid(Vector3(0.9, 1.6, 0.4))
	B.box(self, Vector3(0.9, 1.6, 0.35), Vector3(0.0, 0.8, 0.0), Color(0.14, 0.16, 0.19))
	B.box(self, Vector3(0.92, 0.14, 0.37), Vector3(0.0, 1.4, 0.0), band_color, 0.8)
	_lamp = B.box(self, Vector3(0.14, 0.14, 0.05), Vector3(0.25, 1.1, 0.2), lamp_off_color)
	B.label3d(self, breaker_id, Vector3(0.0, 2.0, 0.0), 64, band_color.lightened(0.4))
	_refresh_lamp()


func _on_interact(_actor: Node3D) -> void:
	if rules == null:
		return
	var result: Dictionary = rules.use_breaker(breaker_id, _now())
	var text := _text_for(str(result.get("result", "")))
	if not text.is_empty():
		show_message(text, message_seconds)
	_apply_result_visual(result)
	used.emit(breaker_id, result)


## Reaplica el estado visual a partir de las reglas (por ejemplo tras cargar partida).
func refresh_from_rules() -> void:
	if rules == null:
		_lamp_on = false
	elif breaker_id == RulesScript.BREAKER_A:
		_lamp_on = rules.lamp_lit
	elif breaker_id == RulesScript.BREAKER_C:
		_lamp_on = rules.pressure_on
	else:
		_lamp_on = false
	_refresh_lamp()


func lamp_is_on() -> bool:
	return _lamp_on


func _now() -> float:
	if clock.is_valid():
		return float(clock.call())
	return Time.get_ticks_msec() / 1000.0


func _text_for(result_name: String) -> String:
	if result_name == RulesScript.RESULT_LAMP:
		return text_lamp
	if result_name == RulesScript.RESULT_BURNED:
		return text_burned
	if result_name == RulesScript.RESULT_PRESSURE:
		return text_pressure
	if result_name == RulesScript.RESULT_COOLDOWN:
		return text_cooldown
	return ""


func _apply_result_visual(result: Dictionary) -> void:
	var result_name := str(result.get("result", ""))
	if result_name == RulesScript.RESULT_LAMP or result_name == RulesScript.RESULT_PRESSURE:
		_lamp_on = true
		_refresh_lamp()
	elif result_name == RulesScript.RESULT_BURNED:
		_flash()


func _flash() -> void:
	if _lamp == null:
		return
	B.set_glow(_lamp, Color(1.0, 0.6, 0.2), 6.0)
	get_tree().create_timer(0.4).timeout.connect(_refresh_lamp)


func _refresh_lamp() -> void:
	if _lamp == null:
		return
	if _lamp_on:
		B.set_glow(_lamp, lamp_on_color, 3.0)
	else:
		B.set_glow(_lamp, lamp_off_color, 0.0)
