shader_type spatial;
// Facility floor for Final Thaw (Compatibility renderer).
// Worn concrete (world-space photo texture) with expansion joints, edge grime and standing meltwater.
// Puddles come from a fixed-seed noise texture, so they are deterministic and always in the same place.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D arm_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_tex : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 tint : source_color = vec3(0.5, 0.53, 0.55);
uniform float tile_m = 3.0;
uniform float joint_spacing = 4.0;
uniform float wetness = 0.05;          // 0 = dry floor, 1 = flooded
uniform float puddle_scale = 0.12;
uniform vec4 room_bounds = vec4(-12.0, -8.0, 12.0, 8.0); // x0, z0, x1, z1: grime gathers along the walls
// Local wet spots (x, z, radius_x, radius_z) where water gathers more, e.g. under a leaking shutter.
uniform vec4 wet_spot_a = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 wet_spot_b = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec3 puddle_sheen : source_color = vec3(0.05, 0.07, 0.09);

#include "res://assets/shaders/illustrated_light.gdshaderinc"

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 uv = wpos.xz / tile_m;
	vec3 base = texture(albedo_tex, uv).rgb;
	vec3 arm = texture(arm_tex, uv).rgb;
	float lum = dot(base, vec3(0.299, 0.587, 0.114));
	vec3 col = mix(vec3(lum), base, 0.3) * tint * 1.7;
	float rough = arm.g;

	// Expansion joints.
	vec2 g = abs(fract(wpos.xz / joint_spacing + 0.5) - 0.5) * joint_spacing;
	vec2 fw = fwidth(wpos.xz) * 1.4;
	float joint = 1.0 - smoothstep(vec2(0.0), fw + 0.012, g).x * smoothstep(vec2(0.0), fw + 0.012, g).y;
	col *= 1.0 - joint * 0.5;

	// Grime along the walls.
	float d_wall = min(min(wpos.x - room_bounds.x, room_bounds.z - wpos.x), min(wpos.z - room_bounds.y, room_bounds.w - wpos.z));
	float n = texture(noise_tex, wpos.xz * 0.21).r;
	col *= 1.0 - (1.0 - smoothstep(0.0, 1.6, d_wall + (n - 0.5) * 0.8)) * 0.45;

	// Standing meltwater: dark, smooth, mirror-like patches with a damp rim.
	float p = texture(noise_tex, wpos.xz * puddle_scale).r + (n - 0.5) * 0.12;
	float spot = 0.0;
	if (wet_spot_a.z > 0.0) {
		spot = max(spot, 1.0 - smoothstep(0.4, 1.0, length((wpos.xz - wet_spot_a.xy) / wet_spot_a.zw)));
	}
	if (wet_spot_b.z > 0.0) {
		spot = max(spot, 1.0 - smoothstep(0.4, 1.0, length((wpos.xz - wet_spot_b.xy) / wet_spot_b.zw)));
	}
	float threshold = mix(0.86, 0.45, wetness) - spot * 0.3;
	float puddle = smoothstep(threshold, threshold + 0.06, p);
	float damp = smoothstep(threshold - 0.12, threshold, p);
	col *= 1.0 - damp * 0.12;
	col = mix(col, col * vec3(0.6, 0.66, 0.72), puddle);
	rough = mix(rough, rough * 0.6, damp);
	rough = mix(rough, 0.16, puddle);

	ALBEDO = col;
	ROUGHNESS = rough;
	METALLIC = 0.0;
	// The environment has no specular (illustrated_light.gdshaderinc): standing water reads as a cool painted sheen
	// that grows at grazing angles instead of a reflection.
	float grazing = 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	EMISSION = puddle_sheen * puddle * (0.35 + 0.65 * grazing * grazing);
	NORMAL_MAP = mix(texture(normal_tex, uv).rgb, vec3(0.5, 0.5, 1.0), damp);
	NORMAL_MAP_DEPTH = 0.6;
}
