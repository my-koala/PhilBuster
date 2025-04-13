extends MenuView
class_name ShopView

@export
var card_library: CardLibrary

@onready
var shop_container: Container = $"shop_container"

const CARD_INSTANCE: PackedScene = preload("res://assets/card/card_instance.tscn")

func _ready() -> void:
	for i: int in range(3):
		var card_instance: CardInstance = CARD_INSTANCE.instantiate() as CardInstance
		card_instance.card_info = card_library.get_random_basic_card()
		
		shop_container.add_child(card_instance)
	
	for i: int in range(3):
		var card_instance: CardInstance = CARD_INSTANCE.instantiate() as CardInstance
		card_instance.card_info = card_library.get_random_modifier_card()
		
		shop_container.add_child(card_instance)
