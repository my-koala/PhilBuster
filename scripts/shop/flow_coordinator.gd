@tool
extends Control
class_name FlowCoordinator

@export
var root_view: MenuView

@export
var back_button: Button

var _view_stack: Array[MenuView]
var _current_view: MenuView

var _all_views: Dictionary[String, MenuView]

# Needed to be compatible with Godot editor signals (dont take node references)
func push_view_by_name(view_name: String) -> void:
	var search_result: MenuView = _all_views.get(view_name)
	if (!is_instance_valid(search_result)):
		return
	
	push_view(search_result)

func push_view(view: MenuView) -> void:
	if is_instance_valid(_current_view):
		var current: MenuView = _current_view
		
		await current.hide_menu().finished
		_view_stack.append(current)
	
	_current_view = view
	back_button.visible = _current_view != root_view
	await view.show_menu().finished

func pop_view() -> void:
	var last_view: MenuView = root_view if _view_stack.size() == 0 else _view_stack.pop_back()
	
	await _current_view.hide_menu().finished
	_current_view = last_view
	
	back_button.visible = _current_view != root_view
	await last_view.show_menu().finished

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# god why doesnt Godot have an easy GetComponentsInChildren<T>
	for child: Control in get_children():
		if is_instance_of(child, MenuView):
			_all_views[child.name] = child
			child.visible = false
	
	back_button.visible = false
	back_button.pressed.connect(_on_back_button_pressed)
	push_view(root_view)

func _on_back_button_pressed() -> void:
	if Engine.is_editor_hint():
		return
	
	pop_view()
