shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_schlick_ggx, unshaded, depth_test_disabled;

uniform vec4 color : source_color;
uniform float color_intensity = 10.0;
uniform float transparency_level = 16.0;
uniform float speed = 0.0;
uniform float zoom_amplitude = 12.555;

void fragment() {
	ALPHA = pow(length(UV - vec2(0.5)),transparency_level + zoom_amplitude * sin(TIME * speed));
	ALBEDO.rgb = color.rgb * color_intensity;
}