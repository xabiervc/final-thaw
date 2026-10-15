shader_type spatial;
// Helix Station B surfaces (docs/art/ASSET_PRODUCTION_BIBLE.md, "Helix Station B"), Compatibility renderer.
// World-space projected PBR set (albedo, OpenGL normal, ARM) so batched, split and reused geometry never shows seams.
// Optional second set below `dado_height` (glazed tile under brick) with a dark bullnose line; wear that follows causes:
// grime toward each storey's floor, flood tide lines at fixed world heights, vertical streaks, a damp band.
// `triplanar` blends three projections for curved kit pieces (pipes, machinery); walls and slabs use the cheaper
// dominant-axis projection.

uniform sampler2D albedo_a : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_a : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D arm_a : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 tint_a : source_color = vec3(1.0);
uniform float tile_a = 3.0;
uniform float saturation_a = 1.0;
uniform sampler2D albedo_b : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_b : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D arm_b : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 tint_b : source_color = vec3(1.0);
uniform float tile_b = 1.5;
uniform float saturation_b = 1.0;
// Turn the B set a quarter (long glazed tiles laid horizontally).
uniform bool rotate_b = false;
// Dado: below this height above the storey floor the B set is used. Negative = no dado.
uniform float dado_height = -1.0;
uniform vec3 cap_color : source_color = vec3(0.12, 0.2, 0.16);
uniform float cap_width = 0.07;
uniform sampler2D noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float normal_strength = 1.0;
uniform float metallic_amount = 0.0;
uniform float roughness_bias = 0.0;
uniform float grime_height = 1.2;
uniform float grime_strength = 0.35;
uniform float streak_strength = 0.25;
// Flood marks at absolute world heights (the March flood filled the pit to -1.35 and P0 to 0.35).
uniform float tide_a_y = -1.35;
uniform float tide_b_y = 0.35;
uniform float tide_strength = 0.5;
uniform bool triplanar = false;
uniform bool is_floor = false;

#include "res://assets/shaders/illustrated_light.gdshaderinc"

varying vec3 wpos;
varying vec3 wnrm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

// Storey datum below a point (P-1 -2, P0 0, M 3, P2 6; the yard is at -2).
float datum(float y) {
	return y >= 5.95 ? 6.0 : (y >= 2.95 ? 3.0 : (y >= -0.05 ? 0.0 : -2.0));
}

vec3 desat(vec3 c, float s) {
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	return mix(vec3(l), c, s);
}

// One projection: uv, and the world tangent frame of that plane.
void plane_uv(int axis, vec3 p, vec3 n, out vec2 uv, out vec3 t, out vec3 b) {
	if (axis == 0) {
		uv = vec2(p.z * sign(n.x), p.y);
		t = vec3(0.0, 0.0, sign(n.x));
		b = vec3(0.0, 1.0, 0.0);
	} else if (axis == 1) {
		uv = vec2(p.x, -p.z * sign(n.y));
		t = vec3(1.0, 0.0, 0.0);
		b = vec3(0.0, 0.0, -sign(n.y));
	} else {
		uv = vec2(-p.x * sign(n.z), p.y);
		t = vec3(-sign(n.z), 0.0, 0.0);
		b = vec3(0.0, 1.0, 0.0);
	}
}

// Normal maps are imported RGTC (two channels, VRAM compressed), so Z is rebuilt from XY.
vec3 decode_normal(vec2 rg) {
	vec2 xy = rg * 2.0 - 1.0;
	float z = sqrt(max(0.0, 1.0 - dot(xy, xy)));
	return vec3(xy * normal_strength, max(z, 0.05));
}

