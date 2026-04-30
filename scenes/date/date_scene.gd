extends Control

var title_label: Label
var description_label: Label
var action_container: VBoxContainer

var current_date: Dictionary = {}

func _ready() -> void:
	build_ui()
	start_date(SceneRouter.temp_npc_id)

func build_ui() -> void:
	var root := ScreenRoot.create(self)

	title_label = UIFactory.title("")
	root.add_child(title_label)

	description_label = UIFactory.body("")
	root.add_child(description_label)

	action_container = VBoxContainer.new()
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 10)
	root.add_child(action_container)

func start_date(npc_id: String) -> void:
	current_date = {
		"npc_id": npc_id,
		"progress": 50,
		"mistakes": 0
	}

	var npc: Dictionary = DataManager.get_npc(npc_id)

	title_label.text = "Cita con %s" % npc.get("name", npc_id)

	description_label.text = "El ambiente es tenso… pero cargado de posibilidad."

	build_actions()

func build_actions() -> void:
	clear_container(action_container)

	add_action("Hablar", func(): do_talk())
	add_action("Dar regalo", func(): do_gift())
	add_action("Hacer movimiento", func(): do_move())
	add_action("Terminar cita", func(): end_date())

func add_action(text: String, callback: Callable) -> void:
	var button := UIFactory.button(text)
	button.pressed.connect(callback)
	action_container.add_child(button)

func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

# ====== ACCIONES ======

func do_talk() -> void:
	var npc_id: String = current_date["npc_id"]
	var known_info: Array = GameManager.player["known_npc_info"].get(npc_id, {}).get("info", [])

	if known_info.is_empty():
		do_random_dialogue()
		return

	if randf() < 0.65:
		do_random_dialogue()
	else:
		do_question()

func do_question() -> void:
	var npc_id: String = current_date["npc_id"]

	var q: Dictionary = build_question(npc_id)

	if q.is_empty():
		do_random_dialogue()
		return

	clear_container(action_container)

	description_label.text = q["question"]

	for option in q["options"]:
		var value: String = str(option)

		var button: Button = UIFactory.button(value)
		button.pressed.connect(func(): answer_question(q, value))
		action_container.add_child(button)

func do_gift() -> void:
	current_date["progress"] += 8
	description_label.text = "El regalo provoca una reacción interesante."

	GameManager.consume_action(3)
	refresh()

func do_move() -> void:
	if current_date["progress"] >= 70:
		current_date["progress"] += 12
		description_label.text = "Te acercas… y la reacción es favorable. La tensión crece."
	else:
		current_date["progress"] -= 15
		description_label.text = "El momento no era el adecuado. Retrocedes."

	GameManager.consume_action(4)
	refresh()

func end_date() -> void:
	var npc_id: String = current_date["npc_id"]
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var result: int = current_date["progress"]

	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	if result >= 70:
		var gain: int = 12
		var rivalry_text: String = GameManager.add_affinity(npc_id, gain)

		var info_key: String = GameManager.reveal_random_npc_info(npc_id)
		var reveal_text: String = ""

		if info_key != "":
			var label: String = GameManager.get_info_label(info_key)
			var info_data: Dictionary = npc.get("info", {})
			var value: String = str(info_data.get(info_key, ""))
			reveal_text = "\n\nLa cita también reveló algo importante:\n%s: %s" % [label, value]

		GameManager.add_npc_note(
			npc_id,
			"La cita terminó con una cercanía difícil de ignorar."
		)

		description_label.text = "La cita fue un éxito. Algo ha cambiado entre ustedes.\nAfinidad +%s%s%s" % [
			gain,
			reveal_text,
			rivalry_text
		]
	else:
		var loss: int = -10
		var rivalry_text: String = GameManager.add_affinity(npc_id, loss)

		GameManager.add_npc_note(
			npc_id,
			"Una cita incómoda dejó una distancia temporal."
		)

		description_label.text = "La cita termina con una sensación incómoda.\nAfinidad %s%s" % [
			loss,
			rivalry_text
		]

	SaveManager.save_game()

	await get_tree().create_timer(2.0).timeout
	SceneRouter.go_to_location()

func refresh() -> void:
	current_date["progress"] = clamp(current_date["progress"], 0, 100)
	title_label.text = "Cita (Progreso: %s)" % current_date["progress"]

func do_random_dialogue() -> void:
	var dialogues: Array = [
		"La conversación avanza con una calma peligrosa. Hay silencios que pesan más que cualquier confesión.",
		"Hablan de cosas simples, pero cada pausa parece acercarlos un poco más.",
		"Una mirada se queda demasiado tiempo. Ninguno de los dos la menciona.",
		"El ambiente se vuelve más íntimo, aunque las palabras sigan siendo prudentes.",
		"Hay algo en su tono que no estaba ahí antes. Algo cálido. Algo difícil de ignorar."
	]

	var index: int = randi_range(0, dialogues.size() - 1)
	current_date["progress"] = clamp(current_date["progress"] + 5, 0, 100)
	description_label.text = dialogues[index]

	GameManager.consume_action(3)
	refresh()

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

	# generar distractores simples
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

	return {
		"question": "¿Recuerdas esto sobre %s?" % npc.get("name", npc_id),
		"info_key": info_key,
		"correct": correct_value,
		"options": options
	}

func answer_question(question: Dictionary, selected: String) -> void:
	var correct: String = question["correct"]

	clear_container(action_container)

	if selected == correct:
		current_date["progress"] = clamp(current_date["progress"] + 15, 0, 100)
		description_label.text = "Respondes sin dudar.\nLa reacción es inmediata… y claramente favorable."
	else:
		current_date["progress"] = clamp(current_date["progress"] - 12, 0, 100)
		current_date["mistakes"] += 1
		description_label.text = "Tu respuesta no coincide.\nLa distancia entre ambos se hace evidente."

	GameManager.consume_action(3)

	await get_tree().create_timer(1.5).timeout
	build_actions()
	refresh()
