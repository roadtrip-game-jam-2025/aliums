extends Camera3D

func _physics_process(delta: float) -> void:
  var input_dir := Input.get_vector("ui_up", "ui_down", "ui_right", "ui_left")
  position += transform.basis.x * input_dir.y * delta * -10
  position += transform.basis.z * input_dir.x * delta * 10
  var mouse_motion = Input.get_last_mouse_velocity()
  rotation.y -= mouse_motion.x * delta * 0.001
  rotation.x -= mouse_motion.y * delta * 0.001
  rotation.x = clamp(rotation.x, -PI/2, PI/2)
