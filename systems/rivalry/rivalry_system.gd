extends Node

func process_affinity_change(source_npc_id: String, amount: int) -> Array:
	var results: Array = []

	if amount <= 0:
		return results

	for rivalry_id in DataManager.rivalries.keys():
		var rivalry: Dictionary = DataManager.get_rivalry(rivalry_id)

		if not rivalry.get("enabled", false):
			continue

		var npc_a: String = rivalry.get("npc_a", "")
		var npc_b: String = rivalry.get("npc_b", "")

		if not DataManager.npcs.has(npc_a) or not DataManager.npcs.has(npc_b):
			continue

		if source_npc_id != npc_a and source_npc_id != npc_b:
			continue

		var affected_npc_id: String = npc_b if source_npc_id == npc_a else npc_a
		var rules: Dictionary = rivalry.get("rules", {})

		var threshold: int = int(rules.get("affinity_gain_threshold", 5))
		var minimum_affinity: int = int(rules.get("minimum_affinity_to_trigger", 40))
		var penalty_ratio: float = float(rules.get("penalty_ratio", 0.5))

		if amount < threshold:
			continue

		GameManager.ensure_relationship(source_npc_id)
		GameManager.ensure_relationship(affected_npc_id)

		var source_relation: Dictionary = GameManager.player["relationships"][source_npc_id]

		if int(source_relation.get("affinity", 0)) < minimum_affinity:
			continue

		var penalty: int = max(1, int(round(float(amount) * penalty_ratio)))
		var affected_relation: Dictionary = GameManager.player["relationships"][affected_npc_id]

		affected_relation["jealousy"] = clamp(
			int(affected_relation.get("jealousy", 0)) + penalty,
			0,
			100
		)

		GameManager.add_npc_note(
			affected_npc_id,
			"Algo cambió al notar tu cercanía con otra persona."
		)

		results.append({
			"rivalry_id": rivalry_id,
			"affected_npc_id": affected_npc_id,
			"penalty": penalty,
			"description": rivalry.get("description", "")
		})

	return results
