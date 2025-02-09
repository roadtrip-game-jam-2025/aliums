extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("pressed", _on_randomize_button_pressed)

func _on_randomize_button_pressed() -> void:
  var hair_color = Color(randf(), randf(), randf())
  var hair_color_picker = get_node("%HairColorPicker")
  hair_color_picker.emit_signal("color_changed", hair_color)
  hair_color_picker.color = hair_color

  var skin_color = Color(randf(), randf(), randf())
  var skin_color_picker = get_node("%SkinTonePicker")
  skin_color_picker.emit_signal("color_changed", skin_color)
  skin_color_picker.color = skin_color

  var animation_dropdown = get_node("%AnimationDropdown")
  animation_dropdown.select(randi() % animation_dropdown.get_item_count())
  animation_dropdown.emit_signal("item_selected", animation_dropdown.selected)
