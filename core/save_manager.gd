extends Node

const AUTOSAVE_PATH := "user://autosave.json"
const MANUAL_SAVE_PATH := "user://savegame.json"


func autosave_game() -> void:
	write_save_file(AUTOSAVE_PATH)


func save_game() -> void:
	write_save_file(MANUAL_SAVE_PATH)


func write_save_file(path: String) -> void:
	var save_data := {
		"player": GameManager.player,
		"current_day": GameManager.current_day,
		"current_month": GameManager.current_month,
		"current_weekday_index": GameManager.current_weekday_index,
		"current_time_block": GameManager.current_time_block,
		"current_action_index": GameManager.current_action_index,
		"current_location_id": GameManager.current_location_id,
		"final_union_npc_id": GameManager.player.get("final_union_npc_id", "")
	}

	var file := FileAccess.open(path, FileAccess.WRITE)

	if file == null:
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func load_continue_game() -> bool:
	if FileAccess.file_exists(AUTOSAVE_PATH):
		return load_from_path(AUTOSAVE_PATH)

	if FileAccess.file_exists(MANUAL_SAVE_PATH):
		return load_from_path(MANUAL_SAVE_PATH)

	return false


func load_manual_game() -> bool:
	return load_from_path(MANUAL_SAVE_PATH)


func load_game() -> bool:
	return load_continue_game()


func load_from_path(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false

	var file := FileAccess.open(path, FileAccess.READ)

	if file == null:
		return false

	var content := file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if typeof(data) != TYPE_DICTIONARY:
		return false

	GameManager.player = data.get("player", {})
	GameManager.current_day = int(data.get("current_day", 1))
	GameManager.current_month = int(data.get("current_month", 1))
	GameManager.current_weekday_index = int(data.get("current_weekday_index", 0))
	GameManager.current_time_block = str(data.get("current_time_block", "morning"))
	GameManager.current_action_index = int(data.get("current_action_index", 0))
	GameManager.current_location_id = str(data.get("current_location_id", "home"))
	
	if not GameManager.player.has("final_union_npc_id"):
		GameManager.player["final_union_npc_id"] = str(data.get("final_union_npc_id", ""))

	if not GameManager.player.has("emotional_calendar"):
		GameManager.player["emotional_calendar"] = {}
		
	return true


func has_continue_file() -> bool:
	return FileAccess.file_exists(AUTOSAVE_PATH) or FileAccess.file_exists(MANUAL_SAVE_PATH)


func has_manual_save_file() -> bool:
	return FileAccess.file_exists(MANUAL_SAVE_PATH)


func has_save_file() -> bool:
	return has_continue_file()
