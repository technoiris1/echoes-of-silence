shader_type spatial;
render_mode blend_add, unshaded, depth_draw_never, cull_disabled, depth_test_disabled;

void fragment() {
	vec3 glow_color = vec3(1.0, 0.85, 0.3);
	ALBEDO = glow_color * 2.0;
	EMISSION = glow_color * 8.0;
}