shader_type canvas_item;
render_mode blend_mix;

// font texture.
uniform sampler2D font_texture: filter_nearest, hint_default_black;

// Number of characters horizontally / vertically in font_texture
uniform ivec2 font_size = ivec2(16, 16);

// Character offset in 'r'.
uniform sampler2D character_buffer: filter_nearest, repeat_disable, hint_default_black;

// forground color
uniform sampler2D forground_color: filter_nearest, source_color, repeat_disable, hint_default_white;

// background color
uniform sampler2D background_color: filter_nearest, source_color, repeat_disable, hint_default_black;

void fragment() {
	vec2 terminal_uv = UV * vec2(textureSize(character_buffer, 0));
	ivec2 char_position = ivec2(floor(terminal_uv));
	vec2 char_uv = fract(terminal_uv);

	// https://github.com/godotengine/godot/issues/57841
	// (usampler2D and isampler2D are not working correctly)
	int char = int(texelFetch(character_buffer, char_position, 0).r * 255.0);

	char_uv.x += float(char % font_size.x);
	char_uv.y += float(char / font_size.x);

	char_uv /= vec2(font_size);
	
	vec4 char_color = texture(font_texture, char_uv);
	COLOR *= mix(
		texelFetch(background_color, char_position, 0),
		texelFetch(forground_color, char_position, 0),
		char_color.a
	);
}