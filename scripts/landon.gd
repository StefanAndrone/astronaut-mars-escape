extends CharacterBody2D
class_name Landon

@export var speed: float = 200.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_walking: bool = false
var inventory_ui: InventoryUI = null
var pending_pickup_item_name: String = ""
var is_launching: bool = false

const PICKUP_DISTANCE: float = 120.0

func _ready() -> void:
	animated_sprite.play("idle")
	remove_already_picked_items()
	hide_legacy_inventory_bar()
	ensure_inventory_ui()
	restore_placed_ramp_state()

func hide_legacy_inventory_bar() -> void:
	var legacy_bar: Node = get_node_or_null("../InventoryBar")
	if legacy_bar != null:
		legacy_bar.hide()

func ensure_inventory_ui() -> void:
	inventory_ui = get_node_or_null("InventoryUI") as InventoryUI
	if inventory_ui == null:
		inventory_ui = InventoryUI.new()
		inventory_ui.name = "InventoryUI"
		add_child(inventory_ui)
		inventory_ui.build_ui()
		inventory_ui.refresh()

func remove_already_picked_items() -> void:
	for item_name: String in InventoryData.ITEM_DEFINITIONS.keys():
		var item: ItemData = InventoryData.ITEM_DEFINITIONS[item_name]
		if InventoryData.picked_item_ids.has(item.item_id):
			var node: Node = get_node_or_null("../" + item_name)
			if node != null:
				node.queue_free()

func _input(event: InputEvent) -> void:
	if is_launching:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if try_use_selected_item_on_placeable(mouse_pos) or try_use_selected_item_on_ramp(mouse_pos) or try_use_selected_item_on_remote(mouse_pos):
			get_viewport().set_input_as_handled()

func restore_placed_ramp_state() -> void:
	var ramp: AnimatedSprite2D = get_node_or_null("../PlacedRamp") as AnimatedSprite2D
	if ramp == null:
		return
	ramp.visible = InventoryData.placed_ramp_visible
	ramp.play(InventoryData.placed_ramp_animation)
	var placed_punchglove: AnimatedSprite2D = get_node_or_null("../PlacedPunchglove") as AnimatedSprite2D
	if placed_punchglove != null:
		placed_punchglove.visible = InventoryData.placed_punchglove_visible
		placed_punchglove.play("idle")
	var placed_extinguisher: AnimatedSprite2D = get_node_or_null("../PlacedExtinguisher") as AnimatedSprite2D
	if placed_extinguisher != null:
		# If extinguisher was launched, keep it hidden regardless of saved visibility
		if InventoryData.extinguisher_launched:
			placed_extinguisher.visible = false
			InventoryData.placed_extinguisher_visible = false
		else:
			placed_extinguisher.visible = InventoryData.placed_extinguisher_visible
		placed_extinguisher.play("idle")

func try_use_selected_item_on_placeable(mouse_pos: Vector2) -> bool:
	if inventory_ui == null:
		return false
	var selected_item: ItemData = inventory_ui.get_selected_item()
	if selected_item == null:
		return false
	if selected_item.item_id == "mechanical_glove" and is_mouse_over_collision("../PlacedPunchglove/CollisionShape2D", mouse_pos):
		var placed_punchglove: AnimatedSprite2D = get_node_or_null("../PlacedPunchglove") as AnimatedSprite2D
		if placed_punchglove == null:
			return false
		placed_punchglove.visible = true
		placed_punchglove.play("idle")
		InventoryData.placed_punchglove_visible = true
		inventory_ui.consume_selected_item()
		return true
	if selected_item.item_id == "fire_extinguisher" and is_mouse_over_collision("../PlacedExtinguisher/CollisionShape2D", mouse_pos):
		var placed_extinguisher: AnimatedSprite2D = get_node_or_null("../PlacedExtinguisher") as AnimatedSprite2D
		if placed_extinguisher == null:
			return false
		placed_extinguisher.visible = true
		placed_extinguisher.play("idle")
		InventoryData.placed_extinguisher_visible = true
		inventory_ui.consume_selected_item()
		return true
	return false

func is_mouse_over_collision(collision_path: NodePath, mouse_pos: Vector2) -> bool:
	var collision_shape: CollisionShape2D = get_node_or_null(collision_path) as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return false
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rectangle == null:
		return false
	return rectangle.get_rect().has_point(collision_shape.to_local(mouse_pos))

