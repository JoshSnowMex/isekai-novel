extends PanelContainer
class_name WorldHudBar


var date_label: Label
var player_label: Label
var world_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(1, 44)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func build() -> void:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	var root: HBoxContainer = HBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	date_label = make_hud_label(HORIZONTAL_ALIGNMENT_LEFT)
	root.add_child(date_label)

	player_label = make_hud_label(HORIZONTAL_ALIGNMENT_CENTER)
	root.add_child(player_label)

	world_label = make_hud_label(HORIZONTAL_ALIGNMENT_RIGHT)
	root.add_child(world_label)


func make_hud_label(alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	return label


func refresh() -> void:
	date_label.text = "Mes %s · Día %s · %s · %s" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		GameManager.get_time_label()
	]

	player_label.text = "Res %s/%s · Oro %s · Acc %s" % [
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
