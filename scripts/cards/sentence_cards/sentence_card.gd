# I saw that CardNoun and CardVerb are essentially copies of each other
# so object oriented brain go brrrrrrrrrrr
## Base class for cards that must go into ad-libbed sentences
class_name SentenceCard
extends Card

@export var dollars : int
@export var time : int

# TODO: investigate a dynamic solution
@export_range(-1.0, 1.0, 0.01) var relevancy_immigration : float
@export_range(-1.0, 1.0, 0.01) var relevancy_tax : float
