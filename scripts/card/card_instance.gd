@tool
extends Control
class_name CardInstance

# TODO: Texture swap based on card type.
# TODO: Animations on select, mouse hover, deselect.

signal select_started()
signal select_stopped()

var card_info: CardInfo = null:
	get:
		return card_info
	set(value):
		if card_info != value:
			card_info = value
			_update_display()

@export
var selectable: bool = true:
	get:
		return selectable
	set(value):
		selectable = value
		if !selectable && _selected:
			deselect()

@onready
var _label: Label = %label as Label
@onready
var _color_rect: ColorRect = %color_rect as ColorRect
@onready
var _pickable: Control = %pickable as Control

var _input_mouse_hovering: bool = false

var _selected: bool = false

func is_selected() -> bool:
	return _selected

func select() -> void:
	if selectable && !_selected:
		_selected = true
		select_started.emit()

func deselect() -> void:
	if _selected:
		_selected = false
		select_stopped.emit()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_pickable.mouse_entered.connect(func() -> void: _input_mouse_hovering = true)
	_pickable.mouse_exited.connect(func() -> void: _input_mouse_hovering = false)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed(&"mouse_left") && _input_mouse_hovering:
		if !_selected:
			select()
		else:
			deselect()

func _update_display() -> void:
	if is_instance_valid(card_info):
		_label.text = card_info.word
		
		if card_info is CardInfoBasicNoun:
			_color_rect.color = Color.RED
		elif card_info is CardInfoBasicVerb:
			_color_rect.color = Color.BLUE
		elif card_info is CardInfoModifierAdjective:
			_color_rect.color = Color.ORANGE_RED
		elif card_info is CardInfoModifierAdverb:
			_color_rect.color = Color.BLUE_VIOLET
	else:
		_label.text = "N/A"
		_color_rect.color = Color.GRAY

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _input_mouse_hovering:
		pass
	else:
		pass
	
	if _selected:
		pass
	else:
		pass
