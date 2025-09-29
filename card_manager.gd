@tool
extends Control

class_name CardManager
@export var starting_drop : CardDrop
@export var deck_positions : PackedVector2Array = []

@export_range(0.01,10.0, 0.001, "height / width") var card_aspect_ratio : float = 12.0/7.0 : 
	set(value):
		card_aspect_ratio = value
		if get_child_count() > 0:
			for c in get_children():
				set_card_size(c)
		
@export_range(10,1000, 1) var card_width: float = 70 :
	set(value):
		card_width = value
		if get_child_count() > 0:
			for c in get_children():
				set_card_size(c)
		
@export var texture_back: Texture2D : 
	set(value):
		texture_back = value
		for c in get_children():
			if c is Card:
				c.texture_back = texture_back

var card_size : Vector2 = Vector2(70, 120)

var card_dragging : Card 
var card_hovering : Card  : set = set_card_hovering
var card_drop : Card 


var position_tween : Tween
var drag_speed : float = 0.05
var move_speed : float = 0.1
var pile_offset : float = 1.0


func _ready() -> void:
	if starting_drop:
		deck_positions.append(starting_drop.global_position)
		
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	for c in get_children():
		c.deck = 0
		c.position = deck_positions[0]
		set_card_size(c)
		c.manager = self

func _process(_delta: float) -> void:
	if card_hovering and Input.is_action_just_pressed("right_click"):
		card_hovering.front = !card_hovering.front
		
	if card_hovering and Input.is_action_pressed("left_click"): 
		card_dragging = card_hovering
		card_dragging.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		move_child(card_dragging, get_child_count()-1)
		card_hovering.set_hover(true)
		#set_card_hovering(null)
		
	if card_dragging:
		if Input.is_action_just_released("left_click"):
			card_dragging.set_mouse_filter(Control.MOUSE_FILTER_PASS)
			card_dragging.set_hover(false)
			if card_drop:
				card_dragging.prev_position = card_drop.position
				card_dragging.free_placement = false
			else:
				card_dragging.free_placement = true
			if not card_dragging.free_placement:
				move_card(card_dragging, card_dragging.prev_position, move_speed)
			card_dragging = null
			
		else:
			
			move_card(card_dragging, get_global_mouse_position()-card_dragging.pivot_offset, drag_speed)
		
		

func set_card_size(c: Card) ->void:
	card_size = Vector2(card_width, card_width*card_aspect_ratio)
	c.size = card_size
	c.pivot_offset = card_size/2.0

#
func set_card_hovering(_card_hovering: Card):
	if card_dragging:

		if _card_hovering:
			if _card_hovering.is_card_drop:
				card_drop = _card_hovering
		else:
			card_dragging.free_placement = true
			card_drop = null
		return
		
	if card_hovering and _card_hovering == null:
		card_hovering.set_hover(false)

	card_hovering = _card_hovering
	
	if card_hovering:
		card_hovering.set_hover(true)
	
#
func move_card(_card: Card, _pos: Vector2, _speed: float)->void:
	if position_tween and position_tween.is_valid():
			position_tween.kill()
			position_tween = null
	position_tween = create_tween()
	position_tween.set_parallel(true)
	position_tween.tween_property(_card, "position", _pos, _speed)
	#
#
			#
		#
			#
