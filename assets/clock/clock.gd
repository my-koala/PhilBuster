extends Node

@onready var hour_hand: TextureRect = $hour_hand
@onready var minute_hand: TextureRect = $minute_hand

var total_minutes: int = 0
var minute_degrees_per_minute: int = 360.0 / 60.0
var hour_degrees_per_hour: int = 360.0 / 12.0

func _process(delta: float) -> void:
	# Test lines to see if it works
	#total_minutes += 1
	#update_clock_hands()
	pass

# Function to manually add time
func add_time(minutes_to_add: int) -> void:
	total_minutes += minutes_to_add
	update_clock_hands()
	
var target_minute_angle: float = 0
var target_hour_angle: float = 0
var lerp_speed: float = 0.1

func update_clock_hands() -> void:
	# Calculate where we want the hand to be at the end of the updates.
	target_minute_angle = (total_minutes % 60) * minute_degrees_per_minute
	target_hour_angle = (total_minutes / 60 % 12) * hour_degrees_per_hour
	
	# Lerp the rotation until it gets there.
	minute_hand.rotation = lerp_angle(minute_hand.rotation, deg_to_rad(target_minute_angle), lerp_speed)
	hour_hand.rotation = lerp_angle(hour_hand.rotation, deg_to_rad(target_hour_angle), lerp_speed)
	
func set_time(hour: int, minute: int) -> void:
	hour = clamp(hour, 0, 11)
	minute = clamp(minute, 0, 59)

	total_minutes = (hour * 60) + minute

	# Update the target angles
	target_minute_angle = minute * minute_degrees_per_minute
	target_hour_angle = (hour % 12) * hour_degrees_per_hour

	# Lerp the rotation until it gets there.
	minute_hand.rotation = lerp_angle(minute_hand.rotation, deg_to_rad(target_minute_angle), lerp_speed)
	hour_hand.rotation = lerp_angle(hour_hand.rotation, deg_to_rad(target_hour_angle), lerp_speed)
