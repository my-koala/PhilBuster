@tool
extends Control
class_name SessionDiscard

signal submitted()

@export
var enabled: bool = true:
	get:
		return enabled
	set(value):
		if enabled != value:
			enabled = value
			_dirty = true

@onready
var _game_button: GameButton = %game_button as GameButton
@onready
var _label_count: Label = %label_count as Label

var _dirty: bool = true

func set_discard_count(discard_count: int) -> void:
	_label_count.text = "%d left" % [discard_count]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_game_button.pressed.connect(submitted.emit)
	
	_update()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if _dirty:
		_dirty = false
		_update()
		

func _update() -> void:
	_game_button.disabled = !enabled
