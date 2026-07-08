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
	load_dialogue_from_file()
	
	show_line()
	
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
		astronaut_box.show()
	elif current_line["speaker"] == "AI":
		ai_label.text = formatted_text
		ai_box.show()
		
	dialogue_timer.start(current_line["duration"])

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
