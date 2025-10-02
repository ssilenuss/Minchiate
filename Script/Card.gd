@tool
extends TextureRect
class_name Card
#enum Suit {FIRE, WATER, AIR, EARTH}
@export var can_drag : bool
@export var deck : Deck
@export var z_offset : Vector2 = Vector2.ZERO 

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

@export_category("Hovering")
@export var hover_scale : float = 1.1

@export_category("Animation")
@export var hover_scale_speed : float = 0.1
@export var position_speed : float = 0.1

var manager : CardManager

#var hover : bool = false : set = set_hover
var hover_tween : Tween
var position_tween : Tween


var prev_position : Vector2 = Vector2.ZERO

var prev_scale : Vector2

var front := false :
	set(value):
		front = value
		if front:
			texture = texture_front
		else:
			texture = texture_back

var is_card_drop:=false



func _ready()->void:
	front = front
	
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	prev_position = position
	prev_scale = scale
	


func _on_mouse_entered()->void:
	#set_hover(true)
	manager.set_card_hovering(self)
	
func _on_mouse_exited()->void:
	#if manager.card_hovering == self:
		#manager.card_hovering = null
	manager.set_card_hovering(null)
	#set_hover(false)
#
func set_hover(_hover: bool):
	#if manager.card_dragging:
		#return
	#
	#hover = _hover
	
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
		hover_tween = null
		
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	if _hover:
		hover_tween.tween_property(self, "scale", Vector2.ONE * hover_scale, hover_scale_speed)
		
	else:
		hover_tween.tween_property(self, "scale", prev_scale, hover_scale_speed)
		
func shift_perspective(_offset: Vector2)->void:
	global_position = prev_position + _offset
	
func get_positions()->PackedVector2Array:
	var positions := [position, prev_position]
	
	return positions

func move( _pos: Vector2, _speed: float)->void:
	
	if position_tween and position_tween.is_valid():
			position_tween.kill()
			position_tween = null
	position_tween = create_tween()
	position_tween.set_parallel(true)
	position_tween.tween_property(self, "position", _pos, _speed)
	#position_tween.tween_callback(get_positions)
