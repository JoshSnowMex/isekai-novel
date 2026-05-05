extends Node

const STEP_ORDER: Array = [
	"interest",
	"dating",
	"lovers",
	"partner"
]

func get_next_step_id(npc_id: String) -> String:
	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var state: String = relation.get("relationship_state", "none")

	for step_id in STEP_ORDER:
		var step: Dictionary = DataManager.get_relationship_step(step_id)

		if step.get("from_state", "") == state:
			return step_id

	return ""

func has_available_step(npc_id: String) -> bool:
	var step_id: String = get_next_step_id(npc_id)

	if step_id == "":
		return false

	return can_start_step(npc_id, step_id)

func can_start_step(npc_id: String, step_id: String) -> bool:
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	if step.is_empty():
		return false

	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var current_state: String = relation.get("relationship_state", "none")
	var expected_state: String = step.get("from_state", "")

	if current_state != expected_state:
		return false

	var total: int = GameManager.get_total_affinity(npc_id)
	var required_total: int = int(step.get("required_total_affinity", 0))

	if total < required_total:
		return false

	if step.get("required_successful_date", false):
		if not GameManager.has_world_flag("successful_date:%s" % npc_id):
			return false

	if not meets_info_category_requirements(npc_id, step.get("required_info_categories", {})):
		return false

	return true

func get_blocked_reason(npc_id: String, step_id: String) -> String:
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	if step.is_empty():
		return "No hay un avance de relación disponible."

	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	var current_state: String = relation.get("relationship_state", "none")
	var expected_state: String = step.get("from_state", "")

	if current_state != expected_state:
		return "La relación todavía no está en el punto correcto para este avance."

	var total: int = GameManager.get_total_affinity(npc_id)
	var required_total: int = int(step.get("required_total_affinity", 0))

	if total < required_total:
		return "Necesitas más vínculo antes de intentar esta cita especial. Vínculo requerido: %s." % required_total

	if step.get("required_successful_date", false):
		if not GameManager.has_world_flag("successful_date:%s" % npc_id):
			return "Necesitas tener primero una cita normal exitosa con este personaje. Una cita fallida no cuenta para avanzar la relación."

	var info_reason: String = get_info_category_blocked_reason(npc_id, step.get("required_info_categories", {}))

	if info_reason != "":
		return info_reason

	return ""

func get_known_info_count_for_tier(npc_id: String, tier: int) -> int:
	GameManager.ensure_npc_knowledge(npc_id)

	var known_info: Array = GameManager.player["known_npc_info"][npc_id].get("info", [])
	var count: int = 0

	for info_key in known_info:
		var key: String = str(info_key)

		if GameManager.get_info_tier(key) == tier:
			count += 1

	return count

func get_known_info_keys_for_tier(npc_id: String, tier: int) -> Array:
	GameManager.ensure_npc_knowledge(npc_id)

	var known_info: Array = GameManager.player["known_npc_info"][npc_id].get("info", [])
	var result: Array = []

	for info_key in known_info:
		var key: String = str(info_key)

		if GameManager.get_info_tier(key) == tier:
			result.append(key)

	return result

func create_special_date_state(npc_id: String, step_id: String) -> Dictionary:
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	return {
		"npc_id": npc_id,
		"date_location_id": "special_relationship",
		"relationship_step_id": step_id,
		"date_type": "special",
		"progress": 0,
		"mistakes": 0,
		"questions_answered": 0,
		"questions_required": int(step.get("questions_required", 2)),
		"allowed_failures": int(step.get("allowed_failures", 0)),
		"answered_info_keys": []
	}

func build_special_question(date_state: Dictionary) -> Dictionary:
	var npc_id: String = date_state.get("npc_id", "")
	var step_id: String = date_state.get("relationship_step_id", "")
	var step: Dictionary = DataManager.get_relationship_step(step_id)
	var answered: Array = date_state.get("answered_info_keys", [])
	var required_categories: Dictionary = step.get("required_info_categories", {})

	var candidates: Array = get_known_info_keys_for_categories(npc_id, required_categories)
	var available_candidates: Array = []

	for key in candidates:
		if not answered.has(key):
			available_candidates.append(key)

	if available_candidates.is_empty():
		return {}

	var info_key: String = str(available_candidates.pick_random())
	return build_question_for_info_key(npc_id, info_key)

