extends Node2D

@onready var landon: CharacterBody2D = $Landon
@onready var placed_extinguisher: AnimatedSprite2D = $PlacedExtinguisher
@onready var start_marker: Marker2D = $PlacedExtinguisher/Start
@onready var middle_marker: Marker2D = $PlacedExtinguisher/Middle
@onready var end_marker: Marker2D = $PlacedExtinguisher/End
@onready var first_martian: AnimatedSprite2D = $FirstMartian
@onready var red_line: Area2D = $RedLine

func _ready() -> void:
	var right_arrow: Node = get_node_or_null("RightArrow")
	if right_arrow != null and right_arrow is CanvasItem:
		(right_arrow as CanvasItem).visible = InventoryData.martian_defeated

	if InventoryData.martian_defeated:
		# Martian is defeated - scene is safe, remove danger & martian
		if is_instance_valid(first_martian):
			first_martian.queue_free()
		if is_instance_valid(red_line):
			red_line.queue_free()
		if is_instance_valid(placed_extinguisher):
			placed_extinguisher.queue_free()
		if is_instance_valid(landon):
			landon.visible = true
			landon.set_process(true)
			landon.set_physics_process(true)
		return

	# Check if we should start the extinguisher animation (triggered from mars_ground)
	if InventoryData.extinguisher_launched:
		# Hide Landon - he stayed behind pressing the remote
		call_deferred("_hide_landon")
		
		# Animate extinguisher straight to the martian
		animate_extinguisher_to_martian()
		
		# Reset the flag so it doesn't animate again on scene reload
		InventoryData.extinguisher_launched = false
	else:
		# Extinguisher not launched yet - Landon should be visible and active
		if is_instance_valid(landon):
			landon.visible = true
			landon.set_process(true)
			landon.set_physics_process(true)


func _hide_landon() -> void:
	if is_instance_valid(landon):
		landon.visible = false
		landon.set_process(false)
		landon.set_physics_process(false)
		# Also stop any movement
		landon.velocity = Vector2.ZERO


func animate_extinguisher_to_martian() -> void:
	if not is_instance_valid(placed_extinguisher):
		return
	
	# Get end marker position (martian's head)
	var end_pos: Vector2 = end_marker.global_position
	var start_pos: Vector2 = start_marker.global_position
	
	# Ensure extinguisher starts at start marker
	placed_extinguisher.global_position = start_pos
	placed_extinguisher.visible = true
	placed_extinguisher.play("rolling")
	
	# Animate straight to martian's head (end marker)
	var tween: Tween = create_tween()
	var duration: float = 2.0  # seconds
	
	tween.tween_property(placed_extinguisher, "global_position", end_pos, duration)
	
	# After reaching martian's head, trigger impact sequence
	tween.tween_callback(stop_extinguisher.bind(placed_extinguisher)).set_delay(0.2)


func stop_extinguisher(extinguisher: AnimatedSprite2D) -> void:
	if is_instance_valid(extinguisher):
		extinguisher.stop()
	
	_play_martian_defeat_sequence()


func _play_martian_defeat_sequence() -> void:
	# Calculate center position between extinguisher and martian to cover both
	var martian_pos: Vector2 = first_martian.global_position if is_instance_valid(first_martian) else Vector2(974, 330)
	var extinguisher_pos: Vector2 = placed_extinguisher.global_position if is_instance_valid(placed_extinguisher) else martian_pos
	var cloud_center: Vector2 = (martian_pos + extinguisher_pos) / 2.0
	
	var cloud_texture: Texture2D = load("res://images/cloud.png") as Texture2D
	var cloud_sprite: Sprite2D = Sprite2D.new()
	if cloud_texture != null:
		cloud_sprite.texture = cloud_texture
	
	cloud_sprite.z_index = 100
	add_child(cloud_sprite)
	cloud_sprite.global_position = cloud_center
	cloud_sprite.scale = Vector2(0.5, 0.5)
	cloud_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# 1. Puff cloud expands without fading (solid puff to cover martian + extinguisher)
	var cloud_tween: Tween = create_tween()
	cloud_tween.tween_property(cloud_sprite, "scale", Vector2(3.0, 3.0), 1.0)
	await cloud_tween.finished
	
	# Pause briefly while fully covered
	await get_tree().create_timer(0.3).timeout
	
	# Hide extinguisher while covered
	if is_instance_valid(placed_extinguisher):
		placed_extinguisher.visible = false
	
	# 2. Position Martian horizontally and drop down to ground level so it doesn't float
	if is_instance_valid(first_martian):
		first_martian.rotation_degrees = -90.0
		# Drop y position down to ground level (feet were around 524, rotated height is ~187, so center y = 430)
		first_martian.global_position.y = 435.0
	
	# Remove cloud to reveal the fallen martian
	var cloud_fade: Tween = create_tween()
	cloud_fade.tween_property(cloud_sprite, "modulate:a", 0.0, 0.4)
	await cloud_fade.finished
	cloud_sprite.queue_free()
	
	# 3. Martian fades away while lying on the ground
	if is_instance_valid(first_martian):
		var martian_tween: Tween = create_tween()
		martian_tween.tween_property(first_martian, "modulate:a", 0.0, 1.5)
		await martian_tween.finished
	
	# Mark martian as defeated
	InventoryData.martian_defeated = true
	
	# 4. Change scene back to mars_ground.tscn
	get_tree().change_scene_to_file("res://mars_ground.tscn")
