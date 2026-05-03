extends Control

var text_label: Label
var option_container: VBoxContainer
var selected_class_id: String = ""

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	show_intro_text()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	root.add_child(UIFactory.title("El umbral"))

	var main: HBoxContainer = HBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 24)
	root.add_child(main)

	var left_panel: VBoxContainer = VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(left_panel)

	text_label = UIFactory.body()
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_child(text_label)

	var right_panel: VBoxContainer = VBoxContainer.new()
	right_panel.custom_minimum_size = Vector2(360, 1)
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_constant_override("separation", 10)
	main.add_child(right_panel)

	var class_label: Label = UIFactory.body("Elige tu camino")
	right_panel.add_child(class_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	right_panel.add_child(scroll)

	option_container = VBoxContainer.new()
	option_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_container.add_theme_constant_override("separation", 10)
	scroll.add_child(option_container)

func show_intro_text() -> void:
	text_label.text = "No recuerdas el momento exacto en que cruzaste el umbral.\n\nSolo recuerdas una luz imposible, una voz cálida pronunciando tu nombre y el peso de una nueva vida esperándote al otro lado.\n\nLa aldea te observa con curiosidad. Algunos con cautela. Otros con una intensidad que todavía no sabes interpretar.\n\nAntes de dar tu primer paso, algo dentro de ti despierta."

	show_class_options()

func show_class_options() -> void:
	clear_options()

	for class_id in DataManager.player_classes.keys():
		var class_data: Dictionary = DataManager.get_player_class(class_id)
		var button: Button = UIFactory.button(class_data.get("name", class_id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): select_class(class_id))
		option_container.add_child(button)

func select_class(class_id: String) -> void:
	selected_class_id = class_id
	var class_data: Dictionary = DataManager.get_player_class(class_id)

	var text: String = ""
	text += class_data.get("name", "") + "\n\n"
	text += class_data.get("description", "") + "\n\n"
	text += "Estilo narrativo:\n"
	text += class_data.get("narrative_style", "") + "\n\n"

	text += "Fortalezas:\n"
	for item in class_data.get("strengths", []):
		text += "- %s\n" % item

	text += "\nDebilidades:\n"
	for item in class_data.get("weaknesses", []):
		text += "- %s\n" % item

	text += "\n¿Este será el impulso que guiará tu nueva vida?"

	text_label.text = text

	clear_options()

	var confirm_button: Button = UIFactory.button("Confirmar clase")
	confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	confirm_button.pressed.connect(confirm_class)
	option_container.add_child(confirm_button)

	var back_button: Button = UIFactory.button("Elegir otra clase")
	back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button.pressed.connect(show_intro_text)
	option_container.add_child(back_button)

func confirm_class() -> void:
	GameManager.start_new_game("Forastero", selected_class_id)
	SaveManager.save_game()
	SceneRouter.go_to_world_map()

func clear_options() -> void:
	for child in option_container.get_children():
		child.queue_free()

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
