extends Node

func get_dialogue_line(npc_id: String, category: String = "casual") -> String:
	var valid_dialogues: Array = []

	var context: Dictionary = {
		"trigger": "dialogue",
		"npc_id": npc_id,
		"category": category,
		"location": GameManager.current_location_id,
		"time_block": GameManager.current_time_block
	}

	for dialogue_id in DataManager.dialogues.keys():
		var dialogue: Dictionary = DataManager.get_dialogue(dialogue_id)

		if not dialogue_matches_npc(dialogue, npc_id):
			continue

		if not dialogue_matches_category(dialogue, category):
			continue

		var conditions: Dictionary = dialogue.get("conditions", {})

		if not ConditionSystem.check_conditions(conditions, context):
			continue

		valid_dialogues.append({
			"id": dialogue_id,
			"priority": int(dialogue.get("priority", 0)),
			"lines": dialogue.get("lines", [])
		})

	if valid_dialogues.is_empty():
		return get_default_line(npc_id)

	valid_dialogues.sort_custom(func(a, b):
		return int(a.get("priority", 0)) > int(b.get("priority", 0))
	)

	var top_priority: int = int(valid_dialogues[0].get("priority", 0))
	var top_dialogues: Array = []

	for entry in valid_dialogues:
		if int(entry.get("priority", 0)) == top_priority:
			top_dialogues.append(entry)

	var selected_dialogue: Dictionary = top_dialogues.pick_random()
	var lines: Array = selected_dialogue.get("lines", [])

	if lines.is_empty():
		return get_default_line(npc_id)

	return str(lines.pick_random())

func dialogue_matches_npc(dialogue: Dictionary, npc_id: String) -> bool:
	var dialogue_npc_id: String = dialogue.get("npc_id", "")

	if dialogue_npc_id == "*":
		return true

	return dialogue_npc_id == npc_id

func dialogue_matches_category(dialogue: Dictionary, category: String) -> bool:
	var dialogue_category: String = dialogue.get("category", "casual")

	if dialogue_category == category:
		return true

	if category == "casual" and dialogue_category == "lore":
		return true

	if category == "casual" and dialogue_category == "flirty":
		return true

	if category == "casual" and dialogue_category == "jealous":
		return true

	if category == "casual" and dialogue_category == "after_petition":
		return true

	return false

func get_default_line(npc_id: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var npc_name: String = npc.get("name", npc_id)

	return "Conversas con %s durante un rato. Algunas cosas se dicen; otras quedan suspendidas en el aire." % npc_name
