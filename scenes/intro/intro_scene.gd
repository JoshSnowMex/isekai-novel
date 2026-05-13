extends Control


enum IntroStep {
	PROLOGUE,
	APPEARANCE,
	CLASS,
	CONFIRM
}


var background_layer: Control

var top_panel: PanelContainer
var top_label: Label

var hero_panel: PanelContainer
var hero_holder: Control
var hero_caption_label: Label

var bottom_panel: PanelContainer
var bottom_title_label: Label
var bottom_text_label: Label
var bottom_content: VBoxContainer
var bottom_buttons: HBoxContainer

var selected_class_id: String = ""
var selected_appearance_id: String = "man"
var current_step: IntroStep = IntroStep.PROLOGUE
var prologue_index: int = 0

var prologue_pages: Array = [
	"No recuerdas el final de tu vida anterior.\n\nSolo el sonido de una página rasgándose… y una luz imposible abriéndose bajo tus pies.",
	"Al despertar, Luminaria ya conoce tu nombre.\n\nO quizá solo finge conocerlo. En este mundo, incluso la memoria puede mentir.",
	"El Velo te ha traído aquí por una razón.\n\nNadie está de acuerdo sobre cuál. Algunos rezan por ti. Otros te temen. Otros esperan que falles.",
	"Antes de cruzar del todo el umbral, debes decidir qué forma tomó el Forastero… y qué impulso lo empujará a sobrevivir."
]


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	show_prologue()
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
	build_top_panel()
	build_hero_panel()
	build_bottom_panel()


