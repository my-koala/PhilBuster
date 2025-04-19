@tool
extends Control
class_name Session

# problem: discarding of cards after read

signal session_finished(success: bool)

signal gameover()

const CARD_INSTANCE_SCENE: PackedScene = preload("res://assets/card/card_instance.tscn")

const HAND_COUNT_MAX: int = 7

const TIME_WORD: int = 1

@export_range(0.0, 1.0, 0.001)
var deck_deal_cooldown: float = 0.125:
	get:
		return deck_deal_cooldown
	set(value):
		deck_deal_cooldown = clampf(value, 0.0, 1.0)

@export
var bust_word: int = 1
@export
var bust_field_empty: int = 10
@export
var bust_field_neutral: int = 1
@export
var bust_field_relevant: int = 5
@export
var bust_field_irrelevant: int = 5

var _deck_deal_cooldown: float = 0.0

@onready
var _sentence_container: SentenceContainer = %sentence_container as SentenceContainer
@onready
var _hand_container: Container = %hand_container as Container
@onready
var _hand_container_cards: HandContainer = %hand_container/cards as HandContainer
@onready
var _hand_container_highlight: Highlight = %hand_container/highlight as Highlight
@onready
var _bust_meter: BustMeter = %bust_meter as BustMeter
@onready
var _drag: Control = %drag as Control
@onready
var _drag_overlay: ColorRect = %drag_overlay as ColorRect
@onready
var _session_speak: SessionSpeak = %session_speak as SessionSpeak
@onready
var _session_discard: SessionDiscard = %session_discard as SessionDiscard
@onready
var _clock: Clock = %clock as Clock
@onready
var _phil: Phil = %phil as Phil
@onready
var _game_over: GameOver = %game_over as GameOver
@onready
var _audio_discard: AudioStreamPlayer = $audio/discard as AudioStreamPlayer
@onready
var _audio_deal: AudioStreamPlayer = $audio/deal as AudioStreamPlayer
@onready
var _label_session: Label= %label_session as Label

var _deck_card_instances: Array[CardInstance] = []
var _hand_card_instances: Array[CardInstance] = []
var _hand_card_instances_fields: Array[CardInstance] = []

var _game_stats: GameStats = null

var _session_active: bool = false

func is_session_active() -> bool:
	return _session_active

# TODO: session customizations?
# time = number of minutes. each word will generally be worth 1 minute
func start_session(game_stats: GameStats) -> void:
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
	
	_bust_meter.bust_max = game_stats.get_session_bust_max()
	_bust_meter.clear_bust()
	
	_clock.time_passed = 0
	_clock.time_region_start = 0
	_clock.time_region_duration = game_stats.get_session_time_max()
	
	_session_discard.set_discard_count(_game_stats.get_discard_count())
	
	#_topic_loader.set_topic(topic)
	# temporary
	_sentence_container.set_sentence(_game_stats.topic_get_sentence())
	_sentence_container.set_bubble_thought(true)
	_game_over.stop()
	
	_label_session.text = "Session #%d\nBill Topic: %s" % [_game_stats.get_session(), _game_stats.topic_get_name()]
	
	_session_speak.enabled = true
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
	
	_session_speak.enabled = false
	
	_game_over.stop()
	session_finished.emit(success)
	
	_game_stats.reset_discard_count()
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
			_hand_container_cards.add_child(card_instance)
			_audio_deal.play()

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
	
	_session_speak.submitted.connect(_on_session_speak_submitted)
	
	_game_over.return_to_menu.connect(stop_session.bind(false))
	
	_hand_container_highlight.highlight_started.connect(func() -> void: _hand_container.z_index = 8)
	_hand_container_highlight.highlight_stopped.connect(func() -> void: _hand_container.z_index = 0)

var _submitted: bool = false

func _on_session_speak_submitted() -> void:
	# TODO: once sentence container is animated, start immediately and then check if is reading
	# remove _submitted bool
	if _submitted:
		return
	_submitted = true
	
	_sentence_container.set_immutable(true)
	
	_session_speak.enabled = false
	_session_discard.enabled = false
	for card_instance: CardInstance in _hand_card_instances:
		card_instance.can_drag = false
	
	_phil.play_animation_stand()
	# TEMP: give enough time for phil to stand up
	# TODO: move startup/stopping animations to sentence_container
	# will animate background dimming, thought bubble changing, etc.
	await get_tree().create_timer(1.0).timeout
	_sentence_container.read_sentence()
	_sentence_container.set_bubble_thought(false)
	_submitted = false

func _on_sentence_container_read_started() -> void:
	pass
	# will move the above submit_submitted code here eventually
	# once sentence_container has animation stuff for start/stop

