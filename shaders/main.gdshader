shader_type spatial;
render_mode depth_test_disabled, skip_vertex_transform, unshaded,
cull_disabled;

uniform vec4 albedo : source_color;

void vertex() {
	POSITION = vec4(VERTEX.x, -VERTEX.y, 0.0, 1.0);
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
