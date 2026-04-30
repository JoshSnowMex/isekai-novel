extends Node

func process_affinity_events(npc_id: String, affinity: int) -> Array:
	var triggered: Array = []

	for event_id in DataManager.events.keys():
		var event: Dictionary = DataManager.events[event_id]

		if event.get("type", "") != "affinity":
			continue

		if event.get("npc_id", "") != npc_id:
			continue

		var threshold: int = int(event.get("threshold", 0))

		if affinity < threshold:
			continue

		GameManager.ensure_npc_knowledge(npc_id)

		var knowledge: Dictionary = GameManager.player["known_npc_info"][npc_id]

		if not knowledge.has("events_triggered"):
			knowledge["events_triggered"] = []

		if event.get("once", false) and knowledge["events_triggered"].has(event_id):
			continue

		knowledge["events_triggered"].append(event_id)

		triggered.append(event.get("text", ""))

	return triggered
