extends Control

var title_label: Label
var description_label: Label
var action_container: VBoxContainer

var current_date: Dictionary = {}

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()

	if SceneRouter.temp_date_type == "special":
		start_special_date(SceneRouter.temp_npc_id, SceneRouter.temp_relationship_step_id)
	else:
		start_date(SceneRouter.temp_npc_id, SceneRouter.temp_date_location_id)

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	title_label = UIFactory.title("")
	root.add_child(title_label)

	var description_scroll: ScrollContainer = ScrollContainer.new()
	description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	root.add_child(description_scroll)

	description_label = UIFactory.body("")
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_scroll.add_child(description_label)

	action_container = VBoxContainer.new()
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 8)
	action_container.custom_minimum_size = Vector2(1, 150)
	root.add_child(action_container)

func start_date(npc_id: String, date_location_id: String = "") -> void:
	if date_location_id == "":
		var available: Array = DateSystem.get_available_date_locations(npc_id)

		if available.is_empty():
			SceneRouter.go_to_world_map()
			return

		date_location_id = str(available[0])

	current_date = DateSystem.create_date_state(npc_id, date_location_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)

	title_label.text = "Cita con %s" % npc.get("name", npc_id)

	description_label.text = "%s\n\n%s\n\nProgreso inicial: %s" % [
		date_location.get("name", date_location_id),
		date_location.get("description", ""),
		current_date.get("progress", 0)
	]

	build_actions()

func start_special_date(npc_id: String, step_id: String) -> void:
	current_date = RelationshipSystem.create_special_date_state(npc_id, step_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	title_label.text = "Cita especial con %s" % npc.get("name", npc_id)

	description_label.text = "%s\n\n%s\n\nPara avanzar, deberás responder correctamente sobre lo que conoces de %s." % [
		step.get("name", step_id),
		step.get("description", ""),
		npc.get("name", npc_id)
	]

	build_special_actions()

func build_actions() -> void:
	clear_container(action_container)

	var talk_button: Button = UIFactory.button("Hablar")
	talk_button.disabled = not DateSystem.can_talk(current_date)
	talk_button.pressed.connect(func(): do_talk())
	action_container.add_child(talk_button)

	var gift_button: Button = UIFactory.button("Dar regalo")
	gift_button.disabled = not DateSystem.can_gift(current_date)
	gift_button.pressed.connect(func(): do_gift())
	action_container.add_child(gift_button)

	var move_button: Button = UIFactory.button("Hacer movimiento")
	move_button.disabled = not DateSystem.can_move(current_date)
	move_button.pressed.connect(func(): show_move_selection())
	action_container.add_child(move_button)

	add_action("Terminar cita", func(): end_date())

func build_special_actions() -> void:
	clear_container(action_container)

	if RelationshipSystem.is_special_date_complete(current_date):
		add_action("Cerrar la conversación", func(): end_special_date())
	else:
		add_action("Responder", func(): do_special_question())
		add_action("Cancelar", func(): cancel_special_date())

func add_action(text: String, callback: Callable) -> void:
	var button: Button = UIFactory.button(text)
	button.pressed.connect(callback)
	action_container.add_child(button)

func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func do_special_question() -> void:
	var q: Dictionary = RelationshipSystem.build_special_question(current_date)

	if q.is_empty():
		description_label.text = "Aunque has llegado hasta aquí, aún no conoces suficiente información aplicable para sostener esta conversación."
		build_special_actions()
		return

	clear_container(action_container)

	description_label.text = q.get("question", "")

	for option in q.get("options", []):
		var value: String = str(option)
		var button: Button = UIFactory.button(value)
		button.pressed.connect(func(): answer_special_question(q, value))
		action_container.add_child(button)

func answer_special_question(question: Dictionary, selected: String) -> void:
	var result: Dictionary = RelationshipSystem.answer_special_question(current_date, question, selected)

	description_label.text = "%s\n\nProgreso especial: %s/%s\nErrores: %s" % [
		result.get("text", ""),
		current_date.get("progress", 0),
		current_date.get("questions_required", 0),
		current_date.get("mistakes", 0)
	]

	GameManager.consume_action(3)
	SaveManager.save_game()
	build_special_actions()

func end_special_date() -> void:
	var result: Dictionary = RelationshipSystem.finish_special_date(current_date)
	SaveManager.save_game()
	show_final_summary(result.get("text", "La cita especial terminó."))

func cancel_special_date() -> void:
	show_final_summary("Decides no continuar con esta cita especial por ahora.\n\nA veces, no forzar una respuesta también protege el vínculo.")

func do_talk() -> void:
	if not DateSystem.can_talk(current_date):
		description_label.text = "La conversación ya dio todo lo que podía dar en esta cita."
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
	clear_container(action_container)

	description_label.text = q["question"]

	for option in q["options"]:
		var value: String = str(option)
		var button: Button = UIFactory.button(value)
		button.pressed.connect(func(): answer_question(q, value))
		action_container.add_child(button)

	var back_button: Button = UIFactory.button("No responder")
	back_button.pressed.connect(func(): build_actions())
	action_container.add_child(back_button)

func do_gift() -> void:
	if not DateSystem.can_gift(current_date):
		description_label.text = "Ya diste un regalo durante esta cita."
		build_actions()
		return

	var gifts: Array = GameManager.get_gift_items_in_inventory()

	clear_container(action_container)

	if gifts.is_empty():
		description_label.text = "No tienes regalos disponibles."
		var back_button: Button = UIFactory.button("Volver")
		back_button.pressed.connect(func(): build_actions())
		action_container.add_child(back_button)
		return

	description_label.text = "Elige un regalo para la cita."

	for entry in gifts:
		var item_entry: Dictionary = entry
		var item_id: String = item_entry.get("item_id", "")
		var amount: int = int(item_entry.get("amount", 0))
		var item_data: Dictionary = DataManager.get_item(item_id)

		var button: Button = UIFactory.button("%s x%s" % [
			item_data.get("name", item_id),
			amount
		])
		button.pressed.connect(func(): give_date_gift(item_id))
		action_container.add_child(button)

	var back_button: Button = UIFactory.button("Volver")
	back_button.pressed.connect(func(): build_actions())
	action_container.add_child(back_button)

func give_date_gift(item_id: String) -> void:
	if not DateSystem.can_gift(current_date):
		description_label.text = "Ya diste un regalo durante esta cita."
		build_actions()
		return

	var npc_id: String = current_date["npc_id"]

	if not GameManager.has_item(item_id):
		description_label.text = "Ya no tienes ese objeto."
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

	description_label.text = "%s\nRegalo: %s\nProgreso %+d" % [
		message,
		item.get("name", item_id),
		progress_change
	]

	build_actions()
	refresh()

func show_move_selection() -> void:
	clear_container(action_container)

	var move_ids: Array = DateSystem.get_available_moves(current_date)

	description_label.text = "Elige un gesto. No todos los movimientos son buena idea solo porque puedas intentarlos."

	if move_ids.is_empty():
		description_label.text = "Ya no conviene intentar más movimientos en esta cita."
	else:
		for move_id in move_ids:
			var id: String = str(move_id)
			var move: Dictionary = DataManager.get_date_move(id)
			var button: Button = UIFactory.button(move.get("name", id))
			button.pressed.connect(func(): perform_move(id))
			action_container.add_child(button)

	var back_button: Button = UIFactory.button("Volver")
	back_button.pressed.connect(func(): build_actions())
	action_container.add_child(back_button)

func perform_move(move_id: String) -> void:
	var result: Dictionary = DateSystem.perform_move(current_date, move_id)

	GameManager.consume_action(4)
	SaveManager.save_game()

	description_label.text = "%s\n\nProgreso actual: %s\nMovimientos usados: %s/%s" % [
		result.get("text", ""),
		current_date.get("progress", 0),
		current_date.get("moves_used", []).size(),
		DateSystem.NORMAL_DATE_MAX_MOVES
	]

	build_actions()
	refresh()

func end_date() -> void:
	var result: Dictionary = DateSystem.finish_date(current_date)
	SaveManager.save_game()
	show_final_summary(result.get("text", "La cita terminó."))

func refresh() -> void:
	current_date["progress"] = clamp(current_date["progress"], 0, 100)

	var npc_id: String = current_date.get("npc_id", "")
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var date_location_id: String = current_date.get("date_location_id", "")
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)

	title_label.text = "Cita con %s · %s · Progreso: %s" % [
		npc.get("name", npc_id),
		date_location.get("name", date_location_id),
		current_date["progress"]
	]

