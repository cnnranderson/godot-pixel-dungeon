shader_type canvas_item;

uniform vec4 SelectedColor : hint_color = vec4(0.18, 0.25, 0.32, 1.0);

void fragment()
{
	vec4 pixel = texture(TEXTURE, UV);
	if (pixel == vec4(1)) {
		COLOR = SelectedColor;
	} else {
		COLOR = vec4(0);
	}
}