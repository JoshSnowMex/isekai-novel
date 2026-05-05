extends Node

const COMPLETED_PREFIX := "storylet_completed:"
const BLOCKED_PREFIX := "storylet_blocked:"


func process_storylets(context: Dictionary = {}) -> Array:
	var available: Array = get_available_storylets(context)

	if available.is_empty():
		return []

	available.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)

	var selected: Dictionary = available[0]
	var storylet_id: String = selected.get("storylet_id", "")
	var storylet: Dictionary = selected.get("storylet", {})

	if storylet_id == "" or storylet.is_empty():
		return []

	var text: String = complete_storylet(storylet_id, storylet, context)

	if text == "":
		return []

	return [text]


func get_available_storylets(context: Dictionary = {}) -> Array:
	var result: Array = []

	for storylet_id in DataManager.storylets.keys():
		var storylet: Dictionary = DataManager.get_storylet(storylet_id)

		if not is_storylet_available(storylet_id, storylet, context):
			continue

		var weight: int = calculate_storylet_weight(storylet_id, storylet, context)

		if weight <= 0:
			continue

		result.append({
			"storylet_id": storylet_id,
			"storylet": storylet,
			"weight": weight
		})

	return result


func is_storylet_available(storylet_id: String, storylet: Dictionary, context: Dictionary = {}) -> bool:
	if storylet.is_empty():
		return false

	if is_storylet_completed(storylet_id) and not bool(storylet.get("repeatable", false)):
		return false

	if GameManager.has_world_flag(BLOCKED_PREFIX + storylet_id):
		return false

	var npc_id: String = storylet.get("npc_id", "")

	if npc_id != "":
		var profile: Dictionary = DataManager.get_npc_story_profile(npc_id)

		if profile.is_empty():
			return false

		if not bool(profile.get("romanceable", true)) and storylet.get("category", "") in ["romance", "final_union"]:
			return false

	var conditions: Dictionary = storylet.get("conditions", {})

	if not ConditionSystem.check_conditions(conditions, build_condition_context(storylet, context)):
		return false

	return true


func build_condition_context(storylet: Dictionary, context: Dictionary = {}) -> Dictionary:
	var result: Dictionary = context.duplicate(true)

	if storylet.get("npc_id", "") != "":
		result["npc_id"] = storylet.get("npc_id", "")

	return result


func calculate_storylet_weight(storylet_id: String, storylet: Dictionary, context: Dictionary = {}) -> int:
	var weight: int = int(storylet.get("priority", 0))
	var npc_id: String = storylet.get("npc_id", "")

	if npc_id == "":
		return weight

	GameManager.ensure_relationship(npc_id)

	var friendship: int = GameManager.get_relationship_value(npc_id, "friendship")
	var tension: int = GameManager.get_relationship_value(npc_id, "tension")
	var loyalty: int = GameManager.get_relationship_value(npc_id, "loyalty")
	var jealousy: int = GameManager.get_relationship_value(npc_id, "jealousy")
	var total: int = GameManager.get_total_affinity(npc_id)

	var profile: Dictionary = DataManager.get_npc_story_profile(npc_id)
	var story_role: Dictionary = profile.get("story_role", {})

	var veil_sensitivity: int = int(story_role.get("veil_sensitivity", 0))
	var social_risk: int = int(story_role.get("social_risk", 0))
	var romantic_disruption: int = int(story_role.get("romantic_disruption", 0))

	weight += int(total * 0.4)
	weight += int(friendship * 0.15)
	weight += int(tension * 0.15)
	weight += int(loyalty * 0.25)

	var consequence_type: String = storylet.get("consequence_type", "")

	if consequence_type in ["cost", "rupture", "escalation"]:
		weight += int(jealousy * 0.15)
		weight += int(romantic_disruption * 0.2)

	if storylet.get("category", "") == "main_story":
		weight += int(veil_sensitivity * 0.15)

	if storylet.get("category", "") == "consequence":
		weight += int(social_risk * 0.1)

	var compatibility: Dictionary = GameManager.get_romantic_compatibility(npc_id)

	if int(compatibility.get("modifier", 0)) < 0 and tension >= 20 and loyalty >= 20:
		weight += 6

	return weight


func complete_storylet(storylet_id: String, storylet: Dictionary, context: Dictionary = {}) -> String:
	mark_storylet_completed(storylet_id)
	block_incompatible_storylets(storylet)
	apply_storylet_effects(storylet, context)

	var title: String = storylet.get("title", "Historia")
	var text: String = storylet.get("text", "")

	if text == "":
		return title

	return "%s\n\n%s" % [title, text]


func apply_storylet_effects(storylet: Dictionary, context: Dictionary = {}) -> void:
	var effects: Dictionary = storylet.get("effects", {})
	var npc_id: String = storylet.get("npc_id", context.get("npc_id", ""))

	if effects.is_empty():
		return

	if effects.has("add_world_flags"):
		for flag in effects["add_world_flags"]:
			GameManager.add_world_flag(str(flag))

	if effects.has("world_state"):
		var world_state_effects: Dictionary = effects["world_state"]

		for key in world_state_effects.keys():
			GameManager.add_world_state_value(str(key), int(world_state_effects[key]))

	if effects.has("relationship") and npc_id != "":
		var relationship_effects: Dictionary = effects["relationship"]

		for key in relationship_effects.keys():
			GameManager.add_relationship_value(npc_id, str(key), int(relationship_effects[key]))

	if effects.has("collectibles"):
		for collectible_id in effects["collectibles"]:
			GameManager.add_collectible(str(collectible_id))


func block_incompatible_storylets(storylet: Dictionary) -> void:
	for blocked_id in storylet.get("blocks", []):
		GameManager.add_world_flag(BLOCKED_PREFIX + str(blocked_id))


func is_storylet_completed(storylet_id: String) -> bool:
	return GameManager.has_world_flag(COMPLETED_PREFIX + storylet_id)


func mark_storylet_completed(storylet_id: String) -> void:
	GameManager.add_world_flag(COMPLETED_PREFIX + storylet_id)
