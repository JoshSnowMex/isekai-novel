extends Node

func check_conditions(conditions: Dictionary, context: Dictionary = {}) -> bool:
	if conditions.is_empty():
		return true

	if conditions.has("relationship"):
		if not check_relationship_conditions(conditions["relationship"], context):
			return false

	if conditions.has("player_stats"):
		if not check_player_stat_conditions(conditions["player_stats"]):
			return false

	if conditions.has("world_flags"):
		if not check_world_flag_conditions(conditions["world_flags"]):
			return false
	
	if conditions.has("world_state"):
		if not check_world_state_conditions(conditions["world_state"]):
			return false

	if conditions.has("time"):
		if not check_time_conditions(conditions["time"]):
			return false

	if conditions.has("inventory"):
		if not check_inventory_conditions(conditions["inventory"]):
			return false

	return true

func check_relationship_conditions(data: Dictionary, context: Dictionary = {}) -> bool:
	var npc_id: String = data.get("npc_id", context.get("npc_id", ""))

	if npc_id == "":
		return false

	GameManager.ensure_relationship(npc_id)

	var relation: Dictionary = GameManager.player["relationships"][npc_id]

	for key in data.keys():
		if key == "npc_id":
			continue

		var rule: Dictionary = data[key]
		var value: int = int(relation.get(key, 0))

		if not compare_number(value, rule):
			return false

	return true

func check_player_stat_conditions(data: Dictionary) -> bool:
	for stat_name in data.keys():
		var rule: Dictionary = data[stat_name]
		var value: int = int(GameManager.player["stats"].get(stat_name, 0))

		if not compare_number(value, rule):
			return false

	return true

func check_world_flag_conditions(data: Dictionary) -> bool:
	if not GameManager.player.has("world_flags"):
		GameManager.player["world_flags"] = []

	var flags: Array = GameManager.player["world_flags"]

	if data.has("has_all"):
		for flag in data["has_all"]:
			if not flags.has(flag):
				return false

	if data.has("has_any"):
		var found: bool = false

		for flag in data["has_any"]:
			if flags.has(flag):
				found = true
				break

		if not found:
			return false

	if data.has("missing_all"):
		for flag in data["missing_all"]:
			if flags.has(flag):
				return false

	return true

func check_time_conditions(data: Dictionary) -> bool:
	if data.has("min_day"):
		if GameManager.current_day < int(data["min_day"]):
			return false

	if data.has("max_day"):
		if GameManager.current_day > int(data["max_day"]):
			return false

	if data.has("time_block"):
		if GameManager.current_time_block != str(data["time_block"]):
			return false

	if data.has("location"):
		if GameManager.current_location_id != str(data["location"]):
			return false

	return true

func check_inventory_conditions(data: Dictionary) -> bool:
	if data.has("has_item"):
		var item_id: String = str(data["has_item"])
		if not GameManager.has_item(item_id):
			return false

	return true

func compare_number(value: int, rule: Dictionary) -> bool:
	if rule.has("min"):
		if value < int(rule["min"]):
			return false

	if rule.has("max"):
		if value > int(rule["max"]):
			return false

	if rule.has("equals"):
		if value != int(rule["equals"]):
			return false

	return true

func check_world_state_conditions(data: Dictionary) -> bool:
	for key in data.keys():
		var rule: Dictionary = data[key]
		var value: int = GameManager.get_world_state_value(key)

		if not compare_number(value, rule):
			return false

	return true
