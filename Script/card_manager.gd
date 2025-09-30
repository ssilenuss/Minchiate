@tool
extends Control

class_name CardManager
@export var starting_drop : CardDrop
@export var decks : Array[Deck] :
	set(value):
		decks = value
		print("decks: ", decks)

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
		new_deck_from(starting_drop)

		
	set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	
	for c in get_children():
		if decks.size()>0:
			c.position = decks[0].position
		set_card_size(c)
		c.manager = self
	

func _process(_delta: float) -> void:
	if card_hovering and Input.is_action_just_pressed("right_click"):
		card_hovering.front = !card_hovering.front
		
	if card_hovering and Input.is_action_pressed("left_click"): 
		if card_hovering.can_drag:
			card_dragging = card_hovering
			card_dragging.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
			card_dragging.move_to_front()
			card_hovering.set_hover(true)
		#set_card_hovering(null)
		
	if card_dragging:
		if Input.is_action_just_released("left_click"):
			card_dragging.set_mouse_filter(Control.MOUSE_FILTER_PASS)
			card_dragging.set_hover(false)
			if card_drop:
				if not card_drop.deck:
					new_deck_from(card_drop)
				card_drop.deck.add_card(card_dragging)
				#card_dragging.prev_position = card_drop.position
				#card_dragging.free_placement = false
			else:
				#card_dragging.free_placement = true
				pass
			if card_dragging.deck:
				#move_card(card_dragging, card_dragging.deck.position, move_speed)
				card_dragging.move(card_dragging.deck.position, move_speed)
			card_dragging = null
			
		else:
			
			#move_card(card_dragging, get_global_mouse_position()-card_dragging.pivot_offset, drag_speed)
			card_dragging.move(get_global_mouse_position()-card_dragging.pivot_offset, drag_speed)
		
		

func set_card_size(c: Card) ->void:
	card_size = Vector2(card_width, card_width*card_aspect_ratio)
	c.size = card_size
	c.pivot_offset = card_size/2.0

func set_card_hovering(_card_hovering: Card):
	if card_dragging:

		if _card_hovering:
			if _card_hovering.is_card_drop:
				card_drop = _card_hovering
				if not card_drop.deck:
					new_deck_from(card_drop)
				card_drop.deck.add_card(card_dragging)
		else:
			#card_dragging.free_placement = true
			if card_drop:
				card_drop.deck.remove_card(card_dragging)
				decks.erase(card_drop.deck)
			card_drop = null
		return
	
	
	if card_hovering and _card_hovering == null:
		card_hovering.set_hover(false)

	card_hovering = _card_hovering
	
	if card_hovering:
		card_hovering.set_hover(true)
	
#
#func move_card(_card: Card, _pos: Vector2, _speed: float)->void:
	#if position_tween and position_tween.is_valid():
			#position_tween.kill()
			#position_tween = null
	#position_tween = create_tween()
	#position_tween.set_parallel(true)
	#position_tween.tween_property(_card, "position", _pos, _speed)

#gotta figure out what's going on with the deck count.  Not currently working.
func new_deck_from(_card: Card)->void:
	var d := Deck.new()
	d.add_card(_card)
	d.position = _card.position
	decks.append(d)
	#print(decks.size(), " decks in play")
	print_deck_info()

func set_card_drop(_card: Card)->void:
	card_drop = _card

func print_deck_info()->void:
	print("num of decks: ", decks.size())
	for i in decks.size():
		print("Deck ", i, " has ", decks[i].cards.size(), " cards.")
	
			#
		#
			#
