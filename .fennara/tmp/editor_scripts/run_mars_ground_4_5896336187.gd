@tool
extends RefCounted

func run(ctx) -> void:
	var img: Image = load("res://images/MCTile.png").get_image()
	ctx.log("MCTile dimensions: %dx%d" % [img.get_width(), img.get_height()])
	var img_mc: Image = load("res://images/MC.png").get_image()
	ctx.log("MC dimensions: %dx%d" % [img_mc.get_width(), img_mc.get_height()])
