@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Scene root not found")
		return

	var rect: ColorRect = ColorRect.new()
	rect.name = "GreenRectangle"
	rect.color = Color(0.0, 1.0, 0.0, 1.0)
	rect.size = Vector2(100, 100)
	rect.position = Vector2(0, 0)

	root.add_child(rect)
	ctx.own(rect)
	ctx.mark_modified()
	ctx.log("Added GreenRectangle to mars_ground.tscn")
