extends Control

var header_label: Label
var status_label: Label
var location_container: VBoxContainer
var info_label: Label

func _ready() -> void:
	build_ui()
	refresh_screen()
	show_pending_narrative_messages()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	header_label = UIFactory.title("")
	root.add_child(header_label)

	status_label = UIFactory.body("")
	root.add_child(status_label)

	info_label = UIFactory.body("Selecciona una ubicación.")
	root.add_child(info_label)

	location_container = VBoxContainer.new()
	location_container.alignment = BoxContainer.ALIGNMENT_CENTER
	location_container.add_theme_constant_override("separation", 10)
	root.add_child(location_container)

	var save_button: Button = UIFactory.button("Guardar partida")
	save_button.pressed.connect(_on_save_pressed)
	root.add_child(save_button)

	var journal_button: Button = UIFactory.button("Bitácora")
	journal_button.pressed.connect(func(): SceneRouter.go_to_journal())
	root.add_child(journal_button)

	var menu_button: Button = UIFactory.button("Volver al menú")
	menu_button.pressed.connect(_on_menu_pressed)
	root.add_child(menu_button)

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
		button.pressed.connect(func(): visit_location(location_id))
		location_container.add_child(button)

func visit_location(location_id: String) -> void:
	GameManager.current_location_id = location_id
	SceneRouter.go_to_location()

func _on_save_pressed() -> void:
	SaveManager.save_game()
	info_label.text = "Partida guardada."

func _on_menu_pressed() -> void:
	SceneRouter.go_to_main_menu()

func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		var entry: Dictionary = message
		combined_text += "%s\n\n%s\n\n" % [
			entry.get("name", "Hito narrativo"),
			entry.get("text", "")
		]

	info_label.text = combined_text.strip_edges()
	SaveManager.save_game()
