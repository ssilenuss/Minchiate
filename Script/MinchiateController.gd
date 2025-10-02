extends Control

@export var card_manager : CardManager
@export var camera : SmoothCam
@export var noise : FastNoiseLite

#var cards : Array[Card] = []

var screen_size : Vector2
var screen_center : Vector2
var screen_edges : Vector4  

var active_deck: Deck
var active_card: Card

enum states{RESTART, CUTDECK}

var game_state : int : set = set_game_state
	
var position_tween: Tween 

var waiting_for_user: bool = false


signal cards_ready


func _ready() -> void:
	randomize()

	camera.screen_moved.connect(set_screen_positions)
	set_screen_positions()
	
	card_manager.new_deck()
	for c in card_manager.get_children():
		card_manager.decks[0].add_card(c)
		c.position = Vector2.ZERO
	
	active_deck = card_manager.decks[0]
	
	
		
		
	
	#place_cards_randomly_around_screen(active_deck)
	set_game_state(states.RESTART)

func _process(_delta: float) -> void:

	if game_state == states.CUTDECK and waiting_for_user:
		if Input.is_action_just_pressed("left_click") and card_manager.card_hovering:
			cut_deck(card_manager.card_hovering,card_manager.decks[0])
			print("deck cut")
			

func set_game_state(_state :int)->void:
	game_state = _state
	match game_state:
		states.RESTART:
			#place_cards_randomly_around_screen(card_manager.decks[0])
			pass
		states.CUTDECK:

			var margin := Vector2(screen_size.x*.49, screen_size.y*.495)
			var end := Vector2(camera.left_node.global_position.x+margin.x, camera.bottom_node.position.y-margin.y)
			var start := Vector2(camera.right_node.global_position.x-margin.x, camera.top_node.position.y+margin.y)
			create_card_line(active_deck, start, end, 0.02)
			await cards_ready
			waiting_for_user = true
			

func cut_deck(_card:Card, _deck: Deck)->void:
	print(_card)
	var idx : int = _deck.cards.find(_card)
	var new_cards : Array[Card] = []
	for i in range(idx, _deck.cards.size()):
		#should reverse order of cards
		new_cards.append(_deck.cards.pop_back())
	
	var new_pos:= Vector2(_card.position.x - _card.size.x*1.5, _card.position.y)
	print(new_cards)
	
	stack_cards(new_cards,new_pos,0.02)
	

func place_cards_randomly_around_screen(_deck: Deck)->void:
	#place cards randomly around an area
	for c in _deck.cards:
		var area : Vector2 = screen_size/2.0
		area.x -= c.size.x/2.0
		area.y -= c.size.y/2.0
		var new_pos := Vector2( 
			randf_range(-area.x-c.size.x, area.x), 
			randf_range(-area.y-c.size.y, area.y))
		c.position = new_pos
	
func create_offset_pile(_deck: Deck, _pos: Vector2, _speed: float)->void:
	for i in _deck.cards.size():
		_deck.cards[i].can_drag = false
		_deck.cards[i].set_hover(false)
		_deck.cards[i].move_to_front()
		
		var noise_scalar : float = 10.0
		var weight :float = i / float(_deck.cards.size())
		
		
		var new_pos :Vector2= lerp(_pos, _pos, weight)
		var nudge := Vector2(noise.get_noise_2dv(new_pos), noise.get_noise_2dv(-new_pos))
		new_pos += nudge * noise_scalar
		_deck.cards[i].move(new_pos-_deck.cards[i].size/2.0, _speed)
		await get_tree().create_timer(_speed/4.0).timeout
	
	card_manager.print_deck_info()
	cards_ready.emit()

func create_card_line(_deck: Deck, _start: Vector2, _end: Vector2, _speed: float)->void:
	for i in _deck.cards.size():
		_deck.cards[i].can_drag = false
		_deck.cards[i].set_hover(false)
		_deck.cards[i].move_to_front()
		
		var noise_scalar : float = 10.0
		var weight :float = i / float(_deck.cards.size())
		var new_pos :Vector2= lerp(_start, _end, weight)
		var nudge := Vector2(noise.get_noise_2dv(new_pos), noise.get_noise_2dv(-new_pos))
		new_pos += nudge * noise_scalar
		_deck.cards[i].move(new_pos-_deck.cards[i].size/2.0, _speed)
		await get_tree().create_timer(_speed/4.0).timeout
	
	card_manager.print_deck_info()
	cards_ready.emit()
	
func stack_cards(_cards: Array[Card], _pos: Vector2, _speed: float)->void:
	card_manager.new_deck_from(_cards[0])
	
	for c in _cards:
		#print(_cards)
		#print(cards[0])
		#print(c)
		card_manager.decks[card_manager.decks.size()-1].add_card(c)
		c.can_drag = false
		c.set_hover(false)
		c.move_to_front()
		c.move(_pos-c.size/2.0, _speed)
		await get_tree().create_timer(_speed/4.0).timeout
	
	card_manager.print_deck_info()
	cards_ready.emit()

		
	
	
	
	
func set_screen()->void:
	pass
	
	

func set_screen_positions()->void:
	screen_size = get_viewport().get_visible_rect().size
	screen_edges = Vector4(
		camera.left_node.global_position.x,
		camera.top_node.global_position.y,
		camera.right_node.global_position.x,
		camera.bottom_node.global_position.y
	)
	screen_center = screen_size/2.0 + Vector2(camera.left_node.global_position.x, camera.top_node.global_position.y)
	
	#set card offsetsd
	for d in card_manager.decks:
		for i in d.cards.size():
			var scalor :float = 10.0
			var z_weight :float = i/ float(d.cards.size()) 
			var card_pos : Vector2 = d.cards[i].global_position
			var card_middle : Vector2 = card_pos + d.cards[i].size/2.0
			var dist : Vector2 = card_middle - screen_center
			var max_dist = Vector2(screen_edges.y, screen_edges.z)
			var offset_weight = Vector2(dist.x/screen_size.x, dist.y/screen_size.y)
			var new_pos = card_pos+offset_weight*z_weight
			if i == d.cards.size()/2:
				print(d.cards[i].global_position,d.cards[i].position,d.cards[i].prev_position )
			#d.cards[i].prev_position = d.cards[i].position
			d.cards[i].shift_perspective(offset_weight*z_weight)
			#d.cards[i].z_offset = Vector2(offset, offset) 
	#print(screen_center)
	
func _on_resized() -> void:
	screen_size = get_viewport().get_visible_rect().size
