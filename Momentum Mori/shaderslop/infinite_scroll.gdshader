shader_type canvas_item;

uniform sampler2D tex : source_color, repeat_enable;
uniform vec2 scroll_speed = vec2(0.1, 0.0);

void fragment() {
	vec2 uv = UV + scroll_speed * TIME;
	COLOR = texture(tex, uv);
}