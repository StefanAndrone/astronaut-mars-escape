class_name DialogueUI
extends CanvasLayer

signal dialogue_finished()

const BAR_HEIGHT: int = 125

var choice_panel: Panel
var choice_hbox: HBoxContainer
var choice_vbox: VBoxContainer
var choice_buttons: Array[Button] = []

var astronaut_box: Panel
var astronaut_label: RichTextLabel

var martian_box: Panel
var martian_label: RichTextLabel

var full_screen_button: Button
var dialogue_timer: Timer

var current_lines: Array = []
var current_line_idx: int = 0

func _init() -> void:
	layer = 15

func _ready() -> void:
	build_ui()

func build_ui() -> void:
	if choice_panel != null:
		return
		
	var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

	# Style for Speech Boxes (White rounded panels)
	var style_speech: StyleBoxFlat = StyleBoxFlat.new()
	style_speech.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	style_speech.set_corner_radius_all(8)
	style_speech.content_margin_left = 12
	style_speech.content_margin_top = 12
	style_speech.content_margin_right = 12
	style_speech.content_margin_bottom = 12

	# Style for Choice Panel (Covers Inventory Bar)
	var style_choice: StyleBoxFlat = StyleBoxFlat.new()
	style_choice.bg_color = Color(0.2, 0.2, 0.25, 0.98)
	style_choice.set_corner_radius_all(0)
	style_choice.content_margin_left = 20
	style_choice.content_margin_top = 10
	style_choice.content_margin_right = 20
	style_choice.content_margin_bottom = 10

	# 1. Choice Panel - positioned directly over inventory bar (bottom 125px)
	choice_panel = Panel.new()
	choice_panel.name = "ChoicePanel"
	choice_panel.add_theme_stylebox_override("panel", style_choice)
	choice_panel.position = Vector2(0, viewport_height - BAR_HEIGHT)
	choice_panel.size = Vector2(viewport_width, BAR_HEIGHT)
	add_child(choice_panel)

	choice_vbox = VBoxContainer.new()
	choice_vbox.name = "ChoiceVBox"
	choice_vbox.position = Vector2(40, 10)
	choice_vbox.size = Vector2(viewport_width - 80, BAR_HEIGHT - 20)
	choice_vbox.add_theme_constant_override("separation", 6)
	choice_panel.add_child(choice_vbox)

	choice_panel.hide()

	# 2. Astronaut Speech Box (Left of Landon, above inventory bar)
	astronaut_box = Panel.new()
	astronaut_box.name = "AstronautBox"
	astronaut_box.add_theme_stylebox_override("panel", style_speech)
	astronaut_box.position = Vector2(280, 100)
	astronaut_box.custom_minimum_size = Vector2(160, 60)
	astronaut_box.size = Vector2(280, 130)
	add_child(astronaut_box)

	var ast_margin: MarginContainer = MarginContainer.new()
	ast_margin.name = "MarginContainer"
	ast_margin.position = Vector2.ZERO
	ast_margin.size = Vector2(280, 130)
	ast_margin.add_theme_constant_override("margin_left", 12)
	ast_margin.add_theme_constant_override("margin_top", 12)
	ast_margin.add_theme_constant_override("margin_right", 12)
	ast_margin.add_theme_constant_override("margin_bottom", 12)
	astronaut_box.add_child(ast_margin)

	astronaut_label = RichTextLabel.new()
	astronaut_label.name = "AstronautLabel"
	astronaut_label.bbcode_enabled = true
	astronaut_label.fit_content = true
	astronaut_label.scroll_active = false
	astronaut_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	astronaut_label.add_theme_color_override("default_color", Color.BLACK)
	astronaut_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ast_margin.add_child(astronaut_label)

	astronaut_box.hide()

	# 3. Martian Speech Box (Above the Astronaut and to the left of the Martian)
	martian_box = Panel.new()
	martian_box.name = "MartianBox"
	martian_box.add_theme_stylebox_override("panel", style_speech)
	martian_box.position = Vector2(600, 100)
	martian_box.custom_minimum_size = Vector2(160, 60)
	martian_box.size = Vector2(280, 130)
	add_child(martian_box)

	var mar_margin: MarginContainer = MarginContainer.new()
	mar_margin.name = "MarginContainer"
	mar_margin.position = Vector2.ZERO
	mar_margin.size = Vector2(280, 130)
	mar_margin.add_theme_constant_override("margin_left", 12)
	mar_margin.add_theme_constant_override("margin_top", 12)
	mar_margin.add_theme_constant_override("margin_right", 12)
	mar_margin.add_theme_constant_override("margin_bottom", 12)
	martian_box.add_child(mar_margin)

	martian_label = RichTextLabel.new()
	martian_label.name = "MartianLabel"
	martian_label.bbcode_enabled = true
	martian_label.fit_content = true
	martian_label.scroll_active = false
	martian_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	martian_label.add_theme_color_override("default_color", Color.BLACK)
	martian_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mar_margin.add_child(martian_label)

	martian_box.hide()

	# 4. Full screen invisible button to click anywhere to advance dialogue
	full_screen_button = Button.new()
	full_screen_button.name = "FullScreenButton"
	full_screen_button.position = Vector2.ZERO
	full_screen_button.size = Vector2(viewport_width, viewport_height)
	full_screen_button.flat = true
	full_screen_button.pressed.connect(_on_full_screen_pressed)
	add_child(full_screen_button)
	full_screen_button.hide()

	# 5. Dialogue Timer for automatic advancing
	dialogue_timer = Timer.new()
	dialogue_timer.name = "DialogueTimer"
	dialogue_timer.one_shot = true
	dialogue_timer.timeout.connect(_on_timer_timeout)
	add_child(dialogue_timer)

