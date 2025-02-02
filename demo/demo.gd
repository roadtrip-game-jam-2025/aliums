extends Node3D

func make_meeple() -> void:
  var ground_ray = PhysicsRayQueryParameters3D.create($Camera3D.global_position, $Camera3D.global_position + -$Camera3D.global_transform.basis.z * 1000)
  var space_state = get_world_3d().direct_space_state
  var collision = space_state.intersect_ray(ground_ray)
  var new_meeple = load("res://demo/demo_meeple.tscn").instantiate()
  new_meeple.set_hair_color(Color(randf(), randf(), randf()))
  new_meeple.position = collision.position if collision else $Camera3D.global_position
  add_child(new_meeple)

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
  var input_dir := Input.get_vector("ui_up", "ui_down", "ui_right", "ui_left")
  $Camera3D.position += $Camera3D.transform.basis.x * input_dir.y * delta * -10
  $Camera3D.position += $Camera3D.transform.basis.z * input_dir.x * delta * 10
  var mouse_motion = Input.get_last_mouse_velocity()
  $Camera3D.rotation.y -= mouse_motion.x * delta * 0.001
  $Camera3D.rotation.x -= mouse_motion.y * delta * 0.001
  $Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/2, PI/2)

  if Input.is_action_just_pressed("ui_cancel"):
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  if Input.is_action_just_pressed("ui_press"):
    make_meeple()
