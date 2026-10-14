extends Node
## Phase 1 clue objects and controls wired to the circuit model (phase1_circuit_model.gd, FASE1_LOGIC_CONTRACT.md).
## The model decides every outcome; this node only reads the player's position, shows the prompt, calls the model and
## reflects its state on the dressing (Column rings, indicator strips, archive screen). Nothing here knows the solution:
## the schematic documents the intent, the bridge shows an anomaly, the indicators show consequences, the terminal
## verifies, and a three-step hint ladder (H) is the only help. Every action is logged to the console for play reports.
## Record content, extraction and containment are not implemented: the archive text is a marked placeholder.

const CircuitModel = preload("res://scripts/prototypes/phase1_circuit_model.gd")
const SfxSynth = preload("res://scripts/audio/sfx_synth.gd")
const REACH := 2.2
const CYAN := Color(0.4, 0.86, 0.88)
const GREEN := Color(0.45, 0.95, 0.65)
const RED := Color(1.0, 0.35, 0.3)
const AMBER := Color(1.0, 0.7, 0.25)
const LIVE := 1.8
const DIM := 0.15
const HINTS := [
	"Recuerda tu objetivo: acceder al registro del ensayo sin volver a ponerlo en marcha.",
	"Compara el circuito previsto con lo que realmente está alimentado.",
	"Fíjate en si la rama de ensayo sigue conectada cuando pides alimentar el archivo.",
]

var circuit = CircuitModel.new()
var greybox = null
var hotspots: Array = []
var events: Array = []
var clues: Dictionary = {}
var hints_used: int = 0
var current_hotspot: String = ""
var _audio: AudioStreamPlayer
var _power_up: AudioStream
var _alarm: AudioStreamWAV
var _denied: AudioStream
var _beep: AudioStream


func setup(host) -> void:
	greybox = host
	_power_up = SfxSynth.power_up()
	_alarm = SfxSynth.alarm_pip()
	_alarm.loop_mode = AudioStreamWAV.LOOP_DISABLED
	_denied = SfxSynth.denied()
	_beep = SfxSynth.terminal_beep()
	_audio = AudioStreamPlayer.new()
	add_child(_audio)
	_add_hotspot("schematic", Vector3(22.0, -2.0, 19.0), "Examinar", "Esquema de distribución", Callable(self, "examine_schematic"))
	_add_hotspot("bridge", Vector3(14.2, -2.0, 18.0), "Examinar", "Conexión", Callable(self, "examine_bridge"))
	_add_hotspot("maintenance", Vector3(23.0, -2.0, 22.6), "Accionar", "Interruptor de mantenimiento", Callable(self, "toggle_maintenance"))
	_add_hotspot("selector", Vector3(14.0, 3.0, -15.7), "Accionar", "Selector de recuperación", Callable(self, "toggle_selector"))
	_add_hotspot("isolator", Vector3(20.0, 3.0, -15.7), "Accionar", "Seccionador de ensayo", Callable(self, "toggle_isolator"))
	_add_hotspot("indicators", Vector3(17.0, 3.0, -15.85), "Leer", "Indicadores", Callable(self, "read_indicators"))
	_add_hotspot("terminal", Vector3(4.0, 3.0, -16.3), "Usar", "Terminal del archivo", Callable(self, "use_terminal"))
	_add_hotspot("rearm", Vector3(6.3, 3.0, -16.0), "Rearmar", "Protección de recuperación", Callable(self, "request_rearm"))
	_add_hotspot("shortcut", Vector3(2.0, 3.0, -10.0), "Desbloquear", "Puerta del atajo", Callable(self, "use_shortcut"), Callable(self, "_shortcut_available"))
	_refresh_visuals()


func _add_hotspot(id: String, pos: Vector3, verb: String, label: String, handler: Callable, available: Callable = Callable()) -> void:
	var entry := {"id": id, "pos": pos, "verb": verb, "name": label, "handler": handler}
	if available.is_valid():
		entry["available"] = available
	hotspots.append(entry)


func _shortcut_available(player_pos: Vector3) -> bool:
	return not greybox.shortcut_open and greybox.unlock_allowed(player_pos)


