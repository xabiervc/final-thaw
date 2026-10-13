extends RefCounted
class_name ControlRoomRules
## Logica pura del puzle de registros y cableado (Fase 1, sala de control).
## Sin nodos, UI, tiempo real, fisica ni autoloads: el tiempo llega como parametro.
##
## Solucion: el registro posterior al incidente invalida al anterior; el cable
## de la compuerta llega por el circuito verde (cuadro C). A solo enciende una
## lampara de estado y B tiene el fusible quemado.

const LOG_BEFORE := "maintenance_0614"
const LOG_AFTER := "post_incident_review"
const LOG_IDS: Array[String] = [LOG_BEFORE, LOG_AFTER]

const BREAKER_A := "A"
const BREAKER_B := "B"
const BREAKER_C := "C"
const BREAKER_IDS: Array[String] = [BREAKER_A, BREAKER_B, BREAKER_C]

const B_COOLDOWN_SECONDS := 4.0

const RESULT_LAMP := "lamp"
const RESULT_BURNED := "burned"
const RESULT_PRESSURE := "pressure"
const RESULT_COOLDOWN := "cooldown"
const RESULT_INVALID := "invalid"

var lamp_lit: bool = false
var pressure_on: bool = false
var gate_open: bool = false

var _logs_read: Dictionary = {}
var _attempts: Dictionary = {BREAKER_A: 0, BREAKER_B: 0, BREAKER_C: 0}
var _b_ready_at: float = -INF


## Devuelve true solo la primera vez que se registra un registro valido.
func read_log(log_id: String) -> bool:
	if not LOG_IDS.has(log_id) or _logs_read.has(log_id):
		return false
	_logs_read[log_id] = true
	return true


func has_read_log(log_id: String) -> bool:
	return _logs_read.has(log_id)


func has_read_both_logs() -> bool:
	return _logs_read.size() == LOG_IDS.size()


## Resultado: accepted, result, correct, gate_powered. No contiene textos ni nodos.
func use_breaker(breaker_id: String, now_seconds: float) -> Dictionary:
	if breaker_id == BREAKER_A:
		lamp_lit = true
		_attempts[BREAKER_A] += 1
		return _result(true, RESULT_LAMP, false)
	if breaker_id == BREAKER_B:
		if not is_breaker_available(BREAKER_B, now_seconds):
			return _result(false, RESULT_COOLDOWN, false)
		_b_ready_at = now_seconds + B_COOLDOWN_SECONDS
		_attempts[BREAKER_B] += 1
		return _result(true, RESULT_BURNED, false)
	if breaker_id == BREAKER_C:
		pressure_on = true
		_attempts[BREAKER_C] += 1
		return _result(true, RESULT_PRESSURE, true)
	return _result(false, RESULT_INVALID, false)


func is_breaker_available(breaker_id: String, now_seconds: float) -> bool:
	if breaker_id == BREAKER_A or breaker_id == BREAKER_C:
		return true
	if breaker_id == BREAKER_B:
		return now_seconds >= _b_ready_at
	return false


func breaker_b_remaining(now_seconds: float) -> float:
	return maxf(0.0, _b_ready_at - now_seconds)


func can_open_gate() -> bool:
	return pressure_on


## Devuelve true solo cuando la compuerta pasa de cerrada a abierta.
func open_gate() -> bool:
	if not pressure_on or gate_open:
		return false
	gate_open = true
	return true


func is_gate_open() -> bool:
	return gate_open


func attempts_for(breaker_id: String) -> int:
	return int(_attempts.get(breaker_id, 0))


func total_attempts() -> int:
	var total := 0
	for breaker_id in BREAKER_IDS:
		total += int(_attempts[breaker_id])
	return total


## El rearme de B es temporal y no se guarda: tras cargar, B vuelve a estar disponible.
func get_state() -> Dictionary:
	var logs: Array = _logs_read.keys()
	logs.sort()
	return {
		"logs_read": logs,
		"lamp_lit": lamp_lit,
		"pressure_on": pressure_on,
		"gate_open": gate_open,
		"attempts": {
			BREAKER_A: attempts_for(BREAKER_A),
			BREAKER_B: attempts_for(BREAKER_B),
			BREAKER_C: attempts_for(BREAKER_C),
		},
	}


## Tolerante con datos de guardado incompletos o erroneos; impone los invariantes.
func apply_state(state: Dictionary) -> void:
	reset()
	var logs: Variant = state.get("logs_read", [])
	if logs is Array:
		for log_id in logs:
			if LOG_IDS.has(str(log_id)):
				_logs_read[str(log_id)] = true
	lamp_lit = bool(state.get("lamp_lit", false))
	pressure_on = bool(state.get("pressure_on", false))
	gate_open = bool(state.get("gate_open", false)) and pressure_on
	var attempts: Variant = state.get("attempts", {})
	if attempts is Dictionary:
		for breaker_id in BREAKER_IDS:
			_attempts[breaker_id] = maxi(0, int(attempts.get(breaker_id, 0)))


func reset() -> void:
	lamp_lit = false
	pressure_on = false
	gate_open = false
	_logs_read = {}
	_attempts = {BREAKER_A: 0, BREAKER_B: 0, BREAKER_C: 0}
	_b_ready_at = -INF


func _result(accepted: bool, result: String, correct: bool) -> Dictionary:
	return {
		"accepted": accepted,
		"result": result,
		"correct": correct,
		"gate_powered": pressure_on,
	}
