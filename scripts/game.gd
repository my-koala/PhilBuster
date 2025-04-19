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
	GAMEOVER,
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
@onready
var _music_player: MusicPlayer = $music_player as MusicPlayer

var _state: State = State.NONE

var _loop: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Subscribe to looping events
	_session.gameover.connect(_on_session_gameover)
	_session.session_finished.connect(_on_session_finished)
	_shop.shop_finished.connect(_on_shop_finished)
	_main_menu.play_pressed.connect(_on_main_menu_start)
	
	start()

func _reset() -> void:
	game_stats.reset_deck()
	game_stats.reset_money()
	game_stats.topic_randomize()
	game_stats.reset_topic_memory()
	game_stats.reset_time_wasted()
	game_stats.reset_bust_accumulated()
	game_stats.reset_session()
	game_stats.reset_rerolls()
	
	_card_library.reset_library()
	for card_info: CardInfo in game_stats.get_deck():
		_card_library.pull_card(card_info)
	
	_money_display.init(game_stats)

func start() -> void:
	if _loop:
		return
	_loop = true
	
	_reset()
	start_menu()

func stop() -> void:
	_loop = false

func start_menu() -> void:
	_music_player.play_track(MusicPlayer.Track.TITLE)
	_main_menu.visible = true
	_main_menu.present_menu()

func start_session() -> void:
	_music_player.play_track(MusicPlayer.Track.MAIN)
	game_stats.topic_randomize()
	await _transition.fade_in("- Session #%d -\nA bill concerning '%s' must be delayed..." % [game_stats.get_session(), game_stats.topic_get_name()], 2.0)
	_shop.hide_shop()
	_main_menu.visible = false
	await get_tree().create_timer(2).timeout
	_session.start_session(game_stats)
	await _transition.fade_out()

func start_shop() -> void:
	_music_player.play_track(MusicPlayer.Track.RECESS)
	await _transition.fade_in("Senate has called recess...")
	await get_tree().create_timer(2).timeout
	_shop.start_shop(_card_library, game_stats)
	await _transition.fade_out()

func _on_session_gameover() -> void:
	_music_player.play_track(MusicPlayer.Track.GAMEOVER)

func _on_session_finished(successful: bool) -> void:
	if successful:
		game_stats.session_increment()
		start_shop()
	else:
		await _transition.fade_in("")
		start_menu()
		_reset()
		await _transition.fade_out()

func _on_shop_finished() -> void:
	start_session()

func _on_main_menu_start() -> void:
	start_session()
