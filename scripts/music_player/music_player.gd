@tool
extends Node
class_name MusicPlayer

enum Track {
	NONE,
	TITLE,
	MAIN,
	RECESS,
	GAMEOVER,
	RESULTS,
}

@export_range(0.0, 8.0, 0.001, "hide_slider", "or_greater")
var transition_duration_in: float = 1.5:
	get:
		return transition_duration_in
	set(value):
		transition_duration_in = maxf(value, 0.0)

@export_range(0.0, 8.0, 0.001, "hide_slider", "or_greater")
var transition_duration: float = 1.5:
	get:
		return transition_duration
	set(value):
		transition_duration = maxf(value, 0.0)

@onready
var _music_title: AudioStreamPlayer = $music_title as AudioStreamPlayer
var _music_title_linear_volume: float = 1.0
@onready
var _music_main: AudioStreamPlayer = $music_main as AudioStreamPlayer
var _music_main_linear_volume: float = 1.0
@onready
var _music_recess: AudioStreamPlayer = $music_recess as AudioStreamPlayer
var _music_recess_linear_volume: float = 1.0
@onready
var _music_gameover: AudioStreamPlayer = $music_gameover as AudioStreamPlayer
var _music_gameover_linear_volume: float = 1.0
@onready
var _music_results: AudioStreamPlayer = $music_results as AudioStreamPlayer
var _music_results_linear_volume: float = 1.0

var _track: Track = Track.NONE

var _tween: Tween = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Cache music volumes.
	_music_title_linear_volume = _music_title.volume_linear
	_music_main_linear_volume = _music_main.volume_linear
	_music_recess_linear_volume = _music_recess.volume_linear
	_music_gameover_linear_volume = _music_gameover.volume_linear
	_music_results_linear_volume = _music_results.volume_linear
	
	_track = Track.TITLE
	play_track(Track.NONE)

func _tween_to_mute(audio_stream_player: AudioStreamPlayer, full_volume: float) -> void:
	if audio_stream_player.playing:
		var duration: float = transition_duration
		duration *= remap(audio_stream_player.volume_linear, 0.0, full_volume, 0.0, 1.0)
		_tween.tween_property(audio_stream_player, "volume_linear", 0.0, duration)
		_tween.tween_callback(audio_stream_player.stop)
	else:
		audio_stream_player.volume_linear = 0.0

func _tween_to_full(audio_stream_player: AudioStreamPlayer, full_volume: float) -> void:
	_tween.tween_property(audio_stream_player, "volume_linear", full_volume, 0.0)
	if !audio_stream_player.playing:
		_tween.tween_callback(audio_stream_player.play)

func play_track(track: Track) -> void:
	if _track == track:
		return
	_track = track
	
	if is_instance_valid(_tween):
		_tween.kill()
		_tween = null
	_tween = create_tween()
	_tween.set_parallel(false)
	
	match track:
		Track.NONE:
			_music_title.volume_linear = 0.0
			_music_title.stop()
			_music_main.volume_linear = 0.0
			_music_main.stop()
			_music_recess.volume_linear = 0.0
			_music_recess.stop()
			_music_gameover.volume_linear = 0.0
			_music_gameover.stop()
			_music_results.volume_linear = 0.0
			_music_results.stop()
		Track.TITLE:
			_tween_to_mute(_music_main, _music_main_linear_volume)
			_tween_to_mute(_music_recess, _music_recess_linear_volume)
			_tween_to_mute(_music_gameover, _music_gameover_linear_volume)
			_tween_to_mute(_music_results, _music_results_linear_volume)
			
			_tween.tween_interval(0.5)
			_tween_to_full(_music_title, _music_title_linear_volume)
		Track.MAIN:
			_tween_to_mute(_music_title, _music_main_linear_volume)
			_tween_to_mute(_music_recess, _music_recess_linear_volume)
			_tween_to_mute(_music_gameover, _music_gameover_linear_volume)
			_tween_to_mute(_music_results, _music_results_linear_volume)
			
			_tween.tween_interval(0.5)
			_tween_to_full(_music_main, _music_main_linear_volume)
		Track.RECESS:
			_tween_to_mute(_music_title, _music_main_linear_volume)
			_tween_to_mute(_music_main, _music_main_linear_volume)
			_tween_to_mute(_music_gameover, _music_gameover_linear_volume)
			_tween_to_mute(_music_results, _music_results_linear_volume)
			
			_tween.tween_interval(0.5)
			_tween_to_full(_music_recess, _music_recess_linear_volume)
		Track.GAMEOVER:
			_tween_to_mute(_music_title, _music_main_linear_volume)
			_tween_to_mute(_music_main, _music_main_linear_volume)
			_tween_to_mute(_music_recess, _music_recess_linear_volume)
			_tween_to_mute(_music_results, _music_results_linear_volume)
			
			_tween_to_full(_music_gameover, _music_gameover_linear_volume)
			
			_tween.tween_interval(_music_gameover.stream.get_length() + 0.5)
			_tween.tween_callback(play_track.bind(Track.RESULTS))
		Track.RESULTS:
			_tween_to_mute(_music_title, _music_main_linear_volume)
			_tween_to_mute(_music_main, _music_main_linear_volume)
			_tween_to_mute(_music_recess, _music_recess_linear_volume)
			_tween_to_mute(_music_gameover, _music_gameover_linear_volume)
			
			_tween.tween_interval(0.5)
			_tween_to_full(_music_results, _music_results_linear_volume)
	
