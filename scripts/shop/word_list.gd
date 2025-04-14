extends Panel
class_name WordList

signal list_changed()

@onready
var label: Label = $label

@onready
var container: Container = $word_type/v_box_container

var _game_stats: GameStats
var _cards: Array[CardInfo]

const BUTTON: PackedScene = preload("res://assets/shop/word_list_button.tscn")

func init(name: String, cards: Array[CardInfo], game_stats: GameStats) -> void:
	label.text = name
	_game_stats = game_stats
	_cards = cards
	
	for child: Node in container.get_children():
		child.queue_free()
	
	#for card: CardInfo in cards:
	for i: int in range(cards.size()):
		var card: CardInfo = cards[i]
		var button: Button = BUTTON.instantiate() as Button
		button.text = card.get_word()
		button.set_pressed_no_signal(game_stats.deck_has(card))
		button.toggled.connect(func(toggled: bool) -> void: _on_card_button_toggled(button, i, toggled))
		container.add_child(button)
	
func _on_card_button_toggled(button: Button, idx: int, toggled: bool) -> void:
	var card: CardInfo = _cards[idx]
	
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
