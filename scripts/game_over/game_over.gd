@tool
extends Control
class_name GameOver

signal return_to_menu()

@onready
var _container_session_label_data: Label = %container_session/label_data as Label
@onready
var _container_money_label_data: Label = %container_money/label_data as Label
@onready
var _container_time_label_data: Label = %container_time/label_data as Label
@onready
var _container_bust_label_data: Label = %container_bust/label_data as Label
@onready
var _container_cards_label_data: Label = %container_cards/label_data as Label
@onready
var _button: Button = %button as Button

@onready
var _animation_player: AnimationPlayer = $animation_player as AnimationPlayer

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_button.pressed.connect(return_to_menu.emit)

func set_data(session: int, money: int, time: int, bust: int, cards: int) -> void:
	_container_session_label_data.text = str(session)
	_container_money_label_data.text = str(money)
	_container_time_label_data.text = str(time)
	_container_bust_label_data.text = str(bust)
	_container_cards_label_data.text = str(cards)

func start() -> void:
	_animation_player.play(&"start")

func stop() -> void:
	_animation_player.play(&"stop")
