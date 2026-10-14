shader_type spatial;
// Worn diagonal hazard paint (yellow/black) in world space, for barrier tops, door jambs and floor edges.
// Not emissive: hazard paint is a surface, not a light (emissive amber is reserved for interactables).

uniform sampler2D noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 paint_a : source_color = vec3(0.78, 0.56, 0.1);
uniform vec3 paint_b : source_color = vec3(0.045, 0.045, 0.05);
uniform float stripe_m = 0.22;
uniform float wear = 0.35;

varying vec3 wpos;
varying vec3 wnrm;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 a = abs(wnrm);
	vec2 p = a.y > 0.5 ? wpos.xz : (a.x > a.z ? vec2(wpos.z, wpos.y) : vec2(wpos.x, wpos.y));
	float t = fract((p.x + p.y) / stripe_m);
	float aa = fwidth((p.x + p.y) / stripe_m);
	float stripe = smoothstep(0.5 - aa, 0.5 + aa, t) * (1.0 - smoothstep(1.0 - aa, 1.0, t));
	vec3 col = mix(paint_a, paint_b, stripe);
	float n = texture(noise_tex, p * 0.9).r;
	float scuff = smoothstep(1.0 - wear, 1.0 - wear + 0.12, n);
	col = mix(col, vec3(0.16, 0.17, 0.18), scuff * 0.85);
	ALBEDO = col;
	ROUGHNESS = mix(0.7, 0.9, scuff);
	METALLIC = scuff * 0.4;
}
