@tool
extends Control
class_name FlyoutSpawner

const FLYOUT_TEXT: PackedScene = preload("res://assets/flyout/flyout.tscn")

var _container: Container

func spawn_flyout(text: String, modulate: Color) -> void:
	var flyout: Label = FLYOUT_TEXT.instantiate()
	flyout.text = text
	flyout.modulate = modulate
	_container.add_child(flyout)
	
	var zero_alpha: Color = modulate
	zero_alpha.a = 0
	
	var flyout_tween: Tween = get_tree().create_tween()
	flyout_tween.set_trans(Tween.TRANS_SINE)
	flyout_tween.set_ease(Tween.EASE_OUT)
	flyout_tween.tween_property(flyout, "modulate", zero_alpha, 1.5)
	flyout_tween.play()
	
	await flyout_tween.finished
	
	flyout.queue_free()

func _ready() -> void:
	_container = _get_container_object()
	if !is_instance_valid(_container):
		assert(false, "why is no container child??? i punt you i punt you")

func _get_container_object() -> Container:
	for node: Node in get_children():
		if is_instance_of(node, Container):
			return node as Container
	return null

func _get_configuration_warnings() -> PackedStringArray:
	if !is_instance_valid(_get_container_object()):
		return ["dumbass you need a container object here (HBox or VBox please)"]
	return []
