@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node2D = Node2D.new()
	root.name = "MarsGround3"
	ctx.set_scene_root(root)

	# 1. Background Sprite2D
	var bg: Sprite2D = Sprite2D.new()
	bg.name = "Sprite2D"
	bg.texture = load("res://images/Mars Ground.png")
	bg.position = Vector2(612.25, 323)
	bg.scale = Vector2(0.500408, 0.501543)
	root.add_child(bg)
	ctx.own(bg)

	# 2. LeftArrow
	var left_arrow: Sprite2D = Sprite2D.new()
	left_arrow.name = "LeftArrow"
	left_arrow.texture = load("res://images/arrow.png")
	left_arrow.position = Vector2(66, 479)
	left_arrow.scale = Vector2(0.14264911, 0.1487604)
	left_arrow.flip_h = true
	root.add_child(left_arrow)
	ctx.own(left_arrow)

	# 3. NavigationRegion2D
	var nav_region: NavigationRegion2D = NavigationRegion2D.new()
	nav_region.name = "NavigationRegion2D"
	var nav_poly: NavigationPolygon = NavigationPolygon.new()
	var outline: PackedVector2Array = PackedVector2Array([
		Vector2(-10, 380),
		Vector2(1250, 380),
		Vector2(1250, 580),
		Vector2(-10, 580)
	])
	nav_poly.add_outline(outline)
	nav_poly.make_polygons_from_outlines()
	nav_region.navigation_polygon = nav_poly
	root.add_child(nav_region)
	ctx.own(nav_region)

	# 4. Landon (CharacterBody2D)
	var landon: CharacterBody2D = CharacterBody2D.new()
	landon.name = "Landon"
	landon.script = load("res://scripts/landon.gd")
	landon.position = Vector2(90, 450)
	root.add_child(landon)
	ctx.own(landon)

	# Landon children: AnimatedSprite2D
	var anim_sprite: AnimatedSprite2D = AnimatedSprite2D.new()
	anim_sprite.name = "AnimatedSprite2D"
	anim_sprite.position = Vector2(0, -120)
	anim_sprite.scale = Vector2(0.686812, 0.679688)

	var mc_tex: Texture2D = load("res://images/MCTile.png")
	var sf: SpriteFrames = SpriteFrames.new()
	sf.add_animation("idle")
	sf.set_animation_speed("idle", 5)
	sf.set_animation_loop("idle", true)
	var idle_atlas: AtlasTexture = AtlasTexture.new()
	idle_atlas.atlas = mc_tex
	idle_atlas.region = Rect2(778, 10, 243, 505)
	sf.add_frame("idle", idle_atlas)

	sf.add_animation("walk")
	sf.set_animation_speed("walk", 12)
	sf.set_animation_loop("walk", true)
	var walk_regions: Array[Rect2] = [
		Rect2(37, 10, 243, 505),
		Rect2(284, 10, 243, 505),
		Rect2(531, 10, 243, 505),
		Rect2(37, 519, 243, 505),
		Rect2(284, 519, 243, 505),
		Rect2(531, 519, 243, 505)
	]
	for reg in walk_regions:
		var w_atlas: AtlasTexture = AtlasTexture.new()
		w_atlas.atlas = mc_tex
		w_atlas.region = reg
		sf.add_frame("walk", w_atlas)

	anim_sprite.sprite_frames = sf
	anim_sprite.animation = &"idle"
	landon.add_child(anim_sprite)
	ctx.own(anim_sprite)

	# Landon children: NavigationAgent2D
	var nav_agent: NavigationAgent2D = NavigationAgent2D.new()
	nav_agent.name = "NavigationAgent2D"
	landon.add_child(nav_agent)
	ctx.own(nav_agent)

	# Landon children: CollisionShape2D
	var col_shape: CollisionShape2D = CollisionShape2D.new()
	col_shape.name = "CollisionShape2D"
	col_shape.position = Vector2(0, -120)
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = Vector2(119.5, 317.5)
	col_shape.shape = rect_shape
	landon.add_child(col_shape)
	ctx.own(col_shape)

	ctx.log("Successfully created mars_ground_3.tscn")
	ctx.mark_modified()
