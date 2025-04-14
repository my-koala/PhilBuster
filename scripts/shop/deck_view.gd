extends MenuView
class_name DeckView

@onready
var progress_bar: ProgressBar = $progress_bar

@onready
var progress_bar_label: Label = $progress_bar/label

@onready
var word_types_list: Control = $word_types

var _game: Game
var _session: Session
var _card_library : CardLibrary
var _game_stats : GameStats

const WORD_LIST: PackedScene = preload("res://assets/shop/word_list.tscn")

func _ready() -> void:
	_game = get_tree().current_scene as Game
	_session = get_tree().current_scene.find_child("session") as Session
	if is_instance_valid(_game):
		_card_library = _game.card_library
		_game_stats = _game.game_stats

	reset_lists()

func reset_lists() -> void:
	for child: Node in word_types_list.get_children():
		child.queue_free()
	
	var pulled_cards: Array[CardInfo] = _card_library.pulled_cards
	var pulled_nouns: Array[CardInfo] = pulled_cards.filter(func(card: CardInfo) -> bool: return is_instance_of(card, CardInfoBasicNoun))
	var pulled_verbs: Array[CardInfo] = pulled_cards.filter(func(card: CardInfo) -> bool: return is_instance_of(card, CardInfoBasicVerb))
	var pulled_adjectives: Array[CardInfo] = pulled_cards.filter(func(card: CardInfo) -> bool: return is_instance_of(card, CardInfoModifierAdjective))
	var pulled_adverbs: Array[CardInfo] = pulled_cards.filter(func(card: CardInfo) -> bool: return is_instance_of(card, CardInfoModifierAdverb))
	
	_initialize_list("Nouns", pulled_nouns)
	_initialize_list("Verbs", pulled_verbs)
	_initialize_list("Adjectives", pulled_adjectives)
	_initialize_list("Adverbs", pulled_adverbs)
	_on_word_list_changed()

func _initialize_list(name: String, cards: Array[CardInfo]) -> void:
	var word_list: WordList = WORD_LIST.instantiate() as WordList
	word_list.init(name, cards, _game_stats)
	word_list.list_changed.connect(_on_word_list_changed)
	word_types_list.add_child(word_list)

func _on_word_list_changed() -> void:
	var max_cards: int = _game_stats.DECK_MAX_COUNT
	var cards: int = _game_stats.deck_get_size()
	
	progress_bar.max_value = max_cards
	progress_bar.value = cards
	progress_bar_label.text = "Cards: %d / %d" % [cards, max_cards]
