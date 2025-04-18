@tool
extends Control
class_name SessionSpeak

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

var _dirty: bool = true

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
