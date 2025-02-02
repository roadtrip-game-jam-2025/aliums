extends Node2D

func _draw() -> void:
  var viewport_size = get_viewport().get_visible_rect().size
  var center = viewport_size / 2
  var line_length = 20
  draw_line(Vector2(center.x - line_length, center.y), Vector2(center.x + line_length, center.y), Color.WHITE)
  draw_line(Vector2(center.x, center.y - line_length), Vector2(center.x, center.y + line_length), Color.WHITE)
