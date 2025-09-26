#@tool
extends TextureRect
class_name Card
#enum Suit {FIRE, WATER, AIR, EARTH}
enum Suits {BATONS, CUPS, SWORDS, COINS, TRUMPS}
@export var suit : Suits = Suits.BATONS 
@export var value : int = 0 :
	set(v):
		value = v
		if suit == Suits.TRUMPS:
			if value < 0: value = 0
			elif value > 40 : value = 40
		else:
			if value < 1: value = 1
			elif value > 13 : value = 13
@export var texture_front: Texture2D
@export var texture_back: Texture2D
@export var collision_shape: CollisionShape2D
@export var card_name : StringName = "Test"

var hover : bool = false

func _ready()->void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
func _on_mouse_entered()->void:
	pass

func _on_mouse_exited()->void:
	pass
