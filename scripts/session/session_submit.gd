@tool
extends Control
class_name SessionSubmit

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
var _button: Button = %button as Button

var _dirty: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_button.pressed.connect(submitted.emit)

func _physics_process(delta: float) -> void:
	if !_dirty:
		return
	_dirty = false
	
	_button.disabled = !enabled
