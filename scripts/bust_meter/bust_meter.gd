@tool
extends Control
class_name BustMeter

# TODO:
# draw ticks for every 5 ticks ish?

const PROGRESS_BAR_SIZE_MAX: float = 256.0
const PROGRESS_BAR_SIZE_MIN: float = 1.0
const PROGRESS_BAR_BUST_UNIT: float = 32.0

signal busted()

@export_range(0.0, 1024.0, 1.0, "or_greater")
var progress_bar_speed: float = 256.0:
	get:
		return progress_bar_speed
	set(value):
		progress_bar_speed = maxf(value, 0.0)

@export_range(0, 256, 1, "or_greater")
var bust_max: int = 64:
	get:
		return bust_max
	set(value):
		bust_max = maxi(value, 0)
		if _bust >= bust_max:
			busted.emit()

@onready
var _progress_bar: ProgressBar = %progress_bar as ProgressBar

var _bust: int = 0

func add_bust(bust: int) -> void:
	_bust += bust
	if _bust >= bust_max:
		busted.emit()

func remove_bust(bust: int) -> void:
	_bust = maxi(_bust - maxi(bust, 0), 0)

func clear_bust() -> void:
	_bust = 0

func _process(delta: float) -> void:
	var progress_bar_size_y: float = clampf(PROGRESS_BAR_BUST_UNIT * float(bust_max), PROGRESS_BAR_SIZE_MIN, PROGRESS_BAR_SIZE_MAX)
	_progress_bar.custom_minimum_size.y = move_toward(_progress_bar.size.y, progress_bar_size_y, delta * progress_bar_speed)
	_progress_bar.max_value = bust_max
	_progress_bar.value = move_toward(_progress_bar.value, float(_bust), delta * progress_bar_speed)
