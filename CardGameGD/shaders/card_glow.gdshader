shader_type canvas_item;

// Simple glow shader for cards
// Adds an outer glow effect with configurable color and intensity

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float glow_size : hint_range(0.0, 0.1) = 0.02;
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// Sample surrounding pixels to create glow
	float alpha_sum = 0.0;
	int samples = 8;

	for (int i = 0; i < samples; i++) {
		float angle = float(i) * 6.28318 / float(samples);
		vec2 offset = vec2(cos(angle), sin(angle)) * glow_size;
		alpha_sum += texture(TEXTURE, UV + offset).a;
	}

	// Create glow based on surrounding alpha
	float glow = alpha_sum / float(samples);
	glow = smoothstep(0.0, 1.0, glow) * glow_intensity;

	// Combine original color with glow
	if (color.a < 0.1 && glow > 0.1) {
		COLOR = vec4(glow_color.rgb, glow_color.a * glow);
	} else {
		COLOR = color;
	}
}
