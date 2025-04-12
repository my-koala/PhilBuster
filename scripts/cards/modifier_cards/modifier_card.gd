# I saw that CardAdjective and CardAdverb are essentially copies of each other
# so object oriented brain go brrrrrrrrrrr
## Base class for cards that modify the scoring of sentence cards
class_name ModifierCard
extends Card

@export var dollar_multiplier: float
@export var time_multiplier: float
@export var bust_multiplier: float
