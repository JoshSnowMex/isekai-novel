extends Control


var hud_bar: WorldHudBar
var shop_frame: PanelContainer
var shop_layer: Control
var background_layer: Control

var global_action_panel: PanelContainer
var global_action_buttons: HBoxContainer

var main_panel: PanelContainer
var main_title_label: Label
var main_description_scroll: ScrollContainer
var main_description_label: Label
var item_grid: GridContainer

var detail_panel: PanelContainer
var detail_title_label: Label
var detail_description_scroll: ScrollContainer
var detail_description_label: Label
var detail_actions: HBoxContainer

var selected_item_id: String = ""
var current_message: String = ""

const BASE_SHOP_SIZE := Vector2(1050.0, 540.0)


func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_shop()
	show_pending_narrative_messages()


func build_ui() -> void:
	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 0
	root.offset_top = 0
	root.offset_right = 0
	root.offset_bottom = 0
	root.add_theme_constant_override("separation", 4)
	add_child(root)

	hud_bar = WorldHudBar.new()
	hud_bar.build()
	root.add_child(hud_bar)

	shop_frame = PanelContainer.new()
	shop_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(shop_frame)

	var frame_margin: MarginContainer = MarginContainer.new()
	frame_margin.add_theme_constant_override("margin_left", 6)
	frame_margin.add_theme_constant_override("margin_top", 6)
	frame_margin.add_theme_constant_override("margin_right", 6)
	frame_margin.add_theme_constant_override("margin_bottom", 6)
	shop_frame.add_child(frame_margin)

	shop_layer = Control.new()
	shop_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_layer.clip_contents = true
	frame_margin.add_child(shop_layer)

	background_layer = Control.new()
	background_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_layer.offset_left = 0
	background_layer.offset_top = 0
	background_layer.offset_right = 0
	background_layer.offset_bottom = 0
	shop_layer.add_child(background_layer)

	build_background()
	build_global_action_panel()
	build_main_panel()
	build_detail_panel()

	call_deferred("refresh_layout_after_frame")


func build_background() -> void:
	clear_children(background_layer)

	var location_data: Dictionary = DataManager.get_location("shop")
	var location_ui: Dictionary = DataManager.get_location_ui("shop")

	var background_path: String = str(location_ui.get("background", ""))
	var fallback_title: String = str(location_data.get("name", "Tienda del Umbral"))
	var final_asset_name: String = background_path.get_file()

	if final_asset_name == "":
		final_asset_name = "location_shop_umbral.png"

	var background: Control = VisualAsset.make_texture_or_placeholder(
		background_path,
		fallback_title,
		"Fondo final: %s" % final_asset_name
	)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.offset_left = 0
	background.offset_top = 0
	background.offset_right = 0
	background.offset_bottom = 0
	background_layer.add_child(background)


