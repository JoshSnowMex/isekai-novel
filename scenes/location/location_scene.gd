extends Control

var title_label: Label
var description_label: Label
var action_container: VBoxContainer
var npc_container: VBoxContainer

var current_location_id: String = ""
var last_message: String = ""

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	load_location(GameManager.current_location_id)

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	var back_button: Button = UIFactory.button("← Volver al mapa")
	back_button.pressed.connect(_on_back_pressed)
	root.add_child(back_button)

	title_label = UIFactory.title("")
	root.add_child(title_label)

	description_label = UIFactory.body("")
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	root.add_child(description_label)

	var action_label: Label = UIFactory.body("Acciones")
	root.add_child(action_label)

	var action_scroll: ScrollContainer = ScrollContainer.new()
	action_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	action_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(action_scroll)

	action_container = VBoxContainer.new()
	action_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 10)
	action_scroll.add_child(action_container)

	var npc_label: Label = UIFactory.body("Personas aquí")
	root.add_child(npc_label)

	npc_container = VBoxContainer.new()
	npc_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	npc_container.alignment = BoxContainer.ALIGNMENT_CENTER
	npc_container.add_theme_constant_override("separation", 10)
	root.add_child(npc_container)

func load_location(location_id: String, message: String = "") -> void:
	current_location_id = location_id

	var data: Dictionary = DataManager.get_location(location_id)

	title_label.text = data.get("name", location_id)

	if message != "":
		last_message = message
		description_label.text = message
	elif last_message != "":
		description_label.text = last_message
	else:
		description_label.text = data.get("description", "")

	build_actions(data)
	build_npcs()

func build_actions(location_data: Dictionary) -> void:
	clear_container(action_container)

	var actions: Dictionary = location_data.get("actions", {})
	var activities: Array = location_data.get("activities", [])

	for activity_id in activities:
		var id: String = str(activity_id)
		var activity: Dictionary = DataManager.get_activity(id)
		add_action(activity.get("name", id), func(): do_activity(id))

	if actions.get("train", false):
		add_action("Entrenar", func(): do_train(location_data))

	if actions.get("work_full", false):
		add_action("Trabajar jornada completa", func(): do_work_full())

	if actions.get("work_half", false):
		add_action("Trabajar medio turno", func(): do_work_half())

	if actions.get("rest", false):
		add_action("Descansar", func(): do_rest())

	if actions.get("shop", false):
		add_action("Comprar", func(): SceneRouter.go_to_shop())

	if action_container.get_child_count() == 0:
		action_container.add_child(UIFactory.body("No hay acciones disponibles aquí por ahora."))

func build_npcs() -> void:
	clear_container(npc_container)

	for npc_id in DataManager.npcs.keys():
		var npc: Dictionary = DataManager.get_npc(npc_id)
		var time: String = GameManager.current_time_block
		var npc_location_id: String = ScheduleSystem.get_npc_location(npc_id)

		if npc_location_id == current_location_id:
			GameManager.mark_npc_seen(npc_id)
			GameManager.reveal_npc_schedule(npc_id, "%s:%s" % [
				ScheduleSystem.get_day_type(),
				time
			])

			var button: Button = UIFactory.button(npc.get("name", npc_id))
			button.pressed.connect(func(): interact_npc(npc_id))
			npc_container.add_child(button)

	if npc_container.get_child_count() == 0:
		npc_container.add_child(UIFactory.body("No ves a nadie conocido aquí en este momento."))

func add_action(text: String, callback: Callable, allow_when_exhausted: bool = false) -> void:
	var button: Button = UIFactory.button(text)
	button.disabled = GameManager.is_day_exhausted() and not allow_when_exhausted
	button.pressed.connect(callback)
	action_container.add_child(button)

func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

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

func interact_npc(npc_id: String) -> void:
	clear_container(action_container)

	var npc: Dictionary = DataManager.get_npc(npc_id)

	action_container.add_child(UIFactory.title(npc.get("name", npc_id)))

	var talk_button: Button = UIFactory.button("Hablar")
	talk_button.disabled = GameManager.is_day_exhausted()
	talk_button.pressed.connect(func(): talk_to_npc(npc_id))
	action_container.add_child(talk_button)

	var gift_button: Button = UIFactory.button("Dar regalo")
	gift_button.disabled = GameManager.is_day_exhausted()
	gift_button.pressed.connect(func(): show_gift_selection(npc_id))
	action_container.add_child(gift_button)

	var can_date: bool = GameManager.can_invite_to_date(npc_id)

	if can_date:
		var date_button: Button = UIFactory.button("Invitar a cita")
		date_button.disabled = GameManager.is_day_exhausted()
		date_button.pressed.connect(func(): show_date_location_selection(npc_id))
		action_container.add_child(date_button)
	
	var step_id: String = RelationshipSystem.get_next_step_id(npc_id)

	if step_id != "":
		var step: Dictionary = DataManager.get_relationship_step(step_id)
		var can_start_special: bool = RelationshipSystem.can_start_step(npc_id, step_id)

		var special_button: Button = UIFactory.button("Avance de relación: %s" % step.get("name", step_id))
		special_button.disabled = GameManager.is_day_exhausted() or not can_start_special
		special_button.pressed.connect(func(): SceneRouter.go_to_date(npc_id, "", "special", step_id))
		action_container.add_child(special_button)

		if can_start_special:
			action_container.add_child(UIFactory.body("Puedes intentar avanzar la relación. Esta cita especial pondrá a prueba cuánto conoces realmente a %s." % npc.get("name", npc_id)))
		else:
			var reason: String = RelationshipSystem.get_blocked_reason(npc_id, step_id)

			if reason != "":
				action_container.add_child(UIFactory.body("Avance bloqueado:\n%s" % reason))
	
	var petition_button: Button = UIFactory.button("Pedir favor")
	petition_button.disabled = GameManager.is_day_exhausted() or not PetitionSystem.has_any_available_petition(npc_id)
	petition_button.pressed.connect(func(): show_petitions(npc_id))
	action_container.add_child(petition_button)

	var back_button: Button = UIFactory.button("Volver")
	back_button.pressed.connect(func(): load_location(current_location_id))
	action_container.add_child(back_button)

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

