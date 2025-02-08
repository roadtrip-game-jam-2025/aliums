extends Node3D

@export var hair_color: Color = Color(0.8, 0.5, 0.5)

func set_hair_color(color: Color) -> void:
  var m = $Hair.get_active_material(0).duplicate()
  m.albedo_color = color
  $Hair.material_override = m

func set_skin_tone(color: Color) -> void:
  var m = $Body.get_active_material(0).duplicate()
  m.albedo_color = color
  for mesh in [$Face, $Body, $Ears]:
    mesh.material_override = m
