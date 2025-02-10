extends Node

var piece_types = {}

func load_outfits() -> void:
  piece_types = {
    "Tops": {
      "array": [],
      "dropdown": %TopDropdown
    },
    "Bottoms": {
      "array": [],
      "dropdown": %BottomDropdown
    },
    "Shoes": {
      "array": [],
      "dropdown": %ShoesDropdown
    }
  }
  for piece_type in ["Tops", "Bottoms"]:
    for file_name in DirAccess.get_files_at("res://Characters/CharacterPieces/" + piece_type):
      if file_name.ends_with(".res"):
        var piece = load("res://Characters/CharacterPieces/" + piece_type + "/" + file_name)
        piece_types[piece_type]["array"].append(piece)
        piece_types[piece_type]["dropdown"].add_item(file_name)
    print("Loaded %s %s" % [piece_types[piece_type].size(), piece_type])

  var shoes_dir = DirAccess.get_files_at("res://Characters/CharacterPieces/Shoes")
  var grouped_shoes = {}
  for file_name in shoes_dir:
    if file_name.ends_with(".res"):
      var shoe_name_with_side = file_name.replace(".res", "")
      var array_shoe_name = shoe_name_with_side.split("_").slice(0, -1)
      var shoe_name = ""
      for n in array_shoe_name:
        shoe_name += n + "_"
      shoe_name = shoe_name.rstrip("_")
      if !grouped_shoes.has(shoe_name):
        grouped_shoes[shoe_name] = {}
      var side = shoe_name_with_side.split("_").slice(-1)[0]
      grouped_shoes[shoe_name][side] = load("res://Characters/CharacterPieces/Shoes/" + file_name)
  piece_types["Shoes"]["dropdown"].add_item("None")
  for shoe_name in grouped_shoes:
    piece_types["Shoes"]["array"].append(grouped_shoes[shoe_name])
    piece_types["Shoes"]["dropdown"].add_item(shoe_name)
  print("Loaded %s Shoes" % piece_types["Shoes"]["array"].size())

func _ready() -> void:
  load_outfits()

func set_piece(piece_type: String, index: int) -> void:
  var character = %Meeple
  print(piece_type, index)
  match piece_type:
    "Tops":
      character.set_top(piece_types[piece_type]["array"][index])
    "Bottoms":
      character.set_bottom(piece_types[piece_type]["array"][index])
    "Shoes":
      if index == 0:
        character.remove_shoes()
      else:
        var shoes = piece_types[piece_type]["array"][index - 1]
        character.set_shoes(shoes["L"], shoes["R"])
    _:
      print("Invalid piece type: %s" % piece_type)
