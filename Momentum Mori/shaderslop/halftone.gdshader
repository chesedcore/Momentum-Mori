shader_type canvas_item;

uniform vec2 start_point = vec2(0.0, 0.0);
uniform vec2 end_point = vec2(1.0, 1.0);

uniform float speed = 0.1;
uniform float scale = 80.0;

uniform float start_size = 0.35;
uniform float end_size = 0.05;

uniform vec4 dot_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.15;

void fragment() {
	vec2 dir = normalize(end_point - start_point);

	// Scroll pattern
	vec2 uv = UV * scale + dir * TIME * speed;

	// Progress from start to end
	float t =
		dot(UV - start_point, dir) /
		dot(end_point - start_point, dir);

	t = clamp(t, 0.0, 1.0);

	// Dot radius decreases toward the end
	float dot_size = mix(start_size, end_size, t);

	// Position inside cell
	vec2 cell = fract(uv) - 0.5;
	float dist = length(cell);

	// Circular dot
	float dot_mask =
		1.0 -
		smoothstep(
			dot_size,
			dot_size + 0.03,
			dist
		);

	// Transparent background, only dots are visible
	COLOR = vec4(
		dot_color.rgb,
		dot_color.a * dot_mask * strength
	);
}