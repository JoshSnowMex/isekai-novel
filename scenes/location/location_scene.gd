extends Control


var hud_bar: WorldHudBar
var location_frame: PanelContainer
var location_layer: Control
var background_layer: Control
var character_layer: Control
var bottom_panel: PanelContainer
var bottom_title_label: Label
var bottom_description_scroll: ScrollContainer
var bottom_description_label: Label
var bottom_actions: HBoxContainer
var global_action_panel: PanelContainer
var global_action_buttons: HBoxContainer

var current_location_id: String = ""
var last_message: String = ""
var selected_npc_id: String = ""
var character_positions_by_location: Dictionary = {}

const BASE_LOCATION_SIZE := Vector2(1050.0, 540.0)
const CHARACTER_BASE_SIZE := Vector2(132.0, 210.0)


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	load_location(GameManager.current_location_id)
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

	location_frame = PanelContainer.new()
	location_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(location_frame)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	location_frame.add_child(margin)

	location_layer = Control.new()
	location_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	location_layer.clip_contents = true
	margin.add_child(location_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	location_layer.add_child(background_layer)

	character_layer = Control.new()
	character_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	character_layer.offset_left = 0
	character_layer.offset_top = 0
	character_layer.offset_right = 0
	character_layer.offset_bottom = 0
	location_layer.add_child(character_layer)

	build_global_action_panel()
	build_bottom_panel()

	call_deferred("refresh_layout_after_frame")


func build_global_action_panel() -> void:
	global_action_panel = PanelContainer.new()
	global_action_panel.custom_minimum_size = Vector2(360, 46)
	location_layer.add_child(global_action_panel)

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

	add_global_action("Mapa", func(): _on_back_pressed())
	add_global_action("Bitácora", func(): SceneRouter.go_to_journal(SceneRouter.LOCATION_SCENE))
	add_global_action("Guardar", func():
		SaveManager.save_game()
		show_location_message(
			"Partida guardada",
			"El progreso fue guardado manualmente.\nPuedes continuar explorando esta zona."
		)
	)


func build_bottom_panel() -> void:
	bottom_panel = PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(760, 190)
	location_layer.add_child(bottom_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	bottom_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	bottom_title_label = Label.new()
	bottom_title_label.custom_minimum_size = Vector2(1, 24)
	bottom_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_title_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	bottom_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottom_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(bottom_title_label)

	bottom_description_scroll = ScrollContainer.new()
	bottom_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bottom_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(bottom_description_scroll)

	bottom_description_label = Label.new()
	bottom_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_description_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	bottom_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	bottom_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom_description_scroll.add_child(bottom_description_label)

	bottom_actions = HBoxContainer.new()
	bottom_actions.custom_minimum_size = Vector2(1, 40)
	bottom_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_actions.size_flags_vertical = Control.SIZE_SHRINK_END
	bottom_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_actions.add_theme_constant_override("separation", 8)
	box.add_child(bottom_actions)

func load_location(location_id: String, message: String = "") -> void:
	current_location_id = location_id
	selected_npc_id = ""

	var location_data: Dictionary = DataManager.get_location(location_id)

	if message != "":
		last_message = message

	hud_bar.refresh()
	rebuild_background()
	rebuild_characters()
	show_location_overview(location_data)
	call_deferred("refresh_layout_after_frame")


func rebuild_background() -> void:
	clear_children(background_layer)

	var location_data: Dictionary = DataManager.get_location(current_location_id)
	var location_ui: Dictionary = DataManager.get_location_ui(current_location_id)

	var background_path: String = str(location_ui.get("background", ""))
	var fallback_title: String = str(location_data.get("name", current_location_id))
	var final_asset_name: String = background_path.get_file()

	if final_asset_name == "":
		final_asset_name = "location_%s.png" % current_location_id

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


func rebuild_characters() -> void:
	clear_children(character_layer)

	var present_npcs: Array = get_present_npcs()

	for index in range(present_npcs.size()):
		create_character_button(str(present_npcs[index]), index, present_npcs.size())


func get_present_npcs() -> Array:
	var result: Array = []

	for npc_id in DataManager.npcs.keys():
		var id: String = str(npc_id)
		var npc_location_id: String = ScheduleSystem.get_npc_location(id)

		if npc_location_id == current_location_id:
			result.append(id)

	return result


func create_character_button(npc_id: String, index: int, total: int) -> void:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_ui: Dictionary = DataManager.get_npc_ui(npc_id)
	var known: bool = is_npc_known(npc_id)
	var display_name: String = get_npc_display_name(npc_id)

	var button: Button = Button.new()
	button.flat = true
	button.focus_mode = Control.FOCUS_ALL
	button.tooltip_text = display_name
	button.set_meta("npc_id", npc_id)
	button.mouse_entered.connect(func(): show_character_preview(npc_id))
	button.focus_entered.connect(func(): show_character_preview(npc_id))
	button.pressed.connect(func(): select_npc(npc_id))
	character_layer.add_child(button)

	var button_size: Vector2 = get_scaled_character_size()
	var button_position: Vector2 = get_stable_character_position(npc_id, index, total, button_size)

	button.position = button_position
	button.custom_minimum_size = button_size
	button.size = button_size

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.offset_left = 0
	root_margin.offset_top = 0
	root_margin.offset_right = 0
	root_margin.offset_bottom = 0
	root_margin.add_theme_constant_override("margin_left", 2)
	root_margin.add_theme_constant_override("margin_top", 2)
	root_margin.add_theme_constant_override("margin_right", 2)
	root_margin.add_theme_constant_override("margin_bottom", 2)
	button.add_child(root_margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.alignment = BoxContainer.ALIGNMENT_END
	box.add_theme_constant_override("separation", 4)
	root_margin.add_child(box)

	var sprite_path: String = str(npc_ui.get("map_sprite", npc_ui.get("talking", npc_ui.get("portrait", ""))))
	var final_asset_name: String = sprite_path.get_file()

	if final_asset_name == "":
		final_asset_name = "%s_location_sprite.png" % npc_id.capitalize()

	var sprite_title: String = display_name

	if not known:
		sprite_title = "???"

	var sprite: Control = VisualAsset.make_texture_or_placeholder(
		sprite_path,
		sprite_title,
		"Sprite final: %s" % final_asset_name
	)
	sprite.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sprite.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(sprite)

	var name_plate: PanelContainer = PanelContainer.new()
	name_plate.custom_minimum_size = Vector2(1, 34)
	box.add_child(name_plate)

	var name_margin: MarginContainer = MarginContainer.new()
	name_margin.add_theme_constant_override("margin_left", 6)
	name_margin.add_theme_constant_override("margin_top", 3)
	name_margin.add_theme_constant_override("margin_right", 6)
	name_margin.add_theme_constant_override("margin_bottom", 3)
	name_plate.add_child(name_margin)

	var name_label: Label = Label.new()
	name_label.text = display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.clip_text = true
	name_margin.add_child(name_label)

	button.set_meta("name_label", name_label)

func show_location_overview(location_data: Dictionary) -> void:
	selected_npc_id = ""
	clear_bottom_actions()

	bottom_title_label.text = str(location_data.get("name", current_location_id))

	if last_message != "":
		bottom_description_label.text = last_message
	else:
		bottom_description_label.text = str(location_data.get("description", ""))

	var present_npcs: Array = get_present_npcs()

	for npc_id in present_npcs:
		add_approach_npc_action(str(npc_id))

	if present_npcs.is_empty():
		add_bottom_action("No hay nadie", func(): pass, true)

	add_bottom_action("Acciones del lugar", func(): show_location_actions(location_data))
	add_bottom_action("Volver al mapa", func(): _on_back_pressed())

func add_approach_npc_action(npc_id: String) -> void:
	var locked_npc_id: String = npc_id
	var display_name: String = get_npc_display_name(locked_npc_id)

	add_bottom_action(
		"Acercarse a %s" % display_name,
		func(): select_npc(locked_npc_id)
	)
	
func show_location_actions(location_data: Dictionary) -> void:
	selected_npc_id = ""
	clear_bottom_actions()

	bottom_title_label.text = "Acciones de %s" % location_data.get("name", current_location_id)
	bottom_description_label.text = "Elige qué hacer en esta ubicación. Estas acciones consumen tiempo si corresponde."

	var actions: Dictionary = location_data.get("actions", {})
	var activities: Array = location_data.get("activities", [])

	for activity_id in activities:
		var id: String = str(activity_id)
		var activity: Dictionary = DataManager.get_activity(id)
		add_bottom_action(activity.get("name", id), func(): do_activity(id))

	if actions.get("train", false):
		add_bottom_action("Entrenar", func(): do_train(location_data))

	if actions.get("work_full", false):
		add_bottom_action("Trabajar jornada completa", func(): do_work_full())

	if actions.get("work_half", false):
		add_bottom_action("Trabajar medio turno", func(): do_work_half())

	if actions.get("rest", false):
		add_bottom_action("Descansar", func(): do_rest())

	if actions.get("shop", false):
		add_bottom_action("Comprar", func(): SceneRouter.go_to_shop())

	if bottom_actions.get_child_count() == 0:
		bottom_description_label.text = "No hay acciones disponibles aquí por ahora."

	add_bottom_action("Volver", func(): show_location_overview(DataManager.get_location(current_location_id)))


func show_character_preview(npc_id: String) -> void:
	if selected_npc_id != "":
		return

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var display_name: String = get_npc_display_name(npc_id)

	bottom_title_label.text = display_name

	if is_npc_known(npc_id):
		bottom_description_label.text = "Está aquí. Puedes acercarte y decidir cómo relacionarte con %s." % npc.get("name", npc_id)
	else:
		bottom_description_label.text = "Ves a alguien en esta zona, pero todavía no sabes quién es."

	clear_bottom_actions()
	add_bottom_action("Acercarse", func(): select_npc(npc_id))
	add_bottom_action("Acciones del lugar", func(): show_location_actions(DataManager.get_location(current_location_id)))


func select_npc(npc_id: String) -> void:
	selected_npc_id = npc_id

	GameManager.mark_npc_seen(npc_id)
	GameManager.reveal_npc_schedule(npc_id, "%s:%s" % [
		ScheduleSystem.get_day_type(),
		GameManager.current_time_block
	])

	refresh_character_labels()
	interact_npc(npc_id)

func refresh_character_labels() -> void:
	for character_button in character_layer.get_children():
		if not character_button.has_meta("npc_id"):
			continue

		var npc_id: String = str(character_button.get_meta("npc_id"))
		var label: Label = character_button.get_meta("name_label") as Label

		if label != null:
			label.text = get_npc_display_name(npc_id)

		character_button.tooltip_text = get_npc_display_name(npc_id)
		
func interact_npc(npc_id: String) -> void:
	clear_bottom_actions()

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = npc.get("name", npc_id)

	bottom_title_label.text = npc_name
	bottom_description_label.text = "¿Qué quieres hacer con %s?" % npc_name

	add_bottom_action("Hablar", func(): talk_to_npc(npc_id), GameManager.is_day_exhausted())
	add_bottom_action("Regalar", func(): show_gift_selection(npc_id), GameManager.is_day_exhausted())

	var petition_disabled: bool = GameManager.is_day_exhausted() or not PetitionSystem.has_any_available_petition(npc_id)
	add_bottom_action("Pedir favor", func(): show_petitions(npc_id), petition_disabled)

	var date_disabled: bool = GameManager.is_day_exhausted() or not GameManager.can_invite_to_date(npc_id)
	add_bottom_action("Invitar a cita", func(): show_date_location_selection(npc_id), date_disabled)

	var step_id: String = RelationshipSystem.get_next_step_id(npc_id)

	if step_id != "":
		var step: Dictionary = DataManager.get_relationship_step(step_id)
		var can_start_special: bool = RelationshipSystem.can_start_step(npc_id, step_id)

		add_bottom_action(
			"Avance: %s" % step.get("name", step_id),
			func(): SceneRouter.go_to_date(npc_id, "", "special", step_id),
			GameManager.is_day_exhausted() or not can_start_special
		)

		if can_start_special:
			bottom_description_label.text += "\n\nPuedes intentar avanzar la relación. Esta cita especial pondrá a prueba cuánto conoces realmente a %s." % npc_name
		else:
			var reason: String = RelationshipSystem.get_blocked_reason(npc_id, step_id)

			if reason != "":
				bottom_description_label.text += "\n\nAvance especial bloqueado por ahora."

	add_bottom_action("Cerrar", func():
		selected_npc_id = ""
		show_location_overview(DataManager.get_location(current_location_id))
	)


func show_gift_selection(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var npc: Dictionary = DataManager.get_npc(npc_id)

	clear_bottom_actions()
	bottom_title_label.text = "Regalo para %s" % npc.get("name", npc_id)

	if relation.get("gift_given_today", false):
		bottom_description_label.text = "Ya le diste un regalo hoy."
	else:
		var gifts: Array = GameManager.get_gift_items_in_inventory()

		if gifts.is_empty():
			bottom_description_label.text = "No tienes regalos disponibles."
		else:
			bottom_description_label.text = "Elige con cuidado. Un regalo puede acercar... o alejar."

			for entry in gifts:
				var item_entry: Dictionary = entry
				var item_id: String = item_entry.get("item_id", "")
				var amount: int = int(item_entry.get("amount", 0))
				var item_data: Dictionary = DataManager.get_item(item_id)

				add_bottom_action("%s x%s" % [
					item_data.get("name", item_id),
					amount
				], func(): give_gift(npc_id, item_id))

	add_bottom_action("Volver", func(): interact_npc(npc_id))


func show_petitions(npc_id: String) -> void:
	clear_bottom_actions()

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var petition_ids: Array = PetitionSystem.get_available_petitions(npc_id)

	bottom_title_label.text = "Pedir favor a %s" % npc.get("name", npc_id)

	if petition_ids.is_empty():
		bottom_description_label.text = "No hay nada que puedas pedirle ahora."
	else:
		bottom_description_label.text = "Algunas peticiones cruzan una línea. Elige con cuidado."

		for petition_id in petition_ids:
			var id: String = str(petition_id)
			var petition: Dictionary = DataManager.get_petition(id)
			add_bottom_action(petition.get("name", id), func(): confirm_petition(id))

	add_bottom_action("Volver", func(): interact_npc(npc_id))


func confirm_petition(petition_id: String) -> void:
	clear_bottom_actions()

	var petition: Dictionary = DataManager.get_petition(petition_id)
	var npc_id: String = petition.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)

	bottom_title_label.text = npc.get("name", npc_id)
	bottom_description_label.text = petition.get("request_text", "")

	add_bottom_action("Hacer la petición", func(): perform_petition(petition_id))
	add_bottom_action("No todavía", func(): interact_npc(npc_id))


func show_date_location_selection(npc_id: String) -> void:
	clear_bottom_actions()

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var available_locations: Array = DateSystem.get_available_date_locations(npc_id)

	bottom_title_label.text = "Invitar a cita a %s" % npc.get("name", npc_id)

	if available_locations.is_empty():
		bottom_description_label.text = "Hay intención de invitarle, pero todavía no tienes un lugar adecuado para esta cita. Mejora el vínculo, descubre más información o prueba en otro momento."
	else:
		bottom_description_label.text = "Elige un lugar. El ambiente puede cambiarlo todo."

		for date_location_id in available_locations:
			var id: String = str(date_location_id)
			var date_location: Dictionary = DataManager.get_date_location(id)
			add_bottom_action(date_location.get("name", id), func(): SceneRouter.go_to_date(npc_id, id))

	add_bottom_action("Volver", func(): interact_npc(npc_id))


func give_gift(npc_id: String, item_id: String) -> void:
	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return

	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	if relation.get("gift_given_today", false):
		show_location_message("Regalo no disponible", "Ya le diste un regalo hoy.")
		return

	if not GameManager.has_item(item_id):
		show_location_message("Regalo no disponible", "Ya no tienes ese objeto.")
		return

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var item: Dictionary = DataManager.get_item(item_id)
	var prefs: Dictionary = npc.get("gift_preferences", {})

	var result: int = 0
	var reaction: String = ""
	var gift_strategy: String = "gift_neutral"

	if item_id in prefs.get("loves", []):
		result = randi_range(5, 6)
		reaction = "Su reacción lo dice todo. Has tocado una fibra muy personal."
		gift_strategy = "gift_loved"

		GameManager.record_emotional_date(
			npc_id,
			"first_loved_gift",
			"Primer regalo amado"
		)

	elif item_id in prefs.get("likes", []):
		result = randi_range(3, 4)
		reaction = "Acepta el regalo con una calidez difícil de fingir."
		gift_strategy = "gift_liked"
	elif item_id in prefs.get("hates", []):
		result = randi_range(-5, -4)
		reaction = "La incomodidad aparece de inmediato. Fue una mala elección."
		gift_strategy = "gift_hated"
	else:
		result = randi_range(1, 2)
		reaction = "Acepta el gesto con cortesía."
		gift_strategy = "gift_neutral"

	var relationship_text: String = ""

	if result > 0:
		relationship_text += GameManager.add_relationship_value(npc_id, "friendship", result)

		if result >= 3:
			var tension_bonus: int = 1
			relationship_text += GameManager.add_relationship_value(npc_id, "tension", tension_bonus)
	else:
		relationship_text += GameManager.add_relationship_value(npc_id, "friendship", result)
		relationship_text += GameManager.add_relationship_value(npc_id, "jealousy", 2)

	relation["gift_given_today"] = true

	GameManager.remove_item(item_id, 1)
	GameManager.reveal_npc_gift(npc_id, item_id)

	var message: String = "%s\nRegalo: %s\nAmistad: %+d%s" % [
		reaction,
		item.get("name", item_id),
		result,
		relationship_text
	]

	var reveal_chance: float = 0.25

	match gift_strategy:
		"gift_loved":
			reveal_chance = 0.85
		"gift_liked":
			reveal_chance = 0.60
		"gift_neutral":
			reveal_chance = 0.25
		"gift_hated":
			reveal_chance = 0.55

	if randf() < reveal_chance:
		var info_key: String = GameManager.reveal_npc_info_by_strategy(npc_id, {
			"strategy": gift_strategy,
			"max_tier": 90,
			"include_next_step_missing": true
		})

		if info_key != "":
			message += "\n\n" + GameManager.format_discovered_info(npc_id, info_key)

	var postgame_gift_text: String = process_postgame_gift_effect(npc_id, gift_strategy)

	if postgame_gift_text != "":
		message += "\n\n" + postgame_gift_text

	GameManager.consume_action(5)
	SaveManager.autosave_game()
	reload_scene(message)


func talk_to_npc(npc_id: String) -> void:
	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return

	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)

	var friendship_gain: int = randi_range(2, 4)
	var tension_gain: int = 0

	if randf() < 0.35:
		tension_gain = 1

	var relationship_text: String = GameManager.add_relationship_value(npc_id, "friendship", friendship_gain)

	if tension_gain > 0:
		relationship_text += GameManager.add_relationship_value(npc_id, "tension", tension_gain)

	var dialogue_line: String = DialogueSystem.get_dialogue_line(npc_id, "casual")

	var message: String = "%s\n\nAmistad +%s" % [
		dialogue_line,
		friendship_gain
	]

	if tension_gain > 0:
		message += "\nTensión +%s" % tension_gain

	message += relationship_text

	var reveal_chance: float = 0.45

	if not GameManager.get_missing_info_for_next_relationship_step(npc_id, 60).is_empty():
		reveal_chance = 0.75

	if randf() < reveal_chance:
		var info_key: String = GameManager.reveal_npc_info_by_strategy(npc_id, {
			"strategy": "talk",
			"max_tier": 70,
			"include_next_step_missing": true
		})

		if info_key != "":
			message += "\n\n" + GameManager.format_discovered_info(npc_id, info_key)

	GameManager.add_npc_note(
		npc_id,
		"Una conversación casual dejó ver algo más profundo de %s." % npc.get("name", npc_id)
	)

	GameManager.consume_action(5)
	SaveManager.autosave_game()
	reload_scene(message)


func do_activity(activity_id: String) -> void:
	if GameManager.is_day_exhausted():
		reload_scene("Ya no te queda tiempo útil hoy. Deberías volver a casa y dormir.")
		return

	var result_message: String = GameManager.perform_activity(activity_id)
	SaveManager.autosave_game()
	reload_scene(result_message)


func do_train(location_data: Dictionary) -> void:
	var stat: String = location_data.get("train_stat", "intellect")
	GameManager.player["stats"][stat] += 1
	GameManager.consume_action(10)
	reload_scene("Entrenas y mejoras %s." % stat)


func do_work_full() -> void:
	GameManager.player["money"] += 20
	GameManager.consume_action(25)
	reload_scene("Trabajas una jornada completa.\nDinero +20")


func do_work_half() -> void:
	GameManager.player["money"] += 10
	GameManager.consume_action(15)
	reload_scene("Trabajas medio turno.\nDinero +10")


func do_rest() -> void:
	GameManager.player["stamina"] = min(
		int(GameManager.player.get("stamina", 0)) + 20,
		int(GameManager.player.get("max_stamina", 100))
	)
	GameManager.consume_action(5)
	reload_scene("Descansas un momento.\nResistencia +20")


func perform_petition(petition_id: String) -> void:
	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return

	var result: Dictionary = PetitionSystem.perform_petition(petition_id)
	var petition: Dictionary = DataManager.get_petition(petition_id)
	var npc_id: String = petition.get("npc_id", "")

	GameManager.consume_action(5)
	GameManager.add_npc_note(
		npc_id,
		"Una petición cruzó un límite y dejó consecuencias."
	)

	SaveManager.autosave_game()
	reload_scene(result.get("text", "La petición terminó."))


func process_postgame_gift_effect(npc_id: String, gift_strategy: String) -> String:
	if not PostgameSystem.is_postgame_started():
		return ""

	var partner_id: String = PostgameSystem.get_partner_id()

	if partner_id == npc_id:
		match gift_strategy:
			"gift_loved":
				return PostgameSystem.strengthen_final_union(
					4,
					"El regalo tocó algo importante en tu unión definitiva."
				)
			"gift_liked":
				return PostgameSystem.strengthen_final_union(
					2,
					"El gesto cuidó la unión definitiva."
				)
			"gift_hated":
				return PostgameSystem.strain_final_union(
					4,
					"El regalo hirió una zona sensible de la unión definitiva."
				)
			_:
				return ""

	var strain: int = 0

	match gift_strategy:
		"gift_loved":
			strain = 2
		"gift_liked":
			strain = 1
		_:
			strain = 0

	if strain <= 0:
		return ""

	PostgameSystem.add_postgame_state_value("outside_temptation", strain)

	return PostgameSystem.strain_final_union(
		strain,
		"Dar regalos significativos a otra persona después de una unión definitiva genera tensión."
	)

func reload_scene(message: String = "") -> void:
	SaveManager.autosave_game()

	if message == "":
		show_location_overview(DataManager.get_location(current_location_id))
		return

	last_message = message
	show_location_message(
		DataManager.get_location(current_location_id).get("name", current_location_id),
		message
	)

	hud_bar.refresh()
	
func show_location_message(title: String, message: String) -> void:
	selected_npc_id = ""
	clear_bottom_actions()

	bottom_title_label.text = title
	bottom_description_label.text = message

	add_bottom_action(
		"Continuar en la ubicación",
		func(): show_location_overview(DataManager.get_location(current_location_id))
	)

	add_bottom_action(
		"Acciones del lugar",
		func(): show_location_actions(DataManager.get_location(current_location_id))
	)

	add_bottom_action("Volver al mapa", func(): _on_back_pressed())

func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	show_location_message(
		"El Velo se agita",
		combined_text.strip_edges()
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


func add_global_action(text: String, callback: Callable) -> void:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	global_action_buttons.add_child(button)


func add_bottom_action(text: String, callback: Callable, disabled: bool = false) -> void:
	var button: Button = Button.new()
	button.text = text
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(110, 34)

	if not disabled:
		button.pressed.connect(callback)

	bottom_actions.add_child(button)


func clear_bottom_actions() -> void:
	clear_children(bottom_actions)


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func is_npc_known(npc_id: String) -> bool:
	if not GameManager.player.has("known_npc_info"):
		return false

	if not GameManager.player["known_npc_info"].has(npc_id):
		return false

	var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]
	return bool(knowledge.get("profile_seen", false))


func get_npc_display_name(npc_id: String) -> String:
	if not is_npc_known(npc_id):
		return "???"

	var npc: Dictionary = DataManager.get_npc(npc_id)
	return str(npc.get("name", npc_id))


func get_scaled_character_size() -> Vector2:
	var scale_value: float = get_location_scale()
	var size_value: Vector2 = CHARACTER_BASE_SIZE * scale_value

	var min_width: float = 82.0
	var min_height: float = 132.0

	if location_layer.size.x >= 900:
		min_width = 116.0
		min_height = 184.0
	elif location_layer.size.x >= 700:
		min_width = 98.0
		min_height = 158.0

	return Vector2(
		max(size_value.x, min_width),
		max(size_value.y, min_height)
	)

func get_stable_character_position(npc_id: String, index: int, total: int, character_size: Vector2) -> Vector2:
	if not character_positions_by_location.has(current_location_id):
		character_positions_by_location[current_location_id] = {}

	var location_positions: Dictionary = character_positions_by_location[current_location_id]

	if location_positions.has(npc_id):
		var stored_position: Vector2 = location_positions[npc_id]
		return clamp_character_position(stored_position, character_size)

	var position_value: Vector2 = get_character_position(index, total, character_size)
	location_positions[npc_id] = position_value

	return position_value

func clamp_character_position(position_value: Vector2, character_size: Vector2) -> Vector2:
	var margin: float = 8.0
	var max_x: float = max(margin, location_layer.size.x - character_size.x - margin)
	var max_y: float = max(margin, location_layer.size.y - character_size.y - margin)

	return Vector2(
		clamp(position_value.x, margin, max_x),
		clamp(position_value.y, margin, max_y)
	)
	
func get_character_position(index: int, total: int, character_size: Vector2) -> Vector2:
	var safe_width: float = max(location_layer.size.x, 1.0)
	var safe_height: float = max(location_layer.size.y, 1.0)

	var usable_width: float = safe_width * 0.76
	var start_x: float = (safe_width - usable_width) * 0.5

	var gap: float = 18.0

	if total > 1:
		gap = min(34.0, usable_width / float(total) * 0.12)

	var total_width: float = float(total) * character_size.x + float(max(total - 1, 0)) * gap
	var x: float = start_x + ((usable_width - total_width) * 0.5) + float(index) * (character_size.x + gap)

	var floor_y: float = safe_height - character_size.y - get_bottom_panel_reserved_height()

	if safe_height < 520:
		floor_y = safe_height - character_size.y - 118.0

	var y: float = max(62.0, floor_y)

	return Vector2(
		clamp(x, 8.0, max(8.0, safe_width - character_size.x - 8.0)),
		clamp(y, 54.0, max(54.0, safe_height - character_size.y - 8.0))
	)


func get_bottom_panel_reserved_height() -> float:
	if location_layer.size.x < 760:
		return 220.0

	return 204.0


func get_location_scale() -> float:
	var safe_width: float = max(location_layer.size.x, 1.0)
	var safe_height: float = max(location_layer.size.y, 1.0)

	var scale_x: float = safe_width / BASE_LOCATION_SIZE.x
	var scale_y: float = safe_height / BASE_LOCATION_SIZE.y

	return min(scale_x, scale_y)


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func layout_overlay_controls() -> void:
	if global_action_panel == null or bottom_panel == null or location_layer == null:
		return

	var margin: float = 10.0

	var global_width: float = 360.0
	if location_layer.size.x < 760:
		global_width = 270.0

	global_action_panel.size = Vector2(global_width, 46)
	global_action_panel.position = Vector2(
		max(margin, location_layer.size.x - global_width - margin),
		margin
	)

	var panel_width: float = min(820.0, max(420.0, location_layer.size.x - 24.0))
	var panel_height: float = 190.0

	if location_layer.size.x < 760:
		panel_width = max(360.0, location_layer.size.x - 24.0)
		panel_height = 206.0

	bottom_panel.size = Vector2(panel_width, panel_height)
	bottom_panel.position = Vector2(
		12.0,
		max(12.0, location_layer.size.y - panel_height - 12.0)
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if location_layer != null:
			call_deferred("refresh_layout_after_frame")
			call_deferred("rebuild_characters")


func _on_back_pressed() -> void:
	SceneRouter.go_to_world_map()


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