func answer_special_question(date_state: Dictionary, question: Dictionary, selected: String) -> Dictionary:
	var correct: String = question.get("correct", "")
	var info_key: String = question.get("info_key", "")

	if not date_state.has("answered_info_keys"):
		date_state["answered_info_keys"] = []

	date_state["answered_info_keys"].append(info_key)
	date_state["questions_answered"] = int(date_state.get("questions_answered", 0)) + 1

	var label: String = GameManager.get_info_label(info_key)

	if selected == correct:
		date_state["progress"] = int(date_state.get("progress", 0)) + 1

		return {
			"correct": true,
			"text": "Respuesta correcta.\n\nRecordaste bien: %s.\n\nLa reacción confirma que no solo acumulaste cercanía: también escuchaste." % label
		}

	date_state["mistakes"] = int(date_state.get("mistakes", 0)) + 1

	return {
		"correct": false,
		"text": "Respuesta incorrecta.\n\nEl detalle era: %s.\n\nLa duda aparece en el momento exacto en que la relación necesitaba certeza." % label
	}

func is_special_date_complete(date_state: Dictionary) -> bool:
	return int(date_state.get("questions_answered", 0)) >= int(date_state.get("questions_required", 0))

func finish_special_date(date_state: Dictionary) -> Dictionary:
	var npc_id: String = date_state.get("npc_id", "")
	var step_id: String = date_state.get("relationship_step_id", "")
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	var questions_required: int = int(step.get("questions_required", 0))
	var allowed_failures: int = int(step.get("allowed_failures", 0))
	var progress: int = int(date_state.get("progress", 0))
	var mistakes: int = int(date_state.get("mistakes", 0))

	var success: bool = progress >= questions_required - allowed_failures and mistakes <= allowed_failures

	if success:
		return complete_relationship_step(npc_id, step_id)

	return fail_relationship_step(npc_id, step_id)

func complete_relationship_step(npc_id: String, step_id: String) -> Dictionary:
	var step: Dictionary = DataManager.get_relationship_step(step_id)
	var to_state: String = step.get("to_state", "")

	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]
	relation["relationship_state"] = to_state

	GameManager.record_emotional_date(
		npc_id,
		"relationship_%s_day" % to_state,
		"Relación: %s" % GameManager.get_relationship_state_label(to_state)
	)

	var flag: String = "relationship_step:%s:%s" % [npc_id, step_id]
	GameManager.add_world_flag(flag)

	var piece_index: int = int(step.get("portrait_piece_index", 0))
	var collectible_text: String = ""

	if piece_index > 0:
		var piece_id: String = "portrait_piece:%s:%s" % [npc_id, piece_index]

		if not GameManager.has_collectible(piece_id):
			GameManager.add_collectible(piece_id)
			collectible_text += "\n\nColeccionable obtenido:\nPieza de retrato %s de %s" % [
				piece_index,
				DataManager.get_npc(npc_id).get("name", npc_id)
			]

	if to_state == "partner":
		var trophy_id: String = "relationship_trophy:%s" % npc_id

		if not GameManager.has_collectible(trophy_id):
			GameManager.add_collectible(trophy_id)
			collectible_text += "\n\nTrofeo de vínculo obtenido:\n%s" % DataManager.get_npc(npc_id).get("name", npc_id)

	GameManager.add_npc_note(
		npc_id,
		"La relación avanzó a estado: %s." % to_state
	)

	var event_texts: Array = EventSystem.process_events({
		"trigger": "relationship_step_completed",
		"npc_id": npc_id,
		"step_id": step_id,
		"to_state": to_state
	})

	var milestone_results: Array = MilestoneSystem.process_milestones({
		"trigger": "relationship_step_completed",
		"npc_id": npc_id,
		"step_id": step_id,
		"to_state": to_state
	})

	for milestone in milestone_results:
		GameManager.add_pending_narrative_message(milestone)

	var final_text: String = step.get("success_text", "La relación avanzó.")

	for text in event_texts:
		final_text += "\n\n" + str(text)

	final_text += collectible_text

	return {
		"success": true,
		"text": final_text
	}

func fail_relationship_step(npc_id: String, step_id: String) -> Dictionary:
	var step: Dictionary = DataManager.get_relationship_step(step_id)

	var relationship_text: String = ""
	relationship_text += GameManager.add_relationship_value(npc_id, "friendship", -2)
	relationship_text += GameManager.add_relationship_value(npc_id, "tension", -3)
	relationship_text += GameManager.add_relationship_value(npc_id, "jealousy", 3)

	GameManager.add_npc_note(
		npc_id,
		"Una cita especial fallida dejó dudas sobre el siguiente paso."
	)

	return {
		"success": false,
		"text": "%s\n\nConsecuencias:\nAmistad -2\nTensión -3\nCelos +3%s" % [
			step.get("failure_text", "La cita especial falló."),
			relationship_text
		]
	}

