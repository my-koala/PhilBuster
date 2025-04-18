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
var game_stats: GameStats = GameStats.new()

@onready
var _card_library: CardLibrary = $card_library as CardLibrary
@onready
var _session: Session = $session as Session
@onready
var _shop: Shop = $shop as Shop
@onready
var _transition: Transition = $transition/transition as Transition
@onready
var _main_menu: MainMenu = $main_menu as MainMenu
@onready
var _money_display: MoneyDisplay = $money_display as MoneyDisplay

var _loop: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	start()

func start() -> void:
	if _loop:
		return
	
	_loop = true
	
	game_stats.reset_deck()
	game_stats.reset_money()
	game_stats.topic_randomize()
	game_stats.reset_topic_memory()
	
	_card_library.reset_library()
	
	for card_info: CardInfo in game_stats.get_deck():
		_card_library.pull_card(card_info)
	
	_money_display.init(game_stats)
	
	# Subscribe to looping events
	_session.session_finished.connect(_on_session_finished)
	_shop.shop_finished.connect(_on_shop_finished)
	_main_menu.play_pressed.connect(_on_main_menu_start)
	
	# Start the main menu
	start_menu()

func stop() -> void:
	_loop = false

func start_menu() -> void:
	_main_menu.visible = true
	_main_menu.present_menu()
	print("presentu")

func start_session() -> void:
	game_stats.topic_randomize()
	await _transition.fade_in("A bill concerning %s..." % [game_stats.topic_get_name()])
	_shop.hide_shop()
	_main_menu.visible = false
	await get_tree().create_timer(2).timeout
	_session.start_session(game_stats)
	await _transition.fade_out()

func start_shop() -> void:
	await _transition.fade_in("Senate has called recess...")
	await get_tree().create_timer(2).timeout
	_shop.start_shop(_card_library, game_stats)
	await _transition.fade_out()

func _on_session_finished(successful: bool) -> void:
	if successful:
		game_stats.session_increment()
		start_shop()
	else:
		await _transition.fade_in("")
		start_menu()
		await _transition.fade_out()

func _on_shop_finished() -> void:
	start_session()

func _on_main_menu_start() -> void:
	start_session()
