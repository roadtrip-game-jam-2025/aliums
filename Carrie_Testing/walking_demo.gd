extends Node3D

@export var char_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  for i in range(10):
    var c = char_scene.instantiate()
    c.position = Vector3(0, 0, i*2)
    var hair: MeshInstance3D = c.get_node("Armature/Skeleton3D/Hair_Med")
    var mat: StandardMaterial3D = StandardMaterial3D.new()
    mat.albedo_color = Color(randf(), randf(), randf())
    hair.material_override = mat

    var char_size = randf_range(0, 2)
    var skel = c.get_node("Armature/Skeleton3D")
    var meshes = skel.get_children()
    for mesh: MeshInstance3D in meshes:
      var dupe = mesh.duplicate()
      dupe.set_blend_shape_value(0, char_size)
      skel.add_child(dupe)
      mesh.queue_free()
    add_child(c)

    var ap: AnimationPlayer = c.get_node("AnimationPlayer")
    for a_name in ap.get_animation_list():
      var anim = ap.get_animation(a_name)
      anim.loop_mode = Animation.LOOP_LINEAR
      ap.play(a_name, -1, randf_range(0, 2))
