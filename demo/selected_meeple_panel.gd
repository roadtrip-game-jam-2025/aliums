extends Panel

var meeple: Node3D
var dupe: Node3D

@onready var window: SubViewport = $SubViewportContainer/SubViewport
@onready var camera = $SubViewportContainer/SubViewport/Camera3D

func select_meeple(meeple: Node3D) -> void:
  if self.dupe:
    self.dupe.queue_free()
  self.meeple = meeple
  dupe = meeple.duplicate()
  dupe.freeze = true
  window.add_child(dupe)
  dupe.rotation.y = -PI / 2
  dupe.position = window.get_node("SelectTarget").position

func _physics_process(delta: float) -> void:
  if dupe:
    dupe.rotation.y += delta
