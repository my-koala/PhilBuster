extends Node
class_name CardLibrary

@export
var base_card_path: String

var _available_cards : Array[CardInfo]
var _all_cards: Array[CardInfo]

# TODO: Influence random card selection by rarity somehow
## Pulls a random card from the library which has never been pulled.
func get_random_card() -> CardInfo:
	if _available_cards.size() == 0:
		return null
	
	return _available_cards[randi_range(0, _available_cards.size())]

## "Pulls" a card, removing it from available cards to randomly draw
func pull_card(card_info: CardInfo) -> void:
	_available_cards.erase(card_info)

## Resets the state of the library, allowing every card to be pulled again
func reset_library() -> void:
	_available_cards = _all_cards.duplicate()

func _ready() -> void:
	print("Loading cards...")
	
	var base_dir: DirAccess = DirAccess.open(base_card_path)
	if (!is_instance_valid(base_dir)):
		return
	
	_load_folder(base_dir)
	reset_library()
	
	print("Loaded %d cards." % _all_cards.size())

# lets gooo recursive functions
func _load_folder(path: DirAccess) -> void:
	var dir: String = path.get_current_dir()
	
	# Parse any CardInfo resources in the directory and load them
	for file: String in path.get_files():
		# god I wish GDScript had nameof()
		var card_info: CardInfo = load("%s/%s" % [dir, file]) as CardInfo
		if (!is_instance_valid(card_info)):
			continue
		
		_all_cards.append(card_info)
	
	# Recurse into subdirectories (EXIT CONDITION: no subdirs)
	for subdirectory: String in path.get_directories():
		var subdir_access: DirAccess = DirAccess.open("%s/%s" % [dir, subdirectory])
		if (!is_instance_valid(subdir_access)):
			return
		
		_load_folder(subdir_access)
