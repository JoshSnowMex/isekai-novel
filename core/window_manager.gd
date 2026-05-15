extends Node


const BASE_WINDOW_SIZE := Vector2i(1280, 720)
const MIN_WINDOW_SIZE := Vector2i(960, 540)


func _ready() -> void:
	var window: Window = get_window()

	window.min_size = MIN_WINDOW_SIZE

	if window.size == Vector2i.ZERO:
		window.size = BASE_WINDOW_SIZE

	window.size_changed.connect(_on_window_size_changed)
	get_tree().root.size_changed.connect(_on_root_size_changed)

	call_deferred("sync_viewport_to_window")


func _on_window_size_changed() -> void:
	sync_viewport_to_window()


func _on_root_size_changed() -> void:
	get_tree().call_group("responsive_layout", "refresh_responsive_layout")


func sync_viewport_to_window() -> void:
	var window: Window = get_window()
	var window_size: Vector2i = window.size

	if window_size.x <= 0 or window_size.y <= 0:
		return

	get_tree().root.size = window_size
	get_tree().call_group("responsive_layout", "refresh_responsive_layout")
