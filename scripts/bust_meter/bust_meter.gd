@tool
extends Control
class_name BustMeter

const PROGRESS_BAR_SIZE_MAX: float = 314.0
const PROGRESS_BAR_SIZE_MIN: float = 64.0
const PROGRESS_BAR_BUST_UNIT: float = 16.0
const PROGRESS_BAR_SPEED: float = 64.0

signal busted()

@onready
var _progress_bar: ProgressBar = %progress_bar as ProgressBar

var _bust: int = 0
var _bust_max: int = 64

func set_bust_max(bust_max: int) -> void:
	_bust_max = maxi(bust_max, 0)
	_bust = mini(_bust, _bust_max)
	
	if _bust == _bust_max:
		busted.emit()

func add_bust(bust: int) -> void:
	_bust = mini(_bust + maxi(bust, 0), _bust_max)
	
	if _bust == _bust_max:
		busted.emit()

func remove_bust(bust: int) -> void:
	_bust = maxi(_bust - maxi(bust, 0), 0)

func clear_bust() -> void:
	_bust = 0

func _process(delta: float) -> void:
	var progress_bar_size_y: float = clampf(PROGRESS_BAR_BUST_UNIT * float(_bust_max), PROGRESS_BAR_SIZE_MIN, PROGRESS_BAR_SIZE_MAX)
	_progress_bar.custom_minimum_size.y = move_toward(_progress_bar.size.y, progress_bar_size_y, delta * PROGRESS_BAR_SPEED)
	_progress_bar.max_value = _bust_max
	_progress_bar.value = move_toward(_progress_bar.value, float(_bust), delta * PROGRESS_BAR_SPEED)
