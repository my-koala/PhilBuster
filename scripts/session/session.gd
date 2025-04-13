@tool
extends Control
class_name Session

const CARD_INSTANCE_SCENE: PackedScene = preload("res://assets/card/card_instance.tscn")

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

var _hand_basic_card_instances: Array[CardInstance] = []
var _hand_modifier_card_instances: Array[CardInstance] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_sentence_container.field_press_started.connect(_on_sentence_container_field_press_started)
	
	var card_infos: Array[CardInfo] = [
		load("res://assets/card/info/basic/noun/tariff.tres") as CardInfo,
		load("res://assets/card/info/basic/verb/cut.tres") as CardInfo,
		load("res://assets/card/info/modifier/adjective/great.tres") as CardInfo,
		load("res://assets/card/info/modifier/adverb/greatly.tres") as CardInfo,
	]
	
	for card_info: CardInfo in card_infos:
		var card_instance: CardInstance = CARD_INSTANCE_SCENE.instantiate() as CardInstance
		_hand_container.add_child(card_instance)
		card_instance.card_info = card_info
		card_instance.drag_started.connect(_on_card_instance_drag_started.bind(card_instance))
		card_instance.drag_stopped.connect(_on_card_instance_drag_stopped.bind(card_instance))
		_hand_basic_card_instances.append(card_instance)
	
	_sentence_container.clear_sentence()
	_sentence_container.set_sentence("The Koala {v} the {n} in a cute manner.")
	
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

var _card_instance_drag: CardInstance = null

func _on_sentence_container_field_press_started(sentence_container_field: SentenceContainerField) -> void:
	assert(!is_instance_valid(_card_instance_drag))
	if sentence_container_field.has_card_instance():
		var card_instance: CardInstance = sentence_container_field.get_card_instance()
		sentence_container_field.remove_card_instance()
		card_instance.start_drag()

func _on_card_instance_drag_started(card_instance: CardInstance) -> void:
	assert(!is_instance_valid(_card_instance_drag))
	
	_card_instance_drag = card_instance
	
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
	assert(is_instance_valid(_card_instance_drag))
	assert(_card_instance_drag == card_instance)
	
	_card_instance_drag = null
	
	_drag_overlay.visible = false
	_drag_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for sentence_container_field: SentenceContainerField in _sentence_container.get_fields():
		pass# Clear highlights and dims.
	
	# TODO:
	# check for field that's hovered, and try add.
	# if fail, fallback to hand container
	var success: bool = false
	var sentence_container_field: SentenceContainerField = _sentence_container.get_focused_field()
	if is_instance_valid(sentence_container_field):
		if sentence_container_field.add_card_instance(card_instance):
			success = true
		elif _sentence_container.add_field_modifier(sentence_container_field, card_instance):
			success = true
	
	if !success:
		card_instance.reparent(_hand_container)
		card_instance.reset_physics_interpolation()