func meets_info_category_requirements(npc_id: String, requirements: Dictionary) -> bool:
	if requirements.is_empty():
		return true

	for category_id in requirements.keys():
		var required_count: int = int(requirements[category_id])
		var known_count: int = get_known_info_count_for_category(npc_id, str(category_id))

		if known_count < required_count:
			return false

	return true


func get_info_category_blocked_reason(npc_id: String, requirements: Dictionary) -> String:
	if requirements.is_empty():
		return ""

	var missing_lines: Array = []

	for category_id in requirements.keys():
		var required_count: int = int(requirements[category_id])
		var known_count: int = get_known_info_count_for_category(npc_id, str(category_id))
		var category_title: String = GameManager.get_info_category_title(str(category_id))

		if known_count < required_count:
			missing_lines.append("- %s: %s/%s" % [
				category_title,
				known_count,
				required_count
			])

	if missing_lines.is_empty():
		return ""

	var text: String = "Necesitas conocer mejor a este personaje en categorías concretas:\n"

	for line in missing_lines:
		text += "%s\n" % line

	text += "Hablar, tener citas exitosas y dar regalos adecuados puede revelar información nueva."

	return text.strip_edges()


func get_known_info_count_for_category(npc_id: String, category_id: String) -> int:
	GameManager.ensure_npc_knowledge(npc_id)

	var known_info: Array = GameManager.player["known_npc_info"][npc_id].get("info", [])
	var category_keys: Array = GameManager.get_info_keys_for_category(category_id)
	var count: int = 0

	for info_key in known_info:
		if category_keys.has(str(info_key)):
			count += 1

	return count


func get_known_info_keys_for_category(npc_id: String, category_id: String) -> Array:
	GameManager.ensure_npc_knowledge(npc_id)

	var known_info: Array = GameManager.player["known_npc_info"][npc_id].get("info", [])
	var category_keys: Array = GameManager.get_info_keys_for_category(category_id)
	var result: Array = []

	for info_key in known_info:
		var key: String = str(info_key)

		if category_keys.has(key):
			result.append(key)

	return result


func get_known_info_keys_for_categories(npc_id: String, requirements: Dictionary) -> Array:
	var result: Array = []

	for category_id in requirements.keys():
		var keys: Array = get_known_info_keys_for_category(npc_id, str(category_id))

		for key in keys:
			if not result.has(key):
				result.append(key)

	return result

func build_question_for_info_key(npc_id: String, info_key: String) -> Dictionary:
	var question_type: String = pick_question_type_for_info_key(info_key)
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var info_data: Dictionary = npc.get("info", {})
	var correct_value: String = str(info_data.get(info_key, ""))
	var label: String = GameManager.get_info_label(info_key)
	var category_label: String = GameManager.get_info_category_title_for_key(info_key)

	var options: Array = build_question_options(npc_id, info_key, correct_value)

	var question_text: String = ""

	match question_type:
		"inverse":
			question_text = build_inverse_question_text(npc_id, info_key, label, category_label)
		"contextual":
			question_text = build_contextual_question_text(npc_id, info_key, label, category_label)
		_:
			question_text = build_direct_question_text(npc_id, info_key, label, category_label)

	return {
		"question": question_text,
		"info_key": info_key,
		"correct": correct_value,
		"options": options,
		"question_type": question_type
	}


func pick_question_type_for_info_key(info_key: String) -> String:
	var category_id: String = GameManager.get_info_category_id_for_key(info_key)

	if category_id in ["basic", "likes", "contact", "personal_profile"]:
		var roll: float = randf()

		if roll < 0.75:
			return "direct"

		return "inverse"

	if category_id in ["personality", "desire_chemistry", "romance", "history", "responsibility_cost", "emotional_shadow", "final"]:
		var roll: float = randf()

		if roll < 0.45:
			return "contextual"
		elif roll < 0.75:
			return "direct"

		return "inverse"

	return "direct"


