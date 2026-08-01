@tool
extends RefCounted

func run(ctx) -> void:
	var img: Image = load("res://images/MC.png").get_image()
	var rect: Rect2i = img.get_used_rect()
	ctx.log("MC used rect: %s" % str(rect))
	var img_tile: Image = load("res://images/MCTile.png").get_image()
	var rect_tile: Rect2i = img_tile.get_used_rect()
	ctx.log("MCTile used rect: %s" % str(rect_tile))
