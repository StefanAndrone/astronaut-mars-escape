extends Area2D

@onready var martian: AnimatedSprite2D = get_node("../FirstMartian")
@onready var laser: Sprite2D = get_node("../Laser")
@onready var landon: CharacterBody2D = get_node("../Landon")

func _ready() -> void:
	laser.visible = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Landon":
		return

	landon.get_node("AnimatedSprite2D").play("idle")
	landon.velocity = Vector2.ZERO
	landon.set_deferred("monitoring", false)
	landon.get_node("NavigationAgent2D").target_position = landon.global_position

	# Martian turns to face astronaut
	martian.flip_h = true
	await get_tree().create_timer(0.3).timeout

	# Calculate leg positions to align them
	var astronaut_leg_y: float = get_astronaut_leg_y()
	var target_martian_y: float = get_martian_y_for_leg_alignment(astronaut_leg_y)

	# Martian walks to align legs with astronaut
	var target_pos: Vector2 = Vector2(martian.global_position.x, target_martian_y)

	var tween: Tween = create_tween()
	tween.tween_property(martian, "global_position", target_pos, 0.5)

	await tween.finished

	_position_laser()
	laser.visible = true

	await get_tree().create_timer(1.0).timeout

	landon.visible = false
	laser.visible = false

	await get_tree().create_timer(1.0).timeout

	get_tree().change_scene_to_file("res://lose1.tscn")

func get_astronaut_leg_y() -> float:
	var astronaut_sprite: AnimatedSprite2D = landon.get_node("AnimatedSprite2D")
	var sprite_height: float = 505.0  # Astronaut sprite height in pixels (243x505 atlas region)
	var scale_y: float = 0.679688
	var visual_height: float = sprite_height * scale_y
	var sprite_center_y: float = astronaut_sprite.global_position.y
	return sprite_center_y + visual_height / 2.0

func get_martian_y_for_leg_alignment(target_leg_y: float) -> float:
	var sprite_height: float = 250.0  # Martian sprite height in pixels (125x250 atlas region)
	var scale_y: float = 1.552
	var visual_height: float = sprite_height * scale_y
	return target_leg_y - visual_height / 2.0

func _position_laser() -> void:
	# Use markers for laser endpoints
	var gun_marker: Marker2D = martian.get_parent().get_node("FirstMartian/Marker2D")
	var target_marker: Marker2D = landon.get_node("Marker2D")

	var gun_pos: Vector2 = gun_marker.global_position
	var target_pos: Vector2 = target_marker.global_position

	var direction: Vector2 = (target_pos - gun_pos).normalized()
	var distance: float = gun_pos.distance_to(target_pos)

	# Position laser at midpoint between gun and target
	laser.global_position = gun_pos + (direction * distance / 2.0)
	laser.rotation = direction.angle()
	laser.scale.x = distance / laser.texture.get_width()
