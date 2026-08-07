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
var is_frozen: bool = false

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

func freeze() -> void:
	is_frozen = true
	clear_selection()
	if is_instance_valid(tooltip):
		tooltip.hide()

func _on_slot_gui_input(event: InputEvent, slot_index: int) -> void:
	if is_frozen:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var previously_selected_slot: int = selected_slot
		var clicked_item: ItemData = InventoryData.slots[slot_index]
		
		if clicked_item == null:
			clear_selection()
		else:
			# Check if using selected item on another inventory slot
			if previously_selected_slot != -1 and previously_selected_slot != slot_index:
				var selected_item: ItemData = InventoryData.slots[previously_selected_slot]
				if selected_item != null:
					# Combine Chewed Gum or Chewing Gum with Mechanical Glove
					var is_gum: bool = (selected_item.item_id == "chewed_gum" or selected_item.item_id == "chewing_gum" or clicked_item.item_id == "chewed_gum" or clicked_item.item_id == "chewing_gum")
					var is_glove: bool = (selected_item.item_id == "mechanical_glove" or clicked_item.item_id == "mechanical_glove")
					if is_gum and is_glove:
						var sticky_glove: ItemData = InventoryData.ITEM_DEFINITIONS.get("StickyPunchglove")
						if sticky_glove != null:
							# Set target slot to Sticky Punchglove and empty source slot
							InventoryData.slots[previously_selected_slot] = null
							InventoryData.slots[slot_index] = sticky_glove
							clear_selection()
							refresh()
							var vp_handled: Viewport = get_viewport()
							if vp_handled != null:
								vp_handled.set_input_as_handled()
							return

			select_slot(slot_index)
			if clicked_item.item_id == "chewing_gum":
				consume_selected_item()
				var chewed_item: ItemData = InventoryData.ITEM_DEFINITIONS.get("ChewedGum")
				if chewed_item != null:
					InventoryData.slots[slot_index] = chewed_item
					refresh()
				var landon: Node = get_tree().current_scene.get_node_or_null("Landon")
				if landon != null and landon.has_method("ensure_dialogue_ui"):
					var dui: DialogueUI = landon.call("ensure_dialogue_ui") as DialogueUI
					if dui != null:
						dui.start_dialogue([
							{"speaker": "Astronaut", "text": "That gum was so tasty!", "duration": 3.0}
						])
		var vp: Viewport = get_viewport()
		if vp != null:
			vp.set_input_as_handled()

func _on_slot_mouse_entered(slot_index: int) -> void:
	if is_frozen:
		return
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

func _unhandled_input(_event: InputEvent) -> void:
	pass

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
