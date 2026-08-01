class_name InventoryData
extends RefCounted

const MAX_SLOTS: int = 10

static var slots: Array[ItemData] = []
static var picked_item_ids: Dictionary = {}
static var placed_ramp_visible: bool = false
static var placed_ramp_animation: StringName = &"with ground"
static var placed_punchglove_visible: bool = false
static var placed_extinguisher_visible: bool = false
static var extinguisher_launched: bool = false
static var martian_defeated: bool = false

static var ITEM_DEFINITIONS: Dictionary = {
	"FireExtinguisher": ItemData.new("fire_extinguisher", "Fire Extinguisher", "res://images/fire extinguisher.png"),
	"TallChair": ItemData.new("tall_chair", "Tall Chair", "res://images/tall chair.png"),
	"RemoteForGlove": ItemData.new("remote_for_glove", "Remote for Glove", "res://images/remote for glove.png"),
	"MechanicalGlove": ItemData.new("mechanical_glove", "Mechanical Glove", "res://images/mechanical glove.png"),
	"FlowerVase": ItemData.new("flower_vase", "Flower Vase", "res://images/flower vase.png")
}

static func _static_init() -> void:
	slots.resize(MAX_SLOTS)
	for i: int in range(MAX_SLOTS):
		slots[i] = null
	extinguisher_launched = false

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

static func return_item_to_inventory(node_name: String) -> bool:
	if not ITEM_DEFINITIONS.has(node_name):
		return false
	var item: ItemData = ITEM_DEFINITIONS[node_name]
	var slot: int = find_first_empty_slot()
	if slot == -1:
		return false
	slots[slot] = item
	picked_item_ids[item.item_id] = true
	return true

static func return_item_by_id(item_id: String) -> bool:
	var target_item: ItemData = null
	for item_name: String in ITEM_DEFINITIONS.keys():
		var def: ItemData = ITEM_DEFINITIONS[item_name]
		if def.item_id == item_id:
			target_item = def
			break
	if target_item == null:
		return false
	var slot: int = find_first_empty_slot()
	if slot == -1:
		return false
	slots[slot] = target_item
	picked_item_ids[item_id] = true
	return true

static func has_item(item_id: String) -> bool:
	return picked_item_ids.has(item_id)

static func remove_item_at(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return null
	var item: ItemData = slots[slot_index]
	if item == null:
		return null
	slots[slot_index] = null
	return item
