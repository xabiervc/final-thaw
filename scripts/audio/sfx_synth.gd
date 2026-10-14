extends RefCounted
## Small deterministic sound synthesiser: builds the Helix test bay's sound set as AudioStreamWAV at load time.
## Original work (no samples, no external assets). Every random source uses a fixed seed, so a given sound is
## identical on every run; variation between footsteps comes from distinct fixed-seed variants.
##
## Signals are generated as PackedFloat32Array in [-1, 1] and converted to 16-bit mono PCM.

const RATE := 22050


static func to_stream(samples: PackedFloat32Array, loop: bool = false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		var v := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, v)
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.stereo = false
	s.data = bytes
	if loop:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = 0
		s.loop_end = samples.size()
	return s


static func _buffer(seconds: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(seconds * RATE))
	return b


static func _rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r


## Attack/decay envelope in seconds.
static func _env(t: float, attack: float, decay: float) -> float:
	if t < attack:
		return t / maxf(attack, 0.0001)
	return exp(-(t - attack) / maxf(decay, 0.0001))


static func _normalize(b: PackedFloat32Array, peak: float) -> PackedFloat32Array:
	var m := 0.0
	for v in b:
		m = maxf(m, absf(v))
	if m > 0.0:
		for i in b.size():
			b[i] = b[i] / m * peak
	return b


## Crossfades the tail into the head so a loop has no click.
static func _make_loopable(b: PackedFloat32Array, fade_seconds: float) -> PackedFloat32Array:
	var n := int(fade_seconds * RATE)
	var size := b.size()
	var out := b.slice(0, size - n)
	for i in n:
		var k := float(i) / n
		out[i] = b[i] * k + b[size - n + i] * (1.0 - k)
	return out


# --- sounds ---------------------------------------------------------------------------------------------------------

## Room tone: low rumble of air handling and distant dripping water (looping).
static func room_tone() -> AudioStreamWAV:
	var b := _buffer(6.5)
	var r := _rng(11)
	var lp := 0.0
	var lp2 := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += 0.02 * (r.randf_range(-1.0, 1.0) - lp)
		lp2 += 0.08 * (lp - lp2)
		b[i] = lp2 * 6.0 + sin(TAU * 55.0 * t) * 0.02
	# Sparse drips at fixed times: short pitched blips with a falling chirp.
	for drip in [[0.8, 1400.0], [2.9, 1150.0], [4.4, 1650.0], [5.7, 1250.0]]:
		var start := int(float(drip[0]) * RATE)
		for j in int(0.09 * RATE):
			var t := float(j) / RATE
			var f: float = float(drip[1]) * (1.0 + 0.6 * exp(-t * 60.0))
			if start + j < b.size():
				b[start + j] += sin(TAU * f * t) * _env(t, 0.002, 0.02) * 0.12
	return to_stream(_make_loopable(_normalize(b, 0.5), 0.5), true)


## Generator running: 50 Hz mains hum with harmonics, slow beating and a mechanical rattle (looping).
static func generator_hum() -> AudioStreamWAV:
	var b := _buffer(2.2)
	var r := _rng(23)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += 0.15 * (r.randf_range(-1.0, 1.0) - lp)
		var hum := sin(TAU * 50.0 * t) * 0.5 + sin(TAU * 100.0 * t) * 0.3 + sin(TAU * 150.0 * t) * 0.15 + sin(TAU * 251.0 * t) * 0.06
		var rattle := lp * (0.6 + 0.4 * sin(TAU * 12.5 * t))
		b[i] = hum * (0.85 + 0.15 * sin(TAU * 2.5 * t)) + rattle * 0.35
	return to_stream(_make_loopable(_normalize(b, 0.6), 0.2), true)


## Generator alarm: soft two-tone pip, looped every 1.6 s (matches the beacon pulse period).
static func alarm_pip() -> AudioStreamWAV:
	var b := _buffer(1.6)
	for i in b.size():
		var t := float(i) / RATE
		var v := 0.0
		if t < 0.16:
			v = sin(TAU * 740.0 * t) * _env(t, 0.005, 0.06)
		elif t > 0.2 and t < 0.36:
			var u := t - 0.2
			v = sin(TAU * 587.0 * u) * _env(u, 0.005, 0.06)
		b[i] = v
	return to_stream(_normalize(b, 0.5), true)


## Lever: heavy mechanical thunk with a metallic latch click.
static func lever_clunk() -> AudioStreamWAV:
	var b := _buffer(0.45)
	var r := _rng(31)
	var hp_prev := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var thump := sin(TAU * (70.0 + 50.0 * exp(-t * 30.0)) * t) * _env(t, 0.002, 0.09)
		var n := r.randf_range(-1.0, 1.0)
		var click := (n - hp_prev) * _env(t, 0.0005, 0.012)
		hp_prev = n
		var ring := sin(TAU * 1830.0 * t) * _env(t, 0.001, 0.08) * 0.15
		b[i] = thump + click * 0.5 + ring
	return to_stream(_normalize(b, 0.85))


## Power coming online: relay clack, then a rising electrical swell.
static func power_up() -> AudioStreamWAV:
	var b := _buffer(1.8)
	var r := _rng(41)
	var lp := 0.0
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var f := 55.0 + 190.0 * (1.0 - exp(-t * 1.8))
		phase += TAU * f / RATE
		lp += 0.05 * (r.randf_range(-1.0, 1.0) - lp)
		var swell := minf(t / 1.2, 1.0) * exp(-maxf(t - 1.3, 0.0) * 6.0)
		var tone := (sin(phase) * 0.6 + sin(phase * 2.0) * 0.25 + sin(phase * 3.0) * 0.1) * swell
		var relay := r.randf_range(-1.0, 1.0) * _env(t, 0.0005, 0.01) * 0.8
		b[i] = tone + lp * 2.0 * swell + relay
	return to_stream(_normalize(b, 0.8))


