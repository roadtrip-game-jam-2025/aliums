extends ColorPickerButton

@export var signal_name: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("color_changed", _on_color_changed)
  # Terrible hack; wait for the color picker to be ready
  await get_tree().create_timer(0.01).timeout
  %SkinToneManager.emit_signal(signal_name, color)

func _on_color_changed(new_color: Color) -> void:
  %SkinToneManager.emit_signal(signal_name, new_color)
