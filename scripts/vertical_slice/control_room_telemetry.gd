extends RefCounted
class_name ControlRoomTelemetry
## Telemetria local del puzle de registros y cableado. SOLO para pruebas.
##
## - Apagada por defecto: con enabled = false no se crea ningun directorio ni archivo.
## - Sin red y sin datos personales. El identificador de sesion es aleatorio y no se guarda.
## - Escribe lineas JSON en base_dir/control_room_<sesion>.jsonl; el archivo lo recoge a mano
##   quien dirija la prueba.
## - El tiempo llega como parametro (segundos desde que empezo la sala), igual que en las reglas.
##
## Solo recoge lo que responde a las hipotesis H1-H4. No anadir campos hasta que los datos
## demuestren que no bastan.

const IDLE_STEP_SECONDS := 30.0

var enabled: bool = false
var base_dir: String = "user://telemetry"
## Registros distintos que hay que haber leido para que read_both_logs sea true.
var required_logs: int = 2

var session_id: String = ""
var events_written: int = 0

var _path: String = ""
var _active: bool = false
var _solved: bool = false
var _logs_seen: Dictionary = {}
var _scans: int = 0
var _hints: int = 0
var _attempts: int = 0
var _scanned_near_traces: bool = false
var _last_useful_at: float = 0.0
var _idle_marks_emitted: int = 0


func is_active() -> bool:
	return _active


func file_path() -> String:
	return _path


## Abre una sesion nueva. Devuelve false si esta apagada o no se pudo crear el archivo.
func start_session(hint_mode: String, flags: Dictionary, version: String) -> bool:
	if not enabled:
		return false
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_dir)) != OK:
		push_warning("Telemetry: could not create %s" % base_dir)
		return false
	session_id = _new_session_id()
	_path = base_dir.path_join("control_room_%s.jsonl" % session_id)
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if file == null:
		push_warning("Telemetry: could not open %s" % _path)
		return false
	file.close()
	_active = true
	_solved = false
	_logs_seen = {}
	_scans = 0
	_hints = 0
	_attempts = 0
	_scanned_near_traces = false
	_last_useful_at = 0.0
	_idle_marks_emitted = 0
	events_written = 0
	_write("session_start", 0.0, {"sid": session_id, "version": version, "hint_mode": hint_mode, "flags": flags})
	return true


## Reinicia el reloj de inactividad (por ejemplo al intentar abrir la compuerta o pedir una pista).
func notify_useful_action(t: float) -> void:
	_last_useful_at = t
	_idle_marks_emitted = 0


func log_read(log_id: String, t: float) -> void:
	_logs_seen[log_id] = true
	notify_useful_action(t)
	_write("log_read", t, {"id": log_id})


## near_traces indica si habia trazas a menos del radio de escaneo.
func scan_used(near_traces: bool, t: float) -> void:
	_scans += 1
	if near_traces:
		_scanned_near_traces = true
		notify_useful_action(t)
	_write("scan_used", t, {"near_traces": near_traces})


## Solo para intentos aceptados por las reglas (un B bloqueado no es un intento).
func breaker_used(breaker_id: String, correct: bool, t: float) -> void:
	_attempts += 1
	notify_useful_action(t)
	_write("breaker_used", t, {
		"id": breaker_id,
		"correct": correct,
		"read_both_logs": _logs_seen.size() >= required_logs,
		"scanned_before": _scanned_near_traces,
	})


func hint_shown(level: int, trigger: String, t: float) -> void:
	_hints += 1
	_write("hint_shown", t, {"level": level, "trigger": trigger})


func gate_opened(t: float) -> void:
	_write("gate_opened", t, {})


func solved(t: float) -> void:
	_solved = true
	_write("solved", t, {
		"t_total": t,
		"attempts": _attempts,
		"logs_read": _logs_seen.size(),
		"scans": _scans,
		"hints": _hints,
	})


## Emite un evento idle por cada 30 s sin accion util. Si pasa mas tiempo de golpe emite
## uno solo con la marca mas alta. Devuelve cuantos eventos escribio.
func tick(now_seconds: float) -> int:
	if not _active or _solved:
		return 0
	var marks := int(floor((now_seconds - _last_useful_at) / IDLE_STEP_SECONDS))
	if marks > _idle_marks_emitted:
		_idle_marks_emitted = marks
		_write("idle", now_seconds, {"seconds": marks * IDLE_STEP_SECONDS})
		return 1
	return 0


func _write(event_name: String, t: float, fields: Dictionary) -> void:
	if not _active:
		return
	var line := {"e": event_name, "t": snappedf(t, 0.001)}
	for key in fields:
		line[key] = fields[key]
	var file := FileAccess.open(_path, FileAccess.READ_WRITE)
	if file == null:
		return
	file.seek_end()
	file.store_line(JSON.stringify(line, "", true))
	file.close()
	events_written += 1


func _new_session_id() -> String:
	return Crypto.new().generate_random_bytes(8).hex_encode()
