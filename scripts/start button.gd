extends Sprite2D

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if get_rect().has_point(to_local(get_global_mouse_position())):
				get_tree().change_scene_to_file("res://broken spaceship.tscn")
