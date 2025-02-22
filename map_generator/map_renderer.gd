extends Node2D

const TILE_WIDTH = 16

@onready var tile_map: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D
@onready var map_gen = $MapGenerator

var dragging = false
var drag_start_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  $MapGenerator.generate_map()
  redraw_map()
  camera.position = Vector2((map_gen.map_width * TILE_WIDTH) / 2.0, (map_gen.map_width * TILE_WIDTH) / 2.0)

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if Input.is_action_just_pressed("ui_up"):
    redraw_map()

func _physics_process(delta: float) -> void:
  # Get mouse position in world coordinates
  var mouse_pos = get_local_mouse_position()
  var map_x = int(mouse_pos.x / TILE_WIDTH)
  map_x -= map_gen.map_width / 2
  var map_y = int(mouse_pos.y / TILE_WIDTH)
  map_y -= map_gen.map_width / 2

  # Update tooltip text with map value
  var value = map_gen.generated_map.has(Vector2i(map_x, map_y))
  var tooltip_text = "water"
  if value:
    tooltip_text = "land"
  $Tooltip.text = tooltip_text
  $Tooltip.position = Vector2(mouse_pos.x, mouse_pos.y-32)

func redraw_map() -> void:
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
  print(tile_map.get_used_cells_by_id(1))
