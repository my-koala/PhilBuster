@tool
extends Control
class_name CardInstance

signal drag_started()
signal drag_stopped()

@export
var can_drag: bool = true

@export
var color_noun: Color = Color.ORANGE_RED:
	get:
		return color_noun
	set(value):
		if color_noun != value:
			color_noun = value
			_dirty = true

@export
var color_verb: Color = Color.BLUE_VIOLET:
	get:
		return color_verb
	set(value):
		if color_verb != value:
			color_verb = value
			_dirty = true

@export
var color_adjective: Color = Color.YELLOW:
	get:
		return color_adjective
	set(value):
		if color_adjective != value:
			color_adjective = value
			_dirty = true

@export
var color_adverb: Color = Color.VIOLET:
	get:
		return color_adverb
	set(value):
		if color_adverb != value:
			color_adverb = value
			_dirty = true

var card_info: CardInfo = null:
	get:
		return card_info
	set(value):
		if card_info != value:
			card_info = value
			_dirty = true

@export
var drag_offset: Vector2 = Vector2.ZERO

@onready
var _label_word: Label = %label_word as Label
@onready
var _label_speech: Label = %label_speech as Label
@onready
var _border_img: CanvasItem = %border as CanvasItem
@onready
var _audio_card_pickup: AudioStreamPlayer = $audio/card_pickup as AudioStreamPlayer
@onready
var _audio_card_drop: AudioStreamPlayer = $audio/card_drop as AudioStreamPlayer
@onready
var _button: Button = %button as Button
@onready
var _animation_player: AnimationPlayer = $animation_player as AnimationPlayer
@onready
var _container_stats_reward_label: Label = %container_stats/reward/label as Label
@onready
var _container_stats_time_label: Label = %container_stats/time/label as Label
@onready
var _container_stats_bust_label: Label = %container_stats/bust/label as Label

var _dirty: bool = true

var _drag: bool = false

var _input_mouse_pressed: bool = false

func start_drag() -> void:
	if can_drag && !_drag:
		_drag = true
		_audio_card_pickup.play()
		drag_started.emit()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_animation_player.play(&"card_instance/normal")

func _update_display() -> void:
	if is_instance_valid(card_info):
		_label_word.text = card_info.get_word().to_upper()
		if _label_word.text.is_empty():
			_label_word.text = "<Word>"
		
		var card_info_basic: CardInfoBasic = card_info as CardInfoBasic
		if is_instance_valid(card_info_basic):
			_container_stats_reward_label.text = str(card_info_basic.reward)
			_container_stats_time_label.text = str(card_info_basic.time)
			_container_stats_bust_label.visible = false
			if card_info is CardInfoBasicNoun:
				_label_speech.text = "(Noun)"
				_border_img.modulate = color_noun
			elif card_info is CardInfoBasicVerb:
				_label_speech.text = "(Verb)"
				_border_img.modulate = color_verb
		
		var card_info_modifier: CardInfoModifier = card_info as CardInfoModifier
		if is_instance_valid(card_info_modifier):
			_container_stats_reward_label.text = str("%.1fx" % [card_info_modifier.reward_multiplier])
			_container_stats_time_label.text = str("%.1fx" % [card_info_modifier.time_multiplier])
			_container_stats_bust_label.text = str("%.1fx" % [card_info_modifier.bust_multiplier])
			_container_stats_bust_label.visible = true
			if card_info is CardInfoModifierAdjective:
				_label_speech.text = "(Adjective)"
				_border_img.modulate = color_adjective
			elif card_info is CardInfoModifierAdverb:
				_label_speech.text = "(Adverb)"
				_border_img.modulate = color_adverb
	else:
		_label_word.text = "<Word>"
		_border_img.modulate = Color.GRAY
	
	# TODO: Resize label font size to fit.
	

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() || !can_drag:
		return
	
	var mouse_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if !_drag && _button.button_pressed:
		_drag = true
		_audio_card_pickup.play()
		drag_started.emit()
	if !can_drag || !mouse_pressed:
		if _drag:
			_drag = false
			_audio_card_drop.play()
			drag_stopped.emit()
	
	if can_drag:
		_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	if _drag:
		_animation_player.play(&"card_instance/drag")
	elif _button.is_hovered():
		_animation_player.play(&"card_instance/hover")
	else:
		_animation_player.play(&"card_instance/normal")
	
	if _drag:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
		global_position = get_global_mouse_position() - drag_offset
	else:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	

func _process(delta: float) -> void:
	if _dirty:
		_update_display()
		_dirty = false