func _physics_process(_delta: float) -> void:
	if greybox == null or greybox.player == null or greybox.hud == null:
		return
	var player_pos: Vector3 = greybox.player.position
	var best: Dictionary = {}
	var best_distance: float = REACH
	for h in hotspots:
		if h.has("available") and not bool((h["available"] as Callable).call(player_pos)):
			continue
		var d: float = player_pos.distance_to(h["pos"])
		if d < best_distance:
			best_distance = d
			best = h
	if best.is_empty():
		current_hotspot = ""
		greybox.hud.call("set_prompt", "")
		return
	current_hotspot = str(best["id"])
	greybox.hud.call("set_prompt", "[E] %s - %s" % [best["verb"], best["name"]])
	if Input.is_action_just_pressed("interact"):
		(best["handler"] as Callable).call()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo and key.physical_keycode == KEY_H:
		request_hint()


# --- clues ---------------------------------------------------------------------------------------------------

func examine_schematic() -> void:
	_clue("schematic", "Esquema de distribución", "Una sola fuente y tres ramas independientes: mantenimiento, ensayo y archivo.")


func examine_bridge() -> void:
	_clue("bridge", "Conexión manipulada", "Un cable naranja une la rama del archivo con la del ensayo. No aparece en el esquema.")


func read_indicators() -> void:
	var text := "Destino solicitado: %s\nDemanda en la rama de ensayo: %s\nProtección de recuperación: %s" % [
		"archivo" if circuit.destination == CircuitModel.ARCHIVE else "ensayo",
		"sí" if circuit.fault_present() else "no",
		"disponible" if circuit.protection_available else "disparada"]
	clues["indicators"] = true
	_log("indicators", text.replace("\n", " | "))
	_banner("Indicadores", text, CYAN, 6.0)
	_sound(_beep)


func _clue(id: String, title: String, body: String) -> void:
	clues[id] = true
	_log(id)
	_banner(title, body, CYAN, 6.0)
	_sound(_beep)


# --- controls ------------------------------------------------------------------------------------------------

func toggle_maintenance() -> void:
	circuit.set_maintenance(not circuit.maintenance_on)
	_log("maintenance", "on" if circuit.maintenance_on else "off")
	_sound(_power_up if circuit.maintenance_on else _beep)
	_banner("Mantenimiento " + ("activo" if circuit.maintenance_on else "apagado"), "Alimentación de servicio %s." % ("restablecida" if circuit.maintenance_on else "cortada"), GREEN if circuit.maintenance_on else AMBER, 4.0)
	_refresh_visuals()


func toggle_selector() -> void:
	var was_available: bool = circuit.protection_available
	var target: String = CircuitModel.ARCHIVE if circuit.destination == CircuitModel.TRIAL else CircuitModel.TRIAL
	circuit.select_destination(target)
	_log("selector", target)
	_after_change(was_available, "Selector en " + ("ARCHIVO" if target == CircuitModel.ARCHIVE else "ENSAYO"), "Destino de la alimentación de recuperación.")


func toggle_isolator() -> void:
	var was_available: bool = circuit.protection_available
	circuit.set_isolated(not circuit.trial_isolated)
	_log("isolator", "isolated" if circuit.trial_isolated else "connected")
	_after_change(was_available, "Rama de ensayo " + ("aislada" if circuit.trial_isolated else "conectada"), "Seccionador de ensayo.")


func _after_change(was_available: bool, title: String, body: String) -> void:
	if was_available and not circuit.protection_available:
		_on_trip()
	else:
		_banner(title, body, CYAN, 3.5)
		_sound(_beep)
	_refresh_visuals()


func _on_trip() -> void:
	_log("trip", circuit.last_trip)
	_sound(_alarm)
	_banner("Protección de recuperación disparada", "Demanda simultánea registrada. No se ha perdido nada.", RED, 5.0)
	if greybox != null and greybox.has_method("dip_lights"):
		greybox.dip_lights()


# --- terminal and protection ---------------------------------------------------------------------------

