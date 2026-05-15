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

var card_area: Control
var card_grid: GridContainer

var bottom_panel: PanelContainer
var bottom_text_label: Label
var bottom_buttons: HBoxContainer

var previous_button: Button
var primary_button: Button
var tertiary_button: Button

var selected_class_id: String = ""
var selected_appearance_id: String = ""
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

	build_top_panel()
	build_card_area()
	build_bottom_panel()


func build_background(path: String, title: String, caption: String) -> void:
	clear_children(background_layer)

	var background: Control = VisualAsset.make_texture_or_placeholder(
		path,
		title,
		caption
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_top_panel() -> void:
	top_panel = PanelContainer.new()
	top_panel.custom_minimum_size = Vector2(1040, 46)
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
	top_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	top_label.clip_text = true
	LuminariaTheme.apply_label(top_label, 18, Color(0.96, 0.91, 0.82, 1.0), 2)
	margin.add_child(top_label)


func build_card_area() -> void:
	card_area = Control.new()
	card_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card_area)


func build_bottom_panel() -> void:
	bottom_panel = PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(1040, 136)
	add_child(bottom_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	bottom_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	bottom_text_label = Label.new()
	bottom_text_label.custom_minimum_size = Vector2(1, 74)
	bottom_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_text_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	bottom_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	bottom_text_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	bottom_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom_text_label.clip_text = true
	LuminariaTheme.apply_label(bottom_text_label, 17, Color(0.94, 0.91, 0.86, 1.0), 2)
	box.add_child(bottom_text_label)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	bottom_buttons = HBoxContainer.new()
	bottom_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_buttons.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_buttons.size_flags_vertical = Control.SIZE_SHRINK_END
	bottom_buttons.custom_minimum_size = Vector2(1, 42)
	bottom_buttons.add_theme_constant_override("separation", 10)
	box.add_child(bottom_buttons)


func show_prologue() -> void:
	current_step = IntroStep.PROLOGUE

	var intro_ui: Dictionary = DataManager.get_intro_ui()
	var background_path: String = str(intro_ui.get("prologue_background", "res://assets/backgrounds/intro_veil_crossing.png"))
	var fallback_title: String = str(intro_ui.get("fallback_prologue_title", "El umbral"))

	build_background(
		background_path,
		fallback_title,
		"Fondo final: %s" % background_path.get_file()
	)

	clear_card_area()

	top_label.text = "Nuevo juego · Prólogo · El umbral"
	bottom_text_label.text = str(prologue_pages[prologue_index])

	build_three_buttons(
		"Anterior",
		func():
			prologue_index = max(0, prologue_index - 1)
			show_prologue(),
		prologue_index > 0,
		get_prologue_primary_label(),
		func():
			if prologue_index < prologue_pages.size() - 1:
				prologue_index += 1
				show_prologue()
			else:
				show_appearance_selection(),
		true,
		"Saltar prólogo",
		func():
			show_appearance_selection(),
		true
	)

	call_deferred("refresh_layout_after_frame")


func get_prologue_primary_label() -> String:
	if prologue_index < prologue_pages.size() - 1:
		return "Continuar"

	return "Elegir apariencia"


func show_appearance_selection() -> void:
	current_step = IntroStep.APPEARANCE

	var intro_ui: Dictionary = DataManager.get_intro_ui()
	var background_path: String = str(intro_ui.get("appearance_background", "res://assets/backgrounds/intro_appearance_selection.png"))
	var fallback_title: String = str(intro_ui.get("fallback_appearance_title", "Elige tu forma"))

	build_background(
		background_path,
		fallback_title,
		"Fondo final: %s" % background_path.get_file()
	)

	top_label.text = "Nuevo juego · Apariencia · Elige tu forma"
	bottom_text_label.text = "Selecciona una forma para continuar."

	clear_card_area()
	card_grid = create_grid(3)
	card_area.add_child(card_grid)

	add_appearance_card(card_grid, "Forastero", "man", "Forma masculina")
	add_appearance_card(card_grid, "Forastera", "woman", "Forma femenina")
	add_appearance_card(card_grid, "Forma velada", "veiled", "Presencia tocada por el Velo")

	build_three_buttons(
		"Volver al prólogo",
		func():
			prologue_index = prologue_pages.size() - 1
			show_prologue(),
		true,
		"Continuar",
		func():
			show_class_selection(),
		selected_appearance_id != "",
		"Saltar prólogo",
		func():
			show_class_selection(),
		false
	)

	call_deferred("refresh_layout_after_frame")

func add_appearance_card(parent: Node, title: String, appearance_id: String, description: String) -> void:
	var locked_appearance_id: String = appearance_id
	var asset_path: String = get_player_asset_path(get_appearance_asset_name(locked_appearance_id))
	var is_selected: bool = selected_appearance_id == locked_appearance_id

	var card: Button = Button.new()
	card.focus_mode = Control.FOCUS_ALL
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(220, 390)
	card.text = ""
	card.clip_contents = false
	LuminariaTheme.apply_transparent_button(card)

	var root_box: VBoxContainer = VBoxContainer.new()
	root_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_box.alignment = BoxContainer.ALIGNMENT_CENTER
	root_box.add_theme_constant_override("separation", 6)
	card.add_child(root_box)

	var portal_stage: Control = Control.new()
	portal_stage.custom_minimum_size = Vector2(1, 330)
	portal_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portal_stage.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portal_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_box.add_child(portal_stage)	

	var frame: TextureRect = TextureRect.new()
	frame.texture = VisualAsset.load_texture(LuminariaTheme.SELECTION_FRAME_PATH)
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.offset_left = -4
	frame.offset_top = -4
	frame.offset_right = 4
	frame.offset_bottom = 4
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.modulate = get_selection_frame_color(is_selected)
	portal_stage.add_child(frame)

	var portrait: TextureRect = TextureRect.new()
	portrait.texture = load_player_texture(asset_path)
	portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 34
	portrait.offset_top = 68
	portrait.offset_right = -34
	portrait.offset_bottom = -34
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.modulate = get_selection_portrait_color(is_selected)
	portal_stage.add_child(portrait)

	var text_box: VBoxContainer = VBoxContainer.new()
	text_box.custom_minimum_size = Vector2(1, 58)
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.alignment = BoxContainer.ALIGNMENT_CENTER
	text_box.add_theme_constant_override("separation", 0)
	text_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_box.add_child(text_box)

	var title_label: Label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.clip_text = true
	title_label.text = build_appearance_title_text(title, locked_appearance_id)
	LuminariaTheme.apply_label(title_label, 17, Color(1.0, 0.92, 0.72, 1.0), 2)
	text_box.add_child(title_label)

	var description_label: Label = Label.new()
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.clip_text = true
	description_label.text = description
	LuminariaTheme.apply_label(description_label, 13, Color(0.88, 0.86, 0.92, 1.0), 2)
	text_box.add_child(description_label)

	card.mouse_entered.connect(func():
		bottom_text_label.text = "%s · %s" % [title, description]
	)
	card.focus_entered.connect(func():
		bottom_text_label.text = "%s · %s" % [title, description]
	)
	card.pressed.connect(func():
		selected_appearance_id = locked_appearance_id
		bottom_text_label.text = "%s seleccionado. Pulsa Continuar para elegir camino." % title
		show_appearance_selection()
	)

	parent.add_child(card)
		
func build_appearance_title_text(title: String, appearance_id: String) -> String:
	if selected_appearance_id == appearance_id:
		return "✓ %s" % title

	return title


func get_player_asset_path(asset_name: String) -> String:
	var intro_ui: Dictionary = DataManager.get_intro_ui()
	var player_asset_folder: String = str(intro_ui.get("player_asset_folder", "res://assets/player/"))

	if not player_asset_folder.ends_with("/"):
		player_asset_folder += "/"

	return "%s%s" % [player_asset_folder, asset_name]


func load_player_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)

	return null

