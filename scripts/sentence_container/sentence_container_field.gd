@tool
extends Control
class_name SentenceContainerField

# NOTE:
# can't use mouse_entered/exited for hover detection (since card is dragging over)

signal press_started()
signal press_stopped()
signal hover_started()
signal hover_stopped()
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
var _rich_text_label: RichTextLabel = %rich_text_label as RichTextLabel
@onready
var _preview: Control = %preview as Control
@onready
var _highlight: Highlight = %highlight as Highlight
@onready
var _button: Button = %button as Button

var _dirty: bool = false

var _card_instance: CardInstance = null

var _hover: bool = false

var _input_mouse_hover: bool = false
var _input_mouse_hover_unblocked: bool = false

func get_highlight() -> Highlight:
	return _highlight

func check_card_type(card_instance: CardInstance) -> bool:
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

func check_card_type_modifier(card_instance: CardInstance) -> bool:
	if !is_instance_valid(card_instance):
		return false
	
	match card_type:
		CardType.NOUN:
			return card_instance.card_info is CardInfoModifierAdjective
		CardType.VERB:
			return card_instance.card_info is CardInfoModifierAdverb
		CardType.ADJECTIVE:
			return false
		CardType.ADVERB:
			return false
	return false

func add_card_instance(card_instance: CardInstance) -> bool:
	if !is_instance_valid(card_instance):
		return false
	
	if is_instance_valid(_card_instance):
		return false
	
	if _card_instance == card_instance:
		return false
	
	if !check_card_type(card_instance):
		return false
	
	_card_instance = card_instance
	_dirty = true
	
	var parent: Node = _card_instance.get_parent()
	var pos: Vector2 = _card_instance.global_position
	if is_instance_valid(parent):
		parent.remove_child(_card_instance)
	_preview.add_child(_card_instance)
	_card_instance.position = Vector2.ZERO
	_card_instance.reset_physics_interpolation()
	
	card_instance_added.emit(card_instance)
	return true

func get_card_instance() -> CardInstance:
	return _card_instance

func has_card_instance() -> bool:
	return is_instance_valid(_card_instance)

func remove_card_instance() -> bool:
	if !is_instance_valid(_card_instance):
		return false
	
	var card_instance: CardInstance = _card_instance
	
	_preview.remove_child(_card_instance)
	
	_card_instance = null
	_dirty = true
	
	card_instance_removed.emit(card_instance)
	return true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_preview.visible = false
	_button.pressed.connect(press_started.emit)
	_button.mouse_entered.connect(func() -> void: _input_mouse_hover_unblocked = true)
	_button.mouse_exited.connect(func() -> void: _input_mouse_hover_unblocked = false)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_mouse_hover = get_global_rect().has_point(get_global_mouse_position())

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _input_mouse_hover:
		if !_hover:
			_hover = true
			hover_started.emit()
	else:
		if _hover:
			_hover = false
			hover_stopped.emit()
	
	if _input_mouse_hover_unblocked && has_card_instance():
		_preview.visible = true
	else:
		_preview.visible = false

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
	
