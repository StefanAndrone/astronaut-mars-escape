# Dialogue Box Implementation

## Child Nodes

```
MarginContainer
├── Label (NameLabel)
├── RichTextLabel (TextLabel)
└── Timer (AutoTimer, timeout: 3.0, one_shot: true)
```

## Dialogue JSON File (dialogue.json)

```json
{
  "lines": [
    {"name": "Landon", "text": "Th-that ship... it's not right...", "mood": "scared"},
    {"name": "AI", "text": "Analysis: Structural integrity at 12%. We are in danger.", "mood": "normal"},
    {"name": "Landon", "text": "W-we need to move. Now.", "mood": "scared"}
  ]
}
```

## Script

```gdscript
@export var auto_advance_time: float = 3.0
@export var dialogue_file: String = "res://dialogue.json"

signal dialogue_finished

var dialogue: Array = []
var current_line: int = 0

func _ready():
    visible = false
    $Timer.wait_time = auto_advance_time
    $Timer.timeout.connect(_on_auto_advance)
    load_dialogue()

func load_dialogue():
    var file = FileAccess.open(dialogue_file, FileAccess.READ)
    if file:
        var json = JSON.new()
        var error = json.parse(file.get_as_text())
        if error == OK:
            var data = json.get_data()
            dialogue = data.get("lines", [])
        file.close()

func start():
    current_line = 0
    visible = true
    show_line()
    $Timer.start()

func show_line():
    if current_line >= dialogue.size():
        finish()
        return
    
    var line = dialogue[current_line]
    $MarginContainer/NameLabel.text = line.get("name", "")
    
    if line.get("mood", "") == "scared":
        $MarginContainer/TextLabel.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
        $MarginContainer/TextLabel.text = "..." + line["text"] + "..."
    else:
        $MarginContainer/TextLabel.add_theme_color_override("font_color", Color(1, 1, 1))
        $MarginContainer/TextLabel.text = line["text"]
    
    $Timer.start()

func _on_auto_advance():
    next_line()

func _input(event):
    if event is InputEventMouseButton and event.pressed and visible:
        next_line()
        $Timer.stop()

func next_line():
    current_line += 1
    show_line()

func finish():
    visible = false
    emit_signal("dialogue_finished")
```

## Usage

1. Create `dialogue.json` in your project
2. Add the child nodes to your existing scene
3. Attach the script to the parent node
4. Connect `dialogue_finished` signal to re-enable movement