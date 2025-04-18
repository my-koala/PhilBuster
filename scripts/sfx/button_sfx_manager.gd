# We about to do this shit dirty as FUUUUCK
extends Node
class_name ButtonSFXManager

@onready
var _mouse_over_sfx : AudioStreamPlayer = $mouse_over_sfx

@onready
var _click_sfx : AudioStreamPlayer = $click_sfx

func hook_to_button(button: BaseButton) -> void:
	button.mouse_entered.connect(_mouse_over_sfx.play)
	button.pressed.connect(_click_sfx.play)

func _ready() -> void:
	_search_for_buttons(get_tree().current_scene)

func _search_for_buttons(node: Node) -> void:
	if is_instance_of(node, BaseButton):
		var button: BaseButton = node as BaseButton
		hook_to_button(button)

	for child: Node in node.get_children():
		_search_for_buttons(child)
