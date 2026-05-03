extends Node

var game_config: Dictionary = {}
var player_classes: Dictionary = {}
var locations: Dictionary = {}
var npcs: Dictionary = {}
var npc_info_schema: Dictionary = {}
var items: Dictionary = {}
var activities: Dictionary = {}
var rivalries: Dictionary = {}
var events: Dictionary = {}
var milestones: Dictionary = {}

func _ready() -> void:
	load_all_data()

func load_all_data() -> void:
	game_config = load_json("res://data/game_config.json")
	player_classes = load_json("res://data/player_classes.json")
	locations = load_json("res://data/locations.json")
	npcs = load_json("res://data/npcs.json")
	npc_info_schema = load_json("res://data/npc_info_schema.json")
	items = load_json("res://data/items.json")
	activities = load_json("res://data/activities.json")
	rivalries = load_json("res://data/rivalries.json")
	events = load_json("res://data/events.json")
	milestones = load_json("res://data/milestones.json")

func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON file not found: " + path)
		return {}

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()

	var result: Variant = JSON.parse_string(content)

	if typeof(result) != TYPE_DICTIONARY:
		push_error("Invalid JSON dictionary: " + path)
		return {}

	return result

func get_player_class(class_id: String) -> Dictionary:
	return player_classes.get(class_id, {})

func get_location(location_id: String) -> Dictionary:
	return locations.get(location_id, {})

func get_npc(npc_id: String) -> Dictionary:
	return npcs.get(npc_id, {})

func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})

func get_activity(activity_id: String) -> Dictionary:
	return activities.get(activity_id, {})

func get_milestone(milestone_id: String) -> Dictionary:
	return milestones.get(milestone_id, {})

func get_rivalry(rivalry_id: String) -> Dictionary:
	return rivalries.get(rivalry_id, {})
