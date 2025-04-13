@tool
extends Label
class_name SentenceContainerWord

# TODO: Animations on creation/deletion, reading, and idle.
# NOTE:
# 

var _word: String = ""

func set_word(word: String) -> void:
	_word = word
	
	text = _word
