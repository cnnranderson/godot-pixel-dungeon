shader_type canvas_item;

uniform float progress : hint_range(0, 1);
uniform float diamondPixelSize = 10f;
uniform bool direction = false;

void fragment() {
	float xFraction = fract(FRAGCOORD.x / diamondPixelSize);
	float yFraction = fract(FRAGCOORD.y / diamondPixelSize);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	bool upDiscard = xDistance + yDistance + UV.y > progress * 2.0;
	bool downDiscard = xDistance + yDistance + UV.y < progress * 2.0;
	if (direction && upDiscard) {
		discard;
	} else if (!direction && downDiscard) {
		discard;
	}
}