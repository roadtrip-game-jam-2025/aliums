extends Node2D

const TILE_WIDTH = 16

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D
@onready var map_gen = $MapGenerator
@export var noise: FastNoiseLite

var dragging = false
var drag_start_pos = Vector2()
var pins: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $MapGenerator.generate_map()
  redraw_map()
  camera.position = to_world_coords(Vector2i.ZERO)

func to_world_coords(pos: Vector2i) -> Vector2:
  return Vector2(pos.x * TILE_WIDTH, pos.y * TILE_WIDTH) + Vector2(map_gen.map_width * TILE_WIDTH / 2.0, map_gen.map_width * TILE_WIDTH / 2.0)

func _draw() -> void:
  for src in map_gen.roads.keys():
    for dst in map_gen.roads[src]:
      draw_line(to_world_coords(src), to_world_coords(dst), Color.GREEN, 2)

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.button_index == MOUSE_BUTTON_LEFT:
      if event.pressed:
        dragging = true
        drag_start_pos = event.position
      else:
        dragging = false
  elif event is InputEventMouseMotion and dragging:
    camera.position -= event.relative

func _process(_delta: float) -> void:
  if Input.is_action_just_pressed("ui_up"):
    $MapGenerator.generate_map()
    redraw_map()
    camera.position = Vector2((map_gen.map_width * TILE_WIDTH) / 2.0, (map_gen.map_width * TILE_WIDTH) / 2.0)
  if Input.is_action_just_pressed("ui_scroll_up"):
    camera.zoom += Vector2(0.1, 0.1)
  if Input.is_action_just_pressed("ui_scroll_down"):
    camera.zoom -= Vector2(0.1, 0.1)

func redraw_map() -> void:
  for pin in pins:
    pin.queue_free()
  pins.clear()
  queue_redraw()

  noise.seed = randi()
  for ay in range(0, map_gen.map_width):
    for ax in range(0, map_gen.map_width):
      var n = 0
      var x = ax - map_gen.map_width / 2.0
      var y = ay - map_gen.map_width / 2.0
      if map_gen.altitude_value(x-0.5, y-0.5) == map_gen.TileType.LAND:
        n += 1
      if map_gen.altitude_value(x+0.5, y-0.5) == map_gen.TileType.LAND:
        n += 2
      if map_gen.altitude_value(x+0.5, y+0.5) == map_gen.TileType.LAND:
        n += 4
      if map_gen.altitude_value(x-0.5, y+0.5) == map_gen.TileType.LAND:
        n += 8
      tile_map.set_cell(Vector2i(ax, ay), 1, Vector2i(n, 0))

  for pos in map_gen.points_of_interest:
    var map_x = pos.x + map_gen.map_width / 2
    var map_y = pos.y + map_gen.map_width / 2
    var pin = load("res://map/map_pin.tscn").instantiate()
    pin.position = Vector2(map_x * TILE_WIDTH, map_y * TILE_WIDTH)
    add_child(pin)
    pins.append(pin)