func show_choices(choices: Array[String], callback: Callable) -> void:
	build_ui()
	astronaut_box.hide()
	martian_box.hide()
	full_screen_button.hide()
	dialogue_timer.stop()

	for btn: Button in choice_buttons:
		btn.queue_free()
	choice_buttons.clear()

	for i: int in range(choices.size()):
		var choice_text: String = choices[i]
		var btn: Button = Button.new()
		btn.text = choice_text
		btn.add_theme_font_size_override("font_size", 15)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func():
			choice_panel.hide()
			callback.call(i)
		)
		choice_vbox.add_child(btn)
		choice_buttons.append(btn)

	choice_panel.show()

func start_dialogue_from_json(json_path: String) -> void:
	if not FileAccess.file_exists(json_path):
		push_error("Dialogue file not found at: " + json_path)
		return
	var file: FileAccess = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		push_error("Failed opening dialogue file at: " + json_path)
		return
	var text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var err: Error = json.parse(text)
	if err == OK and json.data is Array:
		start_dialogue(json.data)
	else:
		push_error("JSON Parse Error for dialogue at: " + json_path)

func start_dialogue(lines: Array) -> void:
	build_ui()
	choice_panel.hide()
	current_lines = lines
	current_line_idx = 0
	full_screen_button.show()
	show_line()

func show_line() -> void:
	astronaut_box.hide()
	martian_box.hide()
	dialogue_timer.stop()

	if current_line_idx >= current_lines.size():
		end_dialogue()
		return

	var current_line: Dictionary = current_lines[current_line_idx]
	var formatted_text: String = "[color=black]" + current_line.get("text", "") + "[/color]"
	var speaker: String = current_line.get("speaker", "")

	if speaker == "Astronaut":
		astronaut_label.text = formatted_text
		adjust_box_size(astronaut_box, astronaut_label)
		astronaut_box.show()
	elif speaker == "Martian":
		martian_label.text = formatted_text
		adjust_box_size(martian_box, martian_label)
		martian_box.show()

	var duration: float = float(current_line.get("duration", 4.0))
	dialogue_timer.start(duration)

func adjust_box_size(box: Panel, label: RichTextLabel) -> void:
	var max_width: float = 280.0
	var font: Font = label.get_theme_font("normal_font")
	var font_size: int = label.get_theme_font_size("normal_font_size")
	if font == null:
		font = ThemeDB.fallback_font
	if font_size <= 0:
		font_size = ThemeDB.fallback_font_size

	var raw_text: String = label.text.replacen("[color=black]", "").replacen("[/color]", "")
	var line_width: float = font.get_string_size(raw_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var target_width: float = clamp(line_width + 40.0, 180.0, max_width)

	label.custom_minimum_size = Vector2(target_width - 24.0, 0)
	
	var margin: MarginContainer = box.get_node_or_null("MarginContainer") as MarginContainer
	if margin != null:
		margin.anchor_right = 1.0
		margin.anchor_bottom = 1.0
		margin.offset_left = 0
		margin.offset_top = 0
		margin.offset_right = 0
		margin.offset_bottom = 0

	var num_lines: int = ceil(line_width / (target_width - 30.0))
	var font_height: float = font.get_height(font_size)
	var estimated_height: float = (num_lines * font_height * 1.3) + 30.0
	var target_height: float = max(estimated_height, 60.0)

	box.custom_minimum_size = Vector2(target_width, target_height)
	box.size = Vector2(target_width, target_height)


func _on_full_screen_pressed() -> void:
	advance_dialogue()

func _on_timer_timeout() -> void:
	advance_dialogue()

func advance_dialogue() -> void:
	current_line_idx += 1
	show_line()

func end_dialogue() -> void:
	astronaut_box.hide()
	martian_box.hide()
	full_screen_button.hide()
	dialogue_timer.stop()
	dialogue_finished.emit()
