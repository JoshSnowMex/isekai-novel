extends Node

const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
	var save_data := {
		"player": GameManager.player,
		"current_day": GameManager.current_day,
		"current_month": GameManager.current_month,
		"current_weekday_index": GameManager.current_weekday_index,
		"current_time_block": GameManager.current_time_block,
		"current_action_index": GameManager.current_action_index,
		"current_location_id": GameManager.current_location_id
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)

	if typeof(data) != TYPE_DICTIONARY:
		return false

	GameManager.player = data.get("player", {})
	GameManager.current_day = data.get("current_day", 1)
	GameManager.current_month = data.get("current_month", 1)
	GameManager.current_weekday_index = data.get("current_weekday_index", 0)
	GameManager.current_time_block = data.get("current_time_block", "morning")
	GameManager.current_action_index = data.get("current_action_index", 0)
	GameManager.current_location_id = data.get("current_location_id", "home")

	return true

func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
