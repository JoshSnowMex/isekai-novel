extends ColorRect
class_name LoadGameModal


var panel: PanelContainer
var title_label: Label
var description_label: Label
var autosave_button: Button
var manual_button: Button
var cancel_button: Button


func _ready() -> void:
	build()
	hide_modal()


func build() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	color = Color(0, 0, 0, 0.58)
	mouse_filter = Control.MOUSE_FILTER_STOP

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 260)
	add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	title_label = Label.new()
	title_label.text = "Cargar partida"
	title_label.custom_minimum_size = Vector2(1, 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title_label)

	description_label = Label.new()
	description_label.text = ""
	description_label.custom_minimum_size = Vector2(1, 22)
	description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(description_label)

	var buttons_box: VBoxContainer = VBoxContainer.new()
	buttons_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	buttons_box.add_theme_constant_override("separation", 8)
	box.add_child(buttons_box)

	autosave_button = make_load_button(
		"Último autosave",
		""
	)
	autosave_button.pressed.connect(load_autosave)
	buttons_box.add_child(autosave_button)

	manual_button = make_load_button(
		"Guardado manual",
		""
	)
	manual_button.pressed.connect(load_manual)
	buttons_box.add_child(manual_button)

	cancel_button = Button.new()
	cancel_button.text = "Cancelar"
	cancel_button.focus_mode = Control.FOCUS_ALL
	cancel_button.custom_minimum_size = Vector2(1, 38)
	cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_button.pressed.connect(hide_modal)
	box.add_child(cancel_button)

	call_deferred("layout_modal")


func make_load_button(title: String, hint: String) -> Button:
	var button: Button = Button.new()
	button.text = "%s\n%s" % [title, hint]
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(1, 58)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


func open() -> void:
	visible = true
	update_buttons()
	call_deferred("layout_modal")


func hide_modal() -> void:
	visible = false


func update_buttons() -> void:
	autosave_button.disabled = not SaveManager.has_autosave_file()
	manual_button.disabled = not SaveManager.has_manual_save_file()

	if autosave_button.disabled and manual_button.disabled:
		description_label.text = "No hay partidas guardadas."
	else:
		description_label.text = ""


func load_autosave() -> void:
	if SceneRouter.load_autosave_and_route():
		return

	description_label.text = "No se pudo cargar el autosave."
	update_buttons()


func load_manual() -> void:
	if SceneRouter.load_manual_and_route():
		return

	description_label.text = "No se pudo cargar el guardado manual."
	update_buttons()


func layout_modal() -> void:
	if panel == null:
		return

	var panel_size: Vector2 = Vector2(
		min(560.0, max(420.0, size.x - 32.0)),
		260.0
	)

	panel.size = panel_size
	panel.position = Vector2(
		(size.x - panel_size.x) / 2.0,
		(size.y - panel_size.y) / 2.0
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		call_deferred("layout_modal")
