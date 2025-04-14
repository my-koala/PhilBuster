extends MenuView
class_name ShopView

@export
var card_library: CardLibrary

@onready
var shop_container: Container = $"shop_container"

@onready
var purchase_container: Control = $"purchase_container"

@onready
var purchase_text: Label = $"purchase_container/label"

var _held_card: CardInstance = null
var _is_over_purchase: bool = false
var _can_purchase: bool = false

const CARD_INSTANCE: PackedScene = preload("res://assets/card/card_instance.tscn")

func _ready() -> void:
	for i: int in range(6):
		var card_instance: CardInstance = CARD_INSTANCE.instantiate() as CardInstance
		# We grab a random basic card for the first half of the shop, random modifier for the second half
		card_instance.card_info = card_library.get_random_basic_card() if i < 3 else card_library.get_random_modifier_card()
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
	purchase_text.text = "PURCHASE: $%d"
	
	# TODO: Replace with comparison against player money
	_can_purchase = true
	
	# Change purchase button color to RED if player cannot purchase, or GREEN if player can purchase
	purchase_container.modulate = Color(0,1,0, purchase_container.modulate.a) if _can_purchase else Color(1, 0, 0, purchase_container.modulate.a)
	
func _on_card_drag_stopped(card: CardInstance) -> void:
	purchase_container.modulate = Color(0, 0, 0, purchase_container.modulate.a)
	_held_card = null
	purchase_text.text = "PURCHASE"
	
	# TODO: Insert card in player deck
	if _is_over_purchase && _can_purchase:
		card_library.pull_card(card.card_info)
		card.queue_free()
		
	pass
