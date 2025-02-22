extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("changed", _on_changed)

func _on_changed() -> void:
  print("changed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
