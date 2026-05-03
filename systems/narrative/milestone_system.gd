extends Node

func process_milestones(context: Dictionary = {}) -> Array:
	var triggered: Array = []

	var ordered_ids: Array = DataManager.milestones.keys()
	ordered_ids.sort_custom(func(a, b):
		var milestone_a: Dictionary = DataManager.get_milestone(a)
		var milestone_b: Dictionary = DataManager.get_milestone(b)
		return int(milestone_a.get("priority", 0)) > int(milestone_b.get("priority", 0))
	)

	for milestone_id in ordered_ids:
		var milestone: Dictionary = DataManager.get_milestone(milestone_id)

		if not milestone_matches_trigger(milestone, context):
			continue

		if is_milestone_completed(milestone_id):
			continue

		var conditions: Dictionary = milestone.get("conditions", {})

		if not ConditionSystem.check_conditions(conditions, context):
			continue

		mark_milestone_completed(milestone_id)

		var text: String = milestone.get("text", "")

		if text != "":
			triggered.append({
				"id": milestone_id,
				"name": milestone.get("name", milestone_id),
				"text": text
			})

		apply_milestone_effects(milestone, context)

	return triggered

func milestone_matches_trigger(milestone: Dictionary, context: Dictionary) -> bool:
	var milestone_trigger: String = milestone.get("trigger", "")
	var context_trigger: String = context.get("trigger", "")

	if milestone_trigger == "":
		return false

	if milestone_trigger != context_trigger:
		return false

	if milestone.has("npc_id"):
		if milestone["npc_id"] != context.get("npc_id", ""):
			return false

	return true

func is_milestone_completed(milestone_id: String) -> bool:
	return GameManager.has_world_flag("milestone_completed:" + milestone_id)

func mark_milestone_completed(milestone_id: String) -> void:
	GameManager.add_world_flag("milestone_completed:" + milestone_id)

func apply_milestone_effects(milestone: Dictionary, context: Dictionary) -> void:
	var effects: Dictionary = milestone.get("effects", {})

	if effects.is_empty():
		return

	if effects.has("add_world_flags"):
		for flag in effects["add_world_flags"]:
			GameManager.add_world_flag(str(flag))

	if effects.has("relationship"):
		var npc_id: String = effects["relationship"].get("npc_id", context.get("npc_id", ""))

		for key in effects["relationship"].keys():
			if key == "npc_id":
				continue

			var amount: int = int(effects["relationship"][key])
			GameManager.add_relationship_value(npc_id, key, amount)

	if effects.has("world_state"):
		var world_state_effects: Dictionary = effects["world_state"]

		for key in world_state_effects.keys():
			var amount: int = int(world_state_effects[key])
			GameManager.add_world_state_value(key, amount)
