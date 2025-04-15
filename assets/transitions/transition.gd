extends ColorRect
class_name Transition

@onready
var _label: Label = $label as Label

func fade_in(transition_text: String, duration: float = 1) -> void:
	_label.text = transition_text
	visible = true
	
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), duration)
	tween.play()
	
	await tween.finished

func fade_out(duration: float = 1) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), duration)
	tween.play()
	
	await tween.finished
	
	visible = false
