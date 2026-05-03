extends Control

var money_label: Label
var item_container: VBoxContainer
var message_label: Label

func _ready() -> void:
	setup_fullscreen_root()
	build_ui()
	refresh_shop()

func build_ui() -> void:
	var root: VBoxContainer = ScreenRoot.create(self)

	root.add_child(UIFactory.title("Tienda"))

	money_label = UIFactory.body("")
	root.add_child(money_label)

	message_label = UIFactory.body("Compra regalos para usarlos en tus relaciones.")
	root.add_child(message_label)

	item_container = VBoxContainer.new()
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER
	item_container.add_theme_constant_override("separation", 8)
	root.add_child(item_container)

	var back_button: Button = UIFactory.button("Volver al mapa")
	back_button.pressed.connect(func(): SceneRouter.go_to_world_map())
	root.add_child(back_button)

func refresh_shop() -> void:
	money_label.text = "Dinero: %s" % GameManager.player.get("money", 0)

	for child in item_container.get_children():
		child.queue_free()

	for item_id in DataManager.items.keys():
		var item: Dictionary = DataManager.get_item(item_id)

		if item.get("type", "") != "gift":
			continue

		var button: Button = UIFactory.button("%s — %s monedas" % [
			item.get("name", item_id),
			item.get("price", 0)
		])
		button.pressed.connect(func(): buy_item(item_id))
		item_container.add_child(button)

func buy_item(item_id: String) -> void:
	var success: bool = GameManager.buy_item(item_id, 1)
	var item: Dictionary = DataManager.get_item(item_id)

	if success:
		message_label.text = "Compraste: %s" % item.get("name", item_id)
	else:
		message_label.text = "No tienes suficiente dinero."

	SaveManager.save_game()
	refresh_shop()

func setup_fullscreen_root() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
