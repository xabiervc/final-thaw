// Facility architecture surface for Final Thaw (Compatibility renderer).
// World-space projected photo texture + the "meltwater line": a dark tide stain and wet band near the floor,
// grime that darkens towards the base, panel seams and optional frost near the top. No UVs required.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D arm_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(0.55, 0.6, 0.64);
uniform float tile_m = 3.0;
uniform float metallic_amount = 0.0;
uniform float roughness_bias = 0.0;
// Meltwater line: height of the last flood, in metres above the floor. Negative disables it.
uniform float tide_height = 0.55;
uniform float grime_height = 1.4;
uniform float grime_strength = 0.45;
// Panel seams (metres between vertical seams, 0 = none) and horizontal seam heights.
uniform float seam_spacing = 2.0;
uniform float seam_height_a = 1.2;
uniform float seam_height_b = 2.6;
uniform float seam_darkness = 0.55;
// Frost creeping from the top edge (0 = none).
uniform float frost_amount = 0.0;
uniform float frost_start = 2.4;
// Cutaway: 0 = solid, 1 = gone. Ordered-dither discard, so it stays in the opaque pipeline (works on Compatibility).
uniform float dither_fade = 0.0;

varying vec3 wpos;
varying vec3 wnrm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// The architecture is axis-aligned boxes, so one projection along the dominant normal axis is enough
// (a third of the texture fetches of a blended triplanar, which matters on integrated GPUs).
vec2 project(vec3 p, vec3 w) {
	if (w.x >= w.y && w.x >= w.z) {
		return p.zy;
	}
	if (w.y >= w.z) {
		return p.xz;
	}
	return p.xy;
}

float seam_line(float coord, float spacing, float width_px) {
	float d = abs(fract(coord / spacing + 0.5) - 0.5) * spacing;
	return 1.0 - smoothstep(0.0, fwidth(coord) * width_px, d);
}

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = x + y * 4;
	float m[16] = float[](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
	return (m[i] + 0.5) / 16.0;
}

void fragment() {
	#ifdef CUTAWAY
	if (dither_fade > 0.0 && bayer4(FRAGCOORD.xy) < dither_fade) {
		discard;
	}
#endif
	vec3 w = abs(wnrm);
	vec2 uv = project(wpos, w) / tile_m;
	vec3 base = texture(albedo_tex, uv).rgb;
	vec3 arm = texture(arm_tex, uv).rgb;
	float n = texture(noise_tex, vec2(wpos.x + wpos.z, wpos.y) * 0.18).r;
	float n2 = texture(noise_tex, wpos.xz * 0.11 + vec2(wpos.y * 0.07)).r;

	// Desaturate the photo and push it into the facility palette.
	float lum = dot(base, vec3(0.299, 0.587, 0.114));
	vec3 col = mix(vec3(lum), base, 0.35) * tint * 1.6;
	float rough = clamp(arm.g + roughness_bias, 0.05, 1.0);

	// Grime gradient towards the floor (vertical faces only).
	float vertical = 1.0 - w.y;
	float grime = (1.0 - smoothstep(0.0, grime_height, wpos.y)) * grime_strength * vertical;
	col *= 1.0 - grime * (0.6 + 0.4 * n);

	// Meltwater line: wobbling dark stain edge, darker wet band below it.
	if (tide_height > 0.0) {
		float edge = tide_height + (n - 0.5) * 0.16;
		float below = 1.0 - smoothstep(edge - 0.015, edge + 0.015, wpos.y);
		float stain = exp(-abs(wpos.y - edge) * 38.0);
		col *= 1.0 - vertical * (below * 0.28 + stain * 0.45);
		col = mix(col, col * vec3(0.86, 0.9, 0.84), below * vertical);
		rough = mix(rough, rough * 0.45, below * vertical);
	}

	// Panel seams: vertical every seam_spacing along the face, two horizontal joints.
	if (seam_spacing > 0.0) {
		float along = (w.x > w.z) ? wpos.z : wpos.x;
		float s = seam_line(along, seam_spacing, 1.6) * vertical;
		s = max(s, seam_line(wpos.y - seam_height_a, 100.0, 1.6) * vertical);
		s = max(s, seam_line(wpos.y - seam_height_b, 100.0, 1.6) * vertical);
		col *= 1.0 - s * seam_darkness;
	}

	// Frost: pale crystalline crust from the top edge down, broken up by noise.
	if (frost_amount > 0.0) {
		float f = smoothstep(frost_start, frost_start + 0.7, wpos.y + (n2 - 0.5) * 0.9) * frost_amount;
		f *= smoothstep(0.35, 0.65, n2 + n * 0.3);
		col = mix(col, vec3(0.78, 0.86, 0.9), clamp(f, 0.0, 0.85));
		rough = mix(rough, 0.35, f);
	}

	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = metallic_amount * arm.b;
	SPECULAR = 0.45;
}
