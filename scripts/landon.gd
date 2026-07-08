extends CharacterBody2D

@export var speed: float = 200.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_walking: bool = false

func _ready() -> void:
	animated_sprite.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		nav_agent.target_position = get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	if nav_agent.is_navigation_finished():
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
