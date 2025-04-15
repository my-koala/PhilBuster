@tool
class_name CardInfoBasic
extends CardInfo

## Base class for cards that must go into ad-libbed sentences

## Money reward for playing this card
@export
var reward: int = 1
## Amount of session time taken to say this word
@export
var time: int = 1

# TODO: investigate a dynamic solution
@export_range(-1.0, 1.0, 0.01)
var relevancy_immigration: float

@export_range(-1.0, 1.0, 0.01)
var relevancy_tax: float
