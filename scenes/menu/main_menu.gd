extends Control

var continue_button: Button
var load_manual_button: Button
var subtitle_label: Label

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	update_buttons()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	var spacer_top: Control = Control.new()
	spacer_top.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer_top)

	root.add_child(UIFactory.title(DataManager.game_config.get("game_title", "Isekai Social Sim")))

	subtitle_label = UIFactory.body("Drama romántico · Tensión adulta · Fantasía isekai")
	root.add_child(subtitle_label)

	var menu_container: VBoxContainer = VBoxContainer.new()
	menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.add_theme_constant_override("separation", 10)
	menu_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(menu_container)

	var new_game_button: Button = UIFactory.button("Nuevo juego")
	new_game_button.pressed.connect(_on_new_game_pressed)
	menu_container.add_child(new_game_button)

	continue_button = UIFactory.button("Continuar")
	continue_button.pressed.connect(_on_continue_pressed)
	menu_container.add_child(continue_button)

	load_manual_button = UIFactory.button("Cargar guardado manual")
	load_manual_button.pressed.connect(_on_load_manual_pressed)
	menu_container.add_child(load_manual_button)

	var quit_button: Button = UIFactory.button("Salir")
	quit_button.pressed.connect(_on_quit_pressed)
	menu_container.add_child(quit_button)

	var spacer_bottom: Control = Control.new()
	spacer_bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(spacer_bottom)

func update_buttons() -> void:
	continue_button.disabled = not SaveManager.has_continue_file()
	load_manual_button.disabled = not SaveManager.has_manual_save_file()

func _on_new_game_pressed() -> void:
	SceneRouter.go_to_intro()

func _on_continue_pressed() -> void:
	if SaveManager.load_continue_game():
		SceneRouter.go_to_current_location_scene()

func _on_load_manual_pressed() -> void:
	if SaveManager.load_manual_game():
		SceneRouter.go_to_current_location_scene()

func _on_quit_pressed() -> void:
	SceneRouter.quit_game()
	
func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
