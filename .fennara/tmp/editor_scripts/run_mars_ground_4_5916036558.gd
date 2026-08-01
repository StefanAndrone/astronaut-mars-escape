@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return

	var old_martian: Node = root.get_node_or_null("NiceMartian")
	if old_martian != null:
		old_martian.name = "OldNiceMartian"
		old_martian.queue_free()

	var mc_tex: Texture2D = load("res://images/MC.png") as Texture2D
	var nice_martian: Sprite2D = Sprite2D.new()
	nice_martian.name = "NiceMartian"
	nice_martian.texture = mc_tex
	nice_martian.position = Vector2(850, 480)
	nice_martian.scale = Vector2(0.35, 0.35)

	root.add_child(nice_martian)
	ctx.own(nice_martian)

	ctx.mark_modified()
	ctx.log("Updated NiceMartian in mars_ground_4.tscn with MC.png at Vector2(850, 480)")
