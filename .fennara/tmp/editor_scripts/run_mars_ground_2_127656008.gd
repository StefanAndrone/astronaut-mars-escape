@tool
extends RefCounted

func run(ctx) -> void:
	# Add RightArrow to mars_ground_2.tscn
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return

	var right_arrow: Sprite2D = root.get_node_or_null("RightArrow") as Sprite2D
	if right_arrow == null:
		right_arrow = Sprite2D.new()
		right_arrow.name = "RightArrow"
		right_arrow.texture = load("res://images/arrow.png")
		right_arrow.position = Vector2(1100.9999, 439.00006)
		right_arrow.scale = Vector2(0.14264911, 0.1487604)
		root.add_child(right_arrow)
		ctx.own(right_arrow)
		ctx.mark_modified()
		ctx.log("Added RightArrow to mars_ground_2.tscn")
