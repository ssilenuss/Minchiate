extends Control

@export var card_manager : CardManager
@export var camera : SmoothCam
@export var noise : FastNoiseLite

var cards : Array[Card] = []

var screen_size : Vector2 

enum states{RESTART, CUTDECK}

var game_state : int : set = set_game_state
	
var position_tween: Tween 


signal cards_ready

func _ready() -> void:
	randomize()
	screen_size = get_viewport().get_visible_rect().size
	
	for c in card_manager.get_children():
		cards.append(c)
	cards.shuffle()
	
	#reorder cards for visuals
	for i in cards.size():
		card_manager.move_child(cards[i], i)
	
	place_cards_randomly_around_screen()
	
	set_game_state(states.RESTART)

func _process(_delta: float) -> void:
	if game_state == states.RESTART:
		set_game_state(states.CUTDECK)
	if game_state == states.CUTDECK:
		pass

func set_game_state(_state :int)->void:
	game_state = _state
	match game_state:
		states.RESTART:
			place_cards_randomly_around_screen()
		states.CUTDECK:
			cards.shuffle()
			
			stack_cards(cards, Vector2.ZERO, 0.05)
			await cards_ready
			
			var margin := Vector2(screen_size.x*.49, screen_size.y/10.0)
			var end := Vector2(camera.left_node.global_position.x+margin.x, camera.bottom_node.global_position.y - margin.y*2.0)
			var start := Vector2(camera.right_node.global_position.x-margin.x, camera.bottom_node.global_position.y - margin.y*2.0)
			
			
			create_card_line(cards, start, end, 0.1)
			

func place_cards_randomly_around_screen()->void:
	#place cards randomly around an area
	for c in cards:
		var area : Vector2 = screen_size/2.0
		area.x -= c.size.x/2.0
		area.y -= c.size.y/2.0
		var new_pos := Vector2( 
			randf_range(-area.x-c.size.x, area.x), 
			randf_range(-area.y-c.size.y, area.y))
		c.position = new_pos

func create_card_line(_cards: Array[Card], _start: Vector2, _end: Vector2, _speed: float)->void:
	for i in _cards.size():
		_cards[i].can_drag = false
		_cards[i].set_hover(false)
		_cards[i].move_to_front()
		
		var noise_scalar : float = 10.0
		var weight :float = i / float(_cards.size())
		var new_pos :Vector2= lerp(_start, _end, weight)
		var nudge := Vector2(noise.get_noise_2dv(new_pos), noise.get_noise_2dv(-new_pos))
		new_pos += nudge * noise_scalar
		_cards[i].move(new_pos-_cards[i].size/2.0, _speed)
		await get_tree().create_timer(_speed/4.0).timeout
	
	card_manager.print_deck_info()
	cards_ready.emit()
	
func stack_cards(_cards: Array[Card], _pos: Vector2, _speed: float)->void:
	card_manager.new_deck_from(cards[0])
	
	for c in _cards:
		card_manager.decks[0].add_card(c)
		c.can_drag = false
		c.set_hover(false)
		c.move_to_front()
		c.move(_pos-c.size/2.0, _speed)
		await get_tree().create_timer(_speed/4.0).timeout
	
	card_manager.print_deck_info()
	cards_ready.emit()

		
	
	
	
	
	
	
	


func _on_resized() -> void:
	screen_size = get_viewport().get_visible_rect().size
