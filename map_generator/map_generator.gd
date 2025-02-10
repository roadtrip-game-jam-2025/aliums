extends Node2D

@export var altitude_noise: FastNoiseLite

enum TileType { LAND, SEA }

const TILE_SIZE = 5
@export var sea_level = 0.01
@export var center_weight = 1.0
@export var map_width = 128
@export var minimum_land_ratio = 0.5
@export var max_attempts = 100

var generated_map: Dictionary = {}
var tiles: Dictionary = {}

func _ready() -> void:
  altitude_noise.seed = randi_range(0,2048)

func generate_continent() -> void:
  for m in map_width:
    for n in map_width:
      var x = n - map_width / 2.0
      var y = m - map_width / 2.0
      var value = altitude_value(x, y)
      tiles[Vector2i(int(x), int(y))] = value

func altitude_value(x: float, y: float) -> TileType:
    var value = altitude_noise.get_noise_2d(x, y)
    var center = Vector2(0,0)
    var distance = sqrt((x-center.x)*(x-center.x) + (y-center.y)*(y-center.y))
    value *= exp(-center_weight * distance / (map_width * 0.5))

    if value >= sea_level:
        return TileType.LAND

    return TileType.SEA

func generate_map() -> void:
  for _i in range(max_attempts):
    altitude_noise.seed = randi_range(0,2048)
    tiles = {}
    generate_continent()
    var continent = largest_connected_land_component()
    tiles = {}
    for pos in continent.keys():
      tiles[pos] = TileType.LAND
    if continent.keys().size() > minimum_land_ratio * map_width * map_width:
      generated_map = continent
      break
  assert(generated_map.keys().size() > 0, "Failed to generate map")

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
