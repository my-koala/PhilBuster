extends Node
class_name CardLibrary

const FOLDER_PATH: String = "res://assets/card/info/"

var pulled_cards: Array[CardInfo] = []
var _available_cards: Array[CardInfo] = []
var _available_basic_cards: Array[CardInfo] = []
var _available_modifier_cards: Array[CardInfo] = []
var _all_cards: Array[CardInfo]

# TODO: Influence random card selection by rarity somehow
## Pulls a random card from the library which has never been pulled.
func get_random_card() -> CardInfo:
	if _available_cards.size() == 0:
		return null
	
	return _available_cards[randi_range(0, _available_cards.size() - 1)]

## Pulls a random basic (noun/verb) card from the library which has never been pulled.
func get_random_basic_card() -> CardInfoBasic:
	if _available_basic_cards.size() == 0:
		return null
	
	return _available_basic_cards[randi_range(0, _available_basic_cards.size() - 1)]

## Pulls a random modifier (adjective/adverb) card from the library which has never been pulled.
func get_random_modifier_card() -> CardInfoModifier:
	if _available_modifier_cards.size() == 0:
		return null
	
	return _available_modifier_cards[randi_range(0, _available_modifier_cards.size() - 1)]

## "Pulls" a card, removing it from available cards to randomly draw
func pull_card(card_info: CardInfo) -> void:
	_available_cards.erase(card_info)
	_available_basic_cards.erase(card_info)
	_available_modifier_cards.erase(card_info)
	pulled_cards.append(card_info)

## Resets the state of the library, allowing every card to be pulled again
func reset_library() -> void:
	pulled_cards.clear()
	_available_cards = _all_cards.duplicate()
	_available_basic_cards = _all_cards.filter(func(card: CardInfo) -> bool: return is_instance_of(card, CardInfoBasic))
	_available_modifier_cards = _all_cards.filter(func(card: CardInfo) -> bool: return is_instance_of(card, CardInfoModifier))

func _ready() -> void:
	print("Loading cards...")
	
	_load_folder(FOLDER_PATH)
	reset_library()
	
	print("Loaded %d cards." % _all_cards.size())

# Recursively load cards from card base folder.
func _load_folder(folder_path: String) -> void:
	# Parse any CardInfo resources in the directory and load them
	for file_path: String in DirAccess.get_files_at(folder_path):
		file_path = file_path.replace(".import", "")
		file_path = file_path.replace(".remap", "")
		
		var card_info: CardInfo = load(folder_path + file_path) as CardInfo
		if is_instance_valid(card_info):
			for count: int in range(card_info.pool_count):
				_all_cards.append(card_info)
	
	# Recurse into subdirectories (EXIT CONDITION: no subdirs)
	for sub_folder_path: String in DirAccess.get_directories_at(folder_path):
		_load_folder(folder_path + "/" + sub_folder_path + "/")
