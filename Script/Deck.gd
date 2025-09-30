extends Node2D
class_name Deck

var cards : Array[Card] = [] 


func add_card(_card: Card)->void:
	var card_idx : int = cards.find(_card)
	if card_idx == -1:
		_card.deck = self
		cards.append(_card)
		#print(self, " added to deck: ", cards)
	else:
		print(_card, " is already in this deck!: ")

func remove_card(_card: Card)->void:
	var card_idx : int = cards.find(_card)
	if card_idx == -1:
		print(_card, " not found in deck ")
	else:
		_card.deck = null
		cards.erase(_card)
		#print(_card, " removed from deck: ", cards)
	if cards.size()<=0:
		#print(self, " freed!")
		queue_free()
