extends Panel

var meeple: Node3D
var dupe: Node3D

@onready var window: SubViewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/Camera3D

func deselect_meeple() -> void:
  self.visible = false
  if dupe:
    dupe.queue_free()
    dupe = null

func select_meeple(m: Node3D) -> void:
  self.visible = true
  if self.dupe:
    self.dupe.queue_free()
  self.meeple = m
  dupe = meeple.duplicate()
  dupe.freeze = true
  window.add_child(dupe)
  dupe.rotation = Vector3(0, -PI/2, 0)
  dupe.position = window.get_node("SelectTarget").position
  %NameLabel.text = meeple.get_attribute("display_name")
  %NameLabel.position = camera.unproject_position(dupe.position)
  %NameLabel.position.x -= %NameLabel.size.x / 2
  %NameLabel.position.y += 50

func _physics_process(delta: float) -> void:
  if dupe:
    dupe.rotation.y += delta