## Power failing: falling tone that winds down.
static func power_down() -> AudioStreamWAV:
	var b := _buffer(1.2)
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var f := 240.0 * exp(-t * 2.2) + 30.0
		phase += TAU * f / RATE
		b[i] = (sin(phase) * 0.7 + sin(phase * 2.0) * 0.2) * exp(-t * 2.5)
	return to_stream(_normalize(b, 0.7))


## Terminal access: two clean ascending beeps.
static func terminal_beep() -> AudioStreamWAV:
	var b := _buffer(0.32)
	for i in b.size():
		var t := float(i) / RATE
		var v := 0.0
		if t < 0.11:
			v = sin(TAU * 988.0 * t) * _env(t, 0.004, 0.05)
		elif t > 0.13:
			var u := t - 0.13
			v = sin(TAU * 1319.0 * u) * _env(u, 0.004, 0.07)
		b[i] = v
	return to_stream(_normalize(b, 0.45))


## Access denied: two short low buzzes.
static func denied() -> AudioStreamWAV:
	var b := _buffer(0.36)
	for i in b.size():
		var t := float(i) / RATE
		var on := t < 0.12 or (t > 0.18 and t < 0.3)
		var u := t if t < 0.15 else t - 0.18
		var sq := 1.0 if sin(TAU * 146.0 * t) > 0.0 else -1.0
		b[i] = sq * 0.35 * (1.0 if on else 0.0) * _env(u, 0.004, 0.2)
	return to_stream(_normalize(b, 0.45))


## Bulkhead door: servo whine sliding the slab, ending in a seal clunk.
static func door_open() -> AudioStreamWAV:
	var b := _buffer(1.1)
	var r := _rng(53)
	var lp := 0.0
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var run := clampf(t / 0.08, 0.0, 1.0) * clampf((0.85 - t) / 0.08, 0.0, 1.0)
		var f := 190.0 + 70.0 * clampf(t / 0.8, 0.0, 1.0)
		phase += TAU * f / RATE
		var saw := fmod(phase / TAU, 1.0) * 2.0 - 1.0
		lp += 0.1 * (saw - lp)
		var hiss := r.randf_range(-1.0, 1.0) * 0.15 * run
		var thud := 0.0
		if t > 0.82:
			var u := t - 0.82
			thud = sin(TAU * 62.0 * u) * _env(u, 0.002, 0.07)
		b[i] = lp * 0.5 * run + hiss + thud
	return to_stream(_normalize(b, 0.7))


## Scan pulse: airy rising sweep with a shimmer.
static func scan_pulse() -> AudioStreamWAV:
	var b := _buffer(0.7)
	var phase := 0.0
	var phase2 := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var f := 420.0 + 1500.0 * (t / 0.7)
		phase += TAU * f / RATE
		phase2 += TAU * f * 1.502 / RATE
		b[i] = (sin(phase) * 0.6 + sin(phase2) * 0.25) * _env(t, 0.03, 0.22)
	return to_stream(_normalize(b, 0.4))


## Inspecting an object: soft tick.
static func inspect_tick() -> AudioStreamWAV:
	var b := _buffer(0.09)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = sin(TAU * 1600.0 * t) * _env(t, 0.001, 0.015) + sin(TAU * 800.0 * t) * _env(t, 0.001, 0.03) * 0.5
	return to_stream(_normalize(b, 0.35))


## Footstep on wet concrete: short filtered noise burst. variant selects a fixed seed (cosmetic variation).
static func footstep(variant: int) -> AudioStreamWAV:
	var b := _buffer(0.16)
	var r := _rng(100 + variant)
	var lp := 0.0
	var cutoff := 0.18 + 0.05 * variant
	for i in b.size():
		var t := float(i) / RATE
		lp += cutoff * (r.randf_range(-1.0, 1.0) - lp)
		var splash := r.randf_range(-1.0, 1.0) * _env(maxf(t - 0.02, 0.0), 0.004, 0.03) * 0.25
		b[i] = lp * _env(t, 0.002, 0.03) * 2.0 + splash
	return to_stream(_normalize(b, 0.3))


## Landing after a jump: dull thud.
static func land() -> AudioStreamWAV:
	var b := _buffer(0.22)
	var r := _rng(61)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += 0.12 * (r.randf_range(-1.0, 1.0) - lp)
		b[i] = sin(TAU * 80.0 * t) * _env(t, 0.002, 0.05) + lp * _env(t, 0.002, 0.04) * 1.5
	return to_stream(_normalize(b, 0.45))


## Room cleared: rising three-note chime.
static func complete_chime() -> AudioStreamWAV:
	var b := _buffer(1.6)
	var notes := [[0.0, 523.25], [0.14, 659.25], [0.28, 783.99], [0.42, 1046.5]]
	for i in b.size():
		var t := float(i) / RATE
		var v := 0.0
		for n in notes:
			var u: float = t - float(n[0])
			if u > 0.0:
				var f: float = n[1]
				v += (sin(TAU * f * u) + sin(TAU * f * 2.0 * u) * 0.2) * _env(u, 0.01, 0.5)
		b[i] = v
	return to_stream(_normalize(b, 0.5))
