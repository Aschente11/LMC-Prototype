shader_type spatial;
render_mode unshaded;

/*
RING SHADER
*/


uniform vec3 ring_color: source_color = vec3(1.0);
uniform float ring_frequency = 50.0;
/** Portion of the visible rings. Negative values give wider rings, positive values give narrower rings*/
uniform float ring_portion: hint_range(-0.9, 0.9, 0.1) = 0.0;
/** Negative values move the rings outwards, positive value move the rings inwards */
uniform float move_speed = -10.0;
uniform bool smooth_edge = false;

void fragment() {
	float dist = distance(UV, vec2(0.5,0.5));
	float rings = sin(dist * ring_frequency + (TIME * move_speed));
	rings = step(ring_portion, rings);
	float blend_alpha = smoothstep(0.5, 0.4, dist);
	 bool is_rings = (rings > 0.0) && bool(1 - int(dist > 0.5 || rings < 1.0));

    ALPHA = float(is_rings) * mix(1.0, blend_alpha, float(smooth_edge));
    ALBEDO = float(is_rings) * ring_color;
}