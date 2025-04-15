extends Control
class_name Background

@onready
var _phil_sit_idle: Texture2D = load("res://assets/phil/phil_p1_closed.png")
@onready
var _phil_sit_ready: Texture2D = load("res://assets/phil/phil_p1_open.png")

@onready
var _phil_stand_idle: Texture2D = load("res://assets/phil/phil_p2_neutral.png")
@onready
var _phil_stand_speak: Texture2D = load("res://assets/phil/phil_p2_speak.png")
@onready
var _phil_stand_good: Texture2D = load("res://assets/phil/phil_p2_good.png")
@onready
var _phil_stand_bad: Texture2D = load("res://assets/phil/phil_p2_mismatch.png")
@onready
var _phil_stand_busted: Texture2D = load("res://assets/phil/phil_p2_busted.png")

@onready
var _sitting_phil: TextureRect = $sitting_phil
@onready
var _standing_phil: TextureRect = $standing_phil

func reset_phil() -> void:
	_sitting_phil.visible = true
	_sitting_phil.texture = _phil_sit_idle
	_standing_phil.visible = false

func sentence_complete() -> void:
	_sitting_phil.visible = true
	_sitting_phil.texture = _phil_sit_ready
	_standing_phil.visible = false
	
	await get_tree().create_timer(1).timeout
	
	_sitting_phil.visible = false
	_standing_phil.visible = true
	_standing_phil.texture = _phil_stand_idle
	
	await get_tree().create_timer(0.5).timeout
	
	_standing_phil.texture = _phil_stand_speak

# TODO: Have phil shake horizontally (a little bit)
func bust_meter_increased() -> void:
	_sitting_phil.visible = false
	_standing_phil.visible = true
	
	_standing_phil.texture = _phil_stand_bad

# "Good card" can be defined by modifiers/basic cards resulting in a high reward / time / relevant card
# TODO: Teeth twinkle(?), SFX
func good_card_played() -> void:
	_sitting_phil.visible = false
	_standing_phil.visible = true
	
	# Intentionally having bust texture take priority
	if _standing_phil.texture == _phil_stand_bad:
		return
	
	_standing_phil.texture = _phil_stand_good

# TODO: Have phil shake horizontally (a lot) 
func busted() -> void:
	_sitting_phil.visible = false
	_standing_phil.visible = true
	_standing_phil.texture = _phil_stand_busted
	
	await get_tree().create_timer(2).timeout

func finished_speaking() -> void:
	# Intentionally having other textures take priority
	if _standing_phil.texture == _phil_stand_speak:
		_standing_phil.texture = _phil_stand_idle
	
	await get_tree().create_timer(1).timeout
	reset_phil()

func _ready() -> void:
	reset_phil()
