@tool
extends Control
class_name SentenceContainer

const FIELD_SCENE: PackedScene = preload("res://assets/sentence_container/sentence_container_field.tscn")

@onready
var _flow_container: FlowContainer = %flow_container as FlowContainer

var _instance_words: Array[SentenceContainerWord] = []
var _instance_field_basics: Array[SentenceContainerField] = []
var _instance_field_modifiers: Dictionary[SentenceContainerField, SentenceContainerField] = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_sentence("The Koala {v} the {n} in a cute manner.")

func clear_sentence() -> void:
	for instance_word: SentenceContainerWord in _instance_words:
		_flow_container.remove_child(instance_word)
		instance_word.queue_free()
	_instance_words.clear()
	
	for instance_field: SentenceContainerField in _instance_field_basics:
		_flow_container.remove_child(instance_field)
		instance_field.queue_free()
	
	# TODO: notify via signal of removed cards?
	# should cards be freed from here?
	_instance_field_basics.clear()
	_instance_field_modifiers.clear()

func set_sentence(sentence: String) -> void:
	if !_instance_words.is_empty() || !_instance_field_basics.is_empty():
		return
	
	var tokens: PackedStringArray = sentence.split(" ", false)
	for token: String in tokens:
		if token.begins_with("{") && token.ends_with("}"):
			var word_type: String = token.substr(1, token.length() - 2).to_lower()
			if word_type == "n":
				# TODO: instantiate a packedscene isntead
				var instance_field: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				instance_field.card_type = SentenceContainerField.CardType.NOUN
				_instance_field_basics.append(instance_field)
				_flow_container.add_child(instance_field)
				continue
			
			if word_type == "v":
				var instance_field: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				instance_field.card_type = SentenceContainerField.CardType.VERB
				_instance_field_basics.append(instance_field)
				_flow_container.add_child(instance_field)
				continue
		
		# Create a normal, static word.
		var instance_word: SentenceContainerWord = SentenceContainerWord.new()
		instance_word.set_word(token)
		_instance_words.append(instance_word)
		_flow_container.add_child(instance_word)
