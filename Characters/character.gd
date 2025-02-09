extends Node3D

@onready var head: MeshInstance3D = $Anim_Base/Skeleton3D/Head
@onready var upper_body: MeshInstance3D = $Anim_Base/Skeleton3D/UpperBody
@onready var lower_body: MeshInstance3D = $Anim_Base/Skeleton3D/LowerBody
@onready var hair: MeshInstance3D = $Anim_Base/Skeleton3D/HairBone/Hair.get_child(0)

func _set_albedo(inst: MeshInstance3D, color: Color) -> void:
  for surface in inst.mesh.get_surface_count():
    var material = inst.mesh.surface_get_material(surface).duplicate()
    material.albedo_color = color
    inst.mesh.surface_set_material(surface, material)

func set_skin_tone(color: Color) -> void:
  _set_albedo(head, color)
  _set_albedo(upper_body, color)
  _set_albedo(lower_body, color)

func set_hair_color(color: Color) -> void:
  _set_albedo(hair, color)

func start_animation(animation_name: String) -> void:
  $AnimationPlayer.play(animation_name)

func stop_animation() -> void:
  $AnimationPlayer.stop()

func get_animations() -> PackedStringArray:
  return $AnimationPlayer.get_animation_list()
