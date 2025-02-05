extends Node

const NAMES = [
  "Jack",
  "Jill",
  "Kara",
  "Bree",
  "Carrie",
  "Meeve",
]

@export var display_name: String = NAMES[randi() % NAMES.size()]
@export var wants_coast: float = clamp(randf(), 0.0, 1.0)
@export var wants_trees: float = clamp(randf(), 0.0, 1.0)
@export var wants_snow: float = clamp(randf(), 0.0, 1.0)
@export var wants_rain: float = clamp(randf(), 0.0, 1.0)
@export var wants_desert: float = clamp(randf(), 0.0, 1.0)
