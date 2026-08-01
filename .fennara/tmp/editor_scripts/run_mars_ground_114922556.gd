@tool
extends RefCounted

func run(ctx) -> void:
	var root: Node = ctx.get_scene_root()
	if root == null:
		ctx.error("Root is null")
		return
	
	var nav_region: NavigationRegion2D = root.get_node_or_null("NavigationRegion2D") as NavigationRegion2D
	if nav_region != null:
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
		ctx.log("Updated NavigationRegion2D in " + ctx.get_scene_path())
		ctx.mark_modified()