func _on_sentence_container_read_stopped() -> void:
	await get_tree().create_timer(0.5).timeout
	_phil.play_animation_sit()
	
	_session_speak.enabled = true
	_session_discard.enabled = true
	for card_instance: CardInstance in _hand_card_instances:
		card_instance.can_drag = true
	
	# NOTE: CardInstances not in the tree are "inside" the fields.
	# TODO: Find a better of doing this? Adding to an array perhaps.
	for card_instance: CardInstance in _hand_card_instances_fields:
		_deck_card_instances.append(card_instance)
		_hand_card_instances.erase(card_instance)
	_hand_card_instances_fields.clear()
	
	if _bust_meter.is_full():
		_phil.play_animation_bust()
		gameover.emit()
		await get_tree().create_timer(1.0).timeout
		_game_over.set_data(_game_stats.get_session(), _game_stats.get_money(), 69, 420, 1337)
		_game_over.start()
		return
	
	if _clock.is_time_exceeded():
		await get_tree().create_timer(1.0).timeout
		stop_session(true)
		return
	
	# Clear and generate next sentence
	_sentence_container.clear_sentence()
	_sentence_container.set_sentence(_game_stats.topic_get_sentence())
	_sentence_container.set_bubble_thought(true)
	
	_sentence_container.set_immutable(false)

var _card_info_modifier_stack: Array[CardInfoModifier] = []

func _on_sentence_container_read_word() -> void:
	_phil.play_animation_speak()
	_bust_meter.add_bust(bust_word)
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
		
		if _game_stats.topic_is_word_relevant(card_info.get_word()):
			_bust_meter.remove_bust(bust_field_relevant * bust_multiplier)
			_phil.play_animation_nice()
		elif _game_stats.topic_is_word_irrelevant(card_info.get_word()):
			time_multiplier = 0.0
			reward_multiplier = 0.0
			_bust_meter.add_bust(bust_field_irrelevant * bust_multiplier)
			_phil.play_animation_goof()
		else:
			_bust_meter.add_bust(bust_field_neutral * bust_multiplier)
		
		_clock.add_time(card_info_basic.time * time_multiplier)
		_game_stats.money_add(card_info_basic.reward * reward_multiplier)
	elif is_instance_valid(card_info):
		_clock.add_time(card_info.time)
	else:
		_bust_meter.add_bust(bust_field_empty)
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
		_hand_container_cards.remove_child(card_instance)
	_drag.add_child(card_instance)
	card_instance.global_position = card_instance.get_global_mouse_position()
	card_instance.reset_physics_interpolation()
	
	# TODO: Highlight fields accessible to card instance.
	_hand_container_highlight.enabled = true
	if _game_stats.get_discard_count() > 0:
		_session_discard.get_highlight().enabled = true
	if card_instance.card_info is CardInfoBasicNoun:
		_sentence_container.highlight_fields(SentenceContainerField.CardType.NOUN)
	if card_instance.card_info is CardInfoBasicVerb:
		_sentence_container.highlight_fields(SentenceContainerField.CardType.VERB)
	if card_instance.card_info is CardInfoModifierAdjective:
		_sentence_container.highlight_fields(SentenceContainerField.CardType.NOUN)
	if card_instance.card_info is CardInfoModifierAdverb:
		_sentence_container.highlight_fields(SentenceContainerField.CardType.VERB)

func _on_card_instance_drag_stopped(card_instance: CardInstance) -> void:
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var global_mouse_position: Vector2 = get_global_mouse_position()
	
	_drag.remove_child(card_instance)
	
	# First try discard, then try fields, then fallback to hand container.
	if _session_discard.get_global_rect().has_point(global_mouse_position) && (_game_stats.get_discard_count() > 0):
		_game_stats.discard_count_decrement()
		_session_discard.set_discard_count(_game_stats.get_discard_count())
		_deck_card_instances.append(card_instance)
		_hand_card_instances.erase(card_instance)
		_hand_card_instances_fields.erase(card_instance)
		_audio_discard.play()
	elif _sentence_container.try_insert_card_info(card_instance.card_info, global_mouse_position):
		_hand_card_instances_fields.append(card_instance)
	else:
		# Return to hand.
		_hand_container_cards.add_child(card_instance)
		card_instance.reset_physics_interpolation()
	
	# TODO: Highlight fields accessible to card instance.
	_hand_container_highlight.enabled = false
	_session_discard.get_highlight().enabled = false
	_sentence_container.highlight_fields(SentenceContainerField.CardType.NONE)

func _exit_tree() -> void:
	_sentence_container.clear_sentence()
	
	for card_instance: CardInstance in _deck_card_instances:
		card_instance.queue_free()
	_deck_card_instances.clear()
	
	for card_instance: CardInstance in _hand_card_instances:
		card_instance.queue_free()
	_hand_card_instances.clear()
