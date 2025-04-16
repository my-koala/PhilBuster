extends CanvasLayer
class_name MainMenu

signal play_pressed()

@onready
var background: Control = $background as Control

@onready
var main_screen: FlowCoordinator = $flow_coordinator as FlowCoordinator

func _ready() -> void:
	present_menu()

func present_menu() -> void:
	background.scale = Vector2(3, 3)
	background.modulate = Color(0, 0, 0, 1)
	
	main_screen.pop_all_views()
	main_screen.scale = Vector2(3, 3)
	main_screen.modulate = Color(1, 1, 1, 0)
	
	var background_tween: Tween = get_tree().create_tween()
	background_tween.set_ease(Tween.EASE_OUT)
	background_tween.set_trans(Tween.TRANS_CUBIC)
	background_tween.tween_property(background, "scale", Vector2.ONE, 5)
	background_tween.set_trans(Tween.TRANS_CIRC)
	background_tween.parallel().tween_property(background, "modulate", Color(1, 1, 1, 1), 5)
	background_tween.play()
	
	await get_tree().create_timer(3.5).timeout
	
	var menu_tween: Tween = get_tree().create_tween()
	menu_tween.set_ease(Tween.EASE_OUT)
	menu_tween.set_trans(Tween.TRANS_CUBIC)
	menu_tween.tween_property(main_screen, "scale", Vector2.ONE, 5)
	menu_tween.set_trans(Tween.TRANS_CIRC)
	menu_tween.parallel().tween_property(main_screen, "modulate", Color(1, 1, 1, 1), 5)
	menu_tween.play()

func _on_play_pressed() -> void:
	play_pressed.emit()
