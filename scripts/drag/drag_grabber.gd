@tool
extends Control
class_name DragGrabber

signal hover_started()
signal hover_stopped()
signal grab_started()
signal grab_stopped()

@export
var enabled: bool = true

var _input_mouse_hovered: bool = false
var _input_mouse_just_pressed: bool = false
var _input_mouse_pressed: bool = false

var _hover: bool = false

var _grab: bool = false
var _grab_position: Vector2 = Vector2.ZERO
var _grab_force_start: bool = false

func get_grab_position() -> Vector2:
	return _grab_position

func is_grabbed() -> bool:
	return _grab

func is_hovered() -> bool:
	return _hover

func grab_force_start() -> void:
	_grab_force_start = true

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
	
	if !_grab:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	else:
		Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	
	if !enabled:
		if _grab:
			_grab = false
			grab_stopped.emit()
	elif _input_mouse_just_pressed || (_grab_force_start && _input_mouse_pressed):
		_grab_force_start = false
		if !_grab:
			_grab = true
			grab_started.emit()
	elif !_input_mouse_pressed:
		if _grab:
			_grab = false
			grab_stopped.emit()
	
	_input_mouse_just_pressed = false
	
	if _hover != _input_mouse_hovered:
		_hover = _input_mouse_hovered
		if _hover:
			hover_started.emit()
		else:
			hover_stopped.emit()
	
	if _grab:
		_grab_position = get_global_mouse_position() - pivot_offset

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _grab:
		_grab_position = get_global_mouse_position() - pivot_offset
