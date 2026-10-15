// Painterly light model shared by the station surfaces (docs/art/ASSET_PRODUCTION_BIBLE.md, "Illustrated style").
// Half-tone shading: a soft core-shadow step and a soft lit step instead of a smooth Lambert falloff, so form reads as
// painted planes; shadows stay coloured by the (cool) ambient, lights keep their (warm) colour.
// The environment is diffuse-only: highlights are painted into the textures, never computed. Per-light specular and the
// ambient specular path cost 2-3 ms at 720p on the reference GPU (Intel HD 630, Compatibility/ANGLE), measured
// 2026-10-15 with tools/capture/scene_capture.tscn --bench. Characters keep their own specular materials.

render_mode specular_disabled;

void light() {
	float ndl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float tone = smoothstep(0.02, 0.2, ndl) * 0.5 + smoothstep(0.3, 0.6, ndl) * 0.5;
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * tone * (1.0 - METALLIC * 0.75) / PI;
}
