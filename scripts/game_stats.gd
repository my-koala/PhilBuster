@tool
extends Resource
class_name GameStats

## Class that stores a player's stats, including deck, money, and purchases.

const TOPIC_DIRECTORY: String = "res://assets/topics/"
const DECK_MAX_COUNT: int = 30

signal deck_card_info_added(card_info: CardInfo)
signal deck_card_info_removed(card_info: CardInfo)

signal money_added(amount: int)
signal money_removed(amount: int)

@export
var starting_deck: Array[CardInfo] = []
@export
var starting_money: int = 0
@export
var max_discards: int = 5

@export
var skip_duplicate_sentences: bool = true
@export
var use_global_sentences: bool = true
@export
var use_topic_memory: bool = true

var _deck: Array[CardInfo] = []
var _money: int = 0
var _session: int = 0

var _topic: Topic = null
var _topic_name: String = ""
var _topic_memory_relevant: Dictionary[String, Dictionary] = {}# Dictionary[String, Dictionary[String, bool]]
var _topic_memory_irrelevant: Dictionary[String, Dictionary] = {}# Dictionary[String, Dictionary[String, bool]]

static var _topic_global: Topic = null
static var _topics: Dictionary[String, Topic] = {}

static func _static_init() -> void:
	for file_path: String in DirAccess.get_files_at(TOPIC_DIRECTORY):
		print("GameStats | Loading topic '%s'..." % [file_path])
		file_path = file_path.replace(".import", "")
		file_path = file_path.replace(".remap", "")
		
		var topic: Topic = load(TOPIC_DIRECTORY + file_path) as Topic
		if is_instance_valid(topic):
			if topic.get_topic_name() == "global":
				_topic_global = topic
			else:
				_topics[topic.get_topic_name()] = topic
	
	if !is_instance_valid(_topic_global):
		push_error("GameStats | Failed to read global topic.")
	
	if _topics.is_empty():
		push_error("GameStats | Topic pool is empty.")

static func get_topic_names() -> PackedStringArray:
	var topics: Array[String] = _topics.keys()
	topics.make_read_only()
	return topics

static func get_topic_count() -> int:
	return _topics.size()

func _init() -> void:
	reset_deck()
	reset_money()

func get_deck() -> Array[CardInfo]:
	var deck: Array[CardInfo] = _deck.duplicate()
	deck.make_read_only()
	return deck

func reset_deck() -> void:
	_deck = starting_deck.duplicate()

func reset_money() -> void:
	_money = starting_money

func reset_topic_memory() -> void:
	_topic_memory_relevant.clear()
	_topic_memory_irrelevant.clear()

func deck_append(card_info: CardInfo) -> bool:
	if !is_instance_valid(card_info):
		return false
	
	if _deck.size() == DECK_MAX_COUNT:
		return false
	
	_deck.append(card_info)
	deck_card_info_added.emit(card_info)
	return true

func deck_remove(card_info: CardInfo) -> bool:
	if !is_instance_valid(card_info):
		return false
	
	if !_deck.has(card_info):
		return false
	
	_deck.erase(card_info)
	deck_card_info_removed.emit(card_info)
	return true

func deck_has(card_info: CardInfo) -> bool:
	return _deck.has(card_info)

func deck_is_full() -> bool:
	return _deck.size() == DECK_MAX_COUNT

func deck_get_size() -> int:
	return _deck.size()

func deck_is_empty() -> bool:
	return _deck.is_empty()

func deck_clear() -> void:
	while !_deck.is_empty():
		var card_info: CardInfo = _deck[_deck.size() - 1]
		_deck.pop_back()
		deck_card_info_removed.emit(card_info)

func get_money() -> int:
	return _money

func money_add(amount: int) -> void:
	_money += amount
	money_added.emit()

func money_remove(amount: int) -> void:
	amount = maxi(mini(amount, _money), 0)
	if amount > 0:
		_money -= amount
		money_removed.emit(amount)

func calculate_price_for(card_info : CardInfo) -> int:
	return card_info.price * (floori(_session * 0.25) + 1)

func get_session() -> int:
	return _session

func session_increment() -> void:
	_session += 1

var _topic_sentence_pool: PackedStringArray = PackedStringArray()

func set_topic_name(topic_name: String) -> bool:
	if !_topics.has(topic_name):
		push_error("GameStats | Failed to set current topic to '%s': could not find topic name." % [topic_name])
		return false
	
	if _topic_name == topic_name:
		return true
	
	_topic = _topics[topic_name]
	_topic_name = topic_name
	topic_reset_sentence_pool()
	return true

func topic_get_name() -> String:
	return _topic_name

func topic_randomize() -> void:
	set_topic_name(_topics[_topics.keys()[randi_range(0, _topics.size() - 1)]].get_topic_name())

func topic_get_sentence() -> String:
	if !is_instance_valid(_topic):
		push_error("GameStats | Failed to get topic sentence: topic is not set.")
		return ""
	
	if _topic_sentence_pool.is_empty():
		topic_reset_sentence_pool()
	
	if _topic_sentence_pool.is_empty():
		push_error("TopicLoader | Failed to get topic sentence: empty topic sentence pool.")
		return ""
	
	var topic_sentence_index: int = randi_range(0, _topic_sentence_pool.size() - 1)
	var topic_sentence: String = _topic_sentence_pool[topic_sentence_index]
	
	if skip_duplicate_sentences:
		_topic_sentence_pool.remove_at(topic_sentence_index)
	
	return topic_sentence

func topic_reset_sentence_pool() -> void:
	_topic_sentence_pool = PackedStringArray()
	
	if use_global_sentences && is_instance_valid(_topic_global):
		_topic_sentence_pool.append_array(_topic_global.sentences)
	
	if is_instance_valid(_topic):
		_topic_sentence_pool.append_array(_topic.sentences)

func topic_is_word_relevant(word: String) -> bool:
	if use_topic_memory:
		if !_topic_memory_relevant.has(_topic_name):
			return false
		if !_topic_memory_relevant[_topic_name].has(word):
			return false
		return _topic_memory_relevant[_topic_name][word]
	return _topic.is_word_relevant(word)

func topic_is_word_irrelevant(word: String) -> bool:
	if use_topic_memory:
		if !_topic_memory_irrelevant.has(_topic_name):
			return false
		if !_topic_memory_irrelevant[_topic_name].has(word):
			return false
		return _topic_memory_irrelevant[_topic_name][word]
	return _topic.is_word_irrelevant(word)

func topic_memory_add_word(word: String) -> void:
	if !_topic_memory_relevant.has(_topic_name):
		_topic_memory_relevant[_topic_name] = Dictionary()
	_topic_memory_relevant[_topic_name][word] = _topic.is_word_relevant(word)
	if !_topic_memory_irrelevant.has(_topic_name):
		_topic_memory_irrelevant[_topic_name] = Dictionary()
	_topic_memory_irrelevant[_topic_name][word] = _topic.is_word_irrelevant(word)
