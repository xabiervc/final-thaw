extends SceneTree
## Renders the adaptive music layers of scripts/audio/game_synth.gd to assets/audio/music/*.wav (deterministic).
## Run: godot --headless --path . --script res://tools/audio/render_music.gd
## Loops are crossfaded tail-to-head so they repeat without a click; loop points are set in the .import files.

const G := preload("res://scripts/audio/game_synth.gd")
const S := preload("res://scripts/audio/sfx_synth.gd")
const OUT := "res://assets/audio/music/"


func _init() -> void:
	var layers := {
		"music_investigation": [G.music_investigation(), true],
		"music_tension": [G.music_tension(), true],
		"music_chase": [G.music_chase(), true],
		"music_release": [G.music_release(), false],
	}
	for name in layers:
		var samples: PackedFloat32Array = layers[name][0]
		var loop: bool = layers[name][1]
		if loop:
			samples = S._make_loopable(samples, 0.4)
		var stream := S.to_stream(samples, loop)
		var path := ProjectSettings.globalize_path(OUT + name + ".wav")
		var err := stream.save_to_wav(path)
		print("%s: %.1f s -> %s (%s)" % [name, samples.size() / float(S.RATE), path, error_string(err)])
	quit()
