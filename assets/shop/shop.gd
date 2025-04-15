extends CanvasLayer
class_name Shop

signal shop_finished()

@onready
var flow_coordinator: FlowCoordinator = $flow_coordinator

@onready
var shop_view: ShopView = $flow_coordinator/shop_view

@onready
var deck_view: DeckView = $flow_coordinator/deck_view

func start_shop(card_library: CardLibrary, game_stats: GameStats) -> void:
	visible = true
	flow_coordinator.pop_all_views()
	
	shop_view.reset_shop(card_library, game_stats)
	deck_view.reset_lists(card_library, game_stats)

func hide_shop() -> void:
	visible = false

func exit_shop() -> void:
	shop_finished.emit()
