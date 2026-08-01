@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return

	var down_arrow: Sprite2D = root.get_node_or_null("DownArrow") as Sprite2D
	if down_arrow != null:
		down_arrow.position = Vector2(576, 480)
		ctx.mark_modified()
		ctx.log("Repositioned DownArrow to Vector2(576, 480)")
