@tool
extends RefCounted
class_name GameStats

## Class that stores a player's stats, including deck, money, and purchases.

signal money_changed()

# TODO: Add purchases here.

const DECK_MAX_COUNT: int = 30

var _deck: Array[CardInfo] = []
var _money: int = 0
var _sessions: int = 0

func get_deck() -> Array[CardInfo]:
	var deck: Array[CardInfo] = _deck.duplicate()
	deck.make_read_only()
	return deck

func deck_append(card_info: CardInfo) -> bool:
	if !is_instance_valid(card_info):
		return false
	
	if _deck.size() == DECK_MAX_COUNT:
		return false
	
	_deck.append(card_info)
	return true

func deck_remove(card_info: CardInfo) -> bool:
	if !is_instance_valid(card_info):
		return false
	
	if !_deck.has(card_info):
		return false
	
	_deck.erase(card_info)
	return true

func deck_has(card_info: CardInfo) -> bool:
	return _deck.has(card_info)

func deck_is_full() -> bool:
	return _deck.size() == DECK_MAX_COUNT

func deck_get_size() -> int:
	return _deck.size()

func deck_is_empty() -> bool:
	return _deck.is_empty()

func deck_clear() -> void:
	_deck.clear()

func get_money() -> int:
	return _money

func money_add(amount: int) -> void:
	_money += amount
	money_changed.emit()

func money_remove(amount: int) -> void:
	_money -= amount
	money_changed.emit()

func calculate_price_for(card_info : CardInfo) -> int:
	return card_info.price * (floori(_sessions * 0.25) + 1)

func get_sessions() -> int:
	return _sessions

func session_finished() -> void:
	_sessions += 1
