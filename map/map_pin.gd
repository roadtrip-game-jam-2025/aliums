extends Node2D

@export var color: Color = Color.BLACK
var map_coords: Vector2i

signal hovered(pin: Node2D)
signal unhovered(pin: Node2D)

func _ready() -> void:
  $Area2D.mouse_entered.connect(_on_mouse_entered)
  $Area2D.mouse_exited.connect(_on_mouse_exited)
  $Square.rotation = randf_range(0, TAU)
  $Marker.rotation = randf_range(0, TAU)

func set_map_coordinates(coords: Vector2i) -> void:
  map_coords = coords

func get_map_coordinates() -> Vector2i:
  return map_coords

func _on_mouse_entered() -> void:
  $Marker.visible = true
  hovered.emit(self)

func _on_mouse_exited() -> void:
  $Marker.visible = false
  unhovered.emit(self)
