@tool
extends Control
class_name TutorialSession

@export
var overlay_rect_grow_speed: float = 128.0

@onready
var _overlay_a: ColorRect = $overlay/a as ColorRect
@onready
var _overlay_b: ColorRect = $overlay/b as ColorRect
@onready
var _overlay_c: ColorRect = $overlay/c as ColorRect
@onready
var _overlay_d: ColorRect = $overlay/d as ColorRect

@onready
var _pages: Array[Control] = [
	$pages/page_0 as Control,
	$pages/page_1 as Control,
	$pages/page_2 as Control,
	$pages/page_3 as Control,
	$pages/page_4 as Control,
	$pages/page_5 as Control,
	$pages/page_6 as Control,
	$pages/page_7 as Control,
	$pages/page_8 as Control,
]

@onready
var _boxes: Array[Control] = [
	$boxes/box_0 as Control,
	$boxes/box_1 as Control,
	$boxes/box_2 as Control,
	$boxes/box_3 as Control,
	$boxes/box_4 as Control,
	$boxes/box_5 as Control,
	$boxes/box_6 as Control,
	$boxes/box_7 as Control,
	$boxes/box_8 as Control,
]

@onready
var _button: Button = $button as Button

var _page: int = 0

var _overlay_rect: Rect2 = Rect2()

func _set_overlay_rect(rect: Rect2) -> void:
	_overlay_a.position.x = 0.0
	_overlay_a.position.y = 0.0
	_overlay_a.size.x = size.x
	_overlay_a.size.y = rect.position.y
	
	_overlay_b.position.x = 0.0
	_overlay_b.position.y = rect.position.y + rect.size.y
	_overlay_b.size.x = size.x
	_overlay_b.size.y = size.y - (rect.position.y + rect.size.y)
	
	_overlay_c.position.x = 0.0
	_overlay_c.position.y = rect.position.y
	_overlay_c.size.x = rect.position.x
	_overlay_c.size.y = rect.size.y
	
	_overlay_d.position.x = rect.position.x + rect.size.x
	_overlay_d.position.y = rect.position.y
	_overlay_d.size.x = size.x - (rect.position.x + rect.size.x)
	_overlay_d.size.y = rect.size.y
	
	_overlay_rect = rect

var _input_mouse_hover: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	mouse_entered.connect(func() -> void: _input_mouse_hover = true)
	mouse_exited.connect(func() -> void: _input_mouse_hover = false)
	
	_button.pressed.connect(func() -> void: _page = _pages.size())

func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if Input.is_action_just_pressed(&"mouse_left") && _input_mouse_hover:
		_advance()

func _advance() -> void:
	if _page < _pages.size():
		_page += 1

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _page >= _pages.size():
		visible = false
		return
	
	for i: int in _pages.size():
		_pages[i].visible = (i == _page)
	
	_set_overlay_rect(_boxes[_page].get_global_rect())
	
	#var overlay_rect_next: Rect2 = _box.get_global_rect()
	
	#_set_overlay_rect(Rect2(
	#	_overlay_rect.position.move_toward(overlay_rect_next.position, delta * overlay_rect_grow_speed),
	#	_overlay_rect.size.move_toward(overlay_rect_next.size, delta * overlay_rect_grow_speed),
	#))
