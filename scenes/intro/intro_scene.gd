extends Control

var text_label: Label
var option_container: VBoxContainer
var selected_class_id: String = ""
var selected_gender_identity: String = "man"

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

	var text_scroll: ScrollContainer = ScrollContainer.new()
	text_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	text_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	left_panel.add_child(text_scroll)

	text_label = UIFactory.body()
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_scroll.add_child(text_label)

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
	show_gender_options()

func show_gender_options() -> void:
	text_label.text = "Antes de cruzar del todo el umbral, el mundo intenta entender cómo nombrarte.\n\nEsta elección afecta algunas primeras impresiones románticas, pero no encierra tu historia. En Luminaria, los vínculos pesan más que las etiquetas."

	clear_options()

	add_gender_option("Hombre", "man")
	add_gender_option("Mujer", "woman")
	add_gender_option("No binario", "non_binary")

	var back_button: Button = UIFactory.button("Volver a clase")
	back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button.pressed.connect(func(): select_class(selected_class_id))
	option_container.add_child(back_button)


func add_gender_option(label: String, gender_identity: String) -> void:
	var gender_button: Button = UIFactory.button(label)
	gender_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gender_button.pressed.connect(func(): select_gender_identity(gender_identity))
	option_container.add_child(gender_button)


func select_gender_identity(gender_identity: String) -> void:
	selected_gender_identity = gender_identity

	var label: String = ""

	match gender_identity:
		"man":
			label = "Hombre"
		"woman":
			label = "Mujer"
		"non_binary":
			label = "No binario"
		_:
			label = "Hombre"

	text_label.text = "El mundo recordará tu identidad como: %s.\n\nNo será una jaula. Será solo una de las muchas formas en que algunas personas intentarán entenderte antes de conocerte de verdad.\n\n¿Comenzar esta vida?" % label

	clear_options()

	var start_button: Button = UIFactory.button("Comenzar")
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.pressed.connect(start_game)
	option_container.add_child(start_button)

	var back_button: Button = UIFactory.button("Elegir otra identidad")
	back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_button.pressed.connect(show_gender_options)
	option_container.add_child(back_button)


func start_game() -> void:
	GameManager.start_new_game("Forastero", selected_class_id, selected_gender_identity)
	SaveManager.autosave_game()
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
