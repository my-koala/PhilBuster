@tool
extends RefCounted
class_name GameStats

## Class that stores a player's stats, including deck, money, and purchases.

# TODO: Add purchases here.

const DECK_MAX_COUNT: int = 30

var _deck: Array[CardInstance] = []
var _money: int = 0
var _sessions: int = 0

func get_deck() -> Array[CardInstance]:
	var deck: Array[CardInstance] = _deck.duplicate()
	deck.make_read_only()
	return deck

func deck_shuffle() -> void:
	_deck.shuffle()

func deck_deal() -> CardInstance:
	if _deck.is_empty():
		return null
	
	var card_instance: CardInstance = _deck[0]
	_deck.pop_front()
	return card_instance

func deck_append(card_instance: CardInstance) -> bool:
	if !is_instance_valid(card_instance):
		return false
	
	if _deck.size() == DECK_MAX_COUNT:
		return false
	
	if _deck.has(card_instance):
		return false
	
	_deck.append(card_instance)
	return true

func deck_remove(card_instance: CardInstance) -> bool:
	if !is_instance_valid(card_instance):
		return false
	
	if _deck.is_empty():
		return false
	
	if !_deck.has(card_instance):
		return false
	
	_deck.erase(card_instance)
	return true

func deck_has(card_instance: CardInstance) -> bool:
	return _deck.has(card_instance)

func deck_is_full() -> bool:
	return _deck.size() == DECK_MAX_COUNT

func deck_is_empty() -> bool:
	return _deck.is_empty()

func deck_clear() -> void:
	for card_instance: CardInstance in _deck:
		card_instance.free()
	_deck.clear()

func get_money() -> int:
	return _money

func money_add(amount: int) -> void:
	_money += amount

func money_remove(amount: int) -> void:
	_money -= amount

func calculate_price_for(card_info : CardInfo) -> int:
	return card_info.rarity * (floori(_sessions * 0.25) + 1)

func get_sessions() -> int:
	return _sessions

func session_finished() -> void:
	_sessions += 1
