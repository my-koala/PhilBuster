@tool
extends Control
class_name SentenceContainer

# TODO: popup display for word and field, displaying amounts/multipliers on read

const FIELD_SCENE: PackedScene = preload("res://assets/sentence_container/sentence_container_field.tscn")

const EMPTY_BUST_PENALTY: int = 10

signal read_started()
signal read_word(time: int)
signal read_field_empty(bust: int)
signal read_field_basic(time: int, money: int, bust: int)
signal read_field_modifier(time_multiplier: float, money_multiplier: float, bust_multiplier: float)
signal read_stopped()

signal field_press_started(field: SentenceContainerField)

@onready
var _sentence_loader: SentenceLoader = %sentence_loader as SentenceLoader
@onready
var _flow_container: FlowContainer = %flow_container as FlowContainer

var _word_instances: Array[SentenceContainerWord] = []
var _field_instance_basics: Array[SentenceContainerField] = []
var _field_instance_modifiers: Dictionary[SentenceContainerField, SentenceContainerField] = {}

@export_range(0.0, 1.0, 0.001)
var read_sentence_cooldown: float = 0.1:
	get:
		return read_sentence_cooldown
	set(value):
		read_sentence_cooldown = clampf(value, 0.0, 1.0)

var _read_sentence_cooldown: float = 0.0
var _read_sentence: bool = false
var _read_sentence_index: int = 0

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

func read_sentence() -> void:
	if !_read_sentence:
		_read_sentence = true
		_read_sentence_index = 0
		read_started.emit()

func clear_sentence() -> void:
	for word_instance: SentenceContainerWord in _word_instances:
		_flow_container.remove_child(word_instance)
		word_instance.queue_free()
	_word_instances.clear()
	
	for field_instance_basic: SentenceContainerField in _field_instance_basics:
		_flow_container.remove_child(field_instance_basic)
		field_instance_basic.queue_free()
	_field_instance_basics.clear()
	
	for field_instance_modifier: SentenceContainerField in _field_instance_modifiers:
		_flow_container.remove_child(field_instance_modifier)
		field_instance_modifier.queue_free()
	_field_instance_modifiers.clear()

func set_sentence(sentence: String) -> bool:
	if !_word_instances.is_empty() || !_field_instance_basics.is_empty():
		return false
	
	if sentence.is_empty():
		return false
	
	var tokens: PackedStringArray = sentence.split(" ", false)
	if tokens.is_empty():
		return false
	
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

func generate_sentence(topic: String) -> bool:
	return set_sentence(_sentence_loader.get_random_sentence(topic))

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
				_field_instance_modifiers[field_instance] = field
				return true
		SentenceContainerField.CardType.ADJECTIVE:
			if card_instance.card_info is CardInfoModifierAdjective:
				var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				field_instance.card_type = SentenceContainerField.CardType.ADJECTIVE
				field_instance.press_started.connect(field_press_started.emit.bind(field_instance))
				field_instance.card_instance_added.connect(_on_field_card_instance_added.bind(field_instance))
				field_instance.card_instance_removed.connect(_on_field_card_instance_removed.bind(field_instance))
				_flow_container.add_child(field_instance)
				_flow_container.move_child(field_instance, field.get_index())
				field_instance.add_card_instance(card_instance)
				_field_instance_modifiers[field_instance] = _field_instance_modifiers[field]
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
				_field_instance_modifiers[field_instance] = field
				return true
		SentenceContainerField.CardType.ADVERB:
			if card_instance.card_info is CardInfoModifierAdverb:
				var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
				field_instance.card_type = SentenceContainerField.CardType.ADJECTIVE
				field_instance.press_started.connect(field_press_started.emit.bind(field_instance))
				field_instance.card_instance_added.connect(_on_field_card_instance_added.bind(field_instance))
				field_instance.card_instance_removed.connect(_on_field_card_instance_removed.bind(field_instance))
				_flow_container.add_child(field_instance)
				_flow_container.move_child(field_instance, field.get_index())
				field_instance.add_card_instance(card_instance)
				_field_instance_modifiers[field_instance] = _field_instance_modifiers[field]
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

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _read_sentence:
		if _read_sentence_cooldown > 0.0:
			_read_sentence_cooldown -= delta
		else:
			_read_sentence_cooldown = read_sentence_cooldown
			
			var node: Node = _flow_container.get_child(_read_sentence_index)
			
			var word: SentenceContainerWord = node as SentenceContainerWord
			if is_instance_valid(word):
				word.play_read_animation()
				read_word.emit(1)
			
			var field: SentenceContainerField = node as SentenceContainerField
			if is_instance_valid(field):
				field.play_read_animation()
				match field.card_type:
					SentenceContainerField.CardType.NOUN, SentenceContainerField.CardType.VERB:
						if !field.has_card_instance():
							read_field_empty.emit(EMPTY_BUST_PENALTY)
						else:
							var card_info_basic: CardInfoBasic = field.get_card_instance().card_info as CardInfoBasic
							assert(is_instance_valid(card_info_basic))
							var time: int = card_info_basic.time
							var money: int = card_info_basic.reward
							# TODO: calculate relevancies
							var bust: int = 0
							
							# get all modifiers (adjectives/adverbs) that modify this field
							for field_modifier: SentenceContainerField in _field_instance_modifiers:
								if _field_instance_modifiers[field_modifier] == field:
									var card_info_modifier: CardInfoModifier = field_modifier.get_card_instance().card_info
									time *= card_info_modifier.time_multiplier
									money *= card_info_modifier.dollar_multiplier
									bust *= card_info_modifier.bust_multiplier
							
							# TODO: some sort of pop up display with info
							read_field_basic.emit(time, money, bust)
					SentenceContainerField.CardType.ADJECTIVE, SentenceContainerField.CardType.ADVERB:
						assert(field.has_card_instance())
						var card_info_modifier: CardInfoModifier = field.get_card_instance().card_info as CardInfoModifier
						assert(is_instance_valid(card_info_modifier))
						var time_multiplier: int = card_info_modifier.time_multiplier
						var money_multiplier: int = card_info_modifier.dollar_multiplier
						var bust_multiplier: int = card_info_modifier.bust_multiplier
						read_field_modifier.emit(time_multiplier, money_multiplier, bust_multiplier)
			
			_read_sentence_index += 1
			if _read_sentence_index >= _flow_container.get_child_count():
				_read_sentence = false
				read_stopped.emit()
