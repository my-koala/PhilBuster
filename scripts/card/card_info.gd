@tool
class_name CardInfo
extends Resource

## Base class for all word cards.

## Amount of session time taken to say this word
@export
var time: int = 1

## Base shop price for this card
@export
var price: int = 1

## How many duplicates of this card to add into the global card pool
@export
var pool_count: int = 2

func get_word() -> String:
	return resource_path.get_file().get_basename().replace("_", " ")

static func get_color() -> Color:
	return Color.GRAY

# NOTE: This is only used for displaying which topics this word is relevant to in the inspector.
# Just a quality of life tool for balancing the words!
const TOPIC_DIRECTORY: String = "res://assets/topics/"

static var _topics: Array[Topic] = []

static func _static_init() -> void:
	if !Engine.is_editor_hint():
		return
	for file_path: String in DirAccess.get_files_at(TOPIC_DIRECTORY):
		file_path = file_path.replace(".import", "")
		file_path = file_path.replace(".remap", "")
		
		var topic: Topic = load(TOPIC_DIRECTORY + file_path) as Topic
		if is_instance_valid(topic):
			_topics.append(topic)

func _get_property_list() -> Array[Dictionary]:
	if !Engine.is_editor_hint():
		return []
	
	var property_list: Array[Dictionary] = []
	property_list.append({
		"name": &"relevant_topics",
		"class_name": &"",
		"type": TYPE_PACKED_STRING_ARRAY,
		#"hint": PROPERTY_HINT_ARRAY_TYPE,
		#"hint_string": "String",
		"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
	})
	property_list.append({
		"name": &"irrelevant_topics",
		"class_name": &"",
		"type": TYPE_PACKED_STRING_ARRAY,
		#"hint": PROPERTY_HINT_ARRAY_TYPE,
		#"hint_string": "String",
		"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
	})
	property_list.append({
		"name": &"neutral_topics",
		"class_name": &"",
		"type": TYPE_PACKED_STRING_ARRAY,
		#"hint": PROPERTY_HINT_ARRAY_TYPE,
		#"hint_string": "String",
		"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
	})
	return property_list

func _get(property: StringName) -> Variant:
	if !Engine.is_editor_hint():
		return null
	
	match property:
		&"relevant_topics":
			var relevant_topics: PackedStringArray = PackedStringArray()
			for topic: Topic in _topics:
				if topic.is_word_relevant(get_word()):
					relevant_topics.append(topic.get_topic_name())
			return relevant_topics
		&"irrelevant_topics":
			var relevant_topics: PackedStringArray = PackedStringArray()
			for topic: Topic in _topics:
				if topic.is_word_irrelevant(get_word()):
					relevant_topics.append(topic.get_topic_name())
			return relevant_topics
		&"neutral_topics":
			var relevant_topics: PackedStringArray = PackedStringArray()
			for topic: Topic in _topics:
				if topic.is_word_neutral(get_word()):
					relevant_topics.append(topic.get_topic_name())
			return relevant_topics
	return null
