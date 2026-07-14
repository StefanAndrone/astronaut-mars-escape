class_name ItemData
extends RefCounted

var item_id: String
var display_name: String
var icon_path: String

func _init(id: String, name: String, icon: String) -> void:
	item_id = id
	display_name = name
	icon_path = icon
