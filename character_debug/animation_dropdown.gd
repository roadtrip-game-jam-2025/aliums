extends OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  var animations = %Meeple.get_animations()
  for animation in animations:
    add_item(animation)
  connect("item_selected", _on_item_selected)
  %Meeple.start_animation(get_item_text(0))

func _on_item_selected(index: int) -> void:
  %Meeple.start_animation(get_item_text(index))