void sample_set(sampler2D al, sampler2D nm, sampler2D ar, vec3 p, vec3 n, float tile, bool rot, out vec3 col, out vec3 arm, out vec3 nw) {
	vec3 w = abs(n);
	if (!triplanar) {
		int axis = (w.x >= w.y && w.x >= w.z) ? 0 : ((w.y >= w.z) ? 1 : 2);
		vec2 uv;
		vec3 t;
		vec3 b;
		plane_uv(axis, p, n, uv, t, b);
		if (rot) {
			uv = vec2(uv.y, -uv.x);
			vec3 tmp = t;
			t = b;
			b = -tmp;
		}
		uv /= tile;
		col = texture(al, uv).rgb;
		arm = texture(ar, uv).rgb;
		vec3 tn = decode_normal(texture(nm, uv).rg);
		nw = normalize(t * tn.x + b * tn.y + n * tn.z);
	} else {
		vec3 bw = pow(w, vec3(4.0));
		bw /= (bw.x + bw.y + bw.z);
		col = vec3(0.0);
		arm = vec3(0.0);
		nw = vec3(0.0);
		for (int axis = 0; axis < 3; axis++) {
			float k = axis == 0 ? bw.x : (axis == 1 ? bw.y : bw.z);
			if (k < 0.02) {
				continue;
			}
			vec2 uv;
			vec3 t;
			vec3 b;
			plane_uv(axis, p, n, uv, t, b);
			uv /= tile;
			col += texture(al, uv).rgb * k;
			arm += texture(ar, uv).rgb * k;
			vec3 tn = decode_normal(texture(nm, uv).rg);
			nw += (t * tn.x + b * tn.y + n * tn.z) * k;
		}
		nw = normalize(nw);
	}
}

void fragment() {
	vec3 n = normalize(wnrm);
	vec3 w = abs(n);
	float floor_y = datum(wpos.y + 0.01);
	float h = wpos.y - floor_y;
	vec3 col;
	vec3 arm;
	vec3 nw;
	sample_set(albedo_a, normal_a, arm_a, wpos, n, tile_a, false, col, arm, nw);
	col = desat(col, saturation_a) * tint_a;
	float vertical = 1.0 - w.y;
	if (dado_height > 0.0 && vertical > 0.5 && h < dado_height + 0.12) {
		vec3 col_b;
		vec3 arm_b2;
		vec3 nw_b;
		sample_set(albedo_b, normal_b, arm_b, wpos, n, tile_b, rotate_b, col_b, arm_b2, nw_b);
		col_b = desat(col_b, saturation_b) * tint_b;
		float below = 1.0 - step(dado_height, h);
		col = mix(col, col_b, below);
		arm = mix(arm, arm_b2, below);
		nw = normalize(mix(nw, nw_b, below));
		// bullnose cap: a dark glazed band on top of the tiles
		float cap = step(dado_height - cap_width, h) * (1.0 - step(dado_height, h));
		col = mix(col, cap_color, cap);
		arm = mix(arm, vec3(1.0, 0.3, 0.0), cap);
	}
	float rough = clamp(arm.g + roughness_bias, 0.04, 1.0);
	float nz = texture(noise_tex, vec2(wpos.x + wpos.z, wpos.y) * 0.17).r;
	float nz2 = texture(noise_tex, wpos.xz * 0.09 + vec2(wpos.y * 0.05)).r;

	if (!is_floor) {
		// grime toward the storey floor, broken up by noise
		float grime = (1.0 - smoothstep(0.0, grime_height, h)) * grime_strength * vertical;
		col *= 1.0 - grime * (0.55 + 0.45 * nz);
		// vertical streaks: long, thin, irregular
		float along = (w.x > w.z) ? wpos.z : wpos.x;
		float st = texture(noise_tex, vec2(along * 0.9, wpos.y * 0.035)).r;
		col *= 1.0 - smoothstep(0.55, 0.85, st) * streak_strength * vertical;
		// flood tide lines with a damp band below them
		for (int i = 0; i < 2; i++) {
			float ty = i == 0 ? tide_a_y : tide_b_y;
			if (wpos.y < ty + 0.4 && wpos.y > ty - 2.5 && tide_strength > 0.0) {
				float edge = ty + (nz - 0.5) * 0.12;
				float below = 1.0 - smoothstep(edge - 0.02, edge + 0.02, wpos.y);
				float line = exp(-abs(wpos.y - edge) * 34.0);
				col *= 1.0 - vertical * tide_strength * (below * 0.3 + line * 0.55);
				col = mix(col, col * vec3(0.88, 0.9, 0.84), below * vertical * tide_strength);
				rough = mix(rough, rough * 0.6, below * vertical * tide_strength);
			}
		}
	} else {
		// floors: darker and smoother toward the walls is done by the dressing decals; here only broad mottling
		col *= 0.88 + 0.24 * nz2;
	}

	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = metallic_amount * arm.b;
	AO = arm.r;
	AO_LIGHT_AFFECT = 0.5;
	NORMAL = normalize((VIEW_MATRIX * vec4(nw, 0.0)).xyz);
}
