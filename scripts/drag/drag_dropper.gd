@tool
extends Control
class_name DragDropper

signal hover_started()
signal hover_stopped()
signal press_started()
signal press_stopped()

@onready
var _color_rect_highlight: ColorRect = $color_rect_highlight as ColorRect
@onready
var _color_rect_dim: ColorRect = $color_rect_dim as ColorRect

@export
var enabled: bool = true

var _input_mouse_hovered: bool = false
var _input_mouse_just_pressed: bool = false
var _input_mouse_pressed: bool = false

var _hover: bool = false
var _press: bool = false

func highlight() -> void:
	pass

func unhighlight() -> void:
	pass

func dim() -> void:
	pass

func undim() -> void:
	pass

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(func() -> void: _input_mouse_hovered = true)
	mouse_exited.connect(func() -> void: _input_mouse_hovered = false)

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	_input_mouse_pressed = Input.is_action_pressed(&"mouse_left")
	if Input.is_action_just_pressed(&"mouse_left") && _input_mouse_hovered:
		_input_mouse_just_pressed = true

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if enabled:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	if !enabled:
		if _press:
			_press = false
			press_stopped.emit()
	elif _input_mouse_just_pressed:
		if !_press:
			_press = true
			press_started.emit()
	elif !_input_mouse_pressed:
		if _press:
			_press = false
			press_stopped.emit()
	
	_input_mouse_just_pressed = false
	
	if _hover != _input_mouse_hovered:
		_hover = _input_mouse_hovered
		if _hover:
			hover_started.emit()
		else:
			hover_stopped.emit()
