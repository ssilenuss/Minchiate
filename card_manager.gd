@tool
extends Control

class_name CardManager

@export_range(0.01,10.0, 0.001, "height / width") var card_aspect_ratio : float = 12.0/7.0 : 
	set(value):
		card_aspect_ratio = value
		set_card_size()
		
@export_range(10,1000, 1) var card_width: float = 70 :
	set(value):
		card_width = value
		set_card_size()
		
@export var texture_back: Texture2D : 
	set(value):
		texture_back = value
		for c in get_children():
			if c is Card:
				c.texture_back = texture_back

var card_size : Vector2 = Vector2(70, 120)

func set_card_size() ->void:
	card_size = Vector2(card_width, card_width*card_aspect_ratio)
	for c in get_children():
		if c is Card:
			c.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			c.size = card_size
			c.position = -card_size/2.0
			
		
			
