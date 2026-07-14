class_name InventoryData
extends RefCounted

const MAX_SLOTS: int = 10

static var slots: Array[ItemData] = []
static var picked_item_ids: Dictionary = {}

static var ITEM_DEFINITIONS: Dictionary = {
	"FireExtinguisher": ItemData.new("fire_extinguisher", "Fire Extinguisher", "res://images/fire extinguisher.png"),
	"TallChair": ItemData.new("tall_chair", "Tall Chair", "res://images/tall chair.png"),
	"RemoteForGlove": ItemData.new("remote_for_glove", "Remote for Glove", "res://images/remote for glove.png")
}

static func _static_init() -> void:
	slots.resize(MAX_SLOTS)
	for i: int in range(MAX_SLOTS):
		slots[i] = null

static func find_first_empty_slot() -> int:
	for i: int in range(MAX_SLOTS):
		if slots[i] == null:
			return i
	return -1

static func add_item_by_node_name(node_name: String) -> bool:
	if not ITEM_DEFINITIONS.has(node_name):
		return false
	var item: ItemData = ITEM_DEFINITIONS[node_name]
	if picked_item_ids.has(item.item_id):
		return false
	var slot: int = find_first_empty_slot()
	if slot == -1:
		return false
	slots[slot] = item
	picked_item_ids[item.item_id] = true
	return true

static func has_item(item_id: String) -> bool:
	return picked_item_ids.has(item_id)
