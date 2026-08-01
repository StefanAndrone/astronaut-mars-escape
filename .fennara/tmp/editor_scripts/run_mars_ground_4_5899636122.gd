@tool
extends RefCounted

func run(ctx) -> void:
	var tex_mc: Texture2D = load("res://images/MC.png") as Texture2D
	ctx.log("MC.png: %s" % str(tex_mc))
	var tex_tile: Texture2D = load("res://images/MCTile.png") as Texture2D
	ctx.log("MCTile.png: %s" % str(tex_tile))
