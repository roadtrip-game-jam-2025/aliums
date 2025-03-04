extends Node3D

var paused = false

@onready var selected_meeple_panel: Panel = $SelectedMeeplePanel

func make_meeple(pos: Vector3) -> void:
  var new_meeple = load("res://character_selection_demo/demo_meeple.tscn").instantiate()
  new_meeple.set_hair_color(Color(randf(), randf(), randf()))
  new_meeple.position = pos
  add_child(new_meeple)

func _ready() -> void:
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  for n in range(10):
    make_meeple(Vector3(randf() * 10, 0, randf() * 10))

func select_meeple() -> Node:
  var ground_ray = PhysicsRayQueryParameters3D.create($DemoCamera.global_position, $DemoCamera.global_position + -$DemoCamera.global_transform.basis.z * 1000, 2)
  var space_state = get_world_3d().direct_space_state
  var collision = space_state.intersect_ray(ground_ray)
  if collision:
    return collision.collider
  return null

func _physics_process(delta: float) -> void:
  if Input.is_action_just_pressed("ui_cancel"):
    if paused:
      resume_game()
    else:
      pause_game()
  if Input.is_action_just_pressed("ui_press"):
    if !paused:
      var meeple = select_meeple()
      if meeple:
        pause_game()
        $PauseBox.visible = false
        selected_meeple_panel.select_meeple(meeple)
    else:
      resume_game()

  if paused:
    return

func pause_game() -> void:
  paused = true
  Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
  get_tree().paused = true
  $Crosshair.visible = false
  $PauseBox.visible = true

func resume_game() -> void:
  paused = false
  get_tree().paused = false
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  $Crosshair.visible = true
  $PauseBox.visible = false
  selected_meeple_panel.deselect_meeple()
