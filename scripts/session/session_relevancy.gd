@tool
extends Control
class_name SessionRelevancy

@onready
var _rich_text_label: RichTextLabel = %rich_text_label as RichTextLabel

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	clear_status()

func clear_status() -> void:
	_rich_text_label.text = ""
	visible = false

func set_status(word: String, topic: String, is_modifier: bool, relevant: bool, relevant_bust: int, irrelevant: bool, irrelevant_bust: int, neutral: bool, neutral_bust: int) -> void:
	_rich_text_label.text = ""
	if word.is_empty() || topic.is_empty():
		visible = false
		return
	visible = true
	if is_modifier:
		_rich_text_label.text = ("'%s' is a modifier" % [word])
		return
	if relevant:
		_rich_text_label.text = ("'%s' is [color=dark_green]relevant[/color] to '%s' (-%d Bust)" % [word, topic, relevant_bust])
		return
	if irrelevant:
		_rich_text_label.text = ("'%s' is [color=dark_red]irrelevant[/color] to '%s' (+%d Bust)" % [word, topic, irrelevant_bust])
		return
	if neutral:
		_rich_text_label.text = ("'%s' is [color=black]neutral[/color] to '%s' (+%d Bust)" % [word, topic, neutral_bust])
		return
	_rich_text_label.text = ("'%s' relevancy to '%s' is [color=dark_gray]unknown[/color]" % [word, topic])
