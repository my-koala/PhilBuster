@tool
extends Control
class_name SentenceContainerField

signal selected()

signal card_instance_added(card_instance: CardInstance)
signal card_instance_removed(card_instance: CardInstance)

# TODO:
# Draw crawling ants border animation.

enum CardType {
	NOUN,
	VERB,
	ADJECTIVE,
	ADVERB,
}

@export
var card_type: CardType = CardType.NOUN:
	get:
		return card_type
	set(value):
		if card_type != value:
			card_type = value
			_dirty = true
			remove_card_instance()

@onready
var _color_rect: ColorRect = %color_rect as ColorRect
@onready
var _pickable: Control = %pickable as Control
@onready
var _rich_text_label: RichTextLabel = %rich_text_label as RichTextLabel

var _dirty: bool = false

var _card_instance: CardInstance = null

var _input_mouse_hovered: bool = false

func _card_type_check(card_instance: CardInstance) -> bool:
	if !is_instance_valid(card_instance):
		return false
	
	match card_type:
		CardType.NOUN:
			return card_instance.card_info is CardInfoBasicNoun
		CardType.VERB:
			return card_instance.card_info is CardInfoBasicVerb
		CardType.ADJECTIVE:
			return card_instance.card_info is CardInfoModifierAdjective
		CardType.ADVERB:
			return card_instance.card_info is CardInfoModifierAdverb
	return false

func add_card_instance(card_instance: CardInstance) -> bool:
	if !is_instance_valid(card_instance):
		return false
	
	if is_instance_valid(_card_instance):
		return false
	
	if _card_instance == card_instance:
		return false
	
	if !_card_type_check(card_instance):
		return false
	
	_card_instance = card_instance
	_dirty = true
	
	card_instance_added.emit(card_instance)
	return true

func get_card_instance() -> CardInstance:
	return _card_instance

func remove_card_instance() -> bool:
	if !is_instance_valid(_card_instance):
		return false
	
	var card_instance: CardInstance = _card_instance
	
	_card_instance = null
	_dirty = true
	
	card_instance_removed.emit(card_instance)
	return true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_pickable.mouse_entered.connect(func() -> void: _input_mouse_hovered = true)
	_pickable.mouse_exited.connect(func() -> void: _input_mouse_hovered = false)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if _input_mouse_hovered:
		get_viewport().set_input_as_handled()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			selected.emit()

func _process(delta: float) -> void:
	if !_dirty:
		return
	_dirty = false
	
	var placeholder_text: String = ""
	
	match card_type:
		CardType.NOUN:
			_color_rect.color = Color.RED
			placeholder_text = "noun"
		CardType.VERB:
			_color_rect.color = Color.BLUE
			placeholder_text = "verb"
		CardType.ADJECTIVE:
			_color_rect.color = Color.ORANGE_RED
			placeholder_text = "adjective"
		CardType.ADVERB:
			_color_rect.color = Color.BLUE_VIOLET
			placeholder_text = "adverb"
	
	if is_instance_valid(_card_instance):
		_rich_text_label.text = "[b]%s[/b]" % [_card_instance.card_info.word]
	else:
		_rich_text_label.text = "([i]%s[i])" % [placeholder_text]
	
