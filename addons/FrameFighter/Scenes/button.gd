extends Control

@export var text = "LP"
@export_color_no_alpha var textColor = Color.from_string("#5085ff", Color.WHITE)

@export var released_texture: Texture2D
@export var pressed_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite/Label.text = text
	$Sprite/Label.add_theme_color_override("font_color", textColor)
	
	release()

func press() -> void:
	sprite.texture = pressed_texture

func release() -> void:
	sprite.texture = released_texture
