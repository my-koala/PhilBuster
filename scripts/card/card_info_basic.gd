@tool
class_name CardInfoBasic
extends CardInfo

## Base class for cards that must go into ad-libbed sentences

@export
var dollars: int = 1
@export
var time: int = 1

# TODO: investigate a dynamic solution
@export_range(-1.0, 1.0, 0.01)
var relevancy_immigration: float

@export_range(-1.0, 1.0, 0.01)
var relevancy_tax: float
