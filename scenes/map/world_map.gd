extends Control

var header_label: Label
var status_label: Label
var location_container: VBoxContainer
var info_label: Label

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_screen()
	show_pending_narrative_messages()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	header_label = UIFactory.title("")
	root.add_child(header_label)

	status_label = UIFactory.body("")
	root.add_child(status_label)

	var main: HBoxContainer = HBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 20)
	root.add_child(main)

	var left_panel: VBoxContainer = VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(left_panel)

	var location_label: Label = UIFactory.body("Ubicaciones")
	left_panel.add_child(location_label)

	var location_scroll: ScrollContainer = ScrollContainer.new()
	location_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	location_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	location_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	left_panel.add_child(location_scroll)

	location_container = VBoxContainer.new()
	location_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_container.add_theme_constant_override("separation", 8)
	location_scroll.add_child(location_container)

	var right_panel: VBoxContainer = VBoxContainer.new()
	right_panel.custom_minimum_size = Vector2(340, 1)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_constant_override("separation", 10)
	main.add_child(right_panel)

	info_label = UIFactory.body("Selecciona una ubicación.")
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	info_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(info_label)

	var journal_button: Button = UIFactory.button("Bitácora")
	journal_button.pressed.connect(func(): SceneRouter.go_to_journal())
	right_panel.add_child(journal_button)

	var menu_button: Button = UIFactory.button("Volver al menú")
	menu_button.pressed.connect(_on_menu_pressed)
	right_panel.add_child(menu_button)

func refresh_screen() -> void:
	header_label.text = "Mes %s · Día %s · %s · %s" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		GameManager.get_time_label()
	]

	status_label.text = "Resistencia: %s/%s   |   Dinero: %s   |   Acciones restantes: %s" % [
		GameManager.player.get("stamina", 0),
		GameManager.player.get("max_stamina", 0),
		GameManager.player.get("money", 0),
		GameManager.get_actions_remaining()
	]

	for child in location_container.get_children():
		child.queue_free()

	for location_id in DataManager.locations.keys():
		var location_data: Dictionary = DataManager.get_location(location_id)
		var button: Button = UIFactory.button(location_data.get("name", location_id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): visit_location(location_id))
		location_container.add_child(button)

func visit_location(location_id: String) -> void:
	GameManager.current_location_id = location_id

	if location_id == "home":
		SceneRouter.go_to_home()
		return

	SceneRouter.go_to_location()

func _on_menu_pressed() -> void:
	SceneRouter.go_to_main_menu()

func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	info_label.text = combined_text.strip_edges()
	SaveManager.autosave_game()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return "El Velo se agita\n\n%s" % str(message)

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
