class_name InventoryUI
extends CanvasLayer

const SLOT_COUNT: int = 10
const SLOT_SIZE: int = 64
const SLOT_SPACING: int = 8
const BAR_HEIGHT: int = 125

var slots: Array[TextureRect] = []
var slot_backgrounds: Array[ColorRect] = []
var selection_highlight: ColorRect
var tooltip: Label
var selected_slot: int = -1

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

	tooltip = Label.new()
	tooltip.name = "ItemTooltip"
	tooltip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip.add_theme_color_override("font_color", Color.WHITE)
	tooltip.add_theme_color_override("font_shadow_color", Color.BLACK)
	tooltip.add_theme_constant_override("shadow_offset_x", 2)
	tooltip.add_theme_constant_override("shadow_offset_y", 2)
	tooltip.hide()
	bar.add_child(tooltip)

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
		slot_backgrounds.append(slot_bg)

		var slot: TextureRect = TextureRect.new()
		slot.name = "Slot%d" % i
		slot.position = Vector2.ZERO
		slot.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.gui_input.connect(_on_slot_gui_input.bind(i))
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(i))
		slot.mouse_exited.connect(_on_slot_mouse_exited.bind(i))
		slot_bg.add_child(slot)
		slots.append(slot)

		var highlight: ColorRect = ColorRect.new()
		highlight.name = "SelectionHighlight%d" % i
		highlight.position = Vector2.ZERO
		highlight.size = Vector2(SLOT_SIZE, SLOT_SIZE)
		highlight.color = Color(1.0, 0.85, 0.1, 0.35)
		highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		highlight.hide()
		slot_bg.add_child(highlight)
		if selection_highlight == null:
			selection_highlight = highlight

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if InventoryData.slots[slot_index] == null:
			clear_selection()
		else:
			select_slot(slot_index)
		get_viewport().set_input_as_handled()

func _on_slot_mouse_entered(slot_index: int) -> void:
	var item: ItemData = InventoryData.slots[slot_index]
	if item == null:
		return
	tooltip.text = item.display_name
	tooltip.position = slot_backgrounds[slot_index].position + Vector2(0, -30)
	tooltip.show()

func _on_slot_mouse_exited(_slot_index: int) -> void:
	tooltip.hide()

func select_slot(slot_index: int) -> void:
	clear_selection()
	selected_slot = slot_index
	var highlight: ColorRect = slot_backgrounds[slot_index].get_node("SelectionHighlight%d" % slot_index)
	highlight.show()

func clear_selection() -> void:
	if selected_slot == -1:
		return
	var highlight: ColorRect = slot_backgrounds[selected_slot].get_node("SelectionHighlight%d" % selected_slot)
	highlight.hide()
	selected_slot = -1

func get_selected_item() -> ItemData:
	if selected_slot < 0 or selected_slot >= InventoryData.MAX_SLOTS:
		return null
	return InventoryData.slots[selected_slot]

func consume_selected_item() -> bool:
	if selected_slot < 0:
		return false
	var consumed: ItemData = InventoryData.remove_item_at(selected_slot)
	if consumed == null:
		clear_selection()
		return false
	clear_selection()
	refresh()
	return true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clear_selection()

func refresh() -> void:
	if slots.size() == 0:
		return
	for i: int in range(SLOT_COUNT):
		if i >= slots.size():
			return
		var item: ItemData = InventoryData.slots[i]
		if item == null:
			slots[i].texture = null
			if selected_slot == i:
				clear_selection()
			continue
		if item.icon_path.is_empty():
			slots[i].texture = null
		else:
			slots[i].texture = load(item.icon_path)
