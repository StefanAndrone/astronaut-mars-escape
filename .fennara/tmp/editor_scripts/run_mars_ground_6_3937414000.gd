@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node2D = Node2D.new()
	root.name = "MarsGround6"
	ctx.set_scene_root(root)

	var bg_tex: Texture2D = load("res://images/Mars Ground.png") as Texture2D
	var arrow_tex: Texture2D = load("res://images/arrow.png") as Texture2D

	var bg: Sprite2D = Sprite2D.new()
	bg.name = "Sprite2D"
	bg.texture = bg_tex
	bg.position = Vector2(576, 324)
	bg.scale = Vector2(0.6, 0.6)
	root.add_child(bg)
	ctx.own(bg)

	var up_arrow: Sprite2D = Sprite2D.new()
	up_arrow.name = "UpArrow"
	up_arrow.texture = arrow_tex
	up_arrow.position = Vector2(576, 60)
	up_arrow.scale = Vector2(0.14264911, 0.1487604)
	up_arrow.rotation_degrees = -90.0
	root.add_child(up_arrow)
	ctx.own(up_arrow)

	# Copy NavigationRegion2D and Landon from mars_ground_3.tscn
	var mg3: PackedScene = load("res://mars_ground_3.tscn") as PackedScene
	if mg3 != null:
		var inst: Node = mg3.instantiate()
		var nav: Node = inst.get_node_or_null("NavigationRegion2D")
		if nav != null:
			var nav_dup: Node = nav.duplicate()
			root.add_child(nav_dup)
			ctx.own(nav_dup)
		var landon: Node = inst.get_node_or_null("Landon")
		if landon != null:
			var landon_dup: Node = landon.duplicate()
			root.add_child(landon_dup)
			_own_subtree(ctx, landon_dup)
		inst.queue_free()

	ctx.mark_modified()
	ctx.log("Created mars_ground_6.tscn")

func _own_subtree(ctx, node: Node) -> void:
	ctx.own(node)
	for c in node.get_children():
		_own_subtree(ctx, c)
