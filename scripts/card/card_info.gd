@tool
class_name CardInfo
extends Resource

## Base class for all word cards.

@export
var rarity: int = 0

func get_word() -> String:
	return resource_path.get_file().get_basename().replace("_", " ")
