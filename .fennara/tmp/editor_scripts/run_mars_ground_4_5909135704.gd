@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	var nav_reg: NavigationRegion2D = root.get_node_or_null("NavigationRegion2D") as NavigationRegion2D
	if nav_reg != null and nav_reg.navigation_polygon != null:
		var poly: NavigationPolygon = nav_reg.navigation_polygon
		for i in range(poly.get_outline_count()):
			ctx.log("Outline %d: %s" % [i, str(poly.get_outline(i))])
