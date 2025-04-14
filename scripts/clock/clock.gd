@tool
extends Control
class_name Clock

const MINUTES_PER_HOUR: int = 60
const HOURS_PER_DAY: int = 12

signal time_exceeded()

@export_range(0, MINUTES_PER_HOUR * HOURS_PER_DAY, 1)
var time_region_start: int = MINUTES_PER_HOUR * 1:
	get:
		return time_region_start
	set(value):
		time_region_start = clampi(value, 0, MINUTES_PER_HOUR * HOURS_PER_DAY)

@export_range(0, MINUTES_PER_HOUR * HOURS_PER_DAY, 1)
var time_region_duration: int = MINUTES_PER_HOUR * 2:
	get:
		return time_region_duration
	set(value):
		time_region_duration = clampi(value, 0, MINUTES_PER_HOUR * HOURS_PER_DAY)

@export_range(0, MINUTES_PER_HOUR * HOURS_PER_DAY, 1)
var time_passed: int = 0:
	get:
		return time_passed
	set(value):
		time_passed = clampi(value, 0, MINUTES_PER_HOUR * HOURS_PER_DAY)

@export_range(0.0, 16.0, 0.001, "or_greater")
var hand_rotation_speed: float = 1.0:
	get:
		return hand_rotation_speed
	set(value):
		hand_rotation_speed = maxf(value, 0.0)

@onready var _hour_hand: TextureRect = %hour_hand as TextureRect
@onready var _minute_hand: TextureRect = %minute_hand as TextureRect
@onready var _texture_progress_bar: TextureProgressBar = %texture_progress_bar as TextureProgressBar

func add_time(time: int) -> void:
	time_passed += time
	if time_passed >= time_region_duration:
		time_exceeded.emit()

func _process(delta: float) -> void:
	# Update clock hands.
	# Lerp the rotation until it gets there.
	var minute_hand_target: float = float((time_passed + time_region_start) % MINUTES_PER_HOUR) / float(MINUTES_PER_HOUR) * TAU
	_minute_hand.rotation = lerp_angle(_minute_hand.rotation, minute_hand_target, hand_rotation_speed * delta)
	
	var hour_hand_target: float = (float(time_passed + time_region_start) / float(MINUTES_PER_HOUR)) / HOURS_PER_DAY * TAU
	_hour_hand.rotation = lerp_angle(_hour_hand.rotation, hour_hand_target, hand_rotation_speed * delta)
	
	# Update progress bars.
	var radial_initial_angle: float = (float(time_region_start) / float(MINUTES_PER_HOUR)) / HOURS_PER_DAY * TAU
	var radial_fill_angle: float = (float(time_region_duration) / float(MINUTES_PER_HOUR)) / HOURS_PER_DAY * TAU
	
	_texture_progress_bar.radial_initial_angle = rad_to_deg(radial_initial_angle + radial_fill_angle)
	_texture_progress_bar.radial_fill_degrees = rad_to_deg(radial_fill_angle)
	
	var texture_progress_bar_target: float = 1.0 - clampf(float(time_passed) / float(time_region_duration), 0.0, 1.0)
	_texture_progress_bar.value = lerpf(_texture_progress_bar.value, texture_progress_bar_target, hand_rotation_speed * delta)

func set_time(hour: int, minute: int) -> void:
	#hour = clamp(hour, 0, 11)
	#minute = clamp(minute, 0, 59)
	pass
	#total_minutes = (hour * 60) + minute

func update_progress_bar() -> void:
	#var progress: float = (hour_hand.rotation / deg_to_rad(360))
	#progress_bar.value = progress * progress_bar.max_value
	pass
