extends Node

const MAIN_MENU := "res://scenes/menu/MainMenu.tscn"
const INTRO_SCENE := "res://scenes/intro/IntroScene.tscn"
const WORLD_MAP := "res://scenes/map/WorldMap.tscn"
const LOCATION_SCENE := "res://scenes/location/LocationScene.tscn"
const HOME_SCENE := "res://scenes/home/HomeScene.tscn"
const DATE_SCENE := "res://scenes/date/DateScene.tscn"
const JOURNAL_SCENE := "res://scenes/journal/JournalScene.tscn"
const SHOP_SCENE := "res://scenes/shop/ShopScene.tscn"

var temp_npc_id: String = ""
var temp_date_location_id: String = ""
var temp_date_type: String = "normal"
var temp_relationship_step_id: String = ""

var journal_return_scene: String = WORLD_MAP


func go_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)


func go_to_intro() -> void:
	get_tree().change_scene_to_file(INTRO_SCENE)


func go_to_world_map() -> void:
	get_tree().change_scene_to_file(WORLD_MAP)


func go_to_location() -> void:
	get_tree().change_scene_to_file(LOCATION_SCENE)


func go_to_home() -> void:
	get_tree().change_scene_to_file(HOME_SCENE)


func go_to_journal(return_scene: String = "") -> void:
	if return_scene != "":
		journal_return_scene = return_scene
	else:
		journal_return_scene = WORLD_MAP

	get_tree().change_scene_to_file(JOURNAL_SCENE)


func return_from_journal() -> void:
	if journal_return_scene == "":
		get_tree().change_scene_to_file(WORLD_MAP)
		return

	get_tree().change_scene_to_file(journal_return_scene)


func go_to_shop() -> void:
	get_tree().change_scene_to_file(SHOP_SCENE)

func go_to_current_location_scene() -> void:
	var location_id: String = str(GameManager.current_location_id)

	if location_id == "":
		go_to_world_map()
		return

	if location_id == "home":
		go_to_home()
		return

	if location_id == "shop":
		go_to_shop()
		return

	go_to_location()

func load_autosave_and_route() -> bool:
	if SaveManager.load_autosave_game():
		go_to_current_location_scene()
		return true

	return false


func load_manual_and_route() -> bool:
	if SaveManager.load_manual_game():
		go_to_current_location_scene()
		return true

	return false
	
func quit_game() -> void:
	get_tree().quit()


func go_to_date(npc_id: String, date_location_id: String = "", date_type: String = "normal", relationship_step_id: String = "") -> void:
	temp_npc_id = npc_id
	temp_date_location_id = date_location_id
	temp_date_type = date_type
	temp_relationship_step_id = relationship_step_id
	get_tree().change_scene_to_file(DATE_SCENE)
	
