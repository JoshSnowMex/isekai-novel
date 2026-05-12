extends PanelContainer
class_name WorldStatusPanel


var title_label: Label
var status_label: Label
var world_state_label: Label
var info_label: Label
var action_container: VBoxContainer


func _init() -> void:
	custom_minimum_size = Vector2(340, 1)
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func build() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	title_label = UIFactory.title("")
	root.add_child(title_label)

	status_label = UIFactory.body("")
	root.add_child(status_label)

	world_state_label = UIFactory.body("")
	root.add_child(world_state_label)

	var info_scroll: ScrollContainer = ScrollContainer.new()
	info_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	info_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(info_scroll)

	info_label = UIFactory.body("Elige una zona del mapa para viajar.")
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_scroll.add_child(info_label)

	action_container = VBoxContainer.new()
	action_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_container.add_theme_constant_override("separation", 8)
	root.add_child(action_container)


func set_header() -> void:
	title_label.text = "Mes %s · Día %s\n%s · %s" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		GameManager.get_time_label()
	]

	status_label.text = "Resistencia: %s/%s\nDinero: %s\nAcciones restantes: %s" % [
		GameManager.player.get("stamina", 0),
		GameManager.player.get("max_stamina", 0),
		GameManager.player.get("money", 0),
		GameManager.get_actions_remaining()
	]

	world_state_label.text = "Estado del mundo\nTensión: %s\nVelo: %s\nPresión romántica: %s" % [
		GameManager.get_world_state_value("global_tension"),
		GameManager.get_world_state_value("world_instability"),
		GameManager.get_world_state_value("romantic_pressure")
	]


func set_info(text: String) -> void:
	info_label.text = text


func clear_actions() -> void:
	for child in action_container.get_children():
		child.queue_free()


func add_action(button_text: String, callback: Callable) -> void:
	var button: Button = UIFactory.button(button_text)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	action_container.add_child(button)
