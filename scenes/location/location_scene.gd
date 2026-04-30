extends Control

var title_label: Label
var description_label: Label
var action_container: VBoxContainer
var npc_container: VBoxContainer

var current_location_id: String = ""

func _ready() -> void:
	build_ui()
	load_location(GameManager.current_location_id)

func build_ui() -> void:
	var root := ScreenRoot.create(self)

	title_label = UIFactory.title("")
	root.add_child(title_label)

	description_label = UIFactory.body("")
	root.add_child(description_label)

	var section_label := UIFactory.body("Acciones disponibles")
	root.add_child(section_label)

	action_container = VBoxContainer.new()
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 10)
	root.add_child(action_container)

	var npc_label := UIFactory.body("Personas aquí")
	root.add_child(npc_label)

	npc_container = VBoxContainer.new()
	npc_container.alignment = BoxContainer.ALIGNMENT_CENTER
	npc_container.add_theme_constant_override("separation", 10)
	root.add_child(npc_container)

	var back_button := UIFactory.button("Volver al mapa")
	back_button.pressed.connect(_on_back_pressed)
	root.add_child(back_button)

func load_location(location_id: String) -> void:
	current_location_id = location_id

	var data: Dictionary = DataManager.get_location(location_id)

	title_label.text = data.get("name", location_id)
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
		add_action("Trabajar (jornada completa)", func(): do_work_full())

	if actions.get("work_half", false):
		add_action("Trabajar (medio turno)", func(): do_work_half())

	if actions.get("rest", false):
		add_action("Descansar", func(): do_rest())
	
	if actions.get("shop", false):
		add_action("Comprar", func(): SceneRouter.go_to_shop())

	if current_location_id == "home" and GameManager.is_day_exhausted():
		add_action("Dormir", func(): do_sleep())

func build_npcs() -> void:
	clear_container(npc_container)

	for npc_id in DataManager.npcs.keys():
		var npc: Dictionary = DataManager.get_npc(npc_id)
		var time: String = GameManager.current_time_block

		if npc["schedule"][time] == current_location_id:
			GameManager.mark_npc_seen(npc_id)
			GameManager.reveal_npc_schedule(npc_id, time)

			var button: Button = UIFactory.button(npc.get("name", npc_id))
			button.pressed.connect(func(): interact_npc(npc_id))
			npc_container.add_child(button)

func add_action(text: String, callback: Callable) -> void:
	var button := UIFactory.button(text)
	button.pressed.connect(callback)
	action_container.add_child(button)

func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

# ====== ACCIONES ======

func do_train(location_data: Dictionary) -> void:
	var stat: String = location_data.get("train_stat", "intellect")
	GameManager.player["stats"][stat] += 1
	GameManager.consume_action(10)
	reload_scene()

func do_work_full() -> void:
	GameManager.player["money"] += 20
	GameManager.consume_action(25)
	reload_scene()

func do_work_half() -> void:
	GameManager.player["money"] += 10
	GameManager.consume_action(15)
	reload_scene()

func do_rest() -> void:
	GameManager.player["stamina"] += 20
	GameManager.consume_action(5)
	reload_scene()

func do_sleep() -> void:
	GameManager.sleep_until_next_day()
	reload_scene()

func interact_npc(npc_id: String) -> void:
	clear_container(action_container)

	var npc: Dictionary = DataManager.get_npc(npc_id)

	var title: Label = UIFactory.title(npc.get("name", npc_id))
	action_container.add_child(title)

	var talk_button := UIFactory.button("Hablar")
	talk_button.pressed.connect(func(): talk_to_npc(npc_id))
	action_container.add_child(talk_button)

	var gift_button: Button = UIFactory.button("Dar regalo")
	gift_button.pressed.connect(func(): show_gift_selection(npc_id))
	action_container.add_child(gift_button)

	var affinity: int = GameManager.player["relationships"].get(npc_id, {}).get("affinity", 0)

	var date_button := UIFactory.button("Invitar a cita")
	date_button.disabled = affinity < 40
	date_button.pressed.connect(func(): SceneRouter.go_to_date(npc_id))
	action_container.add_child(date_button)

	var back_button := UIFactory.button("Volver")
	back_button.pressed.connect(func(): load_location(current_location_id))
	action_container.add_child(back_button)

# ====== CONTROL ======

func reload_scene() -> void:
	SaveManager.save_game()
	load_location(current_location_id)

func _on_back_pressed() -> void:
	SceneRouter.go_to_world_map()

func ensure_relationship(npc_id: String) -> void:
	if not GameManager.player["relationships"].has(npc_id):
		GameManager.player["relationships"][npc_id] = {
			"affinity": 0,
			"gift_given_today": false
		}

func talk_to_npc(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	var gain: int = randi_range(2, 4)
	var rivalry_text: String = GameManager.add_affinity(npc_id, gain)

	var message: String = "Conversas con %s.\nLa tensión entre ambos se vuelve un poco más evidente.\nAfinidad +%s" % [
		npc.get("name", npc_id),
		gain
	]

	if randf() < 0.35:
		var info_key: String = GameManager.reveal_random_npc_info(npc_id)

		if info_key != "":
			var label: String = GameManager.get_info_label(info_key)
			var info_data: Dictionary = npc.get("info", {})
			var value: String = str(info_data.get(info_key, ""))

			message += "\n\nNueva información descubierta:\n%s: %s" % [label, value]

	GameManager.add_npc_note(
		npc_id,
		"Una conversación casual dejó ver algo más profundo de %s." % npc.get("name", npc_id)
	)

	description_label.text = message

	GameManager.consume_action(5)
	SaveManager.save_game()
	load_location(current_location_id)

func show_gift_selection(npc_id: String) -> void:
	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	clear_container(action_container)

	var npc: Dictionary = DataManager.get_npc(npc_id)

	var title: Label = UIFactory.title("Regalo para %s" % npc.get("name", npc_id))
	action_container.add_child(title)

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

	if item_id in prefs.get("loves", []):
		result = randi_range(5, 6)
		reaction = "Su reacción lo dice todo. Has tocado una fibra muy personal."
	elif item_id in prefs.get("likes", []):
		result = randi_range(3, 4)
		reaction = "Acepta el regalo con una calidez difícil de fingir."
	elif item_id in prefs.get("hates", []):
		result = randi_range(-5, -4)
		reaction = "La incomodidad aparece de inmediato. Fue una mala elección."
	else:
		result = randi_range(1, 2)
		reaction = "Acepta el gesto con cortesía."

	relation["affinity"] = clamp(int(relation.get("affinity", 0)) + result, 0, 100)
	relation["gift_given_today"] = true

	GameManager.remove_item(item_id, 1)
	GameManager.reveal_npc_gift(npc_id, item_id)

	description_label.text = "%s\nRegalo: %s\nAfinidad: %+d" % [
		reaction,
		item.get("name", item_id),
		result
	]

	GameManager.consume_action(5)
	SaveManager.save_game()
	load_location(current_location_id)

func do_activity(activity_id: String) -> void:
	var result_message: String = GameManager.perform_activity(activity_id)
	description_label.text = result_message
	SaveManager.save_game()
	load_location(current_location_id)
