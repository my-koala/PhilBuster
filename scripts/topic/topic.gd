@tool
extends Resource
class_name Topic

@export
var sentences: PackedStringArray = PackedStringArray()

@export
var words: Dictionary[CardInfo, bool] = {}:
	get:
		return words
	set(value):
		if words != value:
			words = value
			_words_dirty = true

var _words: Dictionary[String, bool] = {}
var _words_dirty: bool = true

func get_topic_sentences() -> PackedStringArray:
	return sentences.duplicate()

func get_topic_name() -> String:
	return resource_path.get_file().get_basename().replace("_", " ")

func is_word_relevant(word: String) -> bool:
	if _words_dirty:
		_update_words()
		_words_dirty = false
	return _words.has(word) && _words[word]

func is_word_irrelevant(word: String) -> bool:
	if _words_dirty:
		_update_words()
		_words_dirty = false
	return _words.has(word) && !_words[word]

func _update_words() -> void:
	_words.clear()
	for card_info: CardInfo in words:
		_words[card_info.get_word()] = words[card_info]
