extends Control
class_name WorldActionPanel


var action_container: HBoxContainer
var panel_texture: TextureRect


func _init() -> void:
	custom_minimum_size = Vector2(420, 60)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_PASS


func build() -> void:
	custom_minimum_size = Vector2(420, 60)
	size = custom_minimum_size

	panel_texture = TextureRect.new()
	panel_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_texture.offset_left = 0
	panel_texture.offset_top = 0
	panel_texture.offset_right = 0
	panel_texture.offset_bottom = 0
	panel_texture.texture = get_top_nav_panel_texture()
	panel_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel_texture.stretch_mode = TextureRect.STRETCH_SCALE
	panel_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel_texture)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 11)
	add_child(margin)

	action_container = HBoxContainer.new()
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 10)
	action_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(action_container)


func get_top_nav_panel_texture() -> Texture2D:
	var world_map_ui: Dictionary = DataManager.get_world_map_ui()
	var path: String = str(world_map_ui.get("top_nav_panel", "res://assets/ui/world_top_nav_panel.png"))

	if ResourceLoader.exists(path):
		return load(path)

	return null


func clear_actions() -> void:
	for child in action_container.get_children():
		child.queue_free()


func add_action(button_text: String, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = button_text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(84, 38)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(callback)

	LuminariaTheme.apply_flat_nav_text_button(button)

	action_container.add_child(button)
