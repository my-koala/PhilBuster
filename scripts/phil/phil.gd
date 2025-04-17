@tool
extends Control
class_name Phil

enum AnimationBaseState {
	SIT,
	STAND,
	BUST,
}

@onready
var _animation_player: AnimationPlayer = $animation_player as AnimationPlayer

var _animation_base_state: AnimationBaseState = AnimationBaseState.SIT

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	play_animation_sit()

# Return to looping idle animation based on base state.
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match _animation_base_state:
		AnimationBaseState.SIT:
			_animation_player.play(&"phil/sit_idle")
		AnimationBaseState.STAND:
			_animation_player.play(&"phil/stand_idle")
		AnimationBaseState.BUST:
			_animation_player.play(&"phil/bust_idle")

func play_animation_sit() -> void:
	match _animation_base_state:
		AnimationBaseState.SIT:
			_animation_player.play(&"phil/sit_idle")
		AnimationBaseState.STAND:
			_animation_player.play(&"phil/stand_sit")
		AnimationBaseState.BUST:
			_animation_player.play(&"phil/sit_idle")
	_animation_base_state = AnimationBaseState.SIT

func play_animation_stand() -> void:
	match _animation_base_state:
		AnimationBaseState.SIT:
			_animation_player.play(&"phil/sit_stand")
		AnimationBaseState.STAND:
			_animation_player.play(&"phil/stand_idle")
		AnimationBaseState.BUST:
			_animation_player.play(&"phil/stand_idle")
	_animation_base_state = AnimationBaseState.STAND

func play_animation_bust() -> void:
	match _animation_base_state:
		AnimationBaseState.SIT:
			_animation_player.play(&"phil/stand_bust")
		AnimationBaseState.STAND:
			_animation_player.play(&"phil/stand_bust")
		AnimationBaseState.BUST:
			_animation_player.play(&"phil/stand_bust")
	_animation_base_state = AnimationBaseState.BUST

func play_animation_goof() -> void:
	_animation_player.play(&"phil/stand_goof")
	_animation_base_state = AnimationBaseState.STAND

func play_animation_nice() -> void:
	_animation_player.play(&"phil/stand_nice")
	_animation_base_state = AnimationBaseState.STAND

func play_animation_speak() -> void:
	if _animation_player.current_animation == &"phil/stand_nice":
		pass
	elif _animation_player.current_animation == &"phil/stand_goof":
		pass
	elif _animation_player.current_animation == &"phil/stand_speak":
		_animation_player.seek(0.0)
	else:
		_animation_player.play(&"phil/stand_speak")
	_animation_base_state = AnimationBaseState.STAND
