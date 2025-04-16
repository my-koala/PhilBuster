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
@onready
var _main_menu: MainMenu = $main_menu as MainMenu

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
	_main_menu.play_pressed.connect(_on_main_menu_start)
	
	# Start the main menu
	start_menu()

func stop() -> void:
	game_stats.deck_clear()
	
	game_stats = null
	_loop = false

func start_menu() -> void:
	_main_menu.visible = true
	_main_menu.present_menu()

func start_session() -> void:
	await _transition.fade_in("A bill concerning {n}...")
	await get_tree().create_timer(2).timeout
	_shop.hide_shop()
	_main_menu.visible = false
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

func _on_main_menu_start() -> void:
	start_session()
