@tool
extends Label
class_name SentenceContainerWord

# TODO: Animations on creation/deletion, reading, and idle.
# NOTE:
# 

var _word: String = ""

func set_word(word: String) -> void:
	_word = word
	
	text = _word

var _tween_read_animation: Tween = null

func play_read_animation() -> void:
	if is_instance_valid(_tween_read_animation):
		_tween_read_animation.custom_step(1000.0)
		_tween_read_animation.kill()
		_tween_read_animation = null
	_tween_read_animation = create_tween()
	
	_tween_read_animation.set_ease(Tween.EASE_OUT)
	_tween_read_animation.set_trans(Tween.TRANS_CUBIC)
	_tween_read_animation.tween_property(self, "position:y", position.y - 24.0, 0.1)
	_tween_read_animation.set_ease(Tween.EASE_IN)
	_tween_read_animation.set_trans(Tween.TRANS_CUBIC)
	_tween_read_animation.tween_property(self, "position:y", position.y, 0.1)
