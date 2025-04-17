@tool
extends Control
class_name Session

# problem: discarding of cards after read

signal session_finished(success: bool)

const CARD_INSTANCE_SCENE: PackedScene = preload("res://assets/card/card_instance.tscn")

const HAND_COUNT_MAX: int = 8

const FIELD_BUST_RELEVANT: int = 1
const FIELD_BUST_NEUTRAL: int = 0
const FIELD_BUST_IRRELEVANT: int = 3
const FIELD_BUST_EMPTY: int = 5

const TIME_WORD: int = 1

@export_range(0.0, 1.0, 0.001)
var deck_deal_cooldown: float = 0.125:
	get:
		return deck_deal_cooldown
	set(value):
		deck_deal_cooldown = clampf(value, 0.0, 1.0)

var _deck_deal_cooldown: float = 0.0

@onready
var _topic_loader: TopicLoader = %topic_loader as TopicLoader
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
@onready
var _phil: Phil = %phil as Phil

var _deck_card_instances: Array[CardInstance] = []
var _hand_card_instances: Array[CardInstance] = []
var _hand_card_instances_fields: Array[CardInstance] = []

var _game_stats: GameStats = null

var _session_active: bool = false

func is_session_active() -> bool:
	return _session_active

# TODO: session customizations?
# time = number of minutes. each word will generally be worth 1 minute
func start_session(game_stats: GameStats, topic: String = "", time: int = 120, bust_max: int = 32, sentence_difficulty: int = 0) -> void:
	if _session_active:
		return
	_session_active = true
	
	_game_stats = game_stats
	
	for card_info: CardInfo in _game_stats.get_deck():
		var card_instance: CardInstance = CARD_INSTANCE_SCENE.instantiate()
		card_instance.drag_started.connect(_on_card_instance_drag_started.bind(card_instance))
		card_instance.drag_stopped.connect(_on_card_instance_drag_stopped.bind(card_instance))
		card_instance.card_info = card_info
		_deck_card_instances.append(card_instance)
	
	_deck_card_instances.shuffle()
	
	_bust_meter.bust_max = bust_max
	_bust_meter.clear_bust()
	
	_clock.time_passed = 0
	_clock.time_region_start = 0
	_clock.time_region_duration = time
	
	#_topic_loader.set_topic(topic)
	# temporary
	_topic_loader.set_topic(_topic_loader.get_topic_names()[0])
	_sentence_container.set_sentence(_topic_loader.get_topic_sentence())
	
	_session_submit.enabled = true
	_phil.play_animation_sit()

func stop_session(success: bool) -> void:
	if !_session_active:
		return
	_session_active = false
	
	_sentence_container.clear_sentence()
	
	for card_instance: CardInstance in _deck_card_instances:
		card_instance.queue_free()
	_deck_card_instances.clear()
	
	for card_instance: CardInstance in _hand_card_instances:
		card_instance.queue_free()
	_hand_card_instances.clear()
	
	_session_submit.enabled = false
	
	session_finished.emit(success)
	
	_game_stats = null

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _session_active:
		# Deal hand if insufficient number of cards.
		if _deck_deal_cooldown > 0.0:
			_deck_deal_cooldown -= delta
		elif !_deck_card_instances.is_empty() && (_hand_card_instances.size() < HAND_COUNT_MAX):
			_deck_deal_cooldown = deck_deal_cooldown
			var card_instance: CardInstance = _deck_card_instances[0]
			_deck_card_instances.pop_front()
			_hand_card_instances.append(card_instance)
			_hand_container.add_child(card_instance)

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_sentence_container.read_started.connect(_on_sentence_container_read_started)
	_sentence_container.read_word.connect(_on_sentence_container_read_word)
	_sentence_container.read_field.connect(_on_sentence_container_read_field)
	_sentence_container.read_stopped.connect(_on_sentence_container_read_stopped)
	
	_sentence_container.card_info_removed.connect(_on_sentence_container_card_info_removed)
	
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_session_submit.submitted.connect(_on_session_submit_submitted)

var _submitted: bool = false

func _on_session_submit_submitted() -> void:
	# TODO: once sentence container is animated, start immediately and then check if is reading
	# remove _submitted bool
	if _submitted:
		return
	_submitted = true
	
	_session_submit.enabled = false
	for card_instance: CardInstance in _hand_card_instances:
		card_instance.disabled = true
	
	_phil.play_animation_stand()
	# TEMP: give enough time for phil to stand up
	# TODO: move startup/stopping animations to sentence_container
	# will animate background dimming, thought bubble changing, etc.
	await get_tree().create_timer(1.0).timeout
	_sentence_container.read_sentence()
	_submitted = false

