@tool
extends Control
class_name SessionSubmit

signal submitted()

@export
var enabled: bool = true:
	get:
		return enabled
	set(value):
		if enabled != value:
			enabled = value
			_dirty = true

@export
var sentence_complete: bool = false:
	get:
		return sentence_complete
	set(value):
		if sentence_complete != value:
			sentence_complete = value
			_dirty = true

@onready
var _rich_text_label: RichTextLabel = %rich_text_label as RichTextLabel
@onready
var _button: Button = %button as Button

var _dirty: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_button.pressed.connect(submitted.emit)

func _physics_process(delta: float) -> void:
	if !_dirty:
		return
	_dirty = false
	
	_button.disabled = !enabled
	
	_rich_text_label.text = ""
	if enabled:
		if sentence_complete:
			_rich_text_label.append_text("[color=green][b]READY![/b][/color]\n")
			_rich_text_label.append_text("[color=white][i]Sentence is Complete![/i][/color]")
		else:
			_rich_text_label.append_text("[color=red][b]WARNING![/b][/color]\n")
			_rich_text_label.append_text("[color=white][i]Sentence is Incomplete![/i][/color]")
