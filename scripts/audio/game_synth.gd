extends RefCounted
## Deterministic synthesiser for the Phase 1/2 game: machine sounds of the recovery unit, facility response cues
## and the adaptive music layers. Original work, no samples. Fixed seeds: identical on every run.
##
## Short effects are generated at runtime (fractions of a second). Music layers are long, so they are rendered
## offline by tools/audio/render_music.gd into assets/audio/music/*.wav and loaded as resources.
## These are functional placeholders, not final audio (see docs/art/ASSET_REGISTER.md).

const S := preload("res://scripts/audio/sfx_synth.gd")
const RATE := 22050


static func _osc_saw(phase: float) -> float:
	return 2.0 * (phase - floor(phase + 0.5))


# --- recovery unit ------------------------------------------------------------------------------------------------

## Electric drive whine with a slow load wobble (looping, 1 s).
static func servo_hum() -> AudioStreamWAV:
	var b := S._buffer(1.0)
	var r := S._rng(301)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += 0.05 * (r.randf_range(-1.0, 1.0) - lp)
		var whine := sin(TAU * 180.0 * t) * 0.35 + sin(TAU * 360.0 * t) * 0.12 + sin(TAU * 541.0 * t) * 0.05
		b[i] = whine * (0.8 + 0.2 * sin(TAU * 3.0 * t)) + lp * 1.4
	return S.to_stream(S._make_loopable(S._normalize(b, 0.55), 0.08), true)


## Alert: a rising two-tone electronic stab, unmistakable but short.
static func alert_sting() -> AudioStreamWAV:
	var b := S._buffer(0.7)
	for i in b.size():
		var t := float(i) / RATE
		var f := 520.0 if t < 0.18 else 780.0
		var u := t if t < 0.18 else t - 0.18
		b[i] = (sin(TAU * f * t) + 0.4 * _osc_saw(f * t)) * S._env(u, 0.004, 0.16)
	return S.to_stream(S._normalize(b, 0.7))


## Heavy track/foot thump with a metallic clank.
static func heavy_step() -> AudioStreamWAV:
	var b := S._buffer(0.35)
	var r := S._rng(311)
	for i in b.size():
		var t := float(i) / RATE
		var thump := sin(TAU * (70.0 + 60.0 * exp(-t * 30.0)) * t) * S._env(t, 0.002, 0.07)
		var clank := r.randf_range(-1.0, 1.0) * S._env(t, 0.001, 0.02) * 0.4 + sin(TAU * 1830.0 * t) * S._env(t, 0.001, 0.05) * 0.15
		b[i] = thump + clank
	return S.to_stream(S._normalize(b, 0.8))


# --- facility -------------------------------------------------------------------------------------------------------

## Public-address chime before an announcement: three descending tones.
static func pa_chime() -> AudioStreamWAV:
	var b := S._buffer(1.3)
	for i in b.size():
		var t := float(i) / RATE
		var v := 0.0
		for k in 3:
			var start := 0.0 + k * 0.32
			var f: float = [784.0, 659.3, 523.3][k]
			if t >= start:
				var u := t - start
				v += (sin(TAU * f * u) + 0.25 * sin(TAU * f * 2.0 * u)) * S._env(u, 0.01, 0.35)
		b[i] = v
	return S.to_stream(S._normalize(b, 0.55))


## Compressor running: motor rumble with an 8 Hz piston chug (looping, 1.5 s). Used as a noise distraction.
static func compressor_run() -> AudioStreamWAV:
	var b := S._buffer(1.5)
	var r := S._rng(321)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += 0.2 * (r.randf_range(-1.0, 1.0) - lp)
		var chug := 0.5 + 0.5 * maxf(0.0, sin(TAU * 8.0 * t))
		b[i] = (sin(TAU * 48.0 * t) * 0.5 + sin(TAU * 96.0 * t) * 0.25 + lp * 0.9) * chug
	return S.to_stream(S._make_loopable(S._normalize(b, 0.75), 0.1), true)


## Roller shutter travelling: slat rattle over a motor tone (2.4 s).
static func shutter_roll() -> AudioStreamWAV:
	var b := S._buffer(2.4)
	var r := S._rng(331)
	for i in b.size():
		var t := float(i) / RATE
		var rattle := r.randf_range(-1.0, 1.0) * (0.5 + 0.5 * sin(TAU * 22.0 * t)) * 0.6
		var motor := sin(TAU * 110.0 * t) * 0.3
		b[i] = (rattle + motor) * minf(1.0, t * 6.0) * minf(1.0, (2.4 - t) * 4.0)
	return S.to_stream(S._normalize(b, 0.7))


## Heavy gate / barrier: low impact and a long metallic ring.
static func gate_clank() -> AudioStreamWAV:
	var b := S._buffer(1.4)
	var r := S._rng(341)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = sin(TAU * 62.0 * t) * S._env(t, 0.002, 0.12) + r.randf_range(-1.0, 1.0) * S._env(t, 0.001, 0.03) * 0.5 \
			+ (sin(TAU * 412.0 * t) + sin(TAU * 637.0 * t) * 0.6) * S._env(t, 0.003, 0.45) * 0.2
	return S.to_stream(S._normalize(b, 0.75))