func _unhandled_input(event: InputEvent) -> void:
	if is_launching:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if try_handle_arrow_click(mouse_pos):
			return
		for item_name: String in InventoryData.ITEM_DEFINITIONS.keys():
			var item_node: Node = get_node_or_null("../" + item_name)
			if item_node == null or not item_node is Sprite2D:
				continue
			var sprite: Sprite2D = item_node as Sprite2D
			if sprite.get_rect().has_point(sprite.to_local(mouse_pos)):
				if InventoryData.picked_item_ids.has(InventoryData.ITEM_DEFINITIONS[item_name].item_id):
					return
				pending_pickup_item_name = item_name
				nav_agent.target_position = item_node.global_position
				return
		pending_pickup_item_name = ""
		nav_agent.target_position = mouse_pos

func try_use_selected_item_on_ramp(mouse_pos: Vector2) -> bool:
	if inventory_ui == null or not is_mouse_over_ramp(mouse_pos):
		return false

	var ramp: AnimatedSprite2D = get_node_or_null("../PlacedRamp") as AnimatedSprite2D
	if ramp == null:
		return false

	var selected_item: ItemData = inventory_ui.get_selected_item()
	if selected_item == null:
		return false

	if selected_item.item_id == "tall_chair":
		ramp.visible = true
		ramp.play("with no ground")
		InventoryData.placed_ramp_visible = true
		InventoryData.placed_ramp_animation = &"with no ground"
		inventory_ui.consume_selected_item()
		return true

	if selected_item.item_id == "flower_vase" and ramp.visible and ramp.animation == &"with no ground":
		ramp.play("with ground")
		InventoryData.placed_ramp_animation = &"with ground"
		inventory_ui.consume_selected_item()
		return true

	return false


func try_use_selected_item_on_remote(mouse_pos: Vector2) -> bool:
	if inventory_ui == null:
		return false
	
	var selected_item: ItemData = inventory_ui.get_selected_item()
	if selected_item == null or selected_item.item_id != "remote_for_glove":
		return false
	
	# Check if ramp is in "with ground" state (vase placed)
	var ramp: AnimatedSprite2D = get_node_or_null("../PlacedRamp") as AnimatedSprite2D
	if ramp == null or not ramp.visible or ramp.animation != &"with ground":
		return false
	
	# Check if extinguisher hasn't been launched yet
	if InventoryData.extinguisher_launched:
		return false
	
	# Check if click is on punchglove or extinguisher collision area
	var punchglove_collision: CollisionShape2D = get_node_or_null("../PlacedPunchglove/CollisionShape2D") as CollisionShape2D
	var extinguisher_collision: CollisionShape2D = get_node_or_null("../PlacedExtinguisher/CollisionShape2D") as CollisionShape2D
	
	var clicked_on_target: bool = false
	if punchglove_collision != null and is_mouse_over_collision("../PlacedPunchglove/CollisionShape2D", mouse_pos):
		clicked_on_target = true
	elif extinguisher_collision != null and is_mouse_over_collision("../PlacedExtinguisher/CollisionShape2D", mouse_pos):
		clicked_on_target = true
	
	if not clicked_on_target:
		return false
	
	# Trigger launch sequence
	launch_extinguisher_sequence()
	# Remote is NOT consumed - stays in inventory
	return true


func launch_extinguisher_sequence() -> void:
	var placed_punchglove: AnimatedSprite2D = get_node_or_null("../PlacedPunchglove") as AnimatedSprite2D
	var placed_extinguisher: AnimatedSprite2D = get_node_or_null("../PlacedExtinguisher") as AnimatedSprite2D
	var ramp: AnimatedSprite2D = get_node_or_null("../PlacedRamp") as AnimatedSprite2D
	
	if placed_punchglove == null or placed_extinguisher == null or ramp == null:
		return
	
	# Block all input/movement during launch
	is_launching = true
	
	# Mark as launched to prevent re-triggering
	InventoryData.extinguisher_launched = true
	
	# 1. Start punchglove "punching" animation
	placed_punchglove.visible = true
	placed_punchglove.play("punching")
	InventoryData.placed_punchglove_visible = true
	
	# 2. Start extinguisher "rolling" animation and movement (delayed 0.13s)
	# Extinguisher starts from its current idle position and moves toward ramp
	await get_tree().create_timer(0.13).timeout
	if not is_instance_valid(placed_extinguisher):
		return
	placed_extinguisher.visible = true
	placed_extinguisher.play("rolling")
	InventoryData.placed_extinguisher_visible = true
	
	# 3. Calculate trajectory waypoints starting from extinguisher's current position
	var extinguisher_start_pos: Vector2 = placed_extinguisher.global_position
	var waypoints: Array[Vector2] = calculate_ramp_trajectory(ramp, extinguisher_start_pos)
	
	# 4. Animate extinguisher along trajectory using Tween
	animate_extinguisher_along_path(placed_extinguisher, waypoints)
	
	# 5. Optionally: play punchglove "idle" after punching animation finishes
	var punch_duration: float = placed_punchglove.sprite_frames.get_animation_speed("punching") > 0 and placed_punchglove.sprite_frames.get_frame_count("punching") > 0
	var punch_anim_time: float = placed_punchglove.sprite_frames.get_frame_count("punching") / placed_punchglove.sprite_frames.get_animation_speed("punching")
	await get_tree().create_timer(punch_anim_time).timeout
	if is_instance_valid(placed_punchglove):
		placed_punchglove.play("idle")
	
	# 6. Wait for extinguisher to finish trajectory and hide, then change scene
	# The tween callback in animate_extinguisher_along_path calls hide_extinguisher
	# We'll add a small delay after that and then change scene
	await get_tree().create_timer(0.5).timeout
	custom_change_of_scene()


