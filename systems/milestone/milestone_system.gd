extends Node

func process_milestones(context: Dictionary = {}) -> Array:
	var triggered: Array = []

	for milestone_id in DataManager.milestones.keys():
		var milestone: Dictionary = DataManager.milestones[milestone_id]

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
			triggered.append(text)

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
	if not GameManager.player.has("world_flags"):
		GameManager.player["world_flags"] = []

	var flag: String = "milestone_completed:" + milestone_id
	return GameManager.player["world_flags"].has(flag)

func mark_milestone_completed(milestone_id: String) -> void:
	if not GameManager.player.has("world_flags"):
		GameManager.player["world_flags"] = []

	var flag: String = "milestone_completed:" + milestone_id

	if not GameManager.player["world_flags"].has(flag):
		GameManager.player["world_flags"].append(flag)

func apply_milestone_effects(milestone: Dictionary, context: Dictionary) -> void:
	var effects: Dictionary = milestone.get("effects", {})

	if effects.is_empty():
		return

	if effects.has("add_world_flags"):
		for flag in effects["add_world_flags"]:
			GameManager.add_world_flag(str(flag))

	if effects.has("world_state"):
		var world_state_effects: Dictionary = effects["world_state"]

		for key in world_state_effects.keys():
			var amount: int = int(world_state_effects[key])
			GameManager.add_world_state_value(key, amount)

	if effects.has("relationship"):
		var npc_id: String = effects["relationship"].get("npc_id", context.get("npc_id", ""))

		if npc_id != "":
			for key in effects["relationship"].keys():
				if key == "npc_id":
					continue

				var amount: int = int(effects["relationship"][key])
				GameManager.add_relationship_value(npc_id, key, amount)
