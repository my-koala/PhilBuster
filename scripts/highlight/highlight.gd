@tool
extends ColorRect
class_name Highlight

# TODO:
# marching ants shader

signal highlight_started()
signal highlight_stopped()

@export
var enabled: bool = false:
	get:
		return enabled
	set(value):
		if enabled != value:
			enabled = value
			if enabled:
				highlight_started.emit()
			else:
				highlight_stopped.emit()
			_dirty = true

@onready
var _ants: ColorRect = $ants as ColorRect

var _dirty: bool = false

func _process(delta: float) -> void:
	if _dirty:
		_dirty = false
	
	if enabled:
		_ants.visible = true
		color = Color(1.0, 1.0, 1.0, 0.1)
	else:
		_ants.visible = false
		color = Color(0.0, 0.0, 0.0, 0.0)
