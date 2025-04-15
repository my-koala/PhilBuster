@tool
extends Node
class_name Game

# for this jam, will only simulate one session from the same starting deck each time the player plays/restarts
# there wont be enough time to implement and balance multiple session difficulties

enum State {
	NONE,
	MENU,
	SESSION,
	SHOP,
}

@export
var default_deck: Array[CardInfo] = []

@onready
var card_library: CardLibrary = $card_library as CardLibrary
@onready
var _session: Session = $session as Session
@onready
var _shop: Shop = $shop as Shop
@onready
var _transition: Transition = $transition/transition as Transition

var _loop: bool = false
var game_stats: GameStats = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	start()

func start() -> void:
	if _loop:
		return
	
	_loop = true
	game_stats = GameStats.new()
	
	# Initialize card deck.
	for card_info: CardInfo in default_deck:
		if !game_stats.deck_is_full():
			game_stats.deck_append(card_info)
		card_library.pull_card(card_info)
	
	# Subscribe to looping events
	_session.session_finished.connect(_on_session_finished)
	_shop.shop_finished.connect(_on_shop_finished)
	
	# Start the session loop
	start_session()

func stop() -> void:
	game_stats.deck_clear()
	
	game_stats = null
	_loop = false

func start_session() -> void:
	await _transition.fade_in("A bill concerning {n}...")
	await get_tree().create_timer(2).timeout
	_shop.hide_shop()
	_session.start_session(game_stats)
	await _transition.fade_out()

func start_shop() -> void:
	await _transition.fade_in("Senate has called recess...")
	await get_tree().create_timer(2).timeout
	_shop.start_shop(card_library, game_stats)
	await _transition.fade_out()
	
func _on_session_finished(successful: bool) -> void:
	if successful:
		game_stats.session_finished()
		start_shop()

func _on_shop_finished() -> void:
	start_session()
