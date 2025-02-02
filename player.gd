extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const ROTATION_SPEED = 0.06
@export var camera: Camera3D

func _ready() -> void:
  camera = $CameraController/CameraTarget/Camera3D
  camera.make_current()
  $CameraController.position = position
  $CameraController.look_at(position)
  $Mesh.material_overlay.albedo_color = Color(1, 0, 0, 0.25)

func _physics_process(delta: float) -> void:
  if $CameraController.position.distance_to(position) > 0.01:
    print_debug($CameraController.position, position)
  $CameraController.position = lerp($CameraController.position, position, 0.5)
  var angle_diff = fposmod(rotation.y - $CameraController.rotation.y + PI, TAU) - PI
  $CameraController.rotation.y += angle_diff * 0.5

  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  # Handle jump.
  if Input.is_action_just_pressed("ui_accept") and is_on_floor():
    velocity.y = JUMP_VELOCITY

  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  var rotation_amount := input_dir.x * ROTATION_SPEED
  rotation.y -= rotation_amount

  var direction := transform.basis.x * input_dir.y * -1  # Forward/back movement along facing direction
  if direction:
    velocity.x = direction.x * SPEED
    velocity.z = direction.z * SPEED
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)
    velocity.z = move_toward(velocity.z, 0, SPEED)

  move_and_slide()
