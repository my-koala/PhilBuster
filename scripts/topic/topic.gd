@tool
extends Resource
class_name Topic

@export
var sentences: PackedStringArray = PackedStringArray()

@export
var relevant_words: Array[CardInfo] = []

@export
var irrelevant_words: Array[CardInfo] = []

func get_topic_name() -> String:
	return resource_path.get_file().get_basename().replace("_", " ")
