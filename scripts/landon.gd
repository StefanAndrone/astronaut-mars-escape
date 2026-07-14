extends CharacterBody2D
class_name Landon

@export var speed: float = 200.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_walking: bool = false
var inventory_ui: InventoryUI = null
var pending_pickup_item_name: String = ""

const PICKUP_DISTANCE: float = 120.0

func _ready() -> void:
	animated_sprite.play("idle")
	remove_already_picked_items()
	hide_legacy_inventory_bar()
	ensure_inventory_ui()

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

func _unhandled_input(event: InputEvent) -> void:
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
