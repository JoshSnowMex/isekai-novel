extends Control

var continue_button: Button
var subtitle_label: Label

func _ready() -> void:
	build_ui()
	update_buttons()

func build_ui() -> void:
	var root := ScreenRoot.create(self)

	root.add_child(UIFactory.title(DataManager.game_config.get("game_title", "Isekai Social Sim")))

	subtitle_label = UIFactory.body("Drama romántico · Tensión adulta · Fantasía isekai")
	root.add_child(subtitle_label)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, 24)
	root.add_child(spacer)

	var new_game_button := UIFactory.button("Nuevo juego")
	new_game_button.pressed.connect(_on_new_game_pressed)
	root.add_child(new_game_button)

	continue_button = UIFactory.button("Continuar")
	continue_button.pressed.connect(_on_continue_pressed)
	root.add_child(continue_button)

	var quit_button := UIFactory.button("Salir")
	quit_button.pressed.connect(_on_quit_pressed)
	root.add_child(quit_button)

func update_buttons() -> void:
	continue_button.disabled = not SaveManager.has_save_file()

func _on_new_game_pressed() -> void:
	SceneRouter.go_to_intro()

func _on_continue_pressed() -> void:
	if SaveManager.load_game():
		SceneRouter.go_to_world_map()

func _on_quit_pressed() -> void:
	SceneRouter.quit_game()
