@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return

	var nice_martian: AnimatedSprite2D = root.get_node_or_null("NiceMartian") as AnimatedSprite2D
	if nice_martian == null:
		nice_martian = AnimatedSprite2D.new()
		nice_martian.name = "NiceMartian"
		nice_martian.position = Vector2(850, 330)
		nice_martian.scale = Vector2(1.5, 1.552)
		nice_martian.flip_h = true

		var texture: Texture2D = load("res://images/martian.png") as Texture2D
		var sf: SpriteFrames = SpriteFrames.new()
		sf.add_animation("idle")
		sf.set_animation_loop("idle", true)
		sf.set_animation_speed("idle", 5.0)

		var atlas_tex: AtlasTexture = AtlasTexture.new()
		atlas_tex.atlas = texture
		atlas_tex.region = Rect2(0, 0, 125, 250)
		sf.add_frame("idle", atlas_tex)

		nice_martian.sprite_frames = sf
		nice_martian.animation = &"idle"
		nice_martian.autoplay = "idle"

		root.add_child(nice_martian)
		ctx.own(nice_martian)
		ctx.mark_modified()
		ctx.log("Added NiceMartian to mars_ground_4.tscn")
