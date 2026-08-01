@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return

	var arrow_tex: Texture2D = load("res://images/arrow.png") as Texture2D

	# Check / add RightArrow
	var right_arrow: Sprite2D = root.get_node_or_null("RightArrow") as Sprite2D
	if right_arrow == null:
		right_arrow = Sprite2D.new()
		right_arrow.name = "RightArrow"
		right_arrow.texture = arrow_tex
		right_arrow.position = Vector2(1101, 439)
		right_arrow.scale = Vector2(0.14264911, 0.1487604)
		root.add_child(right_arrow)
		ctx.own(right_arrow)

	# Check / add DownArrow
	var down_arrow: Sprite2D = root.get_node_or_null("DownArrow") as Sprite2D
	if down_arrow == null:
		down_arrow = Sprite2D.new()
		down_arrow.name = "DownArrow"
		down_arrow.texture = arrow_tex
		down_arrow.position = Vector2(576, 600)
		down_arrow.scale = Vector2(0.14264911, 0.1487604)
		down_arrow.rotation_degrees = 90.0
		root.add_child(down_arrow)
		ctx.own(down_arrow)

	ctx.mark_modified()
	ctx.log("Updated mars_ground_3.tscn with RightArrow and DownArrow")
