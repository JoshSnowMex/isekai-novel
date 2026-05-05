extends Node


func has_final_union() -> bool:
	return str(GameManager.player.get("final_union_npc_id", "")) != ""


func get_final_union_npc_id() -> String:
	return str(GameManager.player.get("final_union_npc_id", ""))


func get_available_candidates() -> Array:
	var result: Array = []

	if has_final_union():
		return result

	for npc_id in DataManager.npcs.keys():
		if can_attempt_final_union(npc_id):
			result.append(npc_id)

	return result


func can_attempt_final_union(npc_id: String) -> bool:
	return get_blocked_reason(npc_id) == ""


func get_blocked_reason(npc_id: String) -> String:
	if has_final_union():
		var chosen_id: String = get_final_union_npc_id()
		var chosen_npc: Dictionary = DataManager.get_npc(chosen_id)

		return "Ya existe una unión definitiva con %s." % chosen_npc.get("name", chosen_id)

	if not GameManager.is_npc_romanceable(npc_id):
		return "Este personaje no está disponible como unión romántica."

	GameManager.ensure_relationship(npc_id)

	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)
	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	var required_state: String = str(requirement.get("required_relationship_state", "partner"))
	var current_state: String = str(relation.get("relationship_state", "none"))

	if current_state != required_state:
		return "La ruta personal debe estar en estado %s." % GameManager.get_relationship_state_label(required_state)

	var total: int = GameManager.get_total_affinity(npc_id)
	var required_total: int = int(requirement.get("required_total_affinity", 98))

	if total < required_total:
		return "Vínculo insuficiente para una unión final. Requerido: %s." % required_total

	var loyalty: int = int(relation.get("loyalty", 0))
	var required_loyalty: int = int(requirement.get("required_loyalty", 70))

	if loyalty < required_loyalty:
		return "La lealtad todavía no sostiene una elección definitiva. Requerida: %s." % required_loyalty

	var jealousy: int = int(relation.get("jealousy", 0))
	var max_jealousy: int = int(requirement.get("max_jealousy", 35))

	if jealousy > max_jealousy:
		return "Los celos siguen demasiado altos para una unión final. Máximo permitido: %s." % max_jealousy

	var info_reason: String = get_info_requirement_blocked_reason(npc_id, requirement.get("required_info_categories", {}))

	if info_reason != "":
		return info_reason

	if bool(requirement.get("required_successful_date", true)):
		if not GameManager.has_world_flag("successful_date:%s" % npc_id):
			return "Necesitas al menos una cita normal exitosa con este personaje."

	if bool(requirement.get("required_perfect_or_excellent_date", true)):
		if not has_excellent_or_perfect_date(npc_id):
			return "Necesitas al menos una cita excelente o perfecta con este personaje."

	var collectible_reason: String = get_collectible_requirement_blocked_reason(npc_id, requirement)

	if collectible_reason != "":
		return collectible_reason

	return ""


func get_info_requirement_blocked_reason(npc_id: String, requirements: Dictionary) -> String:
	if requirements.is_empty():
		return ""

	var missing_lines: Array = []

	for category_id in requirements.keys():
		var required_count: int = int(requirements[category_id])
		var known_count: int = GameManager.get_known_info_count_for_category(npc_id, str(category_id))
		var category_title: String = GameManager.get_info_category_title(str(category_id))

		if known_count < required_count:
			missing_lines.append("- %s: %s/%s" % [
				category_title,
				known_count,
				required_count
			])

	if missing_lines.is_empty():
		return ""

	var text: String = "Falta conocer información clave antes de una unión final:\n"

	for line in missing_lines:
		text += "%s\n" % line

	return text.strip_edges()


func get_collectible_requirement_blocked_reason(npc_id: String, requirement: Dictionary) -> String:
	for collectible_id in requirement.get("required_collectibles", []):
		if not GameManager.has_collectible(str(collectible_id)):
			return "Falta una memoria emocional clave para esta unión final."

	for prefix_template in requirement.get("required_collectible_prefixes", []):
		var prefix: String = str(prefix_template).replace("{npc_id}", npc_id)

		if not has_collectible_with_prefix(prefix):
			return "Necesitas al menos una memoria emocional importante con este personaje."

	return ""


func has_collectible_with_prefix(prefix: String) -> bool:
	for collectible_id in GameManager.get_collectibles():
		if str(collectible_id).begins_with(prefix):
			return true

	return false


func has_excellent_or_perfect_date(npc_id: String) -> bool:
	for flag in GameManager.player.get("world_flags", []):
		var text: String = str(flag)

		if text.begins_with("successful_date:%s:" % npc_id):
			if text.ends_with(":excellent") or text.ends_with(":perfect"):
				return true

	return false


func get_candidate_summary(npc_id: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)
	var reason: String = get_blocked_reason(npc_id)

	var text: String = "%s\n" % npc.get("name", npc_id)
	text += "%s\n" % requirement.get("name", "Unión final")

	if reason == "":
		text += "Disponible para propuesta final."
	else:
		text += "Bloqueado: %s" % reason

	return text


func complete_final_union(npc_id: String) -> Dictionary:
	var reason: String = get_blocked_reason(npc_id)

	if reason != "":
		return {
			"success": false,
			"text": reason
		}

	var requirement: Dictionary = DataManager.get_final_union_requirement(npc_id)
	var npc: Dictionary = DataManager.get_npc(npc_id)

	GameManager.player["final_union_npc_id"] = npc_id
	GameManager.add_world_flag("final_union_chosen")
	GameManager.add_world_flag("final_union:%s" % npc_id)
	GameManager.add_collectible("union_token:%s:final_union" % npc_id)

	GameManager.add_npc_note(
		npc_id,
		"El Forastero eligió a %s como unión definitiva." % npc.get("name", npc_id)
	)

	GameManager.add_world_state_value("romantic_pressure", 8)

	var story_role: Dictionary = DataManager.get_npc_story_profile(npc_id).get("story_role", {})
	var veil_sensitivity: int = int(story_role.get("veil_sensitivity", 0))
	var social_risk: int = int(story_role.get("social_risk", 0))

	if veil_sensitivity >= 70:
		GameManager.add_world_state_value("world_instability", 4)

	if social_risk >= 70:
		GameManager.add_world_state_value("global_tension", 4)

	return {
		"success": true,
		"text": requirement.get(
			"success_text",
			"%s acepta la unión definitiva." % npc.get("name", npc_id)
		)
	}
