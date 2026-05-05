extends Control

var title_label: Label
var status_label: Label
var description_label: Label
var action_container: VBoxContainer


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_screen()


func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	var back_button: Button = UIFactory.button("← Volver al mapa")
	back_button.pressed.connect(_on_back_pressed)
	root.add_child(back_button)

	title_label = UIFactory.title("Casa del Forastero")
	root.add_child(title_label)

	status_label = UIFactory.body("")
	root.add_child(status_label)

	description_label = UIFactory.body("")
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	root.add_child(description_label)

	action_container = VBoxContainer.new()
	action_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_theme_constant_override("separation", 10)
	root.add_child(action_container)

	build_actions()


func refresh_screen(message: String = "") -> void:
	status_label.text = "Mes %s · Día %s · %s · %s\nResistencia: %s/%s · Dinero: %s · Acciones restantes: %s" % [
		GameManager.current_month,
		GameManager.current_day,
		GameManager.get_weekday_name(),
		GameManager.get_time_label(),
		GameManager.player.get("stamina", 0),
		GameManager.player.get("max_stamina", 0),
		GameManager.player.get("money", 0),
		GameManager.get_actions_remaining()
	]

	if message != "":
		description_label.text = message
	else:
		description_label.text = "Una pequeña casa cedida al recién llegado. Aquí puedes recuperar fuerzas, ordenar tus decisiones y cerrar el día cuando estés listo."


func build_actions() -> void:
	clear_container(action_container)

	var rest_button: Button = UIFactory.button("Descansar")
	rest_button.disabled = GameManager.is_day_exhausted()
	rest_button.pressed.connect(_on_rest_pressed)
	action_container.add_child(rest_button)

	var sleep_button: Button = UIFactory.button("Dormir hasta mañana")
	sleep_button.pressed.connect(_on_sleep_pressed)
	action_container.add_child(sleep_button)

	var save_button: Button = UIFactory.button("Guardar partida")
	save_button.pressed.connect(_on_save_pressed)
	action_container.add_child(save_button)

	var map_button: Button = UIFactory.button("Volver al mapa")
	map_button.pressed.connect(_on_back_pressed)
	action_container.add_child(map_button)


func _on_rest_pressed() -> void:
	if not GameManager.can_perform_action(5):
		refresh_screen(GameManager.get_action_blocked_message(5))
		build_actions()
		return

	GameManager.player["stamina"] = min(
		int(GameManager.player.get("stamina", 0)) + 20,
		int(GameManager.player.get("max_stamina", 100))
	)

	GameManager.consume_action(5)
	SaveManager.autosave_game()

	refresh_screen("Descansas un momento.\nResistencia +20")
	build_actions()


func _on_sleep_pressed() -> void:
	GameManager.sleep_until_next_day()
	SaveManager.autosave_game()
	SceneRouter.go_to_world_map()


func _on_save_pressed() -> void:
	SaveManager.save_game()
	refresh_screen("Partida guardada manualmente en la Casa del Forastero.")
	build_actions()


func _on_back_pressed() -> void:
	SceneRouter.go_to_world_map()


func clear_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
