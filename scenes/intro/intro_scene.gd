extends Control

var text_label: Label
var option_container: VBoxContainer
var selected_class_id: String = ""

func _ready() -> void:
	build_ui()
	show_intro_text()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	root.add_child(UIFactory.title("El umbral"))

	text_label = UIFactory.body()
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	root.add_child(text_label)

	var class_label: Label = UIFactory.body("Elige tu camino")
	root.add_child(class_label)

	option_container = VBoxContainer.new()
	option_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_container.alignment = BoxContainer.ALIGNMENT_CENTER
	option_container.add_theme_constant_override("separation", 12)
	root.add_child(option_container)

func show_intro_text() -> void:
	text_label.text = "No recuerdas el momento exacto en que cruzaste el umbral.\n\nSolo recuerdas una luz imposible, una voz cálida pronunciando tu nombre y el peso de una nueva vida esperándote al otro lado.\n\nLa aldea te observa con curiosidad. Algunos con cautela. Otros con una intensidad que todavía no sabes interpretar.\n\nAntes de dar tu primer paso, algo dentro de ti despierta."

	show_class_options()

func show_class_options() -> void:
	clear_options()

	for class_id in DataManager.player_classes.keys():
		var class_data: Dictionary = DataManager.get_player_class(class_id)
		var button: Button = UIFactory.button(class_data.get("name", class_id))
		button.pressed.connect(func(): select_class(class_id))
		option_container.add_child(button)

func select_class(class_id: String) -> void:
	selected_class_id = class_id
	var class_data: Dictionary = DataManager.get_player_class(class_id)

	text_label.text = class_data.get("name", "") + "\n\n" + class_data.get("description", "") + "\n\n¿Este será el impulso que guiará tu nueva vida?"

	clear_options()

	var confirm_button: Button = UIFactory.button("Confirmar clase")
	confirm_button.pressed.connect(confirm_class)
	option_container.add_child(confirm_button)

	var back_button: Button = UIFactory.button("Elegir otra clase")
	back_button.pressed.connect(show_intro_text)
	option_container.add_child(back_button)

func confirm_class() -> void:
	GameManager.start_new_game("Forastero", selected_class_id)
	SaveManager.save_game()
	SceneRouter.go_to_world_map()

func clear_options() -> void:
	for child in option_container.get_children():
		child.queue_free()
