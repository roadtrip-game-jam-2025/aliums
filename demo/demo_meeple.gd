extends RigidBody3D

func set_hair_color(color: Color) -> void:
  $Meeple.set_hair_color(color)

func get_attribute(attribute: String) -> Variant:
  return $MeepleAttributes.get(attribute)
