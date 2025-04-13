extends Control
class_name MenuView

signal on_menu_show()
signal on_menu_hide()

var _active_tween: Tween = null

var _active_scale: Vector2 = Vector2.ONE
var _active_position: Vector2 = Vector2.ZERO
var _active_modulate: Color = Color.WHITE

var _inactive_scale: Vector2 = Vector2(0.75, 0.75)
var _inactive_position: Vector2 = Vector2(-1920, 0)
var _inactive_modulate: Color = Color(1, 1, 1, 0.5)

func show_menu(duration: float = 0.15) -> Tween:
	_cancel_tween()
	
	scale = _inactive_scale
	position = _inactive_position
	modulate = _inactive_modulate
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_callback(func() -> void: self.visible = true)
	tween.tween_property(self, "position", _active_position, duration)
	tween.tween_property(self, "scale", _active_scale, duration)
	tween.parallel().tween_property(self, "modulate", _active_modulate, duration)
	tween.tween_callback(func() -> void: on_menu_show.emit())

	tween.play()
	return tween

func hide_menu(duration: float = 0.15) -> Tween:
	_cancel_tween()
	
	scale = _active_scale
	position = _active_position
	modulate = _active_modulate
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", _inactive_scale, duration)
	tween.parallel().tween_property(self, "modulate", _inactive_modulate, duration)
	tween.tween_property(self, "position", _inactive_position, duration)
	tween.tween_callback(func() -> void: self.visible = false)
	tween.tween_callback(func() -> void: on_menu_hide.emit())

	tween.play()
	return tween

func _cancel_tween() -> void:
	if !is_instance_valid(_active_tween):
		return
	
	# I still need the callback signals to trigger so..... :3
	_active_tween.set_speed_scale(10000)
	await _active_tween.finished
	_active_tween = null

func _ready() -> void:
	visible = false
