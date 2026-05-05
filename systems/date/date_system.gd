extends Node

const NORMAL_DATE_MAX_TALKS: int = 3
const NORMAL_DATE_MAX_QUESTIONS: int = 2
const NORMAL_DATE_MAX_MOVES: int = 2
const NORMAL_DATE_MAX_GIFTS: int = 1

func get_available_date_locations(npc_id: String) -> Array:
	var result: Array = []
	var total: int = GameManager.get_total_affinity(npc_id)

	for date_location_id in DataManager.date_locations.keys():
		var date_location: Dictionary = DataManager.get_date_location(date_location_id)
		var min_total: int = int(date_location.get("min_total_affinity", 0))

		if total >= min_total:
			result.append(date_location_id)

	return result

func create_date_state(npc_id: String, date_location_id: String) -> Dictionary:
	GameManager.ensure_relationship(npc_id)

	var date_location: Dictionary = DataManager.get_date_location(date_location_id)
	var base_progress: int = int(date_location.get("starting_progress", 50))

	var preferred_npcs: Array = date_location.get("preferred_npcs", [])
	var bad_fit_npcs: Array = date_location.get("bad_fit_npcs", [])

	if preferred_npcs.has(npc_id):
		base_progress += 8

	if bad_fit_npcs.has(npc_id):
		base_progress -= 8

	var jealousy: int = GameManager.get_relationship_value(npc_id, "jealousy")

	if jealousy >= 40:
		base_progress -= 8

	return {
		"npc_id": npc_id,
		"date_location_id": date_location_id,
		"progress": clamp(base_progress, 0, 100),
		"mistakes": 0,
		"talks_used": 0,
		"questions_used": 0,
		"gifts_used": 0,
		"moves_used": [],
		"date_type": "normal"
	}

func can_talk(date_state: Dictionary) -> bool:
	return int(date_state.get("talks_used", 0)) < NORMAL_DATE_MAX_TALKS

func can_question(date_state: Dictionary) -> bool:
	return int(date_state.get("questions_used", 0)) < NORMAL_DATE_MAX_QUESTIONS

func can_gift(date_state: Dictionary) -> bool:
	return int(date_state.get("gifts_used", 0)) < NORMAL_DATE_MAX_GIFTS

func can_move(date_state: Dictionary) -> bool:
	var moves_used: Array = date_state.get("moves_used", [])
	return moves_used.size() < NORMAL_DATE_MAX_MOVES

func register_talk(date_state: Dictionary) -> void:
	date_state["talks_used"] = int(date_state.get("talks_used", 0)) + 1

func register_question(date_state: Dictionary) -> void:
	date_state["questions_used"] = int(date_state.get("questions_used", 0)) + 1

func register_gift(date_state: Dictionary) -> void:
	date_state["gifts_used"] = int(date_state.get("gifts_used", 0)) + 1

func get_available_moves(date_state: Dictionary) -> Array:
	var result: Array = []
	var npc_id: String = date_state.get("npc_id", "")
	var total: int = GameManager.get_total_affinity(npc_id)
	var moves_used: Array = date_state.get("moves_used", [])

	if not can_move(date_state):
		return result

	for move_id in DataManager.date_moves.keys():
		if moves_used.has(move_id):
			continue

		var move: Dictionary = DataManager.get_date_move(move_id)
		var min_total: int = int(move.get("min_total_affinity", 0))

		if total >= min_total:
			result.append(move_id)

	return result

