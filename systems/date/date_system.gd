extends Node

const NORMAL_DATE_MAX_TALKS: int = 3
const NORMAL_DATE_MAX_QUESTIONS: int = 2
const NORMAL_DATE_MAX_MOVES: int = 2
const NORMAL_DATE_MAX_GIFTS: int = 1
const RELATIONSHIP_STATE_ORDER := {
	"none": 0,
	"interest": 1,
	"dating": 2,
	"lovers": 3,
	"partner": 4
}

func get_available_date_locations(npc_id: String) -> Array:
	var result: Array = []
	var total: int = GameManager.get_total_affinity(npc_id)

	for date_location_id in DataManager.date_locations.keys():
		var date_location: Dictionary = DataManager.get_date_location(date_location_id)
		var min_total: int = int(date_location.get("min_total_affinity", 0))
		var required_state: String = str(date_location.get("required_relationship_state", "none"))

		if total < min_total:
			continue

		if not meets_relationship_state_requirement(npc_id, required_state):
			continue

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

	GameManager.record_emotional_date(
		npc_id,
		"first_date",
		"Primera cita"
	)

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
		var min_state: String = str(move.get("min_relationship_state", "none"))

		if total < min_total:
			continue

		if not meets_relationship_state_requirement(npc_id, min_state):
			continue

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
	var move_tags: Array = move.get("move_tags", [])

	var progress: int = int(date_state.get("progress", 0))
	var total: int = GameManager.get_total_affinity(npc_id)
	var tension: int = GameManager.get_relationship_value(npc_id, "tension")
	var jealousy: int = GameManager.get_relationship_value(npc_id, "jealousy")

	var score: int = 0

	if progress >= int(move.get("min_progress", 0)):
		score += 25
	else:
		score -= 25

	if total >= int(move.get("min_total_affinity", 0)):
		score += 18
	else:
		score -= 25

	if tension >= int(move.get("min_tension", 0)):
		score += 18
	else:
		score -= 18

	score += calculate_mood_score(move, mood_tags)
	score += calculate_npc_move_preference_score(npc_id, move_tags)
	score += calculate_privacy_score(move, mood_tags)
	score += calculate_known_boundary_score(npc_id, move_tags)

	if jealousy >= 50:
		score -= 15

	score += GameManager.get_romantic_move_modifier(npc_id)

	if progress >= 95:
		score += 8

	var outcome: String = "failure"

	if score >= 65:
		outcome = "success"
	elif score >= 45:
		outcome = "soft_success"

	add_move_used(date_state, move_id)

	if outcome == "success":
		date_state["progress"] = clamp(progress + int(move.get("success_progress", 0)), 0, 100)
		apply_relationship_effects(npc_id, move.get("success_relationship", {}))
		apply_move_world_pressure(move, mood_tags, true)

		return {
			"success": true,
			"outcome": outcome,
			"text": move.get("success_text", "El gesto fue bien recibido.")
		}

	if outcome == "soft_success":
		date_state["progress"] = clamp(progress + int(move.get("soft_success_progress", 0)), 0, 100)
		apply_move_world_pressure(move, mood_tags, true)

		return {
			"success": true,
			"outcome": outcome,
			"text": move.get("soft_success_text", "El gesto no fue rechazado, pero pide más cuidado.")
		}

	date_state["progress"] = clamp(progress + int(move.get("failure_progress", 0)), 0, 100)
	date_state["mistakes"] = int(date_state.get("mistakes", 0)) + 1
	apply_relationship_effects(npc_id, move.get("failure_relationship", {}))
	apply_move_world_pressure(move, mood_tags, false)

	return {
		"success": false,
		"outcome": outcome,
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
		relationship_text += GameManager.add_relationship_value(npc_id, "loyalty", -2)

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

	GameManager.record_emotional_date(
		npc_id,
		"first_successful_date",
		"Primera cita exitosa"
	)

	if success_level == "excellent":
		GameManager.record_emotional_date(
			npc_id,
			"first_excellent_date",
			"Primera cita excelente"
		)

	if success_level == "perfect":
		GameManager.record_emotional_date(
			npc_id,
			"first_perfect_date",
			"Primera cita perfecta"
		)

	var reward_key: String = "%s_rewards" % success_level
	var rewards: Dictionary = date_location.get(reward_key, {})
	var resolved_rewards: Dictionary = {}
	var reward_text: String = ""

	for key in rewards.keys():
		var amount: int = resolve_reward_amount(rewards[key])

		if amount == 0:
			continue

		resolved_rewards[str(key)] = amount

	var location_bonus_text: String = apply_location_fit_bonus_to_resolved_rewards(
		npc_id,
		date_location,
		success_level,
		resolved_rewards
	)

	for key in resolved_rewards.keys():
		var amount: int = int(resolved_rewards[key])
		reward_text += "\n%s %+d" % [
			get_relationship_key_label(str(key)),
			amount
		]
		reward_text += GameManager.add_relationship_value(npc_id, str(key), amount)

	if location_bonus_text != "":
		reward_text += location_bonus_text

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
	var strategy: String = "date_success"
	var allow_advanced: bool = false
	var max_tier: int = 90

	match success_level:
		"success":
			strategy = "date_success"
			allow_advanced = false
			max_tier = 85
		"excellent":
			strategy = "date_excellent"
			allow_advanced = true
			max_tier = 100
		"perfect":
			strategy = "date_excellent"
			allow_advanced = true
			max_tier = 100

	var info_key: String = GameManager.reveal_npc_info_by_strategy(npc_id, {
		"strategy": strategy,
		"max_tier": max_tier,
		"allow_advanced": allow_advanced,
		"include_next_step_missing": true
	})

	if info_key != "":
		reveal_text += "\n\n" + GameManager.format_discovered_info(npc_id, info_key, "Información descubierta durante la cita")

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

func meets_relationship_state_requirement(npc_id: String, required_state: String) -> bool:
	GameManager.ensure_relationship(npc_id)

	var current_state: String = str(GameManager.player["relationships"][npc_id].get("relationship_state", "none"))
	var current_value: int = int(RELATIONSHIP_STATE_ORDER.get(current_state, 0))
	var required_value: int = int(RELATIONSHIP_STATE_ORDER.get(required_state, 0))

	return current_value >= required_value


func calculate_mood_score(move: Dictionary, mood_tags: Array) -> int:
	var score: int = 0

	for tag in move.get("preferred_moods", []):
		if mood_tags.has(tag):
			score += 7

	for tag in move.get("bad_moods", []):
		if mood_tags.has(tag):
			score -= 10

	return score


func calculate_npc_move_preference_score(npc_id: String, move_tags: Array) -> int:
	var profile: Dictionary = DataManager.get_npc_story_profile(npc_id)
	var preferences: Dictionary = profile.get("date_move_preferences", {})

	if preferences.is_empty():
		return 0

	var score: int = 0

	for tag in move_tags:
		if preferences.get("loves", []).has(tag):
			score += 10
		elif preferences.get("likes", []).has(tag):
			score += 5
		elif preferences.get("dislikes", []).has(tag):
			score -= 7
		elif preferences.get("hates", []).has(tag):
			score -= 14

	return score


func calculate_privacy_score(move: Dictionary, mood_tags: Array) -> int:
	var privacy_need: String = str(move.get("privacy_need", "any"))

	if privacy_need == "any":
		return 0

	var is_public: bool = mood_tags.has("public") or mood_tags.has("crowded")
	var is_private: bool = mood_tags.has("private") or mood_tags.has("intimate") or mood_tags.has("sensual")
	var is_semi_private: bool = is_private or mood_tags.has("private_soft") or mood_tags.has("quiet")

	match privacy_need:
		"public":
			return 8 if is_public else -8
		"semi_private":
			return 8 if is_semi_private else -10
		"private":
			return 12 if is_private else -18
		_:
			return 0


func calculate_known_boundary_score(npc_id: String, move_tags: Array) -> int:
	GameManager.ensure_npc_knowledge(npc_id)

	var known_info: Array = GameManager.player["known_npc_info"][npc_id].get("info", [])
	var score: int = 0

	if known_info.has("uncomfortable_provocation"):
		for tag in ["public", "exhibitionist", "bold", "risky", "sexual"]:
			if move_tags.has(tag):
				score -= 4

	if known_info.has("flirt_turn_on") or known_info.has("enjoyed_tension"):
		for tag in ["gentle", "slow_tension", "playful", "flirty", "respectful"]:
			if move_tags.has(tag):
				score += 3

	return score


func apply_move_world_pressure(move: Dictionary, mood_tags: Array, was_positive: bool) -> void:
	var move_tags: Array = move.get("move_tags", [])

	if not was_positive:
		if move_tags.has("sexual") or move_tags.has("bold") or move_tags.has("risky"):
			GameManager.add_world_state_value("romantic_pressure", 1)
		return

	if move_tags.has("public") or mood_tags.has("public") or mood_tags.has("crowded"):
		if move_tags.has("flirty") or move_tags.has("sexual") or move_tags.has("bold"):
			GameManager.add_world_state_value("romantic_pressure", 1)

	if move_tags.has("sexual") or move_tags.has("intense"):
		GameManager.add_world_state_value("romantic_pressure", 1)

func resolve_reward_amount(value) -> int:
	if typeof(value) == TYPE_DICTIONARY:
		var min_value: int = int(value.get("min", 0))
		var max_value: int = int(value.get("max", min_value))

		if max_value < min_value:
			max_value = min_value

		return randi_range(min_value, max_value)

	return int(value)


func get_relationship_key_label(key: String) -> String:
	match key:
		"friendship":
			return "Amistad"
		"tension":
			return "Tensión"
		"loyalty":
			return "Lealtad"
		"jealousy":
			return "Celos"
		_:
			return key.capitalize()


func apply_location_fit_bonus_to_resolved_rewards(
	npc_id: String,
	date_location: Dictionary,
	success_level: String,
	resolved_rewards: Dictionary
) -> String:
	if success_level != "excellent" and success_level != "perfect":
		return ""

	var preferred_npcs: Array = date_location.get("preferred_npcs", [])
	var bad_fit_npcs: Array = date_location.get("bad_fit_npcs", [])

	if bad_fit_npcs.has(npc_id):
		return ""

	var bonus: int = 0
	var reason: String = ""

	if preferred_npcs.has(npc_id):
		match success_level:
			"excellent":
				bonus = randi_range(2, 4)
			"perfect":
				bonus = randi_range(4, 7)

		reason = "El lugar encajó especialmente bien con este personaje."
	else:
		match success_level:
			"excellent":
				bonus = randi_range(1, 2)
			"perfect":
				bonus = randi_range(2, 4)

		reason = "La calidad de la cita fortaleció la confianza."

	if bonus <= 0:
		return ""

	resolved_rewards["loyalty"] = int(resolved_rewards.get("loyalty", 0)) + bonus

	return "\n%s Lealtad +%s" % [reason, bonus]
