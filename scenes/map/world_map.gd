extends Control


var hud_bar: WorldHudBar
var map_layer: Control
var location_layer: Control
var action_panel: WorldActionPanel
var hover_card: LocationHoverCard

const BASE_MAP_SIZE := Vector2(1050.0, 540.0)

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_screen()
	show_pending_narrative_messages()


func build_ui() -> void:
	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	hud_bar = WorldHudBar.new()
	hud_bar.build()
	root.add_child(hud_bar)

	var map_frame: PanelContainer = PanelContainer.new()
	map_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(map_frame)

	var map_margin: MarginContainer = MarginContainer.new()
	map_margin.add_theme_constant_override("margin_left", 6)
	map_margin.add_theme_constant_override("margin_top", 6)
	map_margin.add_theme_constant_override("margin_right", 6)
	map_margin.add_theme_constant_override("margin_bottom", 6)
	map_frame.add_child(map_margin)

	map_layer = Control.new()
	map_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_layer.clip_contents = true
	map_margin.add_child(map_layer)

	build_map_background()
	build_location_layer()
	build_action_panel()
	build_hover_card()

	call_deferred("layout_overlay_controls")
	call_deferred("refresh_overlay_layout_after_frame")


func build_map_background() -> void:
	var world_map_ui: Dictionary = DataManager.get_world_map_ui()
	var background_path: String = str(world_map_ui.get("background", ""))
	var fallback_title: String = str(world_map_ui.get("fallback_title", "Mapa de Luminaria"))

	var background: Control = VisualAsset.make_texture_or_placeholder(
		background_path,
		fallback_title,
		"Fondo final: world_map_luminaria.png"
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	map_layer.add_child(background)


func build_location_layer() -> void:
	location_layer = Control.new()
	location_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	location_layer.offset_left = 0
	location_layer.offset_top = 0
	location_layer.offset_right = 0
	location_layer.offset_bottom = 0
	map_layer.add_child(location_layer)


func build_action_panel() -> void:
	action_panel = WorldActionPanel.new()
	action_panel.build()
	map_layer.add_child(action_panel)

	action_panel.clear_actions()

	action_panel.add_action("Bitácora", func():
		SceneRouter.go_to_journal(SceneRouter.WORLD_MAP)
	)

	action_panel.add_action("Guardar", func():
		SaveManager.save_game()
		show_system_hover_message(
			"Partida guardada",
			"El progreso fue guardado manualmente.",
			"Puedes continuar explorando Luminaria."
		)
	)

	action_panel.add_action("Menú", func():
		SceneRouter.go_to_main_menu()
	)


func build_hover_card() -> void:
	hover_card = LocationHoverCard.new()
	hover_card.build()
	hover_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_layer.add_child(hover_card)
	hover_card.set_intro()
	hover_card.visible = false


func layout_overlay_controls() -> void:
	layout_action_panel()

	if hover_card != null and hover_card.visible:
		position_hover_card_bottom_left()

func refresh_overlay_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()
	rebuild_locations()

func layout_action_panel() -> void:
	var margin: float = 10.0
	var panel_size: Vector2 = action_panel.custom_minimum_size

	if map_layer.size.x < 900:
		panel_size = Vector2(132, 108)

	var x: float = max(margin, map_layer.size.x - panel_size.x - margin)
	var y: float = margin

	action_panel.position = Vector2(x, y)
	action_panel.size = panel_size


func refresh_screen() -> void:
	hud_bar.refresh()
	rebuild_locations()
	hover_card.visible = false
	call_deferred("layout_overlay_controls")


func rebuild_locations() -> void:
	for child in location_layer.get_children():
		child.queue_free()

	for location_id in DataManager.locations.keys():
		create_visual_location_button(str(location_id))

func get_map_scale() -> float:
	var safe_width: float = max(map_layer.size.x, 1.0)
	var safe_height: float = max(map_layer.size.y, 1.0)

	var scale_x: float = safe_width / BASE_MAP_SIZE.x
	var scale_y: float = safe_height / BASE_MAP_SIZE.y

	return min(scale_x, scale_y)


func scale_map_vector(value: Vector2) -> Vector2:
	var scale_value: float = get_map_scale()

	return Vector2(
		value.x * scale_value,
		value.y * scale_value
	)


func get_map_content_offset() -> Vector2:
	var scale_value: float = get_map_scale()
	var content_size: Vector2 = BASE_MAP_SIZE * scale_value

	return Vector2(
		max((map_layer.size.x - content_size.x) * 0.5, 0.0),
		max((map_layer.size.y - content_size.y) * 0.5, 0.0)
	)


func clamp_location_position(position_value: Vector2, button_size: Vector2) -> Vector2:
	var margin: float = 6.0

	var max_x: float = max(margin, map_layer.size.x - button_size.x - margin)
	var max_y: float = max(margin, map_layer.size.y - button_size.y - margin)

	return Vector2(
		clamp(position_value.x, margin, max_x),
		clamp(position_value.y, margin, max_y)
	)
	
func create_visual_location_button(location_id: String) -> void:
	var location_data: Dictionary = DataManager.get_location(location_id)
	var location_ui: Dictionary = DataManager.get_location_ui(location_id)

	var position_data: Dictionary = location_ui.get("position", {})
	var size_data: Dictionary = location_ui.get("size", {})

	var base_position: Vector2 = Vector2(
		float(position_data.get("x", 40)),
		float(position_data.get("y", 40))
	)

	var base_size: Vector2 = Vector2(
		float(size_data.get("x", 92)),
		float(size_data.get("y", 92))
	)

	var content_offset: Vector2 = get_map_content_offset()
	var scaled_position: Vector2 = content_offset + scale_map_vector(base_position)
	var scaled_size: Vector2 = scale_map_vector(base_size)

	var min_button_side: float = 38.0

	if map_layer.size.x >= 900:
		min_button_side = 52.0
	elif map_layer.size.x >= 700:
		min_button_side = 44.0

	scaled_size.x = max(scaled_size.x, min_button_side)
	scaled_size.y = max(scaled_size.y, min_button_side)

	var button: LocationMapButton = LocationMapButton.new()
	button.setup(
		location_id,
		str(location_data.get("name", location_id)),
		str(location_ui.get("accent", ""))
	)

	button.position = clamp_location_position(scaled_position, scaled_size)
	button.custom_minimum_size = scaled_size
	button.size = scaled_size

	button.mouse_entered.connect(func():
		show_location_hover(location_id)
	)

	button.mouse_exited.connect(func():
		hide_hover_card()
	)

	button.focus_entered.connect(func():
		show_location_hover(location_id)
	)

	button.focus_exited.connect(func():
		hide_hover_card()
	)

	button.pressed.connect(func():
		visit_location(location_id)
	)

	location_layer.add_child(button)
	
func show_location_hover(location_id: String) -> void:
	hover_card.set_location(location_id)
	hover_card.visible = true
	position_hover_card_bottom_left()


func show_system_hover_message(title: String, description: String, hint: String) -> void:
	hover_card.title_label.text = title
	hover_card.description_label.text = description
	hover_card.npc_label.text = ""
	hover_card.hint_label.text = hint
	hover_card.visible = true
	position_hover_card_bottom_left()


func hide_hover_card() -> void:
	hover_card.visible = false


func position_hover_card_bottom_left() -> void:
	var margin: float = 12.0
	var bottom_safe_margin: float = 42.0
	var card_size: Vector2 = hover_card.custom_minimum_size

	if map_layer.size.x < 760:
		card_size = Vector2(360, 104)

	var y_position: float = map_layer.size.y - card_size.y - bottom_safe_margin

	if y_position < margin:
		y_position = margin

	hover_card.position = Vector2(
		margin,
		y_position
	)

	hover_card.size = card_size


func visit_location(location_id: String) -> void:
	GameManager.current_location_id = location_id

	if location_id == "home":
		SceneRouter.go_to_home()
		return

	SceneRouter.go_to_location()


func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	show_system_hover_message(
		"El Velo se agita",
		combined_text.strip_edges(),
		"Continúa explorando para ver cómo responde el mundo."
	)

	SaveManager.autosave_game()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return str(message)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if action_panel != null and map_layer != null:
			call_deferred("refresh_overlay_layout_after_frame")

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
