extends MenuView
class_name DeckView

@onready
var progress_bar: ProgressBar = $progress_bar

@onready
var progress_bar_label: Label = $progress_bar/label

@onready
var word_types_list: Control = $word_types

@onready
var card_preview: CardInstance = $card_instance

var _card_library : CardLibrary
var _game_stats : GameStats

const WORD_LIST: PackedScene = preload("res://assets/shop/word_list.tscn")

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

# Reset lists when this view is enabled (so purchased cards can show up)
func _on_visibility_changed() -> void:
	if is_instance_valid(_card_library) && is_instance_valid(_game_stats):
		reset_lists(_card_library, _game_stats)

func reset_lists(card_library: CardLibrary, game_stats: GameStats) -> void:
	_card_library = card_library
	_game_stats = game_stats
	
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
	word_list.on_word_hovered.connect(_on_word_hovered)
	word_types_list.add_child(word_list)

func _on_word_list_changed() -> void:
	var max_cards: int = _game_stats.DECK_MAX_COUNT
	var cards: int = _game_stats.deck_get_size()
	
	progress_bar.max_value = max_cards
	progress_bar.value = cards
	progress_bar_label.text = "Cards: %d / %d" % [cards, max_cards]
	
func _on_word_hovered(card: CardInfo, hovered: bool) -> void:
	# This makes the card preview flicker a lot but I can find a better solution later TM
	card_preview.visible = hovered
	
	if !hovered:
		return
	
	card_preview.card_info = card
