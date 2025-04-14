@tool
class_name SentenceLoader
extends Node

# TODO: sentence rarity, difficulty, length filters? may require a csv file

const SENTENCE_FOLDER_PATH: String = "res://assets/sentences/"

var _global_sentences: PackedStringArray = PackedStringArray()
var _topic_sentences: Dictionary[String, PackedStringArray] = {}

func _init() -> void:
	for file_path: String in DirAccess.get_files_at(SENTENCE_FOLDER_PATH):
		file_path = SENTENCE_FOLDER_PATH + file_path
		# If we are in an exported Godot project, we need to modify our file name slightly
		# to account for the fact that these files are imported
		if file_path.ends_with(".import"):
			file_path = file_path.replace(".import", "")
		if file_path.ends_with(".uid"):
			continue
		
		var file_name: String = file_path.get_file().get_basename()
		
		# Save the global sentences in their own special place
		# otherwise append sentences to the dictionary
		if file_name.to_lower() == "global":
			_global_sentences = _load_sentences(file_path)
		else:
			_topic_sentences[file_name.to_lower()] = _load_sentences(file_path)

## Given a (case insensitive) topic name, return a random sentence
func get_random_sentence(topic: String) -> String:
	topic = topic.to_lower()
	if topic.is_empty() || topic == "global":
		return _global_sentences[randi_range(0, _global_sentences.size() - 1)]
	
	if !_topic_sentences.has(topic):
		push_error("Topic '%s' not found." % [topic])
		return _global_sentences[randi_range(0, _global_sentences.size() - 1)]
	
	var index: int = randi_range(0, _global_sentences.size() + _topic_sentences[topic].size() - 1)
	
	if index < _global_sentences.size():
		return _global_sentences[index]
	return _topic_sentences[topic][index]

func _load_sentences(file_path: String) -> PackedStringArray:
	var sentences: PackedStringArray = PackedStringArray()
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	
	if !is_instance_valid(file):
		push_error("Error reading topic file from file path '%s'." % [file_path])
		return sentences
	
	while !file.eof_reached():
		sentences.append(file.get_line())
	
	return sentences