func show_gift_selection(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	clear_container(action_container)

	var npc: Dictionary = DataManager.get_npc(npc_id)

	action_container.add_child(UIFactory.title("Regalo para %s" % npc.get("name", npc_id)))

	if relation.get("gift_given_today", false):
		description_label.text = "Ya le diste un regalo hoy."
	else:
		var gifts: Array = GameManager.get_gift_items_in_inventory()

		if gifts.is_empty():
			description_label.text = "No tienes regalos disponibles."
		else:
			description_label.text = "Elige con cuidado. Un regalo puede acercar... o alejar."

			for entry in gifts:
				var item_entry: Dictionary = entry
				var item_id: String = item_entry.get("item_id", "")
				var amount: int = int(item_entry.get("amount", 0))
				var item_data: Dictionary = DataManager.get_item(item_id)

				var button: Button = UIFactory.button("%s x%s" % [
					item_data.get("name", item_id),
					amount
				])
				button.pressed.connect(func(): give_gift(npc_id, item_id))
				action_container.add_child(button)

	var back_button: Button = UIFactory.button("Volver")
	back_button.pressed.connect(func(): interact_npc(npc_id))
	action_container.add_child(back_button)

func give_gift(npc_id: String, item_id: String) -> void:
	if not GameManager.can_perform_action(5):
		reload_scene(GameManager.get_action_blocked_message(5))
		return
	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	if relation.get("gift_given_today", false):
		description_label.text = "Ya le diste un regalo hoy."
		return

	if not GameManager.has_item(item_id):
		description_label.text = "Ya no tienes ese objeto."
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

func reload_scene(message: String = "") -> void:
	SaveManager.autosave_game()
	load_location(current_location_id, message)

func _on_back_pressed() -> void:
	SceneRouter.go_to_world_map()

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

func show_petitions(npc_id: String) -> void:
	clear_container(action_container)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var petition_ids: Array = PetitionSystem.get_available_petitions(npc_id)

	action_container.add_child(UIFactory.title("Pedir favor a %s" % npc.get("name", npc_id)))

	if petition_ids.is_empty():
		description_label.text = "No hay nada que puedas pedirle ahora."
	else:
		description_label.text = "Algunas peticiones cruzan una línea. Elige con cuidado."

		for petition_id in petition_ids:
			var id: String = str(petition_id)
			var petition: Dictionary = DataManager.get_petition(id)
			var button: Button = UIFactory.button(petition.get("name", id))
			button.pressed.connect(func(): confirm_petition(id))
			action_container.add_child(button)

	var back_button: Button = UIFactory.button("Volver")
	back_button.pressed.connect(func(): interact_npc(npc_id))
	action_container.add_child(back_button)

func confirm_petition(petition_id: String) -> void:
	clear_container(action_container)

	var petition: Dictionary = DataManager.get_petition(petition_id)
	var npc_id: String = petition.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)

	description_label.text = "%s\n\n%s" % [
		npc.get("name", npc_id),
		petition.get("request_text", "")
	]

	var accept_button: Button = UIFactory.button("Hacer la petición")
	accept_button.pressed.connect(func(): perform_petition(petition_id))
	action_container.add_child(accept_button)

	var cancel_button: Button = UIFactory.button("No todavía")
	cancel_button.pressed.connect(func(): interact_npc(npc_id))
	action_container.add_child(cancel_button)

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

func show_date_location_selection(npc_id: String) -> void:
	clear_container(action_container)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var available_locations: Array = DateSystem.get_available_date_locations(npc_id)

	action_container.add_child(UIFactory.title("Invitar a cita a %s" % npc.get("name", npc_id)))

	if available_locations.is_empty():
		description_label.text = "Hay intención de invitarle, pero todavía no tienes un lugar adecuado para esta cita. Mejora el vínculo, descubre más información o prueba en otro momento."
	else:
		description_label.text = "Elige un lugar. El ambiente puede cambiarlo todo."

		for date_location_id in available_locations:
			var id: String = str(date_location_id)
			var date_location: Dictionary = DataManager.get_date_location(id)
			var button: Button = UIFactory.button(date_location.get("name", id))
			button.pressed.connect(func(): SceneRouter.go_to_date(npc_id, id))
			action_container.add_child(button)

	var back_button: Button = UIFactory.button("Volver")
	back_button.pressed.connect(func(): interact_npc(npc_id))
	action_container.add_child(back_button)