func build_global_action_panel() -> void:
	global_action_panel = PanelContainer.new()
	global_action_panel.custom_minimum_size = Vector2(430, 46)
	shop_layer.add_child(global_action_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	global_action_panel.add_child(margin)

	global_action_buttons = HBoxContainer.new()
	global_action_buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	global_action_buttons.add_theme_constant_override("separation", 8)
	margin.add_child(global_action_buttons)

	add_global_action("Mapa", func(): _on_map_pressed())
	add_global_action("Bitácora", func(): SceneRouter.go_to_journal(SceneRouter.SHOP_SCENE))
	add_global_action("Guardar", func(): _on_save_pressed())
	add_global_action("Cargar", func(): SceneRouter.go_to_main_menu())


func build_main_panel() -> void:
	main_panel = PanelContainer.new()
	main_panel.custom_minimum_size = Vector2(620, 360)
	shop_layer.add_child(main_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	main_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	main_title_label = Label.new()
	main_title_label.custom_minimum_size = Vector2(1, 24)
	main_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_title_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	main_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(main_title_label)

	main_description_scroll = ScrollContainer.new()
	main_description_scroll.custom_minimum_size = Vector2(1, 68)
	main_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_description_scroll.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(main_description_scroll)

	main_description_label = Label.new()
	main_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_description_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	main_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	main_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_description_scroll.add_child(main_description_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(scroll)

	item_grid = GridContainer.new()
	item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_grid.columns = 2
	item_grid.add_theme_constant_override("h_separation", 8)
	item_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(item_grid)


func build_detail_panel() -> void:
	detail_panel = PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(430, 210)
	shop_layer.add_child(detail_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	detail_panel.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	margin.add_child(box)

	detail_title_label = Label.new()
	detail_title_label.custom_minimum_size = Vector2(1, 24)
	detail_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_title_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	detail_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	detail_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(detail_title_label)

	detail_description_scroll = ScrollContainer.new()
	detail_description_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_description_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_description_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail_description_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(detail_description_scroll)

	detail_description_label = Label.new()
	detail_description_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_description_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	detail_description_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	detail_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_description_scroll.add_child(detail_description_label)

	detail_actions = HBoxContainer.new()
	detail_actions.custom_minimum_size = Vector2(1, 40)
	detail_actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_actions.size_flags_vertical = Control.SIZE_SHRINK_END
	detail_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	detail_actions.add_theme_constant_override("separation", 8)
	box.add_child(detail_actions)


func refresh_shop(message: String = "") -> void:
	current_message = message
	GameManager.current_location_id = "shop"
	hud_bar.refresh()

	refresh_main_panel()
	refresh_detail_panel()

	call_deferred("refresh_layout_after_frame")


func refresh_main_panel() -> void:
	clear_children(item_grid)

	main_title_label.text = "Tienda del Umbral"

	if current_message != "":
		main_description_label.text = current_message
	else:
		main_description_label.text = get_shop_description()

	var item_ids: Array = get_shop_item_ids()

	for item_id in item_ids:
		add_item_button(str(item_id))

	if item_ids.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No hay objetos disponibles por ahora."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_grid.add_child(empty_label)


func refresh_detail_panel() -> void:
	clear_children(detail_actions)

	if selected_item_id == "":
		detail_title_label.text = "Elige un objeto"
		detail_description_label.text = "Pasa el cursor o selecciona un regalo para ver detalles. Comprar regalos amplía tus opciones con los personajes."
		add_detail_action("Volver al mapa", func(): _on_map_pressed())
		return

	var item: Dictionary = DataManager.get_item(selected_item_id)
	var item_name: String = str(item.get("name", selected_item_id))
	var price: int = int(item.get("price", 0))
	var owned: int = get_inventory_amount(selected_item_id)

	detail_title_label.text = item_name
	detail_description_label.text = build_item_detail_text(selected_item_id)

	var can_buy: bool = int(GameManager.player.get("money", 0)) >= price

	add_detail_action("Comprar", func(): buy_item(selected_item_id), not can_buy)
	add_detail_action("Comprar x3", func(): buy_item_amount(selected_item_id, 3), not can_buy_amount(selected_item_id, 3))
	add_detail_action("Cerrar", func():
		selected_item_id = ""
		current_message = ""
		refresh_shop()
	)

	if owned > 0:
		var owned_label: Label = Label.new()
		owned_label.text = "En inventario: %s" % owned
		owned_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_actions.add_child(owned_label)


func get_shop_description() -> String:
	var money: int = int(GameManager.player.get("money", 0))
	var gift_count: int = get_total_gift_inventory_count()

	var text: String = ""
	text += "La Tienda del Umbral reúne regalos útiles, extraños y peligrosamente personales."
	text += "\n\nLúmenes disponibles: %s" % money

	if gift_count > 0:
		text += "\nRegalos en inventario: %s" % gift_count
	else:
		text += "\nNo llevas regalos adicionales en la mochila."

	return text


func get_shop_item_ids() -> Array:
	var result: Array = []

	for item_id in DataManager.items.keys():
		var item: Dictionary = DataManager.get_item(str(item_id))

		if item.get("type", "") != "gift":
			continue

		result.append(str(item_id))

	result.sort_custom(func(a, b):
		var item_a: Dictionary = DataManager.get_item(str(a))
		var item_b: Dictionary = DataManager.get_item(str(b))

		var price_a: int = int(item_a.get("price", 0))
		var price_b: int = int(item_b.get("price", 0))

		if price_a == price_b:
			return str(item_a.get("name", a)) < str(item_b.get("name", b))

		return price_a < price_b
	)

	return result


func add_item_button(item_id: String) -> void:
	var locked_item_id: String = item_id
	var item: Dictionary = DataManager.get_item(locked_item_id)
	var item_name: String = str(item.get("name", locked_item_id))
	var price: int = int(item.get("price", 0))
	var owned: int = get_inventory_amount(locked_item_id)

	var button_text: String = "%s\n%s Lúmenes" % [
		item_name,
		price
	]

	if owned > 0:
		button_text += " · Tienes %s" % owned

	var button: Button = Button.new()
	button.text = button_text
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(220, 58)
	button.disabled = price > int(GameManager.player.get("money", 0))

	button.pressed.connect(func():
		selected_item_id = locked_item_id
		current_message = ""
		refresh_shop()
	)

	button.mouse_entered.connect(func():
		show_item_preview(locked_item_id)
	)

	button.focus_entered.connect(func():
		show_item_preview(locked_item_id)
	)

	button.mouse_exited.connect(func():
		restore_shop_text()
	)

	item_grid.add_child(button)


func show_item_preview(item_id: String) -> void:
	var item: Dictionary = DataManager.get_item(item_id)
	var item_name: String = str(item.get("name", item_id))

	main_title_label.text = item_name
	main_description_label.text = build_item_detail_text(item_id)

	detail_title_label.text = item_name
	detail_description_label.text = build_item_detail_text(item_id)


func restore_shop_text() -> void:
	if selected_item_id != "":
		return

	main_title_label.text = "Tienda del Umbral"

	if current_message != "":
		main_description_label.text = current_message
	else:
		main_description_label.text = get_shop_description()

	detail_title_label.text = "Elige un objeto"
	detail_description_label.text = "Pasa el cursor o selecciona un regalo para ver detalles. Comprar regalos amplía tus opciones con los personajes."


func build_item_detail_text(item_id: String) -> String:
	var item: Dictionary = DataManager.get_item(item_id)
	var item_name: String = str(item.get("name", item_id))
	var description: String = str(item.get("description", ""))
	var price: int = int(item.get("price", 0))
	var owned: int = get_inventory_amount(item_id)
	var money: int = int(GameManager.player.get("money", 0))

	var text: String = ""
	text += description

	if text == "":
		text = "Un objeto de la tienda."

	text += "\n\nPrecio: %s Lúmenes" % price
	text += "\nEn inventario: %s" % owned

	if money >= price:
		text += "\nPuedes comprarlo ahora."
	else:
		text += "\nTe faltan %s Lúmenes." % max(price - money, 0)

	text += "\n\nTipo: Regalo"
	text += "\nUso: entrégalo a un personaje desde una ubicación cuando esté presente."

	return text


func buy_item(item_id: String) -> void:
	buy_item_amount(item_id, 1)


func buy_item_amount(item_id: String, amount: int) -> void:
	var item: Dictionary = DataManager.get_item(item_id)
	var item_name: String = str(item.get("name", item_id))
	var price: int = int(item.get("price", 0))
	var total_cost: int = price * amount

	if amount <= 0:
		return

	if int(GameManager.player.get("money", 0)) < total_cost:
		current_message = "No tienes suficientes Lúmenes para comprar %s x%s." % [
			item_name,
			amount
		]
		refresh_shop(current_message)
		return

	for index in range(amount):
		GameManager.buy_item(item_id, 1)

	SaveManager.autosave_game()

	selected_item_id = item_id
	current_message = "Compraste %s x%s.\nLúmenes gastados: %s" % [
		item_name,
		amount,
		total_cost
	]

	refresh_shop(current_message)


func can_buy_amount(item_id: String, amount: int) -> bool:
	var item: Dictionary = DataManager.get_item(item_id)
	var price: int = int(item.get("price", 0))
	var total_cost: int = price * amount

	return int(GameManager.player.get("money", 0)) >= total_cost


func get_inventory_amount(item_id: String) -> int:
	if not GameManager.player.has("inventory"):
		return 0

	var total: int = 0

	for entry in GameManager.player.get("inventory", []):
		var item_entry: Dictionary = entry

		if str(item_entry.get("item_id", "")) == item_id:
			total += int(item_entry.get("amount", 0))

	return total


func get_total_gift_inventory_count() -> int:
	if not GameManager.player.has("inventory"):
		return 0

	var total: int = 0

	for entry in GameManager.player.get("inventory", []):
		var item_entry: Dictionary = entry
		var item_id: String = str(item_entry.get("item_id", ""))
		var item: Dictionary = DataManager.get_item(item_id)

		if item.get("type", "") == "gift":
			total += int(item_entry.get("amount", 0))

	return total


func show_shop_message(title: String, message: String) -> void:
	current_message = message

	main_title_label.text = title
	main_description_label.text = message

	clear_children(detail_actions)
	detail_title_label.text = title
	detail_description_label.text = message

	add_detail_action("Continuar", func():
		current_message = ""
		refresh_shop()
	)


func show_pending_narrative_messages() -> void:
	var messages: Array = GameManager.consume_pending_narrative_messages()

	if messages.is_empty():
		return

	var combined_text: String = ""

	for message in messages:
		combined_text += format_narrative_message(message)
		combined_text += "\n\n"

	show_shop_message(
		"El Velo se agita",
		combined_text.strip_edges()
	)

	SaveManager.autosave_game()
	hud_bar.refresh()


func format_narrative_message(message: Variant) -> String:
	if message is Dictionary:
		var entry: Dictionary = message
		var title: String = str(entry.get("name", entry.get("title", "Hito narrativo")))
		var text: String = str(entry.get("text", entry.get("message", "")))

		if text == "":
			return title

		return "%s\n\n%s" % [title, text]

	return str(message)


func _on_save_pressed() -> void:
	SaveManager.save_game()
	show_shop_message(
		"Partida guardada",
		"El progreso fue guardado manualmente en la Tienda del Umbral."
	)


func _on_map_pressed() -> void:
	SceneRouter.go_to_world_map()


func add_global_action(text: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	global_action_buttons.add_child(button)
	return button


func add_detail_action(text: String, callback: Callable, disabled: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.disabled = disabled
	button.focus_mode = Control.FOCUS_ALL
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(110, 36)

	if not disabled:
		button.pressed.connect(callback)

	detail_actions.add_child(button)
	return button


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func refresh_layout_after_frame() -> void:
	await get_tree().process_frame
	layout_overlay_controls()


func layout_overlay_controls() -> void:
	if shop_layer == null:
		return

	var margin: float = 10.0

	var global_width: float = 430.0

	if shop_layer.size.x < 760:
		global_width = 330.0

	global_action_panel.size = Vector2(global_width, 46)
	global_action_panel.position = Vector2(
		max(margin, shop_layer.size.x - global_width - margin),
		margin
	)

	var detail_width: float = 430.0
	var detail_height: float = 218.0

	var main_width: float = min(650.0, max(420.0, shop_layer.size.x - detail_width - 42.0))
	var main_height: float = min(390.0, max(300.0, shop_layer.size.y - 92.0))

	if shop_layer.size.x < 940:
		main_width = max(360.0, shop_layer.size.x - 24.0)
		main_height = min(330.0, max(260.0, shop_layer.size.y - 300.0))

		detail_width = max(360.0, shop_layer.size.x - 24.0)
		detail_height = 210.0

		main_panel.size = Vector2(main_width, main_height)
		main_panel.position = Vector2(
			12.0,
			68.0
		)

		detail_panel.size = Vector2(detail_width, detail_height)
		detail_panel.position = Vector2(
			12.0,
			max(12.0, shop_layer.size.y - detail_height - 12.0)
		)
	else:
		main_panel.size = Vector2(main_width, main_height)
		main_panel.position = Vector2(
			12.0,
			68.0
		)

		detail_panel.size = Vector2(detail_width, detail_height)
		detail_panel.position = Vector2(
			max(12.0, shop_layer.size.x - detail_width - 12.0),
			max(68.0, shop_layer.size.y - detail_height - 12.0)
		)

	if main_width < 560:
		item_grid.columns = 1
	else:
		item_grid.columns = 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if shop_layer != null:
			call_deferred("refresh_layout_after_frame")


func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
