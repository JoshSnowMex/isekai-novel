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
var dialogues: Dictionary = {}
var petitions: Dictionary = {}
var date_locations: Dictionary = {}
var date_moves: Dictionary = {}
var relationship_steps: Dictionary = {}
var npc_story_profiles: Dictionary = {}
var storylets: Dictionary = {}
var final_union_requirements: Dictionary = {}
var postgame_config: Dictionary = {}
var postgame_storylets: Dictionary = {}
var ui_assets: Dictionary = {}

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
	petitions = load_json("res://data/petitions.json")
	dialogues = load_json("res://data/dialogues.json")
	date_locations = load_json("res://data/date_locations.json")
	date_moves = load_json("res://data/date_moves.json")
	relationship_steps = load_json("res://data/relationship_steps.json")
	npc_story_profiles = load_json("res://data/npc_story_profiles.json")
	storylets = load_json("res://data/storylets.json")
	final_union_requirements = load_json("res://data/final_union_requirements.json")
	postgame_config = load_json("res://data/postgame_config.json")
	postgame_storylets = load_json("res://data/postgame_storylets.json")
	ui_assets = load_json("res://data/ui_assets.json")

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

func get_dialogue(dialogue_id: String) -> Dictionary:
	return dialogues.get(dialogue_id, {})

func get_petition(petition_id: String) -> Dictionary:
	return petitions.get(petition_id, {})

func get_date_location(date_location_id: String) -> Dictionary:
	return date_locations.get(date_location_id, {})

func get_date_move(date_move_id: String) -> Dictionary:
	return date_moves.get(date_move_id, {})

func get_relationship_step(step_id: String) -> Dictionary:
	return relationship_steps.get(step_id, {})

func get_npc_story_profile(npc_id: String) -> Dictionary:
	return npc_story_profiles.get(npc_id, {})

func get_storylet(storylet_id: String) -> Dictionary:
	return storylets.get(storylet_id, {})

func get_final_union_requirement(npc_id: String) -> Dictionary:
	var default_data: Dictionary = final_union_requirements.get("default", {})
	var npc_data: Dictionary = final_union_requirements.get(npc_id, {})
	var result: Dictionary = default_data.duplicate(true)

	for key in npc_data.keys():
		result[key] = npc_data[key]

	return result

func get_postgame_default_config() -> Dictionary:
	return postgame_config.get("default", {})


func get_postgame_partner_config(npc_id: String) -> Dictionary:
	var partners: Dictionary = postgame_config.get("partners", {})
	var default_data: Dictionary = postgame_config.get("default", {})
	var partner_data: Dictionary = partners.get(npc_id, {})
	var result: Dictionary = default_data.duplicate(true)

	for key in partner_data.keys():
		result[key] = partner_data[key]

	return result


func get_postgame_storylet(storylet_id: String) -> Dictionary:
	return postgame_storylets.get(storylet_id, {})

func get_ui_asset_section(section_id: String) -> Dictionary:
	return ui_assets.get(section_id, {})


func get_location_ui(location_id: String) -> Dictionary:
	var locations_ui: Dictionary = ui_assets.get("locations", {})
	return locations_ui.get(location_id, {})


func get_npc_ui(npc_id: String) -> Dictionary:
	var npcs_ui: Dictionary = ui_assets.get("npcs", {})
	return npcs_ui.get(npc_id, {})

func get_title_screen_ui() -> Dictionary:
	return ui_assets.get("title_screen", {})

func get_intro_ui() -> Dictionary:
	return ui_assets.get("intro", {})

func get_world_map_ui() -> Dictionary:
	return ui_assets.get("world_map", {})


func get_ui_theme_assets() -> Dictionary:
	return ui_assets.get("ui", {})
