class_name SentenceLoader
extends Resource

@export var folder_path : String

var _generic_sentences : PackedStringArray
var _loaded_sentences : Dictionary[String, PackedStringArray]

## Given a (case insensitive) topic name, return a random sentence
func get_topic_sentence(topic: String) -> String:
	# TODO: Should we consider returning an error if the topic isnt loaded
	var topic_sentences : PackedStringArray = _loaded_sentences.get(topic.to_lower(), [])
	
	var total_topic_length : int = _generic_sentences.size() + topic_sentences.size()
	
	# This should only ever be a possibility if we have no loaded sentences and no generic sentences to fall back to
	if total_topic_length == 0:
		return "{n} should {v} to Caeden because this shit broke!"
	
	var rng : int = randi_range(0, total_topic_length)
	
	return _generic_sentences[rng] if rng < _generic_sentences.size() else topic_sentences[rng - _generic_sentences.size()]

func _init() -> void:
	for file_path : String in DirAccess.get_files_at(folder_path):
		# (i looked this up on reddit beforehand lmao)
		# If we are in an exported Godot project, we need to modify our file name slightly
		# to account for the fact that these files are imported
		if (file_path.get_extension() == "import"):
			file_path = file_path.replace('.import', '')
		
		# hacky way of just getting the name of the file
		var file_name : String = file_path.get_file().split('.')[0]
		
		# Save the generic sentences in their own special place
		# otherwise append sentences to the dictionary
		if (file_path.get_file().contains("generic")):
			_generic_sentences = _load_sentence_file(file_path)
		else:
			_loaded_sentences[file_name.to_lower()] = _load_sentence_file(file_path)

func _load_sentence_file(path : String) -> PackedStringArray:
	var sentences : PackedStringArray = []
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	
	# Iterate through all lines of our file and append them as sentences
	# TODO: Should we consider basic parsing to ensure that any curly braces are *ONLY* valid {n} and {v}
	while !file.eof_reached():
		var line : String = file.get_line()
		sentences.append(line)
		
	return sentences