func custom_change_of_scene() -> void:
	"""Changes scene from mars_ground to mars_ground_2 and calls do_nothing()"""
	get_tree().change_scene_to_file("res://mars_ground_2.tscn")
	do_nothing()


func do_nothing() -> void:
	"""Placeholder function called after scene change"""
	pass


func calculate_ramp_trajectory(ramp: AnimatedSprite2D, extinguisher_start_pos: Vector2) -> Array[Vector2]:
	# Use the markers placed on the ramp to define the trajectory
	var marker1: Marker2D = get_node_or_null("../PlacedRamp/Marker1") as Marker2D
	var marker2: Marker2D = get_node_or_null("../PlacedRamp/Marker2") as Marker2D
	var marker3: Marker2D = get_node_or_null("../PlacedRamp/Marker3") as Marker2D
	
	if marker1 == null or marker2 == null or marker3 == null:
		# Fallback to collision shape calculation if markers not found
		return calculate_ramp_trajectory_fallback(ramp, extinguisher_start_pos)
	
	# Get global positions of markers
	var marker1_pos: Vector2 = marker1.global_position
	var marker2_pos: Vector2 = marker2.global_position
	var marker3_pos: Vector2 = marker3.global_position
	
	# Trajectory: extinguisher start -> marker1 (ramp bottom) -> marker2 (ramp middle) -> marker3 (ramp top) -> launch off ramp
	var waypoints: Array[Vector2] = []
	waypoints.append(extinguisher_start_pos)  # Start at extinguisher position
	waypoints.append(marker1_pos)             # Move to ramp bottom
	waypoints.append(marker2_pos)             # Move up ramp (middle)
	waypoints.append(marker3_pos)             # Move to ramp top
	
	# Launch off ramp: continue trajectory beyond marker3 in the same direction
	var launch_direction: Vector2 = (marker3_pos - marker2_pos).normalized()
	var launch_vector: Vector2 = launch_direction * 200
	waypoints.append(marker3_pos + launch_vector)  # Fly off ramp
	
	return waypoints


func calculate_ramp_trajectory_fallback(ramp: AnimatedSprite2D, extinguisher_start_pos: Vector2) -> Array[Vector2]:
	# Get ramp collision shape for geometry
	var ramp_collision: CollisionShape2D = get_node_or_null("../PlacedRamp/CollisionShape2D") as CollisionShape2D
	if ramp_collision == null or ramp_collision.shape == null:
		return [extinguisher_start_pos]
	
	var rect_shape: RectangleShape2D = ramp_collision.shape as RectangleShape2D
	if rect_shape == null:
		return [extinguisher_start_pos]
	
	# Ramp collision rect in global coordinates
	var ramp_rect: Rect2 = rect_shape.get_rect()
	var ramp_global_pos: Vector2 = ramp_collision.global_position
	var ramp_top_left: Vector2 = ramp_global_pos + ramp_rect.position
	var ramp_bottom_right: Vector2 = ramp_top_left + ramp_rect.size
	
	# Ramp goes from bottom-left to top-right (sloping up-left to down-right visually)
	# But collision rect position is at (-39, 56) relative to ramp center (856, 374)
	# So ramp bottom-left ≈ (856-39-124, 374+56+70) = (693, 500)
	# Ramp top-right ≈ (856-39+124, 374+56-70) = (941, 360)
	
	var ramp_bottom_left: Vector2 = Vector2(ramp_top_left.x, ramp_bottom_right.y)
	var ramp_top_right: Vector2 = Vector2(ramp_bottom_right.x, ramp_top_left.y)
	
	# Trajectory: extinguisher start -> ramp bottom -> ramp top -> launch off ramp
	var waypoints: Array[Vector2] = []
	waypoints.append(extinguisher_start_pos)  # Start at extinguisher position (365, 470)
	waypoints.append(ramp_bottom_left)        # Move to ramp base
	waypoints.append(ramp_top_right)          # Move up ramp
	# Launch off ramp: continue trajectory beyond ramp top
	var launch_vector: Vector2 = (ramp_top_right - ramp_bottom_left).normalized() * 200
	waypoints.append(ramp_top_right + launch_vector)  # Fly off ramp
	
	return waypoints