## Current state and last recorded trip, shown together and never naming a control to operate.
func diagnostic_text() -> String:
	var info: Dictionary = circuit.inspect()
	var lines := PackedStringArray()
	match str(info["current"]):
		"ARCHIVE_STABLE":
			lines.append("Alimentación de archivo estable. Consulta disponible.")
		"RECOVERY_TRIPPED_FAULT_PRESENT":
			lines.append("Recuperación interrumpida. Persiste la condición de disparo.")
		"RECOVERY_TRIPPED_REARM_PENDING":
			lines.append("Recuperación interrumpida. Rearme pendiente.")
		_:
			lines.append("Archivo sin suministro.")
	lines.append("Destino seleccionado: %s." % ("archivo" if info["destination"] == CircuitModel.ARCHIVE else "ensayo"))
	lines.append("Último disparo: demanda simultánea en archivo y ensayo." if str(info["last_trip"]) != "" else "Sin disparos registrados.")
	return "\n".join(lines)


## The diagnostic is always available; reading the archive needs stable supply.
func use_terminal() -> void:
	var text: String = diagnostic_text()
	var consulted: bool = circuit.consult()
	if consulted:
		clues["archive_consulted"] = true
		text += "\nRegistro parcial consultado. [Contenido pendiente de guión]"
	_log("terminal", "consulted" if consulted else "diagnostic only")
	var accent: Color = CYAN
	if consulted:
		accent = GREEN
	elif not circuit.protection_available:
		accent = RED
	_banner("Diagnóstico del archivo", text, accent, 7.0)
	_sound(_beep)


func request_rearm() -> void:
	var done: bool = circuit.rearm()
	_log("rearm", "accepted" if done else "rejected")
	if done:
		_banner("Protección rearmada", "La alimentación de recuperación queda disponible.", GREEN, 4.0)
		_sound(_power_up)
	else:
		_banner("No se puede rearmar", "Persiste la condición de disparo.", AMBER, 4.0)
		_sound(_denied)
	_refresh_visuals()


func use_shortcut() -> void:
	if greybox.unlock_shortcut(greybox.player.position):
		_log("shortcut", "unlocked")


func request_hint() -> void:
	hints_used = mini(hints_used + 1, HINTS.size())
	_log("hint", str(hints_used))
	greybox.hud.call("set_hint", HINTS[hints_used - 1])


# --- reflection on the dressing ---------------------------------------------------------------------------

func _set_glow(node: MeshInstance3D, live: bool, color: Color) -> void:
	if node == null:
		return
	var material := node.material_override as StandardMaterial3D
	if material == null:
		return
	material.emission = color
	material.emission_energy_multiplier = LIVE if live else DIM


func _refresh_visuals() -> void:
	if greybox == null or greybox.dressing == null:
		return
	var out: Dictionary = circuit.outputs()
	var rings: Array = greybox.dressing.column_rings
	if rings.size() >= 5:
		_set_glow(rings[0], bool(out["maintenance"]), CYAN)
		_set_glow(rings[1], bool(out["diagnostic"]), CYAN)
		_set_glow(rings[2], bool(out["archive"]), CYAN)
		_set_glow(rings[3], bool(out["trial"]), CYAN)
		_set_glow(rings[4], true, GREEN if circuit.protection_available else RED)
	var strips: Dictionary = greybox.dressing.indicators
	if strips.has("archive"):
		_set_glow(strips["archive"], bool(out["archive"]) or (circuit.destination == CircuitModel.ARCHIVE and circuit.protection_available), AMBER)
		_set_glow(strips["trial"], bool(out["trial"]) or circuit.fault_present(), AMBER)
		_set_glow(strips["protection"], true, GREEN if circuit.protection_available else RED)
	_set_glow(greybox.dressing.archive_screen, bool(out["archive"]), CYAN)


# --- plumbing -------------------------------------------------------------------------------------------------

func _banner(title: String, body: String, accent: Color, seconds: float) -> void:
	if greybox != null and greybox.hud != null:
		greybox.hud.call("show_banner", title, body, accent, seconds)


func _sound(stream: AudioStream) -> void:
	if _audio != null and stream != null:
		_audio.stream = stream
		_audio.play()


func _log(id: String, detail: String = "") -> void:
	var stamp: float = Time.get_ticks_msec() / 1000.0
	events.append({"t": stamp, "id": id, "detail": detail})
	print("[phase1 %.1fs] %s %s" % [stamp, id, detail])
