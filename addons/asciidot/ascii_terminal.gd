@tool
extends Control

@export var ascii_font: Texture2D = _property_get_revert("ascii_font")

## Terminal size in characters.
## When you change this value, the back buffer content will be invalidated.
@export var terminal_size := Vector2i(64, 24) :
	set(value):
		if terminal_size == value:
			return
		assert(
			terminal_size.x > 0 && terminal_size.y > 0,
			"Terminal 'width' & 'height' must be > 0."
		)
		
		terminal_size = value
		
		_recreate_textures()

var _dirty_buffer := true

var _char_buffer: Image
var _char_texture: ImageTexture

var _forground_buffer: Image
var _forground_texture: ImageTexture

var _background_buffer: Image
var _background_texture: ImageTexture

func _init():
	material = _property_get_revert("material")
	
	_recreate_textures()

## Fill the complete terminal
func clear_characters(
	character: int = ' '.to_ascii_buffer()[0],
	forground: Color = Color.WHITE,
	background: Color = Color.BLACK
):
	_char_buffer.fill(Color.from_rgba8(character, 0, 0))
	_forground_buffer.fill(forground)
	_background_buffer.fill(background)

	_dirty_buffer = true;
	queue_redraw()

## Set the given character at the given position.
## The character is given as ascii code.
func set_character(pos: Vector2i, character: int, forground: Color, background: Color):
	_char_buffer.set_pixelv(pos, Color.from_rgba8(character, 0, 0))
	_forground_buffer.set_pixelv(pos, forground)
	_background_buffer.set_pixelv(pos, background)

	_dirty_buffer = true
	queue_redraw()

func _recreate_textures() -> void:
	_char_buffer = Image.create(terminal_size.x, terminal_size.y, false, Image.FORMAT_R8)
	if !_char_texture:
		_char_texture = ImageTexture.create_from_image(_char_buffer)
	else:
		_char_texture.set_image(_char_buffer)
	
	_forground_buffer = Image.create(terminal_size.x, terminal_size.y, false, Image.FORMAT_RGBA8)
	if !_forground_texture:
		_forground_texture = ImageTexture.create_from_image(_forground_buffer)
	else:
		_forground_texture.set_image(_forground_buffer)
	
	_background_buffer = Image.create(terminal_size.x, terminal_size.y, false, Image.FORMAT_RGBA8)
	if !_background_texture:
		_background_texture = ImageTexture.create_from_image(_background_buffer)
	else:
		_background_texture.set_image(_background_buffer)
		
	clear_characters()

func _draw() -> void:
	if _dirty_buffer:
		_dirty_buffer = false
		_char_texture.update(_char_buffer)
		_forground_texture.update(_forground_buffer)
		_background_texture.update(_background_buffer)
	
	material.set_shader_parameter("font_texture", ascii_font)
	material.set_shader_parameter("character_buffer", _char_texture)
	material.set_shader_parameter("forground_color", _forground_texture)
	material.set_shader_parameter("background_color", _background_texture)
	

func _property_get_revert(property: StringName) -> Variant:
	if "material" == property:
		var mat := preload("./ascii_terminal.tres")
		if (material is ShaderMaterial && (material as ShaderMaterial).shader == mat.shader):
			return material
		else:
			return mat.duplicate()
			
	if "ascii_font" == property:
		return preload("./default_font/CGA8x8thin.png")
		
	return null;

func _property_can_revert(property: StringName) -> bool:
	return property in ["material", "ascii_font"]