## Checkpoint / note recorded: a soft two-note confirmation (quieter than the puzzle chime).
static func note_tick() -> AudioStreamWAV:
	var b := S._buffer(0.5)
	for i in b.size():
		var t := float(i) / RATE
		var v := sin(TAU * 880.0 * t) * S._env(t, 0.004, 0.08)
		if t > 0.09:
			v += sin(TAU * 1318.5 * (t - 0.09)) * S._env(t - 0.09, 0.004, 0.12)
		b[i] = v
	return S.to_stream(S._normalize(b, 0.45))


# --- music (rendered offline by tools/audio/render_music.gd) ------------------------------------------------------

## Investigation: a low D drone with a slowly breathing fifth, filtered air and sparse glassy tones. Unease, not
## threat (24 s loop).
static func music_investigation() -> PackedFloat32Array:
	var seconds := 24.0
	var b := S._buffer(seconds)
	var r := S._rng(401)
	var lp := 0.0
	var bells := [[1.5, 587.3], [6.2, 698.5], [11.0, 523.3], [15.8, 880.0], [19.4, 659.3]]
	for i in b.size():
		var t := float(i) / RATE
		var breathe := 0.5 + 0.5 * sin(TAU * t / seconds)
		lp += 0.004 * (r.randf_range(-1.0, 1.0) - lp)
		var drone := sin(TAU * 73.42 * t) * 0.5 + sin(TAU * 73.62 * t) * 0.3 + sin(TAU * 110.0 * t) * 0.18 * breathe
		var bell := 0.0
		for bl in bells:
			if t >= bl[0]:
				var u: float = t - float(bl[0])
				bell += (sin(TAU * float(bl[1]) * u) + 0.3 * sin(TAU * float(bl[1]) * 2.01 * u)) * S._env(u, 0.02, 1.6) * 0.12
		b[i] = drone * 0.55 + lp * 9.0 + bell
	return S._normalize(b, 0.55)


## Containment, quiet: the drone darkens, a low heartbeat-like pulse at 72 bpm and a minor-second rub (16 s loop,
## a whole number of beats).
static func music_tension() -> PackedFloat32Array:
	var beat := 60.0 / 72.0
	var seconds := beat * 20.0
	var b := S._buffer(seconds)
	var r := S._rng(411)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var pos := fmod(t, beat)
		var pulse := sin(TAU * 55.0 * pos) * S._env(pos, 0.004, 0.09) + 0.6 * sin(TAU * 52.0 * maxf(pos - 0.22, 0.0)) * (S._env(pos - 0.22, 0.004, 0.08) if pos > 0.22 else 0.0)
		lp += 0.006 * (r.randf_range(-1.0, 1.0) - lp)
		var rub := (sin(TAU * 146.8 * t) + sin(TAU * 155.6 * t)) * 0.08 * (0.6 + 0.4 * sin(TAU * t / seconds))
		b[i] = sin(TAU * 73.42 * t) * 0.3 + pulse * 0.7 + rub + lp * 6.0
	return S._normalize(b, 0.6)


## Chase: driving eighth-note bass at 128 bpm, off-beat ticks and a rising tension tone (7.5 s = 16 beats).
static func music_chase() -> PackedFloat32Array:
	var beat := 60.0 / 128.0
	var seconds := beat * 16.0
	var b := S._buffer(seconds)
	var r := S._rng(421)
	var notes := [73.42, 73.42, 87.31, 73.42, 98.0, 73.42, 87.31, 82.41]
	for i in b.size():
		var t := float(i) / RATE
		var eighth := beat * 0.5
		var k := int(t / eighth)
		var pos := fmod(t, eighth)
		var f: float = notes[k % notes.size()]
		var bass := (_osc_saw(f * t) * 0.6 + sin(TAU * f * t) * 0.5) * S._env(pos, 0.003, 0.12)
		var tick := 0.0
		if k % 2 == 1:
			tick = r.randf_range(-1.0, 1.0) * S._env(pos, 0.001, 0.015) * 0.35
		var kick := sin(TAU * (60.0 + 80.0 * exp(-fmod(t, beat) * 40.0)) * fmod(t, beat)) * S._env(fmod(t, beat), 0.002, 0.1)
		var rise := sin(TAU * (293.7 + 30.0 * t / seconds) * t) * 0.07
		b[i] = bass * 0.55 + tick + kick * 0.6 + rise
	return S._normalize(b, 0.7)


## Escape / ending: a warm open chord that settles (10 s, not looped).
static func music_release() -> PackedFloat32Array:
	var seconds := 10.0
	var b := S._buffer(seconds)
	for i in b.size():
		var t := float(i) / RATE
		var v := 0.0
		for f in [146.83, 220.0, 293.66, 369.99, 440.0]:
			v += sin(TAU * f * t) * 0.2 + sin(TAU * f * 1.003 * t) * 0.1
		b[i] = v * minf(1.0, t / 2.5) * minf(1.0, (seconds - t) / 4.0)
	return S._normalize(b, 0.5)
