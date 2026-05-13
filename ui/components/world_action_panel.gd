extends PanelContainer
class_name WorldActionPanel


var action_container: HBoxContainer


func _init() -> void:
	custom_minimum_size = Vector2(420, 46)
	size = custom_minimum_size


func build() -> void:
	custom_minimum_size = Vector2(420, 46)
	size = custom_minimum_size

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	add_child(margin)

	action_container = HBoxContainer.new()
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 8)
	action_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(action_container)


func clear_actions() -> void:
	for child in action_container.get_children():
		child.queue_free()


func add_action(button_text: String, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = button_text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(82, 34)
	button.pressed.connect(callback)
	action_container.add_child(button)