func do_random_dialogue() -> void:
	var npc_id: String = current_date["npc_id"]
	var dialogue_line: String = DialogueSystem.get_dialogue_line(npc_id, "casual")

	current_date["progress"] = clamp(int(current_date["progress"]) + 5, 0, 100)
	description_label.text = "%s\n\nLa conversación acerca la cita.\nProgreso +5\nConversaciones usadas: %s/%s" % [
		dialogue_line,
		current_date.get("talks_used", 0),
		DateSystem.NORMAL_DATE_MAX_TALKS
	]

	GameManager.consume_action(3)
	SaveManager.save_game()
	refresh()
	build_actions()

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

func answer_question(question: Dictionary, selected: String) -> void:
	var correct: String = question["correct"]
	var npc_id: String = current_date["npc_id"]

	clear_container(action_container)

	if selected == correct:
		var relationship_text: String = GameManager.add_relationship_value(npc_id, "friendship", 2)

		current_date["progress"] = clamp(current_date["progress"] + 15, 0, 100)
		description_label.text = "Respondes sin dudar.\nLa reacción es inmediata… y claramente favorable.\nAmistad +2%s" % relationship_text
	else:
		var relationship_text: String = GameManager.add_relationship_value(npc_id, "friendship", -2)

		current_date["progress"] = clamp(current_date["progress"] - 12, 0, 100)
		current_date["mistakes"] = int(current_date.get("mistakes", 0)) + 1
		description_label.text = "Tu respuesta no coincide.\nLa distancia entre ambos se hace evidente.\nAmistad -2%s" % relationship_text

	GameManager.consume_action(3)
	SaveManager.save_game()

	build_actions()
	refresh()

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

func show_final_summary(summary_text: String) -> void:
	description_label.text = summary_text

	clear_container(action_container)

	var continue_button: Button = UIFactory.button("Continuar")
	continue_button.pressed.connect(func(): SceneRouter.go_to_world_map())
	action_container.add_child(continue_button)
