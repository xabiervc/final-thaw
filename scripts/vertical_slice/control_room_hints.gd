extends RefCounted
class_name ControlRoomHints
## Logica pura de pistas del puzle de registros y cableado.
## Sin nodos, UI, tiempo real ni autoloads: el tiempo llega como parametro y el
## resultado son eventos {level, trigger} que la escena traduce a texto.
##
## Modos: OFF no muestra nada; CONTEXTUAL puede mostrar el nivel 1; FULL puede
## mostrar el nivel 1 y el nivel 2.
##
## Una "accion util" es leer un registro, escanear con una traza cerca, accionar un
## cuadro, intentar abrir la compuerta o pedir una pista. Caminar, mirar o esperar
## no reinician el reloj de inactividad.

const RulesScript = preload("res://scripts/vertical_slice/control_room_rules.gd")

enum Mode { OFF, CONTEXTUAL, FULL }

const LEVEL_1 := 1
const LEVEL_2 := 2

const TRIGGER_WRONG_ATTEMPT := "wrong_attempt"
const TRIGGER_IDLE := "idle"
const TRIGGER_MANUAL := "manual"

const TEXT_KEY_LEVEL_1 := "cr_hint_level_1"
const TEXT_KEY_LEVEL_2 := "cr_hint_level_2"

var mode: int = Mode.CONTEXTUAL
var idle_level_1_seconds: float = 45.0
var idle_level_2_seconds: float = 100.0
var wrong_attempt_delay_seconds: float = 1.5
var manual_escalation_seconds: float = 30.0

var solved: bool = false

var _last_useful_at: float = 0.0
var _idle_level_1_shown: bool = false
var _idle_level_2_shown: bool = false
var _wrong_hint_used: bool = false
var _wrong_hint_pending: bool = false
var _wrong_hint_due_at: float = 0.0
var _last_manual_at: float = -INF


func reset(now_seconds: float = 0.0) -> void:
	solved = false
	_last_useful_at = now_seconds
	_idle_level_1_shown = false
	_idle_level_2_shown = false
	_wrong_hint_used = false
	_wrong_hint_pending = false
	_wrong_hint_due_at = 0.0
	_last_manual_at = -INF


## Reinicia el reloj de inactividad. Cada periodo de inactividad puede mostrar cada nivel una vez.
func notify_useful_action(now_seconds: float) -> void:
	if solved:
		return
	_last_useful_at = now_seconds
	_idle_level_1_shown = false
	_idle_level_2_shown = false


## Registra el resultado de accionar un cuadro. Solo la primera hipotesis incorrecta
## (A o B) programa una pista, que llega tras la respuesta especifica.
func notify_breaker_result(result_name: String, now_seconds: float) -> void:
	notify_useful_action(now_seconds)
	if solved or mode == Mode.OFF or _wrong_hint_used:
		return
	if result_name == RulesScript.RESULT_LAMP or result_name == RulesScript.RESULT_BURNED:
		_wrong_hint_used = true
		_wrong_hint_pending = true
		_wrong_hint_due_at = now_seconds + wrong_attempt_delay_seconds


## Tras abrirse la compuerta ya no hay mas pistas.
func notify_solved() -> void:
	solved = true
	_wrong_hint_pending = false


## Devuelve los eventos de pista que vencen en este instante.
func advance(now_seconds: float) -> Array:
	var events: Array = []
	if solved or mode == Mode.OFF:
		return events
	if _wrong_hint_pending and now_seconds >= _wrong_hint_due_at:
		_wrong_hint_pending = false
		events.append(_event(LEVEL_1, TRIGGER_WRONG_ATTEMPT))
	var idle := now_seconds - _last_useful_at
	if mode == Mode.FULL and not _idle_level_2_shown and idle >= idle_level_2_seconds:
		_idle_level_1_shown = true
		_idle_level_2_shown = true
		events.append(_event(LEVEL_2, TRIGGER_IDLE))
	elif not _idle_level_1_shown and idle >= idle_level_1_seconds:
		_idle_level_1_shown = true
		events.append(_event(LEVEL_1, TRIGGER_IDLE))
	return events


## Peticion manual. La primera da el nivel 1; en modo FULL, una segunda peticion
## en menos de manual_escalation_seconds (inclusive) da el nivel 2.
func request_hint(now_seconds: float) -> Array:
	if solved or mode == Mode.OFF:
		return []
	notify_useful_action(now_seconds)
	var level := LEVEL_1
	if mode == Mode.FULL and now_seconds - _last_manual_at <= manual_escalation_seconds:
		level = LEVEL_2
	_last_manual_at = now_seconds
	return [_event(level, TRIGGER_MANUAL)]


func text_key_for(level: int) -> String:
	if level == LEVEL_1:
		return TEXT_KEY_LEVEL_1
	if level == LEVEL_2:
		return TEXT_KEY_LEVEL_2
	return ""


func _event(level: int, trigger: String) -> Dictionary:
	return {"level": level, "trigger": trigger}
