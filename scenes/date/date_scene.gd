extends Control


var hud_bar: WorldHudBar

var date_frame: PanelContainer
var date_layer: Control
var background_layer: Control

var top_info_panel: PanelContainer
var top_info_label: Label

var global_action_panel: PanelContainer
var global_action_buttons: HBoxContainer

var npc_panel: PanelContainer
var npc_name_label: Label
var npc_portrait_holder: Control
var npc_status_label: Label

var narrative_panel: PanelContainer
var narrative_scroll: ScrollContainer
var narrative_label: Label

var action_panel: PanelContainer
var action_buttons: HBoxContainer

var modal_layer: ColorRect
var modal_panel: PanelContainer
var modal_title_label: Label
var modal_description_label: Label
var modal_scroll: ScrollContainer
var modal_buttons: VBoxContainer
var modal_footer: HBoxContainer

var current_date: Dictionary = {}
var current_mode: String = "normal"
var current_narrative: String = ""
var selected_move_id: String = ""


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()

	if SceneRouter.temp_date_type == "special":
		start_special_date(SceneRouter.temp_npc_id, SceneRouter.temp_relationship_step_id)
	else:
		start_date(SceneRouter.temp_npc_id, SceneRouter.temp_date_location_id)


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

	date_frame = PanelContainer.new()
	date_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	date_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(date_frame)

	var frame_margin: MarginContainer = MarginContainer.new()
	frame_margin.add_theme_constant_override("margin_left", 6)
	frame_margin.add_theme_constant_override("margin_top", 6)
	frame_margin.add_theme_constant_override("margin_right", 6)
	frame_margin.add_theme_constant_override("margin_bottom", 6)
	date_frame.add_child(frame_margin)

	date_layer = Control.new()
	date_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	date_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	date_layer.clip_contents = true
	frame_margin.add_child(date_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	date_layer.add_child(background_layer)

	build_background()
	build_top_info_panel()
	build_global_action_panel()
	build_npc_panel()
	build_narrative_panel()
	build_action_panel()
	build_modal()

	call_deferred("refresh_layout_after_frame")


func build_background() -> void:
	clear_children(background_layer)

	var background: Control = VisualAsset.make_texture_or_placeholder(
		"res://assets/backgrounds/date_scene_default.png",
		"Cita",
		"Fondo final: date_scene_default.png"
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_top_info_panel() -> void:
	top_info_panel = PanelContainer.new()
	top_info_panel.custom_minimum_size = Vector2(560, 46)
	date_layer.add_child(top_info_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	top_info_panel.add_child(margin)

	top_info_label = Label.new()
	top_info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_info_label.clip_text = true
	margin.add_child(top_info_label)


func build_global_action_panel() -> void:
	global_action_panel = PanelContainer.new()
	global_action_panel.custom_minimum_size = Vector2(330, 46)
	date_layer.add_child(global_action_panel)

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

	add_global_action("Guardar", func():
		SaveManager.save_game()
		show_date_message("Partida guardada", "Guardaste durante la cita. El momento queda suspendido en la memoria.")
	)

	add_global_action("Cargar", func(): SceneRouter.go_to_main_menu())

func build_npc_panel() -> void:
	npc_panel = PanelContainer.new()
	npc_panel.custom_minimum_size = Vector2(300, 300)
	date_layer.add_child(npc_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	npc_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	npc_name_label = Label.new()
	npc_name_label.custom_minimum_size = Vector2(1, 26)
	npc_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npc_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	npc_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	npc_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(npc_name_label)

	npc_portrait_holder = Control.new()
	npc_portrait_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npc_portrait_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(npc_portrait_holder)

	npc_status_label = Label.new()
	npc_status_label.custom_minimum_size = Vector2(1, 54)
	npc_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npc_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	npc_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	npc_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(npc_status_label)


func build_narrative_panel() -> void:
	narrative_panel = PanelContainer.new()
	narrative_panel.custom_minimum_size = Vector2(760, 260)
	date_layer.add_child(narrative_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	narrative_panel.add_child(margin)

	narrative_scroll = ScrollContainer.new()
	narrative_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	narrative_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	narrative_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	narrative_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	margin.add_child(narrative_scroll)

	narrative_label = Label.new()
	narrative_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	narrative_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	narrative_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	narrative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	narrative_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	narrative_scroll.add_child(narrative_label)


func build_action_panel() -> void:
	action_panel = PanelContainer.new()
	action_panel.custom_minimum_size = Vector2(760, 72)
	date_layer.add_child(action_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	action_panel.add_child(margin)

	action_buttons = HBoxContainer.new()
	action_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_buttons.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	action_buttons.add_theme_constant_override("separation", 10)
	margin.add_child(action_buttons)


func build_modal() -> void:
	modal_layer = ColorRect.new()
	modal_layer.color = Color(0, 0, 0, 0.55)
	modal_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal_layer.visible = false
	modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	date_layer.add_child(modal_layer)

	modal_panel = PanelContainer.new()
	modal_panel.custom_minimum_size = Vector2(520, 360)
	modal_layer.add_child(modal_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	modal_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	modal_title_label = Label.new()
	modal_title_label.custom_minimum_size = Vector2(1, 28)
	modal_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	modal_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(modal_title_label)

	modal_description_label = Label.new()
	modal_description_label.custom_minimum_size = Vector2(1, 48)
	modal_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	modal_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	modal_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(modal_description_label)

	modal_scroll = ScrollContainer.new()
	modal_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	modal_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(modal_scroll)

	modal_buttons = VBoxContainer.new()
	modal_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	modal_buttons.add_theme_constant_override("separation", 8)
	modal_scroll.add_child(modal_buttons)

	modal_footer = HBoxContainer.new()
	modal_footer.alignment = BoxContainer.ALIGNMENT_CENTER
	modal_footer.add_theme_constant_override("separation", 10)
	box.add_child(modal_footer)


func start_date(npc_id: String, date_location_id: String = "") -> void:
	current_mode = "normal"

	if date_location_id == "":
		var available: Array = DateSystem.get_available_date_locations(npc_id)

		if available.is_empty():
			SceneRouter.go_to_world_map()
			return

		date_location_id = str(available[0])

	current_date = DateSystem.create_date_state(npc_id, date_location_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)

	current_narrative = "%s\n\n%s" % [
		date_location.get("description", ""),
		"La cita comienza con una tensión suave. Todavía hay espacio para equivocarse o para convertir este momento en memoria."
	]

	refresh_date_view()
	build_actions()


func start_special_date(npc_id: String, step_id: String) -> void:
	current_mode = "special"
	current_date = RelationshipSystem.create_special_date_state(npc_id, step_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	current_narrative = "%s\n\nPara avanzar, deberás responder desde lo que realmente conoces de %s." % [
		step.get("description", ""),
		npc.get("name", npc_id)
	]

	refresh_date_view()
	build_special_actions()


func refresh_date_view() -> void:
	hud_bar.refresh()

	var npc_id: String = current_date.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)

	npc_name_label.text = str(npc.get("name", npc_id))

	if current_mode == "special":
		refresh_special_header()
	else:
		refresh_normal_header()

	narrative_label.text = current_narrative
	build_npc_portrait()
	call_deferred("refresh_layout_after_frame")


func refresh_normal_header() -> void:
	var npc_id: String = current_date.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var date_location_id: String = current_date.get("date_location_id", "")
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)
	var progress: int = int(current_date.get("progress", 0))
	var threshold: int = int(date_location.get("success_threshold", 70))

	top_info_label.text = "Cita con %s · %s · Progreso %s%% · Éxito desde %s%%" % [
		npc.get("name", npc_id),
		date_location.get("name", date_location_id),
		progress,
		threshold
	]

	npc_status_label.text = build_npc_status_text(npc_id)


func refresh_special_header() -> void:
	var npc_id: String = current_date.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var step_id: String = str(current_date.get("relationship_step_id", current_date.get("step_id", "")))
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	top_info_label.text = "Cita especial con %s" % npc.get("name", npc_id)
	npc_status_label.text = "Progreso especial: %s/%s\nErrores: %s" % [
		current_date.get("progress", 0),
		current_date.get("questions_required", 0),
		current_date.get("mistakes", 0)
	]


func build_date_scene_summary(date_location: Dictionary) -> String:
	var text: String = ""
	text += str(date_location.get("description", ""))

	var mood_tags: Array = date_location.get("mood_tags", [])

	if not mood_tags.is_empty():
		text += "\n\nAmbiente: %s" % ", ".join(mood_tags)

	return text


func build_npc_status_text(npc_id: String) -> String:
	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var state: String = str(relation.get("relationship_state", "none"))

	return "%s\nVínculo %s · Tensión %s · Celos %s" % [
		GameManager.get_relationship_state_label(state),
		GameManager.get_total_affinity(npc_id),
		int(relation.get("tension", 0)),
		int(relation.get("jealousy", 0))
	]


func build_npc_portrait() -> void:
	clear_children(npc_portrait_holder)

	var npc_id: String = current_date.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_ui: Dictionary = DataManager.get_npc_ui(npc_id)

	var portrait_path: String = str(npc_ui.get("talking", npc_ui.get("portrait", "")))
	var final_asset_name: String = portrait_path.get_file()

	if final_asset_name == "":
		final_asset_name = "%s_talking.png" % str(npc.get("name", npc_id)).capitalize()

	var portrait: Control = VisualAsset.make_texture_or_placeholder(
		portrait_path,
		str(npc.get("name", npc_id)),
		"Arte final: %s" % final_asset_name
	)

	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 0
	portrait.offset_top = 0
	portrait.offset_right = 0
	portrait.offset_bottom = 0
	npc_portrait_holder.add_child(portrait)


func build_actions() -> void:
	close_choice_modal()
	clear_children(action_buttons)

	add_action_button(
		"Hablar",
		func(): do_talk(),
		not DateSystem.can_talk(current_date),
		"Conversar puede mejorar el progreso de la cita o abrir una pregunta sobre lo que sabes."
	)

	add_action_button(
		"Regalar",
		func(): show_gift_selection(),
		not DateSystem.can_gift(current_date),
		"Entrega un regalo de tu inventario. Un gusto correcto puede cambiar mucho el tono."
	)

	add_action_button(
		"Movimiento",
		func(): show_move_selection(),
		not DateSystem.can_move(current_date),
		"Es tu momento de coqueteo físico. Algunos movimientos dependen del ambiente y del vínculo."
	)

	add_action_button(
		"Terminar cita",
		func(): end_date(),
		false,
		"Cierra la cita y registra sus consecuencias."
	)


func build_special_actions() -> void:
	close_choice_modal()
	clear_children(action_buttons)

	if RelationshipSystem.is_special_date_complete(current_date):
		add_action_button(
			"Cerrar conversación",
			func(): end_special_date(),
			false,
			"Termina esta cita especial y aplica sus consecuencias."
		)
	else:
		add_action_button(
			"Responder",
			func(): do_special_question(),
			false,
			"Responde usando información que ya descubriste."
		)

		add_action_button(
			"Cancelar",
			func(): cancel_special_date(),
			false,
			"Salir sin forzar el avance."
		)


func add_action_button(text: String, callback: Callable, disabled: bool = false, hint: String = "") -> Button:
	var button: Button = Button.new()
	button.text = text
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(180, 42)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	if not disabled:
		button.pressed.connect(callback)

	if hint != "":
		button.mouse_entered.connect(func(): show_hint(hint))
		button.focus_entered.connect(func(): show_hint(hint))

	action_buttons.add_child(button)
	return button


func show_hint(text: String) -> void:
	# No cambiamos narrativa, pregunta ni modal al pasar el mouse.
	# La UI de cita debe proteger el texto importante del jugador.
	pass


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func do_talk() -> void:
	if not DateSystem.can_talk(current_date):
		show_date_message("La conversación se agota", "La conversación ya dio todo lo que podía dar en esta cita.")
		build_actions()
		return

	var npc_id: String = current_date["npc_id"]
	var known_info: Array = GameManager.player["known_npc_info"].get(npc_id, {}).get("info", [])

	DateSystem.register_talk(current_date)

	if known_info.is_empty() or not DateSystem.can_question(current_date):
		do_random_dialogue()
		return

	if randf() < 0.65:
		do_random_dialogue()
	else:
		do_question()


func do_random_dialogue() -> void:
	var npc_id: String = current_date["npc_id"]
	var dialogue_line: String = DialogueSystem.get_dialogue_line(npc_id, "casual")

	current_date["progress"] = clamp(int(current_date["progress"]) + 5, 0, 100)

	current_narrative = "%s\n\nLa conversación acerca la cita.\nProgreso +5\nConversaciones usadas: %s/%s" % [
		dialogue_line,
		current_date.get("talks_used", 0),
		DateSystem.NORMAL_DATE_MAX_TALKS
	]

	GameManager.consume_action(3)
	SaveManager.save_game()
	refresh_date_view()
	build_actions()


func do_question() -> void:
	if not DateSystem.can_question(current_date):
		do_random_dialogue()
		return

	var npc_id: String = current_date["npc_id"]
	var q: Dictionary = build_question(npc_id)

	if q.is_empty():
		do_random_dialogue()
		return

	DateSystem.register_question(current_date)
	current_narrative = q["question"]
	refresh_date_view()

	open_choice_modal("Responder", q["question"])

	for option in q["options"]:
		add_question_option_button(q, str(option))

	add_modal_footer_button("No responder", func():
		close_choice_modal()
		current_narrative = "Decides no responder todavía. Algunas preguntas pesan más cuando se entienden a medias."
		refresh_date_view()
		build_actions()
	)


func answer_question(question: Dictionary, selected: String) -> void:
	close_choice_modal()

	var correct: String = question["correct"]
	var npc_id: String = current_date["npc_id"]

	if selected == correct:
		var relationship_text: String = GameManager.add_relationship_value(npc_id, "friendship", 2)
		current_date["progress"] = clamp(current_date["progress"] + 15, 0, 100)
		current_narrative = "Respondes sin dudar.\nLa reacción es inmediata… y claramente favorable.\n\nAmistad +2%s" % relationship_text
	else:
		var relationship_text: String = GameManager.add_relationship_value(npc_id, "friendship", -2)
		current_date["progress"] = clamp(current_date["progress"] - 12, 0, 100)
		current_date["mistakes"] = int(current_date.get("mistakes", 0)) + 1
		current_narrative = "Tu respuesta no coincide.\nLa distancia entre ambos se hace evidente.\n\nAmistad -2%s" % relationship_text

	GameManager.consume_action(3)
	SaveManager.save_game()

	refresh_date_view()
	build_actions()


func show_gift_selection() -> void:
	if not DateSystem.can_gift(current_date):
		show_date_message("Regalo agotado", "Ya diste un regalo durante esta cita.")
		build_actions()
		return

	var gifts: Array = GameManager.get_gift_items_in_inventory()

	if gifts.is_empty():
		current_narrative = "No tienes regalos disponibles.\n\nLa intención existe, pero la mochila no ayuda."
		refresh_date_view()
		return

	current_narrative = "Elige un regalo para esta cita. No todos los regalos dicen lo mismo."
	refresh_date_view()

	open_choice_modal("Elegir regalo", current_narrative)

	for entry in gifts:
		var item_entry: Dictionary = entry
		var item_id: String = item_entry.get("item_id", "")
		var amount: int = int(item_entry.get("amount", 0))
		add_gift_option_button(item_id, amount)

	add_modal_footer_button("Volver", func():
		close_choice_modal()
		current_narrative = "Guardas el regalo por ahora."
		refresh_date_view()
		build_actions()
	)


func give_date_gift(item_id: String) -> void:
	close_choice_modal()

	if not DateSystem.can_gift(current_date):
		show_date_message("Regalo agotado", "Ya diste un regalo durante esta cita.")
		build_actions()
		return

	var npc_id: String = current_date["npc_id"]

	if not GameManager.has_item(item_id):
		show_date_message("Objeto perdido", "Ya no tienes ese objeto.")
		build_actions()
		return

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var item: Dictionary = DataManager.get_item(item_id)
	var prefs: Dictionary = npc.get("gift_preferences", {})

	var progress_change: int = 0
	var message: String = ""

	if item_id in prefs.get("loves", []):
		progress_change = randi_range(12, 16)
		message = "El regalo toca una fibra evidente. La cita se vuelve más íntima."
	elif item_id in prefs.get("likes", []):
		progress_change = randi_range(8, 11)
		message = "El regalo fue una buena elección. La cita fluye mejor."
	elif item_id in prefs.get("hates", []):
		progress_change = randi_range(-18, -12)
		message = "El regalo incomoda el ambiente. Fue una mala elección."
	else:
		progress_change = randi_range(3, 5)
		message = "El gesto se recibe con cortesía."

	current_date["progress"] = clamp(int(current_date.get("progress", 0)) + progress_change, 0, 100)

	if progress_change > 0:
		DateSystem.apply_relationship_effects(npc_id, {
			"friendship": 1
		})
	else:
		DateSystem.apply_relationship_effects(npc_id, {
			"jealousy": 2
		})
		current_date["mistakes"] = int(current_date.get("mistakes", 0)) + 1

	DateSystem.register_gift(current_date)
	GameManager.remove_item(item_id, 1)
	GameManager.reveal_npc_gift(npc_id, item_id)
	GameManager.consume_action(3)
	SaveManager.save_game()

	current_narrative = "%s\n\nRegalo: %s\nProgreso %+d" % [
		message,
		item.get("name", item_id),
		progress_change
	]

	refresh_date_view()
	build_actions()


func show_move_selection() -> void:
	var move_ids: Array = DateSystem.get_available_moves(current_date)

	current_narrative = "Ésta frente a ti... ¿Qué harás?"
	refresh_date_view()

	if move_ids.is_empty():
		current_narrative = "Ya no conviene intentar más movimientos en esta cita."
		refresh_date_view()
		return

	open_choice_modal("Elegir movimiento", current_narrative)

	for move_id in move_ids:
		add_move_option_button(str(move_id))

	add_modal_footer_button("Volver", func():
		close_choice_modal()
		current_narrative = "Dejas pasar la oportunidad"
		refresh_date_view()
		build_actions()
	)


func build_move_hint(move_id: String) -> String:
	var move: Dictionary = DataManager.get_date_move(move_id)
	var text: String = str(move.get("name", move_id))

	text += " · Progreso mínimo %s" % int(move.get("min_progress", 0))
	text += " · Tensión mínima %s" % int(move.get("min_tension", 0))

	var preferred: Array = move.get("preferred_moods", [])

	if not preferred.is_empty():
		text += "\nEncaja con: %s" % ", ".join(preferred)

	return text


func perform_move(move_id: String) -> void:
	close_choice_modal()

	var result: Dictionary = DateSystem.perform_move(current_date, move_id)

	GameManager.consume_action(4)
	SaveManager.save_game()

	current_narrative = "%s\n\nProgreso actual: %s\nMovimientos usados: %s/%s" % [
		result.get("text", ""),
		current_date.get("progress", 0),
		current_date.get("moves_used", []).size(),
		DateSystem.NORMAL_DATE_MAX_MOVES
	]

	refresh_date_view()
	build_actions()


func end_date() -> void:
	var result: Dictionary = DateSystem.finish_date(current_date)
	SaveManager.save_game()
	show_final_summary(result.get("text", "La cita terminó."))


func do_special_question() -> void:
	var q: Dictionary = RelationshipSystem.build_special_question(current_date)

	if q.is_empty():
		current_narrative = "Aunque has llegado hasta aquí, aún no conoces suficiente información aplicable para sostener esta conversación."
		refresh_date_view()
		build_special_actions()
		return

	current_narrative = q.get("question", "")
	refresh_date_view()

	open_choice_modal("Responder", current_narrative)

	for option in q.get("options", []):
		add_special_question_option_button(q, str(option))

	add_modal_footer_button("No responder", func():
		close_choice_modal()
		current_narrative = "Decides no forzar la respuesta todavía."
		refresh_date_view()
		build_special_actions()
	)


func answer_special_question(question: Dictionary, selected: String) -> void:
	close_choice_modal()

	var result: Dictionary = RelationshipSystem.answer_special_question(current_date, question, selected)

	current_narrative = "%s\n\nProgreso especial: %s/%s\nErrores: %s" % [
		result.get("text", ""),
		current_date.get("progress", 0),
		current_date.get("questions_required", 0),
		current_date.get("mistakes", 0)
	]

	GameManager.consume_action(3)
	SaveManager.save_game()

	refresh_date_view()
	build_special_actions()


func end_special_date() -> void:
	var result: Dictionary = RelationshipSystem.finish_special_date(current_date)
	SaveManager.save_game()
	show_final_summary(result.get("text", "La cita especial terminó."))


func cancel_special_date() -> void:
	show_final_summary("Decides no continuar con esta cita especial por ahora.\n\nA veces, no forzar una respuesta también protege el vínculo.")


func show_date_message(title: String, message: String) -> void:
	current_narrative = "%s\n\n%s" % [title, message]
	refresh_date_view()

func build_question(npc_id: String) -> Dictionary:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var info_data: Dictionary = npc.get("info", {})
	var known_info: Array = GameManager.player["known_npc_info"].get(npc_id, {}).get("info", [])

	if known_info.is_empty():
		return {}

	var index: int = randi_range(0, known_info.size() - 1)
	var info_key: String = known_info[index]
	var correct_value: String = str(info_data.get(info_key, ""))

	var options: Array = [correct_value]

	for other_npc_id in DataManager.npcs.keys():
		var other_npc: Dictionary = DataManager.get_npc(other_npc_id)
		var other_info: Dictionary = other_npc.get("info", {})

		if other_info.has(info_key):
			var value: String = str(other_info[info_key])

			if value != correct_value:
				options.append(value)

		if options.size() >= 3:
			break

	options.shuffle()

	var label: String = GameManager.get_info_label(info_key)
	var category_label: String = GameManager.get_info_category_title_for_key(info_key)

	return {
		"question": "Para dar este paso, necesitas demostrar que realmente has puesto atención.\n\n%s · %s\n¿Cuál es la respuesta correcta para %s?" % [
			category_label,
			label,
			npc.get("name", npc_id)
		],
		"info_key": info_key,
		"correct": correct_value,
		"options": options
	}

func open_choice_modal(title: String, description: String) -> void:
	clear_children(modal_buttons)
	clear_children(modal_footer)

	modal_title_label.text = title
	modal_description_label.text = description

	modal_layer.visible = true
	modal_layer.move_to_front()
	call_deferred("refresh_layout_after_frame")

func close_choice_modal() -> void:
	if modal_layer != null:
		modal_layer.visible = false

func add_modal_choice_button(text: String, callback: Callable, hint: String = "") -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 48)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(callback)

	# Importante:
	# No cambiar modal_description_label en hover.
	# Ese texto puede contener la pregunta completa o el resumen final.
	# Robarlo deja al jugador sin contexto.

	modal_buttons.add_child(button)
	return button

func add_modal_footer_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(180, 42)
	button.pressed.connect(callback)
	modal_footer.add_child(button)
	return button

func layout_overlay_controls() -> void:
	if date_layer == null:
		return

	var margin: float = 10.0
	var top_y: float = 10.0
	var top_height: float = 46.0
	var action_height: float = 78.0
	var gap: float = 10.0

	var global_width: float = 330.0

	if date_layer.size.x < 760:
		global_width = 260.0

	global_action_panel.size = Vector2(global_width, top_height)
	global_action_panel.position = Vector2(
		max(margin, date_layer.size.x - global_width - margin),
		top_y
	)

	var info_width: float = max(260.0, date_layer.size.x - global_width - (margin * 3.0))
	top_info_panel.size = Vector2(info_width, top_height)
	top_info_panel.position = Vector2(margin, top_y)

	var available_width: float = max(320.0, date_layer.size.x - (margin * 2.0))
	var bottom_y: float = max(
		top_y + top_height + 260.0,
		date_layer.size.y - action_height - margin
	)

	action_panel.size = Vector2(available_width, action_height)
	action_panel.position = Vector2(margin, bottom_y)

	var center_top: float = top_y + top_height + gap
	var center_height: float = max(300.0, action_panel.position.y - center_top - gap)

	var npc_width: float = clamp(date_layer.size.x * 0.28, 260.0, 360.0)
	var narrative_width: float = available_width - npc_width - gap

	if date_layer.size.x < 760:
		npc_width = max(220.0, available_width * 0.34)
		narrative_width = available_width - npc_width - gap

	narrative_panel.size = Vector2(max(320.0, narrative_width), center_height)
	narrative_panel.position = Vector2(margin, center_top)

	npc_panel.size = Vector2(npc_width, center_height)
	npc_panel.position = Vector2(
		narrative_panel.position.x + narrative_panel.size.x + gap,
		center_top
	)

	if modal_layer != null:
		modal_layer.size = date_layer.size

		var modal_width: float = clamp(date_layer.size.x * 0.76, 560.0, 920.0)
		var modal_height: float = clamp(date_layer.size.y * 0.78, 420.0, 700.0)

		modal_panel.size = Vector2(modal_width, modal_height)
		modal_panel.position = Vector2(
			(date_layer.size.x - modal_width) / 2.0,
			(date_layer.size.y - modal_height) / 2.0
		)
		
func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if date_layer != null:
			call_deferred("refresh_layout_after_frame")


func add_global_action(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	global_action_buttons.add_child(button)
	return button


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

func add_question_option_button(question: Dictionary, value: String) -> void:
	var locked_value: String = value

	add_modal_choice_button(
		locked_value,
		func(): answer_question(question, locked_value)
	)

func add_special_question_option_button(question: Dictionary, value: String) -> void:
	var locked_value: String = value

	add_modal_choice_button(
		locked_value,
		func(): answer_special_question(question, locked_value)
	)


func add_gift_option_button(item_id: String, amount: int) -> void:
	var locked_item_id: String = item_id
	var item_data: Dictionary = DataManager.get_item(locked_item_id)

	add_modal_choice_button(
		"%s x%s" % [item_data.get("name", locked_item_id), amount],
		func(): give_date_gift(locked_item_id),
		str(item_data.get("description", "Un regalo."))
	)


func add_move_option_button(move_id: String) -> void:
	var locked_move_id: String = move_id
	var move: Dictionary = DataManager.get_date_move(locked_move_id)

	add_modal_choice_button(
		move.get("name", locked_move_id),
		func(): perform_move(locked_move_id),
		build_move_hint(locked_move_id)
	)

func show_final_summary(summary_text: String) -> void:
	current_narrative = summary_text
	refresh_date_view()
	clear_children(action_buttons)

	open_choice_modal("Resumen de la cita", "")

	clear_children(modal_buttons)

	var summary_label: Label = Label.new()
	summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	summary_label.text = summary_text
	modal_buttons.add_child(summary_label)

	add_modal_footer_button("Continuar", func():
		close_choice_modal()
		SceneRouter.go_to_current_location_scene()
	)
