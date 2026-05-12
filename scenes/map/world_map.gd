extends Control


var map_layer: Control
var location_layer: Control
var fallback_location_container: VBoxContainer
var status_panel: WorldStatusPanel
var selected_location_id: String = ""


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_screen()
	show_pending_narrative_messages()


func build_ui() -> void:
	var root: HBoxContainer = HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0
	root.add_theme_constant_override("separation", 12)
	add_child(root)

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
	build_fallback_location_list()

	status_panel = WorldStatusPanel.new()
	status_panel.build()
	root.add_child(status_panel)

	build_panel_actions()


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


func build_fallback_location_list() -> void:
	var fallback_panel: PanelContainer = PanelContainer.new()
	fallback_panel.anchor_left = 0.02
	fallback_panel.anchor_top = 0.02
	fallback_panel.anchor_right = 0.32
	fallback_panel.anchor_bottom = 0.98
	fallback_panel.offset_left = 0
	fallback_panel.offset_top = 0
	fallback_panel.offset_right = 0
	fallback_panel.offset_bottom = 0
	map_layer.add_child(fallback_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	fallback_panel.add_child(margin)

	var root: VBoxContainer = VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 6)
	margin.add_child(root)

	var label: Label = UIFactory.body("Ubicaciones")
	root.add_child(label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(scroll)

	fallback_location_container = VBoxContainer.new()
	fallback_location_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fallback_location_container.add_theme_constant_override("separation", 6)
	scroll.add_child(fallback_location_container)


func build_panel_actions() -> void:
	status_panel.clear_actions()

	status_panel.add_action("Entrar a ubicación", func():
		if selected_location_id != "":
			visit_location(selected_location_id)
	)

	status_panel.add_action("Casa del Forastero", func():
		visit_location("home")
	)

	status_panel.add_action("Bitácora", func():
		SceneRouter.go_to_journal()
	)

	status_panel.add_action("Guardar partida", func():
		SaveManager.save_game()
		status_panel.set_info("Partida guardada manualmente.")
	)

	status_panel.add_action("Volver al menú", func():
		SceneRouter.go_to_main_menu()
	)


func refresh_screen() -> void:
	status_panel.set_header()
	rebuild_locations()

	if selected_location_id == "":
		status_panel.set_info(build_world_intro_text())
	else:
		status_panel.set_info(build_location_info_text(selected_location_id))


func rebuild_locations() -> void:
	for child in location_layer.get_children():
		child.queue_free()

	for child in fallback_location_container.get_children():
		child.queue_free()

	for location_id in DataManager.locations.keys():
		create_visual_location_button(str(location_id))
		create_fallback_location_button(str(location_id))


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
	button.pressed.connect(func(): select_location(location_id))
	location_layer.add_child(button)


func create_fallback_location_button(location_id: String) -> void:
	var location_data: Dictionary = DataManager.get_location(location_id)
	var button: Button = UIFactory.button(str(location_data.get("name", location_id)))
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func(): select_location(location_id))
	fallback_location_container.add_child(button)


func select_location(location_id: String) -> void:
	selected_location_id = location_id
	status_panel.set_info(build_location_info_text(location_id))


func build_world_intro_text() -> String:
	var text: String = "Mapa de Luminaria\n\n"
	text += "Selecciona una ubicación del mapa para ver sus detalles o entrar.\n\n"
	text += "Los marcadores actuales son placeholders funcionales con nombres definitivos. Cuando existan los assets finales, se reemplazarán por edificios y zonas clicables sin cambiar el gameplay."

	return text


func build_location_info_text(location_id: String) -> String:
	var location_data: Dictionary = DataManager.get_location(location_id)
	var location_ui: Dictionary = DataManager.get_location_ui(location_id)

	var text: String = "%s\n\n" % location_data.get("name", location_id)
	text += "%s\n\n" % location_data.get("description", "")

	text += "Asset previsto:\n"
	text += "- Mapa: %s\n" % str(location_ui.get("map_icon", "sin asignar"))
	text += "- Fondo: %s\n\n" % str(location_ui.get("background", "sin asignar"))

	var present_npcs: Array = get_present_npcs_for_location(location_id)

	if present_npcs.is_empty():
		text += "Personajes presentes:\n- Nadie visible en este momento.\n"
	else:
		text += "Personajes presentes:\n"

		for npc_id in present_npcs:
			var npc: Dictionary = DataManager.get_npc(str(npc_id))
			text += "- %s\n" % npc.get("name", npc_id)

	if location_id == "home":
		text += "\nLa Casa del Forastero permite descansar, dormir, guardar y gestionar decisiones íntimas."

	return text


func get_present_npcs_for_location(location_id: String) -> Array:
	var result: Array = []

	for npc_id in DataManager.npcs.keys():
		var npc: Dictionary = DataManager.get_npc(str(npc_id))
		var schedule: Dictionary = npc.get("schedule", {})
		var current_location: String = str(schedule.get(GameManager.current_time_block, ""))

		if current_location == location_id:
			result.append(str(npc_id))

	return result


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

	status_panel.set_info(combined_text.strip_edges())
	SaveManager.autosave_game()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return "El Velo se agita\n\n%s" % str(message)


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
