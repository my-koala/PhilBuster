@tool
extends Button
class_name CardInstance

signal drag_started()
signal drag_stopped()

# TODO: Texture swap based on card type.
# TODO: Animations on select, mouse hover, deselect.

@export
var can_drag: bool = true

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
var _border_img: CanvasItem = %border as CanvasItem
@onready
var _card_pickup: AudioStreamPlayer = $card_pickup as AudioStreamPlayer
@onready
var _card_drop: AudioStreamPlayer = $card_drop as AudioStreamPlayer

var _dirty: bool = true

var _drag: bool = false

func start_drag() -> void:
	if !_drag:
		_drag = true
		drag_started.emit()
		_card_pickup.play()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	

func _update_display() -> void:
	if is_instance_valid(card_info):
		_label.text = card_info.get_word()
		
		if card_info is CardInfoBasicNoun:
			_border_img.modulate = Color.RED
		elif card_info is CardInfoBasicVerb:
			_border_img.modulate = Color.BLUE
		elif card_info is CardInfoModifierAdjective:
			_border_img.modulate = Color.ORANGE_RED
		elif card_info is CardInfoModifierAdverb:
			_border_img.modulate = Color.BLUE_VIOLET
	else:
		_label.text = "N/A"
		_border_img.modulate = Color.GRAY

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() || !can_drag:
		return
	
	var mouse_pressed: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	if disabled || !mouse_pressed:
		if _drag:
			_drag = false
			_card_drop.play()
			drag_stopped.emit()
	elif button_pressed:
		if !_drag:
			_drag = true
			_card_drop.play()
			drag_started.emit()
	
	if disabled:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
	else:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	if is_hovered():
		pass
	else:
		pass
	
	if _drag || is_hovered():
		scale = Vector2(1.125, 1.125)
		z_index = 1
	else:
		scale = Vector2(1.0, 1.0)
		z_index = 0
	
	if _drag:
		global_position = get_global_mouse_position() - pivot_offset
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _dirty:
		_update_display()
		_dirty = false
	
