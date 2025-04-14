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
		if !_game_stats.deck_is_full():
			_game_stats.deck_append(card_info)
	
	_session.start_session(game_stats)

func stop() -> void:
	game_stats.deck_clear()
	
	game_stats = null
	_loop = false
