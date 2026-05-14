extends Control


var background_layer: Control
var logo_layer: Control
var menu_panel: PanelContainer

var continue_button: Button
var load_manual_button: Button


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	update_buttons()
	call_deferred("refresh_layout_after_frame")


func build_ui() -> void:
	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	add_child(background_layer)

	build_background()
	build_logo_layer()
	build_menu_panel()


func build_background() -> void:
	clear_children(background_layer)

	var title_ui: Dictionary = DataManager.get_title_screen_ui()
	var background_path: String = str(title_ui.get("background", "res://assets/backgrounds/title_luminaria_threshold.png"))
	var fallback_title: String = str(title_ui.get("fallback_title", "Luminaria: Crónicas del Velo"))
	var fallback_subtitle: String = str(title_ui.get("fallback_subtitle", "Fondo final: title_luminaria_threshold.png"))

	var background: Control = VisualAsset.make_texture_or_placeholder(
		background_path,
		fallback_title,
		fallback_subtitle
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_logo_layer() -> void:
	logo_layer = Control.new()
	logo_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(logo_layer)

	var title_ui: Dictionary = DataManager.get_title_screen_ui()
	var logo_path: String = str(title_ui.get("logo", "res://assets/ui/title_logo_luminaria_cronicas_del_velo.png"))

	var logo: Control = VisualAsset.make_texture_or_placeholder(
		logo_path,
		"Luminaria: Crónicas del Velo",
		"Logo final: %s" % logo_path.get_file()
	)

	logo.set_anchors_preset(Control.PRESET_FULL_RECT)
	logo.offset_left = 0
	logo.offset_top = 0
	logo.offset_right = 0
	logo.offset_bottom = 0
	logo_layer.add_child(logo)

	if logo is TextureRect:
		var logo_texture_rect: TextureRect = logo as TextureRect
		logo_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func build_menu_panel() -> void:
	menu_panel = PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(360, 270)
	add_child(menu_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	menu_panel.add_child(margin)

	var menu_container: VBoxContainer = VBoxContainer.new()
	menu_container.alignment = BoxContainer.ALIGNMENT_CENTER
	menu_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_container.add_theme_constant_override("separation", 10)
	margin.add_child(menu_container)

	var new_game_button: Button = make_menu_button("Nuevo juego")
	new_game_button.pressed.connect(_on_new_game_pressed)
	menu_container.add_child(new_game_button)

	continue_button = make_menu_button("Continuar último autosave")
	continue_button.pressed.connect(_on_continue_pressed)
	menu_container.add_child(continue_button)

	load_manual_button = make_menu_button("Cargar guardado manual")
	load_manual_button.pressed.connect(_on_load_manual_pressed)
	menu_container.add_child(load_manual_button)

	var quit_button: Button = make_menu_button("Salir")
	quit_button.pressed.connect(_on_quit_pressed)
	menu_container.add_child(quit_button)


func make_menu_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(1, 44)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


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


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func layout_overlay_controls() -> void:
	var margin: float = 28.0

	var logo_width: float = min(780.0, max(420.0, size.x * 0.52))
	var logo_height: float = min(260.0, max(150.0, size.y * 0.24))

	if size.x < 800:
		logo_width = min(size.x - (margin * 2.0), 520.0)
		logo_height = 160.0

	logo_layer.size = Vector2(logo_width, logo_height)
	logo_layer.position = Vector2(
		margin,
		max(margin, size.y * 0.12)
	)

	var menu_size: Vector2 = Vector2(380.0, 270.0)

	if size.x < 800:
		menu_size = Vector2(340.0, 270.0)

	menu_panel.size = menu_size
	menu_panel.position = Vector2(
		max(margin, size.x - menu_size.x - margin),
		max(margin, size.y - menu_size.y - margin)
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("refresh_layout_after_frame")


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
