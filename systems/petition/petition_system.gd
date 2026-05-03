extends Node

func get_available_petitions(npc_id: String) -> Array:
	var result: Array = []

	for petition_id in DataManager.petitions.keys():
		var petition: Dictionary = DataManager.get_petition(petition_id)

		if petition.get("npc_id", "") != npc_id:
			continue

		if is_petition_completed(petition_id):
			continue

		var conditions: Dictionary = petition.get("conditions", {})
		var context: Dictionary = {
			"trigger": "petition_available",
			"npc_id": npc_id,
			"petition_id": petition_id
		}

		if not ConditionSystem.check_conditions(conditions, context):
			continue

		result.append(petition_id)

	return result

func has_any_available_petition(npc_id: String) -> bool:
	return not get_available_petitions(npc_id).is_empty()

func is_petition_completed(petition_id: String) -> bool:
	return GameManager.has_world_flag("petition_completed:" + petition_id)

func mark_petition_completed(petition_id: String) -> void:
	GameManager.add_world_flag("petition_completed:" + petition_id)

func perform_petition(petition_id: String) -> Dictionary:
	var petition: Dictionary = DataManager.get_petition(petition_id)

	if petition.is_empty():
		return {
			"success": false,
			"text": "La petición no existe."
		}

	var npc_id: String = petition.get("npc_id", "")

	if petition.get("once", true) and is_petition_completed(petition_id):
		return {
			"success": false,
			"text": "Esta petición ya fue resuelta."
		}

	var context: Dictionary = {
		"trigger": "petition_performed",
		"npc_id": npc_id,
		"petition_id": petition_id
	}

	var conditions: Dictionary = petition.get("conditions", {})

	if not ConditionSystem.check_conditions(conditions, context):
		apply_effects(npc_id, petition.get("effects_failure", {}))
		return {
			"success": false,
			"text": petition.get("failure_text", "La petición fue rechazada.")
		}

	apply_effects(npc_id, petition.get("effects_success", {}))
	mark_petition_completed(petition_id)

	var event_texts: Array = EventSystem.process_events({
		"trigger": "petition_completed",
		"npc_id": npc_id,
		"petition_id": petition_id
	})

	var milestone_results: Array = MilestoneSystem.process_milestones({
		"trigger": "petition_completed",
		"npc_id": npc_id,
		"petition_id": petition_id
	})

	for milestone in milestone_results:
		GameManager.add_pending_narrative_message(milestone)

	var final_text: String = petition.get("success_text", "La petición fue aceptada.")

	for text in event_texts:
		final_text += "\n\n" + str(text)

	return {
		"success": true,
		"text": final_text
	}

func apply_effects(npc_id: String, effects: Dictionary) -> void:
	if effects.is_empty():
		return

	if effects.has("add_world_flags"):
		for flag in effects["add_world_flags"]:
			GameManager.add_world_flag(str(flag))

	if effects.has("relationship"):
		var relationship_effects: Dictionary = effects["relationship"]

		for key in relationship_effects.keys():
			var amount: int = int(relationship_effects[key])
			GameManager.add_relationship_value(npc_id, key, amount)

	if effects.has("world_state"):
		var world_state_effects: Dictionary = effects["world_state"]

		for key in world_state_effects.keys():
			var amount: int = int(world_state_effects[key])
			GameManager.add_world_state_value(key, amount)
