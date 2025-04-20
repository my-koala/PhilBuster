@tool
extends Control
class_name BustMeter

# TODO:
# draw ticks for every 5 ticks ish?

const SIZE_MAX: float = 512.0
const SIZE_MIN: float = 96.0
const SIZE_UNIT: float = 8.0

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

@onready
var _progress_bar: ProgressBar = %progress_bar as ProgressBar
@onready
var _nine_patch_rect: NinePatchRect = %nine_patch_rect as NinePatchRect
@onready
var _blade: TextureRect = %blade as TextureRect
@onready
var _label_count: Label = %label_count as Label

var _bust: int = 0

func is_full() -> bool:
	return _bust >= bust_max

func add_bust(bust: int) -> void:
	_bust = mini(_bust + bust, bust_max)

func remove_bust(bust: int) -> void:
	_bust = maxi(_bust - maxi(bust, 0), 0)

func clear_bust() -> void:
	_bust = 0

func _process(delta: float) -> void:
	var minimum_size_y: float = clampf(SIZE_UNIT * float(bust_max), SIZE_MIN, SIZE_MAX)
	_nine_patch_rect.custom_minimum_size.y = minimum_size_y
	#_progress_bar.custom_minimum_size.y = move_toward(_progress_bar.size.y, progress_bar_size_y, delta * progress_bar_speed)
	_progress_bar.max_value = bust_max
	_progress_bar.value = move_toward(_progress_bar.value, float(_bust), delta * progress_bar_speed)
	_blade.position.y = clampf(move_toward(_blade.position.y, lerpf(_progress_bar.size.y, 0.0, float(_bust) / float(bust_max)), delta * progress_bar_speed), 0.0, _progress_bar.size.y)
	
	_label_count.text = "%d/%d" % [_bust, bust_max]

var _play_animation: bool = false

func play_animation() -> void:
	_play_animation = true

func stop_animation() -> void:
	_play_animation = false
