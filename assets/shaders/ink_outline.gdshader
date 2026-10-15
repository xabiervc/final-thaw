shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled, cull_disabled, blend_mix, fog_disabled, shadows_disabled;
// Illustrated ink outline (docs/art/ASSET_PRODUCTION_BIBLE.md, "Illustrated style"): one full-screen pass over the opaque
// scene that draws controlled, depth-aware lines on silhouettes and creases. A plane's inverse depth is linear across the
// screen, so its Laplacian is ~0 on flat surfaces and large at depth breaks (silhouettes) and folds (creases); lines fade
// with distance so far geometry never turns into scribble. Drawn on a quad that covers the screen (child of the camera).

uniform sampler2D depth_tex : hint_depth_texture, filter_nearest, repeat_disable;
uniform vec3 ink : source_color = vec3(0.07, 0.065, 0.075);
uniform float strength = 0.8;
uniform float width_px = 1.0;
uniform float silhouette = 0.06;
uniform float near_fade = 32.0;
uniform float far_fade = 70.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float view_depth(vec2 uv, mat4 inv_proj) {
	float d = texture(depth_tex, uv).r;
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(uv * 2.0 - 1.0, d * 2.0 - 1.0);
#else
	vec3 ndc = vec3(uv * 2.0 - 1.0, d);
#endif
	vec4 v = inv_proj * vec4(ndc, 1.0);
	return -v.z / v.w;
}

void fragment() {
	vec2 e = width_px / VIEWPORT_SIZE;
	float c = view_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
	float l = view_depth(SCREEN_UV - vec2(e.x, 0.0), INV_PROJECTION_MATRIX);
	float r = view_depth(SCREEN_UV + vec2(e.x, 0.0), INV_PROJECTION_MATRIX);
	float u = view_depth(SCREEN_UV - vec2(0.0, e.y), INV_PROJECTION_MATRIX);
	float d = view_depth(SCREEN_UV + vec2(0.0, e.y), INV_PROJECTION_MATRIX);
	// Laplacian of inverse depth, relative: zero on planes, strong on breaks and folds.
	float ic = 1.0 / c;
	float lap = abs((1.0 / l + 1.0 / r + 1.0 / u + 1.0 / d) - 4.0 * ic) / ic;
	float edge = smoothstep(silhouette * 0.5, silhouette, lap);
	edge *= 1.0 - smoothstep(near_fade, far_fade, c);
	ALBEDO = ink;
	ALPHA = clamp(edge * strength, 0.0, 1.0);
}
