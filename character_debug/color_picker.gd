extends ColorPicker

@export var change_signal: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("color_changed", _on_color_changed)

func _on_color_changed(new_color: Color) -> void:
  get_parent().color = new_color
  %SkinToneManager.emit_signal(change_signal, new_color)
