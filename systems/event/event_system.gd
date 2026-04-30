extends Node

func process_events(context: Dictionary = {}) -> Array:
	var triggered: Array = []

	for event_id in DataManager.events.keys():
		var event: Dictionary = DataManager.events[event_id]

		if not event_matches_trigger(event, context):
			continue

		if is_event_completed(event_id):
			continue

		var conditions: Dictionary = event.get("conditions", {})

		if not ConditionSystem.check_conditions(conditions, context):
			continue

		mark_event_completed(event_id)

		var text: String = event.get("text", "")
		if text != "":
			triggered.append(text)

		apply_event_effects(event, context)

	return triggered

func event_matches_trigger(event: Dictionary, context: Dictionary) -> bool:
	var event_trigger: String = event.get("trigger", "")
	var context_trigger: String = context.get("trigger", "")

	if event_trigger == "":
		return false

	if event_trigger != context_trigger:
		return false

	if event.has("npc_id"):
		if event["npc_id"] != context.get("npc_id", ""):
			return false

	return true

func is_event_completed(event_id: String) -> bool:
	if not GameManager.player.has("world_flags"):
		GameManager.player["world_flags"] = []

	var flag: String = "event_completed:" + event_id
	return GameManager.player["world_flags"].has(flag)

func mark_event_completed(event_id: String) -> void:
	if not GameManager.player.has("world_flags"):
		GameManager.player["world_flags"] = []

	var flag: String = "event_completed:" + event_id

	if not GameManager.player["world_flags"].has(flag):
		GameManager.player["world_flags"].append(flag)

func apply_event_effects(event: Dictionary, context: Dictionary) -> void:
	var effects: Dictionary = event.get("effects", {})

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