func perform_move(date_state: Dictionary, move_id: String) -> Dictionary:
	if not can_move(date_state):
		return {
			"success": false,
			"text": "Ya intentaste suficientes movimientos en esta cita. Forzar más solo volvería incómodo el momento."
		}

	var moves_used: Array = date_state.get("moves_used", [])

	if moves_used.has(move_id):
		return {
			"success": false,
			"text": "Repetir el mismo gesto le quitaría toda naturalidad al momento."
		}

	var npc_id: String = date_state.get("npc_id", "")
	var move: Dictionary = DataManager.get_date_move(move_id)
	var date_location_id: String = date_state.get("date_location_id", "")
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)
	var mood_tags: Array = date_location.get("mood_tags", [])

	var progress: int = int(date_state.get("progress", 0))
	var total: int = GameManager.get_total_affinity(npc_id)
	var tension: int = GameManager.get_relationship_value(npc_id, "tension")
	var jealousy: int = GameManager.get_relationship_value(npc_id, "jealousy")

	var score: int = 0

	if progress >= int(move.get("min_progress", 0)):
		score += 35
	else:
		score -= 30

	if total >= int(move.get("min_total_affinity", 0)):
		score += 25
	else:
		score -= 25

	if tension >= int(move.get("min_tension", 0)):
		score += 20
	else:
		score -= 20

	for tag in move.get("preferred_moods", []):
		if mood_tags.has(tag):
			score += 8

	for tag in move.get("bad_moods", []):
		if mood_tags.has(tag):
			score -= 10

	if jealousy >= 50:
		score -= 15

	score += GameManager.get_romantic_move_modifier(npc_id)

	if progress >= 95:
		score += 12

	var success: bool = score >= 45

	add_move_used(date_state, move_id)

	if success:
		date_state["progress"] = clamp(progress + int(move.get("success_progress", 0)), 0, 100)
		apply_relationship_effects(npc_id, move.get("success_relationship", {}))

		return {
			"success": true,
			"text": move.get("success_text", "El gesto fue bien recibido.")
		}

	date_state["progress"] = clamp(progress + int(move.get("failure_progress", 0)), 0, 100)
	date_state["mistakes"] = int(date_state.get("mistakes", 0)) + 1
	apply_relationship_effects(npc_id, move.get("failure_relationship", {}))

	return {
		"success": false,
		"text": move.get("failure_text", "El gesto no fue bien recibido.")
	}

func add_move_used(date_state: Dictionary, move_id: String) -> void:
	if not date_state.has("moves_used"):
		date_state["moves_used"] = []

	if not date_state["moves_used"].has(move_id):
		date_state["moves_used"].append(move_id)

func apply_relationship_effects(npc_id: String, effects: Dictionary) -> String:
	var result: String = ""

	for key in effects.keys():
		var amount: int = int(effects[key])
		result += GameManager.add_relationship_value(npc_id, key, amount)

	return result

func finish_date(date_state: Dictionary) -> Dictionary:
	var npc_id: String = date_state.get("npc_id", "")
	var date_location_id: String = date_state.get("date_location_id", "")
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)

	var progress: int = int(date_state.get("progress", 0))
	var success_threshold: int = int(date_location.get("success_threshold", 70))
	var mistakes: int = int(date_state.get("mistakes", 0))

	var summary: String = ""
	var success_level: String = "failed"

	GameManager.ensure_relationship(npc_id)
	GameManager.ensure_npc_knowledge(npc_id)

	if progress >= 95:
		success_level = "perfect"
	elif progress >= 85:
		success_level = "excellent"
	elif progress >= success_threshold:
		success_level = "success"

	if success_level == "failed":
		var relationship_text: String = ""
		relationship_text += GameManager.add_relationship_value(npc_id, "friendship", -4)
		relationship_text += GameManager.add_relationship_value(npc_id, "tension", -5)
		relationship_text += GameManager.add_relationship_value(npc_id, "jealousy", 4)

		GameManager.add_npc_note(
			npc_id,
			"Una cita incómoda en %s dejó una distancia temporal." % date_location.get("name", date_location_id)
		)

		summary = "La cita termina con una sensación incómoda.\n\nLugar: %s\nProgreso final: %s\nErrores: %s\n\nAmistad -4\nTensión -5\nLealtad -2%s" % [
			date_location.get("name", date_location_id),
			progress,
			mistakes,
			relationship_text
		]

		return {
			"success": false,
			"level": success_level,
			"text": summary
		}

	var reward_key: String = "success_rewards"

	if success_level == "excellent":
		reward_key = "excellent_rewards"
	elif success_level == "perfect":
		reward_key = "perfect_rewards"

	var rewards: Dictionary = date_location.get(reward_key, {})
	var reward_text: String = ""

	for key in rewards.keys():
		var amount: int = int(rewards[key])
		reward_text += GameManager.add_relationship_value(npc_id, key, amount)

	var reveal_text: String = reveal_date_reward_info(npc_id, success_level)
	var collectible_text: String = grant_date_collectible(npc_id, date_location_id)
	var successful_date_text: String = register_successful_date(npc_id, date_location_id, success_level)
	var rivalry_text: String = process_successful_date_rivalries(npc_id, success_level)
	
	GameManager.add_npc_note(
		npc_id,
		"La cita en %s dejó una memoria difícil de ignorar." % date_location.get("name", date_location_id)
	)

	summary = "La cita fue %s.\n\nLugar: %s\nProgreso final: %s\nErrores: %s\n\nRecompensas aplicadas:%s%s%s%s%s" % [
		get_success_label(success_level),
		date_location.get("name", date_location_id),
		progress,
		mistakes,
		format_reward_text(rewards),
		reveal_text,
		collectible_text,
		successful_date_text,
		rivalry_text
	]

	if reward_text != "":
		summary += reward_text

	return {
		"success": true,
		"level": success_level,
		"text": summary
	}

