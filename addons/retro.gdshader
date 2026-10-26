shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

// Bigger = chunkier pixels (3-5 is Puppet Combo-ish).
uniform float pixel_size : hint_range(1.0, 12.0) = 4.0;
// Fewer = more banded, PS1-style colors.
uniform float color_steps : hint_range(4.0, 64.0) = 24.0;
// VHS-style grain.
uniform float noise_amount : hint_range(0.0, 0.2) = 0.04;
// Dark horizontal lines.
uniform float scanline_strength : hint_range(0.0, 0.5) = 0.1;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = (floor(SCREEN_UV * res / pixel_size) + 0.5) * pixel_size / res;

	vec3 col = texture(screen_tex, uv).rgb;
	col = floor(col * color_steps) / color_steps;
	col += (rand(uv + fract(TIME)) - 0.5) * noise_amount;
	col *= (1.0 - scanline_strength) + scanline_strength * sin(SCREEN_UV.y * res.y * 1.5);

	COLOR = vec4(col, 1.0);
}
