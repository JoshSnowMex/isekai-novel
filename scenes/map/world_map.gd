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
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	hud_bar = WorldHudBar.new()
	hud_bar.build()
	root.add_child(hud_bar)

	var map_frame: PanelContainer = PanelContainer.new()
	map_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(map_frame)

	var map_margin: MarginContainer = MarginContainer.new()
	map_margin.add_theme_constant_override("margin_left", 10)
	map_margin.add_theme_constant_override("margin_top", 10)
	map_margin.add_theme_constant_override("margin_right", 10)
	map_margin.add_theme_constant_override("margin_bottom", 10)
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
	action_panel.position = Vector2(880, 24)
	map_layer.add_child(action_panel)

	action_panel.clear_actions()

	action_panel.add_action("Bitácora", func():
		SceneRouter.go_to_journal()
	)

	action_panel.add_action("Guardar", func():
		SaveManager.save_game()
		hover_card.title_label.text = "Partida guardada"
		hover_card.description_label.text = "El progreso fue guardado manualmente."
		hover_card.npc_label.text = ""
		hover_card.hint_label.text = "Puedes continuar explorando Luminaria."
	)

	action_panel.add_action("Menú", func():
		SceneRouter.go_to_main_menu()
	)


func build_hover_card() -> void:
	hover_card = LocationHoverCard.new()
	hover_card.build()
	hover_card.position = Vector2(24, 510)
	map_layer.add_child(hover_card)
	hover_card.set_intro()


func refresh_screen() -> void:
	hud_bar.refresh()
	rebuild_locations()
	hover_card.set_intro()


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
		float(size_data.get("x", 170)),
		float(size_data.get("y", 86))
	)

	button.size = button.custom_minimum_size

	button.mouse_entered.connect(func():
		hover_card.set_location(location_id)
	)

	button.focus_entered.connect(func():
		hover_card.set_location(location_id)
	)

	button.pressed.connect(func():
		visit_location(location_id)
	)

	location_layer.add_child(button)


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

	hover_card.title_label.text = "El Velo se agita"
	hover_card.description_label.text = combined_text.strip_edges()
	hover_card.npc_label.text = ""
	hover_card.hint_label.text = "Continúa explorando para ver cómo responde el mundo."

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


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