func _on_sentence_container_read_started() -> void:
	pass
	# will move the above submit_submitted code here eventually
	# once sentence_container has animation stuff for start/stop

func _on_sentence_container_read_stopped() -> void:
	await get_tree().create_timer(0.5).timeout
	_phil.play_animation_sit()
	
	_session_submit.enabled = true
	for card_instance: CardInstance in _deck_card_instances:
		card_instance.disabled = false
	for card_instance: CardInstance in _hand_card_instances:
		card_instance.disabled = false
	
	# NOTE: CardInstances not in the tree are "inside" the fields.
	# TODO: Find a better of doing this? Adding to an array perhaps.
	for card_instance: CardInstance in _hand_card_instances_fields:
		_deck_card_instances.append(card_instance)
		_hand_card_instances.erase(card_instance)
	_hand_card_instances_fields.clear()
	
	if _bust_meter.is_full():
		_phil.play_animation_bust()
		await get_tree().create_timer(1.0).timeout
		stop_session(false)
		return
	
	if _clock.is_time_exceeded():
		stop_session(true)
		await get_tree().create_timer(1.0).timeout
		return
	
	# Clear and generate next sentence
	_sentence_container.clear_sentence()
	_sentence_container.set_sentence(_topic_loader.get_topic_sentence())

var _card_info_modifier_stack: Array[CardInfoModifier] = []

func _on_sentence_container_read_word() -> void:
	_phil.play_animation_speak()
	_clock.add_time(TIME_WORD)

func _on_sentence_container_read_field(card_info: CardInfo) -> void:
	_phil.play_animation_speak()
	var card_info_basic: CardInfoBasic = card_info as CardInfoBasic
	if is_instance_valid(card_info_basic):
		var time_multiplier: float = 1.0
		var reward_multiplier: float = 1.0
		var bust_multiplier: float = 1.0
		
		for card_info_modifier: CardInfoModifier in _card_info_modifier_stack:
			time_multiplier *= card_info_modifier.time_multiplier
			reward_multiplier *= card_info_modifier.reward_multiplier
			bust_multiplier *= card_info_modifier.bust_multiplier
		
		if _topic_loader.is_word_relevant(card_info.get_word()):
			_bust_meter.remove_bust(FIELD_BUST_RELEVANT * bust_multiplier)
			_phil.play_animation_nice()
		elif _topic_loader.is_word_irrelevant(card_info.get_word()):
			time_multiplier = 0.0
			reward_multiplier = 0.0
			_bust_meter.add_bust(FIELD_BUST_IRRELEVANT * bust_multiplier)
			_phil.play_animation_goof()
		else:
			_bust_meter.add_bust(FIELD_BUST_NEUTRAL * bust_multiplier)
		
		_clock.add_time(card_info_basic.time * time_multiplier)
		_game_stats.money_add(card_info_basic.reward * reward_multiplier)
	elif is_instance_valid(card_info):
		_clock.add_time(card_info.time)
	else:
		_bust_meter.add_bust(FIELD_BUST_EMPTY)
		_phil.play_animation_goof()

func _on_sentence_container_card_info_removed(card_info: CardInfo) -> void:
	for card_instance: CardInstance in _hand_card_instances_fields:
		if card_instance.card_info == card_info:
			card_instance.start_drag()
			_hand_card_instances_fields.erase(card_instance)
			break

func _on_card_instance_drag_started(card_instance: CardInstance) -> void:
	_drag_overlay.visible = true
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if card_instance.is_inside_tree():
		_hand_container.remove_child(card_instance)
	_drag.add_child(card_instance)
	card_instance.global_position = card_instance.get_global_mouse_position()
	card_instance.reset_physics_interpolation()
	
	# TODO: Highlight fields accessible to card instance.

func _on_card_instance_drag_stopped(card_instance: CardInstance) -> void:
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var global_mouse_position: Vector2 = get_global_mouse_position()
	
	_drag.remove_child(card_instance)
	
	# First try discard, then try fields, then fallback to hand container.
	if _discard.get_global_rect().has_point(global_mouse_position):
		_deck_card_instances.append(card_instance)
		_hand_card_instances.erase(card_instance)
		_hand_card_instances_fields.erase(card_instance)
	elif _sentence_container.try_insert_card_info(card_instance.card_info, global_mouse_position):
		_hand_card_instances_fields.append(card_instance)
	else:
		# Return to hand.
		_hand_container.add_child(card_instance)
		card_instance.reset_physics_interpolation()
	
	# TODO: Highlight fields accessible to card instance.

func _exit_tree() -> void:
	stop_session(false)
