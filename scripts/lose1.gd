extends Node2D

func _ready() -> void:
	print("lose1.gd _ready() called")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		# Check if click is within collision shape bounds (pos: 592, 542; size: 476, 162.25)
		var shape_rect: Rect2 = Rect2(592 - 238, 542 - 81.125, 476, 162.25055)
		if shape_rect.has_point(mouse_pos):
			get_tree().root.set_input_as_handled()
			reset_and_reload()

func reset_and_reload() -> void:
	print("reset_and_reload() called")
	# Go back to mars_ground_2 (keep inventory)
	get_tree().change_scene_to_file("res://mars_ground_2.tscn")