func build_question_options(npc_id: String, info_key: String, correct_value: String) -> Array:
	var options: Array = [correct_value]

	for other_npc_id in DataManager.npcs.keys():
		if other_npc_id == npc_id:
			continue

		var other_npc: Dictionary = DataManager.get_npc(other_npc_id)
		var other_info: Dictionary = other_npc.get("info", {})

		if other_info.has(info_key):
			var value: String = str(other_info.get(info_key, ""))

			if value != correct_value and not options.has(value):
				options.append(value)

		if options.size() >= 3:
			break

	if options.size() < 3:
		for fallback_key in get_fallback_option_keys_for_category(info_key):
			if fallback_key == info_key:
				continue

			var npc: Dictionary = DataManager.get_npc(npc_id)
			var info_data: Dictionary = npc.get("info", {})

			if info_data.has(fallback_key):
				var value: String = str(info_data.get(fallback_key, ""))

				if value != correct_value and not options.has(value):
					options.append(value)

			if options.size() >= 3:
				break

	options.shuffle()
	return options


func get_fallback_option_keys_for_category(info_key: String) -> Array:
	var category_id: String = GameManager.get_info_category_id_for_key(info_key)
	return GameManager.get_info_keys_for_category(category_id)


func build_direct_question_text(npc_id: String, info_key: String, label: String, category_label: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)

	return "Para dar este paso, necesitas demostrar que realmente has puesto atención.\n\n%s · %s\n¿Cuál es la respuesta correcta para %s?" % [
		category_label,
		label,
		npc.get("name", npc_id)
	]


func build_inverse_question_text(npc_id: String, info_key: String, label: String, category_label: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)

	match info_key:
		"uncomfortable_gesture", "uncomfortable_provocation", "romantic_boundary", "breaking_point":
			return "Este avance necesita cuidado, no solo deseo.\n\n%s · %s\n¿Qué opción representa algo que podría incomodar o herir a %s?" % [
				category_label,
				label,
				npc.get("name", npc_id)
			]
		"annoyance":
			return "Si quieres acercarte sin torpeza, también debes recordar lo que molesta.\n\n%s · %s\n¿Qué suele molestar a %s?" % [
				category_label,
				label,
				npc.get("name", npc_id)
			]
		_:
			return "No basta con recordar datos sueltos: necesitas distinguir lo que sí encaja.\n\n%s · %s\n¿Cuál de estas opciones corresponde a %s?" % [
				category_label,
				label,
				npc.get("name", npc_id)
			]


func build_contextual_question_text(npc_id: String, info_key: String, label: String, category_label: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = npc.get("name", npc_id)

	match info_key:
		"soothing":
			return "%s parece tensarse durante la conversación.\n\n%s · %s\n¿Qué sabes que podría tranquilizarle?" % [
				npc_name,
				category_label,
				label
			]
		"flirt_turn_on":
			return "El momento permite coquetear, pero no cualquier tipo de coqueteo sirve.\n\n%s · %s\n¿Qué tipo de coqueteo provoca mejor a %s?" % [
				category_label,
				label,
				npc_name
			]
		"uncomfortable_provocation":
			return "La tensión sube, pero hay formas de arruinarla.\n\n%s · %s\n¿Qué provocación incomodaría a %s?" % [
				category_label,
				label,
				npc_name
			]
		"intimate_pace":
			return "La intimidad no se mide solo por deseo, sino por ritmo.\n\n%s · %s\n¿Qué ritmo íntimo necesita %s?" % [
				category_label,
				label,
				npc_name
			]
		"main_responsibility":
			return "Elegir a alguien también afecta lo que esa persona protege.\n\n%s · %s\n¿Cuál es la responsabilidad principal de %s?" % [
				category_label,
				label,
				npc_name
			]
		"could_neglect_for_love":
			return "El amor también puede distraer de algo importante.\n\n%s · %s\n¿Qué podría descuidar %s por amor?" % [
				category_label,
				label,
				npc_name
			]
		"harmful_pattern":
			return "Conocer a alguien también implica reconocer sus sombras.\n\n%s · %s\n¿Qué patrón dañino aparece en %s bajo presión?" % [
				category_label,
				label,
				npc_name
			]
		"emotional_truth":
			return "Este vínculo necesita algo más que afinidad.\n\n%s · %s\n¿Qué verdad emocional sostiene el corazón de %s?" % [
				category_label,
				label,
				npc_name
			]
		"final_union_condition":
			return "Una unión final no se acepta solo por deseo.\n\n%s · %s\n¿Qué condición necesita %s para aceptar una unión definitiva?" % [
				category_label,
				label,
				npc_name
			]
		_:
			return "El momento pide demostrar atención real.\n\n%s · %s\n¿Qué sabes de %s sobre este detalle?" % [
				category_label,
				label,
				npc_name
			]
