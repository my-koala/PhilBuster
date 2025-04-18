extends MenuView
class_name ShopView

signal on_card_purchase(price: int)

@onready
var shop_container: Container = $"shop_container"

@onready
var purchase_container: Control = $"purchase_container"

@onready
var purchase_text: Label = $"purchase_container/label"

@onready
var _purchase_good_sfx: AudioStreamPlayer = $"shop_purchase" as AudioStreamPlayer

@onready
var _purchase_bad_sfx: AudioStreamPlayer = $"shop_fail" as AudioStreamPlayer

var _card_library : CardLibrary
var _game_stats : GameStats

var _held_card: CardInstance = null
var _is_over_purchase: bool = false
var _can_purchase: bool = false

const CARD_INSTANCE: PackedScene = preload("res://assets/card/card_instance.tscn")

func _ready() -> void:
	purchase_container.mouse_entered.connect(_on_purchase_container_entered)
	purchase_container.mouse_exited.connect(_on_purchase_container_exited)

func reset_shop(card_library: CardLibrary, game_stats: GameStats) -> void:
	_card_library = card_library
	_game_stats = game_stats
	
	for child: Control in shop_container.get_children():
		child.queue_free()
	
	for i: int in range(6):
		var card_instance: CardInstance = CARD_INSTANCE.instantiate() as CardInstance
		# We grab a random basic card for the first half of the shop, random modifier for the second half
		card_instance.card_info = _card_library.get_random_basic_card() if i < 3 else _card_library.get_random_modifier_card()
		card_instance.drag_started.connect(_on_card_drag_started.bind(card_instance))
		card_instance.drag_stopped.connect(_on_card_drag_stopped.bind(card_instance))
		
		shop_container.add_child(card_instance)

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
	
	if !_is_over_purchase:
		return
	
	if _can_purchase:
		var card_info: CardInfo = card.card_info
		var price: int = _game_stats.calculate_price_for(card_info)
		
		_card_library.pull_card(card_info)
		card.queue_free()
		_game_stats.money_remove(price)
		_game_stats.deck_append(card_info)
		on_card_purchase.emit(price)
		_purchase_good_sfx.play()
	else:
		_purchase_bad_sfx.play()
