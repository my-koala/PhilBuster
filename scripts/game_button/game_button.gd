@tool
extends Button
class_name GameButton

@onready
var _audio_hover: AudioStreamPlayer = $audio/hover as AudioStreamPlayer
@onready
var _audio_click: AudioStreamPlayer = $audio/click as AudioStreamPlayer

var _input_mouse_click: bool = false
var _input_mouse_hover: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	pressed.connect(_audio_click.play)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if !disabled && is_hovered():
		if !_input_mouse_hover:
			_input_mouse_hover = true
			_audio_hover.play()
	else:
		if _input_mouse_hover:
			_input_mouse_hover = false
