extends Node

signal skin_tone_changed(color: Color)
signal hair_color_changed(color: Color)

func _ready() -> void:
  connect("skin_tone_changed", _on_skin_tone_changed)
  connect("hair_color_changed", _on_hair_color_changed)

func _on_skin_tone_changed(color: Color) -> void:
  %Meeple.set_skin_tone(color)

func _on_hair_color_changed(color: Color) -> void:
  %Meeple.set_hair_color(color)
