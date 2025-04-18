extends CanvasLayer
class_name SettingsMenu

@onready
var _menu_base : Control = $nine_patch_rect

@onready
var _music_slider : HSlider = %music_slider

@onready
var _sfx_slider : HSlider = %sfx_slider

func show_menu() -> void:
	_menu_base.visible = true

func hide_menu() -> void:
	_menu_base.visible = false

func _ready() -> void:
	_init_slider(_music_slider, "Music")
	_init_slider(_sfx_slider, "Sound")

func _init_slider(slider: HSlider, name: String) -> void:
	var idx: int = AudioServer.get_bus_index(name)
	slider.value_changed.connect(func (vol: float) -> void: AudioServer.set_bus_volume_linear(idx, vol))
	slider.set_value_no_signal(AudioServer.get_bus_volume_linear(idx))

func _input(event: InputEvent) -> void:
	if !is_instance_of(event, InputEventMouseButton):
		return
	
	var mouse_event: InputEventMouseButton = event
	
	if mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	var mouse_position: Vector2 = mouse_event.global_position
	
	if !_menu_base.get_global_rect().has_point(mouse_position):
		hide_menu()
