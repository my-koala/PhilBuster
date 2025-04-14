@tool
extends Control
class_name Session

#const SENTENCE_LOADER: SentenceLoader = preload("res://assets/sentences/sentence_loader.tres") as SentenceLoader

const HAND_COUNT_MAX: int = 8

@export_range(0.0, 1.0, 0.001)
var deck_deal_cooldown: float = 0.125:
	get:
		return deck_deal_cooldown
	set(value):
		deck_deal_cooldown = clampf(value, 0.0, 1.0)

var _deck_deal_cooldown: float = 0.0

@onready
var _sentence_container: SentenceContainer = %sentence_container as SentenceContainer
@onready
var _hand_container: HandContainer = %hand_container as HandContainer
@onready
var _bust_meter: BustMeter = %bust_meter as BustMeter
@onready
var _drag: Control = %drag as Control
@onready
var _drag_overlay: ColorRect = %drag_overlay as ColorRect
@onready
var _discard: Control = %discard as Control
@onready
var _discard_highlight: Highlight = %discard/highlight as Highlight
@onready
var _session_submit: SessionSubmit = %session_submit as SessionSubmit
@onready
var _clock: Clock = %clock as Clock

var _hand_card_instances: Array[CardInstance] = []

var _game_stats: GameStats = null

var _session_active: bool = false

func is_session_active() -> bool:
	return _session_active

# TODO: session customizations?
# time = number of minutes. each word will generally be worth 1 tick
func start_session(game_stats: GameStats, topic: String = "", time: int = 120, bust_max: int = 32, sentence_difficulty: int = 0) -> void:
	if _session_active:
		return
	_session_active = true
	
	_game_stats = game_stats
	_game_stats.deck_shuffle()
	
	_bust_meter.bust_max = bust_max
	_bust_meter.clear_bust()
	
	_clock.time_region_start = 0
	_clock.time_region_duration = time
	
	_session_submit.enabled = false

func stop_session() -> void:
	if !_session_active:
		return
	_session_active = false
	
	for card_instance: CardInstance in _hand_card_instances:
		_game_stats.deck_append(card_instance)
	
	while !_hand_card_instances.is_empty():
		_discard_card_instance_from_hand(_hand_card_instances[0])
	
	_game_stats = null

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _session_active:
		# Deal hand if insufficient number of cards.
		if _deck_deal_cooldown > 0.0:
			_deck_deal_cooldown -= delta
		elif !_game_stats.deck_is_empty() && (_hand_card_instances.size() < HAND_COUNT_MAX):
			_deck_deal_cooldown = deck_deal_cooldown
			
			_append_card_instance_to_hand(_game_stats.deck_deal())
		

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_sentence_container.field_press_started.connect(_on_sentence_container_field_press_started)
	
	_sentence_container.clear_sentence()
	_sentence_container.set_sentence("The Koala {v} the {n} in a cute manner.")
	
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_sentence_container_field_press_started(sentence_container_field: SentenceContainerField) -> void:
	if sentence_container_field.has_card_instance():
		var card_instance: CardInstance = sentence_container_field.get_card_instance()
		sentence_container_field.remove_card_instance()
		card_instance.start_drag()

func _on_card_instance_drag_started(card_instance: CardInstance) -> void:
	_drag_overlay.visible = true
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var parent: Node = card_instance.get_parent()
	if is_instance_valid(parent):
		parent.remove_child(card_instance)
	_drag.add_child(card_instance)
	card_instance.global_position = card_instance.get_global_mouse_position()
	card_instance.reset_physics_interpolation()
	
	for sentence_container_field: SentenceContainerField in _sentence_container.get_fields():
		if !sentence_container_field.has_card_instance() && sentence_container_field.check_card_type(card_instance):
			pass# Highlight field.
		else:
			pass# Dim field.

func _on_card_instance_drag_stopped(card_instance: CardInstance) -> void:
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var global_mouse_position: Vector2 = get_global_mouse_position()
	
	var sentence_container_field_focus: SentenceContainerField = null
	for sentence_container_field: SentenceContainerField in _sentence_container.get_fields():
		# Clear highlights and dims.
		if sentence_container_field.get_global_rect().has_point(global_mouse_position):
			sentence_container_field_focus = sentence_container_field
	
	_drag.remove_child(card_instance)
	
	# First try discard, then try fields, then fallback to hand container.
	var fallback: bool = true
	if _discard.get_global_rect().has_point(global_mouse_position):
		_discard_card_instance_from_hand(card_instance)
		_game_stats.deck_append(card_instance)
		fallback = false
	elif is_instance_valid(sentence_container_field_focus):
		if sentence_container_field_focus.add_card_instance(card_instance):
			fallback = false
		elif _sentence_container.add_field_modifier(sentence_container_field_focus, card_instance):
			fallback = false
	
	if fallback:
		# Return to hand.
		_hand_container.add_child(card_instance)
		card_instance.reset_physics_interpolation()

func _append_card_instance_to_hand(card_instance: CardInstance) -> void:
	if _hand_card_instances.has(card_instance):
		return
	
	card_instance.drag_started.connect(_on_card_instance_drag_started.bind(card_instance))
	card_instance.drag_stopped.connect(_on_card_instance_drag_stopped.bind(card_instance))
	
	var parent: Node = card_instance.get_parent()
	if is_instance_valid(parent):
		parent.remove_child(card_instance)
	_hand_container.add_child(card_instance)
	_hand_card_instances.append(card_instance)

func _discard_card_instance_from_hand(card_instance: CardInstance) -> void:
	if !_hand_card_instances.has(card_instance):
		return
	
	card_instance.drag_started.disconnect(_on_card_instance_drag_started)
	card_instance.drag_stopped.disconnect(_on_card_instance_drag_stopped)
	
	var parent: Node = card_instance.get_parent()
	if is_instance_valid(parent):
		parent.remove_child(card_instance)
	_hand_card_instances.erase(card_instance)
