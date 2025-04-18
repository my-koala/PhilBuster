extends CanvasLayer
class_name Shop

signal shop_finished()

@onready
var flow_coordinator: FlowCoordinator = $flow_coordinator

@onready
var shop_view: ShopView = $flow_coordinator/shop_view

@onready
var deck_view: DeckView = $flow_coordinator/deck_view

@onready
var money_text: Label = $flow_coordinator/heading_banner/money_label

@onready
var money_flyout: FlyoutSpawner = $flow_coordinator/heading_banner/flyout_spawner

var _game_stats: GameStats = null

func _ready() -> void:
	shop_view.on_card_purchase.connect(func (price: int) -> void: update_money(_game_stats.get_money(), -price))

func start_shop(card_library: CardLibrary, game_stats: GameStats) -> void:
	visible = true
	flow_coordinator.pop_all_views()
	_game_stats = game_stats
	
	shop_view.reset_shop(card_library, game_stats)
	deck_view.reset_lists(card_library, game_stats)
	
	update_money(_game_stats.get_money(), 0, false)

func hide_shop() -> void:
	visible = false

func exit_shop() -> void:
	shop_finished.emit()

func update_money(amount: int, offset: int, spawn_offset_text: bool = true) -> void:
	money_text.text = "$%d" % _game_stats.get_money()
	
	if (offset == 0):
		return
	
	var offset_text: String = "$%d" % offset if offset >= 0 else "-$%d" % abs(offset)
	var offset_color: Color = Color.GREEN_YELLOW if offset >= 0 else Color.INDIAN_RED
	
	money_flyout.spawn_flyout(offset_text, offset_color)
