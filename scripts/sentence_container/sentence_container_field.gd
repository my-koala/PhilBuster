@tool
extends Control
class_name SentenceContainerField

# NOTE:
# can't use mouse_entered/exited for hover detection (since card is dragging over)

signal press_started()
signal press_stopped()

# TODO:
# Draw crawling ants border animation.

enum CardType {
	NONE,
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
			set_card_info(null)

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
@onready
var _card_instance: CardInstance = %card_instance as CardInstance

var _card_info: CardInfo = null

var _dirty: bool = false

var _input_mouse_hover: bool = false

func get_highlight() -> Highlight:
	return _highlight

static func get_card_type(card_info: CardInfo) -> CardType:
	if !is_instance_valid(card_info):
		return CardType.NONE
	
	if card_info is CardInfoBasicNoun:
		return CardType.NOUN
	if card_info is CardInfoBasicVerb:
		return CardType.VERB
	if card_info is CardInfoModifierAdjective:
		return CardType.ADJECTIVE
	if card_info is CardInfoModifierAdverb:
		return CardType.ADVERB
	return CardType.NONE

func check_card_type(card_info: CardInfo) -> bool:
	if !is_instance_valid(card_info):
		return false
	
	match card_type:
		CardType.NONE:
			return false
		CardType.NOUN:
			return card_info is CardInfoBasicNoun
		CardType.VERB:
			return card_info is CardInfoBasicVerb
		CardType.ADJECTIVE:
			return card_info is CardInfoModifierAdjective
		CardType.ADVERB:
			return card_info is CardInfoModifierAdverb
	return false

func check_card_type_modifier(card_info_modifier: CardInfoModifier) -> bool:
	if !is_instance_valid(card_info_modifier):
		return false
	
	match card_type:
		CardType.NOUN:
			return card_info_modifier is CardInfoModifierAdjective
		CardType.VERB:
			return card_info_modifier is CardInfoModifierAdverb
		CardType.ADJECTIVE:
			return card_info_modifier is CardInfoModifierAdjective
		CardType.ADVERB:
			return card_info_modifier is CardInfoModifierAdverb
	return false

func get_card_info() -> CardInfo:
	return _card_info

func set_card_info(card_info: CardInfo, forced: bool = false) -> bool:
	if _card_info == card_info:
		return true
	
	if is_instance_valid(card_info):
		if forced:
			card_type = get_card_type(card_info)
		elif !check_card_type(card_info):
			return false
	
	_card_info = card_info
	
	_dirty = true
	return true

func has_card_info() -> bool:
	return is_instance_valid(_card_info)

var _tween_read_animation: Tween = null

func play_read_animation() -> void:
	if is_instance_valid(_tween_read_animation):
		_tween_read_animation.custom_step(1000.0)
		_tween_read_animation.kill()
		_tween_read_animation = null
	_tween_read_animation = create_tween()
	
	_tween_read_animation.set_ease(Tween.EASE_OUT)
	_tween_read_animation.set_trans(Tween.TRANS_CUBIC)
	_tween_read_animation.tween_property(self, "position:y", position.y - 24.0, 0.1)
	_tween_read_animation.set_ease(Tween.EASE_IN)
	_tween_read_animation.set_trans(Tween.TRANS_CUBIC)
	_tween_read_animation.tween_property(self, "position:y", position.y, 0.1)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_preview.visible = false
	
	_button.button_down.connect(press_started.emit)
	_button.button_up.connect(press_stopped.emit)
	_button.mouse_entered.connect(func() -> void: _input_mouse_hover = true)
	_button.mouse_exited.connect(func() -> void: _input_mouse_hover = false)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _input_mouse_hover && is_instance_valid(_card_info):
		_preview.visible = true
	else:
		_preview.visible = false
	
	if !_dirty:
		return
	_dirty = false
	
	_card_instance.card_info = _card_info
	
	var placeholder_text: String = ""
	
	match card_type:
		CardType.NONE:
			_color_rect.color = CardInfo.get_color()
			placeholder_text = "none"
		CardType.NOUN:
			_color_rect.color = CardInfoBasicNoun.get_color()
			placeholder_text = "noun"
		CardType.VERB:
			_color_rect.color = CardInfoBasicVerb.get_color()
			placeholder_text = "verb"
		CardType.ADJECTIVE:
			_color_rect.color = CardInfoModifierAdjective.get_color()
			placeholder_text = "adjective"
		CardType.ADVERB:
			_color_rect.color = CardInfoModifierAdverb.get_color()
			placeholder_text = "adverb"
	
	if is_instance_valid(_card_info):
		_rich_text_label.text = "[b]%s[/b]" % [_card_info.get_word()]
	else:
		_rich_text_label.text = "([i]%s[i])" % [placeholder_text]
	
