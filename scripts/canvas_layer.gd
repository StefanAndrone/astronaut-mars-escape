extends CanvasLayer

@export_file("*.json") var dialogue_file_path: String = "res://dialogues/d1.json"

var dialogue_lines: Array = []
var current_line_index: int = 0

@onready var astronaut_box: Panel = $AstronautBox
@onready var astronaut_label: RichTextLabel = $AstronautBox/MarginContainer/AstronautLabel

@onready var ai_box: Panel = $AIBox
@onready var ai_label: RichTextLabel = $AIBox/MarginContainer/AILabel

@onready var dialogue_timer: Timer = $DialogueTimer
@onready var full_screen_button: Button = $Button

func _ready() -> void:
	dialogue_timer.timeout.connect(_on_timer_timeout)
	full_screen_button.pressed.connect(_on_skip_button_pressed)
	
	setup_speech_style()
	setup_dynamic_labels()
	load_dialogue_from_file()
	
	show_line()

func setup_speech_style() -> void:
	var style_speech: StyleBoxFlat = StyleBoxFlat.new()
	style_speech.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	style_speech.set_corner_radius_all(8)
	style_speech.content_margin_left = 12
	style_speech.content_margin_top = 12
	style_speech.content_margin_right = 12
	style_speech.content_margin_bottom = 12

	for box: Panel in [astronaut_box, ai_box]:
		if box != null:
			box.add_theme_stylebox_override("panel", style_speech)
			var margin: MarginContainer = box.get_node_or_null("MarginContainer") as MarginContainer
			if margin != null:
				margin.add_theme_constant_override("margin_left", 12)
				margin.add_theme_constant_override("margin_top", 12)
				margin.add_theme_constant_override("margin_right", 12)
				margin.add_theme_constant_override("margin_bottom", 12)

func setup_dynamic_labels() -> void:
	for label: RichTextLabel in [astronaut_label, ai_label]:
		if label != null:
			label.bbcode_enabled = true
			label.fit_content = true
			label.scroll_active = false
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func load_dialogue_from_file() -> void:
	if not FileAccess.file_exists(dialogue_file_path):
		push_error("Dialogue file not found at path: " + dialogue_file_path)
		return
		
	var file = FileAccess.open(dialogue_file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error == OK:
		if json.data is Array:
			dialogue_lines = json.data
		else:
			push_error("JSON data structure is not an Array!")
	else:
		push_error("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())

func show_line() -> void:
	astronaut_box.hide()
	ai_box.hide()
	dialogue_timer.stop()
	
	if current_line_index >= dialogue_lines.size():
		end_dialogue()
		return
		
	var current_line = dialogue_lines[current_line_index]
	
	var formatted_text = "[color=black]" + current_line["text"] + "[/color]"
	
	if current_line["speaker"] == "Astronaut":
		astronaut_label.text = formatted_text
		adjust_box_size(astronaut_box, astronaut_label)
		astronaut_box.show()
	elif current_line["speaker"] == "AI":
		ai_label.text = formatted_text
		adjust_box_size(ai_box, ai_label)
		ai_box.show()
		
	dialogue_timer.start(current_line["duration"])

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

	# Fixed inner size for label and margin container
	label.custom_minimum_size = Vector2(target_width - 24.0, 0)
	
	var margin: MarginContainer = box.get_node_or_null("MarginContainer") as MarginContainer
	if margin != null:
		margin.anchor_right = 1.0
		margin.anchor_bottom = 1.0
		margin.offset_left = 0
		margin.offset_top = 0
		margin.offset_right = 0
		margin.offset_bottom = 0

	# Calculate required height based on wrapped lines
	var num_lines: int = ceil(line_width / (target_width - 30.0))
	var font_height: float = font.get_height(font_size)
	var estimated_height: float = (num_lines * font_height * 1.3) + 30.0
	var target_height: float = max(estimated_height, 60.0)

	box.custom_minimum_size = Vector2(target_width, target_height)
	box.size = Vector2(target_width, target_height)



func _on_skip_button_pressed() -> void:
	advance_dialogue()

func _on_timer_timeout() -> void:
	advance_dialogue()

func advance_dialogue() -> void:
	current_line_index += 1
	show_line()

func end_dialogue() -> void:
	astronaut_box.hide()
	ai_box.hide()
	get_tree().change_scene_to_file("res://mars_ground.tscn")
