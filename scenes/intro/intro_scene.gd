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

var narrative_panel: PanelContainer
var narrative_label: Label

var content_panel: PanelContainer
var content_title_label: Label
var content_subtitle_label: Label
var content_container: VBoxContainer

var footer_panel: PanelContainer
var footer_buttons: HBoxContainer

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
	build_narrative_panel()
	build_content_panel()
	build_footer_panel()


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


func build_narrative_panel() -> void:
	narrative_panel = PanelContainer.new()
	narrative_panel.custom_minimum_size = Vector2(760, 160)
	add_child(narrative_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	narrative_panel.add_child(margin)

	narrative_label = Label.new()
	narrative_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	narrative_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	narrative_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	narrative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	narrative_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	margin.add_child(narrative_label)


func build_content_panel() -> void:
	content_panel = PanelContainer.new()
	content_panel.custom_minimum_size = Vector2(900, 360)
	add_child(content_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	content_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	content_title_label = Label.new()
	content_title_label.custom_minimum_size = Vector2(1, 30)
	content_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(content_title_label)

	content_subtitle_label = Label.new()
	content_subtitle_label.custom_minimum_size = Vector2(1, 42)
	content_subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	content_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	content_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(content_subtitle_label)

	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 10)
	box.add_child(content_container)


func build_footer_panel() -> void:
	footer_panel = PanelContainer.new()
	footer_panel.custom_minimum_size = Vector2(520, 58)
	add_child(footer_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	footer_panel.add_child(margin)

	footer_buttons = HBoxContainer.new()
	footer_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	footer_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_buttons.size_flags_vertical = Control.SIZE_EXPAND_FILL
	footer_buttons.add_theme_constant_override("separation", 10)
	margin.add_child(footer_buttons)


func show_prologue() -> void:
	current_step = IntroStep.PROLOGUE
	content_panel.visible = false

	top_label.text = "Nuevo juego · Prólogo"
	narrative_label.text = str(prologue_pages[prologue_index])

	clear_children(footer_buttons)

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
	content_panel.visible = true

	top_label.text = "Nuevo juego · Apariencia"
	narrative_label.text = "El Velo no solo arrastra almas: también les da forma.\n\nElige cómo aparece el Forastero al cruzar hacia Luminaria."

	content_title_label.text = "Apariencia del Forastero"
	content_subtitle_label.text = "Esta elección prepara retratos y presencia visual. La historia seguirá dependiendo de tus decisiones."

	clear_children(content_container)
	clear_children(footer_buttons)

	var grid: GridContainer = create_grid(3)
	content_container.add_child(grid)

	add_appearance_card(grid, "Forastero", "man", "Rostro masculino", "outsider_man.png")
	add_appearance_card(grid, "Forastera", "woman", "Rostro femenino", "outsider_woman.png")
	add_appearance_card(grid, "Forma velada", "veiled", "Presencia ambigua del Velo", "outsider_veiled.png")

	add_footer_button("Volver al prólogo", func():
		prologue_index = prologue_pages.size() - 1
		show_prologue()
	)

	call_deferred("refresh_layout_after_frame")


func add_appearance_card(parent: Node, title: String, appearance_id: String, description: String, asset_name: String) -> void:
	var locked_appearance_id: String = appearance_id

	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(240, 150)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text = "%s\n\n%s\n\nArte final: %s" % [
		title,
		description,
		asset_name
	]
	button.pressed.connect(func():
		selected_appearance_id = locked_appearance_id
		show_class_selection()
	)
	button.mouse_entered.connect(func():
		narrative_label.text = "El Velo adopta esta presencia para que Luminaria pueda mirarte… aunque todavía no sepa entenderte."
	)
	button.focus_entered.connect(func():
		narrative_label.text = "El Velo adopta esta presencia para que Luminaria pueda mirarte… aunque todavía no sepa entenderte."
	)

	parent.add_child(button)


func show_class_selection() -> void:
	current_step = IntroStep.CLASS
	content_panel.visible = true

	top_label.text = "Nuevo juego · Camino del Forastero"
	narrative_label.text = "La apariencia abre la puerta.\n\nEl camino decide qué tipo de presión llevarás dentro cuando el mundo empiece a pedirte respuestas."

	content_title_label.text = "Elige tu camino"
	content_subtitle_label.text = "Cada camino favorece ciertas rutas y complica otras. No son números: son tendencias narrativas."

	clear_children(content_container)
	clear_children(footer_buttons)

	var grid: GridContainer = create_grid(3)
	content_container.add_child(grid)

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
	button.custom_minimum_size = Vector2(250, 150)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text = build_class_front_text(class_id, class_data)

	button.mouse_entered.connect(func():
		button.text = build_class_back_text(class_data)
		show_class_hover_text(class_id)
	)
	button.focus_entered.connect(func():
		button.text = build_class_back_text(class_data)
		show_class_hover_text(class_id)
	)
	button.mouse_exited.connect(func():
		button.text = build_class_front_text(class_id, class_data)
	)

	button.pressed.connect(func():
		selected_class_id = locked_class_id
		show_confirm_selection()
	)

	parent.add_child(button)


func build_class_front_text(class_id: String, class_data: Dictionary) -> String:
	return "%s\n%s\n\n%s" % [
		class_data.get("name", class_id),
		class_data.get("element", ""),
		get_class_asset_hint(class_id)
	]


func build_class_back_text(class_data: Dictionary) -> String:
	var strengths: Array = class_data.get("strengths", [])
	var weaknesses: Array = class_data.get("weaknesses", [])

	var strength_text: String = "Ventaja: define mejor sus vínculos."
	var weakness_text: String = "Riesgo: carga una tensión propia."

	if not strengths.is_empty():
		strength_text = "Ventaja: %s" % str(strengths[0])

	if not weaknesses.is_empty():
		weakness_text = "Riesgo: %s" % str(weaknesses[0])

	return "%s\n\n%s\n\n%s" % [
		class_data.get("name", ""),
		strength_text,
		weakness_text
	]


func show_class_hover_text(class_id: String) -> void:
	var class_data: Dictionary = DataManager.get_player_class(class_id)

	narrative_label.text = "%s\n\n%s" % [
		class_data.get("description", ""),
		class_data.get("narrative_style", "")
	]


func get_class_asset_hint(class_id: String) -> String:
	var appearance_asset_id: String = selected_appearance_id

	if appearance_asset_id == "veiled":
		appearance_asset_id = "veiled"
	elif appearance_asset_id == "woman":
		appearance_asset_id = "female"
	else:
		appearance_asset_id = "male"

	var normalized_class_id: String = class_id
	normalized_class_id = normalized_class_id.replace("_outsider", "")
	normalized_class_id = normalized_class_id.replace("sensitive", "sensitive")
	normalized_class_id = normalized_class_id.replace("bold", "bold")
	normalized_class_id = normalized_class_id.replace("scholar", "scholar")
	normalized_class_id = normalized_class_id.replace("charming", "charming")
	normalized_class_id = normalized_class_id.replace("steadfast", "steadfast")
	normalized_class_id = normalized_class_id.replace("balanced", "balanced")

	return "Arte final:\noutsider_%s_%s.png" % [
		appearance_asset_id,
		normalized_class_id
	]


func show_confirm_selection() -> void:
	current_step = IntroStep.CONFIRM
	content_panel.visible = true

	var class_data: Dictionary = DataManager.get_player_class(selected_class_id)
	var appearance_label: String = get_appearance_label(selected_appearance_id)

	top_label.text = "Nuevo juego · Confirmar Forastero"
	narrative_label.text = "El Velo se aquieta.\n\nEsta será la forma que Luminaria verá al abrir los ojos."

	content_title_label.text = "Confirmar inicio"
	content_subtitle_label.text = "Revisa tu elección antes de comenzar la partida."

	clear_children(content_container)
	clear_children(footer_buttons)

	var summary_panel: PanelContainer = PanelContainer.new()
	summary_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.add_child(summary_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	summary_panel.add_child(margin)

	var label: Label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.text = "%s\n\nApariencia: %s\nCamino: %s\nElemento: %s\n\n%s\n\n%s" % [
		get_class_asset_hint(selected_class_id),
		appearance_label,
		class_data.get("name", selected_class_id),
		class_data.get("element", ""),
		class_data.get("description", ""),
		class_data.get("narrative_style", "")
	]
	margin.add_child(label)

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
	button.custom_minimum_size = Vector2(180, 42)
	button.pressed.connect(callback)
	footer_buttons.add_child(button)
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
	var footer_height: float = 58.0
	var gap: float = 10.0

	top_panel.size = Vector2(
		min(920.0, max(520.0, size.x - (margin * 2.0))),
		top_height
	)
	top_panel.position = Vector2(
		(size.x - top_panel.size.x) / 2.0,
		margin
	)

	footer_panel.size = Vector2(
		min(820.0, max(520.0, size.x * 0.72)),
		footer_height
	)
	footer_panel.position = Vector2(
		(size.x - footer_panel.size.x) / 2.0,
		max(margin, size.y - footer_height - margin)
	)

	var narrative_height: float = 170.0

	if current_step == IntroStep.PROLOGUE:
		narrative_height = min(320.0, max(220.0, size.y * 0.38))

	narrative_panel.size = Vector2(
		min(920.0, max(520.0, size.x - (margin * 2.0))),
		narrative_height
	)
	narrative_panel.position = Vector2(
		(size.x - narrative_panel.size.x) / 2.0,
		top_panel.position.y + top_height + gap
	)

	if content_panel.visible:
		var content_top: float = narrative_panel.position.y + narrative_panel.size.y + gap
		var content_bottom: float = footer_panel.position.y - gap
		var content_height: float = max(260.0, content_bottom - content_top)

		content_panel.size = Vector2(
			min(980.0, max(620.0, size.x - (margin * 2.0))),
			content_height
		)
		content_panel.position = Vector2(
			(size.x - content_panel.size.x) / 2.0,
			content_top
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
