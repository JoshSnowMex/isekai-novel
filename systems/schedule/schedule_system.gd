extends Node


func get_npc_location(npc_id: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var schedule: Dictionary = npc.get("schedule", {})

	var special_location: String = get_special_schedule_location(npc_id, schedule)

	if special_location != "":
		return special_location

	var day_type: String = get_day_type()
	var time_block: String = GameManager.current_time_block

	if schedule.has(day_type):
		var day_schedule: Dictionary = schedule.get(day_type, {})

		if day_schedule.has(time_block):
			return str(day_schedule.get(time_block, ""))

	if schedule.has("default"):
		var default_schedule: Dictionary = schedule.get("default", {})

		if default_schedule.has(time_block):
			return str(default_schedule.get(time_block, ""))

	if schedule.has(time_block):
		return str(schedule.get(time_block, ""))

	return ""


func get_day_type() -> String:
	var weekday_index: int = GameManager.current_weekday_index

	if weekday_index == 5:
		return "saturday"

	if weekday_index == 6:
		return "sunday"

	return "weekday"


func get_day_type_label() -> String:
	match get_day_type():
		"weekday":
			return "Lunes a viernes"
		"saturday":
			return "Sábado"
		"sunday":
			return "Domingo"
		_:
			return "Día desconocido"


func get_special_schedule_location(npc_id: String, schedule: Dictionary) -> String:
	if schedule.has("conditions"):
		for entry in schedule.get("conditions", []):
			var condition_entry: Dictionary = entry
			var conditions: Dictionary = condition_entry.get("conditions", {})

			if ConditionSystem.check_conditions(conditions, {
				"npc_id": npc_id,
				"trigger": "schedule_check"
			}):
				var location: String = str(condition_entry.get(GameManager.current_time_block, ""))

				if location != "":
					return location

				location = str(condition_entry.get("location", ""))

				if location != "":
					return location

	return ""


func get_schedule_location_for(npc_id: String, day_type: String, time_block: String) -> String:
	var npc: Dictionary = DataManager.get_npc(npc_id)
	var schedule: Dictionary = npc.get("schedule", {})

	if schedule.has(day_type):
		var day_schedule: Dictionary = schedule.get(day_type, {})

		if day_schedule.has(time_block):
			return str(day_schedule.get(time_block, ""))

	if schedule.has("default"):
		var default_schedule: Dictionary = schedule.get("default", {})

		if default_schedule.has(time_block):
			return str(default_schedule.get(time_block, ""))

	if schedule.has(time_block):
		return str(schedule.get(time_block, ""))

	return ""


func get_time_block_label(time_block: String) -> String:
	match time_block:
		"morning":
			return "Mañana"
		"afternoon":
			return "Tarde"
		"night":
			return "Noche"
		_:
			return time_block
