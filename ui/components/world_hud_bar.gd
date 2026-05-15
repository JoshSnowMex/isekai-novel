extends PanelContainer
class_name WorldHudBar


var date_label: Label
var player_label: Label
var world_label: Label


func _init() -> void:
	custom_minimum_size = Vector2(1, 52)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func build() -> void:
	add_theme_stylebox_override("panel", LuminariaTheme.make_hud_panel_style())
	
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	var root: HBoxContainer = HBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	date_label = make_hud_label(HORIZONTAL_ALIGNMENT_LEFT)
	date_label.size_flags_stretch_ratio = 1.35
	root.add_child(date_label)

	player_label = make_hud_label(HORIZONTAL_ALIGNMENT_CENTER)
	player_label.size_flags_stretch_ratio = 1.35
	root.add_child(player_label)

	world_label = make_hud_label(HORIZONTAL_ALIGNMENT_RIGHT)
	world_label.size_flags_stretch_ratio = 1.00
	root.add_child(world_label)

func make_hud_label(alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	LuminariaTheme.apply_hud_label(label, alignment)
	return label

func refresh() -> void:
	date_label.text = "Mes %s · Día %s · %s · %s" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		get_clock_label()
	]

	player_label.text = "Resistencia %s · %s Lúmenes · Acciones: %s" % [
		format_number(GameManager.player.get("stamina", 0)),
		format_number(GameManager.player.get("money", 0)),
		GameManager.get_actions_remaining()
	]

	world_label.text = "Tensión %s · Velo %s · Romance %s" % [
		GameManager.get_world_state_value("global_tension"),
		GameManager.get_world_state_value("world_instability"),
		GameManager.get_world_state_value("romantic_pressure")
	]

func get_clock_label() -> String:
	if GameManager.is_day_exhausted():
		return "Medianoche"

	var action_index: int = GameManager.current_action_index

	match GameManager.current_time_block:
		"morning":
			match action_index:
				0:
					return "08:00 · Mañana"
				1:
					return "10:00 · Mañana"
				_:
					return "Mañana"
		"afternoon":
			match action_index:
				0:
					return "12:00 · Tarde"
				1:
					return "15:00 · Tarde"
				2:
					return "18:00 · Tarde"
				_:
					return "Tarde"
		"night":
			match action_index:
				0:
					return "20:00 · Noche"
				1:
					return "22:00 · Noche"
				_:
					return "Noche"
		_:
			return GameManager.get_time_label()
			
func format_number(value: Variant) -> String:
	var number: float = float(value)

	if number == floor(number):
		return str(int(number))

	return "%.1f" % number
