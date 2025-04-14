extends MenuView
class_name ShopView

@onready
var shop_container: Container = $"shop_container"

@onready
var purchase_container: Control = $"purchase_container"

@onready
var purchase_text: Label = $"purchase_container/label"

var _game: Game
var _card_library : CardLibrary
var _game_stats : GameStats

var _held_card: CardInstance = null
var _is_over_purchase: bool = false
var _can_purchase: bool = false

const CARD_INSTANCE: PackedScene = preload("res://assets/card/card_instance.tscn")

func _ready() -> void:
	_game = get_tree().current_scene as Game
	
	if !is_instance_valid(_game):
		print("Game is null; assuming we are running the shop scene directly")
		return
		
	_card_library = _game.card_library
	_game_stats = _game.game_stats
	
	for i: int in range(6):
		var card_instance: CardInstance = CARD_INSTANCE.instantiate() as CardInstance
		# We grab a random basic card for the first half of the shop, random modifier for the second half
		card_instance.card_info = _card_library.get_random_basic_card() if i < 3 else _card_library.get_random_modifier_card()
		card_instance.drag_started.connect(_on_card_drag_started.bind(card_instance))
		card_instance.drag_stopped.connect(_on_card_drag_stopped.bind(card_instance))
		
		shop_container.add_child(card_instance)
	
	purchase_container.mouse_entered.connect(_on_purchase_container_entered)
	purchase_container.mouse_exited.connect(_on_purchase_container_exited)

func _on_purchase_container_entered() -> void:
	purchase_container.modulate.a = 0.75
	_is_over_purchase = true

func _on_purchase_container_exited() -> void:
	purchase_container.modulate.a = 0.25
	_is_over_purchase = false

# TODO: Determine price of cards
func _on_card_drag_started(card: CardInstance) -> void:
	_held_card = card
	
	var price: int = _game_stats.calculate_price_for(card.card_info)
	purchase_text.text = "PURCHASE: $%d" % price
	_can_purchase = _game_stats.get_money() >= price
	
	# Change purchase button color to RED if player cannot purchase, or GREEN if player can purchase
	purchase_container.modulate = Color(0,1,0, purchase_container.modulate.a) if _can_purchase else Color(1, 0, 0, purchase_container.modulate.a)
	
func _on_card_drag_stopped(card: CardInstance) -> void:
	purchase_container.modulate = Color(0, 0, 0, purchase_container.modulate.a)
	_held_card = null
	purchase_text.text = "PURCHASE"
	
	# TODO: Insert card in player deck
	if _is_over_purchase && _can_purchase:
		_card_library.pull_card(card.card_info)
		card.queue_free()
		_game_stats.money_remove(_game_stats.calculate_price_for(card.card_info))
		
	pass
