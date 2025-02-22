extends Node2D

@export var altitude_noise: FastNoiseLite

enum TileType { LAND, SEA }

const TILE_SIZE = 5
@export var sea_level = 0.01
@export var center_weight = 1.0
@export var map_width = 128
@export var minimum_land_ratio = 0.5
@export var max_attempts = 100
@export var points_of_interest_count = 10

var generated_map: Dictionary = {}
var tiles: Dictionary = {}
var points_of_interest: Array[Vector2i] = []

func _ready() -> void:
  altitude_noise.seed = randi_range(0,2048)

func generate_continent() -> void:
  for m in range(map_width):
    for n in range(map_width):
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

func generate_terrain() -> void:
  for _i in range(max_attempts):
    altitude_noise.seed = randi_range(0,2048)
    tiles = {}
    generate_continent()
    var continent = largest_connected_land_component()
    tiles = {}
    for pos in continent.keys():
      tiles[pos] = TileType.LAND
    if continent.keys().size() > minimum_land_ratio * map_width * map_width:
      generated_map = tiles
      return
  assert(generated_map.keys().size() > 0, "Failed to generate terrain")

func _repel_points(points: Array[Vector2i], iterations: int = 10, repel_strength: float = 1.0) -> Array[Vector2i]:
  var repelled_points = points.duplicate()

  for _iter in range(iterations):
    var forces = []
    forces.resize(points_of_interest.size())

    # Calculate repulsion forces
    for i in range(repelled_points.size()):
      forces[i] = Vector2.ZERO
      for j in range(repelled_points.size()):
        if i == j:
          continue

        var diff = Vector2(repelled_points[i] - repelled_points[j])
        var dist = diff.length()
        if dist < 0.0001:
          diff = Vector2(randf_range(-1,1), randf_range(-1,1))
          dist = diff.length()

        forces[i] += diff.normalized() * repel_strength / (dist * dist)

    # Apply forces
    for i in range(repelled_points.size()):
      var new_pos = repelled_points[i] + Vector2i(forces[i])
      # Keep points on land
      if generated_map.has(new_pos):
        repelled_points[i] = new_pos

  return repelled_points

func generate_points_of_interest() -> void:
  points_of_interest.clear()
  for _i in range(points_of_interest_count):
    var random_pos = generated_map.keys().pick_random()
    points_of_interest.append(random_pos)

  points_of_interest = _repel_points(points_of_interest)

func generate_map() -> void:
  generate_terrain()
  generate_points_of_interest()

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
