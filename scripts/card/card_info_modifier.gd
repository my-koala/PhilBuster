@tool
class_name CardInfoModifier
extends CardInfo

## Base class for cards that modify the scoring of sentence cards

@export_range(-8.0, 8.0, 0.001, "or_greater", "or_less")
var dollar_multiplier: float = 1.0:
	get:
		return dollar_multiplier
	set(value):
		dollar_multiplier = value

@export_range(-8.0, 8.0, 0.001, "or_greater", "or_less")
var time_multiplier: float = 1.0:
	get:
		return time_multiplier
	set(value):
		time_multiplier = value

@export_range(-8.0, 8.0, 0.001, "or_greater", "or_less")
var bust_multiplier: float = 1.0:
	get:
		return bust_multiplier
	set(value):
		bust_multiplier = value