func build_background() -> void:
	clear_children(background_layer)

	var background: Control = VisualAsset.make_texture_or_placeholder(
		"res://assets/backgrounds/intro_veil_crossing.png",
		"El umbral",
		"Fondo final: intro_veil_crossing.png"
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_top_panel() -> void:
	top_panel = PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(720, 46)
	add_child(top_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 6)
	top_panel.add_child(margin)

	top_label = Label.new()
	top_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_label.clip_text = true
	margin.add_child(top_label)


func build_hero_panel() -> void:
	hero_panel = PanelContainer.new()
	hero_panel.custom_minimum_size = Vector2(520, 280)
	add_child(hero_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	hero_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	hero_holder = Control.new()
	hero_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(hero_holder)

	hero_caption_label = Label.new()
	hero_caption_label.custom_minimum_size = Vector2(1, 42)
	hero_caption_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_caption_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hero_caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hero_caption_label)


func build_bottom_panel() -> void:
	bottom_panel = PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(920, 250)
	add_child(bottom_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	bottom_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	bottom_title_label = Label.new()
	bottom_title_label.custom_minimum_size = Vector2(1, 28)
	bottom_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottom_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(bottom_title_label)

	bottom_text_label = Label.new()
	bottom_text_label.custom_minimum_size = Vector2(1, 54)
	bottom_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottom_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	bottom_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(bottom_text_label)

	bottom_content = VBoxContainer.new()
	bottom_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_content.add_theme_constant_override("separation", 8)
	box.add_child(bottom_content)

	bottom_buttons = HBoxContainer.new()
	bottom_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_buttons.custom_minimum_size = Vector2(1, 44)
	bottom_buttons.add_theme_constant_override("separation", 10)
	box.add_child(bottom_buttons)


func show_prologue() -> void:
	current_step = IntroStep.PROLOGUE

	top_label.text = "Nuevo juego · Prólogo"
	bottom_title_label.text = "El umbral"
	bottom_text_label.text = str(prologue_pages[prologue_index])

	clear_children(bottom_content)
	clear_children(bottom_buttons)

	set_hero_placeholder(
		"res://assets/backgrounds/intro_veil_crossing.png",
		"El umbral",
		"Arte de prólogo: intro_veil_crossing.png"
	)

	if prologue_index > 0:
		add_footer_button("Anterior", func():
			prologue_index = max(0, prologue_index - 1)
			show_prologue()
		)

	if prologue_index < prologue_pages.size() - 1:
		add_footer_button("Continuar", func():
			prologue_index += 1
			show_prologue()
		)
	else:
		add_footer_button("Elegir apariencia", func():
			show_appearance_selection()
		)

	add_footer_button("Saltar prólogo", func():
		show_appearance_selection()
	)

	call_deferred("refresh_layout_after_frame")


func show_appearance_selection() -> void:
	current_step = IntroStep.APPEARANCE

	top_label.text = "Nuevo juego · Apariencia"
	bottom_title_label.text = "Elige tu forma"
	bottom_text_label.text = "El Velo te da una presencia. Luminaria reaccionará a ella antes de conocerte de verdad."

	clear_children(bottom_content)
	clear_children(bottom_buttons)

	set_hero_placeholder(
		get_appearance_asset_path(selected_appearance_id),
		get_appearance_label(selected_appearance_id),
		"Arte de apariencia: %s" % get_appearance_asset_name(selected_appearance_id)
	)

	var grid: GridContainer = create_grid(3)
	bottom_content.add_child(grid)

	add_appearance_card(grid, "Forastero", "man", "Rostro masculino")
	add_appearance_card(grid, "Forastera", "woman", "Rostro femenino")
	add_appearance_card(grid, "Forma velada", "veiled", "Presencia tocada por el Velo")

	add_footer_button("Volver", func():
		prologue_index = prologue_pages.size() - 1
		show_prologue()
	)

	call_deferred("refresh_layout_after_frame")


func add_appearance_card(parent: Node, title: String, appearance_id: String, description: String) -> void:
	var locked_appearance_id: String = appearance_id

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(220, 82)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text = "%s\n%s" % [title, description]

	button.mouse_entered.connect(func():
		selected_appearance_id = locked_appearance_id
		set_hero_placeholder(
			get_appearance_asset_path(locked_appearance_id),
			get_appearance_label(locked_appearance_id),
			"Arte de apariencia: %s" % get_appearance_asset_name(locked_appearance_id)
		)
	)
	button.focus_entered.connect(func():
		selected_appearance_id = locked_appearance_id
		set_hero_placeholder(
			get_appearance_asset_path(locked_appearance_id),
			get_appearance_label(locked_appearance_id),
			"Arte de apariencia: %s" % get_appearance_asset_name(locked_appearance_id)
		)
	)

	button.pressed.connect(func():
		selected_appearance_id = locked_appearance_id
		show_class_selection()
	)

	parent.add_child(button)


func show_class_selection() -> void:
	current_step = IntroStep.CLASS

	top_label.text = "Nuevo juego · Camino del Forastero"
	bottom_title_label.text = "Elige tu camino"
	bottom_text_label.text = "Cada camino favorece ciertos vínculos y complica otros. Elige una tendencia, no una hoja de números."

	clear_children(bottom_content)
	clear_children(bottom_buttons)

	if selected_class_id == "":
		selected_class_id = "balanced_outsider"

	set_hero_placeholder(
		get_class_asset_path(selected_class_id),
		DataManager.get_player_class(selected_class_id).get("name", selected_class_id),
		get_class_asset_caption(selected_class_id)
	)

	var grid: GridContainer = create_grid(3)
	bottom_content.add_child(grid)

	for class_id in DataManager.player_classes.keys():
		add_class_card(grid, str(class_id))

	add_footer_button("Volver a apariencia", func():
		show_appearance_selection()
	)

	call_deferred("refresh_layout_after_frame")


func add_class_card(parent: Node, class_id: String) -> void:
	var locked_class_id: String = class_id
	var class_data: Dictionary = DataManager.get_player_class(class_id)

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(230, 92)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text = build_class_card_text(class_id, class_data)

	button.mouse_entered.connect(func():
		selected_class_id = locked_class_id
		set_hero_placeholder(
			get_class_asset_path(locked_class_id),
			class_data.get("name", locked_class_id),
			get_class_asset_caption(locked_class_id)
		)
		bottom_text_label.text = build_class_hover_summary(class_data)
	)
	button.focus_entered.connect(func():
		selected_class_id = locked_class_id
		set_hero_placeholder(
			get_class_asset_path(locked_class_id),
			class_data.get("name", locked_class_id),
			get_class_asset_caption(locked_class_id)
		)
		bottom_text_label.text = build_class_hover_summary(class_data)
	)

	button.pressed.connect(func():
		selected_class_id = locked_class_id
		show_confirm_selection()
	)

	parent.add_child(button)


func build_class_card_text(class_id: String, class_data: Dictionary) -> String:
	var strengths: Array = class_data.get("strengths", [])
	var weaknesses: Array = class_data.get("weaknesses", [])

	var strength_text: String = "Ventaja: flexible"
	var weakness_text: String = "Riesgo: sin extremos"

	if not strengths.is_empty():
		strength_text = "Ventaja: %s" % str(strengths[0])

	if not weaknesses.is_empty():
		weakness_text = "Riesgo: %s" % str(weaknesses[0])

	return "%s\n%s\n%s" % [
		class_data.get("name", class_id),
		strength_text,
		weakness_text
	]


func build_class_hover_summary(class_data: Dictionary) -> String:
	return "%s\n%s" % [
		class_data.get("description", ""),
		class_data.get("narrative_style", "")
	]


func show_confirm_selection() -> void:
	current_step = IntroStep.CONFIRM

	var class_data: Dictionary = DataManager.get_player_class(selected_class_id)
	var appearance_label: String = get_appearance_label(selected_appearance_id)

	top_label.text = "Nuevo juego · Confirmar Forastero"
	bottom_title_label.text = "Confirmar inicio"
	bottom_text_label.text = "Apariencia: %s · Camino: %s · Elemento: %s\n%s" % [
		appearance_label,
		class_data.get("name", selected_class_id),
		class_data.get("element", ""),
		class_data.get("narrative_style", "")
	]

	clear_children(bottom_content)
	clear_children(bottom_buttons)

	set_hero_placeholder(
		get_class_asset_path(selected_class_id),
		class_data.get("name", selected_class_id),
		get_class_asset_caption(selected_class_id)
	)

	add_footer_button("Comenzar historia", func():
		start_game()
	)

	add_footer_button("Cambiar camino", func():
		show_class_selection()
	)

	add_footer_button("Cambiar apariencia", func():
		show_appearance_selection()
	)

	call_deferred("refresh_layout_after_frame")


func set_hero_placeholder(path: String, title: String, caption: String) -> void:
	clear_children(hero_holder)

	var visual: Control = VisualAsset.make_texture_or_placeholder(
		path,
		title,
		caption
	)

	visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	visual.offset_left = 0
	visual.offset_top = 0
	visual.offset_right = 0
	visual.offset_bottom = 0
	hero_holder.add_child(visual)

	hero_caption_label.text = caption


func get_appearance_label(appearance_id: String) -> String:
	match appearance_id:
		"man":
			return "Forastero"
		"woman":
			return "Forastera"
		"veiled":
			return "Forma velada"
		_:
			return "Forastero"


func get_appearance_asset_name(appearance_id: String) -> String:
	match appearance_id:
		"man":
			return "outsider_male_base.png"
		"woman":
			return "outsider_female_base.png"
		"veiled":
			return "outsider_veiled_base.png"
		_:
			return "outsider_male_base.png"


func get_appearance_asset_path(appearance_id: String) -> String:
	return "res://assets/player/%s" % get_appearance_asset_name(appearance_id)


func get_class_asset_path(class_id: String) -> String:
	return "res://assets/player/%s" % get_class_asset_name(class_id)


func get_class_asset_name(class_id: String) -> String:
	var appearance_asset_id: String = selected_appearance_id

	if appearance_asset_id == "woman":
		appearance_asset_id = "female"
	elif appearance_asset_id == "veiled":
		appearance_asset_id = "veiled"
	else:
		appearance_asset_id = "male"

	var normalized_class_id: String = class_id.replace("_outsider", "")

	return "outsider_%s_%s.png" % [
		appearance_asset_id,
		normalized_class_id
	]


func get_class_asset_caption(class_id: String) -> String:
	return "Arte final: %s" % get_class_asset_name(class_id)


func start_game() -> void:
	var gender_identity: String = selected_appearance_id

	if gender_identity == "veiled":
		gender_identity = "non_binary"

	GameManager.start_new_game("Forastero", selected_class_id, gender_identity)
	SaveManager.autosave_game()
	SceneRouter.go_to_world_map()


func create_grid(columns: int) -> GridContainer:
	var grid: GridContainer = GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	return grid


func add_footer_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(180, 40)
	button.pressed.connect(callback)
	bottom_buttons.add_child(button)
	return button


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func layout_overlay_controls() -> void:
	var margin: float = 10.0
	var top_height: float = 46.0
	var bottom_height: float = 286.0

	if current_step == IntroStep.PROLOGUE:
		bottom_height = 240.0
	elif current_step == IntroStep.CLASS:
		bottom_height = 318.0
	elif current_step == IntroStep.CONFIRM:
		bottom_height = 220.0

	top_panel.size = Vector2(
		min(920.0, max(520.0, size.x - (margin * 2.0))),
		top_height
	)
	top_panel.position = Vector2(
		(size.x - top_panel.size.x) / 2.0,
		margin
	)

	bottom_panel.size = Vector2(
		min(1040.0, max(640.0, size.x - (margin * 2.0))),
		bottom_height
	)
	bottom_panel.position = Vector2(
		(size.x - bottom_panel.size.x) / 2.0,
		max(margin, size.y - bottom_height - margin)
	)

	var hero_top: float = top_panel.position.y + top_height + margin
	var hero_bottom: float = bottom_panel.position.y - margin
	var hero_height: float = max(180.0, hero_bottom - hero_top)

	hero_panel.size = Vector2(
		min(620.0, max(420.0, size.x * 0.48)),
		hero_height
	)
	hero_panel.position = Vector2(
		(size.x - hero_panel.size.x) / 2.0,
		hero_top
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("refresh_layout_after_frame")


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
