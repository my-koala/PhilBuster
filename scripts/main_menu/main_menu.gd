extends CanvasLayer
class_name MainMenu

signal play_pressed()

@onready
var background: Control = $background as Control

@onready
var main_screen: FlowCoordinator = $flow_coordinator as FlowCoordinator

func _ready() -> void:
	present_menu()

var _tween: Tween = null

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed(&"mouse_left") && is_instance_valid(_tween):
		_tween.kill()
		_tween = null
		background.scale = Vector2.ONE
		background.modulate = Color.WHITE
		main_screen.scale = Vector2.ONE
		main_screen.modulate = Color.WHITE
		main_screen.visible = true

func present_menu() -> void:
	if is_instance_valid(_tween):
		_tween.kill()
		_tween = null
	_tween = create_tween()
	
	background.scale = Vector2(3, 3)
	background.modulate = Color(0, 0, 0, 1)
	
	main_screen.pop_all_views()
	main_screen.scale = Vector2(3, 3)
	main_screen.modulate = Color(1, 1, 1, 0)
	main_screen.visible = false
	
	_tween.set_parallel(true)
	
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(background, "scale", Vector2.ONE, 5)
	_tween.set_trans(Tween.TRANS_CIRC)
	_tween.tween_property(background, "modulate", Color(1, 1, 1, 1), 5)
	_tween.play()
	
	_tween.tween_interval(3.0)
	_tween.set_parallel(false)
	
	_tween.tween_property(main_screen, "visible", true, 0.0)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(main_screen, "scale", Vector2.ONE, 4)
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_CIRC)
	_tween.tween_property(main_screen, "modulate", Color(1, 1, 1, 1), 4)

func _on_play_pressed() -> void:
	play_pressed.emit()


func _on_quit_pressed() -> void:
	if OS.get_name() != "Web":
		get_tree().quit()
