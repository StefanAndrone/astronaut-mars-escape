extends Node2D

@onready var landon: CharacterBody2D = $Landon
@onready var placed_extinguisher: AnimatedSprite2D = $PlacedExtinguisher
@onready var start_marker: Marker2D = $PlacedExtinguisher/Start
@onready var middle_marker: Marker2D = $PlacedExtinguisher/Marker2D
@onready var end_marker: Marker2D = $PlacedExtinguisher/End

func _ready() -> void:
	# Check if we should start the extinguisher animation (triggered from mars_ground)
	if InventoryData.extinguisher_launched:
		# Hide Landon - he stayed behind pressing the remote
		# Use call_deferred to ensure this runs after Landon's own _ready()
		call_deferred("_hide_landon")
		
		# Animate extinguisher straight to the martian
		animate_extinguisher_to_martian()
		
		# Reset the flag so it doesn't animate again on scene reload
		InventoryData.extinguisher_launched = false
	else:
		# Extinguisher not launched yet - Landon should be visible and active
		# (scene defaults handle this, but ensure it's set)
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
	
	# After reaching martian's head, stop animation (don't hide - it hit the martian!)
	tween.tween_callback(stop_extinguisher.bind(placed_extinguisher)).set_delay(0.2)


func stop_extinguisher(extinguisher: AnimatedSprite2D) -> void:
	if is_instance_valid(extinguisher):
		extinguisher.stop()
		# Keep visible at martian position - it hit the martian!
