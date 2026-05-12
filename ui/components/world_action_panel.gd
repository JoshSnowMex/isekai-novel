extends PanelContainer
class_name WorldActionPanel


var action_container: VBoxContainer


func _init() -> void:
	custom_minimum_size = Vector2(150, 118)
	size = custom_minimum_size


func build() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	action_container = VBoxContainer.new()
	action_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_container.add_theme_constant_override("separation", 6)
	margin.add_child(action_container)


func clear_actions() -> void:
	for child in action_container.get_children():
		child.queue_free()


func add_action(button_text: String, callback: Callable) -> void:
	var button: Button = UIFactory.button(button_text)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 28)
	button.pressed.connect(callback)
	action_container.add_child(button)
