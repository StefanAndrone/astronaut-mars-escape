class_name InventoryUI
extends CanvasLayer

const SLOT_COUNT: int = 10
const SLOT_SIZE: int = 64
const SLOT_SPACING: int = 8
const BAR_HEIGHT: int = 125

var slots: Array[TextureRect] = []

func _init() -> void:
	layer = 10

func _ready() -> void:
	build_ui()
	refresh()

func build_ui() -> void:
	if slots.size() > 0:
		return
	var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var viewport_size: Vector2 = Vector2(viewport_width, viewport_height)
	var bar: ColorRect = ColorRect.new()
	bar.name = "InventoryBar"
	bar.position = Vector2(0, viewport_size.y - BAR_HEIGHT)
	bar.size = Vector2(viewport_size.x, BAR_HEIGHT)
	bar.color = Color(0.35, 0.35, 0.35, 1.0)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bar)

	var total_width: float = SLOT_COUNT * SLOT_SIZE + (SLOT_COUNT - 1) * SLOT_SPACING
	var start_x: float = (viewport_size.x - total_width) / 2.0
	var start_y: float = (BAR_HEIGHT - SLOT_SIZE) / 2.0

	for i: int in range(SLOT_COUNT):
		var slot_bg: ColorRect = ColorRect.new()
		slot_bg.name = "SlotBg%d" % i
		slot_bg.position = Vector2(start_x + i * (SLOT_SIZE + SLOT_SPACING), start_y)
		slot_bg.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot_bg.color = Color(0.1, 0.1, 0.1, 1.0)
		slot_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_child(slot_bg)

		var slot: TextureRect = TextureRect.new()
		slot.name = "Slot%d" % i
		slot.position = Vector2.ZERO
		slot.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_bg.add_child(slot)
		slots.append(slot)

func refresh() -> void:
	if slots.size() == 0:
		return
	for i: int in range(SLOT_COUNT):
		if i >= slots.size():
			return
		var item: ItemData = InventoryData.slots[i]
		if item == null:
			slots[i].texture = null
			continue
		if item.icon_path.is_empty():
			slots[i].texture = null
		else:
			slots[i].texture = load(item.icon_path)
