@tool
extends Node
class_name TopicLoader

## Node for interfacing with Topic resources.
## Provides functionality for retrieving topic list, sentences, and word relevancy.
## NOTE: Topic resources should not be directly accessible outside of this class.

const TOPIC_DIRECTORY: String = "res://assets/topics/"

## When retrieving sentences, skip sentences that were already retrieved before.
## Usually used to prevent repeated sentences within a session.
@export
var skip_duplicate_sentences: bool = true

@export
var use_global_sentences: bool = false

var _topic_global: Topic = null
var _topics: Dictionary[String, Topic] = {}

## The current topic to pull sentences from.
var _topic: Topic = null
var _topic_name: String = ""
var _topic_sentence_pool: PackedStringArray = PackedStringArray()

func _init() -> void:
	for file_path: String in DirAccess.get_files_at(TOPIC_DIRECTORY):
		file_path = file_path.replace(".import", "")
		
		var topic: Topic = load(TOPIC_DIRECTORY + file_path) as Topic
		if is_instance_valid(topic):
			if topic.get_topic_name() == "global":
				_topic_global = topic
			else:
				_topics[topic.get_topic_name()] = topic
	
	if !is_instance_valid(_topic_global):
		push_error("TopicLoader | Failed to read global topic.")
	
	if _topics.is_empty():
		push_error("TopicLoader | Topic pool is empty.")

func get_topic_names() -> PackedStringArray:
	var topics: Array[String] = _topics.keys()
	topics.make_read_only()
	return topics

func get_topic() -> String:
	return _topic_name

func set_topic(topic_name: String) -> bool:
	if !_topics.has(topic_name):
		push_error("TopicLoader | Failed to set current topic to '%s': could not find topic name." % [topic_name])
		return false
	
	if _topic_name == topic_name:
		return true
	
	_topic = _topics[topic_name]
	_topic_name = topic_name
	reset_topic_sentence_pool()
	return true

func get_topic_sentence() -> String:
	if !is_instance_valid(_topic):
		push_error("TopicLoader | Failed to get topic sentence: topic is not set.")
		return ""
	
	if _topic_sentence_pool.is_empty():
		reset_topic_sentence_pool()
	
	if _topic_sentence_pool.is_empty():
		push_error("TopicLoader | Failed to get topic sentence: empty topic sentence pool.")
		return ""
	
	var topic_sentence_index: int = randi_range(0, _topic_sentence_pool.size() - 1)
	var topic_sentence: String = _topic_sentence_pool[topic_sentence_index]
	
	if skip_duplicate_sentences:
		_topic_sentence_pool.remove_at(topic_sentence_index)
	
	return topic_sentence

func reset_topic_sentence_pool() -> void:
	_topic_sentence_pool = PackedStringArray()
	
	if use_global_sentences && is_instance_valid(_topic_global):
		_topic_sentence_pool.append_array(_topic_global.sentences)
	
	if is_instance_valid(_topic):
		_topic_sentence_pool.append_array(_topic.sentences)

func is_word_relevant(word: String) -> bool:
	if is_instance_valid(_topic):
		return _topic.relevant_words.find_custom(func(card_info: CardInfo) -> bool: return card_info.get_word() == word)
	return false

func is_word_irrelevant(word: String) -> bool:
	if is_instance_valid(_topic):
		return _topic.irrelevant_words.find_custom(func(card_info: CardInfo) -> bool: return card_info.get_word() == word)
	return false
