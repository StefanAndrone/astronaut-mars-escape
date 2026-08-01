@tool
extends RefCounted

func run(ctx) -> void:
	var mc_tex: Texture2D = load("res://images/MC.png") as Texture2D
	if mc_tex != null:
		ctx.log("MC.png size: %s" % str(mc_tex.get_size()))
	var mc_tile: Texture2D = load("res://images/MCTile.png") as Texture2D
	if mc_tile != null:
		ctx.log("MCTile.png size: %s" % str(mc_tile.get_size()))
