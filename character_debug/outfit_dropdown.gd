extends OptionButton

@export var piece_type: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  connect("item_selected", self.on_item_selected)

func on_item_selected(index: int) -> void:
  var outfit_manager = %OutfitManager
  outfit_manager.set_piece(piece_type, index)