func animate_extinguisher_along_path(extinguisher: AnimatedSprite2D, waypoints: Array[Vector2]) -> void:
	if waypoints.size() < 2:
		return
	
	# Total animation duration matching "rolling" animation: 8 frames @ 10fps = 0.8s
	# But we'll make it slightly longer for the full trajectory, say 1.5s
	var total_distance: float = 0.0
	for i in range(waypoints.size() - 1):
		total_distance += waypoints[i].distance_to(waypoints[i + 1])
	
	var total_duration: float = 1.5  # seconds
	
	var tween: Tween = create_tween()
	tween.set_parallel(false)  # Sequential
	
	for i in range(waypoints.size() - 1):
		var start_pos: Vector2 = waypoints[i]
		var end_pos: Vector2 = waypoints[i + 1]
		var segment_distance: float = start_pos.distance_to(end_pos)
		var segment_duration: float = (segment_distance / total_distance) * total_duration
		
		tween.tween_property(extinguisher, "global_position", end_pos, segment_duration)
	
	# After trajectory completes, hide extinguisher
	tween.tween_callback(hide_extinguisher.bind(extinguisher)).set_delay(0.1)


func hide_extinguisher(extinguisher: AnimatedSprite2D) -> void:
	if is_instance_valid(extinguisher):
		extinguisher.visible = false
		extinguisher.stop()
		InventoryData.placed_extinguisher_visible = false

func is_mouse_over_ramp(mouse_pos: Vector2) -> bool:
	var collision_shape: CollisionShape2D = get_node_or_null("../PlacedRamp/CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return false
	var rectangle: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rectangle == null:
		return false
	return rectangle.get_rect().has_point(collision_shape.to_local(mouse_pos))

func try_handle_arrow_click(mouse_pos: Vector2) -> bool:
	var right_arrow: Node = get_node_or_null("../RightArrow")
	if right_arrow != null and right_arrow is Sprite2D:
		var sprite: Sprite2D = right_arrow as Sprite2D
		if sprite.get_rect().has_point(sprite.to_local(mouse_pos)):
			get_tree().change_scene_to_file("res://mars_ground_2.tscn")
			return true

	var left_arrow: Node = get_node_or_null("../LeftArrow")
	if left_arrow != null and left_arrow is Sprite2D:
		var sprite: Sprite2D = left_arrow as Sprite2D
		if sprite.get_rect().has_point(sprite.to_local(mouse_pos)):
			get_tree().change_scene_to_file("res://mars_ground.tscn")
			return true

	return false

func try_pickup_pending_item() -> void:
	var item_name: String = pending_pickup_item_name
	pending_pickup_item_name = ""
	var item_node: Node = get_node_or_null("../" + item_name)
	if item_node == null or not item_node is Sprite2D:
		return
	var distance: float = global_position.distance_to(item_node.global_position)
	if distance > PICKUP_DISTANCE:
		return
	if InventoryData.add_item_by_node_name(item_name):
		item_node.queue_free()
		if inventory_ui != null:
			inventory_ui.refresh()

func _physics_process(_delta: float) -> void:
	if is_launching:
		return
	if nav_agent.is_navigation_finished():
		if pending_pickup_item_name != "":
			try_pickup_pending_item()
		if is_walking:
			is_walking = false
			animated_sprite.play("idle")
			velocity = Vector2.ZERO
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	var new_velocity: Vector2 = current_agent_position.direction_to(next_path_position) * speed
	velocity = new_velocity
	
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false

	if velocity.length() > 0 and not is_walking:
		is_walking = true
		animated_sprite.play("walk")

	move_and_slide()
