@tool
extends Control
class_name SentenceContainer

const FIELD_SCENE: PackedScene = preload("res://assets/sentence_container/sentence_container_field.tscn")

signal field_press_started(field: SentenceContainerField)

@onready
var _flow_container: FlowContainer = %flow_container as FlowContainer

var _word_instances: Array[SentenceContainerWord] = []
var _field_instance_basics: Array[SentenceContainerField] = []
var _field_instance_modifiers: Dictionary[SentenceContainerField, SentenceContainerField] = {}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	

func get_fields() -> Array[SentenceContainerField]:
	var fields: Array[SentenceContainerField] = []
	fields.append_array(_field_instance_basics)
	fields.append_array(_field_instance_modifiers.keys())
	fields.make_read_only()
	return fields

func has_sentence() -> bool:
	return !_word_instances.is_empty() && !_field_instance_basics.is_empty()

func clear_sentence() -> void:
	for word_instance: SentenceContainerWord in _word_instances:
		_flow_container.remove_child(word_instance)
		word_instance.queue_free()
	_word_instances.clear()
	
	for field_instance: SentenceContainerField in _field_instance_basics:
		_flow_container.remove_child(field_instance)
		field_instance.queue_free()
	
	# TODO: notify via signal of removed cards?
	# should cards be freed from here?
	_field_instance_basics.clear()
	_field_instance_modifiers.clear()

func set_sentence(sentence: String) -> bool:
	if !_word_instances.is_empty() || !_field_instance_basics.is_empty():
		return false
	
	var tokens: PackedStringArray = sentence.split(" ", false)
	for token: String in tokens:
		if token.begins_with("{") && token.ends_with("}"):
			var word_type: String = token.substr(1, token.length() - 2).to_lower()
			if word_type == "n":
				var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				field_instance.card_type = SentenceContainerField.CardType.NOUN
				field_instance.press_started.connect(field_press_started.emit.bind(field_instance))
				field_instance.card_instance_added.connect(_on_field_card_instance_added.bind(field_instance))
				field_instance.card_instance_removed.connect(_on_field_card_instance_removed.bind(field_instance))
				_field_instance_basics.append(field_instance)
				_flow_container.add_child(field_instance)
				continue
			
			if word_type == "v":
				var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				field_instance.card_type = SentenceContainerField.CardType.VERB
				field_instance.press_started.connect(field_press_started.emit.bind(field_instance))
				field_instance.card_instance_added.connect(_on_field_card_instance_added.bind(field_instance))
				field_instance.card_instance_removed.connect(_on_field_card_instance_removed.bind(field_instance))
				_field_instance_basics.append(field_instance)
				_flow_container.add_child(field_instance)
				continue
		
		# Create a normal, static word.
		var word_instance: SentenceContainerWord = SentenceContainerWord.new()
		word_instance.set_word(token)
		_word_instances.append(word_instance)
		_flow_container.add_child(word_instance)
	
	return true

func add_field_modifier(field: SentenceContainerField, card_instance: CardInstance) -> bool:
	if !(card_instance.card_info is CardInfoModifier):
		return false
	
	match field.card_type:
		SentenceContainerField.CardType.NOUN:
			if card_instance.card_info is CardInfoModifierAdjective:
				var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				field_instance.card_type = SentenceContainerField.CardType.ADJECTIVE
				field_instance.press_started.connect(field_press_started.emit.bind(field_instance))
				field_instance.card_instance_added.connect(_on_field_card_instance_added.bind(field_instance))
				field_instance.card_instance_removed.connect(_on_field_card_instance_removed.bind(field_instance))
				_flow_container.add_child(field_instance)
				_flow_container.move_child(field_instance, field.get_index())
				field_instance.add_card_instance(card_instance)
				_field_instance_modifiers[field] = field_instance
				return true
		SentenceContainerField.CardType.VERB:
			if card_instance.card_info is CardInfoModifierAdverb:
				var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				field_instance.card_type = SentenceContainerField.CardType.ADVERB
				field_instance.press_started.connect(field_press_started.emit.bind(field_instance))
				field_instance.card_instance_added.connect(_on_field_card_instance_added.bind(field_instance))
				field_instance.card_instance_removed.connect(_on_field_card_instance_removed.bind(field_instance))
				_flow_container.add_child(field_instance)
				_flow_container.move_child(field_instance, field.get_index())
				field_instance.add_card_instance(card_instance)
				_field_instance_modifiers[field] = field_instance
				return true
	
	return false

func _on_field_card_instance_added(card_instance: CardInstance, field: SentenceContainerField) -> void:
	pass

func _on_field_card_instance_removed(card_instance: CardInstance, field: SentenceContainerField) -> void:
	match field.card_type:
		SentenceContainerField.CardType.ADJECTIVE, SentenceContainerField.CardType.ADVERB:
			# Free card instance.
			_flow_container.remove_child(field)
			field.queue_free()
