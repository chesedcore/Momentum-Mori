shader_type canvas_item;

uniform sampler2D grunge_tex;
uniform sampler2D scratch_tex;

uniform float border_size : hint_range(0.0, 2.0) = 0.15;

uniform float grunge_scale = 1.0;
uniform float scratch_scale = 1.0;

uniform vec4 grunge_color : source_color = vec4(0.3, 0.2, 0.1, 1.0);
uniform float grunge_color_strength : hint_range(0.0, 1.0) = 1.0;

uniform float scratch_strength : hint_range(0.0, 1.0) = 0.15;

void fragment() {
	vec4 col = COLOR;

	// ----- Grungy silhouette -----

	vec2 p = abs(UV - vec2(0.5));
	float edge_dist = 0.5 - max(p.x, p.y);

	// 1 near edge, 0 inside
	float edge_mask = 1.0 - smoothstep(0.0, border_size, edge_dist);

	// Grunge texture
	vec2 guv = (UV - 0.5) * grunge_scale + 0.5;
	guv = clamp(guv, vec2(0.0), vec2(1.0));

	float grunge = texture(grunge_tex, guv).a;

	// Amount of damaged edge
	float grunge_mask = edge_mask * (1.0 - grunge);

	// Tint the damaged edge
	col.rgb = mix(
		col.rgb,
		grunge_color.rgb,
		grunge_mask * grunge_color_strength
	);

	// Preserve transparency effect
	col.a *= 1.0 - grunge_mask * (1.0 - grunge_color.a);

	// ----- Scratch overlay -----

	vec2 suv = (UV - 0.5) * scratch_scale + 0.5;
	suv = clamp(suv, vec2(0.0), vec2(1.0));

	float scratches = texture(scratch_tex, suv).a;

	col.rgb *= mix(
		vec3(1.0),
		vec3(1.0 - scratches),
		scratch_strength
	);

	COLOR = col;
}