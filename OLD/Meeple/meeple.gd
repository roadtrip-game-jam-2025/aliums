extends Node3D

@export var hair_color: Color = Color(0.8, 0.5, 0.5)

func set_hair_color(color: Color) -> void:
  var m = StandardMaterial3D.new()
  m.albedo_color = color
  $Hair.material_override = m
