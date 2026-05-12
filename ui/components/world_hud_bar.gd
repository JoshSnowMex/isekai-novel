extends PanelContainer
class_name WorldHudBar


var date_label: Label
var player_label: Label
var world_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(1, 64)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func build() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root: HBoxContainer = HBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 24)
	margin.add_child(root)

	date_label = make_hud_label()
	root.add_child(date_label)

	player_label = make_hud_label()
	root.add_child(player_label)

	world_label = make_hud_label()
	root.add_child(world_label)


func make_hud_label() -> Label:
	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func refresh() -> void:
	date_label.text = "Mes %s · Día %s · %s · %s" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		GameManager.get_time_label()
	]

	player_label.text = "Resistencia %s/%s · Dinero %s · Acciones %s" % [
		GameManager.player.get("stamina", 0),
		GameManager.player.get("max_stamina", 0),
		GameManager.player.get("money", 0),
		GameManager.get_actions_remaining()
	]

	world_label.text = "Tensión %s · Velo %s · Romance %s" % [
		GameManager.get_world_state_value("global_tension"),
		GameManager.get_world_state_value("world_instability"),
		GameManager.get_world_state_value("romantic_pressure")
	]
