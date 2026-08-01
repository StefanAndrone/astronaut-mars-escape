@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return

	var left_arrow: Sprite2D = root.get_node_or_null("LeftArrow") as Sprite2D
	if left_arrow != null:
		left_arrow.position = Vector2(66, 439)
		ctx.mark_modified()
		ctx.log("Updated LeftArrow position in " + ctx.get_scene_path())
