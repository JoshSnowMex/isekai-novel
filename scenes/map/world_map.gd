extends Control


var hud_bar: WorldHudBar
var map_layer: Control
var location_layer: Control
var action_panel: WorldActionPanel
var hover_card: LocationHoverCard


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
		SceneRouter.go_to_journal()
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
	map_layer.add_child(hover_card)
	hover_card.set_intro()
	hover_card.visible = false


func layout_overlay_controls() -> void:
	layout_action_panel()


func layout_action_panel() -> void:
	var margin: float = 12.0
	var panel_size: Vector2 = action_panel.custom_minimum_size
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


func create_visual_location_button(location_id: String) -> void:
	var location_data: Dictionary = DataManager.get_location(location_id)
	var location_ui: Dictionary = DataManager.get_location_ui(location_id)

	var position_data: Dictionary = location_ui.get("position", {})
	var size_data: Dictionary = location_ui.get("size", {})

	var button: LocationMapButton = LocationMapButton.new()
	button.setup(
		location_id,
		str(location_data.get("name", location_id)),
		str(location_ui.get("accent", ""))
	)

	button.position = Vector2(
		float(position_data.get("x", 40)),
		float(position_data.get("y", 40))
	)

	button.custom_minimum_size = Vector2(
		float(size_data.get("x", 150)),
		float(size_data.get("y", 72))
	)

	button.size = button.custom_minimum_size

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
	position_hover_card_near_mouse()


func show_system_hover_message(title: String, description: String, hint: String) -> void:
	hover_card.title_label.text = title
	hover_card.description_label.text = description
	hover_card.npc_label.text = ""
	hover_card.hint_label.text = hint
	hover_card.visible = true
	position_hover_card_bottom_left()


func hide_hover_card() -> void:
	hover_card.visible = false


func position_hover_card_near_mouse() -> void:
	var margin: float = 12.0
	var mouse_position: Vector2 = map_layer.get_local_mouse_position()
	var card_size: Vector2 = hover_card.custom_minimum_size

	var target_position: Vector2 = mouse_position + Vector2(18, 18)

	if target_position.x + card_size.x > map_layer.size.x - margin:
		target_position.x = mouse_position.x - card_size.x - 18

	if target_position.y + card_size.y > map_layer.size.y - margin:
		target_position.y = mouse_position.y - card_size.y - 18

	target_position.x = clamp(target_position.x, margin, max(margin, map_layer.size.x - card_size.x - margin))
	target_position.y = clamp(target_position.y, margin, max(margin, map_layer.size.y - card_size.y - margin))

	hover_card.position = target_position
	hover_card.size = card_size


func position_hover_card_bottom_left() -> void:
	var margin: float = 12.0
	var card_size: Vector2 = hover_card.custom_minimum_size

	hover_card.position = Vector2(
		margin,
		max(margin, map_layer.size.y - card_size.y - margin)
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
			layout_overlay_controls()


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
