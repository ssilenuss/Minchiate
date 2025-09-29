@tool
extends Node

@export_tool_button("create_deck") var tool_button : Callable = create_deck

@export_dir var card_fronts_dir : String
@export var card_material : Material 

func create_deck()->void:
	for c in get_children():
		c.queue_free()
	
	var deck : Node2D = Node2D.new()
	deck.name = "MinchiateDeck"
	add_child(deck)
	deck.owner = self
	
	var card_name_array : PackedStringArray = []
	var texture_path_array: PackedStringArray = []
	
	var remove_string : String = "Minchiate_card_deck_-_Florence_-_1860-1890_-_"
	
	var dir := DirAccess.open(card_fronts_dir)
	if dir == null: printerr("Could not open folder"); return
	dir.list_dir_begin()
	for file: String in dir.get_files():
		if file.ends_with(".jpg"):
			texture_path_array.append(file)
			
			file = file.replace(remove_string, "")
			file = file.replace(".jpg", "")
			card_name_array.append(file)
	
	for i in card_name_array.size():
		var card : Card = Card.new()
		
		var info : String = card_name_array[i]
		card.name = info
		
		if info.begins_with("Batons"):
			card.suit = card.Suits.BATONS
			card.name = " of Batons"
			info = info.replace("Batons_-_", "")
		elif info.begins_with("Coins"):
			card.suit = card.Suits.COINS
			card.name = " of Coins"
			info = info.replace("Coins_-_", "")
		elif info.begins_with("Cups"):
			card.suit = card.Suits.CUPS
			card.name = " of Cups"
			info = info.replace("Cups_-_", "")
		elif info.begins_with("Swords"):
			card.suit = card.Suits.SWORDS
			card.name = " of Swords"
			info = info.replace("Swords_-_", "")
		elif info.begins_with("Trumps"):
			card.suit = card.Suits.TRUMPS
			info = info.replace("Trumps_-_", "")
			card.name = " " + info.erase(0, 5)
			
		
		if info.left(2).is_valid_int():
			card.value = int(info.left(2))
			card.name = info.left(2) + card.name
		else:
			card.name = info
		
		card.texture_front = load(card_fronts_dir + "/" + texture_path_array[i])
		card.texture_back = load("res://CardTextures/Minchiate_card_deck_-_Florence_-_1860-1890_-_Back.jpg")
		card.texture = card.texture_front
		
		deck.add_child(card)
		card.owner = self
		
	
	
		
	
