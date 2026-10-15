extends Node
## Adaptive music: three synchronised loop layers (investigation, tension, chase) always playing in step and
## crossfaded by gameplay state, plus a one-shot release for the escape. The layers are original placeholder
## music rendered by tools/audio/render_music.gd (see docs/art/ASSET_REGISTER.md); the mix logic is final.
##
## Modes, set by the scene from real game state (never from a timer):
##   investigation - Phase 1 exploration           tension - Containment, not detected / searching
##   chase         - the unit is alerted or chasing  release - Elena is out (ending)       silent

const LAYERS := {
	"investigation": "res://assets/audio/music/music_investigation.wav",
	"tension": "res://assets/audio/music/music_tension.wav",
	"chase": "res://assets/audio/music/music_chase.wav",
}
const RELEASE := "res://assets/audio/music/music_release.wav"
const FADE_RATE := 1.4  # linear volume per second (~0.7 s full crossfade)
const SILENT_DB := -60.0

var mode: String = "silent"
var _players: Dictionary = {}
var _levels: Dictionary = {}
var _release: AudioStreamPlayer


func _ready() -> void:
	GameSettings.ensure_buses()
	for key in LAYERS:
		var p := AudioStreamPlayer.new()
		p.bus = "Music"
		p.stream = load(LAYERS[key])  # forward loop set in the .import settings
		p.volume_db = SILENT_DB
		add_child(p)
		_players[key] = p
		_levels[key] = 0.0
	_release = AudioStreamPlayer.new()
	_release.bus = "Music"
	_release.stream = load(RELEASE)
	_release.volume_db = -4.0
	add_child(_release)


func set_mode(new_mode: String) -> void:
	if new_mode == mode:
		return
	mode = new_mode
	if mode == "release":
		_release.play()
	# All loops start together the first time any is needed, so they stay beat-aligned.
	if mode in _players and not (_players[mode] as AudioStreamPlayer).playing:
		for key in _players:
			(_players[key] as AudioStreamPlayer).play()


func _process(delta: float) -> void:
	for key in _players:
		var target := 1.0 if key == mode else 0.0
		var level := move_toward(float(_levels[key]), target, FADE_RATE * delta)
		_levels[key] = level
		var p := _players[key] as AudioStreamPlayer
		p.volume_db = SILENT_DB if level <= 0.001 else linear_to_db(level) - 3.0


func level(key: String) -> float:
	return float(_levels.get(key, 0.0))
