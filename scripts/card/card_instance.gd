@tool
extends Control
class_name CardInstance

# TODO: Texture swap based on card type.
# TODO: Animations on select, mouse hover, deselect.

var card_info: CardInfo = null:
	get:
		return card_info
	set(value):
		if card_info != value:
			card_info = value
			_dirty = true

@onready
var _label: Label = %label as Label
@onready
var _color_rect: ColorRect = %color_rect as ColorRect
@onready
var _drag_grabber: DragGrabber = %drag_grabber as DragGrabber

var _dirty: bool = false

func get_drag_grabber() -> DragGrabber:
	return _drag_grabber

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	

func _update_display() -> void:
	if is_instance_valid(card_info):
		_label.text = card_info.word
		
		if card_info is CardInfoBasicNoun:
			_color_rect.color = Color.RED
		elif card_info is CardInfoBasicVerb:
			_color_rect.color = Color.BLUE
		elif card_info is CardInfoModifierAdjective:
			_color_rect.color = Color.ORANGE_RED
		elif card_info is CardInfoModifierAdverb:
			_color_rect.color = Color.BLUE_VIOLET
	else:
		_label.text = "N/A"
		_color_rect.color = Color.GRAY

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _drag_grabber.is_grabbed():
		global_position = _drag_grabber.get_grab_position()
	else:
		pass
	
	if _drag_grabber.is_grabbed() || _drag_grabber.is_hovered():
		scale = Vector2(1.125, 1.125)
		z_index = 1
	else:
		scale = Vector2(1.0, 1.0)
		z_index = 0

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _dirty:
		_update_display()
		_dirty = false
	
	if _drag_grabber.is_grabbed():
		pass
	else:
		pass
