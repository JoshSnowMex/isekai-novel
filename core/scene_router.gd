extends Node

const MAIN_MENU := "res://scenes/menu/MainMenu.tscn"
const INTRO_SCENE := "res://scenes/intro/IntroScene.tscn"
const WORLD_MAP := "res://scenes/map/WorldMap.tscn"
const LOCATION_SCENE := "res://scenes/location/LocationScene.tscn"
const DATE_SCENE := "res://scenes/date/DateScene.tscn"
const JOURNAL_SCENE := "res://scenes/journal/JournalScene.tscn"
const SHOP_SCENE := "res://scenes/shop/ShopScene.tscn"

var temp_npc_id: String = ""

func go_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

func go_to_intro() -> void:
	get_tree().change_scene_to_file(INTRO_SCENE)

func go_to_world_map() -> void:
	get_tree().change_scene_to_file(WORLD_MAP)
	
func go_to_location() -> void:
	get_tree().change_scene_to_file(LOCATION_SCENE)
	
func go_to_date(npc_id: String) -> void:
	temp_npc_id = npc_id
	get_tree().change_scene_to_file(DATE_SCENE)

func go_to_journal() -> void:
	get_tree().change_scene_to_file(JOURNAL_SCENE)
	
func go_to_shop() -> void:
	get_tree().change_scene_to_file(SHOP_SCENE)

func quit_game() -> void:
	get_tree().quit()
