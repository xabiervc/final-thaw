class_name GameSettings
extends RefCounted
## Player options with a real effect on the game. GameManager.settings is the single persisted store (JSON/CRC32
## save, slot GameManager.settings_slot); this class only reads, validates and applies it.
##
##  difficulty          explorer | standard | demanding -> recovery-unit senses/speed, stamina drain (see DIFFICULTY)
##  camera_sensitivity  0.4..2.0 multiplier for mouse and right-stick look
##  invert_y            inverts vertical look
##  subtitles           show dialogue / announcement subtitles (cinematic text cards are always shown)
##  game_speed          0.5 | 0.75 | 1.0 global time scale for players who need more time (no penalty)
##  master/music/sfx_volume  0..1 linear, applied to the Master / Music / SFX buses
##  graphics            high (glow + sun shadows) | balanced (no glow) | performance (no glow, no sun shadows);
##                      measured on an Intel HD 630 at 720p (docs: PROJECT_STATUS.md performance section)

const DEFAULTS := {
	"difficulty": "standard",
	"camera_sensitivity": 1.0,
	"invert_y": false,
	"subtitles": true,
	"game_speed": 1.0,
	"master_volume": 0.9,
	"music_volume": 0.7,
	"sfx_volume": 0.9,
	"graphics": "balanced",
}
const GRAPHICS := ["high", "balanced", "performance"]
const DIFFICULTIES := ["explorer", "standard", "demanding"]
const GAME_SPEEDS := [0.5, 0.75, 1.0]
## Every difficulty changes what the recovery unit can do, never what the player can know: the unit's state is
## always shown (icon + eye) and every route stays the same.
const DIFFICULTY := {
	"explorer": {"vision_range": 7.0, "detect_time": 1.3, "alert_time": 0.95, "chase_speed": 4.7, "search_time": 2.5,
		"hearing": 0.7, "run_drain": 9.0, "sweep_speed": 2.6},
	"standard": {"vision_range": 9.0, "detect_time": 0.8, "alert_time": 0.55, "chase_speed": 5.3, "search_time": 3.5,
		"hearing": 1.0, "run_drain": 14.0, "sweep_speed": 3.0},
	"demanding": {"vision_range": 10.5, "detect_time": 0.6, "alert_time": 0.45, "chase_speed": 5.7, "search_time": 5.0,
		"hearing": 1.25, "run_drain": 16.0, "sweep_speed": 3.3},
}
const BUSES := ["Music", "SFX"]


static func get_value(key: String) -> Variant:
	var stored = GameManager.settings.get(key, DEFAULTS.get(key))
	return _validate(key, stored)


static func set_value(key: String, value: Variant) -> void:
	GameManager.settings[key] = _validate(key, value)
	apply()
	GameManager.stats_changed.emit()


static func _validate(key: String, value: Variant) -> Variant:
	match key:
		"difficulty":
			return str(value) if DIFFICULTIES.has(str(value)) else DEFAULTS["difficulty"]
		"camera_sensitivity":
			return clampf(float(value), 0.4, 2.0) if typeof(value) in [TYPE_FLOAT, TYPE_INT] else 1.0
		"invert_y", "subtitles":
			return bool(value) if typeof(value) == TYPE_BOOL else DEFAULTS[key]
		"game_speed":
			var v := float(value) if typeof(value) in [TYPE_FLOAT, TYPE_INT] else 1.0
			for s in GAME_SPEEDS:
				if is_equal_approx(v, s):
					return s
			return 1.0
		"graphics":
			return str(value) if GRAPHICS.has(str(value)) else DEFAULTS["graphics"]
		"master_volume", "music_volume", "sfx_volume":
			return clampf(float(value), 0.0, 1.0) if typeof(value) in [TYPE_FLOAT, TYPE_INT] else DEFAULTS[key]
	return value


static func difficulty() -> String:
	return str(get_value("difficulty"))


## A numeric parameter of the current difficulty (DIFFICULTY table).
static func tuning(param: String) -> float:
	return float((DIFFICULTY[difficulty()] as Dictionary).get(param, 0.0))


static func graphics() -> String:
	return str(get_value("graphics"))


## Applies the graphics preset to a scene's environment and sun (each 3D scene calls this with its own nodes).
static func apply_graphics(env: Environment, sun: DirectionalLight3D) -> void:
	var g := graphics()
	if env != null:
		env.glow_enabled = g == "high"
	if sun != null:
		sun.shadow_enabled = g != "performance"
		# Without its shadow the moon would light every interior through the roofs: on "performance" it lights only
		# the outdoors (yard band) and characters.
		sun.light_cull_mask = 0xFFFFF if g != "performance" else (1 | (1 << 5))


static func subtitles_enabled() -> bool:
	return bool(get_value("subtitles"))


static func look_sensitivity() -> float:
	return float(get_value("camera_sensitivity"))


static func invert_y() -> bool:
	return bool(get_value("invert_y"))


## Applies everything that lives outside a scene: time scale and bus volumes. Safe to call at any time.
static func apply() -> void:
	Engine.time_scale = float(get_value("game_speed"))
	ensure_buses()
	_set_bus_volume("Master", float(get_value("master_volume")))
	_set_bus_volume("Music", float(get_value("music_volume")))
	_set_bus_volume("SFX", float(get_value("sfx_volume")))


## The project has only the Master bus in its default layout; Music and SFX are created at runtime (routed to Master).
static func ensure_buses() -> void:
	for bus_name in BUSES:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			var idx := AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, bus_name)
			AudioServer.set_bus_send(idx, "Master")


static func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, linear <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.001)))