func show_class_selection() -> void:
	current_step = IntroStep.CLASS

	var intro_ui: Dictionary = DataManager.get_intro_ui()
	var background_path: String = str(intro_ui.get("class_background", "res://assets/backgrounds/intro_class_selection.png"))
	var fallback_title: String = str(intro_ui.get("fallback_class_title", "Elige tu camino"))

	build_background(
		background_path,
		fallback_title,
		"Fondo final: %s" % background_path.get_file()
	)

	top_label.text = "Nuevo juego · Camino del Forastero · Elige tu camino"
	bottom_text_label.text = "Selecciona un camino. Cada uno favorece ciertos vínculos y complica otros."

	clear_card_area()
	card_grid = create_grid(6)
	card_area.add_child(card_grid)

	for class_id in DataManager.player_classes.keys():
		add_class_card(card_grid, str(class_id))

	build_three_buttons(
		"Volver a apariencia",
		func():
			show_appearance_selection(),
		true,
		"Continuar",
		func():
			show_confirm_selection(),
		selected_class_id != "",
		"Saltar prólogo",
		func():
			show_confirm_selection(),
		false
	)

	call_deferred("refresh_layout_after_frame")


func add_class_card(parent: Node, class_id: String) -> void:
	var locked_class_id: String = class_id
	var class_data: Dictionary = DataManager.get_player_class(class_id)

	var card: Button = Button.new()
	card.focus_mode = Control.FOCUS_ALL
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(160, 300)
	card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.text = build_class_card_text(class_id, class_data)

	card.mouse_entered.connect(func():
		bottom_text_label.text = build_class_hover_summary(class_data)
	)
	card.focus_entered.connect(func():
		bottom_text_label.text = build_class_hover_summary(class_data)
	)
	card.pressed.connect(func():
		selected_class_id = locked_class_id
		bottom_text_label.text = "%s seleccionado. Pulsa Continuar para confirmar." % class_data.get("name", locked_class_id)
		show_class_selection()
	)

	parent.add_child(card)

