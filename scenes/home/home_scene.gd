extends Control


var hud_bar: WorldHudBar
var home_frame: PanelContainer
var home_layer: Control
var background_layer: Control

var global_action_panel: PanelContainer
var global_action_buttons: HBoxContainer

var main_panel: PanelContainer
var main_title_label: Label
var main_description_scroll: ScrollContainer
var main_description_label: Label
var main_actions: HBoxContainer

var side_panel: PanelContainer
var side_title_label: Label
var side_description_scroll: ScrollContainer
var side_description_label: Label
var side_actions: VBoxContainer

var current_message: String = ""

const BASE_HOME_SIZE := Vector2(1050.0, 540.0)


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_home()
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

	home_frame = PanelContainer.new()
	home_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(home_frame)

	var frame_margin: MarginContainer = MarginContainer.new()
	frame_margin.add_theme_constant_override("margin_left", 6)
	frame_margin.add_theme_constant_override("margin_top", 6)
	frame_margin.add_theme_constant_override("margin_right", 6)
	frame_margin.add_theme_constant_override("margin_bottom", 6)
	home_frame.add_child(frame_margin)

	home_layer = Control.new()
	home_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	home_layer.clip_contents = true
	frame_margin.add_child(home_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	home_layer.add_child(background_layer)

	build_background()
	build_global_action_panel()
	build_main_panel()
	build_side_panel()

	call_deferred("refresh_layout_after_frame")


func build_background() -> void:
	clear_children(background_layer)

	var location_data: Dictionary = DataManager.get_location("home")
	var location_ui: Dictionary = DataManager.get_location_ui("home")

	var background_path: String = str(location_ui.get("background", ""))
	var fallback_title: String = str(location_data.get("name", "Casa del Forastero"))
	var final_asset_name: String = background_path.get_file()

	if final_asset_name == "":
		final_asset_name = "location_home_forastero.png"

	var background: Control = VisualAsset.make_texture_or_placeholder(
		background_path,
		fallback_title,
		"Fondo final: %s" % final_asset_name
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_global_action_panel() -> void:
	global_action_panel = PanelContainer.new()
	global_action_panel.custom_minimum_size = Vector2(430, 46)
	home_layer.add_child(global_action_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	global_action_panel.add_child(margin)

	global_action_buttons = HBoxContainer.new()
	global_action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	global_action_buttons.add_theme_constant_override("separation", 8)
	margin.add_child(global_action_buttons)

	add_global_action("Mapa", func(): _on_map_pressed())
	add_global_action("Bitácora", func(): SceneRouter.go_to_journal(SceneRouter.HOME_SCENE))
	add_global_action("Guardar", func(): _on_save_pressed())
	add_global_action("Cargar", func(): SceneRouter.go_to_main_menu())


func build_main_panel() -> void:
	main_panel = PanelContainer.new()
	main_panel.custom_minimum_size = Vector2(720, 196)
	home_layer.add_child(main_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	main_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	main_title_label = Label.new()
	main_title_label.custom_minimum_size = Vector2(1, 24)
	main_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_title_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	main_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(main_title_label)

	main_description_scroll = ScrollContainer.new()
	main_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(main_description_scroll)

	main_description_label = Label.new()
	main_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_description_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	main_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_description_scroll.add_child(main_description_label)

	main_actions = HBoxContainer.new()
	main_actions.custom_minimum_size = Vector2(1, 40)
	main_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_actions.size_flags_vertical = Control.SIZE_SHRINK_END
	main_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	main_actions.add_theme_constant_override("separation", 8)
	box.add_child(main_actions)


func build_side_panel() -> void:
	side_panel = PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(330, 260)
	home_layer.add_child(side_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	side_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	side_title_label = Label.new()
	side_title_label.custom_minimum_size = Vector2(1, 24)
	side_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_title_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	side_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	side_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	side_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(side_title_label)

	side_description_scroll = ScrollContainer.new()
	side_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(side_description_scroll)

	side_description_label = Label.new()
	side_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_description_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	side_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	side_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_description_scroll.add_child(side_description_label)

	side_actions = VBoxContainer.new()
	side_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_actions.size_flags_vertical = Control.SIZE_SHRINK_END
	side_actions.add_theme_constant_override("separation", 6)
	box.add_child(side_actions)


func refresh_home(message: String = "") -> void:
	current_message = message
	GameManager.current_location_id = "home"
	hud_bar.refresh()

	refresh_main_panel()
	refresh_side_panel()
	call_deferred("refresh_layout_after_frame")


func refresh_main_panel() -> void:
	clear_children(main_actions)

	var location_data: Dictionary = DataManager.get_location("home")
	main_title_label.text = str(location_data.get("name", "Casa del Forastero"))

	if current_message != "":
		main_description_label.text = current_message
	else:
		main_description_label.text = get_home_description()

	var rest_button: Button = add_main_action("Descansar", func(): _on_rest_pressed(), GameManager.is_day_exhausted())
	rest_button.mouse_entered.connect(func(): show_main_preview(
		"Descansar",
		"Recuperas 20 de resistencia y consumes una acción. Útil si aún queda día por delante."
	))
	rest_button.focus_entered.connect(func(): show_main_preview(
		"Descansar",
		"Recuperas 20 de resistencia y consumes una acción. Útil si aún queda día por delante."
	))
	rest_button.mouse_exited.connect(func(): restore_main_text())

	var sleep_button: Button = add_main_action("Dormir hasta mañana", func(): _on_sleep_pressed())
	sleep_button.mouse_entered.connect(func(): show_main_preview(
		"Dormir hasta mañana",
		"Cierra el día actual, recupera toda la resistencia y avanza al siguiente día. También procesa eventos narrativos pendientes."
	))
	sleep_button.focus_entered.connect(func(): show_main_preview(
		"Dormir hasta mañana",
		"Cierra el día actual, recupera toda la resistencia y avanza al siguiente día. También procesa eventos narrativos pendientes."
	))
	sleep_button.mouse_exited.connect(func(): restore_main_text())

	if not GameManager.is_day_exhausted():
		var map_button: Button = add_main_action("Salir al mapa", func(): _on_map_pressed())
		map_button.mouse_entered.connect(func(): show_main_preview(
			"Salir al mapa",
			"Vuelve a Luminaria para visitar ubicaciones, buscar personajes, trabajar o comprar mientras aún tengas acciones disponibles."
		))
		map_button.focus_entered.connect(func(): show_main_preview(
			"Salir al mapa",
			"Vuelve a Luminaria para visitar ubicaciones, buscar personajes, trabajar o comprar mientras aún tengas acciones disponibles."
		))
		map_button.mouse_exited.connect(func(): restore_main_text())


func refresh_side_panel() -> void:
	clear_children(side_actions)

	side_title_label.text = "Vínculos y cierre"
	side_description_label.text = build_home_state_summary()

	build_final_union_options()


func get_home_description() -> String:
	var text: String = ""
	text += "La Casa del Forastero es tu punto seguro en Luminaria. Aquí puedes recuperar fuerzas, guardar tus decisiones y cerrar el día cuando estés listo."

	if GameManager.is_day_exhausted():
		text += "\n\nYa no quedan acciones útiles hoy. Dormir es la mejor forma de continuar."

	var pending_count: int = get_pending_narrative_count()

	if pending_count > 0:
		text += "\n\nAlgo espera ser procesado al descansar. El Velo tiene %s mensaje(s) pendiente(s)." % pending_count

	return text


func build_home_state_summary() -> String:
	var text: String = ""

	text += "Estado actual:\n"
	text += "- Resistencia: %s/%s\n" % [
		int(GameManager.player.get("stamina", 0)),
		int(GameManager.player.get("max_stamina", 0))
	]
	text += "- Lúmenes: %s\n" % int(GameManager.player.get("money", 0))
	text += "- Acciones restantes: %s\n" % GameManager.get_actions_remaining()
	text += "- Momento: Mes %s · Día %s · %s · %s\n" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		GameManager.get_time_label()
	]

	if FinalUnionSystem.has_final_union():
		var npc_id: String = FinalUnionSystem.get_final_union_npc_id()
		var npc: Dictionary = DataManager.get_npc(npc_id)
		text += "\nUnión definitiva:\n"
		text += "- %s\n" % npc.get("name", npc_id)

		if PostgameSystem.is_postgame_started():
			text += "\nPostgame:\n"
			text += PostgameSystem.get_postgame_status_text()
	else:
		var candidates: Array = FinalUnionSystem.get_available_candidates()

		if candidates.is_empty():
			text += "\nUnión definitiva:\n"
			text += "- Aún no hay nadie listo para ese paso.\n"
		else:
			text += "\nUnión definitiva:\n"
			text += "- Hay una decisión importante disponible.\n"

	return text


func build_final_union_options() -> void:
	if FinalUnionSystem.has_final_union():
		return

	var candidates: Array = FinalUnionSystem.get_available_candidates()

	if candidates.is_empty():
		return

	var header: Label = Label.new()
	header.text = "Unión definitiva disponible"
	header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_actions.add_child(header)

	for npc_id in candidates:
		add_final_union_button(str(npc_id))


func add_final_union_button(npc_id: String) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)
	var label_text: String = str(requirement.get(
		"proposal_label",
		"Proponer unión a %s" % npc.get("name", npc_id)
	))

	var button: Button = Button.new()
	button.text = label_text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 36)

	button.pressed.connect(func(): propose_final_union(npc_id))

	button.mouse_entered.connect(func():
		side_title_label.text = "Unión con %s" % npc.get("name", npc_id)
		side_description_label.text = get_final_union_preview_text(npc_id)
	)

	button.focus_entered.connect(func():
		side_title_label.text = "Unión con %s" % npc.get("name", npc_id)
		side_description_label.text = get_final_union_preview_text(npc_id)
	)

	button.mouse_exited.connect(func():
		refresh_side_panel()
	)

	side_actions.add_child(button)


func get_final_union_preview_text(npc_id: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)

	var text: String = ""
	text += "Esta decisión compromete la ruta final con %s.\n\n" % npc.get("name", npc_id)
	text += str(requirement.get("description", "Una unión definitiva cambia el estado de la historia y abre consecuencias de postgame."))

	return text


func show_main_preview(title: String, description: String) -> void:
	main_title_label.text = title
	main_description_label.text = description


func restore_main_text() -> void:
	var location_data: Dictionary = DataManager.get_location("home")
	main_title_label.text = str(location_data.get("name", "Casa del Forastero"))

	if current_message != "":
		main_description_label.text = current_message
	else:
		main_description_label.text = get_home_description()


func show_home_message(title: String, message: String) -> void:
	current_message = message
	clear_children(main_actions)

	main_title_label.text = title
	main_description_label.text = message

	add_main_action("Continuar", func():
		current_message = ""
		refresh_home()
	)


func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	show_home_message(
		"El Velo se agita",
		combined_text.strip_edges()
	)

	SaveManager.autosave_game()
	hud_bar.refresh()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return str(message)


func get_pending_narrative_count() -> int:
	if not GameManager.player.has("pending_narrative_messages"):
		return 0

	var messages: Array = GameManager.player.get("pending_narrative_messages", [])
	return messages.size()


func _on_rest_pressed() -> void:
	if not GameManager.can_perform_action(5):
		show_home_message("No puedes descansar", GameManager.get_action_blocked_message(5))
		return

	var before_stamina: int = int(GameManager.player.get("stamina", 0))

	GameManager.player["stamina"] = min(
		before_stamina + 20,
		int(GameManager.player.get("max_stamina", 100))
	)

	var after_stamina: int = int(GameManager.player.get("stamina", 0))
	var recovered: int = max(after_stamina - before_stamina, 0)

	GameManager.consume_action(5)
	SaveManager.autosave_game()

	hud_bar.refresh()

	show_home_message(
		"Descanso breve",
		"Recuperas fuerzas sin cerrar el día.\n\nResistencia +%s\nTiempo consumido: 1 acción" % recovered
	)


func _on_sleep_pressed() -> void:
	GameManager.sleep_until_next_day()
	SaveManager.autosave_game()

	current_message = ""
	hud_bar.refresh()
	refresh_home("Duermes hasta la mañana siguiente.\n\nLa resistencia se ha recuperado por completo.")
	show_pending_narrative_messages()


func _on_save_pressed() -> void:
	SaveManager.save_game()
	show_home_message(
		"Partida guardada",
		"El progreso fue guardado manualmente en la Casa del Forastero."
	)


func _on_map_pressed() -> void:
	SceneRouter.go_to_world_map()


func propose_final_union(npc_id: String) -> void:
	var result: Dictionary = FinalUnionSystem.complete_final_union(npc_id)

	SaveManager.autosave_game()
	hud_bar.refresh()

	refresh_home(str(result.get("text", "")))


func add_global_action(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	global_action_buttons.add_child(button)
	return button


func add_main_action(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(120, 36)

	if not disabled:
		button.pressed.connect(callback)

	main_actions.add_child(button)
	return button


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func layout_overlay_controls() -> void:
	if home_layer == null:
		return

	var margin: float = 10.0

	var global_width: float = 430.0

	if home_layer.size.x < 760:
		global_width = 330.0

	global_action_panel.size = Vector2(global_width, 46)
	global_action_panel.position = Vector2(
		max(margin, home_layer.size.x - global_width - margin),
		margin
	)

	var main_width: float = min(820.0, max(420.0, home_layer.size.x - 24.0))
	var main_height: float = 196.0

	if home_layer.size.x < 760:
		main_width = max(360.0, home_layer.size.x - 24.0)
		main_height = 218.0

	main_panel.size = Vector2(main_width, main_height)
	main_panel.position = Vector2(
		12.0,
		max(12.0, home_layer.size.y - main_height - 12.0)
	)

	var side_width: float = 340.0
	var side_height: float = min(310.0, max(240.0, home_layer.size.y - 86.0))

	if home_layer.size.x < 900:
		side_width = min(320.0, max(280.0, home_layer.size.x - 24.0))
		side_height = 210.0

	side_panel.size = Vector2(side_width, side_height)

	if home_layer.size.x < 900:
		side_panel.position = Vector2(
			12.0,
			max(60.0, main_panel.position.y - side_height - 10.0)
		)
	else:
		side_panel.position = Vector2(
			max(12.0, home_layer.size.x - side_width - 12.0),
			68.0
		)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if home_layer != null:
			call_deferred("refresh_layout_after_frame")


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
