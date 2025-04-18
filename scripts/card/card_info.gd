@tool
class_name CardInfo
extends Resource

## Base class for all word cards.

## Amount of session time taken to say this word
@export
var time: int = 1

## Base shop price for this card
@export
var price: int = 1

## How many duplicates of this card to add into the global card pool
@export
var pool_count: int = 2

func get_word() -> String:
	return resource_path.get_file().get_basename().replace("_", " ")

static func get_color() -> Color:
	return Color.GRAY