func build_class_card_text(class_id: String, class_data: Dictionary) -> String:
	var marker: String = ""

	if selected_class_id == class_id:
		marker = "✓ "

	return "%s%s\n\n%s\n\n%s" % [
		marker,
		class_data.get("name", class_id),
		get_class_asset_name(class_id),
		class_data.get("element", "")
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
	var confirm_background_path: String = get_confirm_background_path(selected_class_id)

	build_background(
		confirm_background_path,
		"Confirmar Forastero",
		"Fondo final: %s" % get_confirm_background_name(selected_class_id)
	)

	top_label.text = "Nuevo juego · Confirmar Forastero"
	bottom_text_label.text = "%s\n%s" % [
		build_confirm_title(class_data, appearance_label),
		build_confirm_description(class_data)
	]

	clear_card_area()

	build_three_buttons(
		"Volver a camino",
		func():
			show_class_selection(),
		true,
		"Comenzar historia",
		func():
			start_game(),
		true,
		"Cambiar apariencia",
		func():
			show_appearance_selection(),
		true
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

func build_confirm_description(class_data: Dictionary) -> String:
	var style_text: String = str(class_data.get("narrative_style", "")).strip_edges()

	if style_text == "":
		return "El Velo acepta esta forma. Luminaria responderá a tus decisiones."

	if style_text.length() > 150:
		style_text = style_text.substr(0, 147).strip_edges() + "..."

	return style_text

func get_confirm_background_name(class_id: String) -> String:
	var appearance_asset_id: String = selected_appearance_id

	if appearance_asset_id == "woman":
		appearance_asset_id = "female"
	elif appearance_asset_id == "veiled":
		appearance_asset_id = "veiled"
	else:
		appearance_asset_id = "male"

	var normalized_class_id: String = class_id.replace("_outsider", "")

	return "intro_confirm_outsider_%s_%s.png" % [
		appearance_asset_id,
		normalized_class_id
	]

func get_confirm_background_path(class_id: String) -> String:
	var intro_ui: Dictionary = DataManager.get_intro_ui()
	var pattern: String = str(intro_ui.get(
		"confirm_background_pattern",
		"res://assets/backgrounds/intro_confirm_outsider_{appearance}_{class}.png"
	))

	var appearance_asset_id: String = selected_appearance_id

	if appearance_asset_id == "woman":
		appearance_asset_id = "female"
	elif appearance_asset_id == "veiled":
		appearance_asset_id = "veiled"
	else:
		appearance_asset_id = "male"

	var normalized_class_id: String = class_id.replace("_outsider", "")

	return pattern.replace("{appearance}", appearance_asset_id).replace("{class}", normalized_class_id)

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
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 14)
	return grid


func build_three_buttons(
	left_text: String,
	left_callback: Callable,
	left_enabled: bool,
	center_text: String,
	center_callback: Callable,
	center_enabled: bool,
	right_text: String,
	right_callback: Callable,
	right_enabled: bool
) -> void:
	clear_children(bottom_buttons)

	previous_button = add_footer_button(left_text, left_callback)
	previous_button.disabled = not left_enabled

	primary_button = add_footer_button(center_text, center_callback)
	primary_button.disabled = not center_enabled

	tertiary_button = add_footer_button(right_text, right_callback)
	tertiary_button.disabled = not right_enabled


func add_footer_button(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(190, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	LuminariaTheme.apply_button_text(button, 17)
	button.pressed.connect(callback)
	bottom_buttons.add_child(button)
	return button


func clear_card_area() -> void:
	for child in card_area.get_children():
		child.queue_free()


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func layout_overlay_controls() -> void:
	var margin: float = 18.0
	var top_height: float = 46.0
	var panel_width: float = min(1120.0, max(720.0, size.x - (margin * 2.0)))
	var bottom_height: float = 184.0

	top_panel.size = Vector2(panel_width, top_height)
	top_panel.position = Vector2(
		(size.x - panel_width) / 2.0,
		margin
	)

	bottom_panel.size = Vector2(panel_width, bottom_height)
	bottom_panel.position = Vector2(
		(size.x - panel_width) / 2.0,
		max(margin, size.y - bottom_height - margin)
	)

	var card_top: float = top_panel.position.y + top_height + 10.0
	var card_bottom: float = bottom_panel.position.y - 10.0

	card_area.position = Vector2(
		(size.x - panel_width) / 2.0,
		card_top
	)
	card_area.size = Vector2(
		panel_width,
		max(160.0, card_bottom - card_top)
	)

	if card_grid != null:
		var grid_width: float = panel_width
		var grid_height: float = card_area.size.y

		if current_step == IntroStep.APPEARANCE:
			grid_width = min(panel_width, 840.0)
			grid_height = min(card_area.size.y, 410.0)
		elif current_step == IntroStep.CLASS:
			grid_width = min(panel_width, 1120.0)
			grid_height = min(card_area.size.y, 330.0)

		card_grid.size = Vector2(grid_width, grid_height)
		card_grid.position = Vector2(
			(card_area.size.x - grid_width) / 2.0,
			(card_area.size.y - grid_height) / 2.0
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

func build_confirm_title(class_data: Dictionary, appearance_label: String) -> String:
	var player_class_name: String = str(class_data.get("name", selected_class_id))
	var clean_class_name: String = player_class_name
	var element_name: String = str(class_data.get("element", "")).to_lower()

	clean_class_name = clean_class_name.replace("Forastero ", "")
	clean_class_name = clean_class_name.replace("Forastera ", "")
	clean_class_name = clean_class_name.replace("Forma velada ", "")

	if element_name != "":
		return "Camino elegido: %s %s, bajo el signo de %s." % [
			appearance_label,
			clean_class_name,
			element_name
		]

	return "Camino elegido: %s %s." % [
		appearance_label,
		clean_class_name
	]

func get_selection_frame_color(is_selected: bool) -> Color:
	if is_selected:
		return Color(1.0, 0.90, 0.55, 1.0)

	return Color(0.78, 0.82, 0.96, 0.92)


func get_selection_portrait_color(is_selected: bool) -> Color:
	if is_selected:
		return Color(1.0, 1.0, 1.0, 1.0)

	return Color(0.86, 0.90, 1.0, 0.92)


func make_selection_label_style(is_selected: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()

	if is_selected:
		style.bg_color = Color(0.12, 0.07, 0.12, 0.74)
		style.border_color = Color(1.0, 0.78, 0.36, 0.90)
	else:
		style.bg_color = Color(0.04, 0.04, 0.08, 0.58)
		style.border_color = Color(0.68, 0.62, 0.82, 0.38)

	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 6
	style.content_margin_top = 4
	style.content_margin_right = 6
	style.content_margin_bottom = 4
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)

	return style
