extends Node3D

@onready var head: MeshInstance3D = $Anim_Base/Skeleton3D/Head
@onready var upper_body: MeshInstance3D = $Anim_Base/Skeleton3D/UpperBody
@onready var lower_body: MeshInstance3D = $Anim_Base/Skeleton3D/LowerBody
@onready var hair: MeshInstance3D = $Anim_Base/Skeleton3D/HairBone/Hair
@onready var left_shoe: MeshInstance3D = $Anim_Base/Skeleton3D/LeftFootBoneAttachment3D/LeftShoe
@onready var right_shoe: MeshInstance3D = $Anim_Base/Skeleton3D/RightFootBoneAttachment3D/RightShoe

@export var skin_tone: Color = Color(1, 1, 1)
@export var hair_color: Color = Color(1, 1, 1)

func _set_albedo(inst: MeshInstance3D, color: Color) -> void:
  for surface in inst.mesh.get_surface_count():
    var material = inst.mesh.surface_get_material(surface).duplicate()
    material.albedo_color = color
    inst.mesh.surface_set_material(surface, material)

func set_skin_tone(color: Color) -> void:
  skin_tone = color
  _set_albedo(head, color)
  _set_albedo(upper_body, color)
  _set_albedo(lower_body, color)

func set_hair_color(color: Color) -> void:
  hair_color = color
  _set_albedo(hair, color)

func start_animation(animation_name: String) -> void:
  $AnimationPlayer.play(animation_name)

func stop_animation() -> void:
  $AnimationPlayer.stop()

func get_animations() -> PackedStringArray:
  return $AnimationPlayer.get_animation_list()

func set_top(top: ArrayMesh) -> void:
  upper_body.mesh = top
  set_skin_tone(skin_tone)
  set_hair_color(hair_color)

func set_bottom(bottom: ArrayMesh) -> void:
  lower_body.mesh = bottom
  set_skin_tone(skin_tone)
  set_hair_color(hair_color)

func remove_shoes() -> void:
  left_shoe.mesh = null
  right_shoe.mesh = null

func set_shoes(l: ArrayMesh, r: ArrayMesh) -> void:
  left_shoe.mesh = l
  right_shoe.mesh = r
  set_skin_tone(skin_tone)
  set_hair_color(hair_color)
