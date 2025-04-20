extends ColorRect
class_name Transition

@onready
var _label: Label = $label as Label

var _tween: Tween = null

func _ready() -> void:
	self.modulate = Color(1, 1, 1, 0)

func fade_in(transition_text: String, duration: float = 1) -> void:
	if is_instance_valid(_tween):
		_tween.kill()
	_tween = create_tween()
	
	_label.text = transition_text
	visible = true
	
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), duration)
	_tween.play()
	
	await _tween.finished

func fade_out(duration: float = 1) -> void:
	if is_instance_valid(_tween):
		_tween.kill()
	_tween = create_tween()
	
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_parallel(false)
	_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), duration)
	_tween.tween_property(self, "visible", false, 0.0)
	_tween.play()
	
	await _tween.finished
