extends Area2D

@onready var pole: Sprite2D = get_node("../Pole")
@onready var laser: Sprite2D = get_node("../Laser")
@onready var landon: CharacterBody2D = get_node("../Landon")

func _ready() -> void:
	if laser != null:
		laser.visible = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Landon":
		return

	if landon.has_method("disable_control"):
		landon.disable_control()

	var pole_marker: Marker2D = pole.get_node_or_null("Marker2D") as Marker2D
	var landon_marker: Marker2D = landon.get_node_or_null("Marker2D") as Marker2D

	var start_pos: Vector2
	if pole_marker != null:
		start_pos = pole_marker.global_position
	else:
		start_pos = pole.global_position

	var target_pos: Vector2
	if landon_marker != null:
		target_pos = landon_marker.global_position
	else:
		target_pos = landon.global_position

	var direction: Vector2 = (target_pos - start_pos).normalized()
	var distance: float = start_pos.distance_to(target_pos)

	if laser != null:
		laser.global_position = start_pos + (direction * distance / 2.0)
		laser.rotation = direction.angle()
		if laser.texture != null:
			laser.scale.x = distance / laser.texture.get_width()
		laser.scale.y = 0.05
		laser.visible = true

	await get_tree().create_timer(0.8).timeout

	if landon != null:
		landon.visible = false
	if laser != null:
		laser.visible = false

	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file("res://lose3.tscn")
