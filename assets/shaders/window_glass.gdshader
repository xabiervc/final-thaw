shader_type spatial;
render_mode cull_disabled;
// Old wired glass at night (Helix Station B clerestory and facade windows): dark, grimy panes that pick up a little cold
// sky light, brighter toward the top of each window, with dirt streaks. Works on batched geometry (world position only).

uniform vec3 sky_color : source_color = vec3(0.32, 0.4, 0.55);
uniform float sky_energy = 0.32;
uniform sampler2D noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float n = texture(noise_tex, vec2(wpos.x + wpos.z, wpos.y * 0.4) * 0.6).r;
	float streak = texture(noise_tex, vec2((wpos.x + wpos.z) * 2.5, wpos.y * 0.08)).r;
	// brighter toward the top of the opening: each window spans ~3.8 m above its sill
	float up = fract((wpos.y - 5.0) / 3.8 * 0.999);
	float glow = sky_energy * (0.45 + 0.55 * smoothstep(0.0, 1.0, up)) * (0.75 + 0.5 * n) * (1.0 - smoothstep(0.55, 0.9, streak) * 0.6);
	ALBEDO = vec3(0.03, 0.035, 0.04);
	ROUGHNESS = 0.25 + n * 0.3;
	SPECULAR = 0.6;
	EMISSION = sky_color * glow;
}
