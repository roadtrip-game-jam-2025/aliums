extends Node2D

@export var altitude_noise: FastNoiseLite

enum TileType { LAND, SEA }

const TILE_SIZE = 5
@export var SEA_LEVEL = 0.01
@export var GAUSS_SIGMA = 1.0
const RENDER_DISTANCE = 128.0
@export var TARGET_LAND_RATIO = 0.5

var tiles: Dictionary = {}

func _ready() -> void:
  altitude_noise.seed = randi_range(0,2048)

func generate_continent() -> void:
  for m in RENDER_DISTANCE:
    for n in RENDER_DISTANCE:
      var x = n - RENDER_DISTANCE / 2.0
      var y = m - RENDER_DISTANCE / 2.0
      var value = altitude_value(x, y)
      tiles[Vector2i(x, y)] = value

func _draw() -> void:
  for n in range(RENDER_DISTANCE):
    # We divide by two so that half the tiles
    # generate left/above center and half right/below
    var x = n - RENDER_DISTANCE / 2.0

    for pos in tiles.keys():
      var color
      if tiles[pos] == TileType.LAND:
        color = Color(0.0, 1.0, 0.0)
      else:
        color = Color(0.0, 0.0, 1.0)
      var r = Rect2i(pos.x*TILE_SIZE, pos.y*TILE_SIZE, TILE_SIZE, TILE_SIZE)
      draw_rect(r, color)

func altitude_value(x: int, y: int) -> TileType:
    var value = altitude_noise.get_noise_2d(x, y)
    var center = Vector2(0,0)
    var distance = sqrt((x-center.x)*(x-center.x) + (y-center.y)*(y-center.y))
    value *= exp(-GAUSS_SIGMA * distance / (RENDER_DISTANCE * 0.5))

    if value >= SEA_LEVEL:
        return TileType.LAND

    return TileType.SEA

var running = true
func _process(_delta: float) -> void:
  if running:
    altitude_noise.seed = randi_range(0,2048)
    tiles = {}
    generate_continent()
    var continent = largest_connected_land_component()
    tiles = {}
    for pos in continent.keys():
      tiles[pos] = TileType.LAND
    queue_redraw()
    if continent.keys().size() > TARGET_LAND_RATIO * RENDER_DISTANCE * RENDER_DISTANCE:
      running = false
  if Input.is_action_just_pressed("ui_press"):
    running = not running

func largest_connected_land_component() -> Dictionary:
    var visited = {}
    var cur_component = {}
    var max_component = {}

    for pos in tiles.keys():
        if pos in visited or tiles[pos] != TileType.LAND:
            continue

        var stack = [pos]
        cur_component = {}

        while not stack.is_empty():
            var current = stack.pop_back()
            if current in visited:
                continue

            visited[current] = true
            cur_component[current] = tiles[current]
            # Check adjacent tiles (up, down, left, right)
            var neighbors = [
                Vector2i(current.x, current.y - 1),
                Vector2i(current.x, current.y + 1),
                Vector2i(current.x - 1, current.y),
                Vector2i(current.x + 1, current.y)
            ]

            for neighbor in neighbors:
                if neighbor in tiles and tiles[neighbor] == TileType.LAND and not neighbor in visited:
                    stack.push_back(neighbor)

        if cur_component.keys().size() > max_component.keys().size():
          max_component = cur_component

    return max_component
