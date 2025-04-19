@tool
extends Control
class_name CardInstance

signal hover_started()
signal hover_stopped()
signal drag_started()
signal drag_stopped()

@export
var can_drag: bool = true

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
var _corner: ColorRect = %corner as ColorRect
@onready
var _audio_card_pickup: AudioStreamPlayer = $audio/card_pickup as AudioStreamPlayer
@onready
var _audio_card_drop: AudioStreamPlayer = $audio/card_drop as AudioStreamPlayer
@onready
var _audio_card_hover: AudioStreamPlayer = $audio/card_hover as AudioStreamPlayer
@onready
var _button: Button = %button as Button
@onready
var _animation_player: AnimationPlayer = $animation_player as AnimationPlayer
@onready
var _container_stats_reward: Control = %container_stats/reward as Control
@onready
var _container_stats_reward_label: Label = %container_stats/reward/label as Label
@onready
var _container_stats_time: Control = %container_stats/time as Control
@onready
var _container_stats_time_label: Label = %container_stats/time/label as Label
@onready
var _container_stats_bust: Control = %container_stats/bust as Control
@onready
var _container_stats_bust_label: Label = %container_stats/bust/label as Label

var _dirty: bool = true

var _drag: bool = false

var _input_mouse_pressed: bool = false
var _input_mouse_hover: bool = false

func start_drag() -> void:
	if can_drag && !_drag:
		_drag = true
		drag_started.emit()
		_audio_card_pickup.play()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_button.mouse_entered.connect(_on_button_mouse_entered)
	_button.mouse_exited.connect(_on_button_mouse_exited)
	
	_animation_player.play(&"card_instance/normal")

var _hover: bool = false

func _on_button_mouse_entered() -> void:
	if _drag:
		return
	if _hover:
		return
	_hover = true
	hover_started.emit()

func _on_button_mouse_exited() -> void:
	if _drag:
		return
	if !_hover:
		return
	_hover = false
	hover_stopped.emit()

func _update_display() -> void:
	if is_instance_valid(card_info):
		_label_word.text = card_info.get_word().to_upper()
		if _label_word.text.is_empty():
			_label_word.text = "<Word>"
		
		var card_info_basic: CardInfoBasic = card_info as CardInfoBasic
		if is_instance_valid(card_info_basic):
			_container_stats_reward_label.text = str(card_info_basic.reward)
			_container_stats_time_label.text = str(card_info_basic.time)
			_container_stats_bust.visible = false
			if card_info is CardInfoBasicNoun:
				_corner.color = CardInfoBasicNoun.get_color()
				_label_speech.text = "(Noun)"
			elif card_info is CardInfoBasicVerb:
				_corner.color = CardInfoBasicVerb.get_color()
				_label_speech.text = "(Verb)"
		
		var card_info_modifier: CardInfoModifier = card_info as CardInfoModifier
		if is_instance_valid(card_info_modifier):
			_container_stats_reward_label.text = str("%.1fx" % [card_info_modifier.reward_multiplier])
			_container_stats_time_label.text = str("%.1fx" % [card_info_modifier.time_multiplier])
			_container_stats_bust_label.text = str("%.1fx" % [card_info_modifier.bust_multiplier])
			_container_stats_bust.visible = true
			if card_info is CardInfoModifierAdjective:
				_corner.color = CardInfoModifierAdjective.get_color()
				_label_speech.text = "(Adjective)"
			elif card_info is CardInfoModifierAdverb:
				_corner.color = CardInfoModifierAdverb.get_color()
				_label_speech.text = "(Adverb)"
	else:
		_label_word.text = "<Word>"
		_corner.color = Color.GRAY
	
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
		if _input_mouse_hover:
			_input_mouse_hover = false
			hover_stopped.emit()
		_animation_player.play(&"card_instance/drag")
	elif _button.is_hovered():
		if !_input_mouse_hover:
			_input_mouse_hover = true
			_animation_player.play(&"card_instance/hover")
			_audio_card_hover.play()
	else:
		if _input_mouse_hover:
			_input_mouse_hover = false
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
