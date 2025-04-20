extends Panel
class_name WordList

const GAME_BUTTON: PackedScene = preload("res://assets/game_button/game_button.tscn")

signal list_changed()
signal on_word_hovered(card: CardInfo, hovered: bool)

@export
var label: Label

@export
var container: Container

var _game_stats: GameStats
var _cards: Array[CardInfo]

func init(name: String, cards: Array[CardInfo], game_stats: GameStats) -> void:
	label.text = name
	_game_stats = game_stats
	_cards = cards
	
	for child: Node in container.get_children():
		child.queue_free()
	
	#for card: CardInfo in cards:
	for i: int in range(cards.size()):
		var card: CardInfo = cards[i]
		var button: GameButton = GAME_BUTTON.instantiate() as GameButton
		button.toggle_mode = true
		button.text = card.get_word()
		button.set_pressed_no_signal(game_stats.deck_has(card))
		button.toggled.connect(func(toggled: bool) -> void: _on_card_button_toggled(button, card, toggled))
		button.mouse_entered.connect(func() -> void: on_word_hovered.emit(card, true))
		button.mouse_exited.connect(func() -> void: on_word_hovered.emit(card, false))
		container.add_child(button)
	
func _on_card_button_toggled(button: Button, card: CardInfo, toggled: bool) -> void:
	
	if toggled:
		if !_game_stats.deck_append(card):
			button.set_pressed_no_signal(false)
		else:
			list_changed.emit()
	else:
		if !_game_stats.deck_remove(card):
			button.set_pressed_no_signal(true)
		else:
			list_changed.emit()
