extends Node2D

@export var color: Color = Color.BLACK

func _ready() -> void:
  $Area2D.mouse_entered.connect(_on_mouse_entered)
  $Area2D.mouse_exited.connect(_on_mouse_exited)
  $Square.rotation = randf_range(0, TAU)
  $Marker.rotation = randf_range(0, TAU)

func _on_mouse_entered() -> void:
  $Marker.visible = true

func _on_mouse_exited() -> void:
  $Marker.visible = false