func register_successful_date(npc_id: String, date_location_id: String, success_level: String) -> String:
	var flag: String = "successful_date:%s" % npc_id
	var location_flag: String = "successful_date:%s:%s" % [npc_id, date_location_id]
	var level_flag: String = "successful_date:%s:%s:%s" % [npc_id, date_location_id, success_level]

	GameManager.add_world_flag(flag)
	GameManager.add_world_flag(location_flag)
	GameManager.add_world_flag(level_flag)

	return "\n\nLa cita exitosa quedó registrada en tus recuerdos."

func reveal_date_reward_info(npc_id: String, success_level: String) -> String:
	var reveal_text: String = ""

	var info_key: String = GameManager.reveal_random_npc_info(npc_id)

	if info_key != "":
		var npc: Dictionary = DataManager.get_npc(npc_id)
		var label: String = GameManager.get_info_label(info_key)
		var info_data: Dictionary = npc.get("info", {})
		var value: String = str(info_data.get(info_key, ""))

		reveal_text += "\n\nInformación descubierta:\n%s: %s" % [label, value]

	if success_level == "excellent" or success_level == "perfect":
		var gift_id: String = reveal_random_gift_preference(npc_id)

		if gift_id != "":
			var item: Dictionary = DataManager.get_item(gift_id)
			reveal_text += "\n\nTambién descubriste un gusto de regalo:\n%s" % item.get("name", gift_id)

	return reveal_text

func reveal_random_gift_preference(npc_id: String) -> String:
	GameManager.ensure_npc_knowledge(npc_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var prefs: Dictionary = npc.get("gift_preferences", {})
	var candidates: Array = []

	for group in ["loves", "likes"]:
		for item_id in prefs.get(group, []):
			if not GameManager.player["known_npc_info"][npc_id]["gifts"].has(item_id):
				candidates.append(item_id)

	if candidates.is_empty():
		return ""

	var selected: String = str(candidates.pick_random())
	GameManager.reveal_npc_gift(npc_id, selected)
	return selected

func grant_date_collectible(npc_id: String, date_location_id: String) -> String:
	var collectible_id: String = "date_memory:%s:%s" % [npc_id, date_location_id]

	if GameManager.has_collectible(collectible_id):
		return ""

	GameManager.add_collectible(collectible_id)

	var npc: Dictionary = DataManager.get_npc(npc_id)
	var date_location: Dictionary = DataManager.get_date_location(date_location_id)

	return "\n\nColeccionable obtenido:\nRecuerdo de %s en %s" % [
		npc.get("name", npc_id),
		date_location.get("name", date_location_id)
	]

func get_success_label(success_level: String) -> String:
	match success_level:
		"perfect":
			return "perfecta"
		"excellent":
			return "excelente"
		"success":
			return "exitosa"
		_:
			return "fallida"

func format_reward_text(rewards: Dictionary) -> String:
	if rewards.is_empty():
		return "\n- Sin recompensa."

	var text: String = ""

	for key in rewards.keys():
		var label: String = key

		match key:
			"friendship":
				label = "Amistad"
			"tension":
				label = "Tensión"
			"loyalty":
				label = "Lealtad"
			"jealousy":
				label = "Celos"

		text += "\n- %s %+d" % [label, int(rewards[key])]

	return text

func process_successful_date_rivalries(npc_id: String, success_level: String) -> String:
	var rivalry_amount: int = 0

	match success_level:
		"success":
			rivalry_amount = 5
		"excellent":
			rivalry_amount = 8
		"perfect":
			rivalry_amount = 12
		_:
			rivalry_amount = 0

	if rivalry_amount <= 0:
		return ""

	var rivalry_results: Array = RivalrySystem.process_affinity_change(npc_id, rivalry_amount)

	if rivalry_results.is_empty():
		return ""

	var text: String = ""

	for result in rivalry_results:
		var affected_npc_id: String = result.get("affected_npc_id", "")
		var affected_npc: Dictionary = DataManager.get_npc(affected_npc_id)
		var penalty: int = int(result.get("penalty", 0))

		if affected_npc_id == "":
			continue

		GameManager.add_relationship_value(affected_npc_id, "jealousy", penalty)

		text += "\n%s parece haber notado lo bien que fue la cita. Celos +%s" % [
			affected_npc.get("name", affected_npc_id),
			penalty
		]

	return text
