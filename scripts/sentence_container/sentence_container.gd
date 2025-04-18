@tool
extends Control
class_name SentenceContainer

# TODO: popup display for word and field, displaying amounts/multipliers on read

const FIELD_SCENE: PackedScene = preload("res://assets/sentence_container/sentence_container_field.tscn")

signal read_started()
signal read_word()
signal read_field(card_info: CardInfo)
signal read_stopped()

signal card_info_removed(card_info: CardInfo)

@onready
var _flow_container: FlowContainer = %flow_container as FlowContainer

var _word_instances: Array[SentenceContainerWord] = []
var _field_instances: Array[SentenceContainerField] = []

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
	

func has_sentence() -> bool:
	return !_word_instances.is_empty() && !_field_instances.is_empty()

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
	
	for field_instance: SentenceContainerField in _field_instances:
		_flow_container.remove_child(field_instance)
		field_instance.queue_free()
	_field_instances.clear()

func set_sentence(sentence: String) -> bool:
	if !_word_instances.is_empty() || !_field_instances.is_empty():
		return false
	
	if sentence.is_empty():
		return false
	
	var tokens: PackedStringArray = sentence.split(" ", false)
	if tokens.is_empty():
		return false
	
	var reg_ex: RegEx = RegEx.new()
	reg_ex.compile("\\{([NVnv])\\}")
	
	for token: String in sentence.split(" ", false):
		var reg_ex_matches: Array[RegExMatch] = reg_ex.search_all(token)
		var start: int = 0
		for reg_ex_match: RegExMatch in reg_ex_matches:
			if reg_ex_match.get_start() > start:
				var prefix: String = token.substr(start, reg_ex_match.get_start() - start)
				_insert_word_instance(prefix)
			start = reg_ex_match.get_end()
			
			match reg_ex_match.get_string()[1]:
				"N", "n":
					_insert_field_instance(null).card_type = SentenceContainerField.CardType.NOUN
				"V", "v":
					_insert_field_instance(null).card_type = SentenceContainerField.CardType.VERB
		
		if start < token.length():
			var suffix: String = token.substr(start)
			_insert_word_instance(suffix)
	
	return true

func try_insert_card_info(card_info: CardInfo, insert_position: Vector2) -> bool:
	for field_instance: SentenceContainerField in _field_instances:
		if field_instance.get_global_rect().has_point(insert_position):
			if !field_instance.has_card_info() && field_instance.set_card_info(card_info):
				return true
			if field_instance.check_card_type_modifier(card_info as CardInfoModifier):
				_insert_field_instance(card_info, field_instance.get_index())
				return true
			break
	return false

func _insert_field_instance(card_info: CardInfo, index: int = -1) -> SentenceContainerField:
	var field_instance: SentenceContainerField = FIELD_SCENE.instantiate() as SentenceContainerField
	
	field_instance.press_started.connect(_on_field_pressed.bind(field_instance))
	
	if is_instance_valid(card_info):
		field_instance.set_card_info(card_info, true)
	
	_flow_container.add_child(field_instance)
	if index > -1:
		_flow_container.move_child(field_instance, index)
	
	_field_instances.append(field_instance)
	
	return field_instance

func _insert_word_instance(word: String, index: int = -1) -> SentenceContainerWord:
	var word_instance: SentenceContainerWord = SentenceContainerWord.new()
	word_instance.set_word(word)
	_word_instances.append(word_instance)
	_flow_container.add_child(word_instance)
	if index > -1:
		_flow_container.move_child(word_instance, index)
	return word_instance

func _on_field_pressed(field_instance: SentenceContainerField) -> void:
	if field_instance.has_card_info():
		var card_info: CardInfo = field_instance.get_card_info()
		field_instance.set_card_info(null)
		card_info_removed.emit(card_info)
		
		match field_instance.card_type:
			SentenceContainerField.CardType.ADJECTIVE, SentenceContainerField.CardType.ADVERB:
				_flow_container.remove_child(field_instance)
				field_instance.queue_free()
				_field_instances.erase(field_instance)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _read_sentence:
		if _read_sentence_index >= _flow_container.get_child_count():
			_read_sentence = false
			read_stopped.emit()
		elif _read_sentence_cooldown > 0.0:
			_read_sentence_cooldown -= delta
		else:
			_read_sentence_cooldown = read_sentence_cooldown
			
			var node: Node = _flow_container.get_child(_read_sentence_index)
			
			var word: SentenceContainerWord = node as SentenceContainerWord
			if is_instance_valid(word):
				word.play_read_animation()
				read_word.emit()
			
			var field_instance: SentenceContainerField = node as SentenceContainerField
			if is_instance_valid(field_instance):
				field_instance.play_read_animation()
				read_field.emit(field_instance.get_card_info())
			
			_read_sentence_index += 1
