@tool
extends Resource
class_name CardLibrary

@export
var base_card_path: String

var all_cards: Array[CardInfo]

func _init() -> void:
	if Engine.is_editor_hint:
		return
	
	print("Loading cards...")
	
	var base_dir: DirAccess = DirAccess.open(base_card_path)
	if (!is_instance_valid(base_dir)):
		return
	
	_load_folder(base_dir)
	
	print("Loaded %d cards." % all_cards.size())

# lets gooo recursive functions
func _load_folder(path: DirAccess) -> void:
	for file: String in path.get_files():
		# god I wish GDScript had nameof()
		var card_info: CardInfo = load(file) as CardInfo
		if (!is_instance_valid(card_info)):
			continue
		
		all_cards.append(card_info)
		
	for subdirectory: String in path.get_directories():
		var subdir_access: DirAccess = DirAccess.open(subdirectory)
		if (!is_instance_valid(subdir_access)):
			return
		
		_load_folder(subdir_access)
