@tool
extends ColorRect
class_name Highlight

# TODO:
# marching ants shader

@export
var enabled: bool = false

func _process(delta: float) -> void:
	if enabled:
		color = Color(1.0, 1.0, 1.0, 0.1)
	else:
		color = Color(0.0, 0.0, 0.0, 0.0)
